//
//  SSJFinancingHomeHeader.h
//  SuiShouJi
//
//  Created by ricky on 16/5/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJFinancingHomeHeader : UIView

@property(nonatomic, strong) NSString *balanceAmount;

@property(nonatomic, strong) UIButton *transferButton;

@property(nonatomic, strong) UIButton *hiddenButton;

@property (nonatomic, copy) void(^hiddenButtonClickBlock)();

- (void)updateAfterThemeChange;

@end
