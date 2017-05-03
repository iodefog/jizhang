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
    [SSJUserTableManager reloadUserIdWithError:nil];
    
    __weak typeof(currentVC) weakVC = currentVC;
    SSJLoginViewController *loginVC = [[SSJLoginViewController alloc] initWithNibName:nil bundle:nil];
    loginVC.finishHandle = ^(UIViewController *controller) {
        controller.backController = weakVC;
        [controller ssj_backOffAction];
    };
    loginVC.cancelHandle = ^(UIViewController *controller) {
        controller.backController = [weakVC ssj_previousViewController];
        [controller ssj_backOffAction];
    };
    
//    [loginVC ssj_showBackButtonWithTarget:loginVC selector:@selector(backOffAction)];
    SSJNavigationController *naviVC = [[SSJNavigationController alloc] initWithRootViewController:loginVC];
    [currentVC presentViewController:naviVC animated:YES completion:NULL];
    
    return YES;
}

@end
