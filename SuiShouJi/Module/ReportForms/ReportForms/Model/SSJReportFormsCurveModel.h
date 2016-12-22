//
//  SSJReportFormsCurveModel.h
//  SuiShouJi
//
//  Created by old lang on 16/6/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJDatePeriod;

@interface SSJReportFormsCurveModel : NSObject

@property (nonatomic) double payment;

@property (nonatomic) double income;

@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, strong) NSDate *endDate;

+ (instancetype)modelWithPayment:(double)payment
                          income:(double)income
                       startDate:(NSDate *)startDate
                         endDate:(NSDate *)endDate;

@end
