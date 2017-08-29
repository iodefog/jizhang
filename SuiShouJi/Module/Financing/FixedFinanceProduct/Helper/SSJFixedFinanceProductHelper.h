//
//  SSJFixedFinanceProductHelper.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SSJFixedFinanceProductItem;
@class SSJFixedFinanceProductChargeItem;
@class SSJReminderItem;

@interface SSJFixedFinanceProductHelper : NSObject
/**
 计算每日利息
 
 @param model 借贷模型，根据rate、interestType两个属性计算利息
 @return 计算结果
 */
+ (double)caculateInterestForEveryDayWithRate:(double)rate interstType:(SSJMethodOfRateOrTime)rateType money:(double)money;
//SSJMethodOfRateOrTime ratetype
/**
 计算可变本金产生的利息；因为变更流水会改变本金，利息是按照不同时间段内的本金计算
 
 @param date 截止日期
 @param model 借贷模型，用borrowDate、rate、interestType三个属性计算利息
 @param models 借贷生成的流水记录
 @return 计算结果
 */
+ (double)caculateInterestUntilDate:(NSDate *)untilDate model:(SSJFixedFinanceProductItem *)model chargeModels:(NSArray <SSJFixedFinanceProductChargeItem *>*)models;

/**
 计算固定本金产生的利息
 
 @param principal 本金
 @param rate 年华收益率
 @param days 天数
 @return 利息
 */
+ (double)interestWithPrincipal:(double)principal rate:(double)rate days:(int)days;

@end
NS_ASSUME_NONNULL_END
