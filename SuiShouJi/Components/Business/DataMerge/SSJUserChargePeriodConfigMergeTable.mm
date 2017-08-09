//
//  SSJUserChargePeriodConfigMergeTable.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserChargePeriodConfigMergeTable.h"

@implementation SSJUserChargePeriodConfigMergeTable

+ (NSString *)mergeTableName {
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
    for (const WCTProperty& property : SSJChargePeriodConfigTable.AllProperties) {
        multiProperties.push_back(property.inTable([self mergeTableName]));
    }
    
    NSString *startDate;
    
    NSString *endDate;
    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        startDate = [fromDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm.ss.SSS"];
        
        endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm.ss.SSS"];
    } else if (mergeType == SSJMergeDataTypeByBillDate) {
        startDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd"];
        endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd"];
    }
    
    WCTMultiSelect *select;
    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        select = [[db prepareSelectMultiObjectsOnResults:multiProperties fromTables:@[ [self mergeTableName] ]]
                  where:SSJChargePeriodConfigTable.configId.inTable([self mergeTableName]).in([db getOneDistinctColumnOnResult:SSJUserChargeTable.cid
                                                                                                       fromTable:@"bk_user_charge"
                                                                                                           where:SSJUserChargeTable.writeDate.inTable(@"bk_user_charge").between(startDate, endDate)
                      
                                                                                          && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                      
                                                                                          && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2])];
        
    } else if (mergeType == SSJMergeDataTypeByBillDate) {
        select = [[db prepareSelectMultiObjectsOnResults:multiProperties fromTables:@[ [self mergeTableName] ]]
                  where:SSJChargePeriodConfigTable.configId.inTable([self mergeTableName]).in([db getOneDistinctColumnOnResult:SSJUserChargeTable.cid
                                                                                                       fromTable:@"bk_user_charge"
                                                                                                           where:SSJUserChargeTable.billDate.inTable(@"bk_user_charge").between(startDate, endDate)
                                                                                          && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                                                                                          && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2])];
        
    }
    
    if (select.error) {
        [dict setObject:select.error forKey:@"error"];
    }
    
    WCTMultiObject *multiObject;
    
    while ((multiObject = [select nextMultiObject])) {
        SSJChargePeriodConfigTable *periodConfigs = (SSJChargePeriodConfigTable *)[multiObject objectForKey:[self mergeTableName]];
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
        
        SSJChargePeriodConfigTable *sameNameConfig = [db getOneObjectOfClass:SSJChargePeriodConfigTable.class
                                                         fromTable:[self mergeTableName]
                                                    where:SSJChargePeriodConfigTable.billDate == currentConfig.billDate
                                                      && SSJChargePeriodConfigTable.money == currentConfig.money
                                                      && SSJChargePeriodConfigTable.type == currentConfig.type
                                                      && SSJChargePeriodConfigTable.userId == targetUserId
                                                      && SSJChargePeriodConfigTable.operatorType != 2];
        
        if (sameNameConfig) {
            [newAndOldIdDic setObject:sameNameConfig.configId forKey:currentConfig.configId];
        }
        
    }];
    
    
    return newAndOldIdDic;
}

+ (BOOL)updateRelatedTableWithSourceUserId:(NSString *)sourceUserid
                              TargetUserId:(NSString *)targetUserId
                                 withDatas:(NSDictionary *)datas
                                inDataBase:(WCTDatabase *)db {
    
    BOOL success = NO;
    
    NSArray *allconfigs = [db getAllObjectsOfClass:SSJChargePeriodConfigTable.class fromTable:[self tempTableName]];
    
    // 和周期记账有关的表:流水,周期记账
    for (SSJChargePeriodConfigTable *period in allconfigs) {
        NSString *oldId = period.configId;
        NSString *newId = [datas objectForKey:period.configId];

        if (!newId) {
            newId = SSJUUID();
        }
        
        if (![db isTableExists:@"temp_user_charge"]) {
            SSJPRINT(@">>>>>>>>账本所关联的表不存在<<<<<<<<");
            success = NO;
            break;
        }
        
        // 更新流水表
        SSJUserChargeTable *userCharge = [[SSJUserChargeTable alloc] init];
        userCharge.cid = newId;
        success = [db updateRowsInTable:@"temp_user_charge"
                           onProperties:SSJUserChargeTable.cid
                             withObject:userCharge
                                  where:SSJUserChargeTable.cid == oldId];
        if (!success) {
            break;
        }
        
        
        // 如果有同名的则删除当前账本,如果没有则吧账本id更新为新的id
        if ([datas objectForKey:period.configId]) {
            success = [db deleteObjectsFromTable:@"temp_charge_period_config"
                                           where:SSJChargePeriodConfigTable.configId == oldId];
        } else {
            success = [db updateRowsInTable:@"temp_charge_period_config" onProperty:SSJChargePeriodConfigTable.configId withValue:newId
                                      where:SSJChargePeriodConfigTable.configId == oldId];
        }
        
        if (!success) {
            break;
        }

    }
    
    // 将所有的周期记账的userid更新为目标userid
    SSJChargePeriodConfigTable *chargePeriod = [[SSJChargePeriodConfigTable alloc] init];
    chargePeriod.userId = targetUserId;
    success = [db updateRowsInTable:@"temp_charge_period_config"
                       onProperties:SSJChargePeriodConfigTable.userId
                         withObject:chargePeriod
                              where:SSJChargePeriodConfigTable.userId == sourceUserid];
    
    return success;
}


@end
