//
//  SSJUserBillTypeTableMerge.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/25.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserBillTypeTableMerge.h"

@implementation SSJUserBillTypeTableMerge

+ (NSString *)mergeTableName {
    return @"BK_USER_BILL_TYPE";
}

+ (NSString *)tempTableName {
    return @"temp_user_bill_type";
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
    
    for (const WCTProperty& property : SSJTransferCycleTable.AllProperties) {
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
    
    NSArray *booksIds;
    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        booksIds = [db getOneDistinctColumnOnResult:SSJUserChargeTable.booksId
                                          fromTable:@"bk_user_charge"
                                              where:SSJUserChargeTable.billDate.inTable(@"bk_user_charge").between(startDate, endDate)
                    && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                    && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2];
        
    } else if (mergeType == SSJMergeDataTypeByBillDate) {
        booksIds = [db getOneDistinctColumnOnResult:SSJUserChargeTable.booksId
                                          fromTable:@"bk_user_charge"
                                              where:SSJUserChargeTable.billDate.inTable(@"bk_user_charge").between(startDate, endDate)
                    && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                    && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2];
    }

    
    select = [[db prepareSelectMultiObjectsOnResults:multiProperties
                                          fromTables:@[ [self mergeTableName] ]]
              where:SSJUserBillTypeTable.booksId.inTable([self mergeTableName]).in(booksIds)];
    
    
    WCTError *error = select.error;
    
    if (error) {
        [dict setObject:error forKey:@"error"];
    }
    
    WCTMultiObject *multiObject;
    
    while ((multiObject = [select nextMultiObject])) {
        SSJTransferCycleTable *transfers = (SSJTransferCycleTable *)[multiObject objectForKey:[self mergeTableName]];
        [tempArr addObject:transfers];
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
        SSJUserBillTypeTable *currentUserBillType = (SSJUserBillTypeTable *)obj;
        
        SSJUserBillTypeTable *sameNameUserBillType = [db getOneObjectOfClass:SSJUserBillTypeTable.class fromTable:[self mergeTableName]
                                                                       where:SSJUserBillTypeTable.booksId == currentUserBillType.booksId
                                                      && SSJUserBillTypeTable.billName == currentUserBillType.billName
                                                      
                                                      && SSJUserBillTypeTable.userId == targetUserId];
        
        if (sameNameUserBillType) {
            [newAndOldIdDic setObject:currentUserBillType.billId forKey:sameNameUserBillType.billId];
        }
        
    }];
    
    
    return newAndOldIdDic;
}

+ (BOOL)updateRelatedTableWithSourceUserId:(NSString *)sourceUserid
                              TargetUserId:(NSString *)targetUserId
                                 withDatas:(NSDictionary *)datas
                                inDataBase:(WCTDatabase *)db {
    
    __block BOOL success = NO;
    
    // 和周期转账有关的表:流水表
    [datas enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *newId = key;
        NSString *oldId = obj;
        if (![db isTableExists:@"temp_user_charge"] && ![db isTableExists:@"temp_charge_period_config"]) {
            SSJPRINT(@">>>>>>>>周期转账所关联的表不存在<<<<<<<<");
            *stop = YES;
            success = NO;
        }
        
        // 更新流水表
        SSJUserChargeTable *userCharge = [[SSJUserChargeTable alloc] init];
        userCharge.billId = newId;
        success = [db updateRowsInTable:@"temp_user_charge"
                           onProperties:SSJUserChargeTable.billId
                             withObject:userCharge
                                  where:SSJUserChargeTable.billId == oldId];
        if (!success) {
            *stop = YES;
        }
        
        // 更新周期记账
        SSJChargePeriodConfigTable *chargePeriodConfig = [[SSJChargePeriodConfigTable alloc] init];
        chargePeriodConfig.billId = newId;
        success = [db updateRowsInTable:@"temp_charge_period_config"
                           onProperties:SSJChargePeriodConfigTable.billId
                             withObject:userCharge
                                  where:SSJChargePeriodConfigTable.billId == oldId];
        if (!success) {
            *stop = YES;
        }
        
        // 删除同名的记账类型
        success = [db deleteObjectsFromTable:@"temp_user_bill_type"
                                       where:SSJUserBillTypeTable.billId == oldId];
        
        
        if (!success) {
            *stop = YES;
        }
        
    }];
    
    // 将所有的周期转账的userid更新为目标userid
    SSJUserBillTypeTable *userBillType = [[SSJUserBillTypeTable alloc] init];
    userBillType.userId = targetUserId;
    success = [db updateRowsInTable:@"temp_loan"
                       onProperties:SSJUserBillTypeTable.userId
                         withObject:userBillType
                              where:SSJUserBillTypeTable.userId == sourceUserid];
    
    return success;
}


@end
