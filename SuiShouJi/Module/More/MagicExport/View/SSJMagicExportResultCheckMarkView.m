//
//  SSJMagicExportResultCheckMarkView.m
//  SuiShouJi
//
//  Created by old lang on 16/4/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportResultCheckMarkView.h"

static NSString *const kAnimationKey = @"kAnimationKey";

static const NSTimeInterval kDuration = 0.8;

@interface SSJMagicExportResultCheckMarkView ()

@property (nonatomic, copy) void (^finish)();

@property (nonatomic) CGFloat radius;

@end

@implementation SSJMagicExportResultCheckMarkView

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (instancetype)initWithRadius:(CGFloat)radius {
    if (self = [super initWithFrame:CGRectMake(0, 0, radius * 2, radius * 2)]) {
        _radius = radius;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithRadius:MIN(CGRectGetWidth(frame), CGRectGetHeight(frame))];
}

- (void)startAnimation:(void (^)())finish {
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_radius, _radius) radius:_radius startAngle:-M_PI_2 endAngle:(-M_PI_2 - M_PI * 2) clockwise:NO];
    [path moveToPoint:CGPointMake(0.20 * self.width, 0.48 * self.height)];
    [path addLineToPoint:CGPointMake(0.41 * self.width, 0.72 * self.height)];
    [path addLineToPoint:CGPointMake(0.79 * self.width, 0.30 * self.height)];
    
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    layer.path = path.CGPath;
    layer.strokeEnd = 0;
    layer.strokeColor = [UIColor ssj_colorWithHex:@"47cfbe"].CGColor;
    layer.lineWidth = 1.5;
    layer.lineCap = kCALineCapRound;
    layer.fillColor = [UIColor whiteColor].CGColor;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = kDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.delegate = self;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [self.layer addAnimation:animation forKey:kAnimationKey];
    
    _finish = finish;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    layer.strokeEnd = 1;
    [layer removeAnimationForKey:kAnimationKey];
    
    if (_finish) {
        _finish();
        _finish = nil;
    }
}

@end
