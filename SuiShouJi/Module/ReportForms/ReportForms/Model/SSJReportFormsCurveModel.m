//
//  SSJReportFormsCurveModel.m
//  SuiShouJi
//
//  Created by old lang on 16/6/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveModel.h"

@implementation SSJReportFormsCurveModel

+ (instancetype)modelWithPayment:(double)payment
                          income:(double)income
                       startDate:(NSDate *)startDate
                         endDate:(NSDate *)endDate {
    
    SSJReportFormsCurveModel *model = [[SSJReportFormsCurveModel alloc] init];
    model.payment = payment;
    model.income = income;
    model.startDate = startDate;
    model.endDate = endDate;
    return model;
}

- (NSString *)debugDescription {
    return [self ssj_debugDescription];
}


@end
