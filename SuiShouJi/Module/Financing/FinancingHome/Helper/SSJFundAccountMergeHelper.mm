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

@interface SSJFundAccountMergeHelper()

@property (nonatomic, strong) WCTDatabase *db;

@end

@implementation SSJFundAccountMergeHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)startMergeWithSourceFundId:(NSString *)sourceFundId
                      targetFundId:(NSString *)targetFundId
                      needToDelete:(BOOL)needToDelete
                            Success:(void(^)())success
                            failure:(void (^)(NSError *error))failure {
    @weakify(self);
    [self.db runTransaction:^BOOL{
        @strongify(self);
        
        NSString *userId = SSJUSERID();
        
        
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        // 取出账本中所有的流水
        NSArray *chargeArr = [self.db getObjectsOfClass:SSJUserChargeTable.class fromTable:@"BK_USER_CHARGE"
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
            
            if (![self.db updateRowsInTable:@"BK_USER_CHARGE" onProperties:{
                SSJUserChargeTable.fundId,
                SSJUserChargeTable.writeDate,
                SSJUserChargeTable.version
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
                if (![self.db updateRowsInTable:@"BK_USER_CHARGE" onProperty:SSJUserChargeTable.writeDate withValue:now
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
        NSArray *transferArr = [self.db getObjectsOfClass:SSJTransferCycleTable.class fromTable:@"BK_TRANSFER_CYCLE"
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
            
            if (![transfer.transferInId isEqualToString:transfer.transferOutId]) {
                if (![self.db updateRowsInTable:@"BK_TRANSFER_CYCLE" onProperties:{
                    SSJTransferCycleTable.writeDate,
                    SSJTransferCycleTable.version,
                    SSJTransferCycleTable.transferInId,
                    SSJTransferCycleTable.transferOutId
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
                if (![self.db updateRowsInTable:@"BK_TRANSFER_CYCLE" onProperties:{
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
        NSArray *periodChargeArr = [self.db getObjectsOfClass:SSJChargePeriodConfigTable.class fromTable:@"BK_CHARGE_PERIOD_CONFIG"
                                                    where:SSJChargePeriodConfigTable.userId == userId
                                && SSJChargePeriodConfigTable.fundId == sourceFundId
                                && SSJChargePeriodConfigTable.operatorType != 2];
        
        for (SSJChargePeriodConfigTable *periodCharge in periodChargeArr) {
            periodCharge.writeDate = writeDate;
            periodCharge.version = SSJSyncVersion();
            periodCharge.billId = targetFundId;
            
            if (![self.db updateRowsInTable:@"BK_CHARGE_PERIOD_CONFIG" onProperties:{
                SSJChargePeriodConfigTable.writeDate,
                SSJChargePeriodConfigTable.version,
                SSJChargePeriodConfigTable.billId
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
        NSArray *loanArr = [self.db getObjectsOfClass:SSJLoanTable.class fromTable:@"BK_LOAN"
                                                    where:SSJLoanTable.userId == userId
                                && (SSJLoanTable.targetFundid == sourceFundId
                                    || SSJLoanTable.endTargetFundid == sourceFundId
                                    )
                                && SSJLoanTable.operatorType != 2];
        
        for (SSJLoanTable *loan in transferArr) {
            loan.writeDate = writeDate;
            loan.version = SSJSyncVersion();
            if ([loan.targetFundid isEqualToString:sourceFundId]) {
                loan.targetFundid = targetFundId;
            } else if ([loan.endTargetFundid isEqualToString:sourceFundId]) {
                loan.endTargetFundid = targetFundId;
            }
            
            if (![self.db updateRowsInTable:@"BK_LOAN" onProperties:{
                SSJLoanTable.writeDate,
                SSJLoanTable.version,
                SSJLoanTable.targetFundid,
                SSJLoanTable.endTargetFundid
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
        NSArray *repayMentArr = [self.db getObjectsOfClass:SSJCreditRepaymentTable.class fromTable:@"BK_CREDIT_REPAYMENT"
                                                where:SSJCreditRepaymentTable.userId == userId
                            && SSJCreditRepaymentTable.cardId == sourceFundId
                            && SSJCreditRepaymentTable.operatorType != 2];
        
        for (SSJCreditRepaymentTable *repayment in repayMentArr) {
            repayment.writeDate = writeDate;
            repayment.version = SSJSyncVersion();
            repayment.cardId = targetFundId;
            
            if (![self.db updateRowsInTable:@"BK_CREDIT_REPAYMENT" onProperties:{
                SSJCreditRepaymentTable.writeDate,
                SSJCreditRepaymentTable.version,
                SSJCreditRepaymentTable.cardId
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
            SSJUserCreditTable *card = [self.db getOneObjectOfClass:SSJUserCreditTable.class fromTable:@"BK_USER_CREDIT" where:SSJUserCreditTable.cardId == sourceFundId];
            
            if (card) {
                // 如果是信用卡,那要处理提醒和信用卡表
                card.operatorType = 2;
                card.writeDate = writeDate;
                card.version = SSJSyncVersion();
                if (![self.db updateRowsInTable:@"BK_USER_CREDIT" onProperties:{
                    SSJUserCreditTable.operatorType,
                    SSJUserCreditTable.writeDate,
                    SSJUserCreditTable.version
                } withObject:card where:SSJUserCreditTable.cardId == card.cardId]) {
                    dispatch_main_async_safe(^{
                        if (failure) {
                            failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"删除信用卡表失败失败"}]);
                        }
                    });
                    return NO;

                }
            
                if (card.remindId) {
                    SSJUserRemindTable *remind = [[SSJUserRemindTable alloc] init];
                    remind.operatorType = 2;
                    remind.writeDate = writeDate;
                    remind.version = SSJSyncVersion();
                    if (![self.db updateRowsInTable:@"BK_USER_REMIND" onProperties:{
                        SSJUserRemindTable.operatorType,
                        SSJUserRemindTable.writeDate,
                        SSJUserRemindTable.version
                    } withObject:remind where:SSJUserRemindTable.remindId == card.remindId]) {
                        dispatch_main_async_safe(^{
                            if (failure) {
                                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"删除提醒表失败失败"}]);
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
            if (![self.db updateRowsInTable:@"BK_FUND_INFO" onProperties:{
                SSJFundInfoTable.operatorType,
                SSJFundInfoTable.writeDate,
                SSJFundInfoTable.version
            } withObject:fund where:SSJFundInfoTable.fundId == sourceFundId]) {
                dispatch_main_async_safe(^{
                    if (failure) {
                        failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"删除提醒表失败失败"}]);
                    }
                });
                return NO;
                
            }

        }
        
        if (success) {
            success();
        }
        
        
        return YES;
        
    }];
}

- (NSArray *)getFundingsWithType:(SSJFundsTransferType)fundType exceptFundItem:(SSJBaseCellItem *)fundItem{
    NSString *userId = SSJUSERID();
    
    NSString *fundId;
    
    if ([fundItem isKindOfClass:[SSJFinancingHomeitem class]]) {
        SSJFinancingHomeitem *fundingItem = (SSJFinancingHomeitem *)fundItem;
        fundId = fundingItem.fundingID;
    } else if ([fundItem isKindOfClass:[SSJCreditCardItem class]]) {
        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)fundItem;
        fundId = cardItem.cardId;
    }
    
    NSArray *tempFunsArr = [NSArray array];
    
    NSMutableArray *funsArr = [NSMutableArray arrayWithCapacity:0];

    
    if (fundType == SSJFundsTransferTypeNormal) {
        tempFunsArr = [self.db getObjectsOfClass:SSJFundInfoTable.class fromTable:@"BK_FUND_INFO"
                                                where:SSJFundInfoTable.userId == userId
                   && SSJFundInfoTable.fundParent.notIn(@[@"3",@"10",@"11",@"9",@"16"])
                   && SSJFundInfoTable.operatorType != 2
                   && SSJFundInfoTable.fundParent != @"root"
                   && SSJFundInfoTable.fundId != fundId];
    } else if (fundType == SSJFundsTransferTypeCreditCard) {
        tempFunsArr = [self.db getObjectsOfClass:SSJFundInfoTable.class fromTable:@"BK_FUND_INFO"
                                       where:SSJFundInfoTable.userId == userId
                   && SSJFundInfoTable.fundParent.in(@[@"3",@"16"])
                   && SSJFundInfoTable.operatorType != 2
                   && SSJFundInfoTable.fundParent != @"root"
                   && SSJFundInfoTable.fundId != fundId];
    } else if (fundType == SSJFundsTransferTypeAll) {
        tempFunsArr = [self.db getObjectsOfClass:SSJFundInfoTable.class fromTable:@"BK_FUND_INFO"
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
        item.fundingParentName = [self.db getOneValueOnResult:SSJFundInfoTable.fundName fromTable:@"BK_FUND_INFO" where:SSJFundInfoTable.fundParent == @"root"
                                   && SSJFundInfoTable.fundId == fund.fundParent];
        item.fundingColor = fund.fundColor;
        [funsArr addObject:item];
    }
    
    return funsArr;
}


- (WCTDatabase *)db {
    if (!_db) {
        _db = [[WCTDatabase alloc] initWithPath:SSJSQLitePath()];
    }
    return _db;
}



@end
