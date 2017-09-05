//
//  SSJFinancingStore.m
//  SuiShouJi
//
//  Created by ricky on 2017/3/8.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFinancingStore.h"
#import "SSJFundInfoTable.h"
#import "SSJDatabaseQueue.h"
#import "SSJOrmDatabaseQueue.h"
#import "SSJUserChargeTable.h"
#import "SSJUserChargeTable.h"
#import "SSJShareBooksMemberTable.h"
#import "SSJUserBillTypeTable.h"
#import "SSJUserCreditTable.h"
#import "SSJUserRemindTable.h"
#import "SSJLocalNotificationStore.h"
#import "SSJLocalNotificationHelper.h"

@implementation SSJFinancingStore

+ (void)saveFundingItem:(SSJFinancingHomeitem *)item
                Success:(void (^)(SSJFinancingHomeitem *item))success
                failure:(void (^)(NSError *error))failure {

    [[SSJOrmDatabaseQueue sharedInstance] asyncInDatabase:^(WCTDatabase *db) {
        [db runTransaction:^BOOL {

            NSString *editeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];

            NSString *userId = SSJUSERID();


            // 往 fundinfo 表修改或者插入一条数据
            if (!item.fundingID.length) {
                item.fundingID = SSJUUID();
                item.fundingOrder = [[db getOneValueOnResult:SSJFundInfoTable.fundOrder.max()
                                                   fromTable:@"bk_fund_info"
                                                       where:SSJFundInfoTable.userId == userId
                                                               && SSJFundInfoTable.operatorType != 2] integerValue] + 1;
            }


            SSJFundInfoTable *fundInfo = [[SSJFundInfoTable alloc] init];
            fundInfo.fundId = item.fundingID;
            fundInfo.fundName = item.fundingName;
            fundInfo.fundIcon = item.fundingIcon;
            fundInfo.fundParent = item.fundingParent;
            fundInfo.fundColor = item.fundingColor;
            fundInfo.writeDate = editeDate;
            fundInfo.version = SSJSyncVersion();
            fundInfo.memo = item.fundingMemo;
            fundInfo.userId = SSJUSERID();
            fundInfo.fundOrder = item.fundingOrder;
            fundInfo.display = 1;
            fundInfo.fundColor = item.startColor;
            fundInfo.startColor = item.startColor;
            fundInfo.endColor = item.endColor;

            double originalBalance
                    = [[self getFundBalanceWithFundId:item.fundingID type:SSJBillTypeIncome inDataBase:db] doubleValue] - [[self getFundBalanceWithFundId:item.fundingID type:SSJBillTypePay inDataBase:db] doubleValue];

            double differentMoney = item.fundingAmount - originalBalance;

            item.fundOperatortype = 1;
            if (![db insertOrReplaceObject:fundInfo into:@"bk_fund_info"]) {
                NSError *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey: @"插入资金帐户表失败"}];
                if (failure) {
                    dispatch_main_async_safe (^{
                        failure(error);
                    });
                }
                return NO;
            };

            SSJUserChargeTable *userCharge = [[SSJUserChargeTable alloc] init];
            userCharge.chargeId = SSJUUID();
            userCharge.userId = userId;
            userCharge.money
                    = [[NSString stringWithFormat:@"%f", ABS(differentMoney)] ssj_moneyDecimalDisplayWithDigits:2];
            userCharge.writeDate = editeDate;
            userCharge.version = SSJSyncVersion();
            userCharge.operatorType = 1;
            userCharge.fundId = item.fundingID;
            userCharge.billDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"];

            if (differentMoney > 0) {
                userCharge.billId = @"1";
            } else if (item.fundingAmount < 0) {
                userCharge.billId = @"2";
            }


            // 如果余额发生了改变,那在流水表里插入一条平帐支出或者收入
            if (differentMoney) {
                if (![db insertObject:userCharge into:@"bk_user_charge"]) {
                    NSError *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey: @"插入平帐流水失败"}];
                    if (failure) {
                        dispatch_main_async_safe (^{
                            failure(error);
                        });
                    }
                    return NO;
                };
            }

            // 如果是信用卡,往信用卡里插入一条记录
            if (item.cardItem) {
                SSJUserCreditTable *userCredit = [[SSJUserCreditTable alloc] init];
                userCredit.cardId = item.fundingID;
                userCredit.cardQuota = item.cardItem.cardLimit;
                userCredit.billingDate = item.cardItem.cardBillingDay;
                userCredit.repaymentDate = item.cardItem.cardRepaymentDay;
                userCredit.userId = userId;
                userCredit.writeDate = editeDate;
                userCredit.version = SSJSyncVersion();
                userCredit.operatorType = 1;
                userCredit.remindId = item.cardItem.remindItem.remindId;
                userCredit.billDateSettlement = item.cardItem.settleAtRepaymentDay;
                if (![db insertOrReplaceObject:userCredit into:@"bk_user_credit"]) {
                    NSError *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey: @"插入信用卡表失败"}];
                    if (failure) {
                        dispatch_main_async_safe (^{
                            failure(error);
                        });
                    }
                    return NO;
                };
                
            }

            if (item.cardItem.remindItem.remindId.length) {
                SSJUserRemindTable *remindTable = [[SSJUserRemindTable alloc] init];
                remindTable.remindId = item.cardItem.remindItem.remindId;
                remindTable.userId = userId;
                remindTable.remindId = item.cardItem.remindItem.remindId;
                remindTable.remindName = item.cardItem.remindItem.remindName;
                remindTable.memo = item.cardItem.remindItem.remindMemo;
                remindTable.startDate = [item.cardItem.remindItem.remindDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
                remindTable.state = item.cardItem.remindItem.remindState;
                remindTable.version = SSJSyncVersion();
                remindTable.operatorType = 1;
                remindTable.writeDate = editeDate;
                remindTable.type = item.cardItem.remindItem.remindType;
                remindTable.cycle = item.cardItem.remindItem.remindCycle;
                remindTable.isEnd = item.cardItem.remindItem.remindAtTheEndOfMonth;
                if (![db insertOrReplaceObject:remindTable into:@"bk_user_remind"]) {
                    NSError *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey: @"插入提醒失败"}];
                    if (failure) {
                        dispatch_main_async_safe (^{
                            failure(error);
                        });
                    }
                    return NO;
                }

                [SSJLocalNotificationHelper cancelLocalNotificationWithremindItem:item.cardItem.remindItem];

                [SSJLocalNotificationHelper registerLocalNotificationWithremindItem:item.cardItem.remindItem];
            }


            if (success) {
                dispatch_main_async_safe (^{
                    success(item);
                });
            }

            return YES;
        }];


    }];

}

+ (void)queryFundingParentListWithFundingType:(SSJAccountType)type
                                needLoanOrNot:(BOOL)needLoan
                                      Success:(void (^)(NSArray <SSJFundingItem *> *items))success
                                      failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {

        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];

        FMResultSet *fundSet
                = [db executeQuery:@"select * from bk_fund_info where cparent = 'root' and itype = ? order by iorder", @(type)];

        if (!fundSet) {
            if (failure) {
                dispatch_main_async_safe (^{
                    failure([db lastError]);
                });
            }
            return;
        }

        while ([fundSet next]) {
            SSJFundingItem *item = [[SSJFundingItem alloc] init];
            item.fundingID = [fundSet stringForColumn:@"cfundid"];
            item.fundingName = [fundSet stringForColumn:@"cacctname"];
            item.fundingIcon = [fundSet stringForColumn:@"cicoin"];
            item.fundingMemo = [fundSet stringForColumn:@"cmemo"];
            if (![item.fundingID isEqualToString:@"9"]) {
                if (needLoan) {
                    [tempArr addObject:item];
                } else {
                    if (![item.fundingID isEqualToString:@"11"] && ![item.fundingID isEqualToString:@"10"]) {
                        [tempArr addObject:item];
                    }
                }
            }
        }

        if (success) {
            dispatch_main_async_safe (^{
                success(tempArr);
            });
        }

    }];
}

+ (BOOL)checkWhetherSameFundingNameExsitsWith:(SSJFinancingHomeitem *)item {
    __block BOOL exsit;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        NSString *fundid = item.fundingID ?: @"";
        NSInteger count
                = [db intForQuery:@"select count(1) from bk_fund_info where cuserid = ? and CACCTNAME = ? and cfundid <> ? and operatortype <> 2", userId, item.fundingName, fundid];
        if (count > 0) {
            exsit = YES;
        } else {
            exsit = NO;
        }
    }];
    return exsit;
}

+ (void)fundHasDataOrNotWithFundid:(NSString *)fundId
                           Success:(void (^)(BOOL hasData))success
                           failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        BOOL hasData;
        NSString *userId = SSJUSERID();
        NSInteger chargeCount
                = [db intForQuery:@"select count(1) from bk_user_charge where cuserid = ? and ifunsid = ? and operatortype <> 2", userId, fundId];
        NSInteger periodCount
                = [db intForQuery:@"select count(1) from bk_charge_period_config where cuserid = ? and ifunsid = ? and operatortype <> 2", userId, fundId];
        NSInteger periodTransferCount
                = [db intForQuery:@"select count(1) from bk_transfer_cycle where cuserid = ? and (ctransferinaccountid = ? or ctransferoutaccountid = ?) and operatortype <> 2", userId, fundId, fundId];

        NSInteger totalCount = chargeCount + periodCount + periodTransferCount;

        if (totalCount > 0) {
            hasData = YES;
        } else {
            hasData = NO;
        }

        if (success) {
            dispatch_main_async_safe (^{
                success(hasData);
            });
        }

    }];
}

+ (NSNumber *)getFundBalanceWithFundId:(NSString *)fundId type:(SSJBillType)type inDataBase:(WCTDatabase *)db {
    NSNumber *currentBalance = 0;

    WCTResultList resultList = {SSJUserChargeTable.money.inTable(@"bk_user_charge").sum()};

    WCDB::JoinClause
            joinClause = WCDB::JoinClause("bk_user_charge").join("bk_user_bill_type", WCDB::JoinClause::Type::Inner).
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

    joinClause.join("bk_share_books_member", WCDB::JoinClause::Type::Left).
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


@end
