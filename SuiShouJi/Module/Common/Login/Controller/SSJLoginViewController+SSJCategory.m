//
//  SSJLoginViewController+SSJCategory.m
//  SuiShouJi
//
//  Created by old lang on 16/9/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoginViewController+SSJCategory.h"
#import "UIViewController+SSJPageFlow.h"
#import "SSJUserTableManager.h"
#import "SSJNavigationController.h"

@implementation SSJLoginViewController (SSJCategory)

+ (BOOL)reloginIfNeeded {
    UIViewController *currentVC = SSJVisibalController();
    if ([currentVC isKindOfClass:[SSJLoginViewController class]]) {
        return NO;
    }
    
    SSJClearLoginInfo();
    [SSJUserTableManager reloadUserIdWithSuccess:^{
        __weak typeof(currentVC) weak_currentVc = currentVC;
        SSJLoginViewController *loginVC = [[SSJLoginViewController alloc] initWithNibName:nil bundle:nil];
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
