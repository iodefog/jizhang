//
//  SSJAccountTableMerge.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/12.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBooksTypeTableMerge.h"


@implementation SSJBooksTypeTableMerge

+ (NSString *)mergeTableName {
    return @"BK_BOOKS_TYPE";
}

+ (NSString *)tempTableName {
    return @"temp_books_type";
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
    for (const WCTProperty& property : SSJBooksTypeTable.AllProperties) {
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

    NSArray *allBooks = [db getOneDistinctColumnOnResult:SSJUserChargeTable.booksId
                                               fromTable:@"bk_user_charge"
                                                   where:SSJUserChargeTable.writeDate.inTable(@"bk_user_charge").between(startDate, endDate)
                         && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                         && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2];

    if (mergeType == SSJMergeDataTypeByWriteDate) {
        select = [[db prepareSelectMultiObjectsOnResults:multiProperties fromTables:@[ [self mergeTableName] ]]
                  where:SSJBooksTypeTable.booksId.inTable([self mergeTableName]).in(allBooks)];

    } else if (mergeType == SSJMergeDataTypeByBillDate) {
        select = [[db prepareSelectMultiObjectsOnResults:multiProperties fromTables:@[ [self mergeTableName] ]]
                  where:SSJBooksTypeTable.booksId.inTable([self mergeTableName]).in(allBooks)];
    }
    
    WCTError *error = select.error;
    
    if (error) {
        [dict setObject:error forKey:@"error"];
    }
    
    WCTMultiObject *multiObject;

    while ((multiObject = [select nextMultiObject])) {
        SSJBooksTypeTable *userBooks = (SSJBooksTypeTable *)[multiObject objectForKey:[self mergeTableName]];
        [tempArr addObject:userBooks];
    }
    
    [dict setObject:tempArr forKey:@"results"];
    
    return dict;
}

+ (NSDictionary *)getSameNameIdsWithSourceUserId:(NSString *)sourceUserid
                                         TargetUserId:(NSString *)targetUserId
                                            withDatas:(NSArray *)datas
                                           inDataBase:(WCTDatabase *)db {
    
    // 建立一个新老id对照的字典,value是老的id,key是新的id
    NSMutableDictionary *newAndOldIdDic = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [datas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SSJBooksTypeTable *currentBooks = (SSJBooksTypeTable *)obj;
        
        SSJBooksTypeTable *sameNameBook = [db getOneObjectOfClass:SSJBooksTypeTable.class
                                                          fromTable:[self mergeTableName]
                                                            where:SSJBooksTypeTable.booksName == currentBooks.booksName
                                           && SSJBooksTypeTable.userId == targetUserId
                                           && SSJBooksTypeTable.operatorType != 2];

        if (sameNameBook) {
            [newAndOldIdDic setObject:sameNameBook.booksId forKey:currentBooks.booksId];
        }
        
    }];
    
    
    return newAndOldIdDic;
}

+ (BOOL)updateRelatedTableWithSourceUserId:(NSString *)sourceUserid
                                    TargetUserId:(NSString *)targetUserId
                                       withDatas:(NSDictionary *)datas
                                      inDataBase:(WCTDatabase *)db {
    
    BOOL success = NO;
    
    NSArray *allBooks = [db getAllObjectsOfClass:SSJBooksTypeTable.class fromTable:[self tempTableName]];
    
    // 和账本有关的表:流水,周期记账,记账类型
    for (SSJBooksTypeTable *book in allBooks) {
        NSString *oldId = book.booksId;
        NSString *newId = [datas objectForKey:book.booksId];
        
        if (!newId) {
            newId = SSJUUID();
        }
        
        if (![db isTableExists:@"temp_user_charge"] || ![db isTableExists:@"temp_charge_period_config"] || ![db isTableExists:@"temp_user_bill_type"]) {
            SSJPRINT(@">>>>>>>>账本所关联的表不存在<<<<<<<<");
            success = NO;
            break;
        }
        
        // 更新流水表
        SSJUserChargeTable *userCharge = [[SSJUserChargeTable alloc] init];
        userCharge.booksId = newId;
        success = [db updateRowsInTable:@"temp_user_charge"
                           onProperties:SSJUserChargeTable.booksId
                             withObject:userCharge
                                  where:SSJUserChargeTable.booksId == oldId];
        if (!success) {
            break;
        }
        
        
        // 更新记账类型表
        SSJUserBillTypeTable *userBill = [[SSJUserBillTypeTable alloc] init];
        userBill.booksId = newId;
        success = [db updateRowsInTable:@"temp_user_bill_type"
                           onProperties:SSJUserBillTypeTable.booksId
                             withObject:userBill
                                  where:SSJUserBillTypeTable.booksId == oldId];
        
        if (!success) {
            break;
        }
        
        
        // 更新周期记账表
        SSJChargePeriodConfigTable *periodConfig = [[SSJChargePeriodConfigTable alloc] init];
        periodConfig.booksId = newId;
        success = [db updateRowsInTable:@"temp_charge_period_config"
                           onProperties:SSJChargePeriodConfigTable.booksId
                             withObject:periodConfig
                                  where:SSJChargePeriodConfigTable.booksId == oldId];
        if (!success) {
            break;
        }
        
        
        // 删除账本中同名的账本
        if ([datas objectForKey:book.booksId]) {
            success = [db deleteObjectsFromTable:@"temp_books_type"
                                           where:SSJBooksTypeTable.booksId == oldId];
        } else {
            success = [db updateRowsInTable:@"temp_books_type" onProperty:SSJBooksTypeTable.booksId withValue:newId
                                      where:SSJBooksTypeTable.booksId == oldId];
        }
        
        if (!success) {
            break;
        }
    };
    
    // 将所有的账本的userid更新为目标userid
    SSJBooksTypeTable *booksType = [[SSJBooksTypeTable alloc] init];
    booksType.userId = targetUserId;
    success = [db updateRowsInTable:@"temp_books_type"
                       onProperties:SSJBooksTypeTable.userId
                         withObject:booksType
                              where:SSJBooksTypeTable.userId == sourceUserid];
    
    return success;
    
}

@end
