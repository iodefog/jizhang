//
//  SSJDatePeriod.h
//  SuiShouJi
//
//  Created by old lang on 16/3/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SSJDatePeriodType) {
    SSJDatePeriodTypeWeek = NSCalendarUnitWeekOfYear,
    SSJDatePeriodTypeMonth = NSCalendarUnitMonth,
    SSJDatePeriodTypeYear = NSCalendarUnitYear
};

typedef NS_ENUM(NSInteger, SSJDatePeriodComparisonResult) {
    SSJDatePeriodComparisonResultUnknown = NSIntegerMin,
    SSJDatePeriodComparisonResultAscending = NSOrderedAscending,
    SSJDatePeriodComparisonResultSame = NSOrderedSame,
    SSJDatePeriodComparisonResultDescending = NSOrderedDescending
};

@interface SSJDatePeriod : NSObject

@property (nullable, nonatomic, strong, readonly) NSDate *startDate;

@property (nullable, nonatomic, strong, readonly) NSDate *endDate;

@property (nonatomic, readonly) SSJDatePeriodType periodType;

+ (instancetype)datePeriodWithPeriodType:(SSJDatePeriodType)type date:(NSDate *)date;

+ (instancetype)datePeriodWithPeriodType:(SSJDatePeriodType)type date:(NSDate *)date format:(NSString *)format;

+ (SSJDatePeriodComparisonResult)comparePeriod:(SSJDatePeriod *)period withAnotherPeriod:(SSJDatePeriod *)anotherPeriod;

+ (SSJDatePeriodComparisonResult)compareDate:(NSDate *)date withAnotherDate:(NSDate *)anotherDate periodType:(SSJDatePeriodType)type;

- (SSJDatePeriodComparisonResult)compareWithPeriod:(SSJDatePeriod *)period;

- (SSJDatePeriodComparisonResult)compareWithDate:(NSDate *)date;

+ (NSArray *)periodsBetweenPeriod:(SSJDatePeriod *)period andAnotherPeriod:(SSJDatePeriod *)anotherPeriod;

+ (NSArray *)periodsBetweenDate:(NSDate *)date andAnotherDate:(NSDate *)anotherDate periodType:(SSJDatePeriodType)type;

- (NSArray *)periodsFromPeriod:(SSJDatePeriod *)period;

- (NSArray *)periodsFromDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END