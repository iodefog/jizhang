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
 *  设置比例
 */
- (void)setScale:(CGFloat)scale;

/**
 *  设置
 *
 *  @param success  同步成功回调
 *  @param failure  同步失败回调
 */
- (void)setTopTitle:(NSString *)title;

/**
 *  开始数据同步
 *
 *  @param success  同步成功回调
 *  @param failure  同步失败回调
 */
- (void)setBottomTitle:(NSString *)title;

@end
