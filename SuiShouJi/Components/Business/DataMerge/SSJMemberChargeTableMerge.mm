//
//  SSJMemberChargeTableMerge.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJMemberChargeTableMerge.h"

@implementation SSJMemberChargeTableMerge

+ (NSString *)tableName {
    return @"BK_MEMBER_CHARGE";
}

+ (NSString *)tempTableName {
    return @"temp_member_charge";
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
    for (const WCTProperty& property : SSJMembereChargeTable.AllProperties) {
        multiProperties.push_back(property.inTable([self tableName]));
    }

    
    NSString *startDate = [fromDate formattedDateWithFormat:@"yyyy-MM-dd HH:ss:mm"];
    
    NSString *endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd HH:ss:mm"];
    
    WCTMultiSelect *select;
    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        select = [[[db prepareSelectMultiObjectsOnResults:multiProperties
                                               fromTables:@[ [self tableName], @"bk_user_charge", @"bk_member_charge" ]]
                   where:SSJMembereChargeTable.chargeId.inTable([self tableName]) == SSJUserChargeTable.chargeId.inTable([self tableName])
                   && SSJMembereChargeTable.chargeId.inTable(@"bk_member_charge") == SSJUserChargeTable.chargeId.inTable(@"bk_user_charge")
                   && SSJUserChargeTable.writeDate.inTable(@"bk_user_charge").between(startDate, endDate)
                   && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                   && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2]
                  groupBy:{SSJUserChargeTable.cid.inTable(@"bk_user_charge")}];
        
    } else if (mergeType == SSJMergeDataTypeByWriteBillDate) {
        select = [[[db prepareSelectMultiObjectsOnResults:multiProperties
                                               fromTables:@[ [self tableName], @"bk_user_charge", @"bk_member_charge" ]]
                   where:SSJMembereChargeTable.chargeId.inTable([self tableName]) == SSJUserChargeTable.chargeId.inTable([self tableName])
                   && SSJMembereChargeTable.chargeId.inTable(@"bk_member_charge") == SSJUserChargeTable.chargeId.inTable(@"bk_user_charge")
                   && SSJUserChargeTable.billDate.inTable(@"bk_user_charge").between(startDate, endDate)
                   && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                   && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2]
                  groupBy:{SSJUserChargeTable.cid.inTable(@"bk_user_charge")}];
    }
    
    WCTError *error = select.error;
    
    [dict setObject:error forKey:@"error"];
    
    WCTMultiObject *multiObject;
    
    while ((multiObject = [select nextMultiObject])) {
        SSJMembereChargeTable *memberCharges = (SSJMembereChargeTable *)[multiObject objectForKey:[self tableName]];
        [tempArr addObject:memberCharges];
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
        // 成员流水表由于是最后合并的,只要把同样的成员流水,或者被合并账户中已经存在的删掉即可
        
        SSJMembereChargeTable *currentMemberCharge = (SSJMembereChargeTable *)obj;
        
        SSJMembereChargeTable *sameNameMemberCharge = [[db getOneObjectOfClass:SSJMembereChargeTable.class
                                                        fromTable:[self tableName]]
                                          where:SSJMembereChargeTable.chargeId == currentMemberCharge.chargeId
                                                       && SSJMembereChargeTable.memberId == currentMemberCharge.memberId];
        
        NSString *currentMemberChargeUnionId = [NSString stringWithFormat:@"%@,%@",currentMemberCharge.memberId,currentMemberCharge.chargeId];
        
        if (sameNameMemberCharge) {
            [newAndOldIdDic setObject:currentMemberChargeUnionId forKey:@""];
        }
        
        NSNumber *userChargeCount = [[db getOneValueOnResult:SSJUserChargeTable.AnyProperty.count() fromTable:@"bk_user_charge"] where:SSJUserChargeTable.chargeId == currentMemberCharge.chargeId
                                          && SSJUserChargeTable.userId == targetUserId];
        
        if (userChargeCount > 0 ) {
            [newAndOldIdDic setObject:currentMemberChargeUnionId forKey:@""];
        }
        
    }];
    
    
    return newAndOldIdDic;
}

+ (BOOL)updateRelatedTableWithSourceUserId:(NSString *)sourceUserid
                              TargetUserId:(NSString *)targetUserId
                                 withDatas:(NSDictionary *)datas
                                inDataBase:(WCTDatabase *)db {
    
    __block BOOL success = NO;
    
    // 和成员有关的表:成员流水,周期记账,
    [datas enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *newId = obj;
        NSString *oldId = key;
        
        NSString *oldMemberId = [[obj componentsSeparatedByString:@","] firstObject];
        NSString *oldChargeId = [[obj componentsSeparatedByString:@","] lastObject];
        
        
        // 删除同名的成员
        success = [db deleteObjectsFromTable:@"temp_member_charge"
                                       where:SSJMembereChargeTable.memberId == oldMemberId
                                             && SSJMembereChargeTable.chargeId == oldChargeId];
        
        if (!success) {
            *stop = YES;
        }
        
    }];
    
    return success;
}


@end
