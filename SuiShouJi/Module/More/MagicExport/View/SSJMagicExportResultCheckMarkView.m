//
//  SSJMagicExportResultCheckMarkView.m
//  SuiShouJi
//
//  Created by old lang on 16/4/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportResultCheckMarkView.h"

static NSString *const kAnimationKey = @"kAnimationKey";

static const NSTimeInterval kDuration = 0.5;

@interface SSJMagicExportResultCheckMarkView ()

@property (nonatomic, copy) void (^finish)();

@end

@implementation SSJMagicExportResultCheckMarkView

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (instancetype)initWithRadius:(CGFloat)radius {
    if (self = [super initWithFrame:CGRectMake(0, 0, radius, radius)]) {
        
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
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    [path moveToPoint:CGPointMake(0.20 * self.width, 0.48 * self.height)];
    [path moveToPoint:CGPointMake(0.41 * self.width, 0.72 * self.height)];
    [path moveToPoint:CGPointMake(0.79 * self.width, 0.64 * self.height)];
    
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    layer.path = path.CGPath;
    layer.strokeEnd = 0;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = kDuration;
    [self.layer addAnimation:animation forKey:kAnimationKey];
    
    _finish = finish;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    ((CAShapeLayer *)self.layer).strokeEnd = 1;
    [CATransaction commit];
    
    if (_finish) {
        _finish();
        _finish = nil;
    }
}

@end
