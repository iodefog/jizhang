//
//  SSJRecordMakingStore.m
//  SuiShouJi
//
//  Created by ricky on 16/6/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingStore.h"
#import "SSJDatabaseQueue.h"

@implementation SSJRecordMakingStore

+ (void)saveChargeWithChargeItem:(SSJBillingChargeCellItem *)item
                                          Success:(void(^)(SSJBillingChargeCellItem *editeItem))success
                                          failure:(void (^)())failure {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *userId = SSJUSERID();
        NSString *editeTime = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
                
        if (!item.booksId.length) {
            item.booksId = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userId];
        }
        if (!item.booksId.length) {
            item.booksId = userId;
        }
        
        if (![item isKindOfClass:[SSJBillingChargeCellItem class]]) {
            return;
        }
        if (!item.ID.length) {
            item.ID = SSJUUID();
        }
        
        if (item.chargeImage.length && !item.chargeThumbImage.length) {
            NSString *imageName = [item.chargeImage copy];
            if (![item.chargeImage hasSuffix:@".jpg"]) {
                item.chargeImage = [NSString stringWithFormat:@"%@.jpg",imageName];
            }
            item.chargeThumbImage = [NSString stringWithFormat:@"%@-thumb.jpg",imageName];
        }
        SSJBillingChargeCellItem *editeItem = [[SSJBillingChargeCellItem alloc]init];
        double money = [item.money doubleValue];
        NSString *moneyStr = [NSString stringWithFormat:@"%.2f",[item.money doubleValue]];
        if (![db executeUpdate:@"update bk_user set lastselectfundid = ? where cuserid = ?",item.fundId,userId]) {
            *rollback = YES;
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        if (![db intForQuery:@"select count(1) from bk_user_charge where cuserid = ? and ichargeid = ?",userId,item.ID]) {
            editeItem = item;
            editeItem.operatorType = 0;
            //新建流水
            if (![db executeUpdate:@"insert into bk_user_charge (ichargeid , cuserid , imoney , ibillid , ifunsid  , cwritedate , iversion , operatortype , cbilldate , cmemo , cbooksid, cimgurl, thumburl, clientadddate, cdetaildate, ichargetype, cid) values(?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?, ?, ?, ?, ?, ?, ?)",item.ID,userId,moneyStr,item.billId,item.fundId,editeTime,@(SSJSyncVersion()),item.billDate,item.chargeMemo,item.booksId,item.chargeImage,item.chargeThumbImage,editeTime,item.billDetailDate, @(item.idType), item.sundryId]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
            //修改图片同步表
            if (item.chargeImage.length) {
                if (![db executeUpdate:@"insert into bk_img_sync (rid , cimgname , cwritedate , operatortype , isynctype , isyncstate) values (?,?,?,0,0,0)",item.ID,item.chargeImage,[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"]]) {
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                }
            }
            //修改成员流水表
            for (SSJChargeMemberItem *memberItem in item.membersItem) {
                if (![db executeUpdate:@"insert into bk_member_charge (ichargeid ,cmemberid ,cwritedate ,operatortype,iversion) values(?,?,?,0,?)",item.ID,memberItem.memberId,editeTime,@(SSJSyncVersion())]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                }
            }
            if (![db executeUpdate:@"update bk_member_charge set imoney = ? where ichargeid = ?",@(money / item.membersItem.count),item.ID]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
        }else{
            editeItem = item;
            editeItem.operatorType = 1;
            //修改流水
            FMResultSet *originResult = [db executeQuery:@"select a.cbilldate , a.imoney , a.ichargeid , a.ibillid , a.cwritedate , a.ifunsid , a.cuserid , a.cmemo ,  a.cimgurl , a.thumburl , a.cid, a.ichargetype , a.operatortype , a.cbooksid , b.itype from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.ichargeid = ? and a.cuserid = ?",item.ID,userId];
            SSJBillingChargeCellItem *originItem = [[SSJBillingChargeCellItem alloc]init];
            while ([originResult next]) {
                originItem.money = [originResult stringForColumn:@"IMONEY"];
                originItem.fundId = [originResult stringForColumn:@"IFUNSID"];
                originItem.editeDate = [originResult stringForColumn:@"CWRITEDATE"];
                originItem.billId = [originResult stringForColumn:@"IBILLID"];
                originItem.chargeImage = [originResult stringForColumn:@"CIMGURL"];
                originItem.chargeThumbImage = [originResult stringForColumn:@"THUMBURL"];
                originItem.chargeMemo = [originResult stringForColumn:@"CMEMO"];
                if ([originResult intForColumn:@"ichargetype"] == SSJChargeIdTypeCircleConfig) {
                    originItem.sundryId = [originResult stringForColumn:@"cid"];
                }
                originItem.billDate = [originResult stringForColumn:@"CBILLDATE"];
                originItem.incomeOrExpence = [originResult intForColumn:@"ITYPE"];
                originItem.booksId = [originResult stringForColumn:@"CBOOKSID"];
                if (!originItem.booksId.length) {
                    originItem.booksId = userId;
                }
            }
            [originResult close];

            //更新流水表
            if (![db executeUpdate:@"update bk_user_charge set imoney = ? , ibillid = ? , ifunsid = ? , cwritedate = ? , operatortype = 1 , cbilldate = ? , iversion = ? , cmemo = ?  ,cimgurl = ? , thumburl = ?, cbooksid = ?, cdetaildate = ?, ichargetype = ?, cid = ? where ichargeid = ? and cuserid = ?", moneyStr, item.billId, item.fundId, [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], item.billDate, @(SSJSyncVersion()), item.chargeMemo, item.chargeImage, item.chargeThumbImage, item.booksId,item.billDetailDate, @(item.idType), item.sundryId, item.ID,userId]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
            if (item.chargeImage.length) {
                if (![item.chargeImage isEqualToString:originItem.chargeImage]) {
                    if (![db intForQuery:@"select count(1) from bk_img_sync where cimgname = ?",item.chargeImage]) {
                        //修改图片同步表
                        if (![db executeUpdate:@"insert into bk_img_sync (rid , cimgname , cwritedate , operatortype , isynctype , isyncstate) values (?,?,?,0,0,0)",item.ID,item.chargeImage,[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"]]) {
                            if (failure) {
                                SSJDispatch_main_async_safe(^{
                                    failure([db lastError]);
                                });
                            }
                            return;
                        }
                    }
                }
            }
            //删掉已经被删掉的图片
            if (originItem.chargeImage.length && item.chargeImage.length && ![item.chargeImage isEqualToString:originItem.chargeImage]) {
                [[NSFileManager defaultManager] removeItemAtPath:SSJImagePath(originItem.chargeImage) error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:SSJImagePath(originItem.chargeThumbImage) error:nil];
                [db executeUpdate:@"delete from BK_IMG_SYNC where CIMGNAME = ?",originItem.chargeImage];
            }
            //修改成员流水表
            if (![db executeUpdate:@"delete from bk_member_charge where ichargeid = ?",item.ID]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
            for (SSJChargeMemberItem *memberItem in item.membersItem) {
                if (![db executeUpdate:@"insert into bk_member_charge (ichargeid ,cmemberid ,cwritedate ,operatortype,iversion) values(?,?,?,0,?)",item.ID,memberItem.memberId,editeTime,@(SSJSyncVersion())]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                }
            }
            if (![db executeUpdate:@"update bk_member_charge set imoney = ? where ichargeid = ?",@(money / item.membersItem.count),item.ID]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(editeItem);
            });
        }
    }];
}

@end
