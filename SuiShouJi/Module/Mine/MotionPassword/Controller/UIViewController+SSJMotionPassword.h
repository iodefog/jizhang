//
//  UIViewController+SSJMotionPassword.h
//  SuiShouJi
//
//  Created by old lang on 16/8/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (SSJMotionPassword)

+ (void)verifyMotionPasswordIfNeeded:(void (^)(BOOL isVerified))finish animated:(BOOL)animated;

- (void)ssj_remindUserToSetMotionPasswordIfNeeded;

@end
