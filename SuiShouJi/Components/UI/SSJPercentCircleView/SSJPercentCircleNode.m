//
//  SSJPercentCircleNode.m
//  SuiShouJi
//
//  Created by old lang on 16/2/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJPercentCircleNode.h"

static NSString *const kAnimationKey = @"kAnimationKey";

@interface SSJPercentCircleNode ()

@property (nonatomic) CGPoint centerPoint;

@property (nonatomic) CGFloat radius;

@property (nonatomic) CGFloat lineWith;

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) CAShapeLayer *maskLayer;

@property (nonatomic, strong) NSMutableArray *circleLayers;

@property (nonatomic, strong) NSMutableArray *shootLayers;

@property (nonatomic, copy) void (^completion)(void);

@property (nonatomic) NSUInteger animationCounter;

@end

@implementation SSJPercentCircleNode

+ (instancetype)nodeWithCenter:(CGPoint)center radius:(CGFloat)radius lineWith:(CGFloat)lineWith {
    SSJPercentCircleNode *node = [[SSJPercentCircleNode alloc] initWithFrame:CGRectZero];
    node.centerPoint = center;
    node.radius = radius;
    node.lineWith = lineWith;
    return node;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.circleLayers = [NSMutableArray array];
        self.shootLayers = [NSMutableArray array];
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
    [self.shootLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.shootLayers removeAllObjects];
    
    [self.maskLayer removeFromSuperlayer];
    self.maskLayer = nil;
    
    if (self.items.count == 0) {
        if (self.completion) {
            self.completion();
        }
        return;
    }
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:self.radius startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    
    for (int idx = 0; idx < self.items.count; idx ++) {
        SSJPercentCircleNodeItem *item = self.items[idx];
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.contentsScale = [[UIScreen mainScreen] scale];
        layer.path = circlePath.CGPath;
        layer.fillColor = [UIColor whiteColor].CGColor;
        layer.lineWidth = self.lineWith;
        layer.strokeColor = [UIColor ssj_colorWithHex:item.colorValue].CGColor;
        layer.strokeEnd = 0;
        layer.zPosition = self.items.count - idx;
        [self.layer addSublayer:layer];
        
        [self.circleLayers addObject:layer];
        
        //  给圆环添加动画
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.toValue = @(item.endAngle / (M_PI * 2));
        animation.duration = 0.4;
        animation.delegate = self;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [layer addAnimation:animation forKey:kAnimationKey];
    }
    
    [self.layer addSublayer:self.maskLayer];
}

- (void)reloadShootLayers {
    [self.circleLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.circleLayers removeAllObjects];
    
    [self.maskLayer removeFromSuperlayer];
    self.maskLayer = nil;
    
    for (SSJPercentCircleNodeItem *item in self.items) {
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:self.radius startAngle:(item.startAngle - M_PI_2) endAngle:(item.endAngle - M_PI_2) clockwise:YES];
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.contentsScale = [[UIScreen mainScreen] scale];
        layer.path = circlePath.CGPath;
        layer.fillColor = [UIColor whiteColor].CGColor;
        layer.lineWidth = self.lineWith;
        layer.strokeColor = [UIColor ssj_colorWithHex:item.colorValue].CGColor;
        [self.layer addSublayer:layer];
        
        [self.shootLayers addObject:layer];
    }
    
    [self.layer addSublayer:self.maskLayer];
}

- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.fillColor = [UIColor whiteColor].CGColor;
        _maskLayer.contentsScale = [[UIScreen mainScreen] scale];
        _maskLayer.lineWidth = 0;
        _maskLayer.zPosition = FLT_MAX;
        _maskLayer.path = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:self.radius startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES].CGPath;
    }
    return _maskLayer;
}

@end
