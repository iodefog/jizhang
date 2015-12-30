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
@property (nonatomic, strong) NSMutableArray *lineLayers;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic) CGRect circleFrame;

@end

@implementation SSJReportFormsPercentCircle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layers = [NSMutableArray array];
        self.lineLayers = [NSMutableArray array];
        self.images = [NSMutableArray array];
    }
    return self;
}

- (void)layoutSubviews {
    [self updateCircleFrame];
    [self reloadData];
    
//    for (CAShapeLayer *layer in self.layers) {
//        layer.frame = self.circleFrame;
//    }
}

- (void)setCircleInsets:(UIEdgeInsets)circleInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(_circleInsets, circleInsets)) {
        _circleInsets = circleInsets;
        [self updateCircleFrame];
        [self reloadData];
        [self setNeedsLayout];
    }
}

- (void)setCircleWidth:(CGFloat)circleWidth {
    if (_circleWidth != circleWidth) {
        _circleWidth = circleWidth;
        [self reloadData];
        [self setNeedsLayout];
    }
}

- (void)setDataSource:(id<SSJReportFormsPercentCircleDataSource>)dataSource {
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        [self reloadData];
        [self setNeedsLayout];
    }
}

- (void)reloadData {
    
    if (!self.dataSource
        || ![self.dataSource respondsToSelector:@selector(numberOfComponentsInPercentCircle:)]
        || ![self.dataSource respondsToSelector:@selector(percentCircle:itemForComponentAtIndex:)]
        || self.circleWidth <= 0
        || CGRectIsEmpty(self.bounds)
        || CGRectIsEmpty(self.circleFrame)) {
        return;
    }
    
    [self.layers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.layers removeAllObjects];
    
    [self.lineLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.lineLayers removeAllObjects];
    
    [self.images makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.images removeAllObjects];
    
    NSUInteger numberOfComponents = [self.dataSource numberOfComponentsInPercentCircle:self];
    
    CGFloat overlapScale = 0;
    CALayer *lastLayer = nil;
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.circleFrame), CGRectGetMidY(self.circleFrame)) radius:(CGRectGetWidth(self.circleFrame) - self.circleWidth * 0.5) * 0.5 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    
    for (NSUInteger idx = 0; idx < numberOfComponents; idx ++) {
        
        if ([self.dataSource respondsToSelector:@selector(percentCircle:itemForComponentAtIndex:)]) {
            SSJReportFormsPercentCircleItem *item = [self.dataSource percentCircle:self itemForComponentAtIndex:idx];
            if (!item) {
                return;
            }
            
            CAShapeLayer *layer = [CAShapeLayer layer];
            layer.path = circlePath.CGPath;
            layer.fillColor = [UIColor whiteColor].CGColor;
            layer.lineWidth = self.circleWidth;
            layer.strokeColor = item.color.CGColor;
            layer.strokeEnd = 0;
            layer.zPosition = numberOfComponents - idx;
            
            [self.layer addSublayer:layer];
            [self.layers addObject:layer];
            
            overlapScale += item.scale;
            lastLayer = layer;
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            animation.toValue = @(overlapScale);
            animation.duration = 0.7;
            animation.delegate = self;
            animation.removedOnCompletion = NO;
            animation.fillMode = kCAFillModeForwards;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            [layer addAnimation:animation forKey:@"circleAnimation"];
        }
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    for (CAShapeLayer *circleLayer in self.layers) {
        if ([circleLayer animationForKey:@"circleAnimation"] == anim) {
            CABasicAnimation *basicAnimation = (CABasicAnimation *)anim;
            [circleLayer removeAnimationForKey:@"circleAnimation"];
            circleLayer.strokeEnd = [basicAnimation.toValue floatValue];
        }
    }
}

- (void)updateCircleFrame {
    CGRect circleFrame = UIEdgeInsetsInsetRect(self.bounds, self.circleInsets);
    CGFloat circleRadius = MIN(circleFrame.size.width, circleFrame.size.height);
    self.circleFrame = CGRectMake(circleFrame.origin.x, circleFrame.origin.y, circleRadius, circleRadius);
}

@end
