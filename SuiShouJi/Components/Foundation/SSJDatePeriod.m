//
//  SSJDatePeriod.m
//  SuiShouJi
//
//  Created by old lang on 16/3/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatePeriod.h"

static const unsigned int kAllCalendarUnitFlags = NSCalendarUnitYear | NSCalendarUnitQuarter | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekOfMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitEra | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal | NSCalendarUnitWeekOfYear;

@interface SSJDatePeriod ()

@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic) SSJDatePeriodType periodType;
@end

@implementation SSJDatePeriod

//+ (NSDateFormatter *)format {
//    static NSDateFormatter *format = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        format = [[NSDateFormatter alloc] init];
//    });
//    
//    format.dateStyle = NSDateFormatterNoStyle;
//    format.timeStyle = NSDateFormatterNoStyle;
//    format.timeZone = [NSTimeZone systemTimeZone];
//    return format;
//}

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

- (instancetype)init {
    return [self initWithPeriodType:SSJDatePeriodTypeUnknown date:[NSDate date]];
}

- (instancetype)initWithPeriodType:(SSJDatePeriodType)type date:(NSDate *)date {
    if (self = [super init]) {
        self.periodType = type;
        if (type != SSJDatePeriodTypeUnknown) {
            NSTimeInterval interval = 0;
            NSDate *startDate = nil;
            NSDate *endDate = nil;
            NSCalendar *calendar = [NSCalendar currentCalendar];
            [calendar setFirstWeekday:2];//设定周一为周首日
            if ([calendar rangeOfUnit:(NSCalendarUnit)type startDate:&startDate interval:&interval forDate:date]) {
                endDate = [startDate dateByAddingTimeInterval:interval-1];
                
                self.startDate = startDate;
                self.endDate = endDate;
            }
        }
    }
    return self;
}

+ (instancetype)datePeriodWithPeriodType:(SSJDatePeriodType)type date:(NSDate *)date {
    return [[self alloc] initWithPeriodType:type date:date];
}

+ (SSJDatePeriodComparisonResult)compareDate:(NSDate *)date withAnotherDate:(NSDate *)anotherDate periodType:(SSJDatePeriodType)type {
    SSJDatePeriod *period = [SSJDatePeriod datePeriodWithPeriodType:type date:date];
    SSJDatePeriod *anotherPeriod = [SSJDatePeriod datePeriodWithPeriodType:type date:anotherDate];
    return [period compareWithPeriod:anotherPeriod];
}

- (SSJDatePeriodComparisonResult)compareWithPeriod:(SSJDatePeriod *)period {
    if (!period || self.periodType != period.periodType) {
        return SSJDatePeriodComparisonResultUnknown;
    }
    
    return (SSJDatePeriodComparisonResult)[self.startDate compare:period.startDate];
}

- (SSJDatePeriodComparisonResult)compareWithDate:(NSDate *)date {
    SSJDatePeriod *period = [SSJDatePeriod datePeriodWithPeriodType:self.periodType date:date];
    return [self compareWithPeriod:period];
}

+ (NSArray *)periodsBetweenDate:(NSDate *)date andAnotherDate:(NSDate *)anotherDate periodType:(SSJDatePeriodType)type {
    SSJDatePeriod *period = [SSJDatePeriod datePeriodWithPeriodType:type date:date];
    SSJDatePeriod *anotherPeriod = [SSJDatePeriod datePeriodWithPeriodType:type date:anotherDate];
    return [period periodsFromPeriod:anotherPeriod];
}

- (NSArray *)periodsFromPeriod:(SSJDatePeriod *)period {
    if (!period || self.periodType != period.periodType) {
        return nil;
    }
    
    NSMutableArray *periods = [NSMutableArray array];
    NSCalendar *calendar = [[self class] calendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    SSJDatePeriod *earlierPeriod = [self earlierPeriod:period];
    SSJDatePeriod *latestPeriod = self == earlierPeriod ? period : self;
    
    NSInteger periodCount = [latestPeriod periodCountFromPeriod:earlierPeriod];
    for (NSInteger i = 0; i < periodCount; i++) {
        switch (period.periodType) {
            case SSJDatePeriodTypeWeek:
                [components setWeekOfYear:i];
                break;
                
            case SSJDatePeriodTypeMonth:
                [components setMonth:i];
                break;
                
            case SSJDatePeriodTypeYear:
                [components setYear:i];
                break;
            case SSJDatePeriodTypeUnknown:
                [components setWeekOfYear:i];
                break;
        }
        
        NSDate *startDate = [calendar dateByAddingComponents:components toDate:earlierPeriod.startDate options:0];
        NSDate *endDate = [calendar dateByAddingComponents:components toDate:earlierPeriod.endDate options:0];
        
        SSJDatePeriod *period = [[SSJDatePeriod alloc] init];
        period.startDate = startDate;
        period.endDate = endDate;
        [periods addObject:period];
    }
    
    return periods;
}

- (NSArray *)periodsFromDate:(NSDate *)date {
    SSJDatePeriod *period = [SSJDatePeriod datePeriodWithPeriodType:self.periodType date:date];
    return [self periodsFromPeriod:period];
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

+ (NSInteger)periodCountFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate periodType:(SSJDatePeriodType)type {
    SSJDatePeriod *fromPeriod = [SSJDatePeriod datePeriodWithPeriodType:type date:fromDate];
    SSJDatePeriod *toPeriod = [SSJDatePeriod datePeriodWithPeriodType:type date:toDate];
    return [toPeriod periodCountFromPeriod:fromPeriod];
}

- (NSInteger)periodCountFromPeriod:(SSJDatePeriod *)period {
    if (!period || self.periodType != period.periodType) {
        SSJPRINT(@">>> SSJ Warning:period为空或周期类型不匹配");
        return 0;
    }
    
    switch (period.periodType) {
        case SSJDatePeriodTypeWeek: {
            NSDateComponents *tComponents = [[[self class] calendar] components:NSCalendarUnitWeekOfYear fromDate:period.endDate toDate:self.startDate options:0];
            return tComponents.weekOfYear;
        }
            break;
            
        case SSJDatePeriodTypeMonth: {
            NSDateComponents *tComponents = [[[self class] calendar] components:kAllCalendarUnitFlags fromDate:period.endDate toDate:self.startDate options:0];
            return tComponents.month + 12 * tComponents.year;
        }
            break;
            
        case SSJDatePeriodTypeYear: {
            NSDateComponents *tComponents = [[[self class] calendar] components:NSCalendarUnitYear fromDate:period.endDate toDate:self.startDate options:0];
            return tComponents.year;
        }
            break;
            
        case SSJDatePeriodTypeUnknown: {
            return 0;
        }
            break;
    }
}

- (NSInteger)periodCountFromDate:(NSDate *)date {
    SSJDatePeriod *fromPeriod = [SSJDatePeriod datePeriodWithPeriodType:self.periodType date:date];
    return [self periodCountFromPeriod:fromPeriod];
}

@end
