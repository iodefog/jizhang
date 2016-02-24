//
//  SSJBorderButton.h
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJBorderButton : UIView

/**
 *  设置标题字体大小
 *
 *  @param size 标题字体大小
 */
- (void)setFontSize:(CGFloat)size;

/**
 *  设置标题
 *
 *  @param title 标题
 */
- (void)setTitle:(NSString *)title;

/**
 *  设置边框线颜色、普通状态标题颜色、高亮状态背景色
 *
 *  @param color 边框线颜色、普通状态标题颜色、高亮状态背景色
 */
- (void)setColor:(UIColor *)color;

/**
 *  添加点击执行的方法
 *
 *  @param target 执行方法的目标
 *  @param action 执行的方法
 */
- (void)addTarget:(id)target action:(SEL)action;

@end
