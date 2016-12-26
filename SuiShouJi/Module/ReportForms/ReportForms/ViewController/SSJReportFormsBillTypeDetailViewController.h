//
//  SSJReportFormsBillTypeDetailViewController.h
//  SuiShouJi
//
//  Created by old lang on 16/12/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class SSJDatePeriod;

@interface SSJReportFormsBillTypeDetailViewController : SSJBaseViewController

/**
 收支类别id
 */
@property (nonatomic, strong) NSString *billTypeID;

/**
 默认的自定义时间周期
 */
@property (nonatomic, copy, nullable) SSJDatePeriod *customPeriod;

/**
 默认选中的时间周期
 */
@property (nonatomic, copy, nullable) SSJDatePeriod *selectedPeriod;

@end

NS_ASSUME_NONNULL_END
