//
//  UIView+SSJViewAnimatioin.m
//  SuiShouJi
//
//  Created by old lang on 16/4/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "UIView+SSJViewAnimatioin.h"
#import <objc/runtime.h>

static const void *kSSJViewAnimatioinBackgroundViewKey = &kSSJViewAnimatioinBackgroundViewKey;
static const void *kSSJViewAnimatioinShowedKey = &kSSJViewAnimatioinShowedKey;

static const NSTimeInterval kDuration = 0.36;

@implementation UIView (SSJViewAnimatioin)

- (UIView *)ssj_backgroundView {
    UIView *background = objc_getAssociatedObject(self, kSSJViewAnimatioinBackgroundViewKey);
    if (!background) {
        background = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        background.backgroundColor = [UIColor blackColor];
        objc_setAssociatedObject(self, kSSJViewAnimatioinBackgroundViewKey, background, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return background;
}

- (BOOL)ssj_showed {
    return [objc_getAssociatedObject(self, kSSJViewAnimatioinShowedKey) boolValue];
}

- (void)ssj_setShowed:(BOOL)showed {
    objc_setAssociatedObject(self, kSSJViewAnimatioinShowedKey, @(showed), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)popupInView:(UIView *)view completion:(void (^ __nullable)(BOOL finished))completion {
    if (self == view) {
        return;
    }
    if (self.ssj_showed) {
        return;
    }
    
    if (self.ssj_backgroundView.superview != view) {
        [view addSubview:self.ssj_backgroundView];
    }
    
    if (self.superview != view) {
        [view addSubview:self];
    }
    
    self.center = CGPointMake(view.width * 0.5, view.height * 0.5);
    self.transform = CGAffineTransformMakeScale(0, 0);
    
    self.hidden = NO;
    self.ssj_backgroundView.hidden = NO;
    self.ssj_backgroundView.alpha = 0;
    
    [UIView animateKeyframesWithDuration:kDuration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.25 animations:^{
            self.transform = CGAffineTransformMakeScale(0.7, 0.7);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.25 relativeDuration:0.25 animations:^{
            self.transform = CGAffineTransformMakeScale(0.9, 0.9);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.25 animations:^{
            self.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.75 relativeDuration:0.25 animations:^{
            self.transform = CGAffineTransformMakeScale(1, 1);
        }];
        self.ssj_backgroundView.alpha = 0.3;
    } completion:completion];
}

- (void)dismiss:(void (^ __nullable)(BOOL finished))completion {
    if (self.superview) {
        [UIView transitionWithView:self.superview duration:kDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.hidden = YES;
            self.ssj_backgroundView.hidden = YES;
        } completion:completion];
    }
}

@end
