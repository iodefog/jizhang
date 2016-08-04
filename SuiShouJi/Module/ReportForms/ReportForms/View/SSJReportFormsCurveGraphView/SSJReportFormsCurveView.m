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
    
//    CGContextSetStrokeColorWithColor(ctx, [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentColor].CGColor);
//    CGContextAddPath(ctx, [self getLinePathWithPoints:_paymentPoints close:YES].CGPath);
//    CGContextDrawPath(ctx, kCGPathStroke);
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
    CGPoint beginPoint = [[points firstObject] CGPointValue];
    [path moveToPoint:beginPoint];
    [path addBezierThroughPoints:points];
    
    if (close) {
        CGRect contentFrame = UIEdgeInsetsInsetRect(self.bounds, _contentInsets);
        
        if (points.count == 2) {
            // 如果只有2个坐标点，创建的path是从第二个点到第一个点，而且不能用closePath，否则会出现奇葩的现象。。。
            [path addLineToPoint:CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame))];
            [path addLineToPoint:CGPointMake(CGRectGetMaxX(contentFrame), CGRectGetMaxY(contentFrame))];
            [path addLineToPoint:[points[1] CGPointValue]];
        } else {
            // 如果超过2个坐标点，行为是正常的。。。
            [path addLineToPoint:CGPointMake(CGRectGetMaxX(contentFrame), CGRectGetMaxY(contentFrame))];
            [path addLineToPoint:CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame))];
            [path closePath];
        }
    }
    
    return path;
}

@end
