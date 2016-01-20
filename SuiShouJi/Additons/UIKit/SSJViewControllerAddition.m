//
//  SSJViewControllerAddition.m
//  MoneyMore
//
//  Created by old lang on 15-5-21.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJViewControllerAddition.h"
#import <objc/runtime.h>

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

static const void *kBackControllerKey = &kBackControllerKey;

@implementation UIViewController (SSJNavigationStack)

- (void)setBackController:(UIViewController *)backController {
    objc_setAssociatedObject(self, kBackControllerKey, backController, OBJC_ASSOCIATION_ASSIGN);
}

- (UIViewController *)backController {
    return objc_getAssociatedObject(self, kBackControllerKey);
}

- (void)ssj_showBackButtonWithTarget:(id)target selector:(SEL)selector {
    [self ssj_showBackButtonWithImage:[UIImage imageNamed:@"navigation_backOff"] target:target selector:selector];
}

- (void)ssj_showBackButtonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector {
    UIButton *backoffButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backoffButton setFrame:CGRectMake(0, 0, 30, 30)];
    [backoffButton setImage:image forState:UIControlStateNormal];
    [backoffButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, backoffButton.width - image.size.width)];
    if ([self respondsToSelector:selector]) {
        [backoffButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backoffButton];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)ssj_backOffAction {
    if (!self.backController) {
        if (self.navigationController.viewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        return;
    }
    
    if ([self.backController.navigationController.viewControllers containsObject:self]) {
        [self.backController.navigationController popToViewController:self.backController animated:YES];
        return;
    }
    
    if ([self.backController.tabBarController.viewControllers containsObject:self]) {
        [self.backController.tabBarController setSelectedViewController:self.backController];
        return;
    }
    
    if (self.backController.presentedViewController == self) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if ([self.backController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *naviVC = (UINavigationController *)self.backController.presentedViewController;
        if ([naviVC.viewControllers containsObject:self]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            if ([self.backController.parentViewController isKindOfClass:[UINavigationController class]]) {
                [self.backController.navigationController popToViewController:self.backController animated:NO];
            } else if ([self.backController.parentViewController isKindOfClass:[UITabBarController class]]) {
                [self.backController.tabBarController setSelectedViewController:self.backController];
            }
            return;
        }
    }
    
    if ([self.backController.presentedViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabVC = (UITabBarController *)self.backController.presentedViewController;
        if ([tabVC.viewControllers containsObject:self]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            if ([self.backController.parentViewController isKindOfClass:[UINavigationController class]]) {
                [self.backController.navigationController popToViewController:self.backController animated:NO];
            } else if ([self.backController.parentViewController isKindOfClass:[UITabBarController class]]) {
                [self.backController.tabBarController setSelectedViewController:self.backController];
            }
            return;
        }
    }
    
    for (UINavigationController *navi in self.tabBarController.viewControllers) {
        if ([navi isKindOfClass:[UINavigationController class]]) {
            if ([navi.viewControllers containsObject:self.backController]) {
                [self.backController.tabBarController setSelectedViewController:navi];
                [self.navigationController popToRootViewControllerAnimated:YES];
                return;
            }
        }
    }
}

- (UIViewController *)ssj_nextViewController {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1) {
        NSUInteger controllerIndex = [viewControllers indexOfObject:self];
        if (controllerIndex != NSNotFound && (controllerIndex + 1) < viewControllers.count) {
            return [viewControllers objectAtIndex:(controllerIndex + 1)];
        }
    }
    return nil;
}

- (UIViewController *)ssj_previousViewController {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1) {
        NSUInteger controllerIndex = [viewControllers indexOfObject:self];
        if (controllerIndex != NSNotFound && controllerIndex >= 1) {
            return [viewControllers objectAtIndex:(controllerIndex - 1)];
        }
    }
    return nil;
}

@end
