//
//  SSJCalenderHelper.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SSJBillingChargeCellItem;

@interface SSJCalenderHelper : NSObject

/**
 *  查询某年某月的记账数据
 *
 *  @param year    所要查询的年
 *  @param month   所要查询的月
 *  @param success 查询成功的回调
 *  @param failure 查询失败的回调
 */
+ (void)queryDataInYear:(NSInteger)year
                  month:(NSInteger)month
                success:(void (^)(NSMutableDictionary *data))success
                failure:(void (^)(NSError *error))failure;

/**
 *  查询某一天的记账总额
 *
 *  @param date    要查询的日期 (格式 yyyy-MM-dd)
 *  @param success 查询成功的回调
 *  @param failure 查询失败的回调
 */
+ (void)queryBalanceForDate:(NSString*)date
                    success:(void (^)(double income , double expence))success
                    failure:(void (^)(NSError *error))failure;

/**
 *  查询流水详情
 *
 *  @param chargeId 流水id
 *  @param success 查询成功的回调
 *  @param failure 查询失败的回调
 */
+ (void)queryChargeDetailWithId:(NSString *)chargeId
                        success:(void (^)(SSJBillingChargeCellItem *chargeItem))success
                        failure:(nullable void(^)(NSError *error))failure;

/**
 *
 *
 *  @param chargeId 流水id
 *  @param success 查询成功的回调
 *  @param failure 查询失败的回调
 */
+ (void)deleteChargeWithItem:(SSJBillingChargeCellItem *)item
                     success:(nullable void(^)())success
                     failure:(nullable void(^)(NSError *error))failure;

/**
 查询共享账本的

 @param booksId <#booksId description#>
 @param success <#success description#>
 @param failure <#failure description#>
 */
+ (void)queryShareBookStateWithBooksId:(NSString *)booksId
                              memberId:(NSString *)memberId
                               success:(void(^)(SSJShareBooksMemberState state))success
                               failure:(nullable void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
