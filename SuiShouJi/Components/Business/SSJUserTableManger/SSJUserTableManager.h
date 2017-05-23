//
//  SSJUserTableManager.h
//  SuiShouJi
//
//  Created by old lang on 16/1/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJUserItem.h"

NS_ASSUME_NONNULL_BEGIN

@class FMDatabase;

@interface SSJUserTableManager : NSObject

/**
 *  重载当前的用户编号，重载过程分为以下3步:
 *  1:如果存储的当前用户编号(即函数SSJUSERID()的返回值)有效（不为nil，并且长度大于0），则直接返回；
 *  2:如果存储的当前用户编号(即函数SSJUSERID()的返回值)无效，则从用户表中查询没有注册的用户编号，并设置其为当前的用户编号；
 *  3:如果用户表中没有未注册的用户编号，则新建一个用户编号存储到表中，并设置其为当前用户编号；
 *
 *  @param error 错误对象，如果不为nil，则查询过程发生错误
 */
+ (void)reloadUserIdWithError:(NSError **)error;

/**
 *  重载当前的用户编号，重载过程分为以下3步:
 *  1:如果存储的当前用户编号(即函数SSJUSERID()的返回值)有效（不为nil，并且长度大于0），则直接返回；
 *  2:如果存储的当前用户编号(即函数SSJUSERID()的返回值)无效，则从用户表中查询没有注册的用户编号，并设置其为当前的用户编号；
 *  3:如果用户表中没有未注册的用户编号，则新建一个用户编号存储到表中，并设置其为当前用户编号；
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 */
+ (void)reloadUserIdWithSuccess:(nullable void (^)())success
                        failure:(nullable void (^)(NSError *error))failure;

/**
 *  从用户表中查询未注册的用户编号，如果没有则返回nil
 *
 *  @param db 数据库对象
 *  @param error 错误对象，如果不为nil，则查询过程发生错误
 */
+ (NSString *)unregisteredUserIdInDatabase:(FMDatabase *)db
                                     error:(NSError **)error;

/**
 *  查询用户所有信息
 *
 *  @return (SSJUserItem *) 用户信息模型
 */
+ (void)queryUserItemWithID:(NSString *)userID
                    success:(void(^)(SSJUserItem *userItem))success
                    failure:(nullable void(^)(NSError *error))failure;

/**
 *  查询指定的用户信息
 *
 *  @param propertyName 查询的属性
 *  @return (SSJUserItem *) 用户信息模型
 */
+ (void)queryProperty:(NSArray *)propertyNames
            forUserId:(NSString *)userId
              success:(void(^)(SSJUserItem *userModel))success
              failure:(nullable void(^)(NSError *error))failure;

/**
 *  保存用户信息
 *
 *  @return (BOOL) 是否保存成功
 */
+ (void)saveUserItem:(SSJUserItem *)userItem
             success:(nullable void(^)())success
             failure:(nullable void(^)(NSError *error))failure;

/**
 获取当前用户的账本id

 @param success <#success description#>
 @param failure <#failure description#>
 */
+ (void)currentBooksId:(void(^)(NSString *booksId))success
               failure:(nullable void(^)(NSError *error))failure;

/**
 更新当前用户的账本id

 @param booksId <#booksId description#>
 @param success <#success description#>
 @param failure <#failure description#>
 */
+ (void)updateCurrentBooksId:(NSString *)booksId
                     success:(nullable void(^)())success
                     failure:(nullable void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
