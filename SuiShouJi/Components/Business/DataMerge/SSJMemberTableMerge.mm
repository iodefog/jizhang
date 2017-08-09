//
//  SSJMemberTableMerge.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJMemberTableMerge.h"

@implementation SSJMemberTableMerge

+ (NSString *)mergeTableName {
    return @"BK_MEMBER";
}

+ (NSString *)tempTableName {
    return @"temp_member";
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
    for (const WCTProperty& property : SSJMemberTable.AllProperties) {
        multiProperties.push_back(property.inTable([self mergeTableName]));
    }
    for (const WCTProperty& property : SSJMembereChargeTable.AllProperties) {
        multiProperties.push_back(property.inTable(@"bk_member_charge"));
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
        select = [[[db prepareSelectMultiObjectsOnResults:multiProperties
                                               fromTables:@[ [self mergeTableName], @"bk_user_charge", @"bk_member_charge" ]]
                   where:SSJMembereChargeTable.memberId.inTable(@"bk_member_charge") == SSJMemberTable.memberId.inTable([self mergeTableName])
                   && SSJMembereChargeTable.chargeId.inTable(@"bk_member_charge") == SSJUserChargeTable.chargeId.inTable(@"bk_user_charge")
                   && SSJUserChargeTable.writeDate.inTable(@"bk_user_charge").between(startDate, endDate)
                   && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                   && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2]
                  groupBy:{SSJUserChargeTable.cid.inTable(@"bk_user_charge")}];
        
    } else if (mergeType == SSJMergeDataTypeByBillDate) {
        select = [[[db prepareSelectMultiObjectsOnResults:multiProperties
                                               fromTables:@[ [self mergeTableName], @"bk_user_charge", @"bk_member_charge" ]]
                   where:SSJMembereChargeTable.memberId.inTable(@"bk_member_charge") == SSJMemberTable.memberId.inTable([self mergeTableName])
                   && SSJMembereChargeTable.chargeId.inTable(@"bk_member_charge") == SSJUserChargeTable.chargeId.inTable(@"bk_user_charge")
                   && SSJUserChargeTable.billDate.inTable(@"bk_user_charge").between(startDate, endDate)
                   && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                   && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2]
                  groupBy:{SSJUserChargeTable.cid.inTable(@"bk_user_charge")}];
        
        
    }
    
    WCTError *error = select.error;
    
    if (error) {
        [dict setObject:error forKey:@"error"];
    }
    
    WCTMultiObject *multiObject;
    
    while ((multiObject = [select nextMultiObject])) {
        SSJMemberTable *members = (SSJMemberTable *)[multiObject objectForKey:[self mergeTableName]];
        [tempArr addObject:members];
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
        SSJMemberTable *currentMember = (SSJMemberTable *)obj;
        
        SSJMemberTable *sameNameMember = [db getOneObjectOfClass:SSJMemberTable.class
                                                    fromTable:[self mergeTableName]
                                      where:SSJMemberTable.memberName == currentMember.memberName
                                          && SSJMemberTable.userId == targetUserId
                                          && SSJMemberTable.operatorType != 2];
        
        if (sameNameMember) {
            [newAndOldIdDic setObject:sameNameMember.memberId forKey:currentMember.memberId];
        }
        
    }];
    
    
    return newAndOldIdDic;
}

+ (BOOL)updateRelatedTableWithSourceUserId:(NSString *)sourceUserid
                              TargetUserId:(NSString *)targetUserId
                                 withDatas:(NSDictionary *)datas
                                inDataBase:(WCTDatabase *)db {
    
    BOOL success = NO;
    
    NSArray *allLoans = [db getAllObjectsOfClass:SSJMemberTable.class fromTable:[self tempTableName]];
    
    for (SSJMemberTable *member in allLoans) {
        NSString *oldId = member.memberId;
        NSString *newId = [datas objectForKey:oldId];
        
        if (!newId) {
            newId = SSJUUID();
        }
        
        if (![db isTableExists:@"temp_charge_period_config"] && ![db isTableExists:@"temp_member_charge"]) {
            SSJPRINT(@">>>>>>>>成员所关联的表不存在<<<<<<<<");
            success = NO;
            break;
        }
        
        // 更新成员流水表
        SSJMembereChargeTable *memberCharge = [[SSJMembereChargeTable alloc] init];
        memberCharge.memberId = newId;
        success = [db updateRowsInTable:@"temp_member_charge"
                           onProperties:SSJMembereChargeTable.memberId
                             withObject:memberCharge
                                  where:SSJMembereChargeTable.memberId == oldId];
        if (!success) {
            break;
        }
        
        // 更新周期记账表
        WCTSelect *chargePeriodSelect = [db prepareSelectObjectsOfClass:SSJChargePeriodConfigTable.class
                                                              fromTable:@"temp_charge_period_config"];
        
        if (chargePeriodSelect.error) {
            success = NO;
            break;

        }
        
        // 首先查出所有用到这个成员的周期记账
        NSArray <SSJChargePeriodConfigTable *> *periodCharges = [chargePeriodSelect
                                                                 where:SSJChargePeriodConfigTable.memberIds.like([NSString stringWithFormat:@"%%%@%%",oldId])                                                                 && SSJChargePeriodConfigTable.operatorType != 2].allObjects;
        
        // 然后将周期记账中的成员id改成新的id
        for (SSJChargePeriodConfigTable *periodCharge in periodCharges) {
            NSString *newMembers = [periodCharge.memberIds stringByReplacingOccurrencesOfString:oldId withString:newId];
            periodCharge.memberIds = newMembers;
            success = [db updateRowsInTable:@"temp_charge_period_config"
                               onProperties:SSJChargePeriodConfigTable.memberIds
                                 withObject:periodCharge
                                      where:SSJChargePeriodConfigTable.configId == periodCharge.configId];
        }
        
        // 如果有同名的则删除当前成员,如果没有则吧成员id更新为新的id
        if ([datas objectForKey:oldId]) {
            success = [db deleteObjectsFromTable:@"temp_member"
                                           where:SSJMemberTable.memberId == oldId];
        } else {
            success = [db updateRowsInTable:@"temp_member" onProperty:SSJMemberTable.memberId withValue:newId
                                      where:SSJMemberTable.memberId == oldId];
        }
                
        
        if (!success) {
            break;
        }

        
    }
    
    // 和成员有关的表:成员流水,周期记账,
    [datas enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *oldId = obj;
        NSString *newId = key;
        
        
    }];
    
    // 将所有的成员的userid更新为目标userid
    SSJMemberTable *userMember = [[SSJMemberTable alloc] init];
    userMember.userId = targetUserId;
    success = [db updateRowsInTable:@"temp_member"
                       onProperties:SSJMemberTable.userId
                         withObject:userMember
                              where:SSJMemberTable.userId == sourceUserid];
    
    return success;
}


@end
