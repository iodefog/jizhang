//
//  SSJDateAddition.m
//  SuiShouJi
//
//  Created by old lang on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJDateAddition.h"

@implementation NSDate (SSJCategory)

- (NSDateFormatter *)ssj_formatter {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.timeZone = [NSTimeZone systemTimeZone];
    });
    return formatter;
}

- (NSCalendar *)ssj_calendar {
    static NSCalendar *calendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!calendar) {
            calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        }
    });
    return calendar;
}

- (NSString *)ssj_dateStringWithFormat:(NSString *)format {
    [[self ssj_formatter] setDateFormat:format];
    NSString *dateString = [[self ssj_formatter] stringFromDate:self];
    return dateString;
}

- (NSString *)ssj_systemCurrentDateWithFormat:(NSString *)format{
    if (!format || format.length == 0) {
        format = @"yyyy-MM-dd HH:mm:ss";
    }
    [[self ssj_formatter] setDateFormat:format];
    NSString *systemTimeZoneStr = [[self ssj_formatter] stringFromDate:self];
    return systemTimeZoneStr;
}

- (NSUInteger)ssj_numberOfDaysInCurrentMonth {
    NSCalendar *calendar = [self ssj_calendar];
    NSRange daysRange = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self];
    return daysRange.length;
}

- (NSUInteger)ssj_numberOfDaysInCurrentYear {
    NSCalendar *calendar = [self ssj_calendar];
    NSRange daysRange = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:self];
    return daysRange.length;
}

@end
