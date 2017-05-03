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

@property (nonatomic, weak) id<SSJNavigationControllerDelegate> customDelegate;

@end

@interface UIViewController (SSJNavigationController)

@property (nonatomic, getter=ssj_hidesNavigationBarWhenPushed, setter=ssj_setHidesNavigationBarWhenPushed:) BOOL hidesNavigationBarWhenPushed;

@end
