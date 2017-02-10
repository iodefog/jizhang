//
//  SSJHomeCalendarView.h
//  SuiShouJi
//
//  Created by yi cai on 2017/2/8.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, SSJDatePickerMode) {
    SSJDatePickerModeTime,//时、分、AM／PM标志(可选)-系统
    SSJDatePickerModeDate,//年，月，日-系统
    SSJDatePickerModeDateAndTime,//月、日、星期，时间的时、分、AM／PM标志(可选)-系统
    SSJDatePickerModeYearDateAndTime//年，月、日、星期，时间的时、分-自定义
};

typedef NS_OPTIONS(NSInteger, SSJDatePickerComponent) {
    SSJDatePickerComponentYear = 1 << 0,
    SSJDatePickerComponentMonth = 1 << 1,
    SSJDatePickerComponentDay = 1 << 2,
    SSJDatePickerComponentHour = 1 << 3,
    SSJDatePickerComponentMinute = 1 << 4
};

@interface SSJHomeCalendarView : UIControl

//@property (nonatomic) SSJDatePickerMode datePickerMode;

@property (nonatomic, strong) NSDate *date;
/**
 最小时间默认年份在2001-2038之间
 */
@property (nonatomic, strong) NSDate *minDate;
/**
 最大时间默认年份在2001-2038之间
 */
@property (nonatomic, strong) NSDate *maxDate;

//显示，消失
@property (nonatomic, copy) void(^dismissBlock)();
@property (nonatomic, copy) void(^showBlock)();

/**
 背景颜色
 */
@property (nonatomic, copy) NSString *bgColor;
/**
 分割线颜色
 */
@property (nonatomic, copy) NSString *separatorColor;
/**
 主色调
 */
@property (nonatomic, copy) NSString *mainColor;

//选择日期按钮返回选中的时间
@property (nonatomic, copy) void(^confirmBlock)(NSDate *selecteDate);

- (void)setTitleColor:(UIColor *)color forComponent:(SSJDatePickerComponent)component;

- (void)setFillColor:(UIColor *)color forComponent:(SSJDatePickerComponent)component;

- (void)show;
- (void)dismiss;
@end
