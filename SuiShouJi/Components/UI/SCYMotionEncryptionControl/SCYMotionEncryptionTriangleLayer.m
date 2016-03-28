//
//  SCYMotionEncryptionTriangleLayer.m
//  MoneyMore
//
//  Created by old lang on 15-4-22.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SCYMotionEncryptionTriangleLayer.h"

@implementation SCYMotionEncryptionTriangleLayer

//- (instancetype)init {
//    if (self = [super init]) {
//        self.borderColor = [UIColor yellowColor].CGColor;
//        self.borderWidth = 0.5;
//    }
//    return self;
//}

- (void)setSideLength:(CGFloat)sideLength {
    if (_sideLength != sideLength) {
        _sideLength = sideLength;
        self.width = sideLength;
        self.height = sin(M_PI / 3) * sideLength;
        [self p_drawTriangle];
    }
}

- (void)p_drawTriangle {
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 0.5;
    [path moveToPoint:CGPointMake(self.width * 0.5, 0)];
    [path addLineToPoint:CGPointMake(0, self.height)];
    [path addLineToPoint:CGPointMake(self.width, self.height)];
    self.path = path.CGPath;
}

@end
