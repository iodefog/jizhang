//
//  SSJDatePeriod.m
//  SuiShouJi
//
//  Created by old lang on 16/3/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatePeriod.h"
#import "DateTools.h"

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

- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    if (self = [super init]) {
        self.startDate = startDate;
        self.endDate = endDate;
        self.periodType = SSJDatePeriodTypeCustom;
    }
    return self;
}

+ (instancetype)datePeriodWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    return [[self alloc] initWithStartDate:startDate endDate:endDate];
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

+ (NSArray<SSJDatePeriod *> *)periodsBetweenDate:(NSDate *)date andAnotherDate:(NSDate *)anotherDate periodType:(SSJDatePeriodType)type {
    SSJDatePeriod *period = [SSJDatePeriod datePeriodWithPeriodType:type date:date];
    SSJDatePeriod *anotherPeriod = [SSJDatePeriod datePeriodWithPeriodType:type date:anotherDate];
    return [period periodsFromPeriod:anotherPeriod];
}

- (NSArray<SSJDatePeriod *> *)periodsFromPeriod:(SSJDatePeriod *)period {
    if (!period || self.periodType != period.periodType) {
        return nil;
    }
    
    NSMutableArray *periods = [NSMutableArray array];
    NSCalendar *calendar = [[self class] calendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    SSJDatePeriod *earlierPeriod = [self earlierPeriod:period];
    SSJDatePeriod *latestPeriod = self == earlierPeriod ? period : self;
    
    NSInteger periodCount = [latestPeriod periodCountFromPeriod:earlierPeriod];
    for (NSInteger i = 1; i <= periodCount; i++) {
        switch (period.periodType) {
            case SSJDatePeriodTypeDay:
                [components setDay:i];
                break;
                
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
            case SSJDatePeriodTypeCustom:
                break;
        }
        
        NSDate *startDate = [calendar dateByAddingComponents:components toDate:earlierPeriod.startDate options:0];
        SSJDatePeriod *period = [SSJDatePeriod datePeriodWithPeriodType:_periodType date:startDate];
        [periods addObject:period];
    }
    
    return periods;
}

- (NSArray<SSJDatePeriod *> *)periodsFromDate:(NSDate *)date {
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
        NSLog(@">>> SSJ Warning:period为空或周期类型不匹配");
        return 0;
    }
    
    switch (period.periodType) {
        case SSJDatePeriodTypeDay: {
            NSDateComponents *tComponents = [[[self class] calendar] components:NSCalendarUnitDay fromDate:period.startDate toDate:self.startDate options:0];
            return tComponents.day;
        }
            break;
            
        case SSJDatePeriodTypeWeek: {
            NSDateComponents *tComponents = [[[self class] calendar] components:NSCalendarUnitWeekOfYear fromDate:period.startDate toDate:self.startDate options:0];
            return tComponents.weekOfYear;
        }
            break;
            
        case SSJDatePeriodTypeMonth: {
            NSDateComponents *tComponents = [[[self class] calendar] components:kAllCalendarUnitFlags fromDate:period.startDate toDate:self.startDate options:0];
            return tComponents.month + 12 * tComponents.year;
        }
            break;
            
        case SSJDatePeriodTypeYear: {
            NSDateComponents *tComponents = [[[self class] calendar] components:NSCalendarUnitYear fromDate:period.startDate toDate:self.startDate options:0];
            return tComponents.year;
        }
            break;
            
        case SSJDatePeriodTypeUnknown:
        case SSJDatePeriodTypeCustom: {
            return 0;
        }
            break;
    }
}

- (NSInteger)periodCountFromDate:(NSDate *)date {
    SSJDatePeriod *fromPeriod = [SSJDatePeriod datePeriodWithPeriodType:self.periodType date:date];
    return [self periodCountFromPeriod:fromPeriod];
}

- (NSInteger)daysCount {
    NSCalendar *calendar = [[self class] calendar];
    NSRange daysRange = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:(NSCalendarUnit)_periodType forDate:_startDate];
    return daysRange.length;
}

- (BOOL)containDate:(NSDate *)date {
    if ([self.startDate compare:date] != NSOrderedDescending
        && [self.endDate compare:date] != NSOrderedAscending) {
        return YES;
    }
    return NO;
}

#pragma mark - NSCopying
- (instancetype)copyWithZone:(NSZone *)zone {
    if (_periodType == SSJDatePeriodTypeCustom) {
        return [SSJDatePeriod datePeriodWithStartDate:_startDate endDate:_endDate];
    } else {
        return [SSJDatePeriod datePeriodWithPeriodType:_periodType date:_startDate];
    }
}

#pragma mark - NSObject
- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    SSJDatePeriod *anotherPeriod = object;
    if (_periodType != anotherPeriod.periodType
        || [_startDate compare:anotherPeriod.startDate] != NSOrderedSame
        || [_endDate compare:anotherPeriod.endDate] != NSOrderedSame) {
        return NO;
    }
    
    return YES;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@", @{@"startDate":(_startDate ? [_startDate formattedDateWithFormat:@"yyyy-MM-dd"] : [NSNull null]),
                                               @"endDate":(_endDate ? [_endDate formattedDateWithFormat:@"yyyy-MM-dd"] : [NSNull null]),
                                               @"periodType":@(_periodType)}];
}

@end
