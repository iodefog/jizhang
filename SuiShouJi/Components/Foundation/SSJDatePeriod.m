//
//  SSJDatePeriod.m
//  SuiShouJi
//
//  Created by old lang on 16/3/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatePeriod.h"

@interface SSJDatePeriod ()

@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, strong) NSDate *endDate;

@end

@implementation SSJDatePeriod

+ (NSDateFormatter *)format {
    static NSDateFormatter *format = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        format = [[NSDateFormatter alloc] init];
    });
    
    format.dateStyle = NSDateFormatterNoStyle;
    format.timeStyle = NSDateFormatterNoStyle;
    format.timeZone = [NSTimeZone systemTimeZone];
    return format;
}

+ (NSCalendar *)calendar {
    static NSCalendar *calendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!calendar) {
            calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        }
    });
    return calendar;
}

+ (instancetype)datePeriodWithPeriodType:(SSJDatePeriodType)type date:(NSDate *)date {
    SSJDatePeriod *period = [[SSJDatePeriod alloc] init];
    
    NSTimeInterval interval = 0;
    NSDate *startDate = nil;
    NSDate *endDate = nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];//设定周一为周首日
    if ([calendar rangeOfUnit:(NSCalendarUnit)type startDate:&startDate interval:&interval forDate:date]) {
        endDate = [startDate dateByAddingTimeInterval:interval-1];
        
        period.startDate = startDate;
        period.endDate = endDate;
    }
    
    return period;
}

+ (SSJDatePeriodComparisonResult)comparePeriod:(SSJDatePeriod *)period withAnotherPeriod:(SSJDatePeriod *)anotherPeriod {
    if (period.periodType != anotherPeriod.periodType) {
        return SSJDatePeriodComparisonResultUnknown;
    }
    
    return (SSJDatePeriodComparisonResult)[period.startDate compare:anotherPeriod.startDate];
}

+ (SSJDatePeriodComparisonResult)compareDate:(NSDate *)date withAnotherDate:(NSDate *)anotherDate periodType:(SSJDatePeriodType)type {
    SSJDatePeriod *period = [SSJDatePeriod datePeriodWithPeriodType:type date:date];
    SSJDatePeriod *anotherPeriod = [SSJDatePeriod datePeriodWithPeriodType:type date:anotherDate];
    return [self comparePeriod:period withAnotherPeriod:anotherPeriod];
}

- (SSJDatePeriodComparisonResult)compareWithPeriod:(SSJDatePeriod *)period {
    if (self.periodType != period.periodType) {
        return SSJDatePeriodComparisonResultUnknown;
    }
    
    return (SSJDatePeriodComparisonResult)[self.startDate compare:period.startDate];
}

- (SSJDatePeriodComparisonResult)compareWithDate:(NSDate *)date {
    SSJDatePeriod *period = [SSJDatePeriod datePeriodWithPeriodType:self.periodType date:date];
    return [self compareWithPeriod:period];
}

+ (NSArray *)periodsBetweenPeriod:(SSJDatePeriod *)period andAnotherPeriod:(SSJDatePeriod *)anotherPeriod {
    return [period periodsFromPeriod:anotherPeriod];
}

+ (NSArray *)periodsBetweenDate:(NSDate *)date andAnotherDate:(NSDate *)anotherDate periodType:(SSJDatePeriodType)type {
    SSJDatePeriod *period = [SSJDatePeriod datePeriodWithPeriodType:type date:date];
    SSJDatePeriod *anotherPeriod = [SSJDatePeriod datePeriodWithPeriodType:type date:anotherDate];
    return [period periodsFromPeriod:anotherPeriod];
}

- (NSArray *)periodsFromPeriod:(SSJDatePeriod *)period {
    if (self.periodType != period.periodType) {
        return nil;
    }
    
//    SSJDatePeriod *earlierPeriod = [self earlierPeriod:period];
//    SSJDatePeriod *latestPeriod = self == earlierPeriod ? period : self;
//    switch (period.periodType) {
//        case SSJDatePeriodTypeWeek: {
//            NSDateComponents *components = [[[self class] calendar] components:NSCalendarUnitYear fromDate:earlierPeriod.endDate toDate:latestPeriod.startDate options:0];
//            components.year;
//        }
//            
//            break;
//            
//        case SSJDatePeriodTypeMonth: {
//            NSDateComponents *components = [[[self class] calendar] components:NSCalendarUnitYear fromDate:earlierPeriod.endDate toDate:latestPeriod.startDate options:0];
//            components.year;
//        }
//            
//            break;
//            
//        case SSJDatePeriodTypeYear: {
//            NSDateComponents *components = [[[self class] calendar] components:NSCalendarUnitYear fromDate:earlierPeriod.endDate toDate:latestPeriod.startDate options:0];
//            for (int i = 0; i < components.year; <#increment#>) {
//                <#statements#>
//            }
//            ;
//        }
//            
//            break;
//    }
    return nil;
}

- (NSArray *)periodsFromDate:(NSDate *)date {
    return nil;
}

- (SSJDatePeriod *)earlierPeriod:(SSJDatePeriod *)period {
    switch ([self compareWithPeriod:period]) {
        case SSJDatePeriodComparisonResultUnknown:
            return nil;
            break;
            
        case SSJDatePeriodComparisonResultAscending:
            return self;
            break;
            
        case SSJDatePeriodComparisonResultSame:
            return self;
            break;
            
        case SSJDatePeriodComparisonResultDescending:
            return period;
            break;
    }
}

@end
