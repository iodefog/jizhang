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

@property (nonatomic) SSJDatePickerMode datePickerMode;
@property (nonatomic, strong) NSDate *date;
/**
 最小时间默认年份在2001-2038之间
 */
@property (nonatomic, strong) NSDate *minDate;
/**
 最大时间默认年份在2001-2038之间
 */
@property (nonatomic, strong) NSDate *maxDate;
//- (void)setDate:(NSDate *)date animated:(BOOL)animated;

- (void)setTitleColor:(UIColor *)color forComponent:(SSJDatePickerComponent)component;

- (void)setFillColor:(UIColor *)color forComponent:(SSJDatePickerComponent)component;

@end
