//
//  SSJUserDefaultDataCreater.h
//  SuiShouJi
//
//  Created by old lang on 16/1/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface SSJUserDefaultDataCreater : NSObject

/**
 *  同步创建当前用户默认的同步表记录
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)createDefaultSyncRecordWithError:(NSError **)error;

/**
 *  异步创建当前用户默认的同步表记录
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)asyncCreateDefaultSyncRecordWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

/**
 *  创建指定用户默认的资金帐户
 *
 *  @param userId 用户id
 *  @param db     数据库对象
 *
 *  @return (NSError *)
 */
+ (NSError *)createDefaultFundAccountsForUserId:(NSString *)userId inDatabase:(FMDatabase *)db;

/**
 *  同步创建当前用户默认的资金帐户
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)createDefaultFundAccountsWithError:(NSError **)error;

/**
 *  异步创建当前用户默认的资金帐户
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)asyncCreateDefaultBooksTypeWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

/**
 *  创建指定用户默认的账本类型
 *
 *  @param userId 用户id
 *  @param db     数据库对象
 *
 *  @return (NSError *)
 */
+ (NSError *)createDefaultBooksTypeForUserId:(NSString *)userId inDatabase:(FMDatabase *)db;

/**
 *  同步创建当前用户默认的账本
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)createDefaultBooksTypeWithError:(NSError **)error;

/**
 *  异步创建当前用户默认的账本
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)asyncCreateDefaultFundAccountsWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

/**
 *  创建指定用户默认的成员
 *
 *  @param userId 用户id
 *  @param db     数据库对象
 *
 *  @return (NSError *)
 */
+ (NSError *)createDefaultMembersForUserId:(NSString *)userId inDatabase:(FMDatabase *)db;

/**
 *  同步创建当前用户默认的成员
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)createDefaultMembersWithError:(NSError **)error;

/**
 *  异步创建当前用户默认的成员
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)asyncCreateDefaultMembersTypeWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

/**
 *  创建当前用户默认的收支类型
 *
 *  @param db
 *  @return (NSError)
 */
+ (NSError *)createDefaultBillTypesIfNeededForUserId:(NSString *)userID inDatabase:(FMDatabase *)db;

/**
 *  同步创建当前用户默认的收支类型
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)createDefaultBillTypesIfNeededWithError:(NSError **)error;

/**
 *  异步创建当前用户默认的收支类型
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)asyncCreateDefaultBillTypesIfNeededWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

/**
 *  异步创建当前用户默认的所有数据（同步表、资金帐户、收支类型、账本、成员）
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)asyncCreateAllDefaultDataWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

@end
