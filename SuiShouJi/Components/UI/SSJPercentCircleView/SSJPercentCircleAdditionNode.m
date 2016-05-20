//
//  SSJReportFormsPercentCircleAdditionView.m
//  SuiShouJi
//
//  Created by old lang on 16/1/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJPercentCircleAdditionNode.h"

static NSString *const kAnimationKey = @"kAnimationKey";

@interface SSJPercentCircleAdditionNode ()

@property (nonatomic, readwrite, strong) SSJPercentCircleAdditionNodeItem *item;

@property (nonatomic, strong) CAShapeLayer *brokenLineLayer;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, copy) void (^completion)(void);

@end

@implementation SSJPercentCircleAdditionNode

- (instancetype)initWithItem:(SSJPercentCircleAdditionNodeItem *)item {
    if (!item) {
        return nil;
    }
    
    if (self = [super initWithFrame:CGRectZero]) {
        self.item = item;
        
        self.brokenLineLayer.strokeColor = [UIColor ssj_colorWithHex:self.item.borderColorValue].CGColor;
        [self.layer addSublayer:self.brokenLineLayer];
        [self addSubview:self.imageView];
        [self addSubview:self.textLabel];
    }
    return self;
}

- (void)layoutSubviews {
    self.imageView.center = [self imageCenterForItem:self.item];
    self.textLabel.center = [self labelCenterForItem:self.item];
}

- (BOOL)testOverlap:(SSJPercentCircleAdditionNode *)view {
    
    if (!view) {
        return NO;
    }
    
    SSJPercentCircleAdditionNodeItem *anotherItem = view.item;
    if (self.item.startPoint.x == anotherItem.startPoint.x) {
        return YES;
    }
    
    CGPoint lastImageCenter = [self imageCenterForItem:view.item];
    CGFloat lastImageRadius = view.item.imageRadius;
    CGRect lastImageRect = CGRectMake(lastImageCenter.x - lastImageRadius, lastImageCenter.y - lastImageRadius, lastImageRadius * 2, lastImageRadius * 2);
    
    CGPoint currentImageCenter = [self imageCenterForItem:self.item];
    CGFloat currentImageRadius = self.item.imageRadius;
    CGRect currentImageRect = CGRectMake(currentImageCenter.x - currentImageRadius, currentImageCenter.y - currentImageRadius, currentImageRadius * 2, currentImageRadius * 2);
    
    return CGRectIntersectsRect(lastImageRect, currentImageRect);
}

- (void)beginDrawWithCompletion:(void (^)(void))completion {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:self.item.startPoint];
    [path addLineToPoint:[self lineEndPointForItem:self.item]];
    
    self.brokenLineLayer.path = path.CGPath;
    
    CABasicAnimation *lineAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    lineAnimation.duration = 0.1;
    lineAnimation.toValue = @(1);
    lineAnimation.delegate = self;
    lineAnimation.removedOnCompletion = NO;
    lineAnimation.fillMode = kCAFillModeForwards;
    lineAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.brokenLineLayer addAnimation:lineAnimation forKey:kAnimationKey];
    
    self.completion = completion;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([self.brokenLineLayer animationForKey:kAnimationKey] == anim) {
        CABasicAnimation *circleAnimation = (CABasicAnimation *)anim;
        [self.brokenLineLayer removeAnimationForKey:kAnimationKey];
        
//        [CATransaction begin];
//        [CATransaction setDisableActions:YES];
        self.brokenLineLayer.strokeEnd = [circleAnimation.toValue floatValue];
//        [CATransaction commit];
        
        [self showImageView];
    }
}

#pragma mark - Private
- (void)showImageView {
    [UIView animateKeyframesWithDuration:0.36 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.25 animations:^{
            self.imageView.transform = CGAffineTransformMakeScale(0.7, 0.7);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.25 relativeDuration:0.25 animations:^{
            self.imageView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.25 animations:^{
            self.imageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.75 relativeDuration:0.25 animations:^{
            self.imageView.transform = CGAffineTransformMakeScale(1, 1);
        }];
    } completion:^(BOOL finished) {
        [self showTextLabel];
    }];
}

- (void)showTextLabel {
    [UIView transitionWithView:self.textLabel duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.textLabel.hidden = NO;
    } completion:^(BOOL finished) {
        if (self.completion) {
            self.completion();
        }
    }];
}

- (CGPoint)lineEndPointForItem:(SSJPercentCircleAdditionNodeItem *)item {
    CGFloat angle = item.angle;
    angle = angle - floor(angle / (M_PI * 2)) * M_PI * 2;
    
    CGFloat lineEndPointX = item.startPoint.x + cos(angle) * item.lineLength;
    CGFloat lineEndPointY = item.startPoint.y + sin(angle) * item.lineLength;
    
    return CGPointMake(lineEndPointX, lineEndPointY);
}

- (CGPoint)imageCenterForItem:(SSJPercentCircleAdditionNodeItem *)item {
    CGFloat angle = item.angle;
    angle = angle - floor(angle / (M_PI * 2)) * M_PI * 2;
    
    CGFloat imageCenterX = item.startPoint.x + cos(angle) * (item.lineLength + item.imageRadius);
    CGFloat imageCenterY = item.startPoint.y + sin(angle) * (item.lineLength + item.imageRadius);
    
    return CGPointMake(imageCenterX, imageCenterY);
}

- (CGPoint)labelCenterForItem:(SSJPercentCircleAdditionNodeItem *)item {
    CGFloat angle = item.angle;
    angle = angle - floor(angle / (M_PI * 2)) * M_PI * 2;
    
    CGSize labelSize = [item.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:item.textSize]}];
    CGFloat labelRadius = MAX(labelSize.width, labelSize.height) * 0.5;
    
    CGPoint labelCenter = CGPointZero;
    
    if (angle == 0) {
        labelCenter = CGPointMake(item.startPoint.x + item.lineLength + item.imageRadius * 2 + labelRadius + 5 , item.startPoint.y);
    } else if (angle > 0 && angle < M_PI_4) {
        
        CGFloat sideLength = fabs(cos(angle)) * (item.lineLength + item.imageRadius) + item.imageRadius + labelRadius;
        CGFloat labelCenterX = item.startPoint.x + sideLength;
        CGFloat labelCenterY = item.startPoint.y + sideLength * fabs(tan(angle));
        labelCenter = CGPointMake(labelCenterX, labelCenterY);
        
    } else if (angle >= M_PI_4 && angle < M_PI_2) {
        
        CGFloat sideLength = fabs(sin(angle)) * (item.lineLength + item.imageRadius) + item.imageRadius + labelRadius;
        CGFloat labelCenterX = item.startPoint.x + sideLength / fabs(tan(angle));
        CGFloat labelCenterY = item.startPoint.y + sideLength;
        labelCenter = CGPointMake(labelCenterX, labelCenterY);
        
    } else if (angle == M_PI_2) {
        
        labelCenter = CGPointMake(item.startPoint.x , item.startPoint.y + item.lineLength + item.imageRadius * 2 + labelRadius + 5);
        
    } else if (angle > M_PI_2 && angle < M_PI_2 + M_PI_4) {
        
        CGFloat sideLength = fabs(sin(angle)) * (item.lineLength + item.imageRadius) + item.imageRadius + labelRadius;
        CGFloat labelCenterX = item.startPoint.x - sideLength / fabs(tan(angle));
        CGFloat labelCenterY = item.startPoint.y + sideLength;
        labelCenter = CGPointMake(labelCenterX, labelCenterY);
        
    } else if (angle >= M_PI_2 + M_PI_4 && angle < M_PI) {
        
        CGFloat sideLength = fabs(cos(angle)) * (item.lineLength + item.imageRadius) + item.imageRadius + labelRadius;
        CGFloat labelCenterX = item.startPoint.x - sideLength;
        CGFloat labelCenterY = item.startPoint.y + sideLength * fabs(tan(angle));
        labelCenter = CGPointMake(labelCenterX, labelCenterY);
        
    } else if (angle == M_PI) {
        
        labelCenter = CGPointMake(item.startPoint.x - item.lineLength - item.imageRadius * 2 - labelRadius - 5, item.startPoint.y);
        
    } else if (angle > M_PI && angle < M_PI + M_PI_4) {
        
        CGFloat sideLength = fabs(cos(angle)) * (item.lineLength + item.imageRadius) + item.imageRadius + labelRadius;
        CGFloat labelCenterX = item.startPoint.x - sideLength;
        CGFloat labelCenterY = item.startPoint.y - sideLength * fabs(tan(angle));
        labelCenter = CGPointMake(labelCenterX, labelCenterY);
        
    } else if (angle >= M_PI + M_PI_4 && angle < M_PI * 1.5) {
        
        CGFloat sideLength = fabs(sin(angle)) * (item.lineLength + item.imageRadius) + item.imageRadius + labelRadius;
        CGFloat labelCenterX = item.startPoint.x - sideLength / fabs(tan(angle));
        CGFloat labelCenterY = item.startPoint.y - sideLength;
        labelCenter = CGPointMake(labelCenterX, labelCenterY);
        
    } else if (angle == M_PI * 1.5) {
        
        labelCenter = CGPointMake(item.startPoint.x, item.startPoint.y - item.lineLength - item.imageRadius * 2 - labelRadius - 5);
        
    } else if (angle > M_PI * 1.5 && angle < M_PI * 1.5 + M_PI_4) {
        
        CGFloat sideLength = fabs(sin(angle)) * (item.lineLength + item.imageRadius) + item.imageRadius + labelRadius;
        CGFloat labelCenterX = item.startPoint.x + sideLength / fabs(tan(angle));
        CGFloat labelCenterY = item.startPoint.y - sideLength;
        labelCenter = CGPointMake(labelCenterX, labelCenterY);
        
    } else if (angle >= M_PI * 1.5 + M_PI_4 && angle < M_PI * 2) {
        
        CGFloat sideLength = fabs(cos(angle)) * (item.lineLength + item.imageRadius) + item.imageRadius + labelRadius;
        CGFloat labelCenterX = item.startPoint.x + sideLength;
        CGFloat labelCenterY = item.startPoint.y - sideLength * fabs(tan(angle));
        labelCenter = CGPointMake(labelCenterX, labelCenterY);
        
    }
    
    return labelCenter;
}

#pragma mark - Getter
- (CAShapeLayer *)brokenLineLayer {
    if (!_brokenLineLayer) {
        _brokenLineLayer = [CAShapeLayer layer];
        _brokenLineLayer.contentsScale = [[UIScreen mainScreen] scale];
        _brokenLineLayer.lineWidth = 1;
        _brokenLineLayer.fillColor = [UIColor whiteColor].CGColor;
        _brokenLineLayer.strokeEnd = 0;
    }
    return _brokenLineLayer;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImage *image = [[UIImage imageNamed:self.item.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        CGFloat scale = image.size.width / (self.item.imageRadius * 0.75 * 2);
        
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.size = CGSizeMake(self.item.imageRadius * 2, self.item.imageRadius * 2);
        _imageView.contentScaleFactor = _imageView.contentScaleFactor * scale;
        _imageView.contentMode = UIViewContentModeCenter;
        _imageView.tintColor = [UIColor ssj_colorWithHex:self.item.borderColorValue];
        if (self.item.imageBorderShowed) {
            _imageView.layer.borderColor = [UIColor ssj_colorWithHex:self.item.borderColorValue].CGColor;
            _imageView.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
            _imageView.layer.cornerRadius = _imageView.width * 0.5;
        }
        _imageView.transform = CGAffineTransformMakeScale(0, 0);
    }
    return _imageView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.hidden = YES;
        _textLabel.backgroundColor = [UIColor whiteColor];
        _textLabel.font = [UIFont systemFontOfSize:self.item.textSize];
        _textLabel.textColor = [UIColor ssj_colorWithHex:self.item.textColorValue];
        _textLabel.text = self.item.text;
        [_textLabel sizeToFit];
    }
    return _textLabel;
}

@end
