//
//  SSJLoginSecondViewController.h
//  SuiShouJi
//
//  Created by yi cai on 2017/6/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJLoginCommonViewController.h"
@class SSJLoginVerifyPhoneNumViewModel;

@interface SSRegisterAndLoginViewController : SSJLoginCommonViewController

/**注册or忘记密码*/
@property (nonatomic, assign) SSJRegistAndForgetPasswordType regOrForgetType;

/**phone*/
@property (nonatomic, copy) NSString *phoneNum;

@end
