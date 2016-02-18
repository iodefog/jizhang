//
//  SSJReportFormsPercentCircle.m
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJPercentCircleView.h"
#import "SSJPercentCircleAdditionNode.h"

static NSString *const kAnimationKey = @"kAnimationKey";

@interface SSJPercentCircleView ()

@property (nonatomic, readwrite) UIEdgeInsets circleInsets;

@property (nonatomic, readwrite) CGFloat circleThickness;

@property (nonatomic) CGRect circleFrame;

@property (nonatomic, strong) CAShapeLayer *maskLayer;

@property (nonatomic, strong) NSMutableArray *circleLayers;

@property (nonatomic, strong) NSMutableArray *additionViews;

@property (nonatomic) NSUInteger circleAnimationCounter;

@end

@implementation SSJPercentCircleView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame insets:UIEdgeInsetsZero thickness:0];
}

- (instancetype)initWithFrame:(CGRect)frame insets:(UIEdgeInsets)insets thickness:(CGFloat)thickness {
    if (self = [super initWithFrame:frame]) {
        self.circleInsets = insets;
        self.circleThickness = thickness;
        self.circleLayers = [NSMutableArray array];
        self.additionViews = [NSMutableArray array];
        [self.layer addSublayer:self.maskLayer];
    }
    return self;
}

- (void)layoutSubviews {
    [self updateCircleFrame];
}

- (void)reloadData {

    if (!self.dataSource
        || ![self.dataSource respondsToSelector:@selector(numberOfComponentsInPercentCircle:)]
        || ![self.dataSource respondsToSelector:@selector(percentCircle:itemForComponentAtIndex:)]
        || self.circleThickness <= 0
        || CGRectIsEmpty(self.bounds)
        || CGRectIsEmpty(self.circleFrame)) {
        return;
    }
    
    //  移除之前的子视图、图层
    [self.circleLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.circleLayers removeAllObjects];
    
    [self.additionViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.additionViews removeAllObjects];
    
    NSUInteger numberOfComponents = [self.dataSource numberOfComponentsInPercentCircle:self];
    
    CGFloat overlapScale = 0;
    
    //  添加圆环图层
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.circleFrame), CGRectGetMidY(self.circleFrame)) radius:(CGRectGetWidth(self.circleFrame) * 0.5 - self.circleThickness) startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    
    self.maskLayer.path = circlePath.CGPath;
    self.circleAnimationCounter = 0;
    
    for (NSUInteger idx = 0; idx < numberOfComponents; idx ++) {
        
        if ([self.dataSource respondsToSelector:@selector(percentCircle:itemForComponentAtIndex:)]) {
            SSJReportFormsPercentCircleItem *item = [self.dataSource percentCircle:self itemForComponentAtIndex:idx];
            if (!item) {
                return;
            }
            
            item.previousScale = overlapScale;
            
            //  添加圆环
            CAShapeLayer *layer = [CAShapeLayer layer];
            layer.contentsScale = [[UIScreen mainScreen] scale];
            layer.path = circlePath.CGPath;
            layer.fillColor = [UIColor whiteColor].CGColor;
            layer.lineWidth = self.circleThickness * 2;
            layer.strokeColor = [UIColor ssj_colorWithHex:item.colorValue].CGColor;
            layer.strokeEnd = 0;
            layer.zPosition = numberOfComponents - idx;
            [self.layer addSublayer:layer];
            
            [self.circleLayers addObject:layer];
            
            //  给圆环添加动画
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            animation.toValue = @(overlapScale + item.scale);
            animation.duration = 0.7;
            animation.delegate = self;
            animation.removedOnCompletion = NO;
            animation.fillMode = kCAFillModeForwards;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            [layer addAnimation:animation forKey:kAnimationKey];
            
            overlapScale += item.scale;
            
            //  添加附加视图(折线、图片、比例)
            SSJPercentCircleAdditionNodeItem *additionViewItem = [[SSJPercentCircleAdditionNodeItem alloc] init];
            
            CGPoint startPoint = CGPointZero;
            CGPoint turnPoint = CGPointZero;
            CGPoint endPoint = CGPointZero;
            
            SSJPercentCircleAdditionNodeOrientation orientation = SSJPercentCircleAdditionNodeOrientationTopRight;
            
            //  根据比例计算出角度，再根据角度计算出折现的起点
            CGFloat angle = (0.5 * item.scale + item.previousScale) * M_PI * 2;
            CGFloat axisY = -cos(angle) * CGRectGetWidth(self.circleFrame) * 0.5 + CGRectGetMidY(self.circleFrame);
            CGFloat axisX = sin(angle) * CGRectGetWidth(self.circleFrame) * 0.5 + CGRectGetMidX(self.circleFrame);
            startPoint = CGPointMake(axisX, axisY);
            
            if (angle >= 0 && angle < M_PI_2) {
                turnPoint = CGPointMake(axisX + 5, axisY - 10);
                endPoint = CGPointMake(axisX + 5 + 35, axisY - 10);
                orientation = SSJPercentCircleAdditionNodeOrientationTopRight;
            } else if (angle >= M_PI_2 && angle < M_PI) {
                turnPoint = CGPointMake(axisX + 5, axisY + 10);
                endPoint = CGPointMake(axisX + 5 + 35, axisY + 10);
                orientation = SSJPercentCircleAdditionNodeOrientationBottomRight;
            } else if (angle >= M_PI && angle < M_PI + M_PI_2) {
                turnPoint = CGPointMake(axisX - 5, axisY + 10);
                endPoint = CGPointMake(axisX - 5 - 35, axisY + 10);
                orientation = SSJPercentCircleAdditionNodeOrientationBottomLeft;
            } else if (angle >= M_PI + M_PI_2) {
                turnPoint = CGPointMake(axisX - 5, axisY - 10);
                endPoint = CGPointMake(axisX - 5 - 35, axisY - 10);
                orientation = SSJPercentCircleAdditionNodeOrientationTopLeft;
            }
            
            additionViewItem.startPoint = startPoint;
            additionViewItem.turnPoint = turnPoint;
            additionViewItem.endPoint = endPoint;
            additionViewItem.orientation = orientation;
            additionViewItem.imageName = item.imageName;
            additionViewItem.imageRadius = 13;
            additionViewItem.borderColorValue = item.colorValue;
            additionViewItem.gapBetweenImageAndText = 0;
            additionViewItem.text = item.additionalText;
            additionViewItem.textSize = 15;
            additionViewItem.textColorValue = @"#a7a7a7";
            
            SSJPercentCircleAdditionNode *additionView = [[SSJPercentCircleAdditionNode alloc] initWithItem:additionViewItem];
            SSJPercentCircleAdditionNode *lastAdditionView = [self.additionViews lastObject];
            if (lastAdditionView) {
                if ([additionView testOverlap:lastAdditionView]) {
                    [self addSubview:additionView];
                    [self.additionViews addObject:additionView];
                }
            } else {
                [self addSubview:additionView];
                [self.additionViews addObject:additionView];
            }
            
//            [self addSubview:additionView];
//            [self.additionViews addObject:additionView];
        }
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    for (CAShapeLayer *circleLayer in self.circleLayers) {
        if ([circleLayer animationForKey:kAnimationKey] == anim) {
            CABasicAnimation *circleAnimation = (CABasicAnimation *)anim;
            [circleLayer removeAnimationForKey:kAnimationKey];
            circleLayer.strokeEnd = [circleAnimation.toValue floatValue];
            
            self.circleAnimationCounter ++;
            if (self.circleAnimationCounter == self.circleLayers.count) {
                [self.additionViews makeObjectsPerformSelector:@selector(beginDraw)];
            }
            
            return;
        }
    }
}

- (void)updateCircleFrame {
    CGRect circleFrame = UIEdgeInsetsInsetRect(self.bounds, self.circleInsets);
    CGFloat circleDiam = MIN(circleFrame.size.width, circleFrame.size.height);
    self.circleFrame = CGRectMake((self.width - circleDiam) * 0.5, circleFrame.origin.y, circleDiam, circleDiam);
}

- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.fillColor = [UIColor whiteColor].CGColor;
        _maskLayer.contentsScale = [[UIScreen mainScreen] scale];
        _maskLayer.lineWidth = 0;
        _maskLayer.zPosition = FLT_MAX;
    }
    return _maskLayer;
}

@end
