//
//  SSJReportFormsPercentCircleLayer.m
//  SuiShouJi
//
//  Created by old lang on 15/12/30.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJReportFormsPercentCircleLayer.h"

@interface SSJReportFormsPercentCircleLayer ()

@property (nonatomic) BOOL isAnimating;

@end

@implementation SSJReportFormsPercentCircleLayer

- (instancetype)init {
    if (self = [super init]) {
        self.contentsScale = [UIScreen mainScreen].scale;
    }
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"angle"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx {
    
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
//    CGPoint center = CGPointMake(self.width * 0.5, self.height * 0.5);
//    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:self.width * 0.5 startAngle:-M_PI_2 endAngle:self.angle * M_PI * 2 clockwise:YES];
//    [path addArcWithCenter:center radius:(self.width * 0.5 - self.thickness) startAngle:-M_PI_2 endAngle:self.angle * M_PI * 2 clockwise:YES];
//    [path closePath];
    
//    CGPoint center = CGPointMake(self.width * 0.5, self.height * 0.5);
//    CGMutablePathRef path = CGPathCreateMutable();
//    CGPathAddRelativeArc(path, NULL, center.x, center.y, self.width * 0.5, -M_PI_2, self.angle * M_PI * 2);
//    CGPathAddRelativeArc(path, NULL, center.x, center.y, (self.width * 0.5 - self.thickness), -M_PI_2 , self.angle * M_PI * 2);
//    CGPathCloseSubpath(path);
//    
//    
//    self.path = path;
//    CGPathRelease(path);
    
    CAAnimation *arcAnimation = [self animationForKey:@"aa"];
    if (arcAnimation) {
        CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
        CGContextSetStrokeColorWithColor(ctx, self.fillColor.CGColor);
        CGContextAddArc(ctx, self.width * 0.5, self.height * 0.5, self.width * 0.5, -M_PI_2, self.angle, YES);
        
        CGFloat axisY1 = cos(self.angle-M_PI_2) * (self.width * 0.5 - self.thickness);
        CGFloat axisX1 = sin(self.angle-M_PI_2) * (self.width * 0.5 - self.thickness);
        CGContextMoveToPoint(ctx, axisX1+self.width * 0.5, axisY1+self.height * 0.5);
        
        CGContextAddArc(ctx, self.width * 0.5, self.height * 0.5, (self.width * 0.5 - self.thickness), -M_PI_2 + self.angle, -self.angle, YES);
        
        CGFloat axisY2 = -cos(-M_PI_2) * self.width * 0.5;
        CGFloat axisX2 = sin(-M_PI_2) * self.width * 0.5;
        CGContextMoveToPoint(ctx, axisX2, axisY2);
        
//        CGContextClosePath(ctx);
        CGContextStrokePath(ctx);
//        CGContextFillPath(ctx);
    }
    
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.isAnimating = NO;
}

- (void)setAngle:(CGFloat)angle
        animated:(BOOL)animated
        duration:(NSTimeInterval)duration
    finishHandle:(void (^)(void))finishHandle {
    
    self.isAnimating = animated;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"angle"];
    animation.duration = duration;
    animation.delegate = self;
    animation.toValue = @(angle);
    [self addAnimation:animation forKey:@"aa"];
    
    [self setValue:@(angle) forKey:@"angle"];
}


@end
