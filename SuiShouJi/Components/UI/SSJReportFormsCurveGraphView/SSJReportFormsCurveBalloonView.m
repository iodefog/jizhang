//
//  SSJReportFormsCurveBalloonView.m
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveBalloonView.h"

@interface SSJReportFormsCurveBalloonView ()

@end

@implementation SSJReportFormsCurveBalloonView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _titleFont = [UIFont systemFontOfSize:12];
        _titleColor = [UIColor whiteColor];
        _ballonColor = [UIColor yellowColor];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake([self titleRoundedSize].width, size.height);
}

- (void)drawRect:(CGRect)rect {
    CGSize roundedSize = [self titleRoundedSize];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(1, 1, roundedSize.width - 2, roundedSize.height - 2) cornerRadius:roundedSize.height * 0.5];
    
    [path moveToPoint:CGPointMake(self.width * 0.5, roundedSize.height + 4)];
    [path addLineToPoint:CGPointMake(self.width * 0.5 - 4, roundedSize.height - 1)];
    [path addLineToPoint:CGPointMake(self.width * 0.5 + 4, roundedSize.height - 1)];
    [path closePath];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithCGPath:path.CGPath];
    [shadowPath applyTransform:CGAffineTransformMakeTranslation(0, 8)];
    
    [path addLineToPoint:CGPointMake(self.width * 0.5, self.height)];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1);
    CGContextSetStrokeColorWithColor(ctx, _ballonColor.CGColor);
    CGContextSetFillColorWithColor(ctx, _ballonColor.CGColor);
    CGContextAddPath(ctx, path.CGPath);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    CGContextSetFillColorWithColor(ctx, [_ballonColor colorWithAlphaComponent:0.2].CGColor);
    CGContextAddPath(ctx, shadowPath.CGPath);
    CGContextDrawPath(ctx, kCGPathFill);
    
    
    CGSize titleSize = [_title sizeWithAttributes:@{NSFontAttributeName:_titleFont}];
    CGRect titleRect = CGRectMake((roundedSize.width - titleSize.width) * 0.5, (roundedSize.height - titleSize.height) * 0.5, titleSize.width, titleSize.height);
    [_title drawInRect:titleRect withAttributes:@{NSFontAttributeName:_titleFont,
                                                  NSForegroundColorAttributeName:_titleColor}];
}

- (void)setFrame:(CGRect)frame {
    if (!CGRectEqualToRect(self.frame, frame)) {
        [super setFrame:frame];
        [self setNeedsDisplay];
    }
}

- (void)setTitle:(NSString *)title {
    if (![_title isEqualToString:title]) {
        _title = title;
        [self sizeToFit];
        [self setNeedsDisplay];
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    if (_titleFont.pointSize != titleFont.pointSize) {
        _titleFont = titleFont;
        [self sizeToFit];
        [self setNeedsDisplay];
    }
}

- (void)setTitleColor:(UIColor *)titleColor {
    if (!CGColorEqualToColor(_titleColor.CGColor, titleColor.CGColor)) {
        _titleColor = titleColor;
        [self setNeedsDisplay];
    }
}

- (void)setBallonColor:(UIColor *)ballonColor {
    if (!CGColorEqualToColor(_ballonColor.CGColor, ballonColor.CGColor)) {
        _ballonColor = ballonColor;
        [self setNeedsDisplay];
    }
}

- (CGSize)titleRoundedSize {
    CGSize titleSize = [_title sizeWithAttributes:@{NSFontAttributeName:_titleFont}];
    return CGSizeMake(titleSize.width + 20, titleSize.height + 6);
}

@end
