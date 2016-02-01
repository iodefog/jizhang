//
//  SSJUserTableManager.h
//  SuiShouJi
//
//  Created by old lang on 16/1/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SSJUserIdKey;
extern NSString *const SSJUserMobileNoKey;
extern NSString *const SSJUserIconKey;

@class FMDatabase;

@interface SSJUserTableManager : NSObject

/**
 *  重载当前的用户编号，重载过程分为以下3步:
 *  1:如果存储的当前用户编号有效（不为nil，并且长度大于0），则直接返回；
 *  2:如果存储的当前用户编号无效，则从用户表中查询没有注册的用户编号，并设置其为当前的用户编号；
 *  3:如果用户表中没有未注册的用户编号，则新建一个用户编号存储到表中，并设置其为当前用户编号；
 *
 *  @param error 错误对象，如果不为nil，则查询过程发生错误
 */
+ (void)reloadUserIdWithError:(NSError **)error;

/**
 *  从用户表中查询未注册的用户编号，如果没有则返回nil
 *
 *  @param db 数据库对象
 *  @param error 错误对象，如果不为nil，则查询过程发生错误
 */
+ (NSString *)unregisteredUserIdInDatabase:(FMDatabase *)db error:(NSError **)error;

/**
 *  将当前用户编号的注册状态设置为已注册
 *
 *  @param success 成功的回调
 *  @param failure 失败的回调
 */
+ (void)registerUserIdWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

///**
// *  保存当前用户id
// *
// *  @param error 错误对象，如果不为nil，则查询过程发生错误
// */
//+ (void)saveUserId:(NSString *)userId withError:(NSError **)error;
//
///**
// *  将手机号码保存到用户表中当前用户记录下
// *
// *  @param mobileNo 要保存的手机号
// *  @param success 成功的回调
// *  @param failure 失败的回调
// */
//+ (void)asyncSaveMobileNo:(NSString *)mobileNo success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
//
///**
// *  将头像地址保存到用户表中当前用户记录下
// *
// *  @param mobileNo 要保存的头像地址
// *  @param success 成功的回调
// *  @param failure 失败的回调
// */
//+ (void)asyncSaveIcon:(NSString *)icon success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

+ (void)saveUserInfo:(NSDictionary *)userInfo error:(NSError **)error;

@end
