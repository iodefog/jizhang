//
//  SSJBookKeepingHomeHelper.h
//  SuiShouJi
//
//  Created by ricky on 16/3/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJBillingChargeCellItem.h"

@interface SSJBookKeepingHomeHelper : NSObject

//  总收入的key
extern NSString *const SSJIncomeSumlKey;

//  总支出的key
extern NSString *const SSJExpentureSumKey;

/**
 *  查询首页所有记账记录
 *
 *  @param success 查询成功的回调
 *  @param failure 查询失败的回调
 */
+ (void)queryForChargeListWithSuccess:(void(^)(NSArray<SSJBillingChargeCellItem *> *result))success failure:(void (^)(NSError *error))failure;
/**
 *  查询某月的总支出和总收入
 *
 *  @param month   要查询的月份
 *  @param year    要查询的年份
 *  @param success 查询成功的回调
 *  @param failure 查询失败的回调
 */
+ (void)queryForIncomeAndExpentureSumWithMonth:(long)month Year:(long)year Success:(void(^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;
@end
