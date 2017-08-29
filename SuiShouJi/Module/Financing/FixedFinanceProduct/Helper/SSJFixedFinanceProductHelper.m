//
//  SSJFixedFinanceProductHelper.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanceProductHelper.h"

@implementation SSJFixedFinanceProductHelper
/**
 计算每日利息
 
 @param model 借贷模型，根据rate、interestType两个属性计算利息
 @return 计算结果
 */
+ (double)caculateInterestForEveryDayWithRate:(double)rate interstType:(SSJMethodOfRateOrTime)rateType money:(double)money {
    double dayRate = rate * money * 0.01;
    switch (rateType) {
        case SSJMethodOfRateOrTimeDay:
            return dayRate;
            break;
        case SSJMethodOfRateOrTimeMonth:
            return dayRate / 30;
            break;
        case SSJMethodOfRateOrTimeYear:
            return dayRate / 365;
            break;
            
        default:
            break;
    }
    return 0;
}

@end
