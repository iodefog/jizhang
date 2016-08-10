//
//  SSJCircleChargeStore.m
//  SuiShouJi
//
//  Created by ricky on 16/5/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCircleChargeStore.h"
#import "SSJDatabaseQueue.h"
#import "SSJChargeMemBerItem.h"

@implementation SSJCircleChargeStore
+ (void)queryForChargeListWithSuccess:(void(^)(NSArray<SSJBillingChargeCellItem *> *result))success
                              failure:(void (^)(NSError *error))failure {
    __block NSString *booksId = SSJGetCurrentBooksType();
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSMutableArray *chargeList = [NSMutableArray array];
        FMResultSet *chargeResult = [db executeQuery:@"select a.* , b.CCOIN , b.CNAME , b.CCOLOR , b.ITYPE as INCOMEOREXPENSE , b.ID , c.cbooksname , d.cacctname , d.cicoin from BK_CHARGE_PERIOD_CONFIG as a, BK_BILL_TYPE as b , bk_books_type as c , bk_fund_info as d where a.CUSERID = ? and a.OPERATORTYPE != 2 and a.IBILLID = b.ID and c.cbooksid = ? and a.cbooksid = c.cbooksid and c.cuserid = a.cuserid and a.ifunsid = d.cfundid order by A.ITYPE ASC , A.IMONEY DESC",userid,booksId];
        if (!chargeResult) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        while ([chargeResult next]) {
            SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
            item.imageName = [chargeResult stringForColumn:@"CCOIN"];
            item.typeName = [chargeResult stringForColumn:@"CNAME"];
            item.money = [chargeResult stringForColumn:@"IMONEY"];
            item.colorValue = [chargeResult stringForColumn:@"CCOLOR"];
            item.incomeOrExpence = [chargeResult boolForColumn:@"INCOMEOREXPENSE"];
            item.fundId = [chargeResult stringForColumn:@"IFUNSID"];
            item.editeDate = [chargeResult stringForColumn:@"CWRITEDATE"];
            item.billId = [chargeResult stringForColumn:@"IBILLID"];
            item.chargeImage = [chargeResult stringForColumn:@"CIMGURL"];
            item.chargeMemo = [chargeResult stringForColumn:@"CMEMO"];
            item.configId = [chargeResult stringForColumn:@"ICONFIGID"];
            item.billDate = [chargeResult stringForColumn:@"CBILLDATE"];
            item.booksName = [chargeResult stringForColumn:@"CBOOKSNAME"];
            item.isOnOrNot = [chargeResult boolForColumn:@"ISTATE"];
            item.chargeCircleType = [chargeResult intForColumn:@"ITYPE"];
            item.fundName = [chargeResult stringForColumn:@"CACCTNAME"];
            item.fundImage = [chargeResult stringForColumn:@"cicoin"];
            NSString *memberStr = [chargeResult stringForColumn:@"CMEMBERIDS"];
            item.membersItem = [NSMutableArray arrayWithCapacity:0];
            if (!memberStr.length) {
                memberStr = [NSString stringWithFormat:@"%@-0",userid];
            }
            NSArray *idArr = [memberStr componentsSeparatedByString:@","];
            for (NSString *memberId in idArr) {
                SSJChargeMemberItem *memberItem = [[SSJChargeMemberItem alloc]init];
                memberItem.memberId = memberId;
                memberItem.memberName = [db stringForQuery:@"select cname from bk_member where cmemberid = ? and cuserid = ?",memberId,userid];
                memberItem.memberColor = [db stringForQuery:@"select ccolor from bk_member where cmemberid = ? and cuserid = ?",memberId,userid];
                [item.membersItem addObject:memberItem];
            }
            [chargeList addObject:item];
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(chargeList);
            });
        }
    }];
}

+ (void)queryDefualtItemWithIncomeOrExpence:(BOOL)incomeOrExpence
                                    Success:(void(^)(SSJBillingChargeCellItem *item))success
                              failure:(void (^)(NSError *error))failure {
    __block NSString *booksId = SSJGetCurrentBooksType();
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc]init];
        item.billDate = [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"];
        item.billId = [db stringForQuery:@"select a.id from bk_bill_type as a , bk_user_bill as b where b.istate = 1 and b.cuserid = ? and a.id = b.cbillid and a.itype = ? order by b.iorder limit 1",userid,@(incomeOrExpence)];
        item.typeName = [db stringForQuery:@"select cname from bk_bill_type where id = ?",item.billId];
        item.booksName = [db stringForQuery:@"select cbooksname from bk_books_type where cbooksid = ?",booksId];
        item.fundId = [db stringForQuery:@"select cfundid from bk_fund_info where cuserid = ? and operatortype <> 2 order by iorder limit 1",userid];
        item.fundName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ?",item.fundId];
        item.fundImage = [db stringForQuery:@"select cicoin from bk_fund_info where cfundid = ?",item.fundId ];
        item.imageName = [db stringForQuery:@"select ccoin from bk_bill_type where id = ?",item.billId];
        SSJChargeMemberItem *memberItem = [[SSJChargeMemberItem alloc]init];
        memberItem.memberId = [NSString stringWithFormat:@"%@-0",userid];
        memberItem.memberName = @"我";
        item.membersItem = [@[memberItem] mutableCopy];
        item.chargeCircleType = 0;
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(item);
            });
        }

    }];
}

+ (SSJBillingChargeCellItem *)chargeItemWithResultSet:(FMResultSet *)set inDatabase:(FMDatabase *)db {
    SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
    item.imageName = [set stringForColumn:@"CCOIN"];
    item.typeName = [set stringForColumn:@"CNAME"];
    item.money = [set stringForColumn:@"IMONEY"];
    item.colorValue = [set stringForColumn:@"CCOLOR"];
    item.incomeOrExpence = [set boolForColumn:@"INCOMEOREXPENSE"];
    item.fundId = [set stringForColumn:@"IFUNSID"];
    item.editeDate = [set stringForColumn:@"CWRITEDATE"];
    item.billId = [set stringForColumn:@"IBILLID"];
    item.chargeImage = [set stringForColumn:@"CIMGURL"];
    item.chargeMemo = [set stringForColumn:@"CMEMO"];
    item.configId = [set stringForColumn:@"ICONFIGID"];
    item.billDate = [set stringForColumn:@"CBILLDATE"];
    item.booksName = [set stringForColumn:@"CBOOKSNAME"];
    item.isOnOrNot = [set boolForColumn:@"ISTATE"];
    item.chargeCircleType = [set intForColumn:@"ITYPE"];
    item.fundName = [set stringForColumn:@"CACCTNAME"];
    return item;
}

+ (void)saveCircleChargeItem:(SSJBillingChargeCellItem *)item
                     success:(void(^)())success
                     failure:(void (^)(NSError *error))failure {
    NSString *booksid = SSJGetCurrentBooksType();
    if (!item.booksId.length) {
        item.booksId = booksid;
    }
    if (!item.configId.length) {
        item.configId = SSJUUID();
    }
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback){
        NSString *userid = SSJUSERID();
        NSString *cwriteDate = [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSMutableArray *membersIdArr = [NSMutableArray arrayWithCapacity:0];
        for (SSJChargeMemberItem *memberItem in item.membersItem) {
            [membersIdArr addObject:memberItem.memberId];
        }
        if (item.chargeImage.length && ![item.chargeImage hasSuffix:@".jpg"] && ![item.chargeImage hasSuffix:@".webp"]) {
            item.chargeImage = [NSString stringWithFormat:@"%@.jpg",item.chargeImage];
        }
        if (item.chargeThumbImage.length && ![item.chargeThumbImage hasSuffix:@".jpg"] && ![item.chargeImage hasSuffix:@".webp"]) {
            item.chargeThumbImage = [NSString stringWithFormat:@"%@.jpg",item.chargeThumbImage];
        }
        NSString *membersStr = [membersIdArr componentsJoinedByString:@","];
        NSString *originImageName = [db stringForQuery:@"select cimgurl from bk_charge_period_config where iconfigid = ?",item.configId];
        //如果有图片,插入图片表
        if (![item.chargeImage isEqualToString:originImageName]) {
            if (item.chargeImage.length) {
                if (![db executeUpdate:@"insert into bk_img_sync (rid,cimgname,cwritedate,operatortype,isynctype,isyncstate) values (?,?,?,0,0,0)",item.configId,item.chargeImage,cwriteDate]) {
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                    *rollback = YES;
                }
            }
        }
        //插入周期记账表
        if (![db intForQuery:@"select count(1) from bk_charge_period_config where iconfigid = ?",item.configId]) {
            if (![db executeUpdate:@"insert into bk_charge_period_config (iconfigid, cuserid, ibillid, ifunsid, itype, imoney, cimgurl, cmemo, cbilldate, istate, iversion, cwritedate, operatortype, cbooksid, cmemberids) values (?,?,?,?,?,?,?,?,?,1,?,?,0,?,?)",item.configId,userid,item.billId,item.fundId,@(item.chargeCircleType),@([item.money doubleValue]),item.chargeImage,item.chargeMemo,item.billDate,@(SSJSyncVersion()),cwriteDate,booksid,membersStr]) {
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
                *rollback = YES;
            }
            //如果是今天的周期记账,插入一条流水
            if ([item.billDate isEqualToString:[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]]) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *date = [formatter dateFromString:item.billDate];
                NSLog(@"%ld",date.weekday);
                if (item.chargeCircleType == 1 && (date.weekday == 1 || date.weekday == 7)) {
                    
                }else if (item.chargeCircleType == 2 && (date.weekday != 1 && date.weekday != 7)) {
                    
                }else if (item.chargeCircleType == 5 && date.day != date.daysInMonth) {
                    
                }else{
                    NSString *chargeId = SSJUUID();
                    //修改流水表
                    if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, ibillid, ifunsid, iconfigid, imoney, cimgurl, thumburl, cmemo, cbilldate, iversion, cwritedate, operatortype, cbooksid) values (?,?,?,?,?,?,?,?,?,?,?,?,0,?)",chargeId,userid,item.billId,item.fundId,item.configId,@([item.money doubleValue]),item.chargeImage,item.chargeThumbImage,item.chargeMemo,item.billDate,@(SSJSyncVersion()),cwriteDate,booksid]) {
                        if (failure) {
                            SSJDispatch_main_async_safe(^{
                                failure([db lastError]);
                            });
                        }
                        *rollback = YES;
                    }
                    //修改成员流水
                    for (NSString *memberId in membersIdArr) {
                        if (![db executeUpdate:@"insert into bk_member_charge (ichargeid, imoney, iversion, cwritedate, operatortype, cmemberid) values (?,?,?,?,0,?)",chargeId,@([item.money doubleValue] / item.membersItem.count),@(SSJSyncVersion()),cwriteDate,memberId]) {
                            if (failure) {
                                SSJDispatch_main_async_safe(^{
                                    failure([db lastError]);
                                });
                            }
                            *rollback = YES;
                        }
                    }
                    //修改每日汇总表
                    if (!item.incomeOrExpence) {
                        if ([db intForQuery:@"select count(1) from bk_dailysum_charge where cbilldate = ? and cbooksid = ?",item.billDate,item.booksId]) {
                            if (![db executeUpdate:@"update bk_dailysum_charge set expenceamount = expenceamount + ? , sumamount = sumamount - ? where cbooksid = ? and cbilldate = ? and cuserid = ?",@([item.money doubleValue]),@([item.money doubleValue]),item.booksId,item.billDate,userid]) {
                                if (failure) {
                                    SSJDispatch_main_async_safe(^{
                                        failure([db lastError]);
                                    });
                                }
                                *rollback = YES;
                            }
                        }else{
                            if (![db executeUpdate:@"insert into bk_dailysum_charge (cbilldate , expenceamount , incomeamount  , sumamount , cwritedate , cuserid ,cbooksid) values(?,?,0,?,?,?,?)",item.billDate,@([item.money doubleValue]),@(-[item.money doubleValue]),cwriteDate,userid,item.booksId]) {
                                if (failure) {
                                    SSJDispatch_main_async_safe(^{
                                        failure([db lastError]);
                                    });
                                }
                                *rollback = YES;
                            }
                        }
                    }else{
                        if ([db intForQuery:@"select count(1) from bk_dailysum_charge where cbilldate = ? and cbooksid = ?",item.billDate,item.booksId]) {
                            if (![db executeUpdate:@"update bk_dailysum_charge set incomeamount = incomeamount + ? , sumamount = sumamount + ? where cbooksid = ? and cbilldate = ? and cuserid = ?",@([item.money doubleValue]),@([item.money doubleValue]),item.booksId,item.billDate,userid]) {
                                if (failure) {
                                    SSJDispatch_main_async_safe(^{
                                        failure([db lastError]);
                                    });
                                }
                                *rollback = YES;
                            }
                        }else{
                            if (![db executeUpdate:@"insert into bk_dailysum_charge (cbilldate , expenceamount , incomeamount, sumamount , cwritedate , cuserid ,cbooksid) values(?,0,?,?,?,?,?)",item.billDate,@([item.money doubleValue]),@(-[item.money doubleValue]),cwriteDate,userid,item.booksId]) {
                                if (failure) {
                                    SSJDispatch_main_async_safe(^{
                                        failure([db lastError]);
                                    });
                                }
                                *rollback = YES;
                            }
                        }
                    }
                    //修改账户余额表
                    if (!item.incomeOrExpence) {
                        if (![db executeUpdate:@"update bk_funs_acct set ibalance = ibalance - ? where cfundid = ?",@([item.money doubleValue]),item.fundId]) {
                            if (failure) {
                                SSJDispatch_main_async_safe(^{
                                    failure([db lastError]);
                                });
                            }
                            *rollback = YES;
                        }
                    }else{
                        if (![db executeUpdate:@"update bk_funs_acct set ibalance = ibalance + ? where cfundid = ?",item.money,item.fundId]) {
                            if (failure) {
                                SSJDispatch_main_async_safe(^{
                                    failure([db lastError]);
                                });
                            }
                            *rollback = YES;
                        }
                    }
                }
            }else{
                NSString *chargeId = SSJUUID();
                //修改流水表
                if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, ibillid, ifunsid, iconfigid, imoney, cimgurl, thumburl, cmemo, cbilldate, iversion, cwritedate, operatortype, cbooksid) values (?,?,?,?,?,?,?,?,?,?,?,?,0,?)",chargeId,userid,item.billId,item.fundId,item.configId,@([item.money doubleValue]),item.chargeImage,item.chargeThumbImage,item.chargeMemo,item.billDate,@(SSJSyncVersion()),cwriteDate,booksid]) {
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                    *rollback = YES;
                }
                //修改成员流水
                for (NSString *memberId in membersIdArr) {
                    if (![db executeUpdate:@"insert into bk_member_charge (ichargeid, imoney, iversion, cwritedate, operatortype, cmemberid) values (?,?,?,?,0,?)",chargeId,@([item.money doubleValue] / item.membersItem.count),@(SSJSyncVersion()),cwriteDate,memberId]) {
                        if (failure) {
                            SSJDispatch_main_async_safe(^{
                                failure([db lastError]);
                            });
                        }
                        *rollback = YES;
                    }
                }
            }
        }else{
            //修改周期记账
            if (![db executeUpdate:@"update bk_charge_period_config set ibillid = ? ,ifunsid = ? ,itype = ? ,imoney = ?,cimgurl = ?,cmemo = ?,cbilldate = ?,iversion = ?,cwritedate = ?,operatortype = 1 , cmemberids = ? where cuserid = ? and cbooksid = ? and iconfigid = ?",item.billId,item.fundId,@(item.chargeCircleType),item.money,item.chargeImage,item.chargeMemo,item.billDate,@(SSJSyncVersion()),cwriteDate,membersStr,userid,item.booksId,item.configId]) {
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
                *rollback = YES;
            }
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
    }];
}

@end
