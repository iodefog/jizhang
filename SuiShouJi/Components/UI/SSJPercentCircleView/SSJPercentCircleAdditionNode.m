//
//  SSJReportFormsPercentCircleAdditionView.m
//  SuiShouJi
//
//  Created by old lang on 16/1/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJPercentCircleAdditionNode.h"

@implementation SSJPercentCircleAdditionNodeItem

@end


static NSString *const kAnimationKey = @"kAnimationKey";

@interface SSJPercentCircleAdditionNode () <CAAnimationDelegate>

@property (nonatomic, readwrite, strong) SSJPercentCircleAdditionNodeItem *item;

@property (nonatomic, strong) CAShapeLayer *brokenLineLayer;

@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, copy) void (^completion)(void);

@end

@implementation SSJPercentCircleAdditionNode

- (instancetype)initWithItem:(SSJPercentCircleAdditionNodeItem *)item {
    if (self = [super initWithFrame:CGRectZero]) {
        self.item = item;
        
        self.brokenLineLayer.strokeColor = self.item.borderColor.CGColor;
        [self.layer addSublayer:self.brokenLineLayer];
        [self addSubview:self.textLabel];
    }
    return self;
}

- (void)layoutSubviews {
    switch (self.item.range) {
        case SSJRadianRangeTop:
            self.textLabel.centerX = self.item.endPoint.x;
            self.textLabel.bottom = self.item.endPoint.y;
            break;
            
        case SSJRadianRangeRight:
            self.textLabel.left = self.item.endPoint.x;
            self.textLabel.centerY = self.item.endPoint.y;
            break;
            
        case SSJRadianRangeBottom:
            self.textLabel.centerX = self.item.endPoint.x;
            self.textLabel.top = self.item.endPoint.y;
            break;
            
        case SSJRadianRangeLeft:
            self.textLabel.right = self.item.endPoint.x;
            self.textLabel.centerY = self.item.endPoint.y;
            break;
    }
}

- (void)beginDrawWithCompletion:(void (^)(void))completion {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:self.item.startPoint];
    [path addLineToPoint:self.item.breakPoint];
    [path addLineToPoint:self.item.endPoint];
    
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
        
        [self showTextLabel];
    }
}

#pragma mark - Private
- (void)showTextLabel {
    [UIView transitionWithView:_textLabel duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        _textLabel.hidden = NO;
    } completion:^(BOOL finished) {
        if (self.completion) {
            self.completion();
        }
    }];
}

#pragma mark - Getter
- (CAShapeLayer *)brokenLineLayer {
    if (!_brokenLineLayer) {
        _brokenLineLayer = [CAShapeLayer layer];
        _brokenLineLayer.contentsScale = [[UIScreen mainScreen] scale];
        _brokenLineLayer.lineWidth = 1 / [[UIScreen mainScreen] scale];
        _brokenLineLayer.fillColor = [UIColor clearColor].CGColor;
        _brokenLineLayer.strokeEnd = 0;
    }
    return _brokenLineLayer;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.hidden = YES;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.font = self.item.font;
        _textLabel.textColor = self.item.textColor;
        _textLabel.text = self.item.text;
        [_textLabel sizeToFit];
    }
    return _textLabel;
}

@end

#import <objc/runtime.h>

static const void *kNodeTextSizeKey = &kNodeTextSizeKey;

@implementation SSJPercentCircleAdditionNodeItem (Composer)

- (void)setTextSize:(CGSize)textSize {
    objc_setAssociatedObject(self, kNodeTextSizeKey, [NSValue valueWithCGSize:textSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGSize)textSize {
    return [objc_getAssociatedObject(self, kNodeTextSizeKey) CGSizeValue];
}

- (CGFloat)textTop {
    return self.endPoint.y - self.textSize.height * 0.5;
}

- (CGFloat)textBottom {
    return self.endPoint.y + self.textSize.height * 0.5;
}

@end
