//
//  SSJReportFormsCurveView.m
//  SSJCurveGraphDemo
//
//  Created by old lang on 16/6/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveView.h"
#import "UIBezierPath+LxThroughPointsBezier.h"

@interface SSJReportFormsCurveView ()

@property (nonatomic, strong) NSMutableArray *incomePoints;

@property (nonatomic, strong) NSMutableArray *paymentPoints;

@end

@implementation SSJReportFormsCurveView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _bezierSmoothingTension = 0.3;
        _incomePoints = [[NSMutableArray alloc] init];
        _paymentPoints = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)layoutSubviews {
    [self updatePoints:_incomePoints withValues:_incomeValues];
    [self updatePoints:_paymentPoints withValues:_paymentValues];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(ctx, kCGBlendModeXOR);
    
    // 填充颜色
    CGContextSetFillColorWithColor(ctx, [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentFillColor].CGColor);
    CGContextAddPath(ctx, [self getLinePathWithPoints:_paymentPoints close:YES].CGPath);
    CGContextDrawPath(ctx, kCGPathFill);
    
    CGContextSetFillColorWithColor(ctx, [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurveIncomeFillColor].CGColor);
    CGContextAddPath(ctx, [self getLinePathWithPoints:_incomePoints close:YES].CGPath);
    CGContextDrawPath(ctx, kCGPathFill);
    
    // 曲线
    CGContextSetLineWidth(ctx, 1);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentColor].CGColor);
    CGContextAddPath(ctx, [self getLinePathWithPoints:_paymentPoints close:NO].CGPath);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurveIncomeColor].CGColor);
    CGContextAddPath(ctx, [self getLinePathWithPoints:_incomePoints close:NO].CGPath);
    CGContextDrawPath(ctx, kCGPathStroke);
}

- (void)setIncomeValues:(NSArray *)incomeValues {
    if (![_incomeValues isEqualToArray:incomeValues]) {
        _incomeValues = incomeValues;
        [self updatePoints:_incomePoints withValues:_incomeValues];
    }
}

- (void)setPaymentValues:(NSArray *)paymentValues {
    if (![_paymentValues isEqualToArray:paymentValues]) {
        _paymentValues = paymentValues;
        [self updatePoints:_paymentPoints withValues:_paymentValues];
    }
}

- (void)updatePoints:(NSMutableArray *)points withValues:(NSArray *)values {
    if (!values.count || CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    [points removeAllObjects];
    
    CGRect contentFrame = UIEdgeInsetsInsetRect(self.bounds, _contentInsets);
    
    CGFloat unitX = contentFrame.size.width / (values.count - 1);
    for (int i = 0; i < values.count; i ++) {
        NSNumber *value = values[i];
        CGFloat x = unitX * i + contentFrame.origin.x;
        CGFloat y = contentFrame.size.height * (1 - [value floatValue] / _maxValue) + contentFrame.origin.y;
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
}

- (UIBezierPath *)getLinePathWithPoints:(NSArray *)points close:(BOOL)close {
    if (points.count == 0) {
        return nil;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    for (int i = 0; i < points.count; i ++) {
        CGPoint point = [points[i] CGPointValue];
        if (i == 0) {
            [path moveToPoint:point];
        } else {
            CGFloat offset = (point.x - path.currentPoint.x) * 0.35;
            CGPoint controlPoint1 = CGPointMake(path.currentPoint.x + offset, path.currentPoint.y);
            CGPoint controlPoint2 = CGPointMake(point.x - offset, point.y);
            [path addCurveToPoint:point controlPoint1:controlPoint1 controlPoint2:controlPoint2];
        }
    }
    
    if (close) {
        CGRect contentFrame = UIEdgeInsetsInsetRect(self.bounds, _contentInsets);
        [path addLineToPoint:CGPointMake(CGRectGetMaxX(contentFrame), CGRectGetMaxY(contentFrame))];
        [path addLineToPoint:CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame))];
        [path closePath];
    }
    
    return path;
}

@end
