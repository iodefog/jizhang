//
//  SSJBudgetProgressView.h
//  SuiShouJi
//
//  Created by old lang on 16/9/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJBudgetProgressView : UIView

@property (nonatomic) CGFloat budgetMoney;

@property (nonatomic) CGFloat expendMoney;

@property (nonatomic, strong) UIColor *progressColor;

@property (nonatomic, strong) UIColor *overrunProgressColor;

@end
