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
#import "SSJBillingChargeCellItem.h"
#import "SSJOrmDatabaseQueue.h"
#import "SSJFundInfoTable.h"
#import "SSJUserChargeTable.h"
#import "SSJFundingTypeManager.h"
#import "SSJUserBillTypeTable.h"
#import "SSJUserCreditTable.h"
#import "SSJUserRemindTable.h"
#import "SSJShareBooksMemberTable.h"

@implementation SSJFinancingHomeHelper

+ (void)queryForFundingListWithSuccess:(void (^)(NSArray<SSJFinancingHomeitem *> *result))success
                               failure:(void (^)(NSError *error))failure {
    [[SSJOrmDatabaseQueue sharedInstance] asyncInDatabase:^(WCTDatabase *db) {

        NSString *userid = SSJUSERID();


        NSArray *fundResult = [db getObjectsOfClass:SSJFundInfoTable.class
                                          fromTable:@"bk_fund_info"
                                              where:SSJFundInfoTable.operatorType != 2
                                                    && SSJFundInfoTable.userId == userid
                                            orderBy:SSJFundInfoTable.fundOrder.order(WCTOrderedAscending)];

        NSMutableArray *fundingList = [NSMutableArray arrayWithCapacity:0];
        for (SSJFundInfoTable *fund in fundResult) {
            SSJFinancingHomeitem *item = [[SSJFinancingHomeitem alloc] init];
            item.fundingColor = fund.fundColor;
            item.fundingIcon = fund.fundIcon;
            item.fundingID = fund.fundId;
            item.fundingName = fund.fundName;
            item.fundingParent = fund.fundParent;
            item.fundingParentName = [[SSJFundingTypeManager sharedManager] modelForFundId:item.fundingParent].name;
            item.fundingMemo = fund.memo;
            item.fundingOrder = fund.fundOrder;
            item.startColor = fund.startColor;
            item.endColor = fund.endColor;

            if ([item.fundingParent isEqualToString:@"16"] || [item.fundingParent isEqualToString:@"3"]) {
                item.cardItem = [self getCreditCardItemForCardId:item.fundingID inDataBase:db];

                if ([item.fundingParent isEqualToString:@"16"]) {
                    item.cardItem.cardType = SSJCrediteCardTypeAlipay;
                } else if ([item.fundingParent isEqualToString:@"3"]) {
                    item.cardItem.cardType = SSJCrediteCardTypeCrediteCard;
                }

            }


            item.chargeCount
                    = [[db getOneValueOnResult:SSJUserChargeTable.AnyProperty.count() fromTable:@"bk_user_charge" where:SSJUserChargeTable.userId == userid
                                                                                                                        && SSJUserChargeTable.operatorType != 2
                                                                                                                        && SSJUserChargeTable.fundId == item.fundingID] doubleValue];

            item.fundingIncome
                    = [[self getFundBalanceWithFundId:item.fundingID type:SSJBillTypeIncome inDataBase:db] doubleValue];

            item.fundingExpence
                    = [[self getFundBalanceWithFundId:item.fundingID type:SSJBillTypePay inDataBase:db] doubleValue];

            item.fundingAmount = item.fundingIncome - item.fundingExpence;

            if (fund.display || (![item.fundingParent isEqualToString:@"11"] && ![item.fundingParent isEqualToString:@"10"])) {
                [fundingList addObject:item];
            }
        }

        if (success) {
            dispatch_main_async_safe (^{
                success(fundingList);
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


+ (void)SaveFundingOderWithItems:(NSArray <SSJFinancingHomeitem *> *)items error:(NSError **)error {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db , BOOL *rollback) {
        for (int i = 0 ; i < items.count ; i++) {
            NSString *sql;
            SSJBaseCellItem *item = [items ssj_safeObjectAtIndex:i];
            if ([item isKindOfClass:[SSJFinancingHomeitem class]]) {
                SSJFinancingHomeitem *fundingItem = (SSJFinancingHomeitem *) item;
                fundingItem.fundingOrder = i + 1;
                sql
                        = [NSString stringWithFormat:@"update bk_fund_info set iorder = %ld , cwritedate = '%@' , iversion = %@ , operatortype = 1 where cfundid = '%@'" , (long) fundingItem.fundingOrder , [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] , @(SSJSyncVersion()) , fundingItem.fundingID];
            } else if ([item isKindOfClass:[SSJCreditCardItem class]]) {
                SSJCreditCardItem *cardItem = (SSJCreditCardItem *) item;
                cardItem.cardOder = i + 1;
                sql
                        = [NSString stringWithFormat:@"update bk_fund_info set iorder = %ld , cwritedate = '%@' , iversion = %@ , operatortype = 1 where cfundid = '%@'" , (long) cardItem.cardOder , [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] , @(SSJSyncVersion()) , cardItem.fundingID];
            }
            [db executeUpdate:sql];
        }
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    }];
}

+ (void)deleteFundingWithFundingItem:(SSJFinancingHomeitem *)item
                          deleteType:(BOOL)type
                             Success:(void (^)())success
                             failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db , BOOL *rollback) {
        NSString *userId = SSJUSERID();
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        if (!item.cardItem) {
            // 如果是借贷
            SSJFinancingHomeitem *fundingItem = (SSJFinancingHomeitem *) item;
            if ([fundingItem.fundingParent isEqualToString:@"10"] || [fundingItem.fundingParent isEqualToString:@"11"]) {
                if (!type) {
                    //如果保留数据只要将响应的借贷隐藏
                    if (![db executeUpdate:@"update bk_fund_info set idisplay = 0 , cwritedate = ? , iversion = ?, operatortype = 1 where cfundid = ?" , writeDate , @(SSJSyncVersion()) , fundingItem.fundingID]) {
                        *rollback = YES;
                        if (failure) {
                            SSJDispatch_main_sync_safe(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    };
                } else {
                    //如果删掉数据只要将响应的借贷隐藏
                    if (![db executeUpdate:@"update bk_fund_info set idisplay = 0 , cwritedate = ? , iversion = ?, operatortype = 1 where cfundid = ?" , writeDate , @(SSJSyncVersion()) , fundingItem.fundingID]) {
                        *rollback = YES;
                        if (failure) {
                            SSJDispatch_main_sync_safe(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    };

                    // 删除和此账户相关的借贷数据（借贷项目、流水、提醒）
                    NSError *error = nil;
                    if (![SSJLoanHelper deleteLoanDataRelatedToFundID:fundingItem.fundingID writeDate:writeDate database:db error:&error]) {
                        *rollback = YES;
                        if (failure) {
                            SSJDispatch_main_sync_safe(^{
                                failure(error);
                            });
                        }
                        return;
                    }
                }
            } else {
                //如果是普通资金账户
                if (!type) {
                    // 如果保留数据只要删掉资金账户
                    if (![db executeUpdate:@"update bk_fund_info set operatortype = 2 , cwritedate = ? , iversion = ? where cfundid = ?" , writeDate , @(SSJSyncVersion()) , fundingItem.fundingID]) {
                        if (failure) {
                            *rollback = YES;
                            SSJDispatch_main_async_safe(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    };
                } else {
                    // 如果不保留先删掉资金账户
                    if (![db executeUpdate:@"update bk_fund_info set operatortype = 2 , cwritedate = ? , iversion = ? where cfundid = ?" , writeDate , @(SSJSyncVersion()) , fundingItem.fundingID]) {
                        if (failure) {
                            *rollback = YES;
                            SSJDispatch_main_async_safe(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    };

                    // 删除和此账户相关的借贷数据（借贷项目、流水、提醒）
                    NSError *error = nil;
                    if (![SSJLoanHelper deleteLoanDataRelatedToFundID:fundingItem.fundingID writeDate:writeDate database:db error:&error]) {
                        *rollback = YES;
                        if (failure) {
                            SSJDispatch_main_sync_safe(^{
                                failure(error);
                            });
                        }
                        return;
                    }

                    // 删掉账户所对应的转账
                    if (![self deleteTransferChargeInDataBase:db withFundId:fundingItem.fundingID userId:userId error:NULL]) {
                        if (failure) {
                            *rollback = YES;
                            SSJDispatch_main_async_safe(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    }

                    //删除资金账户所对应的流水
                    if (![db executeUpdate:@"update bk_user_charge set operatortype = 2 , cwritedate = ? , iversion = ? where ifunsid = ? and operatortype <> 2 and (ichargetype <> ? or cbooksid in (select cbooksid from bk_share_books_member where cmemberid = ? and istate = ?))" , writeDate , @(SSJSyncVersion()) , fundingItem.fundingID , @(SSJChargeIdTypeShareBooks) , userId , @(SSJShareBooksMemberStateNormal)]) {
                        if (failure) {
                            *rollback = YES;
                            SSJDispatch_main_async_safe(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    };

                }
            }
        } else {
            // 如果是信用卡账户
            SSJCreditCardItem *cardItem = (SSJCreditCardItem *) item;
            if (!type) {
                //删掉资金账户
                if (![db executeUpdate:@"update bk_fund_info set operatortype = 2 , cwritedate = ? , iversion = ? where cfundid = ?" , writeDate , @(SSJSyncVersion()) , cardItem.fundingID]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                };
                //删掉信用卡
                if (![db executeUpdate:@"update bk_user_credit set operatortype = 2 , cwritedate = ? , iversion = ? where cfundid = ?" , writeDate , @(SSJSyncVersion()) , cardItem.fundingID]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                };
                //删掉提醒
                if (cardItem.remindItem) {
                    if (![db executeUpdate:@"update bk_user_remind set operatortype = 2 , cwritedate = ? , iversion = ? where cuserid = ? and cremindid = ?" , writeDate , @(SSJSyncVersion()) , userId , cardItem.remindItem.remindId]) {
                        *rollback = YES;
                        SSJDispatch_main_async_safe(^{
                            if (failure) {
                                failure([db lastError]);
                            }
                            return;
                        });
                    }
                    //取消提醒
                    [SSJLocalNotificationHelper cancelLocalNotificationWithremindItem:cardItem.remindItem];
                }
            } else {
                // 删掉账户所对应的转账
                if (![self deleteTransferChargeInDataBase:db withFundId:cardItem.fundingID userId:userId error:NULL]) {
                    if (failure) {
                        *rollback = YES;
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                }

                if (![SSJCreditCardStore deleteCreditCardWithCardItem:item inDatabase:db forUserId:userId error:NULL]) {
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

+ (BOOL)deleteTransferChargeInDataBase:(FMDatabase *)db withFundId:(NSString *)fundId userId:(NSString *)userId error:(NSError *)error {
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    FMResultSet *transferResult
            = [db executeQuery:@"select * from bk_user_charge where ifunsid = ? and cuserid = ? and operatortype <> 2 and ibillid in (3,4)" , fundId , userId];
    if (!transferResult) {
        error = [db lastError];
    }
    while ([transferResult next]) {
        SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
        item.billId = [transferResult stringForColumn:@"ibillid"];
        item.ID = [transferResult stringForColumn:@"ichargeid"];
        item.editeDate = [transferResult stringForColumn:@"cwritedate"];
        item.billDate = [transferResult stringForColumn:@"cbilldate"];
        item.money = [transferResult stringForColumn:@"imoney"];
        [tempArr addObject:item];
    }
    [transferResult close];

    for (SSJBillingChargeCellItem *item in tempArr) {
        NSDate *writeDate = [NSDate dateWithString:item.editeDate formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSDate *maxDate = [writeDate dateByAddingSeconds:1];
        NSDate *minDate = [writeDate dateBySubtractingSeconds:1];
        NSString *maxDateStr = [maxDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString *minDateStr = [minDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        if ([item.billId isEqualToString:@"3"]) {
            if (![db executeUpdate:@"update bk_user_charge set operatortype = 2 where cuserid = ? and cbilldate = ? and (cwritedate between ? and ?) and imoney = ? and ibillid = 4" , userId , item.billDate , minDateStr , maxDateStr , item.money]) {
                error = [db lastError];
                return NO;
            }
        } else {
            if (![db executeUpdate:@"update bk_user_charge set operatortype = 2 where cuserid = ? and cbilldate = ? and (cwritedate between ? and ?) and imoney = ? and ibillid = 3" , userId , item.billDate , minDateStr , maxDateStr , item.money]) {
                error = [db lastError];
                return NO;
            }
        }
    }

    return YES;
}

+ (SSJFinancingHomeitem *)queryFundItemWithFundingId:(NSString *)fundingId {
    __block SSJFinancingHomeitem *fundItem = [[SSJFinancingHomeitem alloc] init];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        FMResultSet *result
                = [db executeQuery:@"select a.* from bk_fund_info  a where a.cparent != 'root' and a.operatortype <> 2 and a.cuserid = ? and a.cfundid = ?" , userid , fundingId];
        while ([result next]) {
            fundItem = [self fundingItemWithResultSet:result inDatabase:db];
        }
    }];
    return fundItem;
}


+ (NSString *)fundIconForFundingParent:(NSString *)parent {
    switch ( [parent integerValue] ) {
        case 1:
            return @"ft_cash";
            break;

        case 2:
            return @"ft_chuxuka";
            break;

        case 3:
            return @"ft_creditcard";
            break;

        case 4:
            return @"ft_invest";
            break;

        case 5:
            return @"ft_huobijijin";
            break;

        case 6:
            return @"ft_shiwuka";
            break;

        case 7:
            return @"ft_wangluochongzhi";
            break;

        case 8:
            return @"ft_house";
            break;

        case 9:
            return @"ft_yingshouqian";
            break;

        case 10:
            return @"ft_jiechukuan";
            break;

        case 11:
            return @"ft_qiankuan";
            break;

        case 12:
            return @"ft_shebao";
            break;

        case 13:
            return @"ft_weixin";
            break;

        case 14:
            return @"ft_zhifubao";
            break;

        case 15:
            return @"ft_others";
            break;

        default:
            break;
    }
    return @"";
}

+ (NSString *)fundParentNameForFundingParent:(NSString *)parent {
    switch ( [parent integerValue] ) {
        case 1:
            return @"现金";
            break;

        case 2:
            return @"储蓄卡";
            break;

        case 3:
            return @"信用卡";
            break;

        case 4:
            return @"投资账户";
            break;

        case 5:
            return @"货币基金";
            break;

        case 6:
            return @"实物储值卡";
            break;

        case 7:
            return @"网络充值账户";
            break;

        case 8:
            return @"住房公积金";
            break;

        case 9:
            return @"应收钱款";
            break;

        case 10:
            return @"借出款";
            break;

        case 11:
            return @"欠款";
            break;

        case 12:
            return @"社保";
            break;

        case 13:
            return @"微信钱包";
            break;

        case 14:
            return @"支付宝";
            break;

        case 15:
            return @"其他";
            break;

        default:
            break;
    }
    return @"";
}


+ (SSJCreditCardItem *)getCreditCardItemForCardId:(NSString *)cardId inDataBase:(WCTDatabase *)db {
    SSJUserCreditTable *userCredit
            = [db getOneObjectOfClass:SSJUserCreditTable.class fromTable:@"bk_user_credit" where:SSJUserCreditTable.cardId == cardId];
    SSJCreditCardItem *cardItem = [[SSJCreditCardItem alloc] init];
    cardItem.cardLimit = userCredit.cardQuota;
    cardItem.settleAtRepaymentDay = userCredit.billDateSettlement;
    cardItem.cardRepaymentDay = userCredit.repaymentDate;
    cardItem.cardBillingDay = userCredit.billingDate;
    cardItem.remindItem = [self getRemindItemWithRemindId:userCredit.remindId indataBase:db];
    return cardItem;
}

+ (NSNumber *)getFundBalanceWithFundId:(NSString *)fundId type:(SSJBillType)type inDataBase:(WCTDatabase *)db {
    NSNumber *currentBalance = 0;

    WCTResultList resultList = {SSJUserChargeTable.money.inTable(@"bk_user_charge").sum()};

    WCDB::JoinClause joinClause = WCDB::JoinClause("bk_user_charge").join("bk_user_bill_type" , WCDB::JoinClause::Type::Inner).
            on(SSJUserChargeTable.billId.inTable(@"bk_user_charge") == SSJUserBillTypeTable.billId.inTable(@"bk_user_bill_type")
               && ((SSJUserChargeTable.booksId.inTable(@"bk_user_charge") == SSJUserBillTypeTable.booksId.inTable(@"bk_user_bill_type")
                    && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == SSJUserBillTypeTable.userId.inTable(@"bk_user_bill_type")
                   )
                   || SSJUserBillTypeTable.billId.length() < 4
               )
               && SSJUserBillTypeTable.userId.inTable(@"bk_user_charge") == SSJUSERID()
               && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2
               && SSJUserBillTypeTable.billType == type
               && SSJUserChargeTable.fundId == fundId);

    joinClause.join("bk_share_books_member" , WCDB::JoinClause::Type::Left).
            on(SSJUserChargeTable.booksId.inTable(@"bk_user_charge") == SSJShareBooksMemberTable.booksId.inTable(@"bk_share_books_member"));

    WCDB::StatementSelect statementSelect = WCDB::StatementSelect().select(resultList).from(joinClause).
            where(SSJShareBooksMemberTable.memberState.inTable(@"bk_share_books_member") == SSJShareBooksMemberStateNormal
                  || SSJShareBooksMemberTable.memberState.inTable(@"bk_share_books_member").isNull()
                  || SSJUserChargeTable.billId.inTable(@"bk_user_charge") == @"13"
                  || SSJUserChargeTable.billId.inTable(@"bk_user_charge") == @"14");

    WCTStatement *statement = [db prepare:statementSelect];

    while ([statement step]) {
        currentBalance = (NSNumber *) [statement getValueAtIndex:0];
    }

    return currentBalance;

}

+ (SSJReminderItem *)getRemindItemWithRemindId:(NSString *)remindId indataBase:(WCTDatabase *)db {
    SSJReminderItem *item = [[SSJReminderItem alloc] init];
    SSJUserRemindTable *userRemindTable = [db getOneObjectOfClass:SSJUserRemindTable.class fromTable:@"bk_user_remind" where:SSJUserRemindTable.remindId == remindId];
    item.remindId = userRemindTable.remindId;
    item.remindName = userRemindTable.remindName;
    item.remindMemo = userRemindTable.memo;
    item.remindCycle = userRemindTable.cycle;
    item.remindType = userRemindTable.type;
    item.remindState = userRemindTable.state;
    return item;
}



@end
