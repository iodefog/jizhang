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

@end
