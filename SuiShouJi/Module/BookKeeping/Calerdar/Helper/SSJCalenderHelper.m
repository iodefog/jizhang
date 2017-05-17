//
//  SSJCalenderHelper.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCalenderHelper.h"
#import "SSJDatabaseQueue.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJChargeMemberItem.h"

@implementation SSJCalenderHelper
+ (void)queryDataInYear:(NSInteger)year
                          month:(NSInteger)month
                        success:(void (^)(NSMutableDictionary *data))success
                        failure:(void (^)(NSError *error))failure {
    
    if (year == 0 || month > 12) {
        SSJPRINT(@"class:%@\n method:%@\n message:(year == 0 || month > 12)",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        failure(nil);
        return;
    }
    NSString *dateStr = [NSString stringWithFormat:@"%04ld-%02ld-__",(long)year,(long)month];
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSString *booksid = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userid];
        if (!booksid.length) {
            booksid = userid;
        }
        FMResultSet *resultSet = [db executeQuery:@"select a.*, b.CNAME, b.CCOIN, b.CCOLOR, b.ITYPE from BK_USER_CHARGE as a, BK_BILL_TYPE as b where a.IBILLID = b.ID and a.CBILLDATE like ? and a.CUSERID = ? and a.OPERATORTYPE <> 2 and b.istate <> 2 and a.cbooksid = ? order by a.CBILLDATE desc, a.cdetaildate desc, a.cwritedate desc", dateStr,userid,booksid];
        if (!resultSet) {
            SSJPRINT(@"class:%@\n method:%@\n message:%@\n error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorMessage], [db lastError]);
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
        while ([resultSet next]) {
            SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
            item.imageName = [resultSet stringForColumn:@"CCOIN"];
            item.typeName = [resultSet stringForColumn:@"CNAME"];
            item.money = [resultSet stringForColumn:@"IMONEY"];
            item.colorValue = [resultSet stringForColumn:@"CCOLOR"];
            item.incomeOrExpence = [resultSet boolForColumn:@"ITYPE"];
            item.ID = [resultSet stringForColumn:@"ICHARGEID"];
            item.fundId = [resultSet stringForColumn:@"IFUNSID"];
            item.billDate = [resultSet stringForColumn:@"CBILLDATE"];
            item.editeDate = [resultSet stringForColumn:@"CWRITEDATE"];
            item.billId = [resultSet stringForColumn:@"IBILLID"];
            item.chargeMemo = [resultSet stringForColumn:@"cmemo"];
            item.chargeImage = [resultSet stringForColumn:@"cimgurl"];
            item.chargeThumbImage = [resultSet stringForColumn:@"thumburl"];
            item.idType = [resultSet intForColumn:@"ichargetype"];
            item.billDetailDate = [resultSet stringForColumn:@"cdetaildate"];
            if (item.idType == SSJChargeIdTypeCircleConfig) {
                item.configId = [resultSet stringForColumn:@"cid"];
            }
            NSString *billDate = [resultSet stringForColumn:@"CBILLDATE"];
            item.booksId = [resultSet stringForColumn:@"cbooksid"];
            if ([result objectForKey:billDate] == nil) {
                NSMutableArray *items = [[NSMutableArray alloc]init];
                [items addObject:item];
                [result setObject:items forKey:billDate];
            }else{
                NSMutableArray *items = [result objectForKey:billDate];
                [items addObject:item];
                [result setObject:items forKey:billDate];
            }
        }
        SSJDispatch_main_async_safe(^{
            success(result);
        });
    }];
}

+ (void)queryBalanceForDate:(NSString*)date
             success:(void (^)(double income , double expence))success
             failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        double income = 0;
        double expence = 0;
        NSString *userId = SSJUSERID();
        NSString *booksid = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userId];
        if (!booksid.length) {
            booksid = userId;
        }
        FMResultSet *result = [db executeQuery:@"SELECT * FROM BK_DAILYSUM_CHARGE WHERE CBILLDATE = ? AND CUSERID = ? and cbooksid = ?",date,userId,booksid];
        if (!result) {
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        while ([result next]) {
            income = [result doubleForColumn:@"INCOMEAMOUNT"];
            expence = [result doubleForColumn:@"EXPENCEAMOUNT"];
        }
        SSJDispatch_main_async_safe(^{
            success(income,expence);
        });
    }];
}

+ (void)queryChargeDetailWithId:(NSString *)chargeId
                        success:(void (^)(SSJBillingChargeCellItem *chargeItem))success
                        failure:(void(^)(NSError *error))failure {
    if (!chargeId.length) {
        if (failure) {
            SSJDispatchMainAsync(^{
                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"参数chargeId无效"}]);
            });
        }
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db){
        
        FMResultSet *chargeResult = [db executeQuery:@"select a.* , b.* , c.cacctname , d.cbooksname from bk_user_charge a , bk_bill_type b , bk_fund_info c , bk_books_type d where a.ichargeid = ? and a.cuserid = ?  and a.ibillid = b.id and a.ifunsid = c.cfundid and a.cbooksid = d.cbooksid", chargeId, SSJUSERID()];
        if (!chargeResult) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
        while ([chargeResult next]) {
            item.billId = [chargeResult stringForColumn:@"IBILLID"];
            item.imageName = [chargeResult stringForColumn:@"CCOIN"];
            item.typeName = [chargeResult stringForColumn:@"CNAME"];
            item.money = [chargeResult stringForColumn:@"IMONEY"];
            item.chargeImage = [chargeResult stringForColumn:@"CIMGURL"];
            item.chargeMemo = [chargeResult stringForColumn:@"CMEMO"];
            item.billDate = [chargeResult stringForColumn:@"CBILLDATE"];
            item.fundId = [chargeResult stringForColumn:@"IFUNSID"];
            item.fundName = [chargeResult stringForColumn:@"cacctname"];
            item.colorValue = [chargeResult stringForColumn:@"CCOLOR"];
            item.incomeOrExpence = [chargeResult boolForColumn:@"ITYPE"];
            item.billDetailDate = [chargeResult stringForColumn:@"cdetaildate"];
            item.booksId = [chargeResult stringForColumn:@"cbooksid"];
            item.booksId = item.booksId.length ? item.booksId : SSJUSERID();
            item.booksName = [chargeResult stringForColumn:@"cbooksname"];
        }
        [chargeResult close];
        
        FMResultSet *memberResult = [db executeQuery:@"select a.* , b.* from bk_member_charge as a , bk_member as b where a.ichargeid = ? and a.cmemberid = b.cmemberid and b.cuserid = ?", chargeId, SSJUSERID()];
        if (!chargeResult) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSMutableArray *memberItems = [NSMutableArray arrayWithCapacity:0];
        while ([memberResult next]) {
            SSJChargeMemberItem *memberItem = [[SSJChargeMemberItem alloc]init];
            memberItem.memberId = [memberResult stringForColumn:@"cmemberId"];
            memberItem.memberName = [memberResult stringForColumn:@"cname"];
            memberItem.memberColor = [memberResult stringForColumn:@"ccolor"];
            [memberItems addObject:memberItem];
        }
        [memberResult close];
        
        if (!memberItems.count) {
            SSJChargeMemberItem *item = [[SSJChargeMemberItem alloc]init];
            item.memberId = [NSString stringWithFormat:@"%@-0",SSJUSERID()];
            item.memberName = @"我";
            item.memberColor = @"#fc7a60";
            [memberItems addObject:item];
        }
        item.membersItem = memberItems;
        
        if (success) {
            SSJDispatch_main_async_safe(^(){
                success(item);
            })
        }
    }];
}

+ (void)deleteChargeWithItem:(SSJBillingChargeCellItem *)item
                     success:(nullable void(^)())success
                     failure:(nullable void(^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db , BOOL *rollback) {
        NSString *userId = SSJUSERID();
        NSString *booksId = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userId];
        if (!booksId.length) {
            booksId = userId;
        }
        
        if (![db executeUpdate:@"UPDATE BK_USER_CHARGE SET OPERATORTYPE = 2 , CWRITEDATE = ? , IVERSION = ? WHERE ICHARGEID = ?",[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),item.ID]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        if ([db intForQuery:@"SELECT ITYPE FROM BK_BILL_TYPE WHERE ID = ?",item.billId]) {
            if (![db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET EXPENCEAMOUNT = EXPENCEAMOUNT - ? , SUMAMOUNT = SUMAMOUNT + ? , CWRITEDATE = ? WHERE CBILLDATE = ? and cbooksid = ?",[NSNumber numberWithDouble:[item.money doubleValue]],[NSNumber numberWithDouble:[item.money doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],item.billDate,booksId]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure([db lastError]);
                    });
                }
                return;
            };
        } else {
            if (![db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET INCOMEAMOUNT = INCOMEAMOUNT - ? , SUMAMOUnT = SUMAMOUNT - ? , CWRITEDATE = ? WHERE CBILLDATE = ? and cbooksid = ?",[NSNumber numberWithDouble:[item.money doubleValue]],[NSNumber numberWithDouble:[item.money doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],item.billDate,booksId]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure([db lastError]);
                    });
                }
                return;
            };
        }
        
        if (![db executeUpdate:@"DELETE FROM BK_DAILYSUM_CHARGE WHERE SUMAMOUNT = 0 AND INCOMEAMOUNT = 0 AND EXPENCEAMOUNT = 0"]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success();
            });
        }
    }];
}

@end
