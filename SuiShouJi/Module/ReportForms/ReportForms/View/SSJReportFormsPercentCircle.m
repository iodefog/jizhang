//
//  SSJReportFormsPercentCircle.m
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJReportFormsPercentCircle.h"
#import "SSJReportFormsPercentCircleComponent.h"
#import "SSJReportFormsPercentCircleAdditionView.h"

static NSString *const kAnimationKey = @"kAnimationKey";

@interface SSJReportFormsPercentCircle ()

@property (nonatomic) CGRect circleFrame;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) NSMutableArray *circleLayers;
@property (nonatomic, strong) NSMutableArray *additionViews;

@property (nonatomic) NSUInteger circleAnimationCounter;

@end

@implementation SSJReportFormsPercentCircle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        self.componentDic = [NSMutableDictionary dictionary];
        self.circleLayers = [NSMutableArray array];
        self.additionViews = [NSMutableArray array];
        [self.layer addSublayer:self.maskLayer];
    }
    return self;
}

- (void)layoutSubviews {
    [self updateCircleFrame];
//    [self reloadData];
    
//    for (CAShapeLayer *layer in self.layers) {
//        layer.frame = self.circleFrame;
//    }
}

- (void)setCircleInsets:(UIEdgeInsets)circleInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(_circleInsets, circleInsets)) {
        _circleInsets = circleInsets;
        [self updateCircleFrame];
//        [self reloadData];
        [self setNeedsLayout];
    }
}

- (void)setCircleWidth:(CGFloat)circleWidth {
    if (_circleWidth != circleWidth) {
        _circleWidth = circleWidth;
//        [self reloadData];
        [self setNeedsLayout];
    }
}

- (void)setDataSource:(id<SSJReportFormsPercentCircleDataSource>)dataSource {
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
//        [self reloadData];
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
    
    //  移除之前的子视图、图层
    [self.circleLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.circleLayers removeAllObjects];
    
    [self.additionViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.additionViews removeAllObjects];
    
    NSUInteger numberOfComponents = [self.dataSource numberOfComponentsInPercentCircle:self];
    
    CGFloat overlapScale = 0;
//    NSMutableArray *circleItemArr = [NSMutableArray array];
    
    //  添加圆环图层
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.circleFrame), CGRectGetMidY(self.circleFrame)) radius:(CGRectGetWidth(self.circleFrame) * 0.5 - self.circleWidth) startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    
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
            layer.lineWidth = self.circleWidth * 2;
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
//            [circleItemArr addObject:item];
            
            //  添加附加视图(折线、图片、比例)
            SSJReportFormsPercentCircleAdditionViewItem *additionViewItem = [[SSJReportFormsPercentCircleAdditionViewItem alloc] init];
            
            CGPoint startPoint = CGPointZero;
            CGPoint turnPoint = CGPointZero;
            CGPoint endPoint = CGPointZero;
            
            SSJReportFormsPercentCircleAdditionViewOrientation orientation = SSJReportFormsPercentCircleAdditionViewOrientationTopRight;
            
            //  根据比例计算出角度，再根据角度计算出折现的起点
            CGFloat angle = (0.5 * item.scale + item.previousScale) * M_PI * 2;
            CGFloat axisY = -cos(angle) * CGRectGetWidth(self.circleFrame) * 0.5 + CGRectGetMidY(self.circleFrame);
            CGFloat axisX = sin(angle) * CGRectGetWidth(self.circleFrame) * 0.5 + CGRectGetMidX(self.circleFrame);
            startPoint = CGPointMake(axisX, axisY);
            
            if (angle >= 0 && angle < M_PI_2) {
                turnPoint = CGPointMake(axisX + 5, axisY - 10);
                endPoint = CGPointMake(axisX + 5 + 35, axisY - 10);
                orientation = SSJReportFormsPercentCircleAdditionViewOrientationTopRight;
            } else if (angle >= M_PI_2 && angle < M_PI) {
                turnPoint = CGPointMake(axisX + 5, axisY + 10);
                endPoint = CGPointMake(axisX + 5 + 35, axisY + 10);
                orientation = SSJReportFormsPercentCircleAdditionViewOrientationBottomRight;
            } else if (angle >= M_PI && angle < M_PI + M_PI_2) {
                turnPoint = CGPointMake(axisX - 5, axisY + 10);
                endPoint = CGPointMake(axisX - 5 - 35, axisY + 10);
                orientation = SSJReportFormsPercentCircleAdditionViewOrientationBottomLeft;
            } else if (angle >= M_PI + M_PI_2) {
                turnPoint = CGPointMake(axisX - 5, axisY - 10);
                endPoint = CGPointMake(axisX - 5 - 35, axisY - 10);
                orientation = SSJReportFormsPercentCircleAdditionViewOrientationTopLeft;
            }
            
            additionViewItem.startPoint = startPoint;
            additionViewItem.turnPoint = turnPoint;
            additionViewItem.endPoint = endPoint;
            additionViewItem.orientation = orientation;
            additionViewItem.imageName = item.imageName;
            additionViewItem.imageRadius = 20;
            additionViewItem.borderColorValue = item.colorValue;
            additionViewItem.gapBetweenImageAndText = 5;
            additionViewItem.text = [NSString stringWithFormat:@"%.0f％", item.scale * 100];
            additionViewItem.textSize = 12;
            
            SSJReportFormsPercentCircleAdditionView *additionView = [[SSJReportFormsPercentCircleAdditionView alloc] initWithItem:additionViewItem];
            SSJReportFormsPercentCircleAdditionView *lastAdditionView = [self.additionViews lastObject];
            if (lastAdditionView) {
                if ([additionView testOverlap:lastAdditionView]) {
                    [self addSubview:additionView];
                    [self.additionViews addObject:additionView];
                }
            } else {
                [self addSubview:additionView];
                [self.additionViews addObject:additionView];
            }
        }
    }
    
    //  根据元素的scale对数组进行降序排序
//    [circleItemArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//        SSJReportFormsPercentCircleItem *item1 = obj1;
//        SSJReportFormsPercentCircleItem *item2 = obj2;
//        if (item1.scale > item2.scale) {
//            return (NSComparisonResult)NSOrderedAscending;
//        }
//        
//        if (item1.scale < item2.scale) {
//            return (NSComparisonResult)NSOrderedDescending;
//        }
//        return (NSComparisonResult)NSOrderedSame;
//    }];
    
    //  遍历前5个比例最大的收支类型，只有这5个显示图片和比例值
//    for (int i = 0; i < MIN(circleItemArr.count, 5); i ++) {
//        
//        SSJReportFormsPercentCircleItem *item = circleItemArr[i];
//        SSJReportFormsPercentCircleAdditionViewItem *additionViewItem = [[SSJReportFormsPercentCircleAdditionViewItem alloc] init];
//        
//        CGPoint startPoint = CGPointZero;
//        CGPoint turnPoint = CGPointZero;
//        CGPoint endPoint = CGPointZero;
//        
//        SSJReportFormsPercentCircleAdditionViewOrientation orientation = SSJReportFormsPercentCircleAdditionViewOrientationTopRight;
//        
//        //  根据比例计算出角度，再根据角度计算出折现的起点
//        CGFloat angle = (0.5 * item.scale + item.previousScale) * M_PI * 2;
//        CGFloat axisY = -cos(angle) * CGRectGetWidth(self.circleFrame) * 0.5 + CGRectGetMidY(self.circleFrame);
//        CGFloat axisX = sin(angle) * CGRectGetWidth(self.circleFrame) * 0.5 + CGRectGetMidX(self.circleFrame);
//        startPoint = CGPointMake(axisX, axisY);
//        
//        if (angle >= 0 && angle < M_PI_2) {
//            turnPoint = CGPointMake(axisX + 5, axisY - 10);
//            endPoint = CGPointMake(axisX + 5 + 35, axisY - 10);
//            orientation = SSJReportFormsPercentCircleAdditionViewOrientationTopRight;
//        } else if (angle >= M_PI_2 && angle < M_PI) {
//            turnPoint = CGPointMake(axisX + 5, axisY + 10);
//            endPoint = CGPointMake(axisX + 5 + 35, axisY + 10);
//            orientation = SSJReportFormsPercentCircleAdditionViewOrientationBottomRight;
//        } else if (angle >= M_PI && angle < M_PI + M_PI_2) {
//            turnPoint = CGPointMake(axisX - 5, axisY + 10);
//            endPoint = CGPointMake(axisX - 5 - 35, axisY + 10);
//            orientation = SSJReportFormsPercentCircleAdditionViewOrientationBottomLeft;
//        } else if (angle >= M_PI + M_PI_2) {
//            turnPoint = CGPointMake(axisX - 5, axisY - 10);
//            endPoint = CGPointMake(axisX - 5 - 35, axisY - 10);
//            orientation = SSJReportFormsPercentCircleAdditionViewOrientationTopLeft;
//        }
//        
//        additionViewItem.startPoint = startPoint;
//        additionViewItem.turnPoint = turnPoint;
//        additionViewItem.endPoint = endPoint;
//        additionViewItem.orientation = orientation;
//        additionViewItem.imageName = item.imageName;
//        additionViewItem.imageRadius = 20;
//        additionViewItem.borderColorValue = item.colorValue;
//        additionViewItem.gapBetweenImageAndText = 5;
//        additionViewItem.text = [NSString stringWithFormat:@"%.0f％", item.scale * 100];
//        additionViewItem.textSize = 12;
//        
//        SSJReportFormsPercentCircleAdditionView *additionView = [[SSJReportFormsPercentCircleAdditionView alloc] initWithItem:additionViewItem];
//        SSJReportFormsPercentCircleAdditionView *lastAdditionView = [self.additionViews lastObject];
//        if (lastAdditionView) {
//            if ([additionView testOverlap:lastAdditionView]) {
//                [self addSubview:additionView];
//                [self.additionViews addObject:additionView];
//            }
//        } else {
//            [self addSubview:additionView];
//            [self.additionViews addObject:additionView];
//        }
//    }
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
    CGFloat circleRadius = MIN(circleFrame.size.width, circleFrame.size.height);
    self.circleFrame = CGRectMake(circleFrame.origin.x, circleFrame.origin.y, circleRadius, circleRadius);
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
