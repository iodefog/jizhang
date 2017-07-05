//
//  UIViewController+SSJMotionPassword.m
//  SuiShouJi
//
//  Created by old lang on 16/8/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "UIViewController+SSJMotionPassword.h"
#import "SSJNavigationController.h"
#import "SSJFingerprintPWDViewController.h"
#import "SSJMotionPasswordViewController.h"

#import "UIViewController+SSJPageFlow.h"
#import "SSJStartUpgradeAlertView.h"
#import "SSJUserTableManager.h"
#import <LocalAuthentication/LocalAuthentication.h>


@implementation UIViewController (SSJMotionPassword)

+ (void)verifyMotionPasswordIfNeeded:(void (^)(BOOL isVerified))finish animated:(BOOL)animated {
    if (!SSJIsUserLogined()) {
        if (finish) {
            finish(NO);
        }
        return;
    }
    
    // 如果当前页面已经是手势密码或者指纹解锁，直接返回
    UIViewController *currentVC = SSJVisibalController();
    if ([currentVC isKindOfClass:[SSJMotionPasswordViewController class]]
        || [currentVC isKindOfClass:[SSJFingerprintPWDViewController class]]) {
        if (finish) {
            finish(NO);
        }
        return;
    }
    
    [SSJUserTableManager queryProperty:@[@"motionPWD", @"motionPWDState", @"fingerPrintState"] forUserId:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
        
        LAContext *context = [[LAContext alloc] init];
        context.localizedFallbackTitle = @"";
        BOOL fingerPwdOpened = [userItem.fingerPrintState boolValue] && [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
        BOOL motionPwdOpened = [userItem.motionPWDState boolValue] && userItem.motionPWD.length;
        
        if ((motionPwdOpened && fingerPwdOpened) || motionPwdOpened) {
            // 验证手势密码页面
            SSJMotionPasswordViewController *motionVC = [[SSJMotionPasswordViewController alloc] init];
            motionVC.type = SSJMotionPasswordViewControllerTypeVerification;
            motionVC.finishHandle = ^(UIViewController *controller) {
                if (finish) {
                    finish(YES);
                }
                [controller dismissViewControllerAnimated:YES completion:NULL];
            };
            SSJNavigationController *naviVC = [[SSJNavigationController alloc] initWithRootViewController:motionVC];
            [currentVC presentViewController:naviVC animated:animated completion:NULL];
        } else if (fingerPwdOpened) {
            SSJFingerprintPWDViewController *fingerPwdVC = [[SSJFingerprintPWDViewController alloc] init];
            fingerPwdVC.context = context;
            fingerPwdVC.finishHandle = ^(UIViewController *controller) {
                if (finish) {
                    finish(YES);
                }
                [controller dismissViewControllerAnimated:YES completion:NULL];
            };
            SSJNavigationController *naviVC = [[SSJNavigationController alloc] initWithRootViewController:fingerPwdVC];
            [currentVC presentViewController:naviVC animated:animated completion:NULL];
        } else {
            if (finish) {
                finish(NO);
            }
        }
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
        if (finish) {
            finish(NO);
        }
    }];
}

- (void)ssj_remindUserToSetMotionPasswordIfNeeded {
    if (!SSJIsUserLogined()) {
        return;
    }
    
    NSString *userId = SSJUSERID();
    
    [SSJUserTableManager queryProperty:@[@"motionPWD", @"remindSettingMotionPWD"] forUserId:userId success:^(SSJUserItem * _Nonnull userItem) {
        if (![userItem.remindSettingMotionPWD boolValue] && !userItem.motionPWD.length) {
            __weak typeof(self) weakSelf = self;
            [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"为保障您的隐私，建议您设置下手势密码哦！" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:^(SSJAlertViewAction * _Nonnull action) {
                
                userItem.remindSettingMotionPWD = @"1";
                [SSJUserTableManager saveUserItem:userItem success:NULL failure:^(NSError * _Nonnull error) {
                    [SSJAlertViewAdapter showError:error];
                }];
                
            }], [SSJAlertViewAction actionWithTitle:@"立即设置" handler:^(SSJAlertViewAction * _Nonnull action) {
                
                userItem.remindSettingMotionPWD = @"1";
                [SSJUserTableManager saveUserItem:userItem success:NULL failure:^(NSError * _Nonnull error) {
                    [SSJAlertViewAdapter showError:error];
                }];
                
                SSJMotionPasswordViewController *motionVC = [[SSJMotionPasswordViewController alloc] init];
                motionVC.finishHandle = weakSelf.finishHandle;
                motionVC.backController = weakSelf.backController;
                motionVC.type = SSJMotionPasswordViewControllerTypeSetting;
                [weakSelf.navigationController pushViewController:motionVC animated:YES];
            }], nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

@end
