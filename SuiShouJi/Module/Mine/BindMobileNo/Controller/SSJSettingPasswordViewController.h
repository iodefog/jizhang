//
//  SSJSettingPasswordViewController.h
//  SuiShouJi
//
//  Created by old lang on 2017/6/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//
//  重置密码、绑定手机号设置密码
#import "SSJBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 类型

 - SSJSettingPasswordTypeMobileNoBinding: 绑定手机号
 - SSJSettingPasswordTypeResettingPassword: 重置密码
 */
typedef NS_ENUM(NSInteger, SSJSettingPasswordType) {
    SSJSettingPasswordTypeMobileNoBinding,
    SSJSettingPasswordTypeResettingPassword
};

@interface SSJSettingPasswordViewController : SSJBaseViewController

/**
 指定是绑定手机号还是重置密码
 */
@property (nonatomic) SSJSettingPasswordType type;

/**
 手机号
 */
@property (nonatomic, copy) NSString *mobileNo;

@end

NS_ASSUME_NONNULL_END
