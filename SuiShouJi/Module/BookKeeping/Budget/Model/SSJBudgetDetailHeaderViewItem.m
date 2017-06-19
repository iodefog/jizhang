//
//  SSJBudgetDetailHeaderViewItem.m
//  SuiShouJi
//
//  Created by old lang on 16/9/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetDetailHeaderViewItem.h"
#import "SSJBudgetModel.h"

NSString *const SSJBudgetDetailBillInfoNameKey = @"SSJBudgetDetailBillInfoNameKey";
NSString *const SSJBudgetDetailBillInfoColorKey = @"SSJBudgetDetailBillInfoColorKey";

@implementation SSJBudgetDetailHeaderViewItem

+ (instancetype)itemWithBudgetModel:(SSJBudgetModel *)model billMapping:(NSDictionary *)billMapping {
    SSJBudgetDetailHeaderViewItem *item = [[SSJBudgetDetailHeaderViewItem alloc] init];
    item.isMajor = [model.billIds isEqualToArray:@[SSJAllBillTypeId]];
    
    NSDate *endDate = [NSDate dateWithString:model.endDate formatString:@"yyyy-MM-dd"];
    NSDate *nowDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day];
    item.isHistory = [endDate compare:nowDate] == NSOrderedAscending;
    
    NSString *budgetType = nil;
    switch (model.type) {
        case SSJBudgetPeriodTypeWeek:
            budgetType = @"周";
            break;
            
        case SSJBudgetPeriodTypeMonth:
            budgetType = @"月";
            break;
            
        case SSJBudgetPeriodTypeYear:
            budgetType = @"年";
            break;
    }
    
    if (item.isMajor) {
        item.budgetMoneyTitle = [NSString stringWithFormat:@"本%@预算", budgetType];
    } else {
        item.budgetMoneyTitle = [NSString stringWithFormat:@"%@分类预算", budgetType];
    }
    
    item.budgetMoneyValue = [NSString stringWithFormat:@"¥%.2f", model.budgetMoney];
    
    item.intervalTitle = @"距结算日";
    item.intervalValue = [NSString stringWithFormat:@"%d天", (int)[endDate daysFrom:nowDate]];
    
    item.budgetMoney = model.budgetMoney;
    item.expendMoney = model.payMoney;
    
    if (model.billIds.count > 1) {
        item.progressColorValue = model.payMoney > model.budgetMoney ? @"ff654c" : @"0fceb6";
    } else {
        NSString *bllId = [model.billIds firstObject];
        if (bllId) {
            NSDictionary *billInfo = billMapping[bllId];
            item.progressColorValue = billInfo[SSJBudgetDetailBillInfoColorKey];
        }
    }
    
    item.payment = [NSString stringWithFormat:@"已花：%.2f", model.payMoney];
    
    NSMutableAttributedString *paymentStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"已花：%.2f", model.payMoney]];
    [paymentStr setAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1],
                                NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]} range:NSMakeRange(3, paymentStr.length - 3)];
    item.historyPayment = paymentStr;
    
    NSMutableAttributedString *budgetStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"预算：%.2f", model.budgetMoney]];
    [budgetStr setAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1],
                               NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]} range:NSMakeRange(3, budgetStr.length - 3)];
    item.historyBudget = budgetStr;
    
    double balance = model.budgetMoney - model.payMoney;
    if (balance >= 0) {
        NSUInteger daysInterval = [endDate daysFrom:nowDate];
        NSMutableAttributedString *text = nil;
        NSString *money = [NSString stringWithFormat:@"%.2f", balance / (daysInterval + 1)];
        if (daysInterval == 0) {
            text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"您每天还可花%@元哦", money] attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        } else {
            text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"距结算日前，您每天还可花%@元哦", money] attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        }
        [text setAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]} range:[text.string rangeOfString:money]];
        item.payOrOverrun = text;
    } else {
        NSString *money = [NSString stringWithFormat:@"%.2f", ABS(balance)];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"亲爱的小主，您目前已超支%@元喽", money] attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        [text setAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]} range:[text.string rangeOfString:money]];
        item.payOrOverrun = text;
    }
    
    if (item.isMajor) {
        item.billTypeNames = [NSString stringWithFormat:@"%@预算消费明细", budgetType];
    } else {
        NSMutableArray *billNames = [NSMutableArray array];
        for (NSString *billId in model.billIds) {
            NSDictionary *billInfo = billMapping[billId];
            if (billInfo[SSJBudgetDetailBillInfoNameKey]) {
                [billNames addObject:billInfo[SSJBudgetDetailBillInfoNameKey]];
            }
            if (billNames.count == 4) {
                break;
            }
        }
        
        item.billTypeNames = [NSString stringWithFormat:@"预算分类：%@", [billNames componentsJoinedByString:@"、"]];
        
        if (model.billIds.count > 4) {
            item.billTypeNames = [NSString stringWithFormat:@"%@等", item.billTypeNames];
        }
    }
    
    return item;
}

@end
