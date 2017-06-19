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

@protocol SSJMagicExportCalendarViewDataSource <NSObject>

@required
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

@optional

/**
 *  根据返回值决定是否显示日期下的星号
 *
 *  @param calendarView 日期控件对象
 *  @param date 显示星号对应的日期
 *
 *  @return (BOOL)
 */
- (BOOL)calendarView:(SSJMagicExportCalendarView *)calendarView shouldShowMarkerForDate:(NSDate *)date;

@end

@protocol SSJMagicExportCalendarViewDelegate <NSObject>

@optional
/**
 *  根据返回值决定是否可以选中对应的日期；默认返回YES，如果返回YES，则执行方法calendarView:willSelectDate:和calendarView:didSelectDate:
 *
 *  @param calendarView 日期控件对象
 *  @param date 对应的日期
 *
 *  @return (BOOL)
 */
- (BOOL)calendarView:(SSJMagicExportCalendarView *)calendarView shouldSelectDate:(NSDate *)date;

/**
 *  将要选中对应日期执行的方法，
 *
 *  @param calendarView 日期控件对象
 *  @param date 选中的日期
 *
 *  @return (void)
 */
- (void)calendarView:(SSJMagicExportCalendarView *)calendarView willSelectDate:(NSDate *)date;

/**
 *  已经选中对应日期执行的方法
 *
 *  @param calendarView 日期控件对象
 *  @param date 选中的日期
 *
 *  @return (void)
 */
- (void)calendarView:(SSJMagicExportCalendarView *)calendarView didSelectDate:(NSDate *)date;

/**
 *  返回对应日期的文字颜色
 *
 *  @param calendarView 日期控件对象
 *  @param date 对应的日期
 *
 *  @return (UIColor *)
 */
- (UIColor *)calendarView:(SSJMagicExportCalendarView *)calendarView titleColorForDate:(NSDate *)date selected:(BOOL)selected;

/**
 返回对应日期的标注文案颜色，如果实现此方法就忽略markerColor
 
 @param calendarView 日期控件对象
 @param date 对应的日期
 @return (UIColor *)
 */
- (UIColor *)calendarView:(SSJMagicExportCalendarView *)calendarView markerColorForDate:(NSDate *)date selected:(BOOL)selected;

/**
 返回对应日期的标注文字颜色，如果实现此方法就忽略descriptionColor
 
 @param calendarView 日期控件对象
 @param date 显示标注文字对应的日期
 @return (UIColor *)
 */
- (UIColor *)calendarView:(SSJMagicExportCalendarView *)calendarView descriptionColorForDate:(NSDate *)date selected:(BOOL)selected;

/**
 日期的填充颜色，如果实现此方法就忽略fillColor
 
 @param calendarView 日期控件对象
 @param date 对应的日期
 @return (UIColor *)
 */
- (UIColor *)calendarView:(SSJMagicExportCalendarView *)calendarView fillColorForSelectedDate:(NSDate *)date;

/**
 *  返回选中日期下的标注文字
 *
 *  @param calendarView 日期控件对象
 *  @param date 显示标注文字对应的日期
 *
 *  @return (NSString *)
 */
- (NSString *)calendarView:(SSJMagicExportCalendarView *)calendarView descriptionForSelectedDate:(NSDate *)date;

@end


@interface SSJMagicExportCalendarView : UIView

/**
 数据源对象
 */
@property (nonatomic, weak) id<SSJMagicExportCalendarViewDataSource> dataSource;

/**
 代理对象
 */
@property (nonatomic, weak, nullable) id<SSJMagicExportCalendarViewDelegate> delegate;

/**
 日期字体颜色，如果代理对象实现了方法calendarView:titleColorForDate:selected:，就忽略此属性
 */
@property (nonatomic, strong) UIColor *dateColor;

/**
 标注文案颜色颜色，如果代理对象实现了方法calendarView:markerColorForDate:selected:，就忽略此属性
 */
@property (nonatomic, strong) UIColor *markerColor;

/**
 标注文字颜色颜色，如果代理对象实现了方法calendarView:descriptionColorForDate:selected:，就忽略此属性
 */
@property (nonatomic, strong) UIColor *descriptionColor;

/**
 日期的填充颜色，如果代理对象实现了方法calendarView:fillColorForDate:selected:，就忽略此属性
 */
@property (nonatomic, strong) UIColor *fillColor;

// 选中的日期
@property (nullable, nonatomic, strong) NSArray<NSDate *> *selectedDates;

/**
 *  重载数据，会依次调用
 *  periodForCalendarView:、
 *  calendarView:titleColorForDate:
 *  calendarView:descriptionForDate:、
 *  calendarView:shouldShowMarkerForDate:、
 *
 *  @return (void)
 */
- (void)reloadData;

/**
 <#Description#>

 @param date <#date description#>
 */
- (void)reloadDates:(NSArray<NSDate *> *)dates;

/**
 <#Description#>

 @param dates <#dates description#>
 */
- (void)selectDates:(NSArray<NSDate *> *)dates;

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
- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated;

@end



@interface SSJMagicExportCalendarView (SSJTheme)

- (void)updateAppearance;

@end

NS_ASSUME_NONNULL_END
