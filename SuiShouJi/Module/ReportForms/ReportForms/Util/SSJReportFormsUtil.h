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
 *  注意：如果指定所有账本，只会查询当前用户的数据，因为可能会包含共享账本，所以要排除其他人的数据；如果指定某个账本，则会查询该账本上的所有数据
 *
 *  @param type      查询的类型
 *  @param booksId   账本id，如果传nil就当做当前账本，查询所有账本数据传SSJAllBooksIds
 *  @param success   查询成功的回调
 *  @param failure   查询失败的回调
 */
+ (void)queryForPeriodListWithIncomeOrPayType:(SSJBillType)type
                                      booksId:(NSString *)booksId
                                      success:(void (^)(NSArray<SSJDatePeriod *> *))success
                                      failure:(void (^)(NSError *))failure;

/**
 *  查询某个时间段内有效的收入／支出／结余流水纪录
 *  注意：如果指定所有账本，只会查询当前用户的数据，因为可能会包含共享账本，所以要排除其他人的数据；如果指定某个账本，则会查询该账本上的所有数据
 *
 *  @param type         收入／支出／结余
 *  @param booksId      账本id，如果传nil就查询当前账本，查询所有账本数据传SSJAllBooksIds
 *  @param billTypeId   收支类别id，如果传nil就查询所有类别
 *  @param startDate    开始时间
 *  @param endDate      结束时间x
 *  @param success      查询成功的回调
 *  @param failure      查询失败的回调
 */
+ (void)queryForIncomeOrPayType:(SSJBillType)type
                        booksId:(NSString *)booksId
                      startDate:(NSDate *)startDate
                        endDate:(NSDate *)endDate
                        success:(void (^)(NSArray<SSJReportFormsItem *> *result))success
                        failure:(void (^)(NSError *error))failure;

/**
 *  查询某个时间段内有效的收入／支出成员流水统计；
 *  注意：不能查询所有账本
 *
 *  @param type         查询的类型
 *  @param booksId      账本id，如果传nil就查询当前账本
 *  @param startDate    开始时间
 *  @param endDate      结束时间
 *  @param success      查询成功的回调
 *  @param failure      查询失败的回调
 */
+ (void)queryForMemberChargeWithType:(SSJBillType)type
                             booksId:(NSString *)booksId
                           startDate:(NSDate *)startDate
                             endDate:(NSDate *)endDate
                             success:(void (^)(NSArray <SSJReportFormsItem *> *result))success
                             failure:(void (^)(NSError *error))failure;

/**
 根据收支类别名称查询默认的时间维度

 @param startDate 开始日期，传nil就没有开始日期限制
 @param endDate 结束日期，传nil就以当前时间作为结束日期限制
 @param booksId 账本id，传nil认为当前账本，SSJAllBooksIds所有账本
 @param billName 账本名称
 @param billType 收支类型
 @param success 成功回调，如果参数timeDimension是SSJTimeDimensionUnknown，说明期限内没有流水
 @param failure 失败回调
 */
+ (void)queryForDefaultTimeDimensionWithStartDate:(NSDate *)startDate
                                          endDate:(NSDate *)endDate
                                          booksId:(NSString *)booksId
                                         billName:(NSString *)billName
                                         billType:(SSJBillType)billType
                                          success:(void(^)(SSJTimeDimension timeDimension))success
                                          failure:(void (^)(NSError *error))failure;

/**
 根据收支类别id查询默认的时间维度

 @param startDate 开始日期，传nil就没有开始日期限制
 @param endDate 结束日期，传nil就以当前时间作为结束日期限制
 @param booksId 账本id，传nil认为当前账本，SSJAllBooksIds所有账本
 @param billTypeId   收支类别id，如果传nil就查询所有类别
 @param success 成功回调，如果参数timeDimension是SSJTimeDimensionUnknown，说明期限内没有流水
 @param failure 失败回调
 */
+ (void)queryForDefaultTimeDimensionWithStartDate:(NSDate *)startDate
                                          endDate:(NSDate *)endDate
                                          booksId:(NSString *)booksId
                                           billId:(NSString *)billId
                                          success:(void (^)(SSJTimeDimension timeDimension))success
                                          failure:(void (^)(NSError *error))failure;

/**
 根据收支类别名称查询某个时间段内有效的收入／支出流水统计

 @param dimension 查询数据的时间维度单位
 @param booksId 账本id，如果传nil则当做当前账本，传SSJAllBooksIds就是全部帐本
 @param billName 收支类别名称
 @param billType 收支类型
 @param startDate 开始时间，传nil就没有开始日期限制
 @param endDate 结束时间，传nil就以当前时间作为结束日期限制
 @param success 查询成功的回调；result结构：@{SSJReportFormsCurveModelListKey:@[SSJReportFormsCurveModel实例, ...],
                                          SSJReportFormsCurveModelBeginDateKey:NSDate起始时间,
                                          SSJReportFormsCurveModelEndDateKey:NSDate结束时间}
 @param failure 查询失败的回调
 */
+ (void)queryForBillStatisticsWithTimeDimension:(SSJTimeDimension)dimension
                                        booksId:(NSString *)booksId
                                       billName:(NSString *)billName
                                       billType:(SSJBillType)billType
                                      startDate:(NSDate *)startDate
                                        endDate:(NSDate *)endDate
                                        success:(void(^)(NSDictionary *result))success
                                        failure:(void (^)(NSError *error))failure;

/**
 *  根据收支类别id查询某个时间段内有效的收入／支出流水统计
 *
 *  @param dimension    查询数据的时间维度单位
 *  @param booksId      账本id，如果传nil则当做当前账本，传SSJAllBooksIds就是全部帐本
 *  @param billId   收支类别id，如果传nil就查询所有类别
 *  @param startDate    开始时间，传nil就没有开始日期限制
 *  @param endDate      结束时间，传nil就以当前时间作为结束日期限制
 *  @param success      查询成功的回调；result结构：@{SSJReportFormsCurveModelListKey:@[SSJReportFormsCurveModel实例, ...],
                                                  SSJReportFormsCurveModelBeginDateKey:NSDate起始时间,
                                                  SSJReportFormsCurveModelEndDateKey:NSDate结束时间}
 *  @param failure      查询失败的回调
 */
+ (void)queryForBillStatisticsWithTimeDimension:(SSJTimeDimension)dimension
                                        booksId:(NSString *)booksId
                                         billId:(NSString *)billId
                                      startDate:(NSDate *)startDate
                                        endDate:(NSDate *)endDate
                                        success:(void(^)(NSDictionary *result))success
                                        failure:(void (^)(NSError *error))failure;

@end
