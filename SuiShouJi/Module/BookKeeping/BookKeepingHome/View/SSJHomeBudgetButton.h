//
//  SSJHomeBudgetButton.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJBudgetModel.h"

@interface SSJHomeBudgetButton : UIView


@property (nonatomic,strong) id model;

@property (nonatomic,strong) UIButton *button;

typedef void(^budgetButtonClickBlock)(id model);

@property (nonatomic, copy) budgetButtonClickBlock budgetButtonClickBlock;

@property(nonatomic) double currentBalance;

@property (nonatomic) long currentMonth;

@property(nonatomic, strong) UIView *seperatorLine;

- (void)updateAfterThemeChange;

@end
