//
//  SSJReportFormsCurveDot.m
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveDot.h"

@implementation SSJReportFormsCurveDot

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _outerRadius = 8;
        _innerRadius = 4;
        _dotColor = [UIColor blackColor];
        _outerColorAlpha = 0.5;
        
        self.backgroundColor = [UIColor clearColor];
        [self sizeToFit];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(_outerRadius * 2, _outerRadius * 2);
}

- (void)drawRect:(CGRect)rect {
    CGPoint center = CGPointMake(self.width * 0.5, self.height * 0.5);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 外圆
    CGContextSetFillColorWithColor(ctx, [_dotColor colorWithAlphaComponent:_outerColorAlpha].CGColor);
    CGContextAddArc(ctx, center.x, center.y, _outerRadius, 0, M_PI * 2, YES);
    CGContextFillPath(ctx);
    
    // 内圆
    CGContextSetFillColorWithColor(ctx, _dotColor.CGColor);
    CGContextAddArc(ctx, center.x, center.y, _innerRadius, 0, M_PI * 2, YES);
    CGContextFillPath(ctx);
}

- (void)setOuterRadius:(CGFloat)outerRadius {
    if (_outerRadius != outerRadius) {
        _outerRadius = outerRadius;
        [self setNeedsDisplay];
    }
}

- (void)setInnerRadius:(CGFloat)innerRadius {
    if (_innerRadius != innerRadius) {
        _innerRadius = innerRadius;
        [self setNeedsDisplay];
    }
}

- (void)setDotColor:(UIColor *)dotColor {
    if (!CGColorEqualToColor(_dotColor.CGColor, dotColor.CGColor)) {
        _dotColor = dotColor;
        [self setNeedsDisplay];
    }
}

- (void)setOuterColorAlpha:(CGFloat)outerColorAlpha {
    if (_outerColorAlpha != outerColorAlpha) {
        _outerColorAlpha = outerColorAlpha;
        [self setNeedsDisplay];
    }
}

@end
