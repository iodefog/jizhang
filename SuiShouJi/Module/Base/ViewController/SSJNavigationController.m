//
//  SSJNavigationController.m
//  SuiShouJi
//
//  Created by old lang on 17/4/7.
//  Copyright © 2017年 MZL. All rights reserved.
//

#import "SSJNavigationController.h"

@interface SSJNavigationController ()

@end

@implementation SSJNavigationController

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

@end
