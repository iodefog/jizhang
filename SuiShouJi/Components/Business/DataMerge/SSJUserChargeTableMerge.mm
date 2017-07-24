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
    
    if (mergeType == SSJMergeDataTypeByWriteBillDate) {
        startDate = [fromDate formattedDateWithFormat:@"yyyy-MM-dd HH:ss:mm"];
        
        endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd HH:ss:mm"];
    } else if (mergeType == SSJMergeDataTypeByWriteBillDate) {
        startDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd"];
        endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd"];
    }
    
    WCTSelect *select = [db prepareSelectObjectsOfClass:SSJUserChargeTable.class
                                                   fromTable:[self mergeTableName]];
    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        tempArr = [select where:SSJUserChargeTable.userId == sourceUserid
                   && SSJUserChargeTable.operatorType != 2
                   && SSJUserChargeTable.writeDate.between(startDate, endDate)].allObjects;
    } else if (mergeType == SSJMergeDataTypeByWriteBillDate) {
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

        SSJUserChargeTable *sameCharge = [[db getOneObjectOfClass:SSJUserChargeTable.class
                                                         fromTable:[self mergeTableName]]
                                            
                                           where:SSJUserChargeTable.fundId == currentCharge.fundId
                                            && SSJUserChargeTable.billDate == currentCharge.billDate
                                            && SSJUserChargeTable.booksId == currentCharge.booksId
                                          && SSJUserChargeTable.chargeType == currentCharge.chargeType
                                          && SSJUserChargeTable.userId == targetUserId];

        if (sameCharge) {
            [newAndOldIdDic setObject:currentCharge.chargeId forKey:sameCharge.chargeId];
        }
        
    }];
    
    return newAndOldIdDic;
}

+ (BOOL)updateRelatedTableWithSourceUserId:(NSString *)sourceUserid
                              TargetUserId:(NSString *)targetUserId
                                 withDatas:(NSDictionary *)datas
                                inDataBase:(WCTDatabase *)db {
    
    __block BOOL success = NO;
    
    // 和流水有关的表:成员流水,图片同步表
    [datas enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *newId = obj;
        NSString *oldId = key;
        if (![db isTableExists:@"temp_member_charge"] || ![db isTableExists:@"temp_user_charge"] || ![db isTableExists:@"temp_img_sync"]) {
            SSJPRINT(@">>>>>>>>流水所关联的表不存在<<<<<<<<");
            *stop = NO;
            success = NO;
        }
        
        // 更新成员流水
        SSJMembereChargeTable *memberCharge = [[SSJMembereChargeTable alloc] init];
        memberCharge.memberId = newId;
        success = [db updateRowsInTable:@"temp_member_charge"
                           onProperties:SSJMembereChargeTable.memberId
                             withObject:memberCharge
                                  where:SSJMembereChargeTable.memberId == oldId];
        if (!success) {
            *stop = YES;
        }
        
        // 更新图片同步表
        SSJImageSyncTable *syncImage = [[SSJImageSyncTable alloc] init];
        syncImage.imageSourceId = newId;
        success = [db updateRowsInTable:@"temp_member_charge"
                           onProperties:SSJImageSyncTable.imageSourceId
                             withObject:memberCharge
                                  where:SSJImageSyncTable.imageSourceId == oldId];
        if (!success) {
            *stop = YES;
        }

        // 删除同一条流水
        success = [db deleteObjectsFromTable:@"temp_user_charge"
                                       where:SSJUserChargeTable.chargeId == oldId];
        if (!success) {
            *stop = YES;
        }
        
        // 将所有的流水的userid更新为目标userid
        SSJUserChargeTable *userCharge = [[SSJUserChargeTable alloc] init];
        userCharge.userId = targetUserId;
        success = [db updateRowsInTable:@"temp_user_charge"
                           onProperties:SSJUserChargeTable.userId
                             withObject:userCharge
                                  where:SSJUserChargeTable.userId == sourceUserid];
        
        if (!success) {
            *stop = YES;
        }
    }];
    
    return success;
}


@end
