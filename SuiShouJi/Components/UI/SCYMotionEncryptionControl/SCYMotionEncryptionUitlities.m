//
//  SCYMotionEncryptionUitlities.m
//  MoneyMore
//
//  Created by old lang on 15-4-22.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SCYMotionEncryptionUitlities.h"
#import <objc/runtime.h>

SCYMotionEncryptionPoints SCYMotionEncryptionPointsMake(CGPoint startPoint, CGPoint endPoint) {
    SCYMotionEncryptionPoints points;
    points.startPoint = startPoint;
    points.endPoint = endPoint;
    return points;
}

const SCYMotionEncryptionLayout SCYMotionEncryptionLayoutZero = {0, 0};

SCYMotionEncryptionLayout SCYMotionEncryptionLayoutMake(NSUInteger numberOfRows, NSUInteger numberOfColumns) {
    SCYMotionEncryptionLayout motionEncryptionLayout;
    motionEncryptionLayout.numberOfRows = numberOfRows;
    motionEncryptionLayout.numberOfColumns = numberOfColumns;
    return motionEncryptionLayout;
}

BOOL SCYMotionEncryptionLayoutEqualToLayout(SCYMotionEncryptionLayout layout1 ,SCYMotionEncryptionLayout layout2) {
    if (layout1.numberOfColumns != layout2.numberOfColumns) {
        return NO;
    }
    if (layout1.numberOfRows != layout2.numberOfRows) {
        return NO;
    }
    return YES;
}

static const void *kStartPointValueKey = &kStartPointValueKey;
static const void *kEndPointValueKey = &kEndPointValueKey;

@implementation NSValue (SCYMotionEncryptionPoints)

+ (instancetype)valueWithSCYMotionEncryptionPoints:(SCYMotionEncryptionPoints)points {
    return [NSValue valueWithBytes:&points objCType:@encode(SCYMotionEncryptionPoints)];
}

- (SCYMotionEncryptionPoints)SCYMotionEncryptionPointsValue {
    SCYMotionEncryptionPoints points;
    [self getValue:&points];
    return points;
}

@end