//
//  SSJRegistGetVerViewController.h
//  YYDB
//
//  Created by cdd on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

//  注册\忘记密码 获取验证码

#import "SSJBaseViewController.h"
//#import "UIViewController+SSJPageFlow.h"

@interface SSJRegistGetVerViewController : SSJBaseViewController

//  忘记密码手机号，如果是从注册页面“提示手机号已注册，是否忘记密码”进入，传此参数
@property (nonatomic, copy) NSString *forgetMobileNo;

/**
 *  标准初始化方法
 *
 *  @param type 区分是注册还是忘记密码
 */
- (instancetype)initWithRegistAndForgetType:(SSJRegistAndForgetPasswordType)type;

@end
