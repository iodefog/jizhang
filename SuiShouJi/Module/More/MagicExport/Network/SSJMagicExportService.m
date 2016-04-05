//
//  SSJMagicExportService.m
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportService.h"

@implementation SSJMagicExportService

- (void)exportWithBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate emailAddress:(NSString *)email {
    NSString *beginDateStr = [beginDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *endDateStr = [endDate formattedDateWithFormat:@"yyyy-MM-dd"];
    [super request:SSJURLWithAPI(@"/user/sendChargeEmail.go") params:@{@"cuserId":SSJUSERID(),
                                                                       @"beginDate":beginDateStr,
                                                                       @"endDate":endDateStr,
                                                                       @"email":email}];
}

//- (void)requestDidFinish:(NSDictionary *)rootElement {
//    [super requestDidFinish:rootElement];
//}

@end
