//
//  SSJBindMobileNoNetworkService.h
//  SuiShouJi
//
//  Created by old lang on 2017/6/29.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSJBindMobileNoNetworkService : SSJBaseNetworkService

@property (nonatomic, copy, readonly) NSString *mobileNo;

@property (nonatomic, copy, readonly) NSString *authCode;

@property (nonatomic, copy, readonly) NSString *password;

/**
 绑定手机号

 @param mobileNo 手机号
 @param authCode 验证码
 @param password 登录密码
 @param success 成功的回调
 @param failure 失败的回调
 */
- (void)bindMobileNoWithMobileNo:(NSString *)mobileNo
                        authCode:(NSString *)authCode
                        password:(NSString *)password
                         success:(SSJNetworkServiceHandler)success
                         failure:(SSJNetworkServiceHandler)failure;

/**
 更换手机号
 
 @param mobileNo 手机号
 @param authCode 验证码
 @param success 成功的回调
 @param failure 失败的回调
 */
- (void)changeMobileNoWithMobileNo:(NSString *)mobileNo
                          authCode:(NSString *)authCode
                           success:(SSJNetworkServiceHandler)success
                           failure:(SSJNetworkServiceHandler)failure;

@end

NS_ASSUME_NONNULL_END
