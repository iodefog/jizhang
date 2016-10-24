//
//  SSJBudgetWaveWaterView.h
//  SuiShouJi
//
//  Created by old lang on 16/3/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJBudgetWaveWaterView : UIView

// percent<1的情况下，波纹振幅，默认是1
@property (nonatomic) CGFloat waveAmplitude;

// percent<1的情况下，波纹速度，默认是1
@property (nonatomic) CGFloat waveSpeed;

// percent<1的情况下，波纹周期，默认是1
@property (nonatomic) CGFloat waveCycle;

// percent<1的情况下，波纹上升或下降速度，默认是1
@property (nonatomic) CGFloat waveGrowth;

// percent<1的情况下，两条波纹之间的位移
@property (nonatomic) CGFloat waveOffset;

// 内部边框宽度，default 1
@property (nonatomic) CGFloat innerBorderWidth;

// 外部边框宽度，default 1
@property (nonatomic) CGFloat outerBorderWidth;

// 预算金额
@property (nonatomic) double budgetMoney;

// 支出金额
@property (nonatomic) double expendMoney;

- (instancetype)initWithRadius:(CGFloat)radius;

// 停止波纹动画，必须主动跳用，否则波纹视图不能被释放
- (void)stopWave;

@end
