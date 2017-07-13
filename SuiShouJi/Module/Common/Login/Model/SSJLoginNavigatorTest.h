//
//  SSJLoginNavigatorTest.h
//  SuiShouJi
//
//  Created by old lang on 2017/7/13.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SSJNavigationType) {
    SSJNavigationTypePush,
    SSJNavigationTypePresent
};

@interface SSJLoginNavigatorTest : NSObject

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

- (void)goNext:(NSDictionary *)params;

@end
