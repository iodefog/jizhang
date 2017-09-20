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

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithStartPoint:CGPointZero endPoint:CGPointZero];
}

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

- (void)layoutSubviews {
    self.imageView.frame = self.bounds;
}

- (void)caculateFrame {
    CGFloat width = ABS(self.endPoint.x - self.startPoint.x);
    CGFloat height = ABS(self.endPoint.y - self.startPoint.y);
    if (width == 0 && height == 0) {
        return;
    }
    
    CGFloat bevel = sqrt(pow(width, 2) + pow(height, 2));
    CGFloat offsetX = height / bevel * self.lineWidth * 0.5;
    CGFloat offsetY = width / bevel * self.lineWidth * 0.5;
    CGFloat leftX = MIN(self.startPoint.x, self.endPoint.x);
    CGFloat leftY = MIN(self.startPoint.y, self.startPoint.y);
    self.frame = CGRectMake(leftX - offsetX, leftY - offsetY, width + offsetX * 2, height + offsetY * 2);
}

- (void)drawDash {
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    UIGraphicsBeginImageContext(self.frame.size);
    CGFloat lengths[] = {2, 2};
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, self.lineWidth);
    CGContextSetStrokeColorWithColor(ctx, self.lineColor.CGColor);
    CGContextSetLineDash(ctx, 0, lengths, 2);
    CGContextMoveToPoint(ctx, _startPoint.x - self.left, _startPoint.y - self.top);
    CGContextAddLineToPoint(ctx, _endPoint.x - self.left, _endPoint.y - self.top);
    CGContextStrokePath(ctx);
    self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
}

- (void)setStartPoint:(CGPoint)startPoint {
    if (!CGPointEqualToPoint(_startPoint, startPoint)) {
        _startPoint = startPoint;
        [self caculateFrame];
        [self drawDash];
    }
}

- (void)setEndPoint:(CGPoint)endPoint {
    if (!CGPointEqualToPoint(_endPoint, endPoint)) {
        _endPoint = endPoint;
        [self caculateFrame];
        [self drawDash];
    }
}

- (void)setLineWidth:(CGFloat)lineWidth {
    if (_lineWidth != lineWidth) {
        _lineWidth = lineWidth;
        [self caculateFrame];
        [self drawDash];
    }
}

- (void)setLineColor:(UIColor *)lineColor {
    if (!CGColorEqualToColor(_lineColor.CGColor, lineColor.CGColor)) {
        _lineColor = lineColor;
        [self drawDash];
    }
}

@end
