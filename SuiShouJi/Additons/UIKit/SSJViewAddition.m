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

@implementation UIView (SSJBorder)

- (void)ssj_setCornerStyle:(UIRectCorner)cornerStyle {
    [self.layer ssj_setCornerStyle:cornerStyle];
}

- (UIRectCorner)ssj_cornerStyle {
    return [self.layer ssj_cornerStyle];
}

- (void)ssj_setCornerRadius:(CGFloat)cornerRadius {
    [self.layer ssj_setCornerRadius:cornerRadius];
}

- (CGFloat)ssj_cornerRadius {
    return [self.layer ssj_cornerRadius];
}

- (void)ssj_setBorderStyle:(SSJBorderStyle)customBorderStyle {
    [self.layer ssj_setBorderStyle:customBorderStyle];
}

- (SSJBorderStyle)ssj_borderStyle {
    return [self.layer ssj_borderStyle];
}

- (void)ssj_setBorderColor:(UIColor *)color {
    [self.layer ssj_setBorderColor:color];
}

- (UIColor *)ssj_borderColor {
    return [self.layer ssj_borderColor];
}

- (void)ssj_setBorderWidth:(CGFloat)width {
    [self.layer ssj_setBorderWidth:width];
}

- (CGFloat)ssj_borderWidth {
    return [self.layer ssj_borderWidth];
}

- (void)ssj_setBorderInsets:(UIEdgeInsets)insets {
    [self.layer ssj_setBorderInsets:insets];
}

- (UIEdgeInsets)ssj_borderInsets {
    return [self.layer ssj_borderInsets];
}

- (void)ssj_relayoutBorder {
    [self.layer ssj_relayoutBorder];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

static const void *kOriginalContentSizeKey = &kOriginalContentSizeKey;
static const void *kDefaultWatermarkKey = &kDefaultWatermarkKey;
static const void *kWatermarkShowedKey = &kWatermarkShowedKey;

static const NSTimeInterval kAnimationDuration = 0.25;

@implementation UIView (SSJWatermark)

- (void)ssj_showWatermarkWithImageName:(NSString *)imageName animated:(BOOL)animated target:(id)target action:(SEL)action {
    UIImageView *watermark = objc_getAssociatedObject(self, kDefaultWatermarkKey);
    
    if (watermark == self) {
        return;
    }
    
    if (![watermark isKindOfClass:[UIImageView class]]) {
        
        if (watermark) {
            objc_setAssociatedObject(watermark, kWatermarkShowedKey, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [watermark removeFromSuperview];
        }
        
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
        contentSize.height = MAX(watermark.height, CGRectGetHeight(UIEdgeInsetsInsetRect(scrollView.bounds, scrollView.contentInset)));
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
    
    [self addSubview:watermark];
    objc_setAssociatedObject(watermark, kWatermarkShowedKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    watermark.alpha = 0;
    [UIView animateWithDuration:(animated ? kAnimationDuration : 0) animations:^{
        watermark.alpha = 1;
    } completion:nil];
}

- (void)ssj_showWatermarkWithCustomView:(UIView *)view animated:(BOOL)animated target:(id)target action:(SEL)action {
    UIView *watermark = objc_getAssociatedObject(self, kDefaultWatermarkKey);
    
    if (watermark == self) {
        return;
    }
    
    if (watermark.superview == self
        && watermark == view
        && [objc_getAssociatedObject(watermark, kWatermarkShowedKey) boolValue]) {
        return;
    }
    
    if (watermark) {
        objc_setAssociatedObject(watermark, kWatermarkShowedKey, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [watermark removeFromSuperview];
    }
    
    objc_setAssociatedObject(self, kDefaultWatermarkKey, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!view) {
        return;
    }
    watermark = view;
    
    if ([self isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self;
        objc_setAssociatedObject(self, kOriginalContentSizeKey, [NSValue valueWithCGSize:scrollView.contentSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        CGSize contentSize = scrollView.contentSize;
        contentSize.height = MAX(watermark.height, CGRectGetHeight(UIEdgeInsetsInsetRect(scrollView.bounds, scrollView.contentInset)));
        scrollView.contentSize = contentSize;
        watermark.center = CGPointMake(contentSize.width * 0.5, contentSize.height * 0.5);
    } else {
        watermark.center = CGPointMake(self.width * 0.5, self.height * 0.5);
    }
    
    if ([target respondsToSelector:action]) {
        for (UIGestureRecognizer *gesture in watermark.gestureRecognizers) {
            [watermark removeGestureRecognizer:gesture];
        }
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [watermark addGestureRecognizer:tapGesture];
    }
    
    [self addSubview:watermark];
    objc_setAssociatedObject(watermark, kWatermarkShowedKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    watermark.alpha = 0;
    [UIView animateWithDuration:(animated ? kAnimationDuration : 0) animations:^{
        watermark.alpha = 1;
    } completion:nil];
}

- (void)ssj_hideWatermark:(BOOL)animated {
    UIView *watermark = objc_getAssociatedObject(self, kDefaultWatermarkKey);
    
    if (watermark.superview == self) {
        
        objc_setAssociatedObject(watermark, kWatermarkShowedKey, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [UIView animateWithDuration:(animated ? kAnimationDuration : 0) animations:^{
            watermark.alpha = 0;
        } completion:^(BOOL finished) {
            if ([objc_getAssociatedObject(watermark, kWatermarkShowedKey) boolValue]) {
                return;
            }
            
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

- (void)ssj_relayoutWatermark {
    UIView *watermark = objc_getAssociatedObject(self, kDefaultWatermarkKey);
    if (watermark.superview == self) {
        watermark.center = CGPointMake(self.width * 0.5, self.height * 0.5);
    }
}

- (BOOL)ssj_isWatermarkShowed {
    return [objc_getAssociatedObject(self, kWatermarkShowedKey) boolValue];
}

- (void)ssj_setWatermarkShowed:(BOOL)showed {
    objc_setAssociatedObject(self, kWatermarkShowedKey, @(showed), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

static const void *kSSJLoadingIndicatorKey = &kSSJLoadingIndicatorKey;

@implementation UIView (SSJLoadingIndicator)

- (void)ssj_showLoadingIndicator {
    UIActivityIndicatorView *indicatorView = [self ssj_indicator];
    indicatorView.center = CGPointMake(self.width * 0.5, self.height * 0.5);
    [indicatorView startAnimating];
    
    if (indicatorView.superview != self) {
        [self addSubview:indicatorView];
    }
}

- (void)ssj_hideLoadingIndicator {
    [[self ssj_indicator] stopAnimating];
}

- (void)ssj_relayoutLoadingIndicator {
    [self ssj_indicator].center = CGPointMake(self.width * 0.5, self.height * 0.5);
}

- (UIActivityIndicatorView *)ssj_indicator {
    UIActivityIndicatorView *indicator = objc_getAssociatedObject(self, kSSJLoadingIndicatorKey);
    if (indicator) {
        return indicator;
    }
    
    if (!indicator) {
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.layer.zPosition = 100;
        objc_setAssociatedObject(self, kSSJLoadingIndicatorKey, indicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return indicator;
    }
    
    return nil;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

static const void *kBackViewsIdentifier = &kBackViewsIdentifier;
static const void *kShowViewsIdentifier = &kShowViewsIdentifier;

@implementation UIView (SSJBackView)

- (void)ssj_showViewWithBackView:(UIView *)view
                       backColor:(UIColor *)backColor
                           alpha:(CGFloat)a
                          target:(id)target
                     touchAction:(SEL)selector {
    
    if ([[self ssj_showViews] containsObject:view]) {
        return;
    }
    
    UIView *backView = [[UIView alloc] initWithFrame:self.bounds];
    backView.backgroundColor = backColor;
    backView.alpha = a;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [backView addGestureRecognizer:tap];
    
    [self addSubview:backView];
    [self addSubview:view];
    
    [[self ssj_backViews] addObject:backView];
    [[self ssj_showViews] addObject:view];
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
    
    if (![[self ssj_showViews] containsObject:view]) {
        return;
    }
    
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
    NSUInteger index = [[self ssj_showViews] indexOfObject:view];
    if (index != NSNotFound) {
        UIView *backView = [[self ssj_backViews] objectAtIndex:index];
        [view removeFromSuperview];
        [backView removeFromSuperview];
        
        [[self ssj_showViews] removeObjectAtIndex:index];
        [[self ssj_backViews] removeObjectAtIndex:index];
    }
}

- (NSMutableArray *)ssj_backViews {
    NSMutableArray *backViews = objc_getAssociatedObject(self, kBackViewsIdentifier);
    if (!backViews) {
        backViews = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, kBackViewsIdentifier, backViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return backViews;
}

- (NSMutableArray *)ssj_showViews {
    NSMutableArray *showViews = objc_getAssociatedObject(self, kShowViewsIdentifier);
    if (!showViews) {
        showViews = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, kShowViewsIdentifier, showViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return showViews;
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
