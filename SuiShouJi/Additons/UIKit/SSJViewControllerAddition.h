//
//  SSJViewControllerAddition.h
//  MoneyMore
//
//  Created by old lang on 15-5-21.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIViewController (SSJNavigationStack)

/**
 *  点击返回按钮返回到的控制器，如果backViewController为空，则直接返回到上一级页面
 */
@property (nonatomic, weak) UIViewController *backController;

/**
 *  显示返回按钮，并制定返回按钮的点击事件
 *
 *  @param target 按钮的点击事件的目标
 *  @param selector 按钮的点击事件的调用方法
 */
- (void)ssj_showBackButtonWithTarget:(id)target selector:(SEL)selector;

- (void)ssj_showBackButtonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector;

/**
 *  返回到指定的控制器，即backController
 */
- (void)ssj_backOffAction;

/**
 *  导航栏栈中的下一个控制器
 */
- (__kindof UIViewController *)ssj_nextViewController;

/**
 *  导航栏栈中的上一个控制器
 */
- (__kindof UIViewController *)ssj_previousViewController;

- (__kindof UIViewController *)ssj_previousViewControllerBySubtractingIndex:(NSInteger)index;

- (__kindof UIViewController *)ssj_nextViewControllerByAddingIndex:(NSInteger)index;

@end
