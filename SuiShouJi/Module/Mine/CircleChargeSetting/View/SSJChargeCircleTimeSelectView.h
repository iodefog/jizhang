//
//  SSJChargeCircleTimeSelectView.h
//  SuiShouJi
//
//  Created by ricky on 16/6/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJChargeCircleTimeSelectView : UIView

// 选择日期的回调
@property (nonatomic, copy) void (^timerSetBlock)(NSString *dateStr);

// 选择日期的回调
@property (nonatomic, copy) void (^clearButtonClickBlcok)();

// 选择的日期早于最小时间的回调
@property (nonatomic, copy) void (^timeIsTooEarlyBlock)();

// 选择的日期晚于最大时间的回调
@property (nonatomic, copy) void (^timeIsTooLateBlock)();

// 日期选择的最大时间
@property(nonatomic, strong) NSDate *maxDate;

// 日期选择的最小时间
@property(nonatomic, strong) NSDate *minimumDate;

// 是否需要清空按钮
@property(nonatomic) BOOL needClearButtonOrNot;

@property(nonatomic, strong) NSDate *currentDate;

-(void)show;
-(void)dismiss;
@end
