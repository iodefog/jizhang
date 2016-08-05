//
//  UIViewController+SSJMotionPassword.m
//  SuiShouJi
//
//  Created by old lang on 16/8/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "UIViewController+SSJMotionPassword.h"
#import "SSJUserTableManager.h"
#import "SSJStartUpgradeAlertView.h"
#import "SSJMotionPasswordViewController.h"
#import "UIViewController+SSJPageFlow.h"

static NSString *const kRemindUserSettingMotionPasswordKey = @"kRemindUserSettingMotionPasswordKey";

BOOL SSJHasRemindUserSettingMotionPassword() {
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kRemindUserSettingMotionPasswordKey];
    if (SSJUSERID()) {
        return dic[SSJUSERID()];
    } else {
        return NO;
    }
}

void SSJDidRemindUserSettingMotionPassword() {
    if (SSJUSERID()) {
        NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:kRemindUserSettingMotionPasswordKey] mutableCopy];
        if (!dic) {
            dic = [NSMutableDictionary dictionary];
        }
        [dic setObject:@YES forKey:SSJUSERID()];
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kRemindUserSettingMotionPasswordKey];
    }
}

@implementation UIViewController (SSJMotionPassword)

- (void)ssj_remindUserToSetMotionPasswordIfNeeded {
    if (!SSJIsUserLogined()) {
        return;
    }
    
    SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"motionPWD"] forUserId:SSJUSERID()];
    if (!SSJHasRemindUserSettingMotionPassword() && !userItem.motionPWD.length) {
        
        __weak typeof(self) weakSelf = self;
        
//        NSAttributedString *message = [[NSAttributedString alloc] initWithString:@"为保障您的隐私，建议您设置下手势密码哦！" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]}];
//        
//        SSJStartUpgradeAlertView *alert = [[SSJStartUpgradeAlertView alloc] initWithTitle:nil message:message cancelButtonTitle:@"取消" sureButtonTitle:@"确定" cancelButtonClickHandler:^(SSJStartUpgradeAlertView * _Nonnull alert){
//            [alert dismiss];
//            SSJDidRemindUserSettingMotionPassword();
//        } sureButtonClickHandler:^(SSJStartUpgradeAlertView * _Nonnull alert) {
//            [alert dismiss];
//            SSJDidRemindUserSettingMotionPassword();
//            
//            SSJMotionPasswordViewController *motionVC = [[SSJMotionPasswordViewController alloc] init];
//            motionVC.finishHandle = weakSelf.finishHandle;
//            motionVC.backController = weakSelf.backController;
//            motionVC.type = SSJMotionPasswordViewControllerTypeSetting;
//            [weakSelf.navigationController pushViewController:motionVC animated:YES];
//        }];
//        [alert show];
        
        [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"手机上的记账数据将重新从云端获取，若您多个手机使用APP且数据不一致时可重新拉取，请在WIFi下操作。" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:^(SSJAlertViewAction * _Nonnull action) {
            SSJDidRemindUserSettingMotionPassword();
        }], [SSJAlertViewAction actionWithTitle:@"立即拉取" handler:^(SSJAlertViewAction * _Nonnull action) {
            SSJDidRemindUserSettingMotionPassword();
            SSJMotionPasswordViewController *motionVC = [[SSJMotionPasswordViewController alloc] init];
            motionVC.finishHandle = weakSelf.finishHandle;
            motionVC.backController = weakSelf.backController;
            motionVC.type = SSJMotionPasswordViewControllerTypeSetting;
            [weakSelf.navigationController pushViewController:motionVC animated:YES];
        }], nil];
    }
}

@end
