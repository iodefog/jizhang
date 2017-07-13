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
    
    [SSJUserTableManager reloadUserIdWithSuccess:^{
        SSJLoginVerifyPhoneViewController *loginVC = [[SSJLoginVerifyPhoneViewController alloc] initWithNibName:nil bundle:nil];
        SSJNavigationController *naviVC = [[SSJNavigationController alloc] initWithRootViewController:loginVC];
        [currentVC presentViewController:naviVC animated:YES completion:NULL];
    } failure:^(NSError * _Nonnull error) {
        [CDAutoHideMessageHUD showMessage:error.localizedDescription];
    }];
    
    return YES;
}

@end
