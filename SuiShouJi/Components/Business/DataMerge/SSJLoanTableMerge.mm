//
//  SSJLoanTableMerge.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJLoanTableMerge.h"

@implementation SSJLoanTableMerge

+ (NSString *)mergeTableName {
    return @"BK_LOAN";
}

+ (NSString *)tempTableName {
    return @"temp_loan";
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
    for (const WCTProperty& property : SSJLoanTable.AllProperties) {
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
        select = [[db prepareSelectMultiObjectsOnResults:multiProperties fromTables:@[ [self mergeTableName] ]]
                  where:SSJLoanTable.loanId.inTable([self mergeTableName]).in([db getOneDistinctColumnOnResult:SSJUserChargeTable.cid fromTable:@"bk_user_charge"
                                                                                                         where:SSJUserChargeTable.writeDate.inTable(@"bk_user_charge").between(startDate, endDate)
                                                                          && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                                                                          && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2])];
        
    } else if (mergeType == SSJMergeDataTypeByBillDate) {
        select = [[db prepareSelectMultiObjectsOnResults:multiProperties  fromTables:@[ [self mergeTableName] ]]
                  where:SSJLoanTable.loanId.inTable([self mergeTableName]).in([db getOneDistinctColumnOnResult:SSJUserChargeTable.cid fromTable:@"bk_user_charge"
                                                                                                    where:SSJUserChargeTable.billDate.inTable(@"bk_user_charge").between(startDate, endDate)
                                                                          && SSJUserChargeTable.userId.inTable(@"bk_user_charge") == sourceUserid
                                                                          && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2])];
    }
    
    WCTError *error = select.error;
    
    if (error) {
        [dict setObject:error forKey:@"error"];
    }
    
    WCTMultiObject *multiObject;
    
    while ((multiObject = [select nextMultiObject])) {
        SSJLoanTable *loans = (SSJLoanTable *)[multiObject objectForKey:[self mergeTableName]];
        [tempArr addObject:loans];
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
        SSJLoanTable *currentLoan = (SSJLoanTable *)obj;
        
        SSJLoanTable *sameNameLoan = [db getOneObjectOfClass:SSJLoanTable.class
                                                        fromTable:[self mergeTableName]
                                          where:SSJLoanTable.lender == currentLoan.lender
                                      && SSJLoanTable.money == currentLoan.money
                                      && SSJLoanTable.borrowDate == currentLoan.borrowDate
                                      && SSJLoanTable.userId == targetUserId
                                      && SSJLoanTable.operatorType != 2];
        
        if (sameNameLoan) {
            [newAndOldIdDic setObject:sameNameLoan.loanId forKey:currentLoan.loanId];
        }
        
    }];
    
    
    return newAndOldIdDic;
}

+ (BOOL)updateRelatedTableWithSourceUserId:(NSString *)sourceUserid
                              TargetUserId:(NSString *)targetUserId
                                 withDatas:(NSDictionary *)datas
                                inDataBase:(WCTDatabase *)db {
    
    BOOL success = NO;
    
    NSArray *allLoans = [db getAllObjectsOfClass:SSJLoanTable.class fromTable:[self tempTableName]];
    
    for (SSJLoanTable *loan in allLoans) {
        NSString *oldId = loan.loanId;
        NSString *newId = [datas objectForKey:oldId];
        
        if (!newId) {
            newId = SSJUUID();
        }
        
        if (![db isTableExists:@"temp_user_charge"]) {
            SSJPRINT(@">>>>>>>>借贷所关联的表不存在<<<<<<<<");
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
        
        // 如果有同名的则删除当前借贷,如果没有则吧借贷id更新为新的id
        if ([datas objectForKey:oldId]) {
            success = [db deleteObjectsFromTable:@"temp_loan"
                                           where:SSJLoanTable.loanId == oldId];
        } else {
            success = [db updateRowsInTable:@"temp_loan" onProperty:SSJLoanTable.loanId withValue:newId
                                      where:SSJLoanTable.loanId == oldId];
        }
        
    };
    
    // 将所有的借贷的userid更新为目标userid
    SSJLoanTable *userLoan = [[SSJLoanTable alloc] init];
    userLoan.userId = targetUserId;
    success = [db updateRowsInTable:@"temp_loan"
                       onProperties:SSJLoanTable.userId
                         withObject:userLoan
                              where:SSJLoanTable.userId == sourceUserid];
    
    
    
    return success;
    
    
}


@end
