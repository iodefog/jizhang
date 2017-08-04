
//
//  SSJCreditRepaymentTableMerge.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/20.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCreditRepaymentTableMerge.h"

@implementation SSJCreditRepaymentTableMerge

+ (NSString *)mergeTableName {
    return @"BK_CREDIT_REPAYMENT";
}

+ (NSString *)tempTableName {
    return @"temp_credit_repayment";
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

    for (const WCTProperty& property : SSJCreditRepaymentTable.AllProperties) {
        multiProperties.push_back(property.inTable([self mergeTableName]));
    }
    
    NSString *startDate;
    
    NSString *endDate;
    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        startDate = [fromDate formattedDateWithFormat:@"yyyy-MM-dd HH:ss:mm.SSS"];
        
        endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd HH:ss:mm.SSS"];
    } else if (mergeType == SSJMergeDataTypeByBillDate) {
        startDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd"];
        endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd"];
    }
    
    WCTMultiSelect *select;
    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        select = [[db prepareSelectMultiObjectsOnResults:multiProperties fromTables:@[ [self mergeTableName] ]]
                  where:SSJCreditRepaymentTable.cardId.inTable([self mergeTableName]).in([db getOneDistinctColumnOnResult:SSJUserChargeTable.fundId fromTable:@"bk_user_charge"
                                                                                                                    where:SSJUserChargeTable.writeDate.inTable(@"bk_user_charge").between(startDate, endDate)
                                                                                
                                                                                && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                                                                                
                                                                                && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2])];

        
    } else if (mergeType == SSJMergeDataTypeByBillDate) {
        select = [[db prepareSelectMultiObjectsOnResults:multiProperties fromTables:@[ [self mergeTableName] ]]
                  where:SSJCreditRepaymentTable.cardId.inTable([self mergeTableName]).in([db getOneDistinctColumnOnResult:SSJUserChargeTable.fundId fromTable:@"bk_user_charge"
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
        SSJUserCreditTable *credits = (SSJUserCreditTable *)[multiObject objectForKey:[self mergeTableName]];
        [tempArr addObject:credits];
    }
    
    [dict setObject:tempArr forKey:@"results"];
    
    return dict;
}

+ (NSDictionary *)getSameNameIdsWithSourceUserId:(NSString *)sourceUserid
                                    TargetUserId:(NSString *)targetUserId
                                       withDatas:(NSArray *)datas
                                      inDataBase:(WCTDatabase *)db {
    // 信用卡不需要处理,因为在资金账户中已经处理
    
    return nil;
}

+ (BOOL)updateRelatedTableWithSourceUserId:(NSString *)sourceUserid
                              TargetUserId:(NSString *)targetUserId
                                 withDatas:(NSDictionary *)datas
                                inDataBase:(WCTDatabase *)db {
    // 信用卡不需要处理,因为在资金账户中已经处理
    
    return YES;
}


@end
