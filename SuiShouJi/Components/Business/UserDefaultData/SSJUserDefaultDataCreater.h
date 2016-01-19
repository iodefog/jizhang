//
//  SSJUserDefaultDataCreater.h
//  SuiShouJi
//
//  Created by old lang on 16/1/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJUserDefaultDataCreater : NSObject

/**
 *  为当前用户创建默认的同步表记录
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)createDefaultSyncRecordWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

/**
 *  为当前用户创建默认的资金帐户
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)createDefaultFundAccountsWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

/**
 *  为当前用户创建默认的收支类型
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)createDefaultBillTypesIfNeededWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

@end
