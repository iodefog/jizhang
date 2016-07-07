//
//  SSJBaseViewController.h
//  MoneyMore
//
//  Created by old lang on 15-3-22.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJBaseNetworkService.h"

@interface SSJBaseViewController : UIViewController <SSJBaseNetworkServiceDelegate>

/**
 *  统计标题
 */
@property (nonatomic, copy) NSString *statisticsTitle;

/**
 *  点击是否隐藏键盘，默认为NO
 */
@property (nonatomic) BOOL hideKeyboradWhenTouch;

/**
 *  数据库是否完成初始化
 */
@property (nonatomic, readonly) BOOL isDatabaseInitFinished;

/**
 *  是否应用主题，默认为YES
 */
@property (nonatomic) BOOL appliesTheme;

/**
 *  导航栏返回按钮点击事件，如果子类重写此方法，需要调用父类方法
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
