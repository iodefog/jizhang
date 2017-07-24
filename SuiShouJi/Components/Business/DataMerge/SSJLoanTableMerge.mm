//
//  SSJLoanTableMerge.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJLoanTableMerge.h"

@implementation SSJLoanTableMerge

+ (NSString *)tableName {
    return @"BK_LOAN";
}

+ (NSString *)tempTableName {
    return @"temp_loan";
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
    for (const WCTProperty& property : SSJLoanTable.AllProperties) {
        multiProperties.push_back(property.inTable([self tableName]));
    }
    
    NSString *startDate = [fromDate formattedDateWithFormat:@"yyyy-MM-dd HH:ss:mm"];
    
    NSString *endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd HH:ss:mm"];
    
    WCTMultiSelect *select;
    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        select = [[db prepareSelectMultiObjectsOnResults:multiProperties
                                              fromTables:@[ [self tableName] ]]
                  where:SSJLoanTable.loanId.inTable([self tableName]).in([db getObjectsOnResults:SSJUserChargeTable.cid.distinct() fromTable:@"bk_user_charge" where:SSJUserChargeTable.billDate.inTable(@"bk_user_charge").between(startDate, endDate)
                                                                                          && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                                                                                          && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2])];
        
    } else if (mergeType == SSJMergeDataTypeByWriteBillDate) {
        select = [[db prepareSelectMultiObjectsOnResults:multiProperties
                                              fromTables:@[ [self tableName] ]]
                  where:SSJLoanTable.loanId.inTable([self tableName]).in([db getObjectsOnResults:SSJUserChargeTable.cid.distinct() fromTable:@"bk_user_charge" where:SSJUserChargeTable.billDate.inTable(@"bk_user_charge").between(startDate, endDate)
                                                                          && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                                                                          && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2])];
    }
    
    WCTError *error = select.error;
    
    [dict setObject:error forKey:@"error"];
    
    WCTMultiObject *multiObject;
    
    while ((multiObject = [select nextMultiObject])) {
        SSJLoanTable *loans = (SSJLoanTable *)[multiObject objectForKey:[self tableName]];
        [tempArr addObject:loans];
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
        SSJLoanTable *currentLoan = (SSJLoanTable *)obj;
        
        SSJLoanTable *sameNameLoan = [[db getOneObjectOfClass:SSJLoanTable.class
                                                        fromTable:[self tableName]]
                                          where:SSJLoanTable.lender == currentLoan.lender
                                      && SSJLoanTable.money == currentLoan.money
                                      && SSJLoanTable.borrowDate == currentLoan.borrowDate
                                      && SSJLoanTable.fundId == currentLoan.fundId
                                      && SSJLoanTable.targetFundid == currentLoan.targetFundid
                                      && SSJLoanTable.userId == targetUserId];
        
        if (sameNameLoan) {
            [newAndOldIdDic setObject:currentLoan.loanId forKey:sameNameLoan.loanId];
        }
        
    }];
    
    
    return newAndOldIdDic;
}

+ (BOOL)updateRelatedTableWithSourceUserId:(NSString *)sourceUserid
                              TargetUserId:(NSString *)targetUserId
                                 withDatas:(NSDictionary *)datas
                                inDataBase:(WCTDatabase *)db {
    
    __block BOOL success = NO;
    
    // 和借贷有关的表:流水
    [datas enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *newId = obj;
        NSString *oldId = key;
        if (![db isTableExists:@"temp_user_charge"]) {
            SSJPRINT(@">>>>>>>>借贷所关联的表不存在<<<<<<<<");
            *stop = YES;
            success = NO;
        }
        
        // 更新流水表
        SSJUserChargeTable *userCharge = [[SSJUserChargeTable alloc] init];
        userCharge.cid = newId;
        success = [db updateRowsInTable:@"temp_user_charge"
                           onProperties:SSJUserChargeTable.cid
                             withObject:userCharge
                                  where:SSJUserChargeTable.cid == oldId];
        if (!success) {
            *stop = YES;
        }
        
        // 删除同名的借贷
        success = [db deleteObjectsFromTable:@"temp_loan"
                                       where:SSJLoanTable.loanId == oldId];
        
        if (!success) {
            *stop = YES;
        }
        
    }];
    
    return success;
}


@end
