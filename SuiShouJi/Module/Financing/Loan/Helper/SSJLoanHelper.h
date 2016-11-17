//
//  SSJLoanHelper.h
//  SuiShouJi
//
//  Created by old lang on 16/8/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJLoanModel.h"
#import "SSJLoanFundAccountSelectionViewItem.h"
#import "SSJDatabaseQueue.h"

NS_ASSUME_NONNULL_BEGIN

@class SSJReminderItem;
@class SSJLoanCompoundChargeModel;

@interface SSJLoanHelper : NSObject

/**
 *  查询借贷列表
 *
 *  @param fundID    所属的账户ID
 *  @param state     结算状态；0:未结算 1:已结算 2:包含所有未结算、已结算
 *  @param success   查询成功的回调
 *  @param failure   查询失败的回调
 */
+ (void)queryForLoanModelsWithFundID:(NSString *)fundID
                       colseOutState:(int)state
                             success:(void (^)(NSArray <SSJLoanModel *>*list))success
                             failure:(void (^)(NSError *error))failure;

/**
 *  查询借贷详情
 *
 *  @param loanID    借贷项目ID
 *  @param success   查询成功的回调
 *  @param failure   查询失败的回调
 */
+ (void)queryForLoanModelWithLoanID:(NSString *)loanID
                            success:(void (^)(SSJLoanModel *model))success
                            failure:(void (^)(NSError *error))failure;

/**
 *  新增或更新借贷
 *
 *  @param model     借贷模型
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
+ (void)saveLoanModel:(SSJLoanModel *)loanModel
         chargeModels:(NSArray <SSJLoanCompoundChargeModel *>*)chargeModels
          remindModel:(nullable SSJReminderItem *)remindModel
              success:(void (^)())success
              failure:(void (^)(NSError *error))failure;

/**
 *  删除借贷模型
 *
 *  @param model     借贷模型
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
+ (void)deleteLoanModel:(SSJLoanModel *)model
                success:(void (^)())success
                failure:(void (^)(NSError *error))failure;


/**
 删除借贷模型

 @param model  借贷模型
 @param db     db FMDatabase实例

 @return 是否合并成功
 */
+ (BOOL)deleteLoanModel:(SSJLoanModel *)model
             inDatabase:(FMDatabase *)db
              forUserId:(NSString *)userId
                  error:(NSError **)error;

/**
 *  结清借贷
 *
 *  @param model     借贷模型
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
+ (void)closeOutLoanModel:(SSJLoanModel *)model
              chargeModel:(SSJLoanCompoundChargeModel *)chargeModel
                  success:(void (^)())success
                  failure:(void (^)(NSError *error))failure;

/**
 *  查询除借贷以外，当前用户的资金账户列表
 *
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
+ (void)queryFundModelListWithSuccess:(void (^)(NSArray <SSJLoanFundAccountSelectionViewItem *>*items))success
                              failure:(void (^)(NSError *error))failure;

/**
 *  查询资金账户名称
 *
 *  @param ID 资金账户ID
 */
+ (NSString *)queryForFundNameWithID:(NSString *)ID;

/**
 查询资金账户颜色值

 @param ID 资金账户的ID
 @return 16进制颜色值
 */
+ (NSString *)queryForFundColorWithID:(NSString *)ID;

/**
 计算固定本金产生的利息

 @param principal 本金
 @param rate 年华收益率
 @param days 天数
 @return 利息
 */
+ (double)interestWithPrincipal:(double)principal rate:(double)rate days:(int)days;

/**
 *  预期利息
 *
 *  @param model 借贷模型
 *  @param chargeModels 借贷产生的流水
 */
+ (double)expectedInterestWithLoanModel:(SSJLoanModel *)model chargeModels:(NSArray <SSJLoanCompoundChargeModel *>*)chargeModels;

/**
 计算可变本金产生的利息；因为变更流水会改变本金，利息是按照不同时间段内的本金计算

 @param date 截止日期
 @param model 借贷模型，用borrowDate、rate、interestType三个属性计算利息
 @param models 借贷生成的流水记录
 @return 计算结果
 */
+ (double)caculateInterestUntilDate:(NSDate *)untilDate model:(SSJLoanModel *)model chargeModels:(NSArray <SSJLoanCompoundChargeModel *>*)models;

/**
 查询借贷详情

 @param model 借贷流水中的莫一个子流水，转入、转出、利息等
 @param success 成功的回调
 @param failure 失败的回调
 */
+ (void)queryLoanCompoundChangeModelWithChargeId:(NSString *)chargeId
                                         success:(void (^)(SSJLoanCompoundChargeModel *model))success
                                         failure:(void (^)(NSError *error))failure;

/**
 查询借贷产生的流水列表

 @param loanModel 借贷模型
 @param success 成功的回调
 @param failure 失败的回调
 */
+ (void)queryLoanChargeModeListWithLoanModel:(SSJLoanModel *)loanModel
                                     success:(void (^)(NSArray <SSJLoanCompoundChargeModel *>*list))success
                                     failure:(void (^)(NSError *error))failure;

/**
 根据流水id查询借贷生成的转账流水（包括转入、转出、利息），此流水必须是转账生成的

 @param chargeId 借贷生成的流水
 @param success 成功的回调
 @param failure 失败的回调
 */
+ (void)queryLoanCompoundChargeModelWithChargeId:(NSString *)chargeId
                                         success:(void (^)(SSJLoanCompoundChargeModel *model))success
                                         failure:(void (^)(NSError *error))failure;

/**
 删除借贷产生的流水

 @param model 借贷产生的流水模型
 @param success 删除成功的回调
 @param failure 删除失败的回调，error code为1代表删除流水后借贷剩余金额会小于0
 */
+ (void)deleteLoanCompoundChargeModel:(SSJLoanCompoundChargeModel *)model
                              success:(void (^)(void))success
                              failure:(void (^)(NSError *error))failure;

/**
 新增或修改借贷产生的流水

 @param model 借贷产生的流水
 @param success 成功的回调
 @param failure 失败的回调
 */
+ (void)saveLoanCompoundChargeModel:(SSJLoanCompoundChargeModel *)model
                            success:(void (^)(void))success
                            failure:(void (^)(NSError *error))failure;

+ (void)saveLoanCompoundChargeModels:(NSArray <SSJLoanCompoundChargeModel *>*)models
                             success:(void (^)(void))success
                             failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
