//
//  SSJReportFormsUtil.m
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJReportFormsUtil.h"
#import "SSJDatabaseQueue.h"
#import "SSJReportFormsPeriodModel.h"
#import "SSJUserTableManager.h"

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - 数据库查询工具类

@implementation SSJReportFormsDatabaseUtil

+ (void)queryForPeriodListWithIncomeOrPayType:(SSJBillType)type
                                      success:(void (^)(NSArray<SSJDatePeriod *> *))success
                                      failure:(void (^)(NSError *))failure {
    
    SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"currentBooksId"] forUserId:SSJUSERID()];
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *result = nil;
        switch (type) {
            case SSJBillTypeIncome:
            case SSJBillTypePay: {
                NSString *incomeOrPayType = type == SSJBillTypeIncome ? @"0" : @"1";
                result = [db executeQuery:@"select distinct strftime('%Y-%m', a.cbilldate) from bk_user_charge as a, bk_bill_type as b where  a.cuserid = ? and a.ibillid = b.id and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and a.cbooksid = ? and b.itype = ? and b.istate <> 2 order by a.cbilldate", SSJUSERID(), userItem.currentBooksId, incomeOrPayType];
            }   break;
                
            case SSJBillTypeSurplus: {
                result = [db executeQuery:@"select distinct strftime('%Y-%m', a.cbilldate) from bk_user_charge as a, bk_bill_type as b where  a.cuserid = ? and a.ibillid = b.id and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and a.cbooksid = ? and b.istate <> 2 order by a.cbilldate", SSJUSERID(), userItem.currentBooksId];
            }   break;
                
            case SSJBillTypeUnknown:
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure(nil);
                    });
                }
                break;
        }
        
        if (!result) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSInteger year = 0;
        NSMutableArray *list = [NSMutableArray array];
        while ([result next]) {
            NSString *dateStr = [result stringForColumnIndex:0];
            NSDate *date = [NSDate dateWithString:dateStr formatString:@"yyyy-MM"];
            if (year && year != [date year]) {
                SSJDatePeriod *period = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeYear date:date];
                [list addObject:period];
                year = [date year];
            }
            
            SSJDatePeriod *period = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeMonth date:date];
            [list addObject:period];
        }
        
        if (list.count) {
            SSJDatePeriod *firstPeriod = [list firstObject];
            SSJDatePeriod *lastPeriod = [list lastObject];
            [list addObject:[SSJDatePeriod datePeriodWithStartDate:firstPeriod.startDate endDate:lastPeriod.endDate]];
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(list);
            });
        }
    }];
}

+ (void)queryForIncomeOrPayType:(SSJBillType)type
                      startDate:(NSDate *)startDate
                        endDate:(NSDate *)endDate
                        success:(void(^)(NSArray<SSJReportFormsItem *> *result))success
                        failure:(void (^)(NSError *error))failure {
    
    switch (type) {
        case SSJBillTypeIncome:
        case SSJBillTypePay:
            [self queryForIncomeOrPayChargeWithType:type startDate:startDate endDate:endDate success:success failure:failure];
            break;
            
        case SSJBillTypeSurplus:
            [self queryForSurplusWithStartDate:startDate endDate:endDate success:success failure:failure];
            break;
            
        case SSJBillTypeUnknown:
            failure(nil);
            break;
    }
}

//  查询收支数据
+ (void)queryForIncomeOrPayChargeWithType:(SSJBillType)type
                                startDate:(NSDate *)startDate
                                  endDate:(NSDate *)endDate
                                  success:(void (^)(NSArray <SSJReportFormsItem *> *result))success
                                  failure:(void (^)(NSError *error))failure {
    
    NSString *incomeOrPayType = nil;
    switch (type) {
        case SSJBillTypeIncome:
            incomeOrPayType = @"0";
            break;
            
        case SSJBillTypePay:
            incomeOrPayType = @"1";
            break;
            
        case SSJBillTypeSurplus:
        case SSJBillTypeUnknown:
            failure(nil);
            return;
    }
    
    if (!startDate || !endDate) {
        failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"startDate or endDate must not be nil"}]);
        return;
    }
    
    NSString *beginDateStr = [startDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *endDateStr = [endDate formattedDateWithFormat:@"yyyy-MM-dd"];
    
    SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"currentBooksId"] forUserId:SSJUSERID()];
    
    //  查询不同收支类型的总额
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *amountResultSet = [db executeQuery:@"select sum(a.IMONEY) from BK_USER_CHARGE as a, BK_BILL_TYPE as b where a.IBILLID = b.ID and a.CBILLDATE >= ? and a.cbilldate <= ? and a.cbilldate <= datetime('now', 'localtime') and a.CUSERID = ? and a.OPERATORTYPE <> 2 and a.cbooksid = ? and b.istate <> 2 and b.ITYPE = ?", beginDateStr , endDateStr, SSJUSERID(), userItem.currentBooksId, incomeOrPayType];
        
        if (!amountResultSet) {
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
            SSJDispatch_main_async_safe(^{
                success(nil);
            });
            
            return;
        }
        
        //  查询不同收支类型相应的金额、名称、图标、颜色
        FMResultSet *resultSet = [db executeQuery:@"select sum(a.imoney), b.id, b.cname, b.ccoin, b.ccolor from bk_user_charge as a, bk_bill_type as b where a.cuserid = ? and a.ibillid = b.id and a.cbilldate >= ? and a.cbilldate <= ? and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and a.cbooksid = ? and b.itype = ? and b.istate <> 2 group by b.id", SSJUSERID(), beginDateStr, endDateStr, userItem.currentBooksId, incomeOrPayType];
        
        if (!resultSet) {
            SSJPRINT(@">>>SSJ\n class:%@\n method:%@\n message:%@\n error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorMessage], [db lastError]);
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        
        NSMutableArray *result = [@[] mutableCopy];
        while ([resultSet next]) {
            SSJReportFormsItem *item = [[SSJReportFormsItem alloc] init];
            item.ID = [resultSet stringForColumn:@"id"];
            item.money = [resultSet doubleForColumn:@"sum(a.imoney)"];
            item.scale = item.money / amount;
            item.colorValue = [resultSet stringForColumn:@"ccolor"];
            item.imageName = [resultSet stringForColumn:@"ccoin"];
            item.incomeOrPayName = [resultSet stringForColumn:@"cname"];
            [result addObject:item];
        }
        
        SSJDispatch_main_async_safe(^{
            success(result);
        });
    }];
}

//  查询结余数据
+ (void)queryForSurplusWithStartDate:(NSDate *)startDate
                             endDate:(NSDate *)endDate
                             success:(void (^)(NSArray <SSJReportFormsItem *> *result))success
                             failure:(void (^)(NSError *error))failure {
    
    SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"currentBooksId"] forUserId:SSJUSERID()];
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        
        NSString *beginDateStr = [startDate formattedDateWithFormat:@"yyyy-MM-dd"];
        NSString *endDateStr = [endDate formattedDateWithFormat:@"yyyy-MM-dd"];
        
        FMResultSet *resultSet = [db executeQuery:@"select sum(a.imoney), b.itype from bk_user_charge as a, bk_bill_type as b where a.cuserid = ? and a.ibillid = b.id and a.cbilldate >= ? and a.cbilldate <= ? and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and a.cbooksid = ? and b.istate <> 2 group by b.itype order by b.itype desc", SSJUSERID(), beginDateStr, endDateStr, userItem.currentBooksId];
        
        if (!resultSet) {
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
            item.type = type;
            item.money = [resultSet doubleForColumn:@"sum(a.imoney)"];
            item.colorValue = type == 0 ? @"#f56262" : @"#59ae65";
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