//
//  SSJUserReminderTableMerge.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserReminderTableMerge.h"

@implementation SSJUserReminderTableMerge

+ (NSString *)mergeTableName {
    return @"BK_USER_REMIND";
}

+ (NSString *)tempTableName {
    return @"temp_user_remind";
}

+ (NSDictionary *)queryDatasWithSourceUserId:(NSString *)sourceUserid
                                TargetUserId:(NSString *)targetUserId
                                   mergeType:(SSJMergeDataType)mergeType
                                    FromDate:(NSDate *)fromDate
                                      ToDate:(NSDate *)toDate
                                  inDataBase:(WCTDatabase *)db {
    
    // 提醒分成两部分,一部分是信用卡的提醒,一部分是借贷的提醒
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    
    
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    
    WCTPropertyList multiProperties;

    for (const WCTProperty& property : SSJUserRemindTable.AllProperties) {
        multiProperties.push_back(property.inTable([self mergeTableName]));
    }
    
    NSString *startDate;
    
    NSString *endDate;
    
    if (mergeType == SSJMergeDataTypeByWriteBillDate) {
        startDate = [fromDate formattedDateWithFormat:@"yyyy-MM-dd HH:ss:mm"];
        
        endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd HH:ss:mm"];
    } else if (mergeType == SSJMergeDataTypeByWriteBillDate) {
        startDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd"];
        endDate = [toDate formattedDateWithFormat:@"yyyy-MM-dd"];
    }
    
    WCTError *error;
    
    // 首先查出所有信用卡的提醒
    WCTMultiSelect *creditRemindSelect;
    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        creditRemindSelect = [[[db prepareSelectMultiObjectsOnResults:multiProperties fromTables:@[ [self mergeTableName], @"bk_user_charge", @"bk_user_credit" ]]
                   where:SSJUserRemindTable.remindId.inTable([self mergeTableName]) == SSJUserCreditTable.remindId.inTable(@"bk_user_credit")
                   && SSJUserChargeTable.writeDate.inTable(@"bk_user_charge").between(startDate, endDate)
                               && SSJUserCreditTable.cardId.inTable(@"bk_user_credit") == SSJUserChargeTable.fundId.inTable(@"bk_user_charge")
                               && SSJUserRemindTable.userId.inTable([self mergeTableName]) == sourceUserid
                               && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2]
                  groupBy:{SSJUserChargeTable.booksId.inTable(@"bk_user_charge")}];
        
    } else if (mergeType == SSJMergeDataTypeByWriteBillDate) {
        creditRemindSelect = [[[db prepareSelectMultiObjectsOnResults:multiProperties fromTables:@[ [self mergeTableName], @"bk_user_charge", @"bk_user_credit" ]]
                               where:SSJUserRemindTable.remindId.inTable([self mergeTableName]) == SSJUserCreditTable.remindId.inTable(@"bk_user_credit")
                               && SSJUserChargeTable.billDate.inTable(@"bk_user_charge").between(startDate, endDate)
                               && SSJUserCreditTable.cardId.inTable(@"bk_user_credit") == SSJUserChargeTable.fundId.inTable(@"bk_user_charge")
                               && SSJUserRemindTable.userId.inTable([self mergeTableName]) == sourceUserid
                               && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2]
                              groupBy:{SSJUserChargeTable.booksId.inTable(@"bk_user_charge")}];
    }
    
    error = creditRemindSelect.error;
    
    WCTMultiObject *creditRemindMultiObject;
    
    while ((creditRemindMultiObject = [creditRemindSelect nextMultiObject])) {
        SSJUserRemindTable *reminds = (SSJUserRemindTable *)[creditRemindMultiObject objectForKey:[self mergeTableName]];
        [tempArr addObject:reminds];
    }
    
    // 然后查出借贷的提醒
    WCTMultiSelect *loanRemindSelect;
    
    if (mergeType == SSJMergeDataTypeByWriteDate) {
        loanRemindSelect = [[[db prepareSelectMultiObjectsOnResults:multiProperties
                                                           fromTables:@[ [self mergeTableName], @"bk_user_charge", @"bk_user_credit" ]]
                               where:SSJUserRemindTable.remindId.inTable([self mergeTableName]) == SSJUserCreditTable.remindId.inTable(@"bk_user_credit")
                               && SSJUserChargeTable.writeDate.inTable(@"bk_user_charge").between(startDate, endDate)
                             && SSJUserCreditTable.cardId.inTable(@"bk_user_credit") == SSJUserChargeTable.fundId.inTable(@"bk_user_charge")
                             && SSJUserRemindTable.userId.inTable([self mergeTableName]) == sourceUserid
                             && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2]
                              groupBy:{SSJUserRemindTable.remindId.inTable([self mergeTableName])}];
        
    } else if (mergeType == SSJMergeDataTypeByWriteBillDate) {
        loanRemindSelect = [[[db prepareSelectMultiObjectsOnResults:multiProperties
                                                           fromTables:@[ [self mergeTableName], @"bk_user_charge", @"bk_loan" ]]
                               where:SSJUserRemindTable.remindId.inTable([self mergeTableName]) == SSJLoanTable.remindId.inTable(@"bk_loan")
                               && SSJUserChargeTable.billDate.inTable(@"bk_user_charge").between(startDate, endDate)
                             && SSJUserCreditTable.cardId.inTable(@"bk_loan") == SSJUserChargeTable.fundId.inTable(@"bk_user_charge")
                             && SSJUserRemindTable.userId.inTable([self mergeTableName]) == sourceUserid
                             && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2]
                            groupBy:{SSJUserRemindTable.remindId.inTable([self mergeTableName])}];
    }
    
    error = loanRemindSelect.error;
    
    WCTMultiObject *loanRemindMultiObject;
    
    while ((loanRemindMultiObject = [loanRemindSelect nextMultiObject])) {
        SSJUserRemindTable *remind = (SSJUserRemindTable *)[loanRemindMultiObject objectForKey:[self mergeTableName]];
        [tempArr addObject:remind];
    }
    
    [dict setObject:tempArr forKey:@"results"];
    
    if (error) {
        [dict setObject:error forKey:@"error"];
    }
    
    return dict;
}

+ (NSDictionary *)getSameNameIdsWithSourceUserId:(NSString *)sourceUserid
                                    TargetUserId:(NSString *)targetUserId
                                       withDatas:(NSArray *)datas
                                      inDataBase:(WCTDatabase *)db {
    
    // 建立一个新老id对照的字典,key是老的id,value是新的id
    NSMutableDictionary *newAndOldIdDic = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [datas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SSJUserRemindTable *currentRemind = (SSJUserRemindTable *)obj;
        
        SSJUserRemindTable *sameRemind = [[db getOneObjectOfClass:SSJUserRemindTable.class
                                                        fromTable:[self mergeTableName]]
                                          
                                          where:SSJUserRemindTable.remindName == currentRemind.remindName
                                          && SSJUserRemindTable.userId = targetUserId];
        
        if (sameRemind) {
            [newAndOldIdDic setObject:currentRemind.remindName forKey:sameRemind.remindName];
        }
        
    }];
    
    return newAndOldIdDic;
}

+ (BOOL)updateRelatedTableWithSourceUserId:(NSString *)sourceUserid
                              TargetUserId:(NSString *)targetUserId
                                 withDatas:(NSDictionary *)datas
                                inDataBase:(WCTDatabase *)db {
    
    __block BOOL success = NO;
    
    // 和流水有关的表:信用卡,借贷
    [datas enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *newId = obj;
        NSString *oldId = key;
        if (![db isTableExists:@"temp_user_credit"] || ![db isTableExists:@"temp_loan"]) {
            SSJPRINT(@">>>>>>>>提醒所关联的表不存在<<<<<<<<");
            *stop = YES;
            success = NO;
        }
        
        // 更新信用卡表
        SSJUserCreditTable *credit = [[SSJUserCreditTable alloc] init];
        credit.remindId = newId;
        success = [db updateRowsInTable:@"temp_user_credit"
                           onProperties:SSJUserCreditTable.remindId
                             withObject:credit
                                  where:SSJUserCreditTable.remindId == oldId];
        if (!success) {
            *stop = YES;
        }
        
        // 更新借贷
        SSJLoanTable *loan = [[SSJLoanTable alloc] init];
        loan.remindId = newId;
        success = [db updateRowsInTable:@"temp_loan"
                           onProperties:SSJLoanTable.remindId
                             withObject:loan
                                  where:SSJLoanTable.remindId == oldId];
        
        if (!success) {
            *stop = YES;
        }
        
        // 删除同名的提醒
        success = [db deleteObjectsFromTable:@"temp_user_remind"
                                       where:SSJUserRemindTable.remindId == oldId];
        if (!success) {
            *stop = YES;
        }
        
        // 将所有的提醒的userid更新为目标userid
        SSJUserRemindTable *userRemind = [[SSJUserRemindTable alloc] init];
        userRemind.userId = targetUserId;
        success = [db updateRowsInTable:@"temp_user_remind"
                           onProperties:SSJUserRemindTable.userId
                             withObject:userRemind
                                  where:SSJUserRemindTable.userId == sourceUserid];
        
        if (!success) {
            *stop = YES;
        }
    }];
    
    return success;
}


@end
