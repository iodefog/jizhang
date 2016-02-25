//
//  SSJBudgetCalendarHelper.m
//  SuiShouJi
//
//  Created by old lang on 16/2/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetCalendarHelper.h"

@implementation SSJBudgetCalendarHelper

+ (NSString *)getFirstDayOfCurrentWeek {
    return [self getFirstDayForUnit:NSCalendarUnitWeekday];
}

+ (NSString *)getLastDayOfCurrentWeek {
    return [self getLastDayForUnit:NSCalendarUnitWeekday];
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
    NSDate *beginDate = nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];//设定周一为周首日
    //分别修改为 NSDayCalendarUnit NSWeekCalendarUnit NSYearCalendarUnit
    if ([calendar rangeOfUnit:unit startDate:&beginDate interval:nil forDate:[NSDate date]]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.timeZone = [NSTimeZone systemTimeZone];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        return [formatter stringFromDate:beginDate];
    }
    return nil;
}

+ (NSString *)getLastDayForUnit:(NSCalendarUnit)unit {
    NSTimeInterval interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];//设定周一为周首日
    if ([calendar rangeOfUnit:unit startDate:&beginDate interval:&interval forDate:[NSDate date]]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.timeZone = [NSTimeZone systemTimeZone];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        
        endDate = [beginDate dateByAddingTimeInterval:interval-1];
        return [formatter stringFromDate:endDate];
    }
    return nil;
}

@end
