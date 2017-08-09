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
    
    for (const WCTProperty& property : SSJUserBillTypeTable.AllProperties) {
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
    
    NSArray *booksIds;
    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        booksIds = [db getOneDistinctColumnOnResult:SSJUserChargeTable.booksId
                                          fromTable:@"bk_user_charge"
                                              where:SSJUserChargeTable.writeDate.inTable(@"bk_user_charge").between(startDate, endDate)
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
        SSJUserBillTypeTable *userbills = (SSJUserBillTypeTable *)[multiObject objectForKey:[self mergeTableName]];
        [tempArr addObject:userbills];
    }
    
    [dict setObject:tempArr forKey:@"results"];
    
    return dict;
}

+ (NSDictionary *)getSameNameIdsWithSourceUserId:(NSString *)sourceUserid
                                    TargetUserId:(NSString *)targetUserId
                                       withDatas:(NSArray *)datas
                                      inDataBase:(WCTDatabase *)db {
    
    return nil;
}

+ (BOOL)updateRelatedTableWithSourceUserId:(NSString *)sourceUserid
                              TargetUserId:(NSString *)targetUserId
                                 withDatas:(NSDictionary *)datas
                                inDataBase:(WCTDatabase *)db {
    
    __block BOOL success = NO;
    
    NSArray *allBills = [db getAllObjectsOfClass:SSJUserBillTypeTable.class fromTable:[self tempTableName]];
    
    for (SSJUserBillTypeTable *userBill in allBills) {
        
        NSString *sameNameId = [db getOneValueOnResult:SSJUserBillTypeTable.billId fromTable:@"BK_USER_BILL_TYPE"
                                                 where:SSJUserBillTypeTable.userId == targetUserId
                                && SSJUserBillTypeTable.billName == userBill.billName
                                && SSJUserBillTypeTable.booksId == userBill.booksId
                                && SSJUserBillTypeTable.operatorType != 2];
        
        NSString *oldId = userBill.billId;
        NSString *newId = sameNameId;
        
        if (!newId) {
            if (oldId.length > 4) {
                newId = SSJUUID();
            } else {
                newId = oldId;
            }
        }

        if (![db isTableExists:@"temp_user_charge"] && ![db isTableExists:@"temp_charge_period_config"]) {
            SSJPRINT(@">>>>>>>>周期转账所关联的表不存在<<<<<<<<");
            success = NO;
            break;
        }
        
        // 更新流水表
        SSJUserChargeTable *userCharge = [[SSJUserChargeTable alloc] init];
        userCharge.billId = newId;
        success = [db updateRowsInTable:@"temp_user_charge"
                           onProperties:SSJUserChargeTable.billId
                             withObject:userCharge
                                  where:SSJUserChargeTable.billId == oldId];
        if (!success) {
            break;
        }
        
        // 更新周期记账
        SSJChargePeriodConfigTable *chargePeriodConfig = [[SSJChargePeriodConfigTable alloc] init];
        chargePeriodConfig.billId = newId;
        success = [db updateRowsInTable:@"temp_charge_period_config"
                           onProperties:SSJChargePeriodConfigTable.billId
                             withObject:chargePeriodConfig
                                  where:SSJChargePeriodConfigTable.billId == oldId];
        if (!success) {
            break;
        }
        
        
        // 如果有同名的则删除当前记账类型,如果没有则吧记账类型id更新为新的id
        if (sameNameId.length) {
            success = [db deleteObjectsFromTable:@"temp_user_bill_type"
                                           where:SSJUserBillTypeTable.billId == oldId];
        } else {
            if (oldId.length > 4) {
                success = [db updateRowsInTable:@"temp_user_bill_type" onProperty:SSJUserBillTypeTable.billId withValue:newId
                                          where:SSJUserBillTypeTable.billId == oldId];
            }
        }
        
        if (!success) {
            break;
        }

    }
    
    
    // 将所有的记账类型的userid更新为目标userid
    SSJUserBillTypeTable *userBillType = [[SSJUserBillTypeTable alloc] init];
    userBillType.userId = targetUserId;
    success = [db updateRowsInTable:@"temp_user_bill_type"
                       onProperties:SSJUserBillTypeTable.userId
                         withObject:userBillType
                              where:SSJUserBillTypeTable.userId == sourceUserid];
    
    
    return success;
}


@end
