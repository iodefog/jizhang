//
//  SSJBudgetEditViewController.h
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

//  预算编辑、新建

#import "SSJBaseViewController.h"

@class SSJBudgetModel;

@interface SSJBudgetEditViewController : SSJBaseViewController

//  预算配置模型；新建不穿；编辑必传
@property (nonatomic, copy) SSJBudgetModel *model;

@end
