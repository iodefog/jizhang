//
//  SSJLayerAddition.m
//  MoneyMore
//
//  Created by old lang on 15-3-25.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJLayerAddition.h"

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

@implementation SSJBorderLayer

+ (instancetype)layer {
    SSJBorderLayer *layer = [super layer];
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

- (void)setBorderInsets:(UIEdgeInsets)borderInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(_borderInsets, borderInsets)) {
        _borderInsets = borderInsets;
        [self setNeedsDisplay];
    }
}

- (void)drawInContext:(CGContextRef)ctx {
    if (_customBorderStyle == SSJBorderStyleleNone
        || _customBorderWidth <= 0) {
        return;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    if ((_customBorderStyle & SSJBorderStyleTop) == SSJBorderStyleTop) {
        CGPoint leftTop = CGPointMake(_borderInsets.left, _borderInsets.top);
        if ((_cornerStyle & UIRectCornerTopLeft) == UIRectCornerTopLeft) {
            leftTop = CGPointMake(leftTop.x + self.customCornerRadius, leftTop.y);
        }
        
        CGPoint rightTop = CGPointMake(self.width - _borderInsets.right, _borderInsets.top);
        if ((_cornerStyle & UIRectCornerTopRight) == UIRectCornerTopRight) {
            rightTop = CGPointMake(rightTop.x - self.customCornerRadius, leftTop.y);
        }
        
        [path moveToPoint:leftTop];
        [path addLineToPoint:rightTop];
    }
    
    if ((_customBorderStyle & SSJBorderStyleRight) == SSJBorderStyleRight) {
        CGPoint rightTop = CGPointMake(self.width - _borderInsets.right, _borderInsets.top);
        if ((_cornerStyle & UIRectCornerTopRight) == UIRectCornerTopRight) {
            rightTop = CGPointMake(rightTop.x, rightTop.y + self.customCornerRadius);
        }
        
        CGPoint rightBottom = CGPointMake(self.width - _borderInsets.right, self.height - _borderInsets.bottom);
        if ((_cornerStyle & UIRectCornerBottomRight) == UIRectCornerBottomRight) {
            rightBottom = CGPointMake(rightBottom.x, rightBottom.y - self.customCornerRadius);
        }
        
        [path moveToPoint:rightTop];
        [path addLineToPoint:rightBottom];
    }
    
    if ((_customBorderStyle & SSJBorderStyleBottom) == SSJBorderStyleBottom) {
        CGPoint rightBottom = CGPointMake(self.width - _borderInsets.right, self.height - _borderInsets.bottom);
        if ((_cornerStyle & UIRectCornerBottomRight) == UIRectCornerBottomRight) {
            rightBottom = CGPointMake(rightBottom.x - self.customCornerRadius, rightBottom.y);
        }
        
        CGPoint leftBottom = CGPointMake(_borderInsets.left, self.height - _borderInsets.bottom);
        if ((_cornerStyle & UIRectCornerBottomLeft) == UIRectCornerBottomLeft) {
            leftBottom = CGPointMake(leftBottom.x + self.customCornerRadius, leftBottom.y);
        }
        
        [path moveToPoint:rightBottom];
        [path addLineToPoint:leftBottom];
    }
    
    if ((_customBorderStyle & SSJBorderStyleLeft) == SSJBorderStyleLeft) {
        CGPoint leftBottom = CGPointMake(_borderInsets.left, self.height - _borderInsets.bottom);
        if ((_cornerStyle & UIRectCornerBottomLeft) == UIRectCornerBottomLeft) {
            leftBottom = CGPointMake(leftBottom.x, leftBottom.y - self.customCornerRadius);
        }
        
        CGPoint leftTop = CGPointMake(_borderInsets.left, _borderInsets.top);
        if ((_cornerStyle & UIRectCornerTopLeft) == UIRectCornerTopLeft) {
            leftTop = CGPointMake(leftTop.x, leftTop.y + self.customCornerRadius);
        }
        
        [path moveToPoint:leftBottom];
        [path addLineToPoint:leftTop];
    }
    
    if ((_customBorderStyle & SSJBorderStyleTop) == SSJBorderStyleTop
        && (_customBorderStyle & SSJBorderStyleLeft) == SSJBorderStyleLeft) {
        if ((_cornerStyle & UIRectCornerTopLeft) == UIRectCornerTopLeft) {
            CGPoint center = CGPointMake(_borderInsets.left + self.customCornerRadius, _borderInsets.top + self.customCornerRadius);
            [path addArcWithCenter:center radius:self.customCornerRadius startAngle:M_PI endAngle:M_PI * 1.5 clockwise:YES];
        } else {
            CGPoint pt_1 = CGPointMake(_borderInsets.left, _borderInsets.top + self.customCornerRadius);
            CGPoint pt_2 = CGPointMake(_borderInsets.left, _borderInsets.top);
            CGPoint pt_3 = CGPointMake(_borderInsets.left + self.customCornerRadius, _borderInsets.top);
            [path moveToPoint:pt_1];
            [path addLineToPoint:pt_2];
            [path addLineToPoint:pt_3];
        }
    }
    
    if ((_customBorderStyle & SSJBorderStyleTop) == SSJBorderStyleTop
        && (_customBorderStyle & SSJBorderStyleRight) == SSJBorderStyleRight) {
        if ((_cornerStyle & UIRectCornerTopRight) == UIRectCornerTopRight) {
            CGPoint center = CGPointMake(self.width - _borderInsets.right - self.customCornerRadius, _borderInsets.top + self.customCornerRadius);
            [path addArcWithCenter:center radius:self.customCornerRadius startAngle:M_PI * 1.5 endAngle:M_PI * 2 clockwise:YES];
        } else {
            CGPoint pt_1 = CGPointMake(self.width - _borderInsets.right - self.customCornerRadius, _borderInsets.top);
            CGPoint pt_2 = CGPointMake(self.width - _borderInsets.right, _borderInsets.top);
            CGPoint pt_3 = CGPointMake(self.width - _borderInsets.right, _borderInsets.top + self.customCornerRadius);
            [path moveToPoint:pt_1];
            [path addLineToPoint:pt_2];
            [path addLineToPoint:pt_3];
        }
    }
    
    if ((_customBorderStyle & SSJBorderStyleRight) == SSJBorderStyleRight
        && (_customBorderStyle & SSJBorderStyleBottom) == SSJBorderStyleBottom) {
        if ((_cornerStyle & UIRectCornerBottomRight) == UIRectCornerBottomRight) {
            CGPoint center = CGPointMake(self.width - _borderInsets.right - self.customCornerRadius, self.height - _borderInsets.bottom - self.customCornerRadius);
            [path addArcWithCenter:center radius:self.customCornerRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
        } else {
            CGPoint pt_1 = CGPointMake(self.width - _borderInsets.right, self.height - _borderInsets.bottom - self.customCornerRadius);
            CGPoint pt_2 = CGPointMake(self.width - _borderInsets.right, self.height - _borderInsets.bottom);
            CGPoint pt_3 = CGPointMake(self.width - _borderInsets.right - self.customCornerRadius, self.height - _borderInsets.bottom);
            [path moveToPoint:pt_1];
            [path addLineToPoint:pt_2];
            [path addLineToPoint:pt_3];
        }
    }
    
    if ((_customBorderStyle & SSJBorderStyleBottom) == SSJBorderStyleBottom
        && (_customBorderStyle & SSJBorderStyleLeft) == SSJBorderStyleLeft) {
        if ((_cornerStyle & UIRectCornerBottomLeft) == UIRectCornerBottomLeft) {
            CGPoint center = CGPointMake(_borderInsets.left + self.customCornerRadius, self.height - _borderInsets.bottom - self.customCornerRadius);
            [path addArcWithCenter:center radius:self.customCornerRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        } else {
            CGPoint pt_1 = CGPointMake(_borderInsets.left + self.customCornerRadius, self.height - _borderInsets.bottom);
            CGPoint pt_2 = CGPointMake(_borderInsets.left, self.height - _borderInsets.bottom);
            CGPoint pt_3 = CGPointMake(_borderInsets.left, self.height - _borderInsets.bottom - self.customCornerRadius);
            [path moveToPoint:pt_1];
            [path addLineToPoint:pt_2];
            [path addLineToPoint:pt_3];
        }
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

@implementation CALayer (SSJBorder)

+ (void)load {
    SSJSwizzleSelector([self class], @selector(setBounds:), @selector(ssj_setBounds:));
}

- (void)ssj_setBounds:(CGRect)bounds {
    [self ssj_setBounds:bounds];
    SSJBorderLayer *layer = objc_getAssociatedObject(self, kBorderLayerKey);
    if (layer) {
        layer.frame = self.bounds;
    }
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
    [[self ssj_borderLayer] setBorderInsets:insets];
}

- (UIEdgeInsets)ssj_borderInsets {
    return [[self ssj_borderLayer] borderInsets];
}

- (void)ssj_relayoutBorder {
    [self ssj_borderLayer].frame = self.bounds;
}

- (SSJBorderLayer *)ssj_borderLayer {
    SSJBorderLayer *layer = objc_getAssociatedObject(self, kBorderLayerKey);
    if (!layer) {
        layer = [SSJBorderLayer layer];
        layer.frame = self.bounds;
        [self addSublayer:layer];
        objc_setAssociatedObject(self, kBorderLayerKey, layer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return layer;
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
