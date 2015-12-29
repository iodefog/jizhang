//
//  SSJReportFormsPercentCircle.m
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJReportFormsPercentCircle.h"

@interface SSJReportFormsPercentCircle ()

@property (nonatomic, strong) NSMutableArray *layers;
@property (nonatomic) CGRect circleFrame;

@end

@implementation SSJReportFormsPercentCircle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layers = [NSMutableArray array];
    }
    return self;
}

- (void)layoutSubviews {
    for (CAShapeLayer *layer in self.layers) {
        layer.frame = self.circleFrame;
    }
}

- (void)setCircleInsets:(UIEdgeInsets)circleInsets {
    CGRect circleFrame = UIEdgeInsetsInsetRect(self.bounds, self.circleInsets);
    CGFloat circleRadius = MIN(circleFrame.size.width, circleFrame.size.height);
    self.circleFrame = CGRectMake(circleFrame.origin.x, circleFrame.origin.y, circleRadius, circleRadius);
    [self reload];
}

- (void)setCircleWidth:(CGFloat)circleWidth {
    if (_circleWidth != circleWidth) {
        _circleWidth = circleWidth;
        [self reload];
    }
}

- (void)setItems:(NSArray *)items {
    if (![self.items isEqualToArray:items]) {
        _items = items;
        [self reload];
    }
}

- (void)reload {
    if (self.circleWidth <= 0
        || CGRectIsEmpty(self.circleFrame)
        || self.items.count == 0) {
        return;
    }
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.circleFrame), CGRectGetMidY(self.circleFrame)) radius:158 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    
    [self.layers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    for (int i = (int)self.items.count - 1; i >= 0; i --) {
        SSJReportFormsPercentCircleItem *item = self.items[i];
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = circlePath.CGPath;
        layer.lineWidth = self.circleWidth;
        layer.strokeColor = item.color.CGColor;
        layer.strokeEnd = item.scale;
        [self.layer addSublayer:layer];
        [self.layers addObject:layer];
    }
    
    [self setNeedsLayout];
}

@end
