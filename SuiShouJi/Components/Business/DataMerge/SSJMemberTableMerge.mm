//
//  SSJMemberTableMerge.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJMemberTableMerge.h"

@implementation SSJMemberTableMerge

+ (NSString *)tableName {
    return @"BK_MEMBER";
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
        multiProperties.push_back(property.inTable([self tableName]));
    }
    for (const WCTProperty& property : SSJMembereChargeTable.AllProperties) {
        multiProperties.push_back(property.inTable(@"bk_member_charge"));
    }
    
    NSString *startDate = [fromDate formattedDateWithFormat:@"yyyy-MM-dd HH:ss:mm.SSS"];
    
    NSString *endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd HH:ss:mm.SSS"];
    
    WCTMultiSelect *select;
    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        select = [[[db prepareSelectMultiObjectsOnResults:multiProperties
                                               fromTables:@[ [self tableName], @"bk_user_charge" ]]
                   where:SSJMembereChargeTable.memberId.inTable(@"bk_member_charge") == SSJMemberTable.memberId.inTable([self tableName])
                   && SSJMembereChargeTable.chargeId.inTable(@"bk_member_charge") == SSJUserChargeTable.chargeId.inTable(@"bk_user_charge")
                   && SSJUserChargeTable.writeDate.inTable(@"bk_user_charge").between(startDate, endDate)
                   && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                   && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2]
                  groupBy:{SSJUserChargeTable.cid.inTable(@"bk_user_charge")}];
        
    } else if (mergeType == SSJMergeDataTypeByWriteBillDate) {
        select = [[[db prepareSelectMultiObjectsOnResults:multiProperties
                                               fromTables:@[ [self tableName], @"bk_user_charge" ]]
                   where:SSJMembereChargeTable.memberId.inTable(@"bk_member_charge") == SSJMemberTable.memberId.inTable([self tableName])
                   && SSJMembereChargeTable.chargeId.inTable(@"bk_member_charge") == SSJUserChargeTable.chargeId.inTable(@"bk_user_charge")
                   && SSJUserChargeTable.writeDate.inTable(@"bk_user_charge").between(startDate, endDate)
                   && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                   && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2]
                  groupBy:{SSJUserChargeTable.cid.inTable(@"bk_user_charge")}];
    }
    
    WCTError *error = select.error;
    
    [dict setObject:error forKey:@"error"];
    
    WCTMultiObject *multiObject;
    
    while ((multiObject = [select nextMultiObject])) {
        SSJMemberTable *members = (SSJMemberTable *)[multiObject objectForKey:[self tableName]];
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
        
        SSJMemberTable *sameNameMember = [[db getOneObjectOfClass:SSJLoanTable.class
                                                    fromTable:[self tableName]]
                                      where:SSJMemberTable.memberName == currentMember.memberName
                                          && SSJMemberTable.userId == targetUserId];
        
        [newAndOldIdDic setObject:currentMember.memberId forKey:sameNameMember.memberId];
        
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
        if (![db isTableExists:@"temp_user_charge"]) {
            SSJPRINT(@">>>>>>>>借贷所关联的表不存在<<<<<<<<");
            *stop = YES;
            success = NO;
        }
        
        // 更新流水表
        SSJUserChargeTable *userCharge = [[SSJUserChargeTable alloc] init];
        userCharge.cid = newId;
        success = [db updateRowsInTable:@"temp_user_charge"
                           onProperties:SSJUserChargeTable.cid
                             withObject:userCharge
                                  where:SSJUserChargeTable.cid == oldId];
        if (!success) {
            *stop = YES;
        }
        
        
        
        // 删除同名的资金账户
        success = [db deleteObjectsFromTable:@"temp_loan"
                                       where:SSJLoanTable.loanId == oldId];
        
        if (!success) {
            *stop = YES;
        }
    }];
    
    return success;
}


@end
