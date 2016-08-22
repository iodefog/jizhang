//
//  SSJMagicExportCalendarView.h
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const SSJMagicExportCalendarViewBeginDateKey;
extern NSString *const SSJMagicExportCalendarViewEndDateKey;

@class SSJDatePeriod;
@class SSJMagicExportCalendarView;

@protocol SSJMagicExportCalendarViewDelegate <NSObject>

/**
 *  返回日历显示的日期范围，返回的字典中定义了两个key：
 *  SSJMagicExportCalendarViewBeginDateKey对应的值是开始日期；
 *  SSJMagicExportCalendarViewEndDateKey对应的值是结束日期；
 *  日历展示的范围从开始日期当月第一天开始，到结束日期当月的最后一天结束
 *
 *  @param dates 存储要取消选中日期的数据
 *
 *  @return (void)
 */
- (NSDictionary<NSString *, NSDate *>*)periodForCalendarView:(SSJMagicExportCalendarView *)calendarView;

/**
 *  根据返回值决定是否显示日期下的星号
 *
 *  @param calendarView 日期控件对象
 *  @param date 显示星号对应的日期
 *
 *  @return (BOOL)
 */
- (BOOL)calendarView:(SSJMagicExportCalendarView *)calendarView shouldShowMarkerForDate:(NSDate *)date;

/**
 *  返回对应日期下的标注文字
 *
 *  @param calendarView 日期控件对象
 *  @param date 显示标注文字对应的日期
 *
 *  @return (NSString *)
 */
- (NSString *)calendarView:(SSJMagicExportCalendarView *)calendarView descriptionForSelectedDate:(NSDate *)date;

/**
 *  返回对应日期的文字颜色
 *
 *  @param calendarView 日期控件对象
 *  @param date 对应的日期
 *
 *  @return (UIColor *)
 */
- (UIColor *)calendarView:(SSJMagicExportCalendarView *)calendarView colorForDate:(NSDate *)date;

/**
 *  根据返回值决定是否可以选中对应的日期；默认返回YES，如果返回YES，则执行方法calendarView:didSelectDate:
 *
 *  @param calendarView 日期控件对象
 *  @param date 对应的日期
 *
 *  @return (BOOL)
 */
- (BOOL)calendarView:(SSJMagicExportCalendarView *)calendarView shouldSelectDate:(NSDate *)date;

/**
 *  选中对应日期执行的方法
 *
 *  @param calendarView 日期控件对象
 *  @param date 选中的日期
 *
 *  @return (void)
 */
- (void)calendarView:(SSJMagicExportCalendarView *)calendarView didSelectDate:(NSDate *)date;

@end


@interface SSJMagicExportCalendarView : UIView

// 代理对象
@property (nonatomic, weak) id<SSJMagicExportCalendarViewDelegate> delegate;

// 选中的日期字体颜色
@property (nonatomic, strong) UIColor *selectedDateColor;

// 选中的日期背景颜色、为选中的星号颜色、选中后日期下的标注字体颜色（即方法calendarView:descriptionForSelectedDate:返回的文字的颜色）
@property (nonatomic, strong) UIColor *highlightColor;

// 选中的日期
@property (nullable, nonatomic, strong) NSArray<NSDate *> *selectedDates;

/**
 *  重载数据，会依次调用
 *  periodForCalendarView:、
 *  calendarView:descriptionForSelectedDate:、
 *  calendarView:descriptionForSelectedDate:、
 *  calendarView:colorForDate:
 *
 *  @return (void)
 */
- (void)reload;

/**
 *  取消选中数组dates中的日期，此方法会比调用reload取消选中日期高效一些
 *
 *  @param dates 存储要取消选中日期的数据
 *
 *  @return (void)
 */
- (void)deselectDates:(NSArray<NSDate *> *)dates;

/**
 *  将特定的日期呈现在显示范围内
 *
 *  @param date 显示在可视范围内的日期
 */
- (void)scrollToDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END