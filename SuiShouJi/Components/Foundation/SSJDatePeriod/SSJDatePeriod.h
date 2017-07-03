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
    SSJDatePeriodTypeUnknown = 0,
    SSJDatePeriodTypeDay = NSCalendarUnitDay,
    SSJDatePeriodTypeWeek = NSCalendarUnitWeekOfYear,
    SSJDatePeriodTypeMonth = NSCalendarUnitMonth,
    SSJDatePeriodTypeYear = NSCalendarUnitYear,
    SSJDatePeriodTypeCustom = NSUIntegerMax
};

typedef NS_ENUM(NSInteger, SSJDatePeriodComparisonResult) {
    SSJDatePeriodComparisonResultUnknown = NSIntegerMin,
    SSJDatePeriodComparisonResultAscending = NSOrderedAscending,
    SSJDatePeriodComparisonResultSame = NSOrderedSame,
    SSJDatePeriodComparisonResultDescending = NSOrderedDescending
};

@interface SSJDatePeriod : NSObject <NSCopying>

@property (nullable, nonatomic, strong, readonly) NSDate *startDate;

@property (nullable, nonatomic, strong, readonly) NSDate *endDate;

@property (nonatomic, readonly) SSJDatePeriodType periodType;

- (instancetype)initWithPeriodType:(SSJDatePeriodType)type date:(NSDate *)date;

+ (instancetype)datePeriodWithPeriodType:(SSJDatePeriodType)type date:(NSDate *)date;

- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

+ (instancetype)datePeriodWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

+ (SSJDatePeriodComparisonResult)compareDate:(NSDate *)date withAnotherDate:(NSDate *)anotherDate periodType:(SSJDatePeriodType)type;

- (SSJDatePeriodComparisonResult)compareWithPeriod:(SSJDatePeriod *)period;

- (SSJDatePeriodComparisonResult)compareWithDate:(NSDate *)date;

+ (nullable NSArray<SSJDatePeriod *> *)periodsBetweenDate:(NSDate *)date andAnotherDate:(NSDate *)anotherDate periodType:(SSJDatePeriodType)type;

- (nullable NSArray<SSJDatePeriod *> *)periodsFromPeriod:(SSJDatePeriod *)period;

- (nullable NSArray<SSJDatePeriod *> *)periodsFromDate:(NSDate *)date;

+ (NSInteger)periodCountFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate periodType:(SSJDatePeriodType)type;

- (NSInteger)periodCountFromPeriod:(SSJDatePeriod *)period;

- (NSInteger)periodCountFromDate:(NSDate *)date;

- (NSInteger)daysCount;

- (BOOL)containDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
