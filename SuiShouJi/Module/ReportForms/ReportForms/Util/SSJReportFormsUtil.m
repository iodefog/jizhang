//
//  SSJReportFormsUtil.m
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJReportFormsUtil.h"
#import "FMDB.h"

@implementation SSJReportFormsUtil

+ (NSArray *)queryForIncomeOrPayType:(SSJReportFormsIncomeOrPayType)type inYear:(NSString *)year {
    switch (type) {
        case SSJReportFormsIncomeOrPayTypeIncome:
        case SSJReportFormsIncomeOrPayTypePay:
            return [self queryForIncomeOrPay:type billDate:[NSString stringWithFormat:@"%@-__-__",year]];
            
        case SSJReportFormsIncomeOrPayTypeSurplus:
            return [self queryForSurplusWithBillDate:[NSString stringWithFormat:@"%@-__-__",year]];
        case SSJReportFormsIncomeOrPayTypeUnknown:
            return nil;
    }
}

+ (NSArray *)queryForIncomeOrPayType:(SSJReportFormsIncomeOrPayType)type inMonth:(NSString *)month {
    switch (type) {
        case SSJReportFormsIncomeOrPayTypeIncome:
        case SSJReportFormsIncomeOrPayTypePay:
            return [self queryForIncomeOrPay:type billDate:[NSString stringWithFormat:@"____-%@-__",month]];
            
        case SSJReportFormsIncomeOrPayTypeSurplus:
            return [self queryForSurplusWithBillDate:[NSString stringWithFormat:@"____-%@-__",month]];
        case SSJReportFormsIncomeOrPayTypeUnknown:
            return nil;
    }
}

+ (NSArray *)queryForIncomeOrPay:(SSJReportFormsIncomeOrPayType)type billDate:(NSString *)billDate {
    
    NSString *incomeOrPayType = nil;
    switch (type) {
        case SSJReportFormsIncomeOrPayTypeIncome:
            incomeOrPayType = @"0";
            break;
            
        case SSJReportFormsIncomeOrPayTypePay:
            incomeOrPayType = @"1";
            break;
            
        case SSJReportFormsIncomeOrPayTypeSurplus:
        case SSJReportFormsIncomeOrPayTypeUnknown:
            return nil;
    }
    
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        return nil;
    }
    
    FMResultSet *amountResultSet = [db executeQuery:@"SELECT SUM(IMONEY) FROM (SELECT A.IMONEY FROM BK_USER_CHARGE AS A, BK_BILL_TYPE AS B WHERE A.IBILLID = B.ID AND A.CBILLDATE LIKE ? AND B.ITYPE = ?)",billDate,incomeOrPayType];
    
    if (!amountResultSet) {
        [db close];
        return nil;
    }
    
    double amount = 0;
    while ([amountResultSet next]) {
        amount = [amountResultSet doubleForColumnIndex:0];
    }
    
    if (amount == 0) {
        [db close];
        return nil;
    }
    
    FMResultSet *resultSet = [db executeQuery:@"SELECT A.AMOUNT, B.CNAME, B.CCOIN, B.CCOLOR FROM (SELECT SUM(IMONEY) AS AMOUNT, IBILLID FROM BK_USER_CHARGE WHERE CBILLDATE LIKE ? GROUP BY IBILLID) AS A, BK_BILL_TYPE AS B WHERE A.IBILLID = B.ID AND B.ITYPE = ?",billDate,incomeOrPayType];
    
    if (!resultSet) {
        [db close];
        return nil;
    }
    
    NSMutableArray *result = [@[] mutableCopy];
    while ([resultSet next]) {
        SSJReportFormsItem *item = [[SSJReportFormsItem alloc] init];
        item.money = [resultSet doubleForColumn:@"AMOUNT"];
        item.scale = item.money / amount;
        item.colorValue = [resultSet stringForColumn:@"CCOLOR"];
        item.imageName = [resultSet stringForColumn:@"CCOIN"];
        item.incomeOrPayName = [resultSet stringForColumn:@"CNAME"];
        [result addObject:item];
    }
    return result;
}

+ (NSArray *)queryForSurplusWithBillDate:(NSString *)billDate {
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        return nil;
    }
    
    FMResultSet *resultSet = [db executeQuery:@"SELECT SUM(IMONEY) FROM (SELECT A.IMONEY, B.ITYPE, FROM BK_USER_CHARGE AS A, BK_BILL_TYPE AS B WHERE A.IBILLID = B.ID AND A.CBILLDATE LIKE ?) GROUP BY ITYPE ORDER BY ITYPE DESC",billDate];
    
    if (!resultSet) {
        [db close];
        return nil;
    }
    
    double amount = 0;
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:2];
    while ([resultSet next]) {
        SSJReportFormsItem *item = [[SSJReportFormsItem alloc] init];
        item.money = [resultSet doubleForColumn:@"SUM(IMONEY)"];
        item.colorValue = @"#64b3fe";
        item.imageName = @"";
        [result addObject:item];
        amount += item.money;
    }
    
    for (int i = 0; i < result.count; i ++) {
        SSJReportFormsItem *item = result[i];
        item.scale = item.money / amount;
    }
    
    return result;
}

@end