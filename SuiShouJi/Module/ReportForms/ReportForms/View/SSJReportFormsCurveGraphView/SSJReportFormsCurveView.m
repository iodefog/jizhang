//
//  SSJReportFormsCurveView.m
//  SSJCurveGraphDemo
//
//  Created by old lang on 16/6/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveView.h"

@implementation SSJReportFormsCurveView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _bezierSmoothingTension = 0.3;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(ctx, kCGBlendModeXOR);
    
    CGContextSetFillColorWithColor(ctx, [UIColor ssj_colorWithHex:@"e9f4ea"].CGColor);
    CGContextAddPath(ctx, [self getLinePathWithValues:_paymentValues close:YES].CGPath);
    CGContextDrawPath(ctx, kCGPathFill);
    
    CGContextSetFillColorWithColor(ctx, [UIColor ssj_colorWithHex:@"fae5e5"].CGColor);
    CGContextAddPath(ctx, [self getLinePathWithValues:_incomeValues close:YES].CGPath);
    CGContextDrawPath(ctx, kCGPathFill);
    
    CGContextSetLineWidth(ctx, 1);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor ssj_colorWithHex:@"59ae65"].CGColor);
    CGContextAddPath(ctx, [self getLinePathWithValues:_paymentValues close:NO].CGPath);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor ssj_colorWithHex:@"f56262"].CGColor);
    CGContextAddPath(ctx, [self getLinePathWithValues:_incomeValues close:NO].CGPath);
    CGContextDrawPath(ctx, kCGPathStroke);
}

- (CGPoint)getPointForIndex:(NSUInteger)idx values:(NSArray *)values {
    if (idx >= values.count) {
        return CGPointZero;
    }
    
    // Compute the point position in the view from the data with a set scale value
    CGFloat x = 0;
    if (idx > 0) {
        if (values.count > 2) {
            CGFloat unitX = (self.width - _margin) / (values.count - 2);
            x = (idx - 1) * unitX + _margin;
        } else {
            x = self.width;
        }
    }
    
    NSNumber *value = values[idx];
    CGFloat y = self.height * (1 - [value floatValue] / _maxValue);
    
    return CGPointMake(x, y);
}

- (UIBezierPath*)getLinePathWithValues:(NSArray *)values close:(BOOL)close
{
    UIBezierPath* path = [UIBezierPath bezierPath];
    
    for (int i = 0; i < values.count - 1; i ++) {
        CGPoint controlPoint[2];
        CGPoint p = [self getPointForIndex:i values:values];
        
        // Start the path drawing
        if(i == 0)
            [path moveToPoint:p];
        
        CGPoint nextPoint, previousPoint, m;
        
        // First control point
        nextPoint = [self getPointForIndex:i + 1 values:values];
        previousPoint = [self getPointForIndex:i - 1 values:values];
        m = CGPointZero;
        
        if(i > 0) {
            m.x = (nextPoint.x - previousPoint.x) / 2;
            m.y = (nextPoint.y - previousPoint.y) / 2;
        } else {
            m.x = (nextPoint.x - p.x) / 2;
            m.y = (nextPoint.y - p.y) / 2;
        }
        
        controlPoint[0].x = p.x + m.x * _bezierSmoothingTension;
        controlPoint[0].y = p.y + m.y * _bezierSmoothingTension;
        
        // Second control point
        nextPoint = [self getPointForIndex:i + 2 values:values];
        previousPoint = [self getPointForIndex:i values:values];
        p = [self getPointForIndex:i + 1 values:values];
        m = CGPointZero;
        
        if(i < values.count - 2) {
            m.x = (nextPoint.x - previousPoint.x) / 2;
            m.y = (nextPoint.y - previousPoint.y) / 2;
        } else {
            m.x = (p.x - previousPoint.x) / 2;
            m.y = (p.y - previousPoint.y) / 2;
        }
        
        controlPoint[1].x = p.x - m.x * _bezierSmoothingTension;
        controlPoint[1].y = p.y - m.y * _bezierSmoothingTension;
        
        [path addCurveToPoint:p controlPoint1:controlPoint[0] controlPoint2:controlPoint[1]];
    }
    
    if (close) {
        [path addLineToPoint:CGPointMake(self.width, self.height)];
        [path closePath];
    }
    
    return path;
}

@end
