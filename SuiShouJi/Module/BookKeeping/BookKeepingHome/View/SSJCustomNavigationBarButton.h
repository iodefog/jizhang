//
//  SSJCustomNavigationBarView.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJBudgetModel.h"
#import "SSJHomeBudgetButton.h"
#import "SSJHomeBarButton.h"

@interface SSJCustomNavigationBarButton : UIView
@property (nonatomic,strong) SSJBudgetModel *model;
@property (nonatomic,strong) SSJHomeBudgetButton *budgetButton;
@property (nonatomic,strong) SSJHomeBarButton *calenderButton;
@property (nonatomic) long currentDay;

typedef void(^budgetButtonClickBlock)(SSJBudgetModel *model);

@property (nonatomic, copy) budgetButtonClickBlock budgetButtonClickBlock;
@end
