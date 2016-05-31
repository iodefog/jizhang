//
//  SSJBillingChargeViewController.h
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

//  记账流水
#import "SSJBaseViewController.h"

@class SSJDatePeriod;

NS_ASSUME_NONNULL_BEGIN

@interface SSJBillingChargeViewController : SSJBaseViewController

//  收支类型ID，必传
@property (nonatomic, copy) NSString *billTypeID;

//  查询周期内的流水
@property (nonatomic, strong) SSJDatePeriod *period;

//  收支类型的颜色
@property (nonatomic, strong) UIColor *color;

@end

NS_ASSUME_NONNULL_END