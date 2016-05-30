//
//  SSJReportFormsUtil.h
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJReportFormsItem.h"
#import "SSJDatePeriod.h"

///---------------------------------------------------------------------------------------------
/// ****  数据库查询工具类  **** //
///---------------------------------------------------------------------------------------------

@interface SSJReportFormsDatabaseUtil : NSObject

/**
 *  查询所有有效的收入／支出／结余流水纪录的年份、月份列表；
 *
 *  @param type      查询的类型
 *  @param success   查询成功的回调
 *  @param failure   查询失败的回调
 */
+ (void)queryForPeriodListWithIncomeOrPayType:(SSJBillType)type
                                      success:(void (^)(NSArray<SSJDatePeriod *> *))success
                                      failure:(void (^)(NSError *))failure;

/**
 *  查询某个时间段内有效的收入／支出／结余流水纪录
 *
 *  @param type         查询的类型
 *  @param startDate    开始时间
 *  @param endDate      结束时间
 *  @param success      查询成功的回调
 *  @param failure      查询失败的回调
 */
+ (void)queryForIncomeOrPayType:(SSJBillType)type
                      startDate:(NSDate *)startDate
                        endDate:(NSDate *)endDate
                        success:(void(^)(NSArray<SSJReportFormsItem *> *result))success
                        failure:(void (^)(NSError *error))failure;

@end

///---------------------------------------------------------------------------------------------
/// ****  日历工具类  **** //
///---------------------------------------------------------------------------------------------

@interface SSJReportFormsCalendarUtil : NSObject

// 更改后的月份
@property (nonatomic) NSInteger year;

// 更改后的年份
@property (nonatomic) NSInteger month;

// 当前时间年份
- (NSInteger)currentYear;

// 当前时间月份
- (NSInteger)currentMonth;

// 下一年
- (NSInteger)nextYear;

// 上一年
- (NSInteger)preYear;

// 下个月，如果横跨一年，则年份自动递增，最大年份不超过今年
- (NSInteger)nextMonth;

// 上个月，如果横跨一年，则年份自动递减
- (NSInteger)preMonth;

@end