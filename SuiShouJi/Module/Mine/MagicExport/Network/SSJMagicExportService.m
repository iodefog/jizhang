//
//  SSJMagicExportService.m
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportService.h"

@interface SSJMagicExportService ()

@property (nonatomic, copy) NSString *email;

@end

@implementation SSJMagicExportService

- (void)exportWithBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate emailAddress:(NSString *)email {
    _email = email;
    NSString *beginDateStr = [beginDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *endDateStr = [endDate formattedDateWithFormat:@"yyyy-MM-dd"];
    
    [super request:SSJURLWithAPI(@"/user/sendChargeEmail.go") params:@{@"cuserId":SSJUSERID() ?: @"",
                                                                       @"beginDate":beginDateStr ?: @"",
                                                                       @"endDate":endDateStr ?: @"",
                                                                       @"email":email ?: @""}];
}

@end
