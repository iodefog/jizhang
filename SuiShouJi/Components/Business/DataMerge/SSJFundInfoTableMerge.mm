//
//  SSJFundInfoTableMerge.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFundInfoTableMerge.h"

@implementation SSJFundInfoTableMerge

+ (NSString *)tableName {
    return @"BK_LOAN";
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
    for (const WCTProperty& property : SSJUserChargeTable.AllProperties) {
        multiProperties.push_back(property.inTable(@"bk_user_charge"));
    }
    for (const WCTProperty& property : SSJFundInfoTable.AllProperties) {
        multiProperties.push_back(property.inTable([self tableName]));
    }
    
    NSString *startDate = [fromDate formattedDateWithFormat:@"yyyy-MM-dd HH:ss:mm.SSS"];
    
    NSString *endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd HH:ss:mm.SSS"];
    
    WCTMultiSelect *select;
    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        select = [[[db prepareSelectMultiObjectsOnResults:multiProperties
                                               fromTables:@[ [self tableName], @"bk_user_charge" ]]
                   where:SSJFundInfoTable.fundId.inTable([self tableName]) == SSJUserChargeTable.fundId.inTable(@"bk_user_charge")
                   && SSJUserChargeTable.writeDate.inTable(@"bk_user_charge").between(startDate, endDate)
                   && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                   && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2]
                  groupBy:{SSJUserChargeTable.fundId.inTable(@"bk_user_charge")}];
        
    } else if (mergeType == SSJMergeDataTypeByWriteBillDate) {
        select = [[[db prepareSelectMultiObjectsOnResults:multiProperties
                                               fromTables:@[ [self tableName], @"bk_user_charge" ]]
                   where:SSJFundInfoTable.fundId.inTable([self tableName]) == SSJUserChargeTable.fundId.inTable(@"bk_user_charge")
                   && SSJUserChargeTable.billDate.inTable(@"bk_user_charge").between(startDate, endDate)
                   && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid]
                  groupBy:{SSJUserChargeTable.fundId.inTable(@"bk_user_charge")}];
    }
    
    WCTError *error = select.error;
    
    [dict setObject:error forKey:@"error"];
    
    WCTMultiObject *multiObject;
    
    while ((multiObject = [select nextMultiObject])) {
        SSJFundInfoTable *funds = (SSJFundInfoTable *)[multiObject objectForKey:[self tableName]];
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
        
        SSJFundInfoTable *sameNameFund = [[db getOneObjectOfClass:SSJFundInfoTable.class
                                                         fromTable:[self tableName]]
                                           where:SSJFundInfoTable.fudName == currentFund.fudName
                                          && SSJBooksTypeTable.userId == targetUserId];
        
        [newAndOldIdDic setObject:currentFund.fundId forKey:sameNameFund.fundId];
        
    }];
    
    
    return newAndOldIdDic;
}

+ (BOOL)updateRelatedTableWithSourceUserId:(NSString *)sourceUserid
                              TargetUserId:(NSString *)targetUserId
                                 withDatas:(NSDictionary *)datas
                                inDataBase:(WCTDatabase *)db {
    
    __block BOOL success = NO;
    
    // 和资金账户有关的表:流水,周期记账,借贷,信用卡,转账,周期转账,信用卡还款
    [datas enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *newId = obj;
        NSString *oldId = key;
        if (![db isTableExists:@"temp_user_charge"] || ![db isTableExists:@"temp_period_config"]) {
            SSJPRINT(@">>>>>>>>资金账户所关联的表不存在<<<<<<<<");
            *stop = NO;
            success = NO;
        }
        
        // 更新流水表
        SSJUserChargeTable *userCharge = [[SSJUserChargeTable alloc] init];
        userCharge.fundId = newId;
        success = [db updateRowsInTable:@"temp_user_charge"
                           onProperties:SSJUserChargeTable.fundId
                             withObject:userCharge
                                  where:SSJUserChargeTable.fundId == oldId];
        if (!success) {
            *stop = YES;
        }
        
        // 更新周期记账表
        SSJChargePeriodConfigTable *periodConfig = [[SSJChargePeriodConfigTable alloc] init];
        periodConfig.fundId = newId;
        success = [db updateRowsInTable:@"temp_charge_period_config"
                           onProperties:SSJChargePeriodConfigTable.fundId
                             withObject:periodConfig
                                  where:SSJChargePeriodConfigTable.fundId == oldId];
        
        if (!success) {
            *stop = YES;
        }
        
        // 更新信用卡表
        SSJUserCreditTable *creditCard = [[SSJUserCreditTable alloc] init];
        creditCard.cardId = newId;
        success = [db updateRowsInTable:@"temp_charge_period_config"
                           onProperties:SSJUserCreditTable.cardId
                             withObject:creditCard
                                  where:SSJUserCreditTable.cardId == oldId];
        
        if (!success) {
            *stop = YES;
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
            *stop = YES;
        }
        
        // 删除同名的资金账户
        success = [db deleteObjectsFromTable:@"temp_fund_info"
                                       where:SSJFundInfoTable.fundId == oldId];
        
        if (!success) {
            *stop = YES;
        }
    }];
    
    return success;
}


@end
