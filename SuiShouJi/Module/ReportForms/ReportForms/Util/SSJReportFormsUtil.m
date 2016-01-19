//
//  SSJReportFormsUtil.m
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJReportFormsUtil.h"
#import "SSJDatabaseQueue.h"

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - 数据库查询工具类

@implementation SSJReportFormsDatabaseUtil

+ (void)queryForIncomeOrPayType:(SSJReportFormsIncomeOrPayType)type
                         inYear:(NSInteger)year
                          month:(NSInteger)month
                        success:(void(^)(NSArray<SSJReportFormsItem *> *))success
                        failure:(void (^)(NSError *error))failure {
    
    if (year <= 0 || month > 12) {
        failure(nil);
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
            [self queryForIncomeOrPay:type billDate:dateStr success:success failure:failure];
            break;
            
        case SSJReportFormsIncomeOrPayTypeSurplus:
            [self queryForSurplusWithBillDate:dateStr success:success failure:failure];
            break;
            
        case SSJReportFormsIncomeOrPayTypeUnknown:
            failure(nil);
            break;
    }
}

//  查询收支数据
+ (void)queryForIncomeOrPay:(SSJReportFormsIncomeOrPayType)type
                   billDate:(NSString *)billDate
                    success:(void (^)(NSArray <SSJReportFormsItem *> *result))success
                    failure:(void (^)(NSError *error))failure {
    
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
            failure(nil);
            return;
    }
    
    //  查询不同收支类型的总额
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *amountResultSet = [db executeQuery:@"select sum(a.IMONEY) from BK_USER_CHARGE as a, BK_BILL_TYPE as b where a.IBILLID = b.ID and a.CBILLDATE like ? and a.CUSERID = ? and a.OPERATORTYPE <> 2 and a.IBILLID like '1___' or a.IBILLID like '2___' and b.ITYPE = ?", billDate, SSJUSERID(), incomeOrPayType];
        
        if (!amountResultSet) {
//            [[SSJDatabaseQueue sharedInstance] close];
            SSJPRINT(@">>>SSJ\n class:%@\n method:%@\n message:%@\n error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorMessage], [db lastError]);
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        
        double amount = 0;
        while ([amountResultSet next]) {
            amount = [amountResultSet doubleForColumnIndex:0];
        }
        
        if (amount == 0) {
//            [[SSJDatabaseQueue sharedInstance] close];
            SSJDispatch_main_async_safe(^{
                success(nil);
            });
            
            return;
        }
        
        //  查询不同收支类型相应的金额、名称、图标、颜色
        FMResultSet *resultSet = [db executeQuery:@"select a.IBILLID, a.AMOUNT, b.CNAME, b.CCOIN, b.CCOLOR from (select sum(IMONEY) as AMOUNT, IBILLID from BK_USER_CHARGE where CBILLDATE like ? and CUSERID = ? and OPERATORTYPE <> 2 and IBILLID like '1___' or IBILLID like '2___' group by IBILLID) as a, BK_BILL_TYPE as b where a.IBILLID = b.ID and b.ITYPE = ?", billDate, SSJUSERID(), incomeOrPayType];
        
        if (!resultSet) {
//            [[SSJDatabaseQueue sharedInstance] close];
            SSJPRINT(@">>>SSJ\n class:%@\n method:%@\n message:%@\n error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorMessage], [db lastError]);
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        
        NSMutableArray *result = [@[] mutableCopy];
        while ([resultSet next]) {
            SSJReportFormsItem *item = [[SSJReportFormsItem alloc] init];
            item.ID = [resultSet stringForColumn:@"IBILLID"];
            item.money = [resultSet doubleForColumn:@"AMOUNT"];
            item.scale = item.money / amount;
            item.colorValue = [resultSet stringForColumn:@"CCOLOR"];
            item.imageName = [resultSet stringForColumn:@"CCOIN"];
            item.incomeOrPayName = [resultSet stringForColumn:@"CNAME"];
            [result addObject:item];
        }
        
        SSJDispatch_main_async_safe(^{
            success(result);
        });
    }];
}

//  查询结余数据
+ (void)queryForSurplusWithBillDate:(NSString *)billDate
                            success:(void (^)(NSArray <SSJReportFormsItem *> *result))success
                            failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select sum(IMONEY), ITYPE from (select a.IMONEY, b.ITYPE from BK_USER_CHARGE as a, BK_BILL_TYPE as b where a.IBILLID = b.ID and a.CBILLDATE like ? and a.CUSERID = ? and a.OPERATORTYPE <> 2 and IBILLID like '1___' or IBILLID like '2___') group by ITYPE order by ITYPE desc", billDate, SSJUSERID()];
        
        if (!resultSet) {
//            [[SSJDatabaseQueue sharedInstance] close];
            SSJPRINT(@">>>SSJ\n class:%@\n method:%@\n message:%@\n error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorMessage], [db lastError]);
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        
        double amount = 0;
        
        NSMutableArray *result = [NSMutableArray arrayWithCapacity:2];
        while ([resultSet next]) {
            //  0:收入 1:支出
            int type = [resultSet intForColumn:@"ITYPE"];
            
            SSJReportFormsItem *item = [[SSJReportFormsItem alloc] init];
            item.money = [resultSet doubleForColumn:@"SUM(IMONEY)"];
            item.colorValue = type == 0 ? @"#64b3fe" : @"#fe7373";
            item.imageName = type == 0 ? @"reportForms_income" : @"reportForms_expenses";
            [result addObject:item];
            amount += item.money;
        }
        
        for (int i = 0; i < result.count; i ++) {
            SSJReportFormsItem *item = result[i];
            item.scale = item.money / amount;
        }
        
        SSJDispatch_main_async_safe(^{
            success(result);
        });
    }];
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