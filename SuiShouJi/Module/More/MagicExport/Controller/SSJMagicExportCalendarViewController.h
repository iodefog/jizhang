//
//  SSJMagicExportCalendarViewController.h
//  SuiShouJi
//
//  Created by old lang on 16/4/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSJMagicExportCalendarViewController : SSJBaseViewController

// 日历开始的日期
@property (nonatomic, strong) NSDate *beginDate;

// 日历结束的日期
@property (nonatomic, strong) NSDate *endDate;

// 选中的开始日期
@property (nonatomic, strong, readonly) NSDate *selectBeginDate;

// 选中的结束日期
@property (nonatomic, strong, readonly) NSDate *selectEndDate;

// 选择日期完成的回调
@property (nonatomic, copy) void (^completion)(SSJMagicExportCalendarViewController *);

@end

NS_ASSUME_NONNULL_END