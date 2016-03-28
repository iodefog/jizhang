//
//  SCYMotionEncryptionCircleLayer.m
//  SCYMotionEncryptionDemo
//
//  Created by old lang on 15-3-22.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCYMotionEncryptionCircleLayer.h"
//#import "SCYMotionEncryptionTriangleLayer.h"

////  默认状态颜色
//#define NORMAL_COLOR RGBCOLOR(171, 147, 118)
////  选中状态颜色
//#define SELECT_COLOR RGBCOLOR(248, 130, 9)
////  错误状态颜色
//#define RED_COLOR RGBCOLOR(241, 80, 79)
//
//static NSString *const kDefaultImageKey = @"kDefaultImageKey";
//static NSString *const kCorrectImageKey = @"kCorrectImageKey";
//static NSString *const kErrorImageKey = @"kErrorImageKey";

static const CGFloat kDefaultRadius = 30.0;


@interface SCYMotionEncryptionCircleLayer ()

@property (nonatomic, strong) UIImage *defaultImage;

@property (nonatomic, strong) UIImage *correctImage;

@property (nonatomic, strong) UIImage *errorImage;

@end

@implementation SCYMotionEncryptionCircleLayer

- (instancetype)init {
    if (self = [super init]) {
        self.radius = kDefaultRadius;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.drawsAsynchronously = YES;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    if (!CGRectIsEmpty(frame)) {
        _radius = MIN(frame.size.width, frame.size.height);
        [super setFrame:CGRectMake(frame.origin.x, frame.origin.y, _radius, _radius)];
        return;
    }
    [super setFrame:frame];
}

- (void)setRadius:(CGFloat)radius {
    if (_radius != radius) {
        _radius = radius;
        [super setFrame:CGRectMake(self.left, self.top, radius * 2, radius * 2)];
    }
}

- (void)setImageInfo:(NSDictionary *)imageInfo {
    _defaultImage = imageInfo[@(SCYMotionEncryptionCircleLayerStatusDefault)];
    _correctImage = imageInfo[@(SCYMotionEncryptionCircleLayerStatusCorrect)];
    _errorImage = imageInfo[@(SCYMotionEncryptionCircleLayerStatusError)];
    [self updateStatus];
}

- (void)setStatus:(SCYMotionEncryptionCircleLayerStatus)status {
    _status = status;
    [self updateStatus];
}

- (void)updateStatus {
    switch (_status) {
        case SCYMotionEncryptionCircleLayerStatusDefault:
            self.contents = (id)_defaultImage.CGImage;
            break;
            
        case SCYMotionEncryptionCircleLayerStatusCorrect:
            self.contents = (id)_correctImage.CGImage;
            break;
            
        case SCYMotionEncryptionCircleLayerStatusError:
            self.contents = (id)_errorImage.CGImage;
            break;
    }
}

@end
