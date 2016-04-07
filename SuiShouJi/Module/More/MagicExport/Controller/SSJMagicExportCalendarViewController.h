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

// 起始导出日期
@property (nonatomic, strong) NSDate *beginDate;

// 结束导出日期
@property (nonatomic, strong) NSDate *endDate;

// 选择日期完成的回调
@property (nonatomic, copy) void (^completion)(NSDate *selectedBeginDate, NSDate *selectedEndDate);

@end

NS_ASSUME_NONNULL_END