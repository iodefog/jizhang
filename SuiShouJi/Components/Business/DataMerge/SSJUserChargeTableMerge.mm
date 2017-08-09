//
//  SSJUserChargeTableMerge.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserChargeTableMerge.h"

@implementation SSJUserChargeTableMerge

+ (NSString *)mergeTableName {
    return @"BK_USER_CHARGE";
}

+ (NSString *)tempTableName {
    return @"temp_user_charge";
}

+ (NSDictionary *)queryDatasWithSourceUserId:(NSString *)sourceUserid
                                TargetUserId:(NSString *)targetUserId
                                   mergeType:(SSJMergeDataType)mergeType
                                    FromDate:(NSDate *)fromDate
                                      ToDate:(NSDate *)toDate
                                  inDataBase:(WCTDatabase *)db {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSArray *tempArr = [NSArray array];
    
    NSString *startDate;
    
    NSString *endDate;
    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        startDate = [fromDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    } else if (mergeType == SSJMergeDataTypeByBillDate) {
        startDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd"];
        endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd"];
    }
    
    WCTSelect *select = [db prepareSelectObjectsOfClass:SSJUserChargeTable.class
                                                   fromTable:[self mergeTableName]];
    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        tempArr = [select where:SSJUserChargeTable.userId == sourceUserid
                   && SSJUserChargeTable.operatorType != 2
                   && SSJUserChargeTable.writeDate.between(startDate, endDate)].allObjects;
    } else if (mergeType == SSJMergeDataTypeByBillDate) {
        tempArr = [select where:SSJUserChargeTable.userId == sourceUserid
                   && SSJUserChargeTable.operatorType != 2
                   && SSJUserChargeTable.billDate.between(startDate, endDate)].allObjects;
    }
    
    WCTError *error = select.error;
    
    if (error) {
        [dict setObject:error forKey:@"error"];
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
        SSJUserChargeTable *currentCharge = (SSJUserChargeTable *)obj;

        SSJUserChargeTable *sameCharge = [db getOneObjectOfClass:SSJUserChargeTable.class
                                                         fromTable:[self mergeTableName]
                                            
                                           where:SSJUserChargeTable.money == currentCharge.money
                                            && SSJUserChargeTable.billDate == currentCharge.billDate
                                          && SSJUserChargeTable.chargeType == currentCharge.chargeType
                                          && SSJUserChargeTable.userId == targetUserId
                                          && SSJUserChargeTable.operatorType != 2];

        if (sameCharge) {
            [newAndOldIdDic setObject:sameCharge.chargeId forKey:currentCharge.chargeId];
        }
        
    }];
    
    return newAndOldIdDic;
}

+ (BOOL)updateRelatedTableWithSourceUserId:(NSString *)sourceUserid
                              TargetUserId:(NSString *)targetUserId
                                 withDatas:(NSDictionary *)datas
                                inDataBase:(WCTDatabase *)db {
    
    BOOL success = NO;
    
    NSArray *allCharges = [db getAllObjectsOfClass:SSJUserChargeTable.class fromTable:[self tempTableName]];

    
    // 和流水有关的表:成员流水,图片同步表
    for (SSJUserChargeTable *charge in allCharges) {
        NSString *oldId = charge.chargeId;
        NSString *newId = [datas objectForKey:charge.chargeId];
        
        if (!newId) {
            newId = SSJUUID();
        }
    
        if (![db isTableExists:@"temp_user_charge"] || ![db isTableExists:@"temp_img_sync"]) {
            SSJPRINT(@">>>>>>>>流水所关联的表不存在<<<<<<<<");
            success = NO;
            break;
        }
        
        // 更新成员流水
        SSJMembereChargeTable *memberCharge = [[SSJMembereChargeTable alloc] init];
        memberCharge.memberId = newId;
        success = [db updateRowsInTable:@"temp_member_charge"
                           onProperties:SSJMembereChargeTable.chargeId
                             withObject:memberCharge
                                  where:SSJMembereChargeTable.chargeId == oldId];
        if (!success) {
            break;
        }
        
        // 更新图片同步表
        SSJImageSyncTable *syncImage = [[SSJImageSyncTable alloc] init];
        syncImage.imageSourceId = newId;
        success = [db updateRowsInTable:@"temp_img_sync"
                           onProperties:SSJImageSyncTable.imageSourceId
                             withObject:memberCharge
                                  where:SSJImageSyncTable.imageSourceId == oldId];
        if (!success) {
            break;
        }
        
        // 如果有同名的则删除当前流水,如果没有则吧流水id更新为新的id
        if ([datas objectForKey:oldId]) {
            success = [db deleteObjectsFromTable:@"temp_user_charge"
                                           where:SSJUserChargeTable.chargeId == oldId];
        } else {
            success = [db updateRowsInTable:@"temp_user_charge" onProperty:SSJUserChargeTable.chargeId withValue:newId
                                      where:SSJUserChargeTable.chargeId == oldId];
        }
        
        if (!success) {
            break;
        }

    }
    
    // 将所有的流水的userid更新为目标userid
    SSJUserChargeTable *userCharge = [[SSJUserChargeTable alloc] init];
    userCharge.userId = targetUserId;
    success = [db updateRowsInTable:@"temp_user_charge"
                       onProperties:SSJUserChargeTable.userId
                         withObject:userCharge
                              where:SSJUserChargeTable.userId == sourceUserid];
    
    
    return success;
}


@end
