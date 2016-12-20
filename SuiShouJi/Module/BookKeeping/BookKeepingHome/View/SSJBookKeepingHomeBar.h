//
//  SSJBookKeepingHomeBar.h
//  SuiShouJi
//
//  Created by ricky on 16/10/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJHomeBudgetButton.h"
#import "SSJHomeBarCalenderButton.h"
#import "SSJBookKeepingHomeBooksButton.h"
#import "FLAnimatedImageView.h"

@interface SSJBookKeepingHomeBar : UIView

@property (nonatomic,strong) SSJHomeBudgetButton *budgetButton;

@property (nonatomic,strong) SSJHomeBarCalenderButton *rightBarButton;

@property(nonatomic, strong) SSJBookKeepingHomeBooksButton *leftButton;

// 首页gif图片
@property (nonatomic, strong) FLAnimatedImageView *loadingView;

- (void)updateAfterThemeChange;

@end
