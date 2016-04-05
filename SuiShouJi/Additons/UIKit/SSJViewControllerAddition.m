//
//  SSJViewControllerAddition.m
//  MoneyMore
//
//  Created by old lang on 15-5-21.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJViewControllerAddition.h"
#import <objc/runtime.h>

//@interface SSJNavigationControllerDelegator : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
//
//@property (nonatomic, weak) id<UINavigationControllerDelegate, UIImagePickerControllerDelegate> delegate;
//
//@end
//
//@implementation SSJNavigationControllerDelegator
//
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    [navigationController setNavigationBarHidden:viewController.hidesNavigationBarWhenPushed];
////    [navigationController setNavigationBarHidden:viewController.hidesNavigationBarWhenPushed animated:YES];
//    
//    if (_delegate && [_delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
//        [_delegate navigationController:navigationController willShowViewController:viewController animated:animated];
//    }
//}
//
//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    if (_delegate && [_delegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
//        [_delegate navigationController:navigationController didShowViewController:viewController animated:animated];
//    }
//}
//
//- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
//    if (_delegate && [_delegate respondsToSelector:@selector(navigationControllerSupportedInterfaceOrientations:)]) {
//        return [_delegate navigationControllerSupportedInterfaceOrientations:navigationController];
//    }
//    return UIInterfaceOrientationMaskPortrait;
//}
//
//- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController {
//    if (_delegate && [_delegate respondsToSelector:@selector(navigationControllerPreferredInterfaceOrientationForPresentation:)]) {
//        return [_delegate navigationControllerPreferredInterfaceOrientationForPresentation:navigationController];
//    }
//    return UIInterfaceOrientationPortrait;
//}
//
//- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
//                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
//    if (_delegate && [_delegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
//        return [_delegate navigationController:navigationController interactionControllerForAnimationController:animationController];
//    }
//    return nil;
//}
//
//- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
//                                            animationControllerForOperation:(UINavigationControllerOperation)operation
//                                                         fromViewController:(UIViewController *)fromVC
//                                                           toViewController:(UIViewController *)toVC  {
//    if (_delegate && [_delegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
//        return [_delegate navigationController:navigationController animationControllerForOperation:operation fromViewController:fromVC toViewController:toVC];
//    }
//    return nil;
//}
//
//#pragma mark - UIImagePickerControllerDelegate
////- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
////    if (_delegate && [_delegate respondsToSelector:@selector(imagePickerController:didFinishPickingImage:editingInfo:)]) {
////        [_delegate imagePickerController:picker didFinishPickingImage:image editingInfo:editingInfo];
////    }
////}
//
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
//    if (_delegate && [_delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)]) {
//        [_delegate imagePickerController:picker didFinishPickingMediaWithInfo:info];
//    }
//}
//
//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//    if (_delegate && [_delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
//        [_delegate imagePickerControllerDidCancel:picker];
//    }
//}
//
//@end

@interface UINavigationController (SSJDelegateForward)

@end

static const void *kDelegatorKey = &kDelegatorKey;
static const void *kForwardDelegatorKey = &kForwardDelegatorKey;

@implementation UINavigationController (SSJDelegateForward)

//+ (void)load {
//    Method originalMethod = class_getInstanceMethod([self class], @selector(setDelegate:));
//    Method swizzledMethod = class_getInstanceMethod([self class], @selector(ssj_setDelegate:));
//    method_exchangeImplementations(originalMethod, swizzledMethod);
//}

//- (void)ssj_setDelegate:(id<UINavigationControllerDelegate>)delegate {
//    [self delegator].delegate = delegate;
//    [self ssj_setDelegate:[self delegator]];
//    
//    objc_setAssociatedObject(self, kForwardDelegatorKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (SSJNavigationControllerDelegator *)delegator {
//    SSJNavigationControllerDelegator *delegator = objc_getAssociatedObject(self, kDelegatorKey);
//    if (!delegator) {
//        delegator = [[SSJNavigationControllerDelegator alloc] init];
//        objc_setAssociatedObject(self, kDelegatorKey, delegator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return delegator;
//}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

static const void *kNavigationBarHiddenKey = &kNavigationBarHiddenKey;
static const void *kBackControllerKey = &kBackControllerKey;

@implementation UIViewController (SSJNavigationStack)

- (void)setHidesNavigationBarWhenPushed:(BOOL)hidesNavigationBarWhenPushed {
    objc_setAssociatedObject(self, kNavigationBarHiddenKey, @(hidesNavigationBarWhenPushed), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hidesNavigationBarWhenPushed {
    return [objc_getAssociatedObject(self, kNavigationBarHiddenKey) boolValue];
}

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
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:selector];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    id<UINavigationControllerDelegate> delegate = (id)self;
    self.navigationController.delegate = delegate;
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

- (UIViewController *)ssj_previousViewControllerBySubtractingIndex:(NSInteger)index {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1) {
        NSUInteger currentIndex = [viewControllers indexOfObject:self];
        if (currentIndex != NSNotFound && currentIndex >= index) {
            return [viewControllers objectAtIndex:(currentIndex - index)];
        }
    }
    
    return nil;
}

- (UIViewController *)ssj_nextViewControllerByAddingIndex:(NSInteger)index {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1) {
        NSUInteger currentIndex = [viewControllers indexOfObject:self];
        if (currentIndex != NSNotFound && currentIndex + index < viewControllers.count) {
            return [viewControllers objectAtIndex:(currentIndex + index)];
        }
    }
    
    return nil;
}

@end
