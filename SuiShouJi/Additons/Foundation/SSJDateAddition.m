//
//  SSJDateAddition.m
//  SuiShouJi
//
//  Created by old lang on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJDateAddition.h"

@implementation NSDate (SSJCategory)

- (NSString *)ssj_dateStringWithFormat:(NSString *)format {
    NSDateFormatter *tempFormat = [[NSDateFormatter alloc] init];
    [tempFormat setDateFormat:format];
    NSString *dateString = [tempFormat stringFromDate:self];
    return dateString;
}

- (NSString *)ssj_systemCurrentDateWithFormat:(NSString *)format{
    NSDate *now = [NSDate date];
    if (!format || format.length == 0) {
        format = @"yyyy-MM-dd HH:mm:ss";
    }
    NSDateFormatter *tempFormat = [[NSDateFormatter alloc] init];
    [tempFormat setDateFormat:format];
    tempFormat.timeZone = [NSTimeZone systemTimeZone];
    NSString *systemTimeZoneStr =  [tempFormat stringFromDate:now];
    return systemTimeZoneStr;
}

@end
