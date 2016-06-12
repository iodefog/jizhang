//
//  SSJReportFormsCurveModel.m
//  SuiShouJi
//
//  Created by old lang on 16/6/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveModel.h"

@implementation SSJReportFormsCurveModel

+ (instancetype)modelWithPayment:(NSString *)payment income:(NSString *)income time:(NSString *)time period:(SSJDatePeriod *)period {
    SSJReportFormsCurveModel *model = [[SSJReportFormsCurveModel alloc] init];
    model.payment = payment;
    model.income = income;
    model.time = time;
    model.period = period;
    return model;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@>:%@", self, @{@"payment":_payment,
                                                          @"income":_income,
                                                          @"time":_time,
                                                          @"period":_period}];
}


@end
