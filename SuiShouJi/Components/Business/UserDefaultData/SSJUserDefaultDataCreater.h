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
 *  同步创建当前用户默认的同步表记录
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)createDefaultSyncRecordWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

/**
 *  异步创建当前用户默认的同步表记录
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)asyncCreateDefaultSyncRecordWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

/**
 *  同步创建当前用户默认的资金帐户
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)createDefaultFundAccountsWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

/**
 *  异步创建当前用户默认的资金帐户
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)asyncCreateDefaultFundAccountsWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

/**
 *  同步创建当前用户默认的收支类型
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)createDefaultBillTypesIfNeededWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

/**
 *  异步创建当前用户默认的收支类型
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)asyncCreateDefaultBillTypesIfNeededWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;


/**
 *  异步创建当前用户默认的所有数据（同步表、资金帐户、收支类型）
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)asyncCreateAllDefaultDataWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

@end
