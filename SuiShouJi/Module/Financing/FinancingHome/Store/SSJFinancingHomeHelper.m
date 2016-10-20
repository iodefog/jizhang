//
//  SSJFinancingHomeHelper.m
//  SuiShouJi
//
//  Created by ricky on 16/3/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFinancingHomeHelper.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "SSJCreditCardStore.h"
#import "SSJCreditCardItem.h"
#import "SSJLoanHelper.h"
#import "SSJLocalNotificationHelper.h"
#import "SSJDailySumChargeTable.h"

@implementation SSJFinancingHomeHelper
+ (void)queryForFundingListWithSuccess:(void(^)(NSArray<SSJFinancingHomeitem *> *result))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSMutableArray *fundingList = [[NSMutableArray alloc]init];
        FMResultSet * fundingResult = [db executeQuery:@"select a.* from bk_fund_info a where a.cparent != 'root' and a.operatortype <> 2 and a.cuserid = ? order by a.iorder asc, a.cparent asc , a.cwritedate desc",userid];
        if (!fundingResult) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        int count = 1;
        while ([fundingResult next]) {
            SSJFinancingHomeitem *item = [[SSJFinancingHomeitem alloc] init];
            item.fundingColor = [fundingResult stringForColumn:@"CCOLOR"];
            item.fundingIcon = [fundingResult stringForColumn:@"CICOIN"];
            item.fundingID = [fundingResult stringForColumn:@"CFUNDID"];
            item.fundingName = [fundingResult stringForColumn:@"CACCTNAME"];
            item.fundingParent = [fundingResult stringForColumn:@"CPARENT"];
            item.fundingMemo = [fundingResult stringForColumn:@"CMEMO"];
            item.fundingOrder = [fundingResult intForColumn:@"IORDER"];
            if (item.fundingOrder == 0) {
                item.fundingOrder = count;
            }
            if ([fundingResult boolForColumn:@"idisplay"] || (![item.fundingParent isEqualToString:@"11"] && ![item.fundingParent isEqualToString:@"10"])) {
                [fundingList addObject:item];
            }
            count ++;
        }
        [fundingResult close];
        NSString *currentDate = [[NSDate date]formattedDateWithFormat:@"yyyy-MM-dd"];
        for (SSJFinancingHomeitem *item in fundingList) {
            item.fundingAmount = [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.cuserid = ? and a.operatortype <> 2 and (a.cbilldate <= ? or length(a.loanid) > 0) and b.itype = 0 and a.ifunsid = ?",userid,currentDate,item.fundingID] - [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.cuserid = ? and a.operatortype <> 2 and (a.cbilldate <= ? or length(a.loanid) > 0) and b.itype = 1 and a.ifunsid = ?",userid,currentDate,item.fundingID];
            item.chargeCount = [db intForQuery:@"select count(1) from bk_user_charge where ifunsid = ? and cuserid = ? and operatortype <> 2",item.fundingID,userid];
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(fundingList);
            });
        }
    }];
}

+ (void)queryForFundingSumMoney:(void(^)(double result))success failure:(void (^)(NSError *error))failure{
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        double fundingSum = 0;
        NSString *currentDate = [[NSDate date]formattedDateWithFormat:@"yyyy-MM-dd"];
        fundingSum = [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge a, bk_bill_type b ,bk_fund_info c where a.ibillid = b.id and a.cuserid = ? and a.operatortype <> 2 and (a.cbilldate <= ? or length(a.loanid) > 0) and b.itype = 0 and a.ifunsid = c.cfundid and c.idisplay = 1 and c.operatortype <> 2",userid,currentDate] - [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge a, bk_bill_type b ,bk_fund_info c where a.ibillid = b.id and a.cuserid = ? and a.operatortype <> 2 and (a.cbilldate <= ? or length(a.loanid) > 0) and b.itype = 1 and a.ifunsid = c.cfundid and c.idisplay = 1 and c.operatortype <> 2",userid,currentDate];
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(fundingSum);
            });
        }
    }];
}

+ (SSJFinancingHomeitem *)fundingItemWithResultSet:(FMResultSet *)set inDatabase:(FMDatabase *)db {
    SSJFinancingHomeitem *item = [[SSJFinancingHomeitem alloc] init];
    item.fundingColor = [set stringForColumn:@"CCOLOR"];
    item.fundingIcon = [set stringForColumn:@"CICOIN"];
    item.fundingID = [set stringForColumn:@"CFUNDID"];
    item.fundingName = [set stringForColumn:@"CACCTNAME"];
    item.fundingParent = [set stringForColumn:@"CPARENT"];
    item.fundingMemo = [set stringForColumn:@"CMEMO"];
    item.fundingOrder = [set intForColumn:@"IORDER"];
    return item;
}


+ (void)SaveFundingOderWithItems:(NSArray <SSJFinancingHomeitem *> *)items error:(NSError **)error{
    [[SSJDatabaseQueue sharedInstance]asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (int i = 0; i < items.count; i++) {
            NSString *sql;
            SSJBaseItem *item = [items ssj_safeObjectAtIndex:i];
            if ([item isKindOfClass:[SSJFinancingHomeitem class]]) {
                SSJFinancingHomeitem *fundingItem = (SSJFinancingHomeitem *)item;
                fundingItem.fundingOrder = i + 1;
                sql = [NSString stringWithFormat:@"update bk_fund_info set iorder = %ld , cwritedate = '%@' , iversion = %@ , operatortype = 1 where cfundid = '%@'",fundingItem.fundingOrder,[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),fundingItem.fundingID];
            }else if ([item isKindOfClass:[SSJCreditCardItem class]]){
                SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
                cardItem.cardOder = i + 1;
                sql = [NSString stringWithFormat:@"update bk_fund_info set iorder = %ld , cwritedate = '%@' , iversion = %@ , operatortype = 1 where cfundid = '%@'",cardItem.cardOder,[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),cardItem.cardId];
            }
            [db executeUpdate:sql];
        }
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    }];
}

+ (void)deleteFundingWithFundingItem:(SSJBaseItem *)item
                          deleteType:(BOOL)type
                             Success:(void(^)())success
                             failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance]asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *userId = SSJUSERID();
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        if ([item isKindOfClass:[SSJFinancingHomeitem class]]) {
            // 如果是借贷
            SSJFinancingHomeitem *fundingItem = (SSJFinancingHomeitem *)item;
            if ([fundingItem.fundingParent isEqualToString:@"10"] || [fundingItem.fundingParent isEqualToString:@"11"]) {
                if (!type) {
                    //如果保留数据只要将响应的借贷隐藏
                    if (![db executeUpdate:@"update bk_fund_info set idisplay = 0 , cwritedate = ? , iversion = ?, operatortype = 1 where cfundid = ?",writeDate,@(SSJSyncVersion()),fundingItem.fundingID]) {
                        *rollback = YES;
                        if (failure) {
                            SSJDispatchMainAsync(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    };
                }else{
                    //如果删掉数据只要将响应的借贷隐藏
                    if (![db executeUpdate:@"update bk_fund_info set idisplay = 0 , cwritedate = ? , iversion = ?, operatortype = 1 where cfundid = ?",writeDate,@(SSJSyncVersion()),fundingItem.fundingID]) {
                        *rollback = YES;
                        if (failure) {
                            SSJDispatchMainAsync(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    };
                    FMResultSet *resultSet = [db executeQuery:@"select * from bk_loan where cthefundid = ?",fundingItem.fundingID];
                    if (!resultSet) {
                        if (failure) {
                            *rollback = YES;
                            SSJDispatchMainAsync(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    }
                    SSJLoanModel *loanModel = [[SSJLoanModel alloc] init];
                    while ([resultSet next]) {
                        loanModel.ID = [resultSet stringForColumn:@"loanid"];
                        loanModel.userID = [resultSet stringForColumn:@"cuserid"];
                        loanModel.lender = [resultSet stringForColumn:@"lender"];
                        loanModel.jMoney = [resultSet doubleForColumn:@"jmoney"];
                        loanModel.fundID = [resultSet stringForColumn:@"cthefundid"];
                        loanModel.targetFundID = [resultSet stringForColumn:@"ctargetfundid"];
                        loanModel.endTargetFundID = [resultSet stringForColumn:@"cetarget"];
                        loanModel.chargeID = [resultSet stringForColumn:@"cthecharge"];
                        loanModel.targetChargeID = [resultSet stringForColumn:@"ctargetcharge"];
                        loanModel.endChargeID = [resultSet stringForColumn:@"cethecharge"];
                        loanModel.endTargetChargeID = [resultSet stringForColumn:@"cetargetcharge"];
                        loanModel.interestChargeID = [resultSet stringForColumn:@"cinterestid"];
                        loanModel.borrowDate = [NSDate dateWithString:[resultSet stringForColumn:@"cborrowdate"] formatString:@"yyyy-MM-dd"];
                        loanModel.repaymentDate = [NSDate dateWithString:[resultSet stringForColumn:@"crepaymentdate"] formatString:@"yyyy-MM-dd"];
                        loanModel.endDate = [NSDate dateWithString:[resultSet stringForColumn:@"cenddate"] formatString:@"yyyy-MM-dd"];
                        loanModel.rate = [resultSet doubleForColumn:@"rate"];
                        loanModel.memo = [resultSet stringForColumn:@"memo"];
                        loanModel.remindID = [resultSet stringForColumn:@"cremindid"];
                        loanModel.interest = [resultSet boolForColumn:@"interest"];
                        loanModel.closeOut = [resultSet boolForColumn:@"iend"];
                        loanModel.type = [resultSet intForColumn:@"itype"];
                        loanModel.operatorType = [resultSet intForColumn:@"operatorType"];
                        loanModel.version = [resultSet longLongIntForColumn:@"iversion"];
                        loanModel.writeDate = [NSDate dateWithString:[resultSet stringForColumn:@"cwritedate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
                    }
                    [resultSet close];
                    if (![SSJLoanHelper deleteLoanModel:loanModel inDatabase:db forUserId:userId error:NULL]) {
                        if (failure) {
                            *rollback = YES;
                            SSJDispatchMainAsync(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    };
                }
            }else{
                //如果是普通资金帐户
                if (!type) {
                    // 如果保留数据只要删掉资金帐户
                    if (![db executeUpdate:@"update bk_fund_info set operatortype = 2 , cwritedate = ? , iversion = ? where cfundid = ?",writeDate,@(SSJSyncVersion()),fundingItem.fundingID]) {
                        if (failure) {
                            *rollback = YES;
                            SSJDispatchMainAsync(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    };
                }else{
                    // 如果不保留先删掉资金帐户
                    if (![db executeUpdate:@"update bk_fund_info set operatortype = 2 , cwritedate = ? , iversion = ? where cfundid = ?",writeDate,@(SSJSyncVersion()),fundingItem.fundingID]) {
                        if (failure) {
                            *rollback = YES;
                            SSJDispatchMainAsync(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    };
                    //删除资金账户所对应的流水
                    if (![db executeUpdate:@"update bk_user_charge set operatortype = 2 , cwritedate = ? , iversion = ? where ifunsid = ?",writeDate,@(SSJSyncVersion()),fundingItem.fundingID]) {
                        if (failure) {
                            *rollback = YES;
                            SSJDispatchMainAsync(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    };
                    
                    //更新日常统计表
                    if (![SSJDailySumChargeTable updateDailySumChargeForUserId:userId inDatabase:db]) {
                        if (failure) {
                            *rollback = YES;
                            SSJDispatchMainAsync(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    }
                    
                    //找出所有和当前资金帐户有关的借贷
                    FMResultSet *resultSet = [db executeQuery:@"select * from bk_loan where loanid in (select loanid from bk_user_charge where ifunsid = ? and operatortype <> 2)", fundingItem.fundingID];
                    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
                    while ([resultSet next]) {
                        SSJLoanModel *loanModel = [[SSJLoanModel alloc] init];
                        loanModel.ID = [resultSet stringForColumn:@"loanid"];
                        loanModel.userID = [resultSet stringForColumn:@"cuserid"];
                        loanModel.lender = [resultSet stringForColumn:@"lender"];
                        loanModel.jMoney = [resultSet doubleForColumn:@"jmoney"];
                        loanModel.fundID = [resultSet stringForColumn:@"cthefundid"];
                        loanModel.targetFundID = [resultSet stringForColumn:@"ctargetfundid"];
                        loanModel.endTargetFundID = [resultSet stringForColumn:@"cetarget"];
                        loanModel.chargeID = [resultSet stringForColumn:@"cthecharge"];
                        loanModel.targetChargeID = [resultSet stringForColumn:@"ctargetcharge"];
                        loanModel.endChargeID = [resultSet stringForColumn:@"cethecharge"];
                        loanModel.endTargetChargeID = [resultSet stringForColumn:@"cetargetcharge"];
                        loanModel.interestChargeID = [resultSet stringForColumn:@"cinterestid"];
                        loanModel.borrowDate = [NSDate dateWithString:[resultSet stringForColumn:@"cborrowdate"] formatString:@"yyyy-MM-dd"];
                        loanModel.repaymentDate = [NSDate dateWithString:[resultSet stringForColumn:@"crepaymentdate"] formatString:@"yyyy-MM-dd"];
                        loanModel.endDate = [NSDate dateWithString:[resultSet stringForColumn:@"cenddate"] formatString:@"yyyy-MM-dd"];
                        loanModel.rate = [resultSet doubleForColumn:@"rate"];
                        loanModel.memo = [resultSet stringForColumn:@"memo"];
                        loanModel.remindID = [resultSet stringForColumn:@"cremindid"];
                        loanModel.interest = [resultSet boolForColumn:@"interest"];
                        loanModel.closeOut = [resultSet boolForColumn:@"iend"];
                        loanModel.type = [resultSet intForColumn:@"itype"];
                        loanModel.operatorType = [resultSet intForColumn:@"operatorType"];
                        loanModel.version = [resultSet longLongIntForColumn:@"iversion"];
                        loanModel.writeDate = [NSDate dateWithString:[resultSet stringForColumn:@"cwritedate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
                        [tempArr addObject:loanModel];
                        [resultSet close];
                    }
                    for (SSJLoanModel *model in tempArr) {
                        if (![SSJLoanHelper deleteLoanModel:model inDatabase:db forUserId:userId error:NULL]) {
                            if (failure) {
                                *rollback = YES;
                                SSJDispatchMainAsync(^{
                                    failure([db lastError]);
                                });
                            }
                            return;
                        };
                    }
                }
            }
        }else{
            // 如果是信用卡账户
            SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
            if (!type) {
                //删掉资金帐户
                if (![db executeUpdate:@"update bk_fund_info set operatortype = 2 , cwritedate = ? , iversion = ? where cfundid = ?",writeDate,@(SSJSyncVersion()),cardItem.cardId]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatchMainAsync(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                };
                //删掉信用卡
                if (![db executeUpdate:@"update bk_user_credit set operatortype = 2 , cwritedate = ? , iversion = ? where cfundid = ?",writeDate,@(SSJSyncVersion()),cardItem.cardId]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatchMainAsync(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                };
                //删掉提醒
                if (cardItem.remindId.length) {
                    if (![db executeUpdate:@"update bk_user_remind set operatortype = 2 , cwritedate = ? , iversion = ? where cuserid = ? and cremindid = ?",writeDate,@(SSJSyncVersion()),userId,cardItem.remindId]) {
                        *rollback = YES;
                        SSJDispatch_main_async_safe(^{
                            if (failure) {
                                failure([db lastError]);
                            }
                            return;
                        });
                    }
                    //取消提醒
                    SSJReminderItem *remindItem = [[SSJReminderItem alloc]init];
                    remindItem.remindId = cardItem.remindId;
                    [SSJLocalNotificationHelper cancelLocalNotificationWithremindItem:remindItem];
                }
            }else{
                if (![SSJCreditCardStore deleteCreditCardWithCardItem:cardItem inDatabase:db forUserId:userId error:NULL]) {
                    *rollback = YES;
                    SSJDispatch_main_async_safe(^{
                        if (failure) {
                            failure([db lastError]);
                        }
                        return;
                    });
                };
            }
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
    }];
}

+ (SSJFinancingHomeitem *)queryFundItemWithFundingId:(NSString *)fundingId{
    __block SSJFinancingHomeitem *fundItem = [[SSJFinancingHomeitem alloc]init];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        FMResultSet *result = [db executeQuery:@"select a.* from bk_fund_info  a where a.cparent != 'root' and a.operatortype <> 2 and a.cuserid = ? and a.cfundid = ?",userid,fundingId];
        while ([result next]) {
            fundItem = [self fundingItemWithResultSet:result inDatabase:db];
        }
    }];
    return fundItem;
}

@end
