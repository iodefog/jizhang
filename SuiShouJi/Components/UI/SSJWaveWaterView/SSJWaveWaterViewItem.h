//
//  SSJWaveWaterViewItem.h
//  SSJWaveWaterDemo
//
//  Created by old lang on 16/3/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJWaveWaterViewItem : NSObject

// 波纹振幅，默认是1
@property (nonatomic) CGFloat waveAmplitude;

// 波纹速度，默认是1
@property (nonatomic) CGFloat waveSpeed;

// 波纹周期，默认是1
@property (nonatomic) CGFloat waveCycle;

// 波纹上升或下降速度，默认是1
@property (nonatomic) CGFloat waveGrowth;

//// 波纹上升或下降减速速率，0～1，默认0
//@property (nonatomic) CGFloat waveDeceleration;

// 百分比，0～1， 默认是0
@property (nonatomic) CGFloat wavePercent;

// 波纹X轴启始位移，默认0
@property (nonatomic) CGFloat waveOffset;

// 波纹颜色
@property (nonatomic, strong) UIColor *waveColor;

+ (instancetype)item;

+ (instancetype)itemWithAmplitude:(CGFloat)amplitude
                            speed:(CGFloat)speed
                            cycle:(CGFloat)cycle
                           growth:(CGFloat)growth
                          percent:(CGFloat)percent
                       waveOffset:(CGFloat)waveOffset
                            color:(UIColor *)color;

@end
