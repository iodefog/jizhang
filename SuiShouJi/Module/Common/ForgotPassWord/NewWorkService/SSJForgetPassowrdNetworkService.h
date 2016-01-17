//
//  SSJForgetPassowrdNetworkService.h
//  YYDB
//
//  Created by old lang on 15/10/29.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

//  忘记密码

#import "SSJBaseNetworkService.h"

@interface SSJForgetPassowrdNetworkService : SSJBaseNetworkService

//  手机号码
@property (readonly, nonatomic, copy) NSString *mobileNo;

//  验证码
@property (readonly, nonatomic, copy) NSString *authCode;

//  密码
@property (readonly, nonatomic, copy) NSString *password;

/**
 *  获取验证码
 *
 *  @param mobileNo 手机号
 */
- (void)getAuthCodeWithMobileNo:(NSString *)mobileNo;

//  验证验证码接口
- (void)checkAuthCodeWithMobileNo:(NSString *)mobileNo authCode:(NSString *)authCode;

//  设置密码接口
- (void)setPasswordWithMobileNo:(NSString *)mobileNo authCode:(NSString *)authCode password:(NSString *)password;

@end
