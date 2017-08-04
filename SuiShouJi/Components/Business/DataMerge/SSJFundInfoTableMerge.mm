//
//  SSJFundInfoTableMerge.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFundInfoTableMerge.h"

@implementation SSJFundInfoTableMerge

+ (NSString *)mergeTableName {
    return @"BK_FUND_INFO";
}

+ (NSString *)tempTableName {
    return @"temp_fund_info";
}

+ (NSDictionary *)queryDatasWithSourceUserId:(NSString *)sourceUserid
                                TargetUserId:(NSString *)targetUserId
                                   mergeType:(SSJMergeDataType)mergeType
                                    FromDate:(NSDate *)fromDate
                                      ToDate:(NSDate *)toDate
                                  inDataBase:(WCTDatabase *)db {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    
    WCTPropertyList multiProperties;
    for (const WCTProperty& property : SSJFundInfoTable.AllProperties) {
        multiProperties.push_back(property.inTable([self mergeTableName]));
    }
    
    NSString *startDate;
    
    NSString *endDate;
    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        startDate = [fromDate formattedDateWithFormat:@"yyyy-MM-dd HH:ss:mm"];
        
        endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd HH:ss:mm"];
    } else if (mergeType == SSJMergeDataTypeByBillDate) {
        startDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd"];
        endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd"];
    }
    
    WCTMultiSelect *select;

    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        select = [[db prepareSelectMultiObjectsOnResults:multiProperties fromTables:@[ [self mergeTableName] ]]
                  where:SSJFundInfoTable.fundId.inTable([self mergeTableName]).in([db getOneDistinctColumnOnResult:SSJUserChargeTable.fundId fromTable:@"bk_user_charge"
                                                                                                             where:SSJUserChargeTable.writeDate.inTable(@"bk_user_charge").between(startDate, endDate)
                                                                              && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                                                                              && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2])];
        
    } else if (mergeType == SSJMergeDataTypeByBillDate) {
        select = [[db prepareSelectMultiObjectsOnResults:multiProperties fromTables:@[ [self mergeTableName] ]]
                  where:SSJFundInfoTable.fundId.inTable([self mergeTableName]).in([db getOneDistinctColumnOnResult:SSJUserChargeTable.fundId fromTable:@"bk_user_charge"
                                                                                                             where:SSJUserChargeTable.billDate.inTable(@"bk_user_charge").between(startDate, endDate)
                                                                                   && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                                                                                   && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2])];
    }
    
    WCTError *error = select.error;
    
    if (error) {
        [dict setObject:error forKey:@"error"];
    }
    
    WCTMultiObject *multiObject;
    
    while ((multiObject = [select nextMultiObject])) {
        SSJFundInfoTable *funds = (SSJFundInfoTable *)[multiObject objectForKey:[self mergeTableName]];
        [tempArr addObject:funds];
    }
    
    [dict setObject:tempArr forKey:@"results"];
    
    return dict;
}

+ (NSDictionary *)getSameNameIdsWithSourceUserId:(NSString *)sourceUserid
                                    TargetUserId:(NSString *)targetUserId
                                       withDatas:(NSArray *)datas
                                      inDataBase:(WCTDatabase *)db {
    
    // 建立一个新老id对照的字典,key是老的id,value是新的id
    NSMutableDictionary *newAndOldIdDic = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [datas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SSJFundInfoTable *currentFund = (SSJFundInfoTable *)obj;
        
        SSJFundInfoTable *sameNameFund = [db getOneObjectOfClass:SSJFundInfoTable.class
                                                         fromTable:[self mergeTableName]
                                           where:SSJFundInfoTable.fundName == currentFund.fundName
                                          && SSJBooksTypeTable.userId == targetUserId];
        
        if (sameNameFund) {
            [newAndOldIdDic setObject:sameNameFund.fundId forKey:currentFund.fundId];
        }
        
    }];
    
    
    return newAndOldIdDic;
}

+ (BOOL)updateRelatedTableWithSourceUserId:(NSString *)sourceUserid
                              TargetUserId:(NSString *)targetUserId
                                 withDatas:(NSDictionary *)datas
                                inDataBase:(WCTDatabase *)db {
    
    BOOL success = NO;
    
    NSArray *allReminds = [db getAllObjectsOfClass:SSJFundInfoTable.class fromTable:[self tempTableName]];

    for (SSJFundInfoTable *fund in allReminds) {
        NSString *oldId = fund.fundId;
        NSString *newId = [datas objectForKey:oldId];
        
        if (!newId) {
            newId = SSJUUID();
        }
        
        if (![db isTableExists:@"temp_user_charge"] || ![db isTableExists:@"temp_charge_period_config"] || ![db isTableExists:@"temp_user_credit"] || ![db isTableExists:@"temp_credit_repayment"] || ![db isTableExists:@"temp_loan"] || ![db isTableExists:@"temp_fund_info"] || ![db isTableExists:@"temp_transfer_cycle"]) {
            SSJPRINT(@">>>>>>>>资金账户所关联的表不存在<<<<<<<<");
            success = NO;
            break;
        }
        
        // 更新流水表
        SSJUserChargeTable *userCharge = [[SSJUserChargeTable alloc] init];
        userCharge.fundId = newId;
        success = [db updateRowsInTable:@"temp_user_charge"
                           onProperties:SSJUserChargeTable.fundId
                             withObject:userCharge
                                  where:SSJUserChargeTable.fundId == oldId];
        if (!success) {
            break;
        }
        
        // 更新周期记账表
        SSJChargePeriodConfigTable *periodConfig = [[SSJChargePeriodConfigTable alloc] init];
        periodConfig.fundId = newId;
        success = [db updateRowsInTable:@"temp_charge_period_config"
                           onProperties:SSJChargePeriodConfigTable.fundId
                             withObject:periodConfig
                                  where:SSJChargePeriodConfigTable.fundId == oldId];
        
        if (!success) {
            break;
        }
        
        // 更新信用卡表
        SSJUserCreditTable *creditCard = [[SSJUserCreditTable alloc] init];
        creditCard.cardId = newId;
        success = [db updateRowsInTable:@"temp_user_credit"
                           onProperties:SSJUserCreditTable.cardId
                             withObject:creditCard
                                  where:SSJUserCreditTable.cardId == oldId];
        
        if (!success) {
            break;
        }
        
        // 更新信用卡还款表
        SSJCreditRepaymentTable *creditRepayMent = [[SSJCreditRepaymentTable alloc] init];
        creditRepayMent.cardId = newId;
        success = [db updateRowsInTable:@"temp_credit_repayment"
                           onProperties:SSJCreditRepaymentTable.cardId
                             withObject:creditRepayMent
                                  where:SSJCreditRepaymentTable.cardId == oldId];
        
        if (!success) {
            break;
        }
        
        // 更新借贷表,分别更新来源和目标账户,结清账户
        SSJLoanTable *loanfund = [[SSJLoanTable alloc] init];
        loanfund.fundId = newId;
        success = [db updateRowsInTable:@"temp_loan"
                           onProperties:SSJLoanTable.fundId
                             withObject:loanfund
                                  where:SSJLoanTable.fundId == oldId];
        
        SSJLoanTable *loanTargetFund = [[SSJLoanTable alloc] init];
        loanTargetFund.targetFundid = newId;
        success = [db updateRowsInTable:@"temp_loan"
                           onProperties:SSJLoanTable.targetFundid
                             withObject:loanTargetFund
                                  where:SSJLoanTable.targetFundid == oldId];
        
        SSJLoanTable *loanEndFund = [[SSJLoanTable alloc] init];
        loanEndFund.endTargetFundid = newId;
        success = [db updateRowsInTable:@"temp_loan"
                           onProperties:SSJLoanTable.endTargetFundid
                             withObject:loanEndFund
                                  where:SSJLoanTable.endTargetFundid == oldId];
        
        if (!success) {
            break;
        }
        
        // 更新周期转账
        SSJTransferCycleTable *cycleTransferIn = [[SSJTransferCycleTable alloc] init];
        cycleTransferIn.transferInId = newId;
        success = [db updateRowsInTable:@"temp_transfer_cycle"
                           onProperties:SSJTransferCycleTable.transferInId
                             withObject:cycleTransferIn
                                  where:SSJTransferCycleTable.transferInId == oldId];
        
        // 更新周期转账,要分别更新转入和转出两个字段
        SSJTransferCycleTable *cycleTransferOut = [[SSJTransferCycleTable alloc] init];
        cycleTransferOut.transferOutId = newId;
        success = [db updateRowsInTable:@"temp_transfer_cycle"
                           onProperties:SSJTransferCycleTable.transferOutId
                             withObject:cycleTransferOut
                                  where:SSJTransferCycleTable.transferOutId == oldId];
        
        if (!success) {
            break;
        }
        
        // 如果有同名的则删除当前资金账户,如果没有则吧资金账户id更新为新的id
        if ([datas objectForKey:oldId]) {
            success = [db deleteObjectsFromTable:@"temp_fund_info"
                                           where:SSJFundInfoTable.fundId == oldId];
            
            success = [db deleteObjectsFromTable:@"temp_user_credit"
                                           where:SSJUserCreditTable.cardId == oldId];
            
            success = [db deleteObjectsFromTable:@"temp_credit_repayment"
                                           where:SSJCreditRepaymentTable.cardId == oldId];
        } else {
            success = [db updateRowsInTable:@"temp_fund_info" onProperty:SSJFundInfoTable.fundId withValue:newId
                                      where:SSJFundInfoTable.fundId == oldId];
            
            success = [db updateRowsInTable:@"temp_user_credit" onProperty:SSJUserCreditTable.cardId withValue:newId
                                      where:SSJUserCreditTable.cardId == oldId];
            
            success = [db updateRowsInTable:@"temp_credit_repayment" onProperty:SSJCreditRepaymentTable.cardId withValue:newId
                                      where:SSJCreditRepaymentTable.cardId == oldId];
            
        }

    }
    
    // 和资金账户有关的表:流水,周期记账,借贷,信用卡,周期转账,信用卡还款
    [datas enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *oldId = obj;
        NSString *newId = key;
        
        
    }];
    
    // 将所有的资金账户的userid更新为目标userid
    SSJFundInfoTable *userfund = [[SSJFundInfoTable alloc] init];
    userfund.userId = targetUserId;
    success = [db updateRowsInTable:@"temp_fund_info"
                       onProperties:SSJFundInfoTable.userId
                         withObject:userfund
                              where:SSJFundInfoTable.userId == sourceUserid];
    
    // 将所有信用卡还款的userid更新为目标userid
    SSJCreditRepaymentTable *userCreditRepayment = [[SSJCreditRepaymentTable alloc] init];
    userCreditRepayment.userId = targetUserId;
    success = [db updateRowsInTable:@"temp_credit_repayment"
                       onProperties:SSJCreditRepaymentTable.userId
                         withObject:userCreditRepayment
                              where:SSJCreditRepaymentTable.userId == sourceUserid];
    
    // 将所有的信用卡的userid更新为目标userid
    SSJUserCreditTable *userCredit = [[SSJUserCreditTable alloc] init];
    userCredit.userId = targetUserId;
    success = [db updateRowsInTable:@"temp_user_credit"
                       onProperties:SSJUserCreditTable.userId
                         withObject:userCredit
                              where:SSJUserCreditTable.userId == sourceUserid];
    
    return success;
}


@end
