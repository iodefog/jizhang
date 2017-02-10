//
//  SSJFundingTransferListStore.h
//  SuiShouJi
//
//  Created by ricky on 16/5/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJFundingTransferDetailItem.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *SSJFundingTransferStoreMonthKey;
extern NSString *SSJFundingTransferStoreListKey;

@interface SSJFundingTransferStore : NSObject

/**
 *  查询转账的列表
 *
 *  @param success 查询成功的回调
 *  @param failure 查询失败的回调
 */
+ (void)queryForFundingTransferListWithSuccess:(nullable void(^)(NSArray <NSDictionary *>*result))success
                                       failure:(nullable void (^)(NSError *error))failure;

/**
 *  删除某条转账
 *
 *  @param success 查询成功的回调
 *  @param failure 查询失败的回调
 */
+ (void)deleteFundingTransferWithItem:(SSJFundingTransferDetailItem *)item
                              Success:(nullable void(^)())success
                              failure:(nullable void (^)(NSError *error))failure;

/**
 新建或编辑周期转账，根据转账id判断此记录如果存在就编辑，反之就新建

 @param ID 转账id
 @param transferOutAccountId 转出账户id
 @param transferInAccountId 转入账户id
 @param money 转账金额
 @param memo 转账备注
 @param cyclePeriodType 周期转账类型
 @param beginDate cyclePeriodType如果是SSJCyclePeriodTypeOnce，就是转账日期；如果是其他值，就是起始日期
 @param endDate cyclePeriodType如果是SSJCyclePeriodTypeOnce，就不需要传值；如果是其他值，就是结束日期
 @param success 成功回调；isExisted参数表示存储这条记录前是否已经存在
 @param failure 失败回调
 */
+ (void)saveCycleTransferRecordWithID:(NSString *)ID
                  transferInAccountId:(NSString *)transferInAccountId
                 transferOutAccountId:(NSString *)transferOutAccountId
                                money:(float)money
                                 memo:(nullable NSString *)memo
                      cyclePeriodType:(SSJCyclePeriodType)cyclePeriodType
                            beginDate:(NSString *)beginDate
                              endDate:(nullable NSString *)endDate
                              success:(nullable void (^)(BOOL isExisted))success
                              failure:(nullable void (^)(NSError *error))failure;

/**
 删除周期转账

 @param ID 周期转账id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)deleteCycleTransferRecordWithID:(NSString *)ID
                                success:(nullable void (^)())success
                                failure:(nullable void (^)(NSError *error))failure;

/**
 更新周期记账的开关状态

 @param ID 周期转账id
 @param opened 是否开启
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)updateCycleTransferRecordStateWithID:(NSString *)ID
                                      opened:(BOOL)opened
                                     success:(nullable void (^)())success
                                     failure:(nullable void (^)(NSError *error))failure;

/**
 查询周期转账列表；
 查询结果数据结构：
 @[@{SSJFundingTransferStoreMonthKey:NSDate,
     SSJFundingTransferStoreListKey:@[SSJFundingTransferDetailItem, ...]}, ...]

 @param success 成功回调
 @param failure 失败回调
 */
+ (void)queryCycleTransferRecordsListWithSuccess:(nullable void (^)(NSArray <NSDictionary *>*))success
                                         failure:(nullable void (^)(NSError *error))failure;


@end

NS_ASSUME_NONNULL_END
