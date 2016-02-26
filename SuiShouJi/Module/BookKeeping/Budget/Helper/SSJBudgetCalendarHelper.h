//
//  SSJBudgetCalendarHelper.h
//  SuiShouJi
//
//  Created by old lang on 16/2/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJBudgetCalendarHelper : NSObject

+ (NSString *)getFirstDayOfCurrentWeek;

+ (NSString *)getLastDayOfCurrentWeek;

+ (NSString *)getFirstDayOfCurrentMonth;

+ (NSString *)getLastDayOfCurrentMonth;

+ (NSString *)getFirstDayOfCurrentYear;

+ (NSString *)getLastDayOfCurrentYear;

+ (NSDictionary *)getPeriodInfoWithCalendarUnit:(NSCalendarUnit)unit ForDate:(NSDate *)date;

@end
