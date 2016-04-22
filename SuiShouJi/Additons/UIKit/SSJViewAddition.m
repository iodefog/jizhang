//
//  SSJViewAddition.m
//  MoneyMore
//
//  Created by old lang on 15-3-22.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJViewAddition.h"
#import <objc/runtime.h>

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UIView (SSJGeometry)

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGPoint)leftTop {
    return CGPointMake(self.left, self.top);
}

- (void)setLeftTop:(CGPoint)leftTop {
    self.left = leftTop.x;
    self.top = leftTop.y;
}

- (CGPoint)leftBottom {
    return CGPointMake(self.left, self.bottom);
}

- (void)setLeftBottom:(CGPoint)leftBottom {
    self.left = leftBottom.x;
    self.bottom = leftBottom.y;
}

- (CGPoint)rightTop {
    return CGPointMake(self.right, self.top);
}

- (void)setRightTop:(CGPoint)rightTop {
    self.right = rightTop.x;
    self.top = rightTop.y;
}

- (CGPoint)rightBottom {
    return CGPointMake(self.right, self.bottom);
}

- (void)setRightBottom:(CGPoint)rightBottom {
    self.right = rightBottom.x;
    self.bottom = rightBottom.y;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

static const void *kBorderLayerKey  = &kBorderLayerKey;

@implementation UIView (SSJBorder)

- (void)ssj_setBorderStyle:(SSJBorderStyle)customBorderStyle {
    [[self ssj_borderLayer] setCustomBorderStyle:customBorderStyle];
}

- (SSJBorderStyle)ssj_borderStyle {
    return [[self ssj_borderLayer] customBorderStyle];
}

- (void)ssj_setBorderColor:(UIColor *)color {
    [[self ssj_borderLayer] setCustomBorderColor:color];
}

- (UIColor *)ssj_borderColor {
    return [[self ssj_borderLayer] customBorderColor];
}

- (void)ssj_setBorderWidth:(CGFloat)with {
    [[self ssj_borderLayer] setCustomBorderWidth:with];
}

- (CGFloat)ssj_borderWidth {
    return [[self ssj_borderLayer] customBorderWidth];
}

- (void)ssj_setBorderInsets:(UIEdgeInsets)insets {
    [[self ssj_borderLayer] setBorderInsets:insets];
}

- (UIEdgeInsets)ssj_borderInsets {
    return [[self ssj_borderLayer] borderInsets];
}

- (void)ssj_relayoutBorder {
    [self ssj_borderLayer].frame = self.layer.bounds;
}

- (SSJBorderLayer *)ssj_borderLayer {
    SSJBorderLayer *layer = objc_getAssociatedObject(self, kBorderLayerKey);
    if (!layer) {
        layer = [SSJBorderLayer layer];
        layer.frame = self.layer.bounds;
        [self.layer addSublayer:layer];
        objc_setAssociatedObject(self, kBorderLayerKey, layer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return layer;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

static const void *kOriginalContentSizeKey = &kOriginalContentSizeKey;
static const void *kDefaultWatermarkKey = &kDefaultWatermarkKey;
static const NSTimeInterval kAnimationDuration = 0.25;

@implementation UIView (SSJWatermark)

- (void)ssj_showWatermarkWithImageName:(NSString *)imageName animated:(BOOL)animated target:(id)target action:(SEL)action {
    UIImageView *watermark = objc_getAssociatedObject(self, kDefaultWatermarkKey);
    
    if (![watermark isKindOfClass:[UIImageView class]]) {
        [watermark removeFromSuperview];
        watermark = [[UIImageView alloc] init];
        objc_setAssociatedObject(self, kDefaultWatermarkKey, watermark, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    UIImage *image = [UIImage imageNamed:imageName];
    watermark.image = image;
    watermark.size = image.size;
    
    if ([self isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self;
        objc_setAssociatedObject(self, kOriginalContentSizeKey, [NSValue valueWithCGSize:scrollView.contentSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        CGSize contentSize = scrollView.contentSize;
        contentSize.height = MAX(watermark.height, scrollView.contentSize.height);
        scrollView.contentSize = contentSize;
        watermark.center = CGPointMake(contentSize.width * 0.5, contentSize.height * 0.5);
    } else {
        watermark.center = CGPointMake(self.width * 0.5, self.height * 0.5);
    }
    
    if ([target respondsToSelector:action]) {
        for (UIGestureRecognizer *gesture in watermark.gestureRecognizers) {
            [watermark removeGestureRecognizer:gesture];
        }
        watermark.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [watermark addGestureRecognizer:tapGesture];
    }
    
    if (watermark.superview != self) {
        [self addSubview:watermark];
        
        watermark.alpha = 0;
        [UIView animateWithDuration:(animated ? kAnimationDuration : 0) animations:^{
            watermark.alpha = 1;
        } completion:nil];
    }
}

- (void)ssj_showWatermarkWithCustomView:(UIView *)view animated:(BOOL)animated target:(id)target action:(SEL)action {
    UIView *watermark = objc_getAssociatedObject(self, kDefaultWatermarkKey);
    
    if (watermark != view) {
        [watermark removeFromSuperview];
        watermark = view;
        objc_setAssociatedObject(self, kDefaultWatermarkKey, watermark, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    if (watermark.superview != self && watermark != self) {
        [self addSubview:watermark];
        
        if ([target respondsToSelector:action]) {
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
            [watermark addGestureRecognizer:tapGesture];
        }
        
        watermark.alpha = 0;
        if ([self isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)self;
            objc_setAssociatedObject(self, kOriginalContentSizeKey, [NSValue valueWithCGSize:scrollView.contentSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            CGSize contentSize = scrollView.contentSize;
            contentSize.height = MAX(watermark.height, scrollView.contentSize.height);
            scrollView.contentSize = contentSize;
            watermark.center = CGPointMake(contentSize.width * 0.5, contentSize.height * 0.5);
        } else {
            watermark.center = CGPointMake(self.width * 0.5, self.height * 0.5);
        }
        
        [UIView animateWithDuration:(animated ? kAnimationDuration : 0) animations:^{
            watermark.alpha = 1;
        } completion:nil];
    }
}

- (void)ssj_hideWatermark:(BOOL)animated {
    UIView *watermark = objc_getAssociatedObject(self, kDefaultWatermarkKey);
    
    if (watermark.superview == self) {
        [UIView animateWithDuration:(animated ? kAnimationDuration : 0) animations:^{
            watermark.alpha = 0;
        } completion:^(BOOL finished) {
            [watermark removeFromSuperview];
            if (watermark.gestureRecognizers.count!=0) {
                UIGestureRecognizer *gesrure = [watermark.gestureRecognizers objectAtIndex:0];
                if (gesrure) {
                    [watermark removeGestureRecognizer:gesrure];
                }
            }
            if ([self isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scrollView = (UIScrollView *)self;
                CGSize originalSize = [objc_getAssociatedObject(self, kOriginalContentSizeKey) CGSizeValue];
                scrollView.contentSize = originalSize;
            }
        }];
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

static const void *kSSJLoadingIndicatorKey = &kSSJLoadingIndicatorKey;

@implementation UIView (SSJLoadingIndicator)

- (void)ssj_showLoadingIndicator {
    UIActivityIndicatorView *indicatorView = [self ssj_indicator];
    if (indicatorView.superview) {
        return;
    }
    indicatorView.center = CGPointMake(self.width * 0.5, self.height * 0.5);
    [indicatorView startAnimating];

    [UIView transitionWithView:self duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self addSubview:indicatorView];
    } completion:NULL];
}

- (void)ssj_hideLoadingIndicator {
    [[self ssj_indicator] stopAnimating];
}

- (UIActivityIndicatorView *)ssj_indicator {
    UIActivityIndicatorView *indicator = objc_getAssociatedObject(self, kSSJLoadingIndicatorKey);
    if (indicator) {
        return indicator;
    }
    
    if (!indicator) {
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        objc_setAssociatedObject(self, kSSJLoadingIndicatorKey, indicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return indicator;
    }
    
    return nil;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

static const void *kBackViewIdentifier = &kBackViewIdentifier;

@implementation UIView (SSJBackView)

- (void)ssj_showViewWithBackView:(UIView *)view
                       backColor:(UIColor *)backColor
                           alpha:(CGFloat)a
                          target:(id)target
                     touchAction:(SEL)selector {
    
    UIView* backView = [[UIView alloc] initWithFrame:self.bounds];
    backView.backgroundColor = backColor;
    backView.alpha = a;
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [backView addGestureRecognizer:gesture];
    
    objc_setAssociatedObject(self, kBackViewIdentifier, backView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addSubview:backView];
    [self addSubview:view];
    
}

- (void)ssj_showViewWithBackView:(UIView *)view
                       backColor:(UIColor *)backColor
                           alpha:(CGFloat)a
                          target:(id)target
                     touchAction:(SEL)selector
                       animation:(void(^)(void))animation
                    timeInterval:(NSTimeInterval)interval
                       fininshed:(void(^)(BOOL finished))fininshed {
    
    [self ssj_showViewWithBackView:view backColor:backColor alpha:a target:target touchAction:selector];
    [UIView animateWithDuration:interval
                     animations:animation
                     completion:fininshed];
}

- (void)ssj_hideBackViewForView:(UIView *)view
                      animation:(void(^)(void))animation
                   timeInterval:(NSTimeInterval)interval
                      fininshed:(void(^)(BOOL complation))fininshed {
    
    [UIView animateWithDuration:interval
                     animations:animation
                     completion:^(BOOL finish){
                         [self ssj_hideBackViewForView:view];
                         if (fininshed) {
                             fininshed(finish);
                         }
                     }];
    
}

- (void)ssj_hideBackViewForView:(UIView *)view {
    UIView* backView = objc_getAssociatedObject(self, kBackViewIdentifier);
    [view removeFromSuperview];
    [backView removeFromSuperview];
}

- (UIView*)backView{
    UIView* backView = objc_getAssociatedObject(self, kBackViewIdentifier);
    return backView;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UIView (SSJResponder)

- (UIResponder *)ssj_getFirstResponder {
    for (UIView *subview in self.subviews) {
        if (subview.isFirstResponder) {
            return subview;
        }
        UIResponder *responder = [subview ssj_getFirstResponder];
        if (responder) {
            return responder;
        }
    }
    return nil;
}

- (UITextField *)ssj_getFirstResponderTextField {
    UIResponder *textField = [self ssj_getFirstResponder];
    if ([textField isKindOfClass:[UITextField class]]) {
        return (UITextField *)textField;
    }
    return nil;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UIView (SSJViewController)

- (UIViewController *)ssj_viewController {
    for (UIView *next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UIView (SSJScreenshot)

- (UIImage *)ssj_takeScreenShot {
    return [self.layer ssj_takeScreenShot];
}

- (UIImage *)ssj_takeScreenShotWithSize:(CGSize)size opaque:(BOOL)opaque scale:(CGFloat)scale {
    return [self.layer ssj_takeScreenShotWithSize:size opaque:opaque scale:scale];
}

@end

