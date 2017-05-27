//
//  SSJBillingChargeHelper.h
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJDatePeriod;

NS_ASSUME_NONNULL_BEGIN

//  对应日期的key
extern NSString *const SSJBillingChargeDateKey;

//  对应总金额的key
extern NSString *const SSJBillingChargeSumKey;

//  对应记账流水模型的key
extern NSString *const SSJBillingChargeRecordKey;

@interface SSJBillingChargeHelper : NSObject

/**
 *  查询某个个人账本的指定类别名字的流水数据；
 *
 *  @param ID           收支类别id
 *  @param booksId      账本id，如果传nil就当做当前账本
 *  @param period       查询的时间段，如果超过当前时间，则截止到今天
 *  @param success      查询成功的回调；参数data中是数组类型，元素对应一个section；
                        元素字典结构：@{SSJBillingChargeDateKey:流水日起字符串，
                        SSJBillingChargeSumKey:流水统计金额,
                        SSJBillingChargeRecordKey:@[SSJBillingChargeCellItem实例...]}
 *  @param failure      查询失败的回调
 */
+ (void)queryDataWithBillTypeID:(NSString *)ID
                        booksId:(nullable NSString *)booksId
                       inPeriod:(SSJDatePeriod *)period
                        success:(void (^)(NSArray <NSDictionary *>*data))success
                        failure:(nullable void (^)(NSError *error))failure;

/**
 查询某个共享账本的指定类别名字的流水数据；

 @param name 类别名字
 @param booksId 共享账本id
 @param period 查询的时间段，如果超过当前时间，则截止到今天
 @param success 查询成功的回调；参数data中是数组类型，元素对应一个section；
                元素字典结构：@{SSJBillingChargeDateKey:流水日起字符串， 
                             SSJBillingChargeSumKey:流水统计金额,
                             SSJBillingChargeRecordKey:@[SSJBillingChargeCellItem实例...]}
 @param failure 查询失败的回调
 */
+ (void)queryDataWithBillTypeName:(NSString *)name
                          booksId:(NSString *)booksId
                         inPeriod:(SSJDatePeriod *)period
                          success:(void (^)(NSArray <NSDictionary *>*data))success
                          failure:(void (^)(NSError *error))failure;

/**
 *  查询某个时间内的成员流水数据；
 *
 *  @param ID           成员id
 *  @param booksId      账本id，如果传nil就当做当前账本，查询所有账本数据传all
 *  @param period       查询的时间段，如果超过当前时间，则截止到今天
 *  @param isPayment    是否查询支出流水
 *  @param success      查询成功的回调；参数data中是数组类型，元素对应一个section；
                        元素字典结构：@{SSJBillingChargeDateKey:流水日起字符串，
                        SSJBillingChargeSumKey:流水统计金额,
                        SSJBillingChargeRecordKey:@[SSJBillingChargeCellItem实例...]}
 *  @param failure      查询失败的回调
 */
+ (void)queryMemberChargeWithMemberID:(NSString *)ID
                              booksId:(nullable NSString *)booksId
                             inPeriod:(SSJDatePeriod *)period
                            isPayment:(BOOL)isPayment
                              success:(void (^)(NSArray <NSDictionary *>*data))success
                              failure:(nullable void (^)(NSError *error))failure;

/**
 *  查询剩余流水数量
 *
 *  @param billId           类别id
 *  @param memberId         成员id
 *  @param booksId          账本id，如果传nil就当做当前账本，查询所有账本数据传all
 *  @param period           查询的时间段，如果超过当前时间，则截止到今天
 *  @param success          查询成功的回调
 *  @param failure          查询失败的回调
 */
+ (void)queryTheRestChargeCountWithBillId:(NSString *)billId
                                 memberId:(NSString *)memberId
                                  booksId:(nullable NSString *)booksId
                                   period:(SSJDatePeriod *)period
                                  success:(void(^)(int count))success
                                  failure:(nullable void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END

