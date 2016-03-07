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

@end
