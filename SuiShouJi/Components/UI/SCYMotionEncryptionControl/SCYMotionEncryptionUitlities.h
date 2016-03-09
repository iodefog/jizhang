//
//  SCYMotionEncryptionUitlities.h
//  MoneyMore
//
//  Created by old lang on 15-4-22.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    CGPoint startPoint;
    CGPoint endPoint;
} SCYMotionEncryptionPoints;

SCYMotionEncryptionPoints SCYMotionEncryptionPointsMake(CGPoint startPoint, CGPoint endPoint);

typedef struct {
    NSUInteger numberOfRows;
    NSUInteger numberOfColumns;
} SCYMotionEncryptionLayout;

extern const SCYMotionEncryptionLayout SCYMotionEncryptionLayoutZero;

SCYMotionEncryptionLayout SCYMotionEncryptionLayoutMake(NSUInteger numberOfRows, NSUInteger numberOfColumns);

BOOL SCYMotionEncryptionLayoutEqualToLayout(SCYMotionEncryptionLayout layout1 ,SCYMotionEncryptionLayout layout2);

typedef NS_ENUM(NSUInteger, SCYMotionEncryptionCircleLayerStatus) {
    SCYMotionEncryptionCircleLayerStatusDefault,    //  默认
    SCYMotionEncryptionCircleLayerStatusCorrect,    //  正确
    SCYMotionEncryptionCircleLayerStatusError,      //  错误
};



@interface NSValue (SCYMotionEncryptionPoints)

+ (instancetype)valueWithSCYMotionEncryptionPoints:(SCYMotionEncryptionPoints)points;

- (SCYMotionEncryptionPoints)SCYMotionEncryptionPointsValue;

@end

