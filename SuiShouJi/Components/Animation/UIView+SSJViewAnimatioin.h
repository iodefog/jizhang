//
//  UIView+SSJViewAnimatioin.h
//  SuiShouJi
//
//  Created by old lang on 16/4/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SSJViewAnimatioin)

- (void)popupInView:(UIView *)view completion:(void (^)())completion;

- (void)dismiss:(void (^)())completion;

@end
