//
//  SSJTrasferCycleTableMerge.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJTrasferCycleTableMerge.h"

@implementation SSJTrasferCycleTableMerge

+ (NSString *)mergeTableName {
    return @"BK_TRANSFER_CYCLE";
}

+ (NSString *)tempTableName {
    return @"temp_transfer_cycle";
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
        startDate = [fromDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    } else if (mergeType == SSJMergeDataTypeByBillDate) {
        startDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd"];
        endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd"];
    }
    
    WCTMultiSelect *select;
    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        select = [[db prepareSelectMultiObjectsOnResults:multiProperties
                                              fromTables:@[ [self mergeTableName] ]]
                  where:SSJTransferCycleTable.writeDate.between(startDate, endDate)
                  && SSJTransferCycleTable.beginDate <= [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"]
                  && SSJTransferCycleTable.userId == sourceUserid
                  && SSJTransferCycleTable.operatorType != 2];
        
    } else if (mergeType == SSJMergeDataTypeByBillDate) {
        select = [[db prepareSelectMultiObjectsOnResults:multiProperties
                                              fromTables:@[ [self mergeTableName] ]]
                  where:SSJTransferCycleTable.beginDate.between(startDate, endDate)
                  && SSJTransferCycleTable.userId == sourceUserid
                  && SSJTransferCycleTable.operatorType != 2];
    }
    
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
        SSJTransferCycleTable *currentTransfer = (SSJTransferCycleTable *)obj;
        
        SSJTransferCycleTable *sameNameTransfer = [db getOneObjectOfClass:SSJTransferCycleTable.class fromTable:[self mergeTableName]
                                          where:SSJTransferCycleTable.money == currentTransfer.money
                                                   && SSJTransferCycleTable.endDate == currentTransfer.endDate
                                                   && SSJTransferCycleTable.beginDate == currentTransfer.beginDate
                                                   && SSJTransferCycleTable.cycleType == currentTransfer.cycleType
                                                   && SSJTransferCycleTable.userId == targetUserId
                                                   && SSJTransferCycleTable.operatorType != 2];
        
        if (sameNameTransfer) {
            [newAndOldIdDic setObject:sameNameTransfer.cycleId forKey:currentTransfer.cycleId];
        }
        
    }];
    
    
    return newAndOldIdDic;
}

+ (BOOL)updateRelatedTableWithSourceUserId:(NSString *)sourceUserid
                              TargetUserId:(NSString *)targetUserId
                                 withDatas:(NSDictionary *)datas
                                inDataBase:(WCTDatabase *)db {
    
    BOOL success = NO;
    
    NSArray *allLoans = [db getAllObjectsOfClass:SSJTransferCycleTable.class fromTable:[self tempTableName]];
    
    for (SSJTransferCycleTable *transfer in allLoans) {
        NSString *oldId = transfer.cycleId;
        NSString *newId = [datas objectForKey:oldId];
        
        if (!newId) {
            newId = SSJUUID();
        }
    
        if (![db isTableExists:@"temp_user_charge"]) {
            SSJPRINT(@">>>>>>>>周期转账所关联的表不存在<<<<<<<<");
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
        
        // 如果有同名的则删除当前周期转账,如果没有则吧周期转账id更新为新的id
        if ([datas objectForKey:oldId]) {
            success = [db deleteObjectsFromTable:@"temp_transfer_cycle"
                                           where:SSJTransferCycleTable.cycleId == oldId];
        } else {
            success = [db updateRowsInTable:@"temp_transfer_cycle" onProperty:SSJTransferCycleTable.cycleId withValue:newId
                                      where:SSJTransferCycleTable.cycleId == oldId];
        }
        
        
        
        
        if (!success) {
            break;
        }

    }
    
    
    // 将所有的周期转账的userid更新为目标userid
    SSJTransferCycleTable *userCycleTransfer = [[SSJTransferCycleTable alloc] init];
    userCycleTransfer.userId = targetUserId;
    success = [db updateRowsInTable:@"temp_transfer_cycle"
                       onProperties:SSJTransferCycleTable.userId
                         withObject:userCycleTransfer
                              where:SSJTransferCycleTable.userId == sourceUserid];
    
    
    return success;
}


@end
