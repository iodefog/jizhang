//
//  SSJMotionPasswordViewController.h
//  SuiShouJi
//
//  Created by old lang on 16/3/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

typedef NS_ENUM(NSUInteger, SSJMotionPasswordViewControllerType) {
    SSJMotionPasswordViewControllerTypeSetting,
    SSJMotionPasswordViewControllerTypeVerification
};

@interface SSJMotionPasswordViewController : SSJBaseViewController

@property (nonatomic) SSJMotionPasswordViewControllerType type;

@end
