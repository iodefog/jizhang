//
//  SSJBudgetBillTypeSelectionViewController.h
//  SuiShouJi
//
//  Created by old lang on 16/9/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

@class SSJBudgetModel;

@interface SSJBudgetBillTypeSelectionViewController : SSJBaseViewController

/**
 选中的类别列表
 注意：只有从编辑／新建预算页面进入需要传值
 */
@property (nonatomic, strong) NSArray <NSString *>*selectedTypeList;

/**
 是否编辑
 注意：只有从编辑／新建预算页面进入需要传值
 */
@property (nonatomic) BOOL edited;

@end
