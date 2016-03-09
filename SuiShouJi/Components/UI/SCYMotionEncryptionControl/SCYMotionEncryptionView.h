//
//  SCYMotionEncryptionView.h
//  SCYMotionEncryptionDemo
//
//  Created by old lang on 15-3-22.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCYMotionEncryptionUitlities.h"

NS_ASSUME_NONNULL_BEGIN

@class SCYMotionEncryptionView;

@protocol SCYMotionEncryptionViewDelegate <NSObject>

@optional
/**
 *  已经选中密码按键的回调（手指未松开，每新选中一个按键触发）
 *
 *  @param motionView 手势密码视图
 *  @param keypads  选中的密码按键
 */
- (void)motionView:(SCYMotionEncryptionView *)motionView didSelectKeypads:(NSArray *)keypads;

/**
 *  完成选中密码按键的回调（手指松开）
 *
 *  @param motionView  手势密码视图
 *  @param keypads  选中的密码按键
 *
 *  @return 返回选中的按键状态
 */
- (SCYMotionEncryptionCircleLayerStatus)motionView:(SCYMotionEncryptionView *)motionView didFinishSelectKeypads:(NSArray *)keypads;

@end

@interface SCYMotionEncryptionView : UIView

@property (nonatomic, weak) id<SCYMotionEncryptionViewDelegate> delegate;

/**
 *  是否显示连接线，默认为NO
 */
@property (nonatomic) BOOL showStroke;

/**
 *  密码按键的触发半径
 */
@property (nonatomic) CGFloat circleRadius;

/**
 *  存储密码按键图片的字典，键对应SCYMotionEncryptionCircleLayerStatus，例如：
 *  @{@(SCYMotionEncryptionCircleLayerStatusDefault):[UIImage imageNamed:@"defaultImage"],
 *    @(SCYMotionEncryptionCircleLayerStatusCorrect):[UIImage imageNamed:@"correctImage"],
 *    @(SCYMotionEncryptionCircleLayerStatusError):[UIImage imageNamed:@"errorImage"]};
 */
@property (nonatomic, strong) NSDictionary<NSNumber *, UIImage *> *imageInfo;

/**
 *  显示内容的内凹，默认是UIEdgeInsetsZero
 */
@property (nonatomic) UIEdgeInsets contentInsets;

/**
 *  密码按键的布局方式，默认是3x3
 */
@property (nonatomic) SCYMotionEncryptionLayout layout;

/**
 *  获取所有的密码按键
 */
- (NSArray *)allKeypads;

/**
 *  设置相应密码按键的状态
 *
 *  @param keypads 密码按键
 *  @param status  状态
 */
- (void)setKeypads:(nullable NSArray *)keypads toStatus:(SCYMotionEncryptionCircleLayerStatus)status;

@end

NS_ASSUME_NONNULL_END
