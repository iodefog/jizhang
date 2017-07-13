//
//  SSJLoginNavigator.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/13.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJLoginNavigator.h"
#import "SSJNavigationController.h"
#import "SSJLoginVerifyPhoneViewController.h"
#import "SSJLoginPhoneViewController.h"
#import "SSRegisterAndLoginViewController.h"
#import "SSJMotionPasswordViewController.h"
#import "SSJBindMobileNoViewController.h"
#import "SSJSettingPasswordViewController.h"
#import "SSJUserTableManager.h"

@interface SSJLoginNavigator ()

@property (nonatomic) SSJLoginType loginType;

@property (nonatomic) SSJNavigationType navigationType;

@property (nonatomic) BOOL motionPwdForgeted;

@property (nonatomic, strong) SSJNavigationController *navigationVC;

@property (nonatomic, strong) UIViewController *sourceController;

@property (nonatomic, copy) void (^finishHandler)();

@property (nonatomic, strong) NSError *lastError;

@end

@implementation SSJLoginNavigator

+ (instancetype)sharedNavigator {
    static SSJLoginNavigator *navigator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        navigator = [[SSJLoginNavigator alloc] init];
    });
    return navigator;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)beginLoginWithSourceController:(UIViewController *)sourceController
                              mobileNo:(NSString *)mobileNo
                             loginType:(SSJLoginType)loginType
                        navigationType:(SSJNavigationType)navigationType
                     motionPwdForgeted:(BOOL)motionPwdForgeted
                         finishHandler:(void(^)())finishHandler {
    self.loginType = loginType;
    self.navigationType = navigationType;
    self.motionPwdForgeted = motionPwdForgeted;
    self.finishHandler = finishHandler;
    self.sourceController = sourceController;
    
    SSJLoginVerifyPhoneViewController *verifyMobileVC = [[SSJLoginVerifyPhoneViewController alloc] init];
    verifyMobileVC.mobileNo = mobileNo;
    
    switch (navigationType) {
        case SSJNavigationTypePush:
            if ([sourceController isKindOfClass:[SSJNavigationController class]]) {
                self.navigationVC = (SSJNavigationController *)sourceController;
            } else {
                if ([sourceController.navigationController isKindOfClass:[SSJNavigationController class]]) {
                    self.navigationVC = (SSJNavigationController *)sourceController.navigationController;
                } else {
                    self.lastError = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"源控制器的导航控制器为nil或者不是SSJNavigationController的实例"}];
                }
            }
            
            if (self.navigationVC) {
                [self.navigationVC pushViewController:verifyMobileVC animated:YES];
            }
            
            break;
            
        case SSJNavigationTypePresent:
            self.navigationVC = [[SSJNavigationController alloc] initWithRootViewController:verifyMobileVC];
            [sourceController presentViewController:self.navigationVC animated:YES completion:NULL];
            break;
    }
}

- (void)finishMobileNoVerification:(NSString *)mobileNo registered:(BOOL)registered {
    if (registered) {
        SSJLoginPhoneViewController *verifyPwdVC = [[SSJLoginPhoneViewController alloc] init];
        verifyPwdVC.phoneNum = mobileNo;
        [self.navigationVC pushViewController:verifyPwdVC animated:YES];
    } else {
        SSRegisterAndLoginViewController *registerVC = [[SSRegisterAndLoginViewController alloc] init];
        registerVC.phoneNum = mobileNo;
        registerVC.regOrForgetType = SSJRegistAndForgetPasswordTypeRegist;
        [self.navigationVC pushViewController:registerVC animated:YES];
    }
}

- (void)finishMobileNoLogin {
    if (self.motionPwdForgeted) {
        SSJMotionPasswordViewController *motionSettingVC = [[SSJMotionPasswordViewController alloc] init];
        motionSettingVC.type = SSJMotionPasswordViewControllerTypeSetting;
        motionSettingVC.loginNavigator = self;
        [self.navigationVC pushViewController:motionSettingVC animated:YES];
    } else {
        [self finishLoginNavigation];
    }
}

- (void)finishMotionPwdSetting {
    if (self.loginType == SSJLoginTypeNormal) {
        [self finishLoginNavigation];
    } else {
        [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
            if (userItem.mobileNo.length) {
                [self finishLoginNavigation];
            } else {
                SSJBindMobileNoViewController *bindMobileNoVC = [[SSJBindMobileNoViewController alloc] init];
                [self.navigationVC pushViewController:bindMobileNoVC animated:YES];
            }
        } failure:^(NSError * _Nonnull error) {
            self.lastError = error;
        }];
    }
}

- (void)beginForgetPwd {
    SSJLoginPhoneViewController *verifyPwdVC = [self.navigationVC.viewControllers lastObject];
    SSRegisterAndLoginViewController *forgetPwdVC = [[SSRegisterAndLoginViewController alloc] init];
    forgetPwdVC.titleL.text = @"忘记密码";
    forgetPwdVC.phoneNum = verifyPwdVC.phoneNum;
    forgetPwdVC.regOrForgetType = SSJRegistAndForgetPasswordTypeForgetPassword;
    [self.navigationVC pushViewController:forgetPwdVC animated:YES];
}

- (void)finishForgetPwd {
    if (self.motionPwdForgeted) {
        SSJMotionPasswordViewController *motionSettingVC = [[SSJMotionPasswordViewController alloc] init];
        motionSettingVC.type = SSJMotionPasswordViewControllerTypeSetting;
        motionSettingVC.loginNavigator = self;
        [self.navigationVC pushViewController:motionSettingVC animated:YES];
    } else {
        [self finishLoginNavigation];
    }
}

- (void)finishRegistration {
    [self finishLoginNavigation];
}

- (void)finishThirdPartLogin {
    if (self.motionPwdForgeted) {
        SSJMotionPasswordViewController *motionSettingVC = [[SSJMotionPasswordViewController alloc] init];
        motionSettingVC.type = SSJMotionPasswordViewControllerTypeSetting;
        motionSettingVC.loginNavigator = self;
        [self.navigationVC pushViewController:motionSettingVC animated:YES];
    } else {
        [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
            if (userItem.mobileNo.length) {
                [self finishLoginNavigation];
            } else {
                SSJBindMobileNoViewController *bindMobileNoVC = [[SSJBindMobileNoViewController alloc] init];
                [self.navigationVC pushViewController:bindMobileNoVC animated:YES];
            }
        } failure:^(NSError * _Nonnull error) {
            self.lastError = error;
        }];
    }
}

- (void)finishBindingMobileNo {
    [self finishLoginNavigation];
}

- (void)finishLoginNavigation {
    if (self.finishHandler) {
        self.finishHandler();
        self.finishHandler = nil;
    }
    
    switch (self.navigationType) {
        case SSJNavigationTypePush:
            [self.navigationVC dismissViewControllerAnimated:YES completion:NULL];
            break;
            
        case SSJNavigationTypePresent:
            [self.navigationVC popToViewController:self.sourceController animated:YES];
            break;
    }
    
    self.navigationVC = nil;
    self.sourceController = nil;
    self.motionPwdForgeted = NO;
}

@end
