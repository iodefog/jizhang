//
//  SSJFixedFinanceProductStore.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SSJFixedFinanceProductItem;
@class SSJFixedFinanceProductChargeItem;
@class SSJReminderItem;

/**
 固定收益理财状态
 SSJFixedFinanceStateNoSettlement = 0, //未结算
 SSJFixedFinanceStateSettlemented,     //已结算
 SSJFixedFinanceStateAll               //全部
 */
typedef NS_ENUM(NSInteger, SSJFixedFinanceState) {
    SSJFixedFinanceStateNoSettlement = 0,
    SSJFixedFinanceStateSettlemented,
    SSJFixedFinanceStateAll
};

@interface SSJFixedFinanceProductStore : NSObject

/**
 根据状态查询固定理财产品

 @param fundID    所属的账户ID
 @param state 状态：未结算，已结算，全部
 @param success 成功
 @param failure 失败
 */
+ (void)queryFixedFinanceProductWithFundID:(NSString *_Nullable)fundID
                                      Type:(SSJFixedFinanceState)state
                                 success:(void (^_Nullable)(NSArray <SSJFixedFinanceProductItem *>* _Nullable resultList))success
                                 failure:(void (^_Nullable)(NSError * _Nullable error))failure;

/**
 *  查询固收理财产品详情
 *
 *  @param fixedFinanceProductID    理财产品id
 *  @param success   查询成功的回调
 *  @param failure   查询失败的回调
 */
+ (void)queryForLoanModelWithLoanID:(NSString *)fixedFinanceProductID
                            success:(void (^)(SSJFixedFinanceProductItem *model))success
                            failure:(void (^)(NSError *error))failure;


/**
 保存固收理财产品（新建，编辑）

 @param model 模型
 @param success 成功
 @param failure 失败
 */
+ (void)saveFixedFinanceProductWithModel:(SSJFixedFinanceProductItem *)model
                            chargeModels:(NSArray <SSJFixedFinanceProductChargeItem *>*)chargeModels
                             remindModel:(nullable SSJReminderItem *)remindModel success:(void (^)(void))success
                                 failure:(void (^)(NSError *error))failure;

/**
 结算固收理财产品
 
 @param model 模型
 @param success 成功
 @param failure 失败
 */
+ (void)settlementFixedFinanceProductWithModel:(SSJFixedFinanceProductItem *)model
                                 success:(void (^)(void))success
                                 failure:(void (^)(NSError *error))failure;



/**
 删除固收理财产品

 @param model 模型
 @param success 成功
 @param failure 失败
 */
+ (void)deleteFixedFinanceProductWithModel:(SSJFixedFinanceProductItem *)model
                                  success:(void (^)(void))success
                                  failure:(void (^)(NSError *error))failure ;
@end
