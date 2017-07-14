//
//  SSJNavigationController.m
//  SuiShouJi
//
//  Created by old lang on 17/4/7.
//  Copyright © 2017年 MZL. All rights reserved.
//

#import "SSJNavigationController.h"
#import <objc/runtime.h>

static const void *kHidesNavigationBarWhenPushedKey = &kHidesNavigationBarWhenPushedKey;

@implementation UIViewController (SSJNavigationController)

- (BOOL)ssj_hidesNavigationBarWhenPushed {
    return [objc_getAssociatedObject(self, kHidesNavigationBarWhenPushedKey) boolValue];
}

- (void)ssj_setHidesNavigationBarWhenPushed:(BOOL)hidesNavigationBarWhenPushed {
    objc_setAssociatedObject(self, kHidesNavigationBarWhenPushedKey, @(hidesNavigationBarWhenPushed), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface SSJNavigationController () <UINavigationControllerDelegate>

@end

@implementation SSJNavigationController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.delegate = self;
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.delegate = self;
    }
    return self;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

- (void)setCustomDelegate:(id<SSJNavigationControllerDelegate>)customDelegate {
    _customDelegate = customDelegate;
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    if (delegate == self) {
        [super setDelegate:delegate];
    }
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [navigationController setNavigationBarHidden:viewController.hidesNavigationBarWhenPushed animated:animated];
    if (_customDelegate && [_customDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [_customDelegate navigationController:self willShowViewController:viewController animated:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (_customDelegate && [_customDelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [_customDelegate navigationController:self didShowViewController:viewController animated:animated];
    }
}

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    if (_customDelegate && [_customDelegate respondsToSelector:@selector(navigationControllerSupportedInterfaceOrientations:)]) {
        return [_customDelegate navigationControllerSupportedInterfaceOrientations:navigationController];
    }
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController {
    if (_customDelegate && [_customDelegate respondsToSelector:@selector(navigationControllerPreferredInterfaceOrientationForPresentation:)]) {
        return [_customDelegate navigationControllerPreferredInterfaceOrientationForPresentation:navigationController];
    }
    return UIInterfaceOrientationPortrait;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
    if (_customDelegate && [_customDelegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        return [_customDelegate navigationController:navigationController interactionControllerForAnimationController:animationController];
    }
    return nil;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    if (_customDelegate && [_customDelegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
        return [_customDelegate navigationController:navigationController animationControllerForOperation:operation fromViewController:fromVC toViewController:toVC];
    }
    return nil;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:YES];
}
@end
