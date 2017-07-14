//
//  SSJLoginNavigator.h
//  SuiShouJi
//
//  Created by old lang on 2017/7/13.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

//  登录流程控制

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SSJNavigationType) {
    SSJNavigationTypePush,
    SSJNavigationTypePresent
};

@interface SSJLoginNavigator : NSObject

/**
 登录了方式
 */
@property (nonatomic, readonly) SSJLoginType loginType;

/**
 最近一次错误
 */
@property (nonatomic, strong, readonly) NSError *lastError;

/**
 获取唯一的单列对象；

 @return 唯一的单列对象
 */
+ (instancetype)sharedNavigator;

/**
 开始登录流程
 
 @param sourceController 来源控制器
 @param mobileNo 默认手机号
 @param loginType 登录方式
 @param navigationType 进入登录页面方式
 @param motionPwdForgeted 是否忘记手势密码
 @param finishHandler 登录流程完成的回调
 */
- (void)beginLoginWithSourceController:(UIViewController *)sourceController
                              mobileNo:(NSString *)mobileNo
                             loginType:(SSJLoginType)loginType
                        navigationType:(SSJNavigationType)navigationType
                     motionPwdForgeted:(BOOL)motionPwdForgeted
                         finishHandler:(void(^)())finishHandler;

/**
 手机号登录第一步完成验证手机号，根据手机号是否注册过跳转相应的页面，未注册进入注册，注册过进入验证密码

 @param mobileNo 验证的手机号
 @param registered 手机号是否注册过
 */
- (void)finishMobileNoVerification:(NSString *)mobileNo registered:(BOOL)registered;

/**
 手机号登录第二步完成手机号登录，会根据是否忘记手势密码跳转相应页面，如果登录流程是由用户忘记手势密码而来，就会跳转到设置手势密码，反之完成登录流程
 */
- (void)finishMobileNoLogin;

/**
 完成手势密码设置；
 如果是三方登录，会根据用户是否绑定过手机号进入相应页面，未绑定就跳转绑定，反之完成登录流程；
 如果是手机号登录，直接完成登录流程
 */
- (void)finishMotionPwdSetting;

/**
 进入忘记密码
 */
- (void)beginForgetPwd;

/**
 完成忘记密码；如果是由用户忘记手势密码进入的登录流程，就会跳转到设置手势密码，反之就完成登录流程
 */
- (void)finishForgetPwd;

/**
 完成注册；直接完成登录流程
 */
- (void)finishRegistration;

/**
 完成三方登录；如果是由用户忘记手势密码进入的登录流程，就会跳转到设置手势密码，反之判断用户是否绑定过手机号，未绑定跳转到绑定，绑定过就直接完成登录流程
 */
- (void)finishThirdPartLogin;

/**
 完成手机号绑定；直接完成登录流程
 */
- (void)finishBindingMobileNo;

@end

NS_ASSUME_NONNULL_END
