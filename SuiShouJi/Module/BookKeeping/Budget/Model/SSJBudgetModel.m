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
    model.booksId = self.booksId;
    model.billIds = self.billIds;
    model.type = self.type;
    model.budgetMoney = self.budgetMoney;
    model.remindMoney = self.remindMoney;
    model.payMoney = self.payMoney;
    model.beginDate = self.beginDate;
    model.endDate = self.endDate;
    model.isAutoContinued = self.isAutoContinued;
    model.isRemind = self.isRemind;
    model.isAlreadyReminded = self.isAlreadyReminded;
    model.isLastDay = self.isLastDay;
    return model;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@", @{@"ID":(_ID ?: @""),
                                               @"userId":(_userId ?: @""),
                                               @"booksId":(_booksId ?: @""),
                                               @"billIds":(_billIds ?: [NSNull null]),
                                               @"type":@(_type),
                                               @"budgetMoney":@(_budgetMoney),
                                               @"remindMoney":@(_remindMoney),
                                               @"payMoney":@(_payMoney),
                                               @"beginDate":(_beginDate ?: @""),
                                               @"endDate":(_endDate ?: @""),
                                               @"isAutoContinued":@(_isAutoContinued),
                                               @"isRemind":@(_isRemind),
                                               @"isAlreadyReminded":@(_isAlreadyReminded),
                                               @"isLastDay":@(_isLastDay)}];
}

@end
