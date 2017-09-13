//
//  SSJRecycleRecoverAlertView.h
//  SuiShouJi
//
//  Created by old lang on 2017/9/12.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJRecycleRecoverAlertView : UIView

@property (nonatomic, copy) void(^confirmBlock)();

+ (instancetype)alertView;

- (void)show;

- (void)dismiss;

- (void)updateAppearanceAccordingToTheme;

@end
