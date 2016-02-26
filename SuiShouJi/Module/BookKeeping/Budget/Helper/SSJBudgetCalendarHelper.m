//
//  SSJBudgetCalendarHelper.m
//  SuiShouJi
//
//  Created by old lang on 16/2/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetCalendarHelper.h"
#import "SSJBudgetConst.h"

@implementation SSJBudgetCalendarHelper

+ (NSString *)getFirstDayOfCurrentWeek {
    return [self getFirstDayForUnit:NSCalendarUnitWeekOfMonth];
}

+ (NSString *)getLastDayOfCurrentWeek {
    return [self getLastDayForUnit:NSCalendarUnitWeekOfMonth];
}

+ (NSString *)getFirstDayOfCurrentMonth {
    return [self getFirstDayForUnit:NSCalendarUnitMonth];
}

+ (NSString *)getLastDayOfCurrentMonth {
    return [self getLastDayForUnit:NSCalendarUnitMonth];
}

+ (NSString *)getFirstDayOfCurrentYear {
    return [self getFirstDayForUnit:NSCalendarUnitYear];
}

+ (NSString *)getLastDayOfCurrentYear {
    return [self getLastDayForUnit:NSCalendarUnitYear];
}

+ (NSString *)getFirstDayForUnit:(NSCalendarUnit)unit {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone systemTimeZone];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDictionary *period = [self getPeriodInfoWithCalendarUnit:unit ForDate:[NSDate date]];
    NSDate *beginDate = period[SSJBudgetPeriodBeginDateKey];
    return [formatter stringFromDate:beginDate];
}

+ (NSString *)getLastDayForUnit:(NSCalendarUnit)unit {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone systemTimeZone];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDictionary *period = [self getPeriodInfoWithCalendarUnit:unit ForDate:[NSDate date]];
    NSDate *endDate = period[SSJBudgetPeriodEndDateKey];
    return [formatter stringFromDate:endDate];
}

+ (NSDictionary *)getPeriodInfoWithCalendarUnit:(NSCalendarUnit)unit ForDate:(NSDate *)date {
    NSTimeInterval interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];//设定周一为周首日
    if ([calendar rangeOfUnit:unit startDate:&beginDate interval:&interval forDate:date]) {
        endDate = [beginDate dateByAddingTimeInterval:interval-1];
        return @{SSJBudgetPeriodBeginDateKey:beginDate,
                 SSJBudgetPeriodEndDateKey:endDate};
    }
    return nil;
}

@end
