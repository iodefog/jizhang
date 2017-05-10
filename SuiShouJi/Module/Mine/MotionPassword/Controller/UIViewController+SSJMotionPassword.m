//
//  UIViewController+SSJMotionPassword.m
//  SuiShouJi
//
//  Created by old lang on 16/8/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "UIViewController+SSJMotionPassword.h"
#import "SSJStartUpgradeAlertView.h"
#import "SSJMotionPasswordViewController.h"
#import "UIViewController+SSJPageFlow.h"
#import "SSJUserTableManager.h"

@implementation UIViewController (SSJMotionPassword)

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
