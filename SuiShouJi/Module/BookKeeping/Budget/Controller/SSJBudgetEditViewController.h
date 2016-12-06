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

/**
 是否编辑，反之新建
 */
@property (nonatomic) BOOL isEdit;

/**
 预算配置模型；如果不传则新内部创建默认预算模型
 */
@property (nonatomic, copy) SSJBudgetModel *model;

/**
 新建预算成功后调用的回调方法，budgetId：新建预算id
 */
@property (nonatomic, copy) void (^addNewBudgetBlock)(NSString *budgetId);

@end
