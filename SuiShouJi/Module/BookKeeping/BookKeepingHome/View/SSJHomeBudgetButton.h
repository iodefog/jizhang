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
@property (nonatomic,strong) SSJBudgetModel *model;

@property (nonatomic,strong) UIButton *button;

typedef void(^budgetButtonClickBlock)(SSJBudgetModel *model);

@property (nonatomic, copy) budgetButtonClickBlock budgetButtonClickBlock;

@property(nonatomic) double currentBalance;
@end
