//
//  SSJWaveWaterView.h
//  SSJWaveWaterDemo
//
//  Created by old lang on 16/3/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJWaveWaterViewItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSJWaveWaterView : UIView

// 表示波纹曲线的模型数组
@property (nonatomic, strong) NSArray <SSJWaveWaterViewItem *> *items;

// 边框颜色
@property (nonatomic) CGFloat borderWidth;

// 边框宽度
@property (nonatomic, strong) UIColor *borderColor;

// 顶部标题
@property (nonatomic, copy) NSString *topTitle;

// 底部标题
@property (nonatomic, copy) NSString *bottomTitle;

// 顶部标题字体大小，default 12
@property (nonatomic) CGFloat topTitleFontSize;

// 底部标题字体大小，default 18
@property (nonatomic) CGFloat bottomTitleFontSize;

// 顶部标题字体大小，default white
@property (nonatomic, strong) UIColor *topTitleColor;

// 顶部标题字体大小，default white
@property (nonatomic, strong) UIColor *bottomTitleColor;

// 顶部标题与底部标题的间隙，default 0
@property (nonatomic) CGFloat titleGap;

//
- (instancetype)initWithRadius:(CGFloat)radius;

// 绘制水波纹，没有动画效果
- (void)drawWave;

// 开始水波动画
- (void)startWave;

// 停止水波动画
- (void)stopWave;

// 重置水波动画，水波纹会回到起点，并且停止动画
- (void)reset;

@end

NS_ASSUME_NONNULL_END
