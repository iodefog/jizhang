//
//  SSJFixedFinanceProductStore.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SSJFixedFinanceProductItem;
@class SSJFixedFinanceProductChargeItem;
@class SSJReminderItem;
@class SSJFixedFinanceProductCompoundItem;
@class FMDatabase;

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

#pragma mark - 固定理财
/**
 根据状态查询固定理财产品列表

 @param fundID    所属的账户ID
 @param state 状态：未结算，已结算，全部
 @param success 成功
 @param failure 失败
 */
+ (void)queryFixedFinanceProductWithFundID:(NSString *)fundID
                                      Type:(SSJFixedFinanceState)state
                                 success:(void (^)(NSArray <SSJFixedFinanceProductItem *>* resultList))success
                                 failure:(void (^)(NSError * error))failure;

/**
 *  查询固收理财产品详情
 *
 *  @param fixedFinanceProductID    理财产品id
 *  @param success   查询成功的回调
 *  @param failure   查询失败的回调
 */
+ (void)queryForFixedFinanceProduceWithProductID:(NSString *)fixedFinanceProductID
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
 @param chargeModel 流水模型
 @param success 成功
 @param failure 失败
 */
+ (void)settlementFixedFinanceProductWithModel:(SSJFixedFinanceProductItem *)model
                                   chargeModel:(SSJFixedFinanceProductChargeItem *)chargeModel
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
                                  failure:(void (^)(NSError *error))failure;

/**
 删除固收理财产品
 
 @param model  模型
 @param db     db FMDatabase实例
 
 @return 是否合并成功
 */
+ (BOOL)deleteFixedFinanceProductModel:(SSJFixedFinanceProductItem *)model
             inDatabase:(FMDatabase *)db
              forUserId:(NSString *)userId
                  error:(NSError **)error;


#pragma mark - 固定理财流水

/**
 查询某个固定理财所有的流水列表
 
 @param model 固定理财模型
 @param resultList 返回的流水列表
 @param success 成功的回调
 @param failure 失败的回调
 */
+ (void)queryFixedFinanceProductChargeListWithModel:(SSJFixedFinanceProductItem *)model
                                     success:(void (^)(NSArray <SSJFixedFinanceProductChargeItem *>*resultList))success
                                     failure:(void (^)(NSError *error))failure;

/**
 查询固定理财流水详情
 
 @param model 固定理财流水(转入、转出、利息)等
 @param success 成功的回调
 @param failure 失败的回调
 */
+ (void)queryFixedFinanceProductChargeDetailWithChargeId:(NSString *)chargeId
                                                 success:(void (^)(SSJFixedFinanceProductChargeItem *model))success
                                                 failure:(void (^)(NSError *error))failure;

/**
 删除固定理财的某个流水
 
 @param model 流水模型
 @param success 删除成功的回调
 @param failure 删除失败的回调，error code为1代表删除流水后借贷剩余金额会小于0
 */
+ (void)deleteFixedFinanceProductChargeWithModel:(SSJFixedFinanceProductChargeItem *)model
                              success:(void (^)(void))success
                              failure:(void (^)(NSError *error))failure;

/**
 新增或修改固定理财的某个流水
 
 @param model 借贷产生的流水
 @param success 成功的回调
 @param failure 失败的回调
 */
+ (void)saveFinanceCompoundChargeModel:(SSJFixedFinanceProductChargeItem *)model
                            success:(void (^)(void))success
                            failure:(void (^)(NSError *error))failure;


/**
 追加投资

 @param model <#model description#>
 @param chargeModels 追加产生的流水
 @param success <#success description#>
 @param failure <#failure description#>
 */
+ (void)addInvestmentWithProductModel:(SSJFixedFinanceProductItem *)model
                         chargeModels:(NSArray <SSJFixedFinanceProductCompoundItem *>*)chargeModels
                              success:(void (^)(void))success
                              failure:(void (^)(NSError *error))failure;


/**
 查询流水cid后缀最大值
 返回后缀
 @param productid <#productid description#>
 */
+ (NSInteger)queryMaxChargeChargeIdSuffixWithProductId:(NSString *)productid;


/**
 计算已产生利息

 @param model model
 @return 利息
 */
+ (double)caculateGenerateRateWithModel:(SSJFixedFinanceProductItem *)model;


/**
 计算预期利息
 
 @param model model
 @return 利息
 */
+ (double)caculateExpectedRateWithModel:(SSJFixedFinanceProductItem *)model;
@end


NS_ASSUME_NONNULL_END
