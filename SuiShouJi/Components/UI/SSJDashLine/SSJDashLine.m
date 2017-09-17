//
//  SSJDashLine.m
//  SuiShouJi
//
//  Created by old lang on 2017/9/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJDashLine.h"

@interface SSJDashLine ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation SSJDashLine

- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    if (self = [super initWithFrame:CGRectZero]) {
        _startPoint = startPoint;
        _endPoint = endPoint;
        self.backgroundColor = [UIColor clearColor];
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
        [self sizeToFit];
        [self drawDash];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(ABS(self.endPoint.x - self.startPoint.x), ABS(self.endPoint.y - self.startPoint.y));
}

- (void)drawDash {
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    UIGraphicsBeginImageContext(self.frame.size);
    //    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGFloat lengths[] = {2, 2};
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, self.lineWidth);
    CGContextSetStrokeColorWithColor(ctx, self.lineColor.CGColor);
    CGContextSetLineDash(ctx, 0, lengths, 2); //画虚线
    CGContextMoveToPoint(ctx, _startPoint.x, _startPoint.y); //开始画线
    CGContextAddLineToPoint(ctx, _endPoint.x, _endPoint.y);
    CGContextStrokePath(ctx);
    self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
}

- (void)setStartPoint:(CGPoint)startPoint {
    if (!CGPointEqualToPoint(_startPoint, startPoint)) {
        _startPoint = startPoint;
        [self drawDash];
    }
}

- (void)setEndPoint:(CGPoint)endPoint {
    if (!CGPointEqualToPoint(_endPoint, endPoint)) {
        _endPoint = endPoint;
        [self drawDash];
    }
}

- (void)setLineColor:(UIColor *)lineColor {
    if (!CGColorEqualToColor(_lineColor.CGColor, lineColor.CGColor)) {
        _lineColor = lineColor;
        [self drawDash];
    }
}

- (void)setLineWidth:(CGFloat)lineWidth {
    if (_lineWidth != lineWidth) {
        _lineWidth = lineWidth;
        [self drawDash];
    }
}

@end
