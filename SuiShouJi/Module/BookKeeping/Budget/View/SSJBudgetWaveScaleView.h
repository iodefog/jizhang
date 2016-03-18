//
//  SSJWaveLoadingIndicator.h
//  WateTest
//
//  Created by old lang on 16/2/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJBudgetWaveScaleView : UIView

/**
 *  波纹比例，小于1时显示动态绿色波纹，等于1时显示满格绿色波纹，大于1时显示满格红色波纹
 */
@property (nonatomic) CGFloat scale;

/**
 *  顶部标题
 */
@property (nonatomic, copy) NSString *title;

/**
 *  底部标题
 */
@property (nonatomic, copy) NSString *subtitlle;

/**
 *  边框宽度
 */
@property (nonatomic) CGFloat borderWidth;

/**
 *  边框颜色
 */
@property (nonatomic, strong) UIColor *borderColor;

/**
 *  波动速度
 */
@property (nonatomic) CGFloat waveAmplitude;

@end
