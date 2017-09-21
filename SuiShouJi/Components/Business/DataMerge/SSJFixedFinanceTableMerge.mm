//
//  SSJFixedFinanceTableMerge.m
//  SuiShouJi
//
//  Created by ricky on 2017/9/20.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanceTableMerge.h"

@implementation SSJFixedFinanceTableMerge

+ (NSString *)mergeTableName {
    return @"BK_FIXED_FINANCE_PRODUCT";
}

+ (NSString *)tempTableName {
    return @"temp_fixed_finance_product";
}

+ (NSDictionary *)queryDatasWithSourceUserId:(NSString *)sourceUserid
                                TargetUserId:(NSString *)targetUserId
                                   mergeType:(SSJMergeDataType)mergeType
                                    FromDate:(NSDate *)fromDate
                                      ToDate:(NSDate *)toDate
                                  inDataBase:(WCTDatabase *)db {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    
    NSMutableArray *productIds = [NSMutableArray arrayWithCapacity:0];

    
    NSString *startDate;
    
    NSString *endDate;
    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        startDate = [fromDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    } else if (mergeType == SSJMergeDataTypeByBillDate) {
        startDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd"];
        endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd"];
    }

    NSArray *cids = [db getOneDistinctColumnOnResult:SSJUserChargeTable.cid fromTable:@"bk_user_charge" where:SSJUserChargeTable.userId == sourceUserid
                                                                                                     && SSJUserChargeTable.writeDate.inTable(@"bk_user_charge").between(startDate, endDate)
                                                                                                     && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2
                                                                                                     && SSJUserChargeTable.chargeType == SSJChargeIdTypeFixedFinance];

    for (NSString *cid in cids) {
        NSString *productId = [cid substringWithRange:NSMakeRange(0 , 36)];
        [productIds addObject:productId];
    }
    
    
    WCTMultiSelect *select;
    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        select = [[db prepareSelectMultiObjectsOnResults:SSJFixedFinanceProductTable.AllProperties
                                              fromTables:@[[self mergeTableName]]]
                      where:SSJFixedFinanceProductTable.productId.inTable([self mergeTableName]).in(productIds)];

        
    } else if (mergeType == SSJMergeDataTypeByBillDate) {
        select = [[db prepareSelectMultiObjectsOnResults:SSJFixedFinanceProductTable.AllProperties
                                              fromTables:@[ [self mergeTableName] ]]
                  where:SSJFixedFinanceProductTable.productId.inTable([self mergeTableName]).in(productIds)];
    }
    
    WCTError *error = select.error;
    
    if (error) {
        dict[@"error"] = error;
    }
    
    WCTMultiObject *multiObject;
    
    while ((multiObject = [select nextMultiObject])) {
        SSJFixedFinanceProductTable *fixedFinanceProduct = (SSJFixedFinanceProductTable *)[multiObject objectForKey:[self mergeTableName]];
        [tempArr addObject:fixedFinanceProduct];
    }
    
    dict[@"results"] = tempArr;
    
    return dict;
}

+ (NSDictionary *)getSameNameIdsWithSourceUserId:(NSString *)sourceUserid
                                    TargetUserId:(NSString *)targetUserId
                                       withDatas:(NSArray *)datas
                                      inDataBase:(WCTDatabase *)db {
    
    // 建立一个新老id对照的字典,key是老的id,value是新的id
    NSMutableDictionary *newAndOldIdDic = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [datas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SSJFixedFinanceProductTable *currentFinanceProduct = (SSJFixedFinanceProductTable *)obj;

        SSJFixedFinanceProductTable *sameNameFinanceProduct = [db getOneObjectOfClass:SSJFixedFinanceProductTable.class
                                                   fromTable:[self mergeTableName]
                                                       where:SSJFixedFinanceProductTable.productName == currentFinanceProduct.productName
                                                             && SSJFixedFinanceProductTable.money == currentFinanceProduct.money
                                                             && SSJFixedFinanceProductTable.startDate == currentFinanceProduct.startDate
                                                             && SSJFixedFinanceProductTable.endDate == currentFinanceProduct.endDate
                                                             && SSJFixedFinanceProductTable.writeDate == currentFinanceProduct.writeDate
                                                             && SSJFixedFinanceProductTable.userId == targetUserId
                                                             && SSJFixedFinanceProductTable.operatorType != 2];
        
        if (currentFinanceProduct) {
            newAndOldIdDic[currentFinanceProduct.productId] = sameNameFinanceProduct.productId;
        }
        
    }];
    
    
    return newAndOldIdDic;
}

+ (BOOL)updateRelatedTableWithSourceUserId:(NSString *)sourceUserid
                              TargetUserId:(NSString *)targetUserId
                                 withDatas:(NSDictionary *)datas
                                inDataBase:(WCTDatabase *)db {
    
    BOOL success = NO;
    
    NSArray *allJFixedFinance = [db getAllObjectsOfClass:SSJFixedFinanceProductTable.class fromTable:[self tempTableName]];
    
    for (SSJFixedFinanceProductTable *fixedFinance in allJFixedFinance) {
        NSString *oldId = fixedFinance.productId;
        NSString *newId = [datas objectForKey:oldId];
        
        if (!newId) {
            newId = SSJUUID();
        }
        
        if (![db isTableExists:@"temp_user_charge"]) {
            SSJPRINT(@">>>>>>>>借贷所关联的表不存在<<<<<<<<");
            success = NO;
            break;
        }
        
        // 更新流水表
        NSArray *oldCharges = [db getObjectsOfClass:SSJUserChargeTable.class fromTable:@"temp_user_charge" where:SSJUserChargeTable.cid.like([NSString stringWithFormat:@"%@%%",oldId])];
        for (SSJUserChargeTable *userCharge in oldCharges) {
            userCharge.cid = [NSString stringWithFormat:@"%@_%@",newId,[[userCharge.cid componentsSeparatedByString:@"_"] lastObject]];
            success = [db updateRowsInTable:@"temp_user_charge"
                               onProperties:SSJUserChargeTable.cid
                                 withObject:userCharge
                                      where:SSJUserChargeTable.chargeId == userCharge.chargeId];
            if (!success) {
                break;
            }
        }
        
        // 如果有同名的则删除当前固收理财,如果没有则吧固收理财id更新为新的id
        if ([datas objectForKey:oldId]) {
            success = [db deleteObjectsFromTable:@"temp_fixed_finance_product"
                                           where:SSJFixedFinanceProductTable.productId == oldId];
        } else {
            success = [db updateRowsInTable:@"temp_fixed_finance_product"
                                 onProperty:SSJFixedFinanceProductTable.productId withValue:newId
                                      where:SSJFixedFinanceProductTable.productId == oldId];
        }
        
    };
    
    // 将所有的固收理财的userid更新为目标userid
    SSJFixedFinanceProductTable *fixedFinance = [[SSJFixedFinanceProductTable alloc] init];
    fixedFinance.userId = targetUserId;
    success = [db updateRowsInTable:@"temp_fixed_finance_product"
                       onProperties:SSJFixedFinanceProductTable.userId
                         withObject:fixedFinance
                              where:SSJFixedFinanceProductTable.userId == sourceUserid];
    
    // 如果有固收理财,则将原来的固收理财打开
    if ([db getOneValueOnResult:SSJFixedFinanceProductTable.AnyProperty.count() fromTable:@"temp_loan" where:SSJLoanTable.type == 1]) {
        [db updateRowsInTable:@"BK_FUND_INFO" onProperty:SSJFundInfoTable.display withValue:@(1) where:SSJFundInfoTable.fundParent == @"17" && SSJFundInfoTable.userId == targetUserId];
    }
    
    return success;
}


@end
