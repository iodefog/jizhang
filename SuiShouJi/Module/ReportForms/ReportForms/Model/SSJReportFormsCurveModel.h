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

@property (nonatomic, copy) NSString *payment;

@property (nonatomic, copy) NSString *income;

@property (nonatomic, copy) NSString *time;

@property (nonatomic, strong) SSJDatePeriod *period;

+ (instancetype)modelWithPayment:(NSString *)payment
                          income:(NSString *)income
                            time:(NSString *)time
                          period:(SSJDatePeriod *)period;

@end
