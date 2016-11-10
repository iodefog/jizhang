//
//  SSJBillingChargeHelper.h
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJDatePeriod;

//  对应日期的key
extern NSString *const SSJBillingChargeDateKey;

//  对应总金额的key
extern NSString *const SSJBillingChargeSumKey;

//  对应记账流水模型的key
extern NSString *const SSJBillingChargeRecordKey;

@interface SSJBillingChargeHelper : NSObject

/**
 *  查询特定时间内的指定类别流水数据；
 *
 *  @param ID           收支类别id
 *  @param booksId      账本id，如果传nil就当做当前账本，查询所有账本数据传all
 *  @param period       查询的时间段，如果超过当前时间，则截止到今天
 *  @param success      查询成功的回调；参数data中是字典类型，有两个key：SSJBillingChargeDateKey对应日期字符串，SSJBillingChargeRecordKey对应数组，数组中元素是SSJBillingChargeCellItem类型实例
 *  @param failure      查询失败的回调
 */
+ (void)queryDataWithBillTypeID:(NSString *)ID
                        booksId:(NSString *)booksId
                       inPeriod:(SSJDatePeriod *)period
                        success:(void (^)(NSArray <NSDictionary *>*data))success
                        failure:(void (^)(NSError *error))failure;

/**
 *  查询某个时间内的成员流水数据；
 *
 *  @param ID           成员id
 *  @param period       查询的时间段，如果超过当前时间，则截止到今天
 *  @param isPayment    是否查询支出流水
 *  @param success      查询成功的回调；参数data中是字典类型，有两个key：SSJBillingChargeDateKey对应日期字符串，SSJBillingChargeRecordKey对应数组，数组中元素是SSJBillingChargeCellItem类型实例
 *  @param failure      查询失败的回调
 */
+ (void)queryMemberChargeWithMemberID:(NSString *)ID
                             inPeriod:(SSJDatePeriod *)period
                            isPayment:(BOOL)isPayment
                              success:(void (^)(NSArray <NSDictionary *>*data))success
                              failure:(void (^)(NSError *error))failure;

@end
