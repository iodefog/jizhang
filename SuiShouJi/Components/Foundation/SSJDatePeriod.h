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
    SSJDatePeriodTypeWeek = NSCalendarUnitWeekOfMonth,
    SSJDatePeriodTypeMonth = NSCalendarUnitWeekOfMonth,
    SSJDatePeriodTypeYear = NSCalendarUnitYear
};

@interface SSJDatePeriod : NSObject

@property (nullable, nonatomic, strong, readonly) NSDate *startDate;

@property (nullable, nonatomic, strong, readonly) NSDate *endDate;

+ (instancetype)datePeriodWithPeriodType:(SSJDatePeriodType)type date:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END