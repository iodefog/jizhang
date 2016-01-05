//
//  SSJFundingDetailHelper.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

//  对应日期的key
extern NSString *const SSJFundingDetailDateKey;

//  对应记账流水模型的key
extern NSString *const SSJFundingDetailRecordKey;

//  对应总和的key
extern NSString *const SSJFundingDetailSumKey;


@interface SSJFundingDetailHelper : NSObject

/**
 *  查询某个年份、月份的记账流水数据；如果月份传0，则查询整年的数据；月份最大不能超过12，年份小于1，否则返回nil
 *
 *  @param inYear    查询的年份，必须大于0
 *  @param month     查询的月份，如果月份传0，则查询整年的数据，最大不能超过12
 *  @param success   查询成功的回调；参数data中是字典类型，有两个key：SSJBillingChargeDateKey对应字符串，SSJBillingChargeRecordKey对应数组，数组中元素是SSJBillingChargeCellItem类型
 *  @param failure   查询失败的回调
 */
+ (void)queryDataWithFundTypeID:(NSString *)ID
                         InYear:(NSInteger)year
                          month:(NSInteger)month
                        success:(void (^)(NSArray <NSDictionary *>*data))success
                        failure:(void (^)(NSError *error))failure;

@end
