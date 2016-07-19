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

- (NSDictionary<NSString *, NSDate *>*)periodForCalendarView:(SSJMagicExportCalendarView *)calendarView;

- (BOOL)calendarView:(SSJMagicExportCalendarView *)calendarView shouldShowMarkerForDate:(NSDate *)date;

- (NSString *)calendarView:(SSJMagicExportCalendarView *)calendarView descriptionForSelectedDate:(NSDate *)date;

- (UIColor *)calendarView:(SSJMagicExportCalendarView *)calendarView colorForDate:(NSDate *)date;

- (BOOL)calendarView:(SSJMagicExportCalendarView *)calendarView shouldSelectDate:(NSDate *)date;

- (void)calendarView:(SSJMagicExportCalendarView *)calendarView didSelectDate:(NSDate *)date;

@end


@interface SSJMagicExportCalendarView : UIView

@property (nonatomic, weak) id<SSJMagicExportCalendarViewDelegate> delegate;

@property (nonatomic, strong) UIColor *selectedDateColor;

@property (nonatomic, strong) UIColor *highlightColor;

@property (nullable, nonatomic, strong) NSArray<NSDate *> *selectedDates;

- (void)reload;

- (void)deselectDates:(NSArray<NSDate *> *)dates;

- (void)scrollToDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END