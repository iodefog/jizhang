//
//  SSJLayerAddition.m
//  MoneyMore
//
//  Created by old lang on 15-3-25.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJLayerAddition.h"
#import <objc/runtime.h>

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@implementation CALayer (SSJCategory)

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

@interface _SSJBorderLayer : CALayer

//  边框线类型
@property (nonatomic, assign) SSJBorderStyle customBorderStyle;

@property (nonatomic, assign) UIRectCorner cornerStyle;

@property (nonatomic, assign) CGFloat customCornerRadius;

//  边框线宽度 dufault 1.0
@property (nonatomic, assign) CGFloat customBorderWidth;

//  边框线颜色 default black
@property (nonatomic, strong) UIColor *customBorderColor;

@end

@implementation _SSJBorderLayer

+ (instancetype)layer {
    _SSJBorderLayer *layer = [super layer];
    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.customBorderColor = [UIColor blackColor];
    layer.customBorderWidth = 1.0;
    layer.contentsScale = [UIScreen mainScreen].scale;
    return layer;
}

- (void)setCustomBorderStyle:(SSJBorderStyle)customBorderStyle {
    if (_customBorderStyle != customBorderStyle) {
        _customBorderStyle = customBorderStyle;
        [self setNeedsDisplay];
    }
}

- (void)setCornerStyle:(UIRectCorner)cornerType {
    if (_cornerStyle != cornerType) {
        _cornerStyle = cornerType;
        [self setNeedsDisplay];
    }
}

- (void)setCustomCornerRadius:(CGFloat)customCornerRadius {
    if (_customCornerRadius != customCornerRadius) {
        _customCornerRadius = customCornerRadius;
        [self setNeedsDisplay];
    }
}

- (void)setCustomBorderColor:(UIColor *)customBorderColor {
    _customBorderColor = customBorderColor;
    [self setNeedsDisplay];
}

- (void)setCustomBorderWidth:(CGFloat)customBorderWidth {
    if (_customBorderWidth != customBorderWidth) {
        _customBorderWidth = customBorderWidth;
        [self setNeedsDisplay];
    }
}

- (void)drawInContext:(CGContextRef)ctx {
    if (_customBorderStyle == SSJBorderStyleleNone
        || _customBorderWidth <= 0) {
        return;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat inset = self.customBorderWidth / 2;
    CGRect contentFrame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(inset, inset, inset, inset));
    CGPoint leftTop = CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMinY(contentFrame));
    CGPoint rightTop = CGPointMake(CGRectGetMaxX(contentFrame), CGRectGetMinY(contentFrame));
    CGPoint rightBottom = CGPointMake(CGRectGetMaxX(contentFrame), CGRectGetMaxY(contentFrame));
    CGPoint leftBottom = CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame));
    
    if ((_customBorderStyle & SSJBorderStyleTop) == SSJBorderStyleTop) {
        CGPoint point_1 = leftTop;
        CGPoint point_2 = rightTop;
        if ((_cornerStyle & UIRectCornerTopLeft) == UIRectCornerTopLeft) {
            point_1 = CGPointMake(leftTop.x + self.customCornerRadius, leftTop.y);
        }
        if ((_cornerStyle & UIRectCornerTopRight) == UIRectCornerTopRight) {
            point_2 = CGPointMake(rightTop.x - self.customCornerRadius, leftTop.y);
        }
        [path moveToPoint:point_1];
        [path addLineToPoint:point_2];
    }
    
    if ((_customBorderStyle & SSJBorderStyleRight) == SSJBorderStyleRight) {
        CGPoint point_1 = rightTop;
        CGPoint point_2 = rightBottom;
        if ((_cornerStyle & UIRectCornerTopRight) == UIRectCornerTopRight) {
            point_1 = CGPointMake(rightTop.x, rightTop.y + self.customCornerRadius);
        }
        if ((_cornerStyle & UIRectCornerBottomRight) == UIRectCornerBottomRight) {
            point_2 = CGPointMake(rightBottom.x, rightBottom.y - self.customCornerRadius);
        }
        [path moveToPoint:point_1];
        [path addLineToPoint:point_2];
    }
    
    if ((_customBorderStyle & SSJBorderStyleBottom) == SSJBorderStyleBottom) {
        CGPoint point_1 = rightBottom;
        CGPoint point_2 = leftBottom;
        if ((_cornerStyle & UIRectCornerBottomRight) == UIRectCornerBottomRight) {
            point_1 = CGPointMake(rightBottom.x - self.customCornerRadius, rightBottom.y);
        }
        if ((_cornerStyle & UIRectCornerBottomLeft) == UIRectCornerBottomLeft) {
            point_2 = CGPointMake(leftBottom.x + self.customCornerRadius, leftBottom.y);
        }
        [path moveToPoint:point_1];
        [path addLineToPoint:point_2];
    }
    
    if ((_customBorderStyle & SSJBorderStyleLeft) == SSJBorderStyleLeft) {
        CGPoint point_1 = leftBottom;
        CGPoint point_2 = leftTop;
        if ((_cornerStyle & UIRectCornerBottomLeft) == UIRectCornerBottomLeft) {
            point_1 = CGPointMake(leftBottom.x, leftBottom.y - self.customCornerRadius);
        }
        if ((_cornerStyle & UIRectCornerTopLeft) == UIRectCornerTopLeft) {
            point_2 = CGPointMake(leftTop.x, leftTop.y + self.customCornerRadius);
        }
        [path moveToPoint:point_1];
        [path addLineToPoint:point_2];
    }
    
    CGFloat radius = self.customCornerRadius;
    if ((_customBorderStyle & SSJBorderStyleTop) == SSJBorderStyleTop
        && (_customBorderStyle & SSJBorderStyleLeft) == SSJBorderStyleLeft
        && (_cornerStyle & UIRectCornerTopLeft) == UIRectCornerTopLeft) {
        CGPoint point = CGPointMake(leftTop.x, leftTop.y + radius);
        CGPoint center = CGPointMake(leftTop.x + radius, leftTop.y + radius);
        [path moveToPoint:point];
        [path addArcWithCenter:center radius:radius startAngle:M_PI endAngle:M_PI * 1.5 clockwise:YES];
    }
    
    if ((_customBorderStyle & SSJBorderStyleTop) == SSJBorderStyleTop
        && (_customBorderStyle & SSJBorderStyleRight) == SSJBorderStyleRight
        && (_cornerStyle & UIRectCornerTopRight) == UIRectCornerTopRight) {
        CGPoint point = CGPointMake(rightTop.x - radius, rightTop.y);
        CGPoint center = CGPointMake(rightTop.x - radius, rightTop.y + radius);
        [path moveToPoint:point];
        [path addArcWithCenter:center radius:radius startAngle:M_PI * 1.5 endAngle:M_PI * 2 clockwise:YES];
    }
    
    if ((_customBorderStyle & SSJBorderStyleRight) == SSJBorderStyleRight
        && (_customBorderStyle & SSJBorderStyleBottom) == SSJBorderStyleBottom
        && (_cornerStyle & UIRectCornerBottomRight) == UIRectCornerBottomRight) {
        CGPoint point = CGPointMake(rightBottom.x, rightBottom.y - radius);
        CGPoint center = CGPointMake(rightBottom.x - radius, rightBottom.y - radius);
        [path moveToPoint:point];
        [path addArcWithCenter:center radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    }
    
    if ((_customBorderStyle & SSJBorderStyleBottom) == SSJBorderStyleBottom
        && (_customBorderStyle & SSJBorderStyleLeft) == SSJBorderStyleLeft
        && (_cornerStyle & UIRectCornerBottomLeft) == UIRectCornerBottomLeft) {
        CGPoint point = CGPointMake(leftBottom.x + radius, leftBottom.y);
        CGPoint center = CGPointMake(leftBottom.x + radius, leftBottom.y - radius);
        [path moveToPoint:point];
        [path addArcWithCenter:center radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    }
    
    CGContextAddPath(ctx, path.CGPath);
    CGContextSetLineWidth(ctx, _customBorderWidth);
    CGContextSetStrokeColorWithColor(ctx, _customBorderColor.CGColor);
    CGContextStrokePath(ctx);
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

static const void *kBorderLayerKey = &kBorderLayerKey;
static const void *kBorderInsetsKey = &kBorderInsetsKey;

@implementation CALayer (SSJBorder)

+ (void)load {
    SSJSwizzleSelector([self class], @selector(setBounds:), @selector(ssj_setBounds:));
}

- (void)ssj_setBounds:(CGRect)bounds {
    [self ssj_setBounds:bounds];
    [self ssj_updateBorderLayerFrame];
}

- (void)ssj_setCornerStyle:(UIRectCorner)cornerStyle {
    [[self ssj_borderLayer] setCornerStyle:cornerStyle];
}

- (UIRectCorner)ssj_cornerStyle {
    return [[self ssj_borderLayer] cornerStyle];
}

- (void)ssj_setCornerRadius:(CGFloat)cornerRadius {
    [self ssj_borderLayer].customCornerRadius = cornerRadius;
}

- (CGFloat)ssj_cornerRadius {
    return [self ssj_borderLayer].customCornerRadius;
}

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
    NSValue *insetsValue = [NSValue valueWithUIEdgeInsets:insets];
    objc_setAssociatedObject(self, kBorderInsetsKey, insetsValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self ssj_updateBorderLayerFrame];
}

- (UIEdgeInsets)ssj_borderInsets {
    return [objc_getAssociatedObject(self, kBorderInsetsKey) UIEdgeInsetsValue];
}

- (void)ssj_relayoutBorder {
    [self ssj_borderLayer].frame = self.bounds;
}

- (_SSJBorderLayer *)ssj_borderLayer {
    _SSJBorderLayer *layer = objc_getAssociatedObject(self, kBorderLayerKey);
    if (!layer) {
        layer = [_SSJBorderLayer layer];
        layer.frame = self.bounds;
        [self addSublayer:layer];
        objc_setAssociatedObject(self, kBorderLayerKey, layer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return layer;
}

- (void)ssj_updateBorderLayerFrame {
    _SSJBorderLayer *layer = objc_getAssociatedObject(self, kBorderLayerKey);
    if (layer) {
        layer.frame = UIEdgeInsetsInsetRect(self.bounds, [self ssj_borderInsets]);
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@implementation CALayer (SSJScreenshot)

- (UIImage *)ssj_takeScreenShot {
    return [self ssj_takeScreenShotWithSize:self.size opaque:YES scale:0];
}

- (UIImage *)ssj_takeScreenShotWithSize:(CGSize)size opaque:(BOOL)opaque scale:(CGFloat)scale {
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
    [self renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshot;
}

@end
