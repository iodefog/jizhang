//
//  SCYMotionEncryptionStrokeLayer.h
//  SCYMotionEncryptionDemo
//
//  Created by old lang on 15-3-22.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SCYMotionEncryptionCircleLayer.h"
#import "SCYMotionEncryptionUitlities.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCYMotionEncryptionStrokeLayer : CALayer

@property (nonatomic, strong) NSDictionary<NSNumber *, UIColor *> *strokeColorInfo;

@property (nullable, nonatomic, strong) NSMutableArray *pointsArray;

@property (nonatomic, assign) SCYMotionEncryptionCircleLayerStatus status;

@end

NS_ASSUME_NONNULL_END