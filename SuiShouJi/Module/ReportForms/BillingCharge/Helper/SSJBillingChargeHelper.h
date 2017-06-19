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

// 对应日期的key
extern NSString *const SSJBillingChargeDateKey;

// 对应总金额的key
extern NSString *const SSJBillingChargeSumKey;

// 对应记账流水模型的key
extern NSString *const SSJBillingChargeRecordKey;

@interface SSJBillingChargeHelper : NSObject

/**
 查询单个账本（共享、个人）的流水列表

 @param memberId 成员id，如果为nil就认为是当前登录用户，如果为SSJAllMembersId，就是所有成员
 @param booksId 账本id，如果为nil，就取当前账本
 @param billId 收支类别id，如果为nil，就查询所有类别流水
 @param billType 收支类型（收入、支出），指定查询收入还是支出流水，如果要查询所有流水，就传SSJBillTypeSurplus；如果传了billId，就不需要传入此参数
 @param period 查询指定时间范围内的流水
 @param success 查询成功的回调；参数data中是数组类型，每个元素对应一个section；
                元素字典结构：@{SSJBillingChargeDateKey:流水日起字符串，
                             SSJBillingChargeSumKey:流水统计金额,
                             SSJBillingChargeRecordKey:@[SSJBillingChargeCellItem实例...]}

 @param failure 失败的回调
 */
+ (void)queryChargeListWithMemberId:(nullable NSString *)memberId
                            booksId:(nullable NSString *)booksId
                             billId:(nullable NSString *)billId
                             period:(nullable SSJDatePeriod *)period
                            success:(void (^)(NSArray<NSDictionary *> *result))success
                            failure:(nullable void (^)(NSError *error))failure;

/**
 查询单个账本（共享、个人）的流水列表
 
 @param memberId 成员id，如果为nil就认为是当前登录用户，如果为SSJAllMembersId，就是所有成员
 @param booksId 账本id，如果为nil，就取当前账本
 @param billName 收支类别名称，如果为nil，就查询任何名称流水
 @param billType 收支类型（收入、支出），指定查询收入还是支出流水，如果要查询所有流水，就传SSJBillTypeSurplus；
 @param period 查询指定时间范围内的流水
 @param success 查询成功的回调；参数data中是数组类型，每个元素对应一个section；
                元素字典结构：@{SSJBillingChargeDateKey:流水日起字符串，
                             SSJBillingChargeSumKey:流水统计金额,
                             SSJBillingChargeRecordKey:@[SSJBillingChargeCellItem实例...]}
 
 @param failure 失败的回调
 */
+ (void)queryChargeListWithMemberId:(nullable NSString *)memberId
                            booksId:(nullable NSString *)booksId
                           billName:(nullable NSString *)billName
                           billType:(SSJBillType)billType
                             period:(nullable SSJDatePeriod *)period
                            success:(void (^)(NSArray<NSDictionary *> *data))success
                            failure:(nullable void (^)(NSError *error))failure;

/**
 查询所有账本中指定类别的流水

 @param billId 要查询流水的类别
 @param period 查询指定时间范围内的流水
 @param success 查询成功的回调；参数data中是数组类型，每个元素对应一个section；
                元素字典结构：@{SSJBillingChargeDateKey:流水日起字符串，
                             SSJBillingChargeSumKey:流水统计金额,
                             SSJBillingChargeRecordKey:@[SSJBillingChargeCellItem实例...]}
 
 @param failure 失败的回调
 */
+ (void)queryAllBooksChargeListBillId:(NSString *)billId
                               period:(nullable SSJDatePeriod *)period
                              success:(void (^)(NSArray<NSDictionary *> *result))success
                              failure:(nullable void (^)(NSError *error))failure;

/**
 *  查询剩余流水数量
 *
 *  @param billId           类别id
 *  @param memberId         成员id
 *  @param booksId          账本id，如果传nil就当做当前账本，查询所有账本数据传SSJAllBooksIds
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

