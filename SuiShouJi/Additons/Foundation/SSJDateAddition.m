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

- (NSString *)ssj_dateStringWithFormat:(NSString *)format {
    [[self ssj_formatter] setDateFormat:format];
    NSString *dateString = [[self ssj_formatter] stringFromDate:self];
    return dateString;
}

- (NSString *)ssj_systemCurrentDateWithFormat:(NSString *)format{
    NSDate *now = [NSDate date];
    if (!format || format.length == 0) {
        format = @"yyyy-MM-dd HH:mm:ss";
    }
    [[self ssj_formatter] setDateFormat:format];
    NSString *systemTimeZoneStr = [[self ssj_formatter] stringFromDate:now];
    return systemTimeZoneStr;
}


@end
