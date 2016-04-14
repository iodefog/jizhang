//
//  UIView+SSJViewAnimatioin.h
//  SuiShouJi
//
//  Created by old lang on 16/4/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (SSJViewAnimatioin)

- (void)popupInView:(UIView *)view completion:(void (^ __nullable)(BOOL finished))completion;

- (void)dismiss:(void (^ __nullable)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END