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
    item.isMajor = [model.billIds isEqualToArray:@[@"all"]];
    
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
        if (model.billIds.count > 1) {
            item.budgetMoneyTitle = [NSString stringWithFormat:@"分类%@预算", budgetType];
        } else {
            NSDictionary *billInfo = billMapping[model.ID];
            item.budgetMoneyTitle = [NSString stringWithFormat:@"%@%@预算", billInfo[SSJBudgetDetailBillInfoNameKey], budgetType];
        }
    }
    
    item.intervalTitle = @"距结算日";
    item.intervalValue = [NSString stringWithFormat:@"%d天", (int)[endDate daysFrom:nowDate]];
    
    item.waveViewPercent = (model.payMoney / model.budgetMoney);
    item.waveViewMoney = model.budgetMoney - model.payMoney;
    
    item.progressViewPercent = (model.payMoney / model.budgetMoney);
    item.progressViewMoney = model.budgetMoney;
    
    if (model.billIds.count > 1) {
        item.progressColorValue = model.payMoney > model.budgetMoney ? @"ff654c" : @"0fceb6";
    } else {
        NSDictionary *billInfo = billMapping[model.ID];
        item.progressColorValue = billInfo[SSJBudgetDetailBillInfoColorKey];
    }
    
    item.payment = [NSString stringWithFormat:@"已花：%.2f", model.payMoney];
    
    NSMutableAttributedString *paymentStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"已花：%.2f", model.payMoney]];
    [paymentStr setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],
                                NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]} range:NSMakeRange(3, paymentStr.length - 3)];
    item.historyPayment = paymentStr;
    
    NSMutableAttributedString *budgetStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"预算：%.2f", model.budgetMoney]];
    [budgetStr setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],
                               NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]} range:NSMakeRange(3, budgetStr.length - 3)];
    item.historyBudget = budgetStr;
    
    double balance = model.budgetMoney - model.payMoney;
    if (balance >= 0) {
        NSString *money = [NSString stringWithFormat:@"%.2f", balance / [endDate daysFrom:nowDate]];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"距结算日前，您每天还可花%@元哦", money]];
        [text setAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]} range:NSMakeRange(12, money.length)];
        item.payOrOverrun = text;
    } else {
        NSString *money = [NSString stringWithFormat:@"%.2f", ABS(balance)];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"亲爱的小主，您目前已超支%@元喽", money]];
        [text setAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]} range:NSMakeRange(12, money.length)];
        item.payOrOverrun = text;
    }
    
    return item;
}

@end
