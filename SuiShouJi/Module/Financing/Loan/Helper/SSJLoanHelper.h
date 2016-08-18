//
//  SSJLoanHelper.h
//  SuiShouJi
//
//  Created by old lang on 16/8/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJLoanModel.h"

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
 *  保存借贷模型
 *
 *  @param model     借贷模型
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
+ (void)saveLoanModel:(SSJLoanModel *)model
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
 *  结清借贷
 *
 *  @param model     借贷模型
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
+ (void)closeOutLoanModel:(SSJLoanModel *)model
                  success:(void (^)())success
                  failure:(void (^)(NSError *error))failure;

/**
 *  恢复已结清借贷
 *
 *  @param model     借贷模型
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
+ (void)recoverLoanModel:(SSJLoanModel *)model
                 success:(void (^)())success
                 failure:(void (^)(NSError *error))failure;

@end
