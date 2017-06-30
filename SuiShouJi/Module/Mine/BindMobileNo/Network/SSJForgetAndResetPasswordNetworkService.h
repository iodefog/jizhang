//
//  SSJForgetAndResetPasswordNetworkService.h
//  SuiShouJi
//
//  Created by old lang on 2017/6/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//
//  忘记密码、重置密码
#import "SSJBaseNetworkService.h"

/**
 忘记密码/重置密码

 - SSJForgetPasswordType: 忘记密码
 - SSJResetPasswordType: 重置密码
 */
typedef NS_ENUM(NSInteger, SSJForgetAndResetPasswordType) {
    SSJForgetPasswordType,
    SSJResetPasswordType
};

@interface SSJForgetAndResetPasswordNetworkService : SSJBaseNetworkService

@property (nonatomic, readonly) SSJForgetAndResetPasswordType type;

@property (nonatomic, copy, readonly) NSString *mobileNo;

@property (nonatomic, copy, readonly) NSString *authCode;

@property (nonatomic, copy, readonly) NSString *password;

/**
 忘记密码/重置密码

 @param type 指定是忘记密码还是重置密码
 @param mobileNo 手机号
 @param authCode 验证码
 @param password 密码
 @param success 成功回调
 @param failure 失败回调
 */
- (void)requestWithType:(SSJForgetAndResetPasswordType)type
               mobileNo:(NSString *)mobileNo
               authCode:(NSString *)authCode
               password:(NSString *)password
                success:(SSJNetworkServiceHandler)success
                failure:(SSJNetworkServiceHandler)failure;

@end
