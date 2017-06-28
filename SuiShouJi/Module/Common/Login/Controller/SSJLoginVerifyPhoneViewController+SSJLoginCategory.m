//
//  SSJLoginVerifyPhoneViewController+SSJLoginCategory.m
//  SuiShouJi
//
//  Created by yi cai on 2017/6/28.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJLoginVerifyPhoneViewController+SSJLoginCategory.h"
#import "UIViewController+SSJPageFlow.h"
#import "SSJNavigationController.h"

#import "SSJUserTableManager.h"

@implementation SSJLoginVerifyPhoneViewController (SSJLoginCategory)
+ (BOOL)reloginIfNeeded {
    UIViewController *currentVC = SSJVisibalController();
    if ([currentVC isKindOfClass:[SSJLoginVerifyPhoneViewController class]]) {
        return NO;
    }
    
    SSJClearLoginInfo();
    [SSJUserTableManager reloadUserIdWithSuccess:^{
        __weak typeof(currentVC) weak_currentVc = currentVC;
        SSJLoginVerifyPhoneViewController *loginVC = [[SSJLoginVerifyPhoneViewController alloc] initWithNibName:nil bundle:nil];
        loginVC.finishHandle = ^(UIViewController *controller) {
            controller.backController = weak_currentVc;
            [controller ssj_backOffAction];
        };
        loginVC.cancelHandle = ^(UIViewController *controller) {
            controller.backController = [weak_currentVc ssj_previousViewController];
            [controller ssj_backOffAction];
        };
        SSJNavigationController *naviVC = [[SSJNavigationController alloc] initWithRootViewController:loginVC];
        [currentVC presentViewController:naviVC animated:YES completion:NULL];
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
    
    return YES;
}

@end
