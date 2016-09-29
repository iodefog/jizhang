//
//  SSJBudgetListSecondaryCellItem.m
//  SuiShouJi
//
//  Created by old lang on 16/9/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetListSecondaryCellItem.h"
#import "SSJBudgetModel.h"

@implementation SSJBudgetListSecondaryCellItem

+ (instancetype)cellItemWithBudgetModel:(SSJBudgetModel *)model {
    SSJBudgetListSecondaryCellItem *item = [[SSJBudgetListSecondaryCellItem alloc] init];
    switch (model.type) {
        case SSJBudgetPeriodTypeWeek:
            item.title = @"周分类预算";
            break;
            
        case SSJBudgetPeriodTypeMonth:
            item.title = @"月分类预算";
            break;
            
        case SSJBudgetPeriodTypeYear:
            item.title = @"年分类预算";
            break;
    }
    
    return item;
}

@end
