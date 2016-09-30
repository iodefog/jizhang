//
//  SSJBudgetListCellItem.m
//  SuiShouJi
//
//  Created by old lang on 16/2/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetListCellItem.h"
#import "SSJBudgetModel.h"

@implementation SSJBudgetListCellItem

+ (instancetype)cellItemWithBudgetModel:(SSJBudgetModel *)model billTypeMapping:(NSDictionary *)mapping {
    SSJBudgetListCellItem *item = [[SSJBudgetListCellItem alloc] init];
    item.budgetID = model.ID;
    item.isMajor = [model.billIds isEqualToArray:@[@"all"]];
    
    NSMutableArray *billTypeNames = [NSMutableArray arrayWithCapacity:model.billIds.count];
    for (NSString *billId in model.billIds) {
        NSString *typeName = mapping[billId];
        if (typeName) {
            [billTypeNames addObject:typeName];
        }
        if (billTypeNames.count >= 4) {
            break;
        }
    }
    
    if (model.billIds.count > 4) {
        [billTypeNames addObject:@"等"];
    }
    item.billTypeName = [billTypeNames componentsJoinedByString:@","];
    
    item.period = [NSString stringWithFormat:@"%@——%@", model.beginDate, model.endDate];
    
    NSMutableAttributedString *expendText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"已花：%.2f", model.payMoney]];
    [expendText addAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]} range:NSMakeRange(0, 3)];
    [expendText addAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]} range:NSMakeRange(3, expendText.length - 3)];
    if (item.isMajor) {
        [expendText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} range:NSMakeRange(0, 3)];
        [expendText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]} range:NSMakeRange(3, expendText.length - 3)];
    } else {
        [expendText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} range:NSMakeRange(0, expendText.length)];
    }
    item.expend = expendText;
    
    NSMutableAttributedString *budgetText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"计划：%.2f", model.budgetMoney]];
    [budgetText addAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]} range:NSMakeRange(0, 3)];
    [budgetText addAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]} range:NSMakeRange(3, budgetText.length - 3)];
    if (item.isMajor) {
        [budgetText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} range:NSMakeRange(0, 3)];
        [budgetText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]} range:NSMakeRange(3, budgetText.length - 3)];
    } else {
        [budgetText addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} range:NSMakeRange(0, budgetText.length)];
    }
    item.budget = budgetText;
    
    item.expendValue = model.payMoney;
    item.budgetValue = model.budgetMoney;
    
    return item;
}

@end
