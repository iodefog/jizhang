//
//  SSJPercentCircleNode.m
//  SuiShouJi
//
//  Created by old lang on 16/2/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJPercentCircleNode.h"

@implementation SSJPercentCircleNodeItem

@end



static NSString *const kAnimationKey = @"kAnimationKey";

@interface SSJPercentCircleNode () <CAAnimationDelegate>

@property (nonatomic, strong) UIColor *fillColor;

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) NSMutableArray *circleLayers;

@property (nonatomic, strong) NSMutableArray *shootLayers;

@property (nonatomic, copy) void (^completion)(void);

@property (nonatomic) NSUInteger animationCounter;

@end

@implementation SSJPercentCircleNode

+ (instancetype)node {
    return [[SSJPercentCircleNode alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.circleLayers = [NSMutableArray array];
        self.shootLayers = [NSMutableArray array];
        _fillColor = [UIColor clearColor];
    }
    return self;
}

- (void)setItems:(NSArray *)items completion:(void (^)(void))completion {
//    if (![self.items isEqualToArray:items]) {
//        self.items = items;
//        self.completion = completion;
//        [self reloadCircleLayers];
//    }
    
    self.animationCounter = 0;
    self.items = items;
    self.completion = completion;
    [self reloadCircleLayers];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    for (CAShapeLayer *circleLayer in self.circleLayers) {
        if ([circleLayer animationForKey:kAnimationKey] == anim) {
            CABasicAnimation *circleAnimation = (CABasicAnimation *)anim;
            [circleLayer removeAnimationForKey:kAnimationKey];
            circleLayer.strokeEnd = [circleAnimation.toValue floatValue];
            
            self.animationCounter ++;
            if (self.animationCounter == self.circleLayers.count) {
                [self reloadShootLayers];
                if (self.completion) {
                    self.completion();
                }
                break;
            }
        }
    }
}

- (void)reloadCircleLayers {
    [self.circleLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.circleLayers removeAllObjects];
    
    [self.shootLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.shootLayers removeAllObjects];
    
    if (self.items.count == 0) {
        if (self.completion) {
            self.completion();
        }
        return;
    }
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:center
                                                              radius:self.radius
                                                          startAngle:self.startAngle
                                                            endAngle:self.startAngle + M_PI * 2
                                                           clockwise:YES];
    
    for (int idx = 0; idx < self.items.count; idx ++) {
        SSJPercentCircleNodeItem *item = self.items[idx];
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.contentsScale = [[UIScreen mainScreen] scale];
        layer.path = circlePath.CGPath;
        layer.fillColor = _fillColor.CGColor;
        layer.lineWidth = self.thickness;
        layer.strokeColor = item.color.CGColor;
        layer.strokeEnd = 0;
        layer.zPosition = self.items.count - idx;
        [self.layer addSublayer:layer];
        
        [self.circleLayers addObject:layer];
        
        // 给圆环添加动画
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.toValue = @(item.endAngle / (M_PI * 2));
        animation.duration = 0.4;
        animation.delegate = self;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [layer addAnimation:animation forKey:kAnimationKey];
    }
}

// 之前的layerlayer之间有重叠区域，直接截图的话会有问题，所以先移除之前的layer，再重建没有重叠区域的layer然后截图
- (void)reloadShootLayers {
    [self.circleLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.circleLayers removeAllObjects];
    
    for (SSJPercentCircleNodeItem *item in self.items) {
        CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:center
                                                                  radius:self.radius
                                                              startAngle:(item.startAngle + self.startAngle)
                                                                endAngle:(item.endAngle + self.startAngle)
                                                               clockwise:YES];
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.contentsScale = [[UIScreen mainScreen] scale];
        layer.path = circlePath.CGPath;
        layer.fillColor = _fillColor.CGColor;
        layer.lineWidth = self.thickness;
        layer.strokeColor = item.color.CGColor;
        [self.layer addSublayer:layer];
        
        [self.shootLayers addObject:layer];
    }
}

@end
