//
//  SSJRegistCheckAuthCodeViewController.h
//  YYDB
//
//  Created by old lang on 15/10/29.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

//  注册\忘记密码 验证验证码

#import "SSJBaseViewController.h"
#import "UIViewController+SSJPageFlow.h"

@interface SSJRegistCheckAuthCodeViewController : SSJBaseViewController

/**
 *  标准初始化方法
 *
 *  @param type 区分是注册还是忘记密码
 *  @param mobileNo 手机号
 */
- (instancetype)initWithRegistAndForgetType:(SSJRegistAndForgetPasswordType)type
                                   mobileNo:(NSString *)mobileNo;

@end
