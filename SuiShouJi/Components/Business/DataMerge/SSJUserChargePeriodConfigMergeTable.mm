//
//  SSJUserChargePeriodConfigMergeTable.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserChargePeriodConfigMergeTable.h"

@implementation SSJUserChargePeriodConfigMergeTable

+ (NSString *)tableName {
    return @"BK_CHARGE_PERIOD_CONFIG";
}

+ (NSString *)tempTableName {
    return @"temp_charge_period_config";
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
    for (const WCTProperty& property : SSJChargePeriodConfigTable.AllProperties) {
        multiProperties.push_back(property.inTable([self tableName]));
    }
    
    NSString *startDate = [fromDate formattedDateWithFormat:@"yyyy-MM-dd HH:ss:mm.SSS"];
    
    NSString *endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd HH:ss:mm.SSS"];
    
    WCTMultiSelect *select;
    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        select = [[[db prepareSelectMultiObjectsOnResults:multiProperties
                                               fromTables:@[ [self tableName], @"bk_user_charge" ]]
                   where:SSJChargePeriodConfigTable.configId.inTable([self tableName]) == SSJUserChargeTable.cid.inTable(@"bk_user_charge")
                   && SSJUserChargeTable.writeDate.inTable(@"bk_user_charge").between(startDate, endDate)
                   && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                   && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2]
                  groupBy:{SSJUserChargeTable.booksId.inTable(@"bk_user_charge")}];
        
    } else if (mergeType == SSJMergeDataTypeByWriteBillDate) {
        select = [[[db prepareSelectMultiObjectsOnResults:multiProperties
                                               fromTables:@[ @"bk_user_charge", [self tableName] ]]
                   where:SSJChargePeriodConfigTable.configId.inTable([self tableName]) == SSJUserChargeTable.cid.inTable(@"bk_user_charge")
                   && SSJUserChargeTable.billDate.inTable(@"bk_user_charge").between(startDate, endDate)
                   && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                   && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2]
                  groupBy:{SSJUserChargeTable.booksId.inTable(@"bk_user_charge")}];
        
    }
    
    WCTError *error = select.error;
    
    [dict setObject:error forKey:@"error"];
    
    WCTMultiObject *multiObject;
    
    while ((multiObject = [select nextMultiObject])) {
        SSJChargePeriodConfigTable *periodConfigs = (SSJChargePeriodConfigTable *)[multiObject objectForKey:[self tableName]];
        [tempArr addObject:periodConfigs];
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
        SSJChargePeriodConfigTable *currentConfig = (SSJChargePeriodConfigTable *)obj;
        
        SSJChargePeriodConfigTable *sameNameConfig = [[db getOneObjectOfClass:SSJChargePeriodConfigTable.class
                                                         fromTable:[self tableName]]
                                                    where:SSJChargePeriodConfigTable.fundId == currentConfig.fundId
                                                    && SSJChargePeriodConfigTable.billDate == currentConfig.billDate
                                                    && SSJChargePeriodConfigTable.booksId == currentConfig.booksId
                                                    && SSJChargePeriodConfigTable.userId == targetUserId];
        
        if (sameNameConfig) {
            [newAndOldIdDic setObject:currentConfig.configId forKey:sameNameConfig.configId];
        }
        
    }];
    
    
    return newAndOldIdDic;
}

+ (BOOL)updateRelatedTableWithSourceUserId:(NSString *)sourceUserid
                              TargetUserId:(NSString *)targetUserId
                                 withDatas:(NSDictionary *)datas
                                inDataBase:(WCTDatabase *)db {
    
    __block BOOL success = NO;
    
    // 和账本有关的表:流水,周期记账
    [datas enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *newId = obj;
        NSString *oldId = key;
        if (![db isTableExists:@"temp_user_charge"] || ![db isTableExists:@"temp_period_config"] || ![db isTableExists:@"temp_books_type"]) {
            SSJPRINT(@">>>>>>>>账本所关联的表不存在<<<<<<<<");
            *stop = YES;
            success = NO;
        }
        
        // 更新流水表
        SSJUserChargeTable *userCharge = [[SSJUserChargeTable alloc] init];
        userCharge.booksId = newId;
        success = [db updateRowsInTable:@"temp_user_charge"
                           onProperties:SSJUserChargeTable.booksId
                             withObject:userCharge
                                  where:SSJUserChargeTable.booksId == oldId];
        if (!success) {
            *stop = YES;
        }
        
        // 更新周期记账表
        SSJChargePeriodConfigTable *periodConfig = [[SSJChargePeriodConfigTable alloc] init];
        periodConfig.booksId = newId;
        success = [db updateRowsInTable:@"temp_charge_period_config"
                           onProperties:SSJChargePeriodConfigTable.booksId
                             withObject:periodConfig
                                  where:SSJChargePeriodConfigTable.booksId == oldId];
        if (!success) {
            *stop = YES;
        }
        
        // 删除账本中同名的账本
        success = [db deleteObjectsFromTable:@"temp_books_type"
                                       where:SSJBooksTypeTable.booksId == oldId];
        
        if (!success) {
            *stop = YES;
        }
    }];
    
    return success;
}


@end
