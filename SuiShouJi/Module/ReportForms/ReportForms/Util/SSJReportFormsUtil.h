//
//  SSJReportFormsUtil.h
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJReportFormsItem.h"

///---------------------------------------------------------------------------------------------
/// ****  数据库查询工具类  **** //
///---------------------------------------------------------------------------------------------

typedef NS_ENUM(NSUInteger, SSJReportFormsIncomeOrPayType) {
    SSJReportFormsIncomeOrPayTypeUnknown,   // 未知
    SSJReportFormsIncomeOrPayTypeIncome,    // 收入
    SSJReportFormsIncomeOrPayTypePay,       // 支出
    SSJReportFormsIncomeOrPayTypeSurplus    // 盈余
};

@interface SSJReportFormsDatabaseUtil : NSObject

// 查询某个年份、月份的收入／支出／盈余的收支类型数据；如果月份传0，则查询整年的数据；月份最大不能超过12，年份小于1，否则返回nil
+ (NSArray<SSJReportFormsItem *> *)queryForIncomeOrPayType:(SSJReportFormsIncomeOrPayType)type inYear:(NSInteger)year month:(NSInteger)month;

@end

///---------------------------------------------------------------------------------------------
/// ****  日历工具类  **** //
///---------------------------------------------------------------------------------------------

@interface SSJReportFormsCalendarUtil : NSObject

// 更改后的月份
@property (nonatomic) NSInteger year;

// 更改后的年份
@property (nonatomic) NSInteger month;

// 当前年份
- (NSInteger)currentYear;

// 当前月份
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