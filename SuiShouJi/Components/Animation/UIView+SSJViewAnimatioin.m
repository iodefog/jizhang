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

@implementation UIView (SSJViewAnimatioin)

- (UIView *)backgroundView {
    UIView *background = objc_getAssociatedObject(self, kSSJViewAnimatioinBackgroundViewKey);
    if (!background) {
        background = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        background.backgroundColor = [UIColor blackColor];
        objc_setAssociatedObject(self, kSSJViewAnimatioinBackgroundViewKey, background, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return background;
}

- (BOOL)showed {
    return [objc_getAssociatedObject(self, kSSJViewAnimatioinShowedKey) boolValue];
}

- (void)setShowed:(BOOL)showed {
    objc_setAssociatedObject(self, kSSJViewAnimatioinShowedKey, @(showed), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)popupInView:(UIView *)view completion:(void (^)())completion {
    if (self == view) {
        return;
    }
    if (self.showed) {
        return;
    }
    
    if (self.superview != view) {
        [view addSubview:self.backgroundView];
        [view addSubview:self];
    }
    
    self.center = CGPointMake(view.width * 0.5, view.height * 0.5);
    self.transform = CGAffineTransformMakeScale(0, 0);
    self.backgroundView.alpha = 0;
    
    [UIView animateKeyframesWithDuration:0.36 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
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
        self.backgroundView.alpha = 0.3;
    } completion:NULL];
}

- (void)popup {
    
}

- (void)showBackground {
    
}

- (void)dismiss:(void (^)())completion {
    
}

@end
