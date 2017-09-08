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
@class SSJDatabase;
@class SSJLoanFundAccountSelectionViewItem;

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
 查询当前本金
 
 *  @param fixedFinanceProductID    理财产品id
 @return 本金
 */
+ (double)queryForFixedFinanceProduceCurrentMoneyWothWithProductID:(NSString *)fixedFinanceProductID;


/**
 查询当前利息和

 *  @param fixedFinanceProductID    理财产品id
 @return 利息
 */
+ (double)queryForFixedFinanceProduceInterestiothWithProductID:(NSString *)fixedFinanceProductID;

//查询所有算手续费和
+ (double)querySettmentInterestWithProductID:(NSString *)fixedFinanceProductID;

/**
 查询结算时输入利息
 
 *  @param fixedFinanceProductID    理财产品id
 @return 利息
 */
+ (double)queryForFixedFinanceProduceJieSuanInterestiothWithProductID:(NSString *)fixedFinanceProductID;


/**
 查询当前最新一条流水的billdate

 @param model <#model description#>
 */
+ (NSString *)queryFixedFinanceProductNewChargeBillDateWithModel:(SSJFixedFinanceProductItem *)model;


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
 删除固收理财账户
 
 @param model 模型
 @param success 成功
 @param failure 失败
 */
+ (void)deleteFixedFinanceProductAccountWithModel:(NSArray <SSJFixedFinanceProductItem *> *)model success:(void (^)(void))success
                                          failure:(void (^)(NSError *error))failure ;



/**
 删除固收理财产品

 @param model 模型
 @param success 成功
 @param failure 失败
 */
+ (void)deleteFixedFinanceProductWithModel:(SSJFixedFinanceProductItem *)model success:(void (^)(void))success
                                  failure:(void (^)(NSError *error))failure;


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
 删除固定理财的某个流水(单个流水，每日利息，手续费，利息平账)
 
 @param model 流水模型
 @param success 删除成功的回调
 @param failure 删除失败的回调，error code为1代表删除流水后借贷剩余金额会小于0
 */
+ (void)deleteFixedFinanceProductChargeWithModel:(SSJFixedFinanceProductChargeItem *)model
                                    productModel:(SSJFixedFinanceProductItem *)productModel
                                         success:(void (^)(void))success
                                         failure:(void (^)(NSError *error))failure;

/**
 删除赎回流水
 
 @param model 流水模型
 @param success 删除成功的回调
 @param failure 删除失败的回调，error code为1代表删除流水后借贷剩余金额会小于0
 */
+ (void)deleteFixedFinanceProductRedemChargeWithModel:(NSArray<SSJFixedFinanceProductChargeItem *> *)modelArr
                                         productModel:(SSJFixedFinanceProductItem *)productModel
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
 追加或赎回投资
 
 @param model model
 param type 1追加2赎回
 @param chargeModels 追加产生的流水
 @param success 成功
 @param failure 失败
 */
+ (void)addOrRedemptionInvestmentWithProductModel:(SSJFixedFinanceProductItem *)productModel
                                             type:(NSInteger)type
                                     chargeModels:(NSArray <SSJFixedFinanceProductCompoundItem *>*)chargeModels
                                          success:(void (^)(void))success
                                          failure:(void (^)(NSError *error))failure;

/**
 结算
 
 @param chargeModels 追加产生的流水
 @param success 成功
 @param failure 失败
 */
+ (void)settlementWithProductModel:(SSJFixedFinanceProductItem *)productModel
                      chargeModels:(NSArray <SSJFixedFinanceProductCompoundItem *>*)chargeModels
                           success:(void (^)(void))success
                           failure:(void (^)(NSError *error))failure;


/**
 删除某个理财产品的所有流水（等同删除某个理财产品）

 @param model 理财产品model
 @param db db
 @param userId
 @param writeDate 为保持writhDate一致
 @param needcreateRecycleRecord 是否加入到回收站
 @param error <#error description#>
 @return <#return value description#>
 */
+ (BOOL)deleteFixedFinanceProductModel:(SSJFixedFinanceProductItem *)model
                            inDatabase:(FMDatabase *)db
                             forUserId:(NSString *)userId
                             writeDate:(NSString *)writeDate
               needcreateRecycleRecord:(BOOL)needcreateRecycleRecord
                                 error:(NSError **)error;


/**
 重新设置某个理财产品的所有流水（等同删除某个理财产品）

 @param model
 @param db <#db description#>
 @param needcreateRecycleRecord <#needcreateRecycleRecord description#>
 */
+ (void)reSetFixedFinanceProductModel:(SSJFixedFinanceProductItem *)model needcreateRecycleRecord:(BOOL)needcreateRecycleRecord;



#pragma mark - Other 

/**
 查询资金账户模型

 @param fundid <#fundid description#>
 @return <#return value description#>
 */
+ (SSJLoanFundAccountSelectionViewItem *)queryfundNameWithFundid:(NSString *)fundid;


/**
 通过一条chareitem查找对应的另外一条流水

 @param oneChargeItem <#oneChargeItem description#>
 @return <#return value description#>
 */
+ (void)queryOtherFixedFinanceProductChargeItemWithChareItem:(SSJFixedFinanceProductChargeItem *)oneChargeItem success:(void (^)(NSArray <SSJFixedFinanceProductChargeItem *> * charegItemArr))success failure:(void (^)(NSError *error))failure;
/**
 通过一条chareitem查找对应的另外一条流水
 
 @param oneChargeItem <#oneChargeItem description#>
 @return <#return value description#>
 */
+ (BOOL)queryOtherFixedFinanceProductChargeItemWithChareItem:(SSJFixedFinanceProductChargeItem *)oneChargeItem inDatabase:(FMDatabase *)db error:(NSError **)error;


/**
 根据一条流水查找对应流水chargeid

 @param oneChargeItem <#oneChargeItem description#>
 @param db <#db description#>
 @param error <#error description#>
 @return <#return value description#>
 */
+ (NSString *)queryChargeIdWithChargeItem:(SSJFixedFinanceProductChargeItem *)oneChargeItem inDatabase:(FMDatabase *)db error:(NSError **)error;
/**
 通过remindid查找

 @param remindid <#remindid description#>
 @return <#return value description#>
 */
+ (NSString *)queryProductIdWithRemindId:(NSString *)remindid;

/**
 查询某个理财账户最新一条派发流水时间
 
 @param model <#model description#>
 @return <#return value description#>
 */
+ (NSDate *)queryPaiFalLastBillDateWithPorductModel:(SSJFixedFinanceProductItem *)model inDatabase:(FMDatabase *)db;


/**
 查询是否由赎回或者追加

 @param model <#model description#>
 @return <#return value description#>
 */
+ (BOOL)queryIsChangeMoneyWithProductModel:(SSJFixedFinanceProductItem *)model;


/**
 查询结算的时候是否有手续费

 @param productItem <#productItem description#>
 @param chargeItem <#chargeItem description#>
 @return <#return value description#>
 */
+ (BOOL)queryHasPoundageWithProduct:(SSJFixedFinanceProductItem *)productItem chargeItem:(SSJFixedFinanceProductChargeItem *)chargeItem;


/**
 查询结算的时候的手续费是多少

 */
+ (double)queryPoundageWithProduct:(SSJFixedFinanceProductItem *)productItem chargeItem:(SSJFixedFinanceProductChargeItem *)chargeIte;


/**
 计算当前余额

 @param productItem <#productItem description#>
 @return <#return value description#>
 */
+ (double)caluclateTheBalanceOfCurrentWithModel:(SSJFixedFinanceProductItem *)productItem;
/**
 生成某个理财产品在起止时间内的利息派发流水  每日流水
 
 @param item <#item description#>
 @param investmentDate <#startDate description#>
 @param endDate <#endDate description#>
 */
+ (BOOL)interestRecordWithModel:(SSJFixedFinanceProductItem *)item investmentDate:(NSDate *)investmentDate endDate:(NSDate *)endDate newMoney:(double)newMoney inDatabase:(FMDatabase *)db error:(NSError **)error;
@end


NS_ASSUME_NONNULL_END
