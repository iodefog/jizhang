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
 *  查询某个年份、月份的记账流水数据；如果月份传0，则查询整年的数据；月份最大不能超过12，年份小于1，否则返回nil
 *  如果是当前年或月，就查询截止到当天的数据
 *
 *  @param inYear    查询的年份，如果传0，则查询所有年份的数据
 *  @param month     查询的月份，如果传0，则查询整年的数据，最大不能超过12
 *  @param success   查询成功的回调；参数data中是字典类型，有两个key：SSJBillingChargeDateKey对应日期字符串，SSJBillingChargeRecordKey对应数组，数组中元素是SSJBillingChargeCellItem类型实例
 *  @param failure   查询失败的回调
 */
+ (void)queryDataWithBillTypeID:(NSString *)ID
                       inPeriod:(SSJDatePeriod *)period
                        success:(void (^)(NSArray <NSDictionary *>*data))success
                        failure:(void (^)(NSError *error))failure;

@end
