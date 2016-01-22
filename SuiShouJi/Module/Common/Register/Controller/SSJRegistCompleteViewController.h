//
//  SSJRegistCompleteViewController.h
//  YYDB
//
//  Created by cdd on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

//  注册\忘记密码 设置密码完成验证

#import "SSJBaseViewController.h"
#import "UIViewController+SSJPageFlow.h"

@interface SSJRegistCompleteViewController : SSJBaseViewController

/**
 *  标准初始化方法
 *
 *  @param type 区分是注册还是忘记密码
 *  @param mobileNo 手机号
 *  @param authCode 验证码
 */
- (instancetype)initWithRegistAndForgetType:(SSJRegistAndForgetPasswordType)type
                                   mobileNo:(NSString *)mobileNo
                                   authCode:(NSString *)authCode;

@end
