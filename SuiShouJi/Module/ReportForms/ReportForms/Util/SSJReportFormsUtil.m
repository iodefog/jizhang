//
//  SSJReportFormsUtil.m
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJReportFormsUtil.h"
#import "FMDB.h"

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - 数据库查询工具类

@implementation SSJReportFormsDatabaseUtil

+ (NSArray<SSJReportFormsItem *> *)queryForIncomeOrPayType:(SSJReportFormsIncomeOrPayType)type inYear:(NSInteger)year month:(NSInteger)month {
    if (year <= 0 || month > 12) {
        return nil;
    }
    
    NSString *dateStr = nil;
    if (month > 0 && month <= 12) {
        dateStr = [NSString stringWithFormat:@"%04d-%02d-__",(int)year,(int)month];
    } else {
        dateStr = [NSString stringWithFormat:@"%04d-__-__",(int)year];
    }
    
    switch (type) {
        case SSJReportFormsIncomeOrPayTypeIncome:
        case SSJReportFormsIncomeOrPayTypePay:
            return [self queryForIncomeOrPay:type billDate:dateStr];
            
        case SSJReportFormsIncomeOrPayTypeSurplus:
            return [self queryForSurplusWithBillDate:dateStr];
        case SSJReportFormsIncomeOrPayTypeUnknown:
            return nil;
    }
    
    return nil;
}

//  查询收支数据
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

//  查询盈余数据
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

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - 日历工具类

@interface SSJReportFormsCalendarUtil ()

@property (nonatomic, strong) NSCalendar *calendar;

@end

@implementation SSJReportFormsCalendarUtil

- (instancetype)init {
    if (self = [super init]) {
        self.calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponent = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
        self.year = [dateComponent year];
        self.month = [dateComponent month];
    }
    return self;
}

- (NSInteger)currentYear {
    NSDateComponents *dateComponent = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
    return [dateComponent year];
}

- (NSInteger)currentMonth {
    NSDateComponents *dateComponent = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
    return [dateComponent month];
}

- (NSInteger)nextYear {
    if (self.year < [self currentYear]) {
        self.year ++;
        if (self.year == [self currentYear]) {
            self.month = MIN(self.month, [self currentMonth]);
        }
    }
    return self.year;
}

- (NSInteger)preYear {
    if (self.year > 1) {
        self.year --;
    }
    return self.year;
}

- (NSInteger)nextMonth {
    if (self.year < [self currentYear]) {
        self.month ++;
        if (self.month > 12) {
            self.year ++;
            self.month = 1;
        }
    } else {
        if (self.month < [self currentMonth]) {
            self.month ++;
        }
    }
    return self.month;
}

- (NSInteger)preMonth {
    if (self.year > 1) {
        self.month --;
        if (self.month == 0) {
            self.month = 12;
            self.year --;
        }
    } else {
        if (self.month > 1) {
            self.month --;
        }
    }
    return self.month;
}

@end