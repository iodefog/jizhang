//
//  SSJBudgetDetailPeriodSwitchControl.h
//  SuiShouJi
//
//  Created by old lang on 16/3/11.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

//  预算周期切换控件

#import <UIKit/UIKit.h>

@interface SSJBudgetDetailPeriodSwitchControl : UIControl

@property (nonatomic, strong) NSArray *titles;

@property (nonatomic) NSUInteger selectedIndex;

@property (nonatomic) CGFloat titleSize;

- (void)updateAppearance;

@end
