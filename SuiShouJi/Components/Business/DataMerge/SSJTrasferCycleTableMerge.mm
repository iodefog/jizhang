//
//  SSJTrasferCycleTableMerge.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJTrasferCycleTableMerge.h"

@implementation SSJTrasferCycleTableMerge

+ (NSString *)tableName {
    return @"BK_TRANSFER_CYCLE";
}

+ (NSString *)tempTableName {
    return @"temp_trasfer_cycle";
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
    for (const WCTProperty& property : SSJTransferCycleTable.AllProperties) {
        multiProperties.push_back(property.inTable([self tableName]));
    }
    
    NSString *startDate = [fromDate formattedDateWithFormat:@"yyyy-MM-dd HH:ss:mm"];
    
    NSString *endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd HH:ss:mm"];
    
    WCTMultiSelect *select;
    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        select = [[db prepareSelectMultiObjectsOnResults:multiProperties
                                              fromTables:@[ [self tableName] ]]
                  where:SSJTransferCycleTable.cycleId.inTable([self tableName]).in([db getObjectsOnResults:SSJUserChargeTable.cid.distinct() fromTable:@"bk_user_charge" where:SSJUserChargeTable.billDate.inTable(@"bk_user_charge").between(startDate, endDate)
                                                                                          && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                                                                                          && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2])];
        
    } else if (mergeType == SSJMergeDataTypeByWriteBillDate) {
        select = [[db prepareSelectMultiObjectsOnResults:multiProperties
                                              fromTables:@[ [self tableName] ]]
                  where:SSJTransferCycleTable.cycleId.inTable([self tableName]).in([db getObjectsOnResults:SSJUserChargeTable.cid.distinct()
                                                                                                 fromTable:@"bk_user_charge"
                                                                                                     where:SSJUserChargeTable.billDate.inTable(@"bk_user_charge").between(startDate, endDate)
                                                                                    && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                                                                                    && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2])];
        
        
    }
    
    WCTError *error = select.error;
    
    [dict setObject:error forKey:@"error"];
    
    WCTMultiObject *multiObject;
    
    while ((multiObject = [select nextMultiObject])) {
        SSJTransferCycleTable *transfers = (SSJTransferCycleTable *)[multiObject objectForKey:[self tableName]];
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
        SSJTransferCycleTable *currentTransfer = (SSJTransferCycleTable *)obj;
        
        SSJTransferCycleTable *sameNameTransfer = [[db getOneObjectOfClass:SSJTransferCycleTable.class
                                                        fromTable:[self tableName]]
                                          where:SSJTransferCycleTable.transferOutId == currentTransfer.transferOutId
                                                   && SSJTransferCycleTable.transferInId == currentTransfer.transferInId
                                                   && SSJTransferCycleTable.money == currentTransfer.money
                                                   && SSJTransferCycleTable.endDate == currentTransfer.endDate
                                                   && SSJTransferCycleTable.beginDate == currentTransfer.beginDate
                                                   && SSJTransferCycleTable.cycleType == currentTransfer.cycleType
                                                   && SSJTransferCycleTable.userId == targetUserId];
        
        if (sameNameTransfer) {
            [newAndOldIdDic setObject:currentTransfer.cycleId forKey:sameNameTransfer.cycleId];
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
        NSString *newId = obj;
        NSString *oldId = key;
        if (![db isTableExists:@"temp_user_charge"]) {
            SSJPRINT(@">>>>>>>>周期转账所关联的表不存在<<<<<<<<");
            *stop = YES;
            success = NO;
        }
        
        // 更新成员流水表
        SSJUserChargeTable *userCharge = [[SSJUserChargeTable alloc] init];
        userCharge.cid = newId;
        success = [db updateRowsInTable:@"temp_user_charge"
                           onProperties:SSJUserChargeTable.cid
                             withObject:userCharge
                                  where:SSJUserChargeTable.cid == oldId];
        if (!success) {
            *stop = YES;
        }
        
        // 删除同名的成员
        success = [db deleteObjectsFromTable:@"temp_transfer_cycle"
                                       where:SSJTransferCycleTable.cycleId == oldId];
        
        if (!success) {
            *stop = YES;
        }
        
    }];
    
    return success;
}


@end
