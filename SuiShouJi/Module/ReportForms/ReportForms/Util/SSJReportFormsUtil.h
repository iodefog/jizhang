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

extern NSString *const SSJReportFormsCurveModelListKey;
extern NSString *const SSJReportFormsCurveModelBeginDateKey;
extern NSString *const SSJReportFormsCurveModelEndDateKey;

@class SSJReportFormsCurveModel;

@interface SSJReportFormsUtil : NSObject

/**
 *  查询所有有效的收入／支出／结余流水纪录的年份、月份列表；
 *
 *  @param type      查询的类型
 *  @param booksId   账本id，如果传nil就当做当前账本，查询所有账本数据传all
 *  @param success   查询成功的回调
 *  @param failure   查询失败的回调
 */
+ (void)queryForPeriodListWithIncomeOrPayType:(SSJBillType)type
                                      booksId:(NSString *)booksId
                                      success:(void (^)(NSArray<SSJDatePeriod *> *))success
                                      failure:(void (^)(NSError *))failure;

/**
 *  查询某个时间段内有效的收入／支出／结余流水纪录
 *
 *  @param type         收入／支出／结余
 *  @param booksId      账本id，如果传nil就当做当前账本，查询所有账本数据传all
 *  @param startDate    开始时间
 *  @param endDate      结束时间
 *  @param success      查询成功的回调
 *  @param failure      查询失败的回调
 */
+ (void)queryForIncomeOrPayType:(SSJBillType)type
                        booksId:(NSString *)booksId
                      startDate:(NSDate *)startDate
                        endDate:(NSDate *)endDate
                        success:(void(^)(NSArray<SSJReportFormsItem *> *result))success
                        failure:(void (^)(NSError *error))failure;


/**
 *  查询某个时间段内有效的收入／支出流水统计
 *
 *  @param type         查询的类型，0:月 1:周
 *  @param startDate    开始时间
 *  @param endDate      结束时间
 *  @param booksId      账本id，如果传nil则当做当前账本，传all就是全部帐本
 *  @param success      查询成功的回调
 *  @param failure      查询失败的回调
 */
+ (void)queryForBillStatisticsWithType:(int)type
                             startDate:(NSDate *)startDate
                               endDate:(NSDate *)endDate
                               booksId:(NSString *)booksId
                               success:(void(^)(NSDictionary *result))success
                               failure:(void (^)(NSError *error))failure;

/**
 *  查询某个时间段内有效的收入／支出成员流水统计
 *
 *  @param type         查询的类型
 *  @param startDate    开始时间
 *  @param endDate      结束时间
 *  @param success      查询成功的回调
 *  @param failure      查询失败的回调
 */
+ (void)queryForMemberChargeWithType:(SSJBillType)type
                           startDate:(NSDate *)startDate
                             endDate:(NSDate *)endDate
                             success:(void (^)(NSArray <SSJReportFormsItem *> *result))success
                             failure:(void (^)(NSError *error))failure;

@end
