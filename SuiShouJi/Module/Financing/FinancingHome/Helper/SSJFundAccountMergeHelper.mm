//
//  SSJFundAccountMergeHelper.m
//  SuiShouJi
//
//  Created by 赵天立 on 2017/7/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFundAccountMergeHelper.h"
#import <WCDB/WCDB.h>
#import "SSJFundInfoTable.h"
#import "SSJUserChargeTable.h"
#import "SSJTransferCycleTable.h"
#import "SSJChargePeriodConfigTable.h"
#import "SSJLoanTable.h"
#import "SSJFinancingHomeitem.h"
#import "SSJCreditCardItem.h"
#import "SSJCreditRepaymentTable.h"
#import "SSJUserRemindTable.h"
#import "SSJUserCreditTable.h"
#import "SSJOrmDatabaseQueue.h"
#import "SSJFundingTypeManager.h"

@interface SSJFundAccountMergeHelper()

@property (nonatomic, strong) WCTDatabase *db;

@end

@implementation SSJFundAccountMergeHelper

+ (void)startMergeWithSourceFundId:(NSString *)sourceFundId
                      targetFundId:(NSString *)targetFundId
                      needToDelete:(BOOL)needToDelete
                            Success:(void(^)())success
                            failure:(void (^)(NSError *error))failure {
    @weakify(self);
    [[SSJOrmDatabaseQueue sharedInstance] asyncInDatabase:^(WCTDatabase *db) {
        [db runTransaction:^BOOL{
            @strongify(self);

            NSString *userId = SSJUSERID();


            NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];

            // 取出账本中所有的流水
            NSArray *chargeArr = [db getObjectsOfClass:SSJUserChargeTable.class fromTable:@"BK_USER_CHARGE"
                                                      where:SSJUserChargeTable.userId == userId
                                                            && SSJUserChargeTable.fundId == sourceFundId
                                                            && SSJUserChargeTable.operatorType != 2];

            for (SSJUserChargeTable *userCharge in chargeArr) {
                NSString *originWriteDate = userCharge.writeDate;
                NSString *now = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
                userCharge.fundId = targetFundId;
                userCharge.version = SSJSyncVersion();

                NSString *otherBillId;

                if ([userCharge.billId integerValue] == SSJSpecialBillIdBalanceRollIn) {
                    otherBillId = [NSString stringWithFormat:@"%ld",SSJSpecialBillIdBalanceRollOut];
                    userCharge.writeDate = now;
                } else if ([userCharge.billId integerValue] == SSJSpecialBillIdLoanChangeEarning) {
                    otherBillId = [NSString stringWithFormat:@"%ld",SSJSpecialBillIdLoanChangeExpense];
                    userCharge.writeDate = now;
                } else if ([userCharge.billId integerValue] == SSJSpecialBillIdLoanBalanceRollIn) {
                    otherBillId = [NSString stringWithFormat:@"%ld",SSJSpecialBillIdLoanBalanceRollOut];
                    userCharge.writeDate = now;
                } else if ([userCharge.billId integerValue] == SSJSpecialBillIdBalanceRollOut) {
                    otherBillId = [NSString stringWithFormat:@"%ld",SSJSpecialBillIdBalanceRollIn];
                    userCharge.writeDate = now;
                } else if ([userCharge.billId integerValue] == SSJSpecialBillIdLoanChangeExpense) {
                    otherBillId = [NSString stringWithFormat:@"%ld",SSJSpecialBillIdLoanChangeEarning];
                    userCharge.writeDate = now;
                } else if ([userCharge.billId integerValue] == SSJSpecialBillIdLoanBalanceRollOut) {
                    otherBillId = [NSString stringWithFormat:@"%ld",SSJSpecialBillIdLoanBalanceRollIn];
                    userCharge.writeDate = now;
                }  else {
                    userCharge.writeDate = writeDate;
                }
                userCharge.operatorType = 1;
                if (![db updateRowsInTable:@"BK_USER_CHARGE" onProperties:{
                                SSJUserChargeTable.fundId,
                                SSJUserChargeTable.writeDate,
                                SSJUserChargeTable.version,
                                SSJUserChargeTable.operatorType
                        } withObject:userCharge
                                          where:SSJUserChargeTable.chargeId == userCharge.chargeId]) {
                    dispatch_main_async_safe(^{
                        if (failure) {
                            failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并流水失败"}]);
                        }
                    });
                    return NO;
                };

                if (otherBillId.length) {
                    if (![db updateRowsInTable:@"BK_USER_CHARGE" onProperty:SSJUserChargeTable.writeDate withValue:now
                                              where:SSJUserChargeTable.writeDate == originWriteDate
                                                    && SSJUserChargeTable.billId == otherBillId]) {
                        dispatch_main_async_safe(^{
                            if (failure) {
                                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并流水失败"}]);
                            }
                        });
                        return NO;
                    }
                }
            }


            // 取出所有的转账
            NSArray *transferArr = [db getObjectsOfClass:SSJTransferCycleTable.class fromTable:@"BK_TRANSFER_CYCLE"
                                                        where:SSJTransferCycleTable.userId == userId
                                                              && (SSJTransferCycleTable.transferInId == sourceFundId
                                                                  || SSJTransferCycleTable.transferOutId == sourceFundId
                                                              )
                                                              && SSJTransferCycleTable.operatorType != 2];

            for (SSJTransferCycleTable *transfer in transferArr) {
                transfer.writeDate = writeDate;
                transfer.version = SSJSyncVersion();
                if ([transfer.transferInId isEqualToString:sourceFundId]) {
                    transfer.transferInId = targetFundId;
                } else if ([transfer.transferOutId isEqualToString:sourceFundId]) {
                    transfer.transferOutId = targetFundId;
                }
                transfer.operatorType = 1;
                if (![transfer.transferInId isEqualToString:transfer.transferOutId]) {
                    if (![db updateRowsInTable:@"BK_TRANSFER_CYCLE" onProperties:{
                            SSJTransferCycleTable.writeDate,
                            SSJTransferCycleTable.version,
                            SSJTransferCycleTable.transferInId,
                            SSJTransferCycleTable.transferOutId,
                            SSJTransferCycleTable.operatorType
                    } withObject:transfer where:SSJTransferCycleTable.cycleId == transfer.cycleId]) {
                        dispatch_main_async_safe(^{
                            if (failure) {
                                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并转账失败"}]);
                            }
                        });
                        return NO;
                    };

                } else {
                    transfer.operatorType = 2;
                    if (![db updateRowsInTable:@"BK_TRANSFER_CYCLE" onProperties:{
                            SSJTransferCycleTable.writeDate,
                            SSJTransferCycleTable.version,
                            SSJTransferCycleTable.transferInId,
                            SSJTransferCycleTable.transferOutId,
                            SSJTransferCycleTable.operatorType
                    } withObject:transfer where:SSJTransferCycleTable.cycleId == transfer.cycleId]) {
                        dispatch_main_async_safe(^{
                            if (failure) {
                                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并转账失败"}]);
                            }
                        });
                        return NO;
                    };
                }
            }

            // 取出所有的周期记账
            NSArray *periodChargeArr = [db getObjectsOfClass:SSJChargePeriodConfigTable.class fromTable:@"BK_CHARGE_PERIOD_CONFIG"
                                                            where:SSJChargePeriodConfigTable.userId == userId
                                                                  && SSJChargePeriodConfigTable.fundId == sourceFundId
                                                                  && SSJChargePeriodConfigTable.operatorType != 2];

            for (SSJChargePeriodConfigTable *periodCharge in periodChargeArr) {
                periodCharge.writeDate = writeDate;
                periodCharge.version = SSJSyncVersion();
                periodCharge.fundId = targetFundId;
                periodCharge.operatorType = 1;
                if (![db updateRowsInTable:@"BK_CHARGE_PERIOD_CONFIG" onProperties:{
                                SSJChargePeriodConfigTable.writeDate,
                                SSJChargePeriodConfigTable.version,
                                SSJChargePeriodConfigTable.fundId,
                                SSJChargePeriodConfigTable.operatorType
                        } withObject:periodCharge
                                          where:SSJChargePeriodConfigTable.configId == periodCharge.configId]) {
                    dispatch_main_async_safe(^{
                        if (failure) {
                            failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并周期记账失败"}]);
                        }
                    });
                    return NO;
                };

            }

            // 取出所有的借贷
            NSArray *loanArr = [db getObjectsOfClass:SSJLoanTable.class fromTable:@"BK_LOAN"
                                                    where:SSJLoanTable.userId == userId
                                                          && (SSJLoanTable.targetFundid == sourceFundId
                                                              || SSJLoanTable.endTargetFundid == sourceFundId
                                                          )
                                                          && SSJLoanTable.operatorType != 2];

            for (SSJLoanTable *loan in loanArr) {
                loan.writeDate = writeDate;
                loan.version = SSJSyncVersion();
                if ([loan.targetFundid isEqualToString:sourceFundId]) {
                    loan.targetFundid = targetFundId;
                } else if ([loan.endTargetFundid isEqualToString:sourceFundId]) {
                    loan.endTargetFundid = targetFundId;
                }
                loan.operatorType = 1;
                if (![db updateRowsInTable:@"BK_LOAN" onProperties:{
                        SSJLoanTable.writeDate,
                        SSJLoanTable.version,
                        SSJLoanTable.targetFundid,
                        SSJLoanTable.endTargetFundid,
                        SSJLoanTable.operatorType
                } withObject:loan where:SSJLoanTable.loanId == loan.loanId]) {
                    dispatch_main_async_safe(^{
                        if (failure) {
                            failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并借贷失败"}]);
                        }
                    });
                    return NO;
                };
            }

            // 取出所有的信用卡还款
            NSArray *repayMentArr = [db getObjectsOfClass:SSJCreditRepaymentTable.class fromTable:@"BK_CREDIT_REPAYMENT"
                                                         where:SSJCreditRepaymentTable.userId == userId
                                                               && SSJCreditRepaymentTable.cardId == sourceFundId
                                                               && SSJCreditRepaymentTable.operatorType != 2];

            for (SSJCreditRepaymentTable *repayment in repayMentArr) {
                repayment.writeDate = writeDate;
                repayment.version = SSJSyncVersion();
                repayment.cardId = targetFundId;
                repayment.operatorType = 1;
                if (![db updateRowsInTable:@"BK_CREDIT_REPAYMENT" onProperties:{
                        SSJCreditRepaymentTable.writeDate,
                        SSJCreditRepaymentTable.version,
                        SSJCreditRepaymentTable.cardId,
                        SSJCreditRepaymentTable.operatorType
                } withObject:repayment where:SSJCreditRepaymentTable.repaymentId == repayment.repaymentId]) {
                    dispatch_main_async_safe(^{
                        if (failure) {
                            failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并还款失败"}]);
                        }
                    });
                    return NO;
                };
            }


            // 如果需要删除资金帐户,则要因为数据都转移了,删掉提醒,删掉还款
            if (needToDelete) {
                SSJUserCreditTable *card = [db getOneObjectOfClass:SSJUserCreditTable.class fromTable:@"BK_USER_CREDIT" where:SSJUserCreditTable.cardId == sourceFundId];

                if (card) {
                    // 如果是信用卡,那要处理提醒和信用卡表
                    card.operatorType = 2;
                    card.writeDate = writeDate;
                    card.version = SSJSyncVersion();
                    if (![db updateRowsInTable:@"BK_USER_CREDIT" onProperties:{
                            SSJUserCreditTable.operatorType,
                            SSJUserCreditTable.writeDate,
                            SSJUserCreditTable.version
                    }               withObject:card where:SSJUserCreditTable.cardId == card.cardId]) {
                        dispatch_main_async_safe(^{
                            if (failure) {
                                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey: @"删除信用卡表失败失败"}]);
                            }
                        });
                        return NO;

                    }

                    if (card.remindId) {
                        SSJUserRemindTable *remind = [[SSJUserRemindTable alloc] init];
                        remind.operatorType = 2;
                        remind.writeDate = writeDate;
                        remind.version = SSJSyncVersion();
                        if (![db updateRowsInTable:@"BK_USER_REMIND" onProperties:{
                                SSJUserRemindTable.operatorType,
                                SSJUserRemindTable.writeDate,
                                SSJUserRemindTable.version
                        }               withObject:remind where:SSJUserRemindTable.remindId == card.remindId]) {
                            dispatch_main_async_safe(^{
                                if (failure) {
                                    failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey: @"删除提醒表失败失败"}]);
                                }
                            });
                            return NO;

                        }
                    }
                }

                SSJFundInfoTable *fund = [[SSJFundInfoTable alloc] init];
                fund.operatorType = 2;
                fund.writeDate = writeDate;
                fund.version = SSJSyncVersion();
                if (![db updateRowsInTable:@"BK_FUND_INFO" onProperties:{
                        SSJFundInfoTable.operatorType,
                        SSJFundInfoTable.writeDate,
                        SSJFundInfoTable.version
                }               withObject:fund where:SSJFundInfoTable.fundId == sourceFundId]) {
                    dispatch_main_async_safe(^{
                        if (failure) {
                            failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey: @"删除提醒表失败失败"}]);
                        }
                    });
                    return NO;

                }
            }

            dispatch_main_async_safe(^{
                if (success) {
                    success();
                }
            });

            return YES;

        }];


    }];
}

+ (void)getFundingsWithType:(SSJFundsTransferType)fundType
                  exceptFundItem:(SSJBaseCellItem *)fundItem
                         Success:(void(^)(NSArray *fundList))success
                         failure:(void (^)(NSError *error))failure {
    [[SSJOrmDatabaseQueue sharedInstance] asyncInDatabase:^(WCTDatabase *db) {
        NSString *userId = SSJUSERID();

        NSString *fundId;

        if (fundItem) {
            if ([fundItem isKindOfClass:[SSJFinancingHomeitem class]]) {
                SSJFinancingHomeitem *fundingItem = (SSJFinancingHomeitem *)fundItem;
                fundId = fundingItem.fundingID;
            } else if ([fundItem isKindOfClass:[SSJCreditCardItem class]]) {
                SSJCreditCardItem *cardItem = (SSJCreditCardItem *)fundItem;
                fundId = cardItem.fundingID;
            }
        } else {
            fundId = @"";
        }

        NSArray *tempFunsArr = [NSArray array];

        NSMutableArray *funsArr = [NSMutableArray arrayWithCapacity:0];


        if (fundType == SSJFundsTransferTypeNormal) {
            tempFunsArr = [db getObjectsOfClass:SSJFundInfoTable.class fromTable:@"BK_FUND_INFO"
                                          where:SSJFundInfoTable.userId == userId
                                                && SSJFundInfoTable.fundParent.notIn(@[@"3",@"10",@"11",@"9",@"16"])
                                                && SSJFundInfoTable.operatorType != 2
                                                && SSJFundInfoTable.fundParent != @"root"
                                                && SSJFundInfoTable.fundId != fundId];
        } else if (fundType == SSJFundsTransferTypeCreditCard) {
            tempFunsArr = [db getObjectsOfClass:SSJFundInfoTable.class fromTable:@"BK_FUND_INFO"
                                          where:SSJFundInfoTable.userId == userId
                                                && SSJFundInfoTable.fundParent.in(@[@"3",@"16"])
                                                && SSJFundInfoTable.operatorType != 2
                                                && SSJFundInfoTable.fundParent != @"root"
                                                && SSJFundInfoTable.fundId != fundId];
        } else if (fundType == SSJFundsTransferTypeAll) {
            tempFunsArr = [db getObjectsOfClass:SSJFundInfoTable.class fromTable:@"BK_FUND_INFO"
                                          where:SSJFundInfoTable.userId == userId
                                                && SSJFundInfoTable.fundParent.notIn(@[@"10",@"11",@"9"])
                                                && SSJFundInfoTable.operatorType != 2
                                                && SSJFundInfoTable.fundParent != @"root"];
        }


        for (SSJFundInfoTable *fund in tempFunsArr) {
            SSJFinancingHomeitem *item = [[SSJFinancingHomeitem alloc] init];
            item.fundingID = fund.fundId;
            item.fundingName = fund.fundName;
            item.fundingIcon = fund.fundIcon;
            item.startColor = fund.startColor;
            item.endColor = fund.endColor;
            item.fundingParent = fund.fundParent;
            item.fundingParentName = [[SSJFundingTypeManager sharedManager] modelForFundId:fund.fundParent].name;
            item.fundingColor = fund.fundColor;
            [funsArr addObject:item];
        }

        dispatch_main_async_safe(^{
            if (success) {
                success(funsArr);
            }
        });
    }];

}



@end
