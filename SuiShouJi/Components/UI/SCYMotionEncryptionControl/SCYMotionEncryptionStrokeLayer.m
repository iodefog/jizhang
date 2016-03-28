//
//  SCYMotionEncryptionStrokeLayer.m
//  SCYMotionEncryptionDemo
//
//  Created by old lang on 15-3-22.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//


#import "SCYMotionEncryptionStrokeLayer.h"
#import <UIKit/UIKit.h>

//  线宽度
static const CGFloat kStrokeLineWidth = 2.0;

//  线颜色
#define STROKE_LINE_DEFAULT_COLOR RGBCOLOR(248, 130, 9)

#define STROKE_LINE_ERROR_COLOR RGBCOLOR(241, 80, 79)

@interface SCYMotionEncryptionStrokeLayer ()

@property (nonatomic, strong) UIColor *defaultColor;

@property (nonatomic, strong) UIColor *correctColor;

@property (nonatomic, strong) UIColor *errorColor;

@end

@implementation SCYMotionEncryptionStrokeLayer

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor].CGColor;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.drawsAsynchronously = YES;
        self.defaultColor = STROKE_LINE_DEFAULT_COLOR;
        self.correctColor = STROKE_LINE_DEFAULT_COLOR;
        self.errorColor = STROKE_LINE_ERROR_COLOR;
    }
    return self;
    
}

- (void)setStrokeColorInfo:(NSDictionary *)strokeColorInfo {
    self.defaultColor = strokeColorInfo[@(SCYMotionEncryptionCircleLayerStatusDefault)];
    self.correctColor = strokeColorInfo[@(SCYMotionEncryptionCircleLayerStatusCorrect)];
    self.errorColor = strokeColorInfo[@(SCYMotionEncryptionCircleLayerStatusError)];
}

- (void)drawInContext:(CGContextRef)ctx {
    if (_pointsArray.count <= 0) {
        return;
    }
    
    @autoreleasepool {
        CGContextSetLineWidth(ctx, kStrokeLineWidth);
        CGContextSetLineJoin(ctx, kCGLineJoinRound);
        switch (_status) {
            case SCYMotionEncryptionCircleLayerStatusDefault: {
                CGContextSetStrokeColorWithColor(ctx, self.defaultColor.CGColor);
            }   break;
                
            case SCYMotionEncryptionCircleLayerStatusCorrect: {
                CGContextSetStrokeColorWithColor(ctx, self.correctColor.CGColor);
            }   break;
                
            case SCYMotionEncryptionCircleLayerStatusError: {
                CGContextSetStrokeColorWithColor(ctx, self.errorColor.CGColor);
            }   break;
        }
        
        [_pointsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSValue *pointValue = obj;
            SCYMotionEncryptionPoints point = [pointValue SCYMotionEncryptionPointsValue];
            CGPoint startPoint = point.startPoint;
            CGPoint endPoint = point.endPoint;
            CGContextMoveToPoint(ctx, startPoint.x, startPoint.y);
            CGContextAddLineToPoint(ctx, endPoint.x, endPoint.y);
        }];
        CGContextDrawPath(ctx, kCGPathStroke);
    }
}

@end
