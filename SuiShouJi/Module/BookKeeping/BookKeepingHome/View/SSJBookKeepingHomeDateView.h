//
//  SSJBookKeepingHomeDateView.h
//  SuiShouJi
//
//  Created by ricky on 16/10/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJBookKeepingHomeDateView : UIView

@property (nonatomic, copy) void(^dismissBlock)();

@property (nonatomic, copy) void(^showBlock)();

@property(nonatomic, strong) NSString *currentDate;

- (void)updateAfterThemeChange;

- (void)show;

- (void)dismiss;

@end
