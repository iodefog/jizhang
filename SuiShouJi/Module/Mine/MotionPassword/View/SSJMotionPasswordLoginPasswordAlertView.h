//
//  SSJMotionPasswordLoginPasswordAlertView.h
//  SuiShouJi
//
//  Created by old lang on 16/5/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSJMotionPasswordLoginPasswordAlertView : UIView

@property (readonly, nonatomic, strong) UIButton *sureButton;

@property (readonly, nonatomic, strong) UITextField *passwordInput;

+ (instancetype)alertView;

- (void)shake;

- (void)show;

- (void)dismiss:(void (^ __nullable)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END
