//
//  SSJNavigationController.h
//  SuiShouJi
//
//  Created by old lang on 17/4/7.
//  Copyright © 2017年 MZL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SSJNavigationControllerDelegate <UINavigationControllerDelegate>

@end

@interface SSJNavigationController : UINavigationController

/**
 导航栏控制器的代理，不要设置原有的delegate，用此属性代替；
 */
@property (nonatomic, weak) id<SSJNavigationControllerDelegate> customDelegate;

@end

@interface UIViewController (SSJNavigationController)

/**
 是否隐藏导航栏；只有设置SSJNavigationController的子控制器有效，默认NO
 */
@property (nonatomic, getter=ssj_hidesNavigationBarWhenPushed, setter=ssj_setHidesNavigationBarWhenPushed:) BOOL hidesNavigationBarWhenPushed;

@end
