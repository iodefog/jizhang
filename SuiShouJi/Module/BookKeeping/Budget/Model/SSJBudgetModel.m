//
//  SSJBudgetModel.m
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetModel.h"

@implementation SSJBudgetModel

- (id)copyWithZone:(nullable NSZone *)zone {
    SSJBudgetModel *model = [[SSJBudgetModel alloc] init];
    model.ID = self.ID;
    model.userId = self.userId;
    model.billIds = self.billIds;
    model.type = self.type;
    model.budgetMoney = self.budgetMoney;
    model.remindMoney = self.remindMoney;
    model.payMoney = self.payMoney;
    model.beginDate = self.beginDate;
    model.endDate = self.endDate;
    model.isAutoContinued = self.isAutoContinued;
    model.isRemind = self.isRemind;
    return model;
}

@end
