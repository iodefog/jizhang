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

typedef NS_ENUM(NSInteger, SSJSettingPasswordType) {
    SSJSettingPasswordTypeMobileNoBinding,
    SSJSettingPasswordTypeResettingPassword
};

@interface SSJSettingPasswordViewController : SSJBaseViewController

@property (nonatomic) SSJSettingPasswordType type;

@end

NS_ASSUME_NONNULL_END
