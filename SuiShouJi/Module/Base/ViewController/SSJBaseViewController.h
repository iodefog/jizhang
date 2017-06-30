//
//  SSJBaseViewController.h
//  MoneyMore
//
//  Created by old lang on 15-3-22.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJBaseNetworkService.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSJBaseViewController : UIViewController <SSJBaseNetworkServiceDelegate>

/**
 *  背景图片
 */
@property (nonatomic, strong, readonly) UIImageView *backgroundView;

/**
 *  统计标题
 */
@property (nonatomic, copy, nullable) NSString *statisticsTitle;

/**
 *  点击是否隐藏键盘，默认为NO
 */
@property (nonatomic) BOOL hideKeyboradWhenTouch;

/**
 *  数据库是否完成初始化
 */
@property (nonatomic, readonly) BOOL isDatabaseInitFinished;

/**
 *  是否应用主题，默认为YE；
 *  注意：要在初始化方法中设置
 */
@property (nonatomic) BOOL appliesTheme;

/**
 是否显示导航栏底部的线，默认YES
 */
@property (nonatomic) BOOL showNavigationBarBaseLine;

/**
 导航栏底部线的颜色，如果不传值就根据appliesTheme采用对应的颜色，appliesTheme为YES就用当前主题的颜色，appliesTheme为NO就用默认主题的颜色
 */
@property (nonatomic, strong, nullable) UIColor *navigationBarBaseLineColor;

/**
 导航栏标题颜色
 */
@property (nonatomic, strong, nullable) UIColor *navigationBarTitleColor;

/**
 导航栏按钮颜色
 */
@property (nonatomic, strong, nullable) UIColor *navigationBarTintColor;

/**
 导航栏背景颜色
 */
@property (nonatomic, strong, nullable) UIColor *navigationBarBackgroundColor;

/**
 *  导航栏返回按钮点击事件
 */
- (void)goBackAction;

/**
 *  同步成功后重载数据，子类根据情况重写，父类中没有做任何处理
 */
- (void)reloadDataAfterSync;

/**
 *  数据库初始化完成后重载数据，子类根据情况重写，父类中没有做任何处理
 */
- (void)reloadDataAfterInitDatabase;

/**
 *  切换主题后调用的方法，子类根据情况重写，必须调用父类方法
 */
- (void)updateAppearanceAfterThemeChanged;

@end

NS_ASSUME_NONNULL_END
