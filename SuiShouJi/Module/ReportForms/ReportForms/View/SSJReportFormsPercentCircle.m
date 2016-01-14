//
//  SSJReportFormsPercentCircle.m
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJReportFormsPercentCircle.h"
#import "SSJReportFormsPercentCircleComponent.h"

static NSString *const kAnimationKey = @"kAnimationKey";

@interface SSJReportFormsPercentCircle ()

@property (nonatomic) CGRect circleFrame;
@property (nonatomic, strong) NSMutableDictionary *componentDic;
@property (nonatomic, strong) CAShapeLayer *maskLayer;

@end

@implementation SSJReportFormsPercentCircle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.componentDic = [NSMutableDictionary dictionary];
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
    for (SSJReportFormsPercentCircleComponent *component in [self.componentDic allValues]) {
        [component.circleLayer removeFromSuperlayer];
        [component.lineLayer removeFromSuperlayer];
        [component.imageView removeFromSuperview];
        [component.scaleLab removeFromSuperview];
    }
    [self.componentDic removeAllObjects];
    
    NSUInteger numberOfComponents = [self.dataSource numberOfComponentsInPercentCircle:self];
    
    CGFloat overlapScale = 0;
    NSMutableArray *circleItemArr = [NSMutableArray array];
    
    //  添加圆环图层
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.circleFrame), CGRectGetMidY(self.circleFrame)) radius:(CGRectGetWidth(self.circleFrame) * 0.5 - self.circleWidth) startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    
    self.maskLayer.path = circlePath.CGPath;
    
    for (NSUInteger idx = 0; idx < numberOfComponents; idx ++) {
        
        if ([self.dataSource respondsToSelector:@selector(percentCircle:itemForComponentAtIndex:)]) {
            SSJReportFormsPercentCircleItem *item = [self.dataSource percentCircle:self itemForComponentAtIndex:idx];
            if (!item) {
                return;
            }
            item.previousScale = overlapScale;
            
            CAShapeLayer *layer = [CAShapeLayer layer];
            layer.contentsScale = [[UIScreen mainScreen] scale];
            layer.path = circlePath.CGPath;
            layer.fillColor = [UIColor whiteColor].CGColor;
            layer.lineWidth = self.circleWidth * 2;
            layer.strokeColor = item.color.CGColor;
            layer.strokeEnd = 0;
            layer.zPosition = numberOfComponents - idx;
            [self.layer addSublayer:layer];
            
            SSJReportFormsPercentCircleComponent *circleComponent = [[SSJReportFormsPercentCircleComponent alloc] init];
            circleComponent.circleLayer = layer;
            [self.componentDic setObject:circleComponent forKey:item.identifier];
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            animation.toValue = @(overlapScale + item.scale);
            animation.duration = 0.7;
            animation.delegate = self;
            animation.removedOnCompletion = NO;
            animation.fillMode = kCAFillModeForwards;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            [layer addAnimation:animation forKey:kAnimationKey];
            
            overlapScale += item.scale;
            [circleItemArr addObject:item];
        }
    }
    
    //  根据元素的scale对数组进行降序排序
    [circleItemArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        SSJReportFormsPercentCircleItem *item1 = obj1;
        SSJReportFormsPercentCircleItem *item2 = obj2;
        if (item1.scale > item2.scale) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        if (item1.scale < item2.scale) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    //  遍历前5个比例最大的收支类型，只有这5个显示图片和比例值
    for (int i = 0; i < MIN(circleItemArr.count, 5); i ++) {
        
        SSJReportFormsPercentCircleItem *item = circleItemArr[i];
        SSJReportFormsPercentCircleComponent *circleComponent = [self.componentDic objectForKey:item.identifier];
        
        //  根据比例计算出角度，再根据角度计算出折现的起点
        CGFloat angle = (0.5 * item.scale + item.previousScale) * M_PI * 2;
        CGFloat axisY = -cos(angle) * CGRectGetWidth(self.circleFrame) * 0.5 + CGRectGetMidY(self.circleFrame);
        CGFloat axisX = sin(angle) * CGRectGetWidth(self.circleFrame) * 0.5 + CGRectGetMidX(self.circleFrame);
        
        //  添加折线图层
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        [linePath moveToPoint:CGPointMake(axisX, axisY)];
        
        if (angle >= 0 && angle < M_PI_2) {
            [linePath addLineToPoint:CGPointMake(axisX + 5, axisY - 10)];
            [linePath addLineToPoint:CGPointMake(axisX + 5 + 35, axisY - 10)];
        } else if (angle >= M_PI_2 && angle < M_PI) {
            [linePath addLineToPoint:CGPointMake(axisX + 5, axisY + 10)];
            [linePath addLineToPoint:CGPointMake(axisX + 5 + 35, axisY + 10)];
        } else if (angle >= M_PI && angle < M_PI + M_PI_2) {
            [linePath addLineToPoint:CGPointMake(axisX - 5, axisY + 10)];
            [linePath addLineToPoint:CGPointMake(axisX - 5 - 35, axisY + 10)];
        } else if (angle >= M_PI + M_PI_2) {
            [linePath addLineToPoint:CGPointMake(axisX - 5, axisY - 10)];
            [linePath addLineToPoint:CGPointMake(axisX - 5 - 35, axisY - 10)];
        }
        
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        lineLayer.contentsScale = [[UIScreen mainScreen] scale];
        lineLayer.lineWidth = 1;
        lineLayer.strokeColor = [UIColor ssj_colorWithHex:@"#e8e8e8"].CGColor;
        lineLayer.fillColor = [UIColor whiteColor].CGColor;
        lineLayer.path = linePath.CGPath;
        lineLayer.strokeEnd = 0;
        
        [self.layer addSublayer:lineLayer];
        circleComponent.lineLayer = lineLayer;
        
        //  添加图片
        CGFloat imageDiam = MAX(item.image.size.width, item.image.size.height) + 10;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:item.image];
        imageView.size = CGSizeMake(imageDiam, imageDiam);
        imageView.contentMode = UIViewContentModeCenter;
        imageView.layer.borderColor = item.color.CGColor;
        imageView.layer.borderWidth = 0.5;
        imageView.layer.cornerRadius = imageView.width * 0.5;
        imageView.layer.transform = CATransform3DMakeScale(0, 0, 0);
        if (angle >= 0 && angle < M_PI) {
            imageView.center = CGPointMake(linePath.currentPoint.x + imageDiam * 0.5, linePath.currentPoint.y);
        } else if (angle >= M_PI) {
            imageView.center = CGPointMake(linePath.currentPoint.x - imageDiam * 0.5, linePath.currentPoint.y);
        }
        
        [self addSubview:imageView];
        circleComponent.imageView = imageView;
        
        //  添加比例值文本
        UILabel *scaleLab = [[UILabel alloc] initWithFrame:CGRectZero];
        scaleLab.hidden = YES;
        scaleLab.backgroundColor = [UIColor whiteColor];
        scaleLab.font = [UIFont systemFontOfSize:12];
        scaleLab.textColor = [UIColor ssj_colorWithHex:@"#393939"];
        scaleLab.text = [NSString stringWithFormat:@"%.0f％", item.scale * 100];
        [scaleLab sizeToFit];
        scaleLab.top = imageView.top + imageDiam * 0.5 + 5;
        scaleLab.centerX =  imageView.centerX;
        
        [self addSubview:scaleLab];
        circleComponent.scaleLab = scaleLab;
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    for (SSJReportFormsPercentCircleComponent *component in self.componentDic.allValues) {
        
        if ([component.circleLayer animationForKey:kAnimationKey] == anim) {
            
            CABasicAnimation *circleAnimation = (CABasicAnimation *)anim;
            [component.circleLayer removeAnimationForKey:kAnimationKey];
            component.circleLayer.strokeEnd = [circleAnimation.toValue floatValue];
            
            CABasicAnimation *lineAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            lineAnimation.duration = 0.35;
            lineAnimation.toValue = @(1);
            lineAnimation.delegate = self;
            lineAnimation.removedOnCompletion = NO;
            lineAnimation.fillMode = kCAFillModeForwards;
            lineAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            [component.lineLayer addAnimation:lineAnimation forKey:kAnimationKey];
            
            return;
        }
        
        if ([component.lineLayer animationForKey:kAnimationKey] == anim) {
            
            CABasicAnimation *lineAnimation = (CABasicAnimation *)anim;
            [component.lineLayer removeAnimationForKey:kAnimationKey];
            component.lineLayer.strokeEnd = [lineAnimation.toValue floatValue];
            
            CAKeyframeAnimation *imageAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
            imageAnimation.duration = 0.35;
            imageAnimation.delegate = self;
            imageAnimation.values = @[@0.7,@0.9,@1.1,@1];
            imageAnimation.removedOnCompletion = NO;
            [component.imageView.layer addAnimation:imageAnimation forKey:kAnimationKey];
            
            component.imageView.layer.transform = CATransform3DMakeScale(1, 1, 1);
            
            return;
        }
        
        if ([component.imageView.layer animationForKey:kAnimationKey] == anim) {
            [component.imageView.layer removeAnimationForKey:kAnimationKey];
            [UIView transitionWithView:component.scaleLab duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                component.scaleLab.hidden = NO;
            } completion:NULL];
            
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
