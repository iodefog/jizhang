//
//  SCYMotionEncryptionCircleLayer.h
//  SCYMotionEncryptionDemo
//
//  Created by old lang on 15-3-22.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SCYMotionEncryptionUitlities.h"

@class SCYMotionEncryptionTriangleLayer;

@interface SCYMotionEncryptionCircleLayer : CALayer

/**
 *  半径
 */
@property (nonatomic) CGFloat radius;

/**
 *  存储密码按键图片的字典，键对应SCYMotionEncryptionCircleLayerStatus，例如：
 *  @{@(SCYMotionEncryptionCircleLayerStatusDefault):[UIImage imageNamed:@"defaultImage"],
 *  @(SCYMotionEncryptionCircleLayerStatusCorrect):[UIImage imageNamed:@"correctImage"],
 *  @(SCYMotionEncryptionCircleLayerStatusError):[UIImage imageNamed:@"errorImage"]};
 */
@property (nonatomic, strong) NSDictionary *imageInfo;

/**
 *  当前状态
 */
@property (nonatomic) SCYMotionEncryptionCircleLayerStatus status;

@end
