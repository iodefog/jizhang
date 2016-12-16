//
//  SSJReportFormsCurveView.m
//  SSJCurveGraphDemo
//
//  Created by old lang on 16/6/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveView.h"
#import "UIBezierPath+LxThroughPointsBezier.h"

void MyCGPathApplierFunc (void *info, const CGPathElement *element) {
    NSMutableDictionary *mapping = (__bridge NSMutableDictionary *)info;
    
    CGPoint *points = element->points;
    CGPathElementType type = element->type;
    
    switch(type) {
        case kCGPathElementMoveToPoint: {
            // contains 1 point
            CGPoint point = points[0];
            [mapping setObject:@(point.y) forKey:@(point.x)];
        }
            break;
            
        case kCGPathElementAddLineToPoint: {
            // contains 1 point
            CGPoint point = points[0];
            [mapping setObject:@(point.y) forKey:@(point.x)];
        }
            break;
            
        case kCGPathElementAddQuadCurveToPoint: {
            // contains 2 points
            CGPoint point1 = points[0];
            CGPoint point2 = points[1];
            
            [mapping setObject:@(point1.y) forKey:@(point1.x)];
            [mapping setObject:@(point2.y) forKey:@(point2.x)];
        }
            break;
            
        case kCGPathElementAddCurveToPoint: {
            // contains 3 points
            CGPoint point1 = points[0];
            CGPoint point2 = points[1];
            CGPoint point3 = points[2];
            
            [mapping setObject:@(point1.y) forKey:@(point1.x)];
            [mapping setObject:@(point2.y) forKey:@(point2.x)];
            [mapping setObject:@(point3.y) forKey:@(point3.x)];
        }
            break;
            
        case kCGPathElementCloseSubpath: // contains no point
            break;
    }
}

@interface SSJReportFormsCurveView ()

@property (nonatomic, strong) UIBezierPath *incomeCurvePath;

@property (nonatomic, strong) UIBezierPath *incomeShadowPath;

@property (nonatomic, strong) UIBezierPath *incomeFillPath;

@property (nonatomic, strong) UIBezierPath *paymentCurvePath;

@property (nonatomic, strong) UIBezierPath *paymentShadowPath;

@property (nonatomic, strong) UIBezierPath *paymentFillPath;

@property (nonatomic, strong) NSMutableDictionary *incomePointMapping;

@property (nonatomic, strong) NSMutableDictionary *paymentPointMapping;

@end

@implementation SSJReportFormsCurveView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _incomeCurvePath = [UIBezierPath bezierPath];
        _incomeShadowPath = [UIBezierPath bezierPath];
        _incomeFillPath = [UIBezierPath bezierPath];
        
        _paymentCurvePath = [UIBezierPath bezierPath];
        _paymentShadowPath = [UIBezierPath bezierPath];
        _incomeFillPath = [UIBezierPath bezierPath];
        
        _incomePointMapping = [NSMutableDictionary dictionary];
        _paymentPointMapping = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)layoutSubviews {
    [self updateIncomePath];
    [self updatePaymentPath];
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(ctx, kCGBlendModeXOR);
    
    // 填充颜色
    if (_fillCurve) {
        if (!_incomeFillPath.empty) {
            CGContextSetFillColorWithColor(ctx, _incomeFillColor.CGColor);
            CGContextAddPath(ctx, _incomeFillPath.CGPath);
            CGContextDrawPath(ctx, kCGPathFill);
        }
        
        if (!_paymentFillPath.empty) {
            CGContextSetFillColorWithColor(ctx, _paymentFillColor.CGColor);
            CGContextAddPath(ctx, _paymentFillPath.CGPath);
            CGContextDrawPath(ctx, kCGPathFill);
        }
    }
    
    // 曲线
    CGContextSetLineWidth(ctx, 1);
    
    if (!_incomeCurvePath.empty) {
        CGContextSetStrokeColorWithColor(ctx, _incomeCurveColor.CGColor);
        CGContextAddPath(ctx, _incomeCurvePath.CGPath);
        CGContextDrawPath(ctx, kCGPathStroke);
    }
    
    if (!_paymentCurvePath.empty) {
        CGContextSetStrokeColorWithColor(ctx, _paymentCurveColor.CGColor);
        CGContextAddPath(ctx, _paymentCurvePath.CGPath);
        CGContextDrawPath(ctx, kCGPathStroke);
    }
    
    // 曲线阴影
    if (_showShadow) {
        if (!_incomeShadowPath.empty) {
            CGContextSetStrokeColorWithColor(ctx, [_incomeCurveColor colorWithAlphaComponent:0.5].CGColor);
            CGContextAddPath(ctx, _incomeShadowPath.CGPath);
            CGContextDrawPath(ctx, kCGPathStroke);
        }
        
        if (!_paymentShadowPath.empty) {
            CGContextSetStrokeColorWithColor(ctx, [_paymentCurveColor colorWithAlphaComponent:0.5].CGColor);
            CGContextAddPath(ctx, _paymentShadowPath.CGPath);
            CGContextDrawPath(ctx, kCGPathStroke);
        }
    }
}

- (void)setIncomeValues:(NSArray *)incomeValues {
    if (![_incomeValues isEqualToArray:incomeValues]) {
        _incomeValues = incomeValues;
        [self updateIncomePath];
        [self setNeedsDisplay];
    }
}

- (void)setPaymentValues:(NSArray *)paymentValues {
    if (![_paymentValues isEqualToArray:paymentValues]) {
        _paymentValues = paymentValues;
        [self updatePaymentPath];
        [self setNeedsDisplay];
    }
}

- (void)setShowShadow:(BOOL)showShadow {
    if (_showShadow != showShadow) {
        _showShadow = showShadow;
        [self setNeedsDisplay];
    }
}

- (void)setFillCurve:(BOOL)fillCurve {
    if (_fillCurve != fillCurve) {
        _fillCurve = fillCurve;
        [self setNeedsDisplay];
    }
}

- (void)setPaymentCurveColor:(UIColor *)paymentCurveColor {
    if (!CGColorEqualToColor(_paymentCurveColor.CGColor, paymentCurveColor.CGColor)) {
        _paymentCurveColor = paymentCurveColor;
        [self setNeedsDisplay];
    }
}

- (void)setIncomeCurveColor:(UIColor *)incomeCurveColor {
    if (!CGColorEqualToColor(_incomeCurveColor.CGColor, incomeCurveColor.CGColor)) {
        _incomeCurveColor = incomeCurveColor;
        [self setNeedsDisplay];
    }
}

- (void)setPaymentFillColor:(UIColor *)paymentFillColor {
    if (!CGColorEqualToColor(_paymentFillColor.CGColor, paymentFillColor.CGColor)) {
        _paymentFillColor = paymentFillColor;
        [self setNeedsDisplay];
    }
}

- (void)setIncomeFillColor:(UIColor *)incomeFillColor {
    if (!CGColorEqualToColor(_incomeFillColor.CGColor, incomeFillColor.CGColor)) {
        _incomeFillColor = incomeFillColor;
        [self setNeedsDisplay];
    }
}

- (CGFloat)paymentAxisYAtAxisX:(CGFloat)axisX {
    return [_paymentPointMapping[@(axisX)] floatValue];
}

- (CGFloat)incomeAxisYAtAxisX:(CGFloat)axisX {
    return [_incomePointMapping[@(axisX)] floatValue];
}

- (void)updateIncomePath {
    [self updateCurvePath:_incomeCurvePath withValues:_incomeValues];
    
    if (_showShadow) {
        [self updateFillPath:_incomeFillPath withCurvePath:_incomeCurvePath];
    }
    
    if (_fillCurve) {
        [self updateCurveShadowPath:_incomeShadowPath withValues:_incomeValues];
    }
    
    // 这个方法只能取到贝塞尔曲线的起始点、终点、两个控制点
//    CGPathApply(_incomeCurvePath.CGPath, (__bridge void * _Nullable)(_incomePointMapping), MyCGPathApplierFunc);
}

- (void)updatePaymentPath {
    [self updateCurvePath:_paymentCurvePath withValues:_paymentValues];
    
    if (_showShadow) {
        [self updateCurveShadowPath:_paymentShadowPath withValues:_paymentValues];
    }
    
    if (_fillCurve) {
        [self updateFillPath:_paymentFillPath withCurvePath:_paymentCurvePath];
    }
    
    // 这个方法只能取到贝塞尔曲线的起始点、终点、两个控制点
//    CGPathApply(_paymentCurvePath.CGPath, (__bridge void * _Nullable)(_paymentPointMapping), MyCGPathApplierFunc);
}

- (void)updateCurvePath:(UIBezierPath *)path withValues:(NSArray *)values {
    if (!path || !values.count || CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    [path removeAllPoints];
    
    CGRect contentFrame = UIEdgeInsetsInsetRect(self.bounds, _contentInsets);
    
    CGFloat unitX = contentFrame.size.width / (values.count - 1);
    for (int i = 0; i < values.count; i ++) {
        NSNumber *value = values[i];
        CGFloat x = unitX * i + contentFrame.origin.x;
        CGFloat y = contentFrame.size.height * (1 - [value floatValue] / _maxValue) + contentFrame.origin.y;
        
        CGPoint point = CGPointMake(x, y);
        if (i == 0) {
            [path moveToPoint:point];
        } else {
            CGFloat offset = (point.x - path.currentPoint.x) * 0.35;
            CGPoint controlPoint1 = CGPointMake(path.currentPoint.x + offset, path.currentPoint.y);
            CGPoint controlPoint2 = CGPointMake(point.x - offset, point.y);
            [path addCurveToPoint:point controlPoint1:controlPoint1 controlPoint2:controlPoint2];
        }
    }
}

- (void)updateCurveShadowPath:(UIBezierPath *)path withValues:(NSArray *)values {
    if (!path || !values.count || CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    [path removeAllPoints];
    
    CGRect contentFrame = UIEdgeInsetsInsetRect(self.bounds, _contentInsets);
    
    CGFloat unitX = contentFrame.size.width / (values.count - 1);
    for (int i = 0; i < values.count; i ++) {
        NSNumber *value = values[i];
        CGFloat x = unitX * i + contentFrame.origin.x;
        CGFloat y = contentFrame.size.height * (1 - [value floatValue] / _maxValue) + contentFrame.origin.y;
        y -= 5;
        
        CGPoint point = CGPointMake(x, y);
        if (i == 0) {
            [path moveToPoint:point];
        } else {
            CGFloat offset = (point.x - path.currentPoint.x) * 0.35;
            CGPoint controlPoint1 = CGPointMake(path.currentPoint.x + offset, path.currentPoint.y);
            CGPoint controlPoint2 = CGPointMake(point.x - offset, point.y);
            [path addCurveToPoint:point controlPoint1:controlPoint1 controlPoint2:controlPoint2];
        }
    }
}

- (void)updateFillPath:(UIBezierPath *)fillPath withCurvePath:(UIBezierPath *)curvePath {
    if (curvePath.empty) {
        return;
    }
    
    [fillPath removeAllPoints];
    
    CGRect contentFrame = UIEdgeInsetsInsetRect(self.bounds, _contentInsets);
    [fillPath appendPath:curvePath];
    [fillPath addLineToPoint:CGPointMake(CGRectGetMaxX(contentFrame), CGRectGetMaxY(contentFrame))];
    [fillPath addLineToPoint:CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame))];
    [fillPath closePath];
}

@end
