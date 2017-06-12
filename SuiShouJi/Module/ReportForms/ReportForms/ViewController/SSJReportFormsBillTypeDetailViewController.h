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

// --------------------------- 个人账本 ---------------------------//
/**
 收支类别id，如果传了此属性，就不需要传billName
 */
@property (nonatomic, strong, nullable) NSString *billTypeID;
// --------------------------------------------------------------//


// --------------------------- 共享账本 ---------------------------//
/**
 收支类别名称，如果传此属性，就不需要传billName
 */
@property (nonatomic, strong, nullable) NSString *billName;
// --------------------------------------------------------------//

/**
 收支类型
 */
@property (nonatomic) SSJBillType billType;

/**
 颜色值
 */
@property (nonatomic, copy) NSString *colorValue;

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
