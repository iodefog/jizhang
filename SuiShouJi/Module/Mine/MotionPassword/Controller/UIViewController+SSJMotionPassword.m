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
#import "SSJLoginVerifyPhoneViewController.h"

#import "UIViewController+SSJPageFlow.h"
#import "SSJStartUpgradeAlertView.h"
#import "SSJUserTableManager.h"
#import <LocalAuthentication/LocalAuthentication.h>


@implementation UIViewController (SSJMotionPassword)

+ (void)verifyMotionPasswordIfNeeded:(void(^)(BOOL isVerified))completion animated:(BOOL)animated {
    if (!SSJIsUserLogined()) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    // 如果当前页面已经是手势密码或者指纹解锁，直接返回
    UIViewController *currentVC = SSJVisibalController();
    if ([currentVC isKindOfClass:[SSJMotionPasswordViewController class]]
        || [currentVC isKindOfClass:[SSJFingerprintPWDViewController class]]) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    [SSJUserTableManager queryProperty:@[@"motionPWD", @"motionPWDState", @"fingerPrintState"] forUserId:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
        
        BOOL motionPwdOpened = [userItem.motionPWDState boolValue] && userItem.motionPWD.length;
        
        LAContext *context = [[LAContext alloc] init];
        context.localizedFallbackTitle = @"";
        BOOL fingerPwdOpened = [userItem.fingerPrintState boolValue];
        
        NSError *error = nil;
        BOOL canEvaluateFingerPwd = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
        BOOL touchIDChanged = NO;
        if (fingerPwdOpened
            && context.evaluatedPolicyDomainState
            && SSJEvaluatedPolicyDomainState()) {
            touchIDChanged = ![context.evaluatedPolicyDomainState isEqualToData:SSJEvaluatedPolicyDomainState()];
        }
        
        if (motionPwdOpened) {
            // 验证手势密码页面
            SSJMotionPasswordViewController *motionVC = [[SSJMotionPasswordViewController alloc] init];
            motionVC.type = SSJMotionPasswordViewControllerTypeVerification;
            motionVC.finishHandle = ^(UIViewController *controller) {
                if (completion) {
                    completion(YES);
                }
            };
            SSJNavigationController *naviVC = [[SSJNavigationController alloc] initWithRootViewController:motionVC];
            [currentVC presentViewController:naviVC animated:animated completion:NULL];
            
        } else if (fingerPwdOpened
                   && canEvaluateFingerPwd
                   && !touchIDChanged) {
            // 验证指纹密码页面
            SSJFingerprintPWDViewController *fingerPwdVC = [[SSJFingerprintPWDViewController alloc] init];
            fingerPwdVC.context = context;
            fingerPwdVC.finishHandle = ^(UIViewController *controller) {
                if (completion) {
                    completion(YES);
                }
            };
            SSJNavigationController *naviVC = [[SSJNavigationController alloc] initWithRootViewController:fingerPwdVC];
            [currentVC presentViewController:naviVC animated:animated completion:NULL];
            
        } else if (error.code == LAErrorTouchIDNotEnrolled || touchIDChanged) {
            // 重新登录
            [SSJUserTableManager reloadUserIdWithSuccess:^{
                SSJLoginVerifyPhoneViewController *loginVC = [[SSJLoginVerifyPhoneViewController alloc] init];
                loginVC.finishHandle = ^(UIViewController *controller) {
                    if (error.code == LAErrorTouchIDNotEnrolled) {
                        // 没有指纹录入要把指纹数据清空并且关闭指纹开关
                        SSJUpdateEvaluatedPolicyDomainState(nil);
                        userItem.fingerPrintState = @"0";
                        [SSJUserTableManager saveUserItem:userItem success:NULL failure:^(NSError * _Nonnull error) {
                            [CDAutoHideMessageHUD showMessage:error.localizedDescription];
                        }];
                    } else {
                        // 登录成功后保存新的指纹数据
                        SSJUpdateEvaluatedPolicyDomainState(context.evaluatedPolicyDomainState);
                    }
                    
                    if (completion) {
                        completion(YES);
                    }
                };
                SSJNavigationController *naviVC = [[SSJNavigationController alloc] initWithRootViewController:loginVC];
                [currentVC presentViewController:naviVC animated:animated completion:NULL];
                
                if (error.code == LAErrorTouchIDNotEnrolled) {
                    [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"您的指纹信息已被移除，请重新登录，若要重新开启指纹密码，请先在系统设置中添加指纹" action:[SSJAlertViewAction actionWithTitle:@"知道了" handler:NULL], nil];
                } else {
                    [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"您的指纹信息发生变更，请重新登录" action:[SSJAlertViewAction actionWithTitle:@"知道了" handler:NULL], nil];
                }
                
            } failure:^(NSError * _Nonnull error) {
                [SSJAlertViewAdapter showError:error];
            }];
        } else {
            if (completion) {
                completion(NO);
            }
        }
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
        if (completion) {
            completion(NO);
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
