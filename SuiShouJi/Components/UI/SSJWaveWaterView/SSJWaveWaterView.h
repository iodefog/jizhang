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

- (instancetype)initWithRadius:(CGFloat)radius;

- (void)startWave;

- (void)stopWave;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
