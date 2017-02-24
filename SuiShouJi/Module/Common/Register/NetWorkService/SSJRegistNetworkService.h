//
//  SSJRegistNetworkService.h
//  YYDB
//
//  Created by old lang on 15/10/29.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

//  注册网络请求

#import "SSJBaseNetworkService.h"

typedef NS_ENUM(NSInteger, SSJRegistNetworkServiceType) {
    SSJRegistNetworkServiceTypeGetAuthCode = 0, //  获取验证码
    SSJRegistNetworkServiceTypeCheckAuthCode,   //  验证验证码
    SSJRegistNetworkServiceTypeSetPassword      //  设置登录密码
};

@interface SSJRegistNetworkService : SSJBaseNetworkService

- (instancetype)initWithDelegate:(id<SSJBaseNetworkServiceDelegate>)delegate type:(SSJRegistAndForgetPasswordType)type;

//  注册、忘记密码类型
@property (readonly, nonatomic) SSJRegistAndForgetPasswordType type;

//  请求接口类型
@property (readonly, nonatomic) SSJRegistNetworkServiceType interfaceType;

//  手机号码
@property (readonly, nonatomic, copy) NSString *mobileNo;

//  验证码
@property (readonly, nonatomic, copy) NSString *authCode;

//  密码
@property (readonly, nonatomic, copy) NSString *password;

//  userId
@property(nonatomic, strong) NSString *userID;

/**
 *  获取验证码
 *
 *  @param mobileNo 手机号
 */
- (void)getAuthCodeWithMobileNo:(NSString *)mobileNo;

/**
 *  验证验证码接口
 *
 *  @param mobileNo 手机号
 *  @param authCode 验证码
 */
- (void)checkAuthCodeWithMobileNo:(NSString *)mobileNo authCode:(NSString *)authCode;

/**
 *  设置密码接口
 *
 *  @param mobileNo 手机号
 *  @param authCode 验证码
 *  @param password 登录密码
 */
- (void)setPasswordWithMobileNo:(NSString *)mobileNo authCode:(NSString *)authCode password:(NSString *)password;

@end
