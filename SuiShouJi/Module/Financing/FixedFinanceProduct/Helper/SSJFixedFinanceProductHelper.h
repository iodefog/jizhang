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
+ (double)caculateInterestForEveryDayWithRate:(double)rate rateType:(SSJMethodOfRateOrTime)rateType money:(double)money;


/**
 计算预期利息

 @param rate 利率
 @param rateType 利率类型（年，月，日）
 @param time 期限
 @param timeType 期限类型（年，月，日）
 @param money 本金
 @param interesttype 气息方式
 @param startDate 气息时间
 @return 预期利息预期利息key：interest，key：desc
 */
+ (NSDictionary *)caculateYuQiInterestWithRate:(double)rate rateType:(SSJMethodOfRateOrTime)rateType time:(double)time timetype:(SSJMethodOfRateOrTime)timeType money:(double)money interestType:(SSJMethodOfInterest)interesttype startDate:(NSString *)startDate;

//SSJMethodOfRateOrTime ratetype
/**
 计算可变本金产生的利息；因为变更流水会改变本金，利息是按照不同时间段内的本金计算
 
 @param date 截止日期
 @param model 借贷模型，用borrowDate、rate、interestType三个属性计算利息
 @param models 借贷生成的流水记录
 @return 计算结果
 */
+ (NSMutableDictionary *)caculateInterestWithModel:(SSJFixedFinanceProductItem *)item chargeModels:(NSArray <SSJFixedFinanceProductChargeItem *>*)models;

/**
 计算固定本金产生的利息
 
 @param principal 本金
 @param rate 年华收益率
 @param days 天数
 @return 利息
 */
+ (double)interestWithPrincipal:(double)principal rate:(double)rate days:(int)days;

+ (int)chargeIdWithModel:(SSJFixedFinanceProductChargeItem *)model;


/**
 两个时间之间有多少天

 @param startDate <#startDate description#>
 @param endDate <#endDate description#>
 @return <#return value description#>
 */
- (NSInteger)getDifferenceWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

@end
NS_ASSUME_NONNULL_END
