//
//  SSJHomeCalendarView.h
//  SuiShouJi
//
//  Created by yi cai on 2017/2/8.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SSJDatePickerMode) {
    SSJDatePickerModeTime,//时、分、AM／PM标志(可选)-系统
    SSJDatePickerModeDate,//年，月，日-系统
    SSJDatePickerModeDateAndTime,//月、日、星期，时间的时、分、AM／PM标志(可选)-系统
    SSJDatePickerModeYearDateAndTime//年，月、日、星期，时间的时、分-自定义
};

//typedef NS_OPTIONS(NSInteger, SSJDatePickerComponent) {
//    SSJDatePickerComponentYear = 1 << 0,
//    SSJDatePickerComponentMonth = 1 << 1,
//    SSJDatePickerComponentDay = 1 << 2,
//    SSJDatePickerComponentHour = 1 << 3,
//    SSJDatePickerComponentMinute = 1 << 4
//};

@class SSJHomeDatePickerViewButtonItem;

@interface SSJHomeDatePickerView : UIControl

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

@property (nonatomic, copy) BOOL(^shouldConfirmBlock)(SSJHomeDatePickerView *view, NSDate *selecteDate);

//选择日期按钮返回选中的时间
@property (nonatomic, copy) void(^confirmBlock)(SSJHomeDatePickerView *view);

@property (nonatomic, copy) void(^closeBlock)(SSJHomeDatePickerView *view);

/**
 背景颜色
 */
@property (nonatomic, copy, nullable) NSString *bgColor;
/**
 分割线颜色
 */
@property (nonatomic, copy, nullable) NSString *separatorColor;
/**
 主色调
 */
@property (nonatomic, copy, nullable) NSString *mainColor;
/**
 警告日期（用户选择了日期大于这个日期就会提醒用户无法选择）
 */
@property (nonatomic, strong, nullable) NSDate *warningDate;
/**
 警告提醒
 */
@property (nonatomic, copy, nullable) NSString *warningString;

// 自定义左侧按钮，默认nil，如果有值，就取代默认的取消按钮
@property (nonatomic, strong, nullable) SSJHomeDatePickerViewButtonItem *leftButtonItem;

// 自定义右侧按钮，默认nil，如果有值，就取代默认的确认按钮
@property (nonatomic, strong, nullable) SSJHomeDatePickerViewButtonItem *rightButtonItem;

//- (void)setTitleColor:(UIColor *)color forComponent:(SSJDatePickerComponent)component;
//
//- (void)setFillColor:(UIColor *)color forComponent:(SSJDatePickerComponent)component;

- (void)show;

- (void)dismiss;

@end

@interface SSJHomeDatePickerViewButtonItem : NSObject

@property (nonatomic, strong, nullable) NSString *title;

@property (nonatomic, strong, nullable) UIColor *titleColor;

@property (nonatomic, strong, nullable) UIImage *image;

+ (instancetype)buttonItemWithTitle:(nullable NSString *)title
                         titleColor:(nullable UIColor *)titleColor
                              image:(nullable UIImage *)image;

@end

NS_ASSUME_NONNULL_END
