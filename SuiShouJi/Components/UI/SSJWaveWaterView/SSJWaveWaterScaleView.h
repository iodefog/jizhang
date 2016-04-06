//
//  SSJWaveWaterScaleView.h
//  SSJWaveWaterDemo
//
//  Created by old lang on 16/3/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJWaveWaterScaleView : UIView

// 波纹振幅，默认是1
@property (nonatomic) CGFloat waveAmplitude;

// 波纹速度，默认是1
@property (nonatomic) CGFloat waveSpeed;

// 波纹周期，默认是1
@property (nonatomic) CGFloat waveCycle;

// 波纹上升或下降速度，默认是1
@property (nonatomic) CGFloat waveGrowth;

@property (nonatomic) CGFloat fullWaveAmplitude;

@property (nonatomic) CGFloat fullWaveSpeed;

@property (nonatomic) CGFloat fullWaveCycle;

@property (nonatomic) CGFloat percent;

@property (nonatomic, copy) NSString *topTitle;

@property (nonatomic, copy) NSString *bottomTitle;

- (instancetype)initWithRadius:(CGFloat)radius;

- (void)stopWave;

@end
