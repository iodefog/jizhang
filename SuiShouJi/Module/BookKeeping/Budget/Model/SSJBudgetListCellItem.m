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
    NSMutableString *billTypeName = nil;
    if (![model.billIds containsObject:SSJAllBillTypeId]) {
        // 因为有些收支类别可能不存在（例如老版本客户端有，新版本没有），所以要以取出来的类别名称为准
        BOOL hasMore = NO;
        NSMutableArray *billTypeNames = [NSMutableArray arrayWithCapacity:model.billIds.count];
        for (NSString *billId in model.billIds) {
            NSDictionary *billInfo = mapping[billId];
            NSString *typeName = billInfo[@"name"];
            if (!typeName.length) {
                continue;
            }
            
            if (billTypeNames.count >= 4) {
                hasMore = YES;
                break;
            } else {
                [billTypeNames addObject:typeName];
            }
        }
        
        if (billTypeNames.count == 0) {
            return nil;
        }
        
        billTypeName = [[billTypeNames componentsJoinedByString:@","] mutableCopy];
        if (hasMore) {
            [billTypeName appendString:@"等"];
        }
    }
    
    SSJBudgetListCellItem *item = [[SSJBudgetListCellItem alloc] init];
    item.budgetID = model.ID;
    item.isMajor = [model.billIds containsObject:SSJAllBillTypeId];
    item.billTypeName = billTypeName;
    item.period = [NSString stringWithFormat:@"%@——%@", model.beginDate, model.endDate];
    
    NSMutableAttributedString *expendText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"已花：%.2f", model.payMoney]];
    [expendText addAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]} range:NSMakeRange(0, 3)];
    [expendText addAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]} range:NSMakeRange(3, expendText.length - 3)];
    if (item.isMajor) {
        [expendText addAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4]} range:NSMakeRange(0, 3)];
        [expendText addAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1]} range:NSMakeRange(3, expendText.length - 3)];
    } else {
        [expendText addAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4]} range:NSMakeRange(0, expendText.length)];
    }
    item.expend = expendText;
    
    NSMutableAttributedString *budgetText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"计划：%.2f", model.budgetMoney]];
    [budgetText addAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]} range:NSMakeRange(0, 3)];
    [budgetText addAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]} range:NSMakeRange(3, budgetText.length - 3)];
    if (item.isMajor) {
        [budgetText addAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4]} range:NSMakeRange(0, 3)];
        [budgetText addAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1]} range:NSMakeRange(3, budgetText.length - 3)];
    } else {
        [budgetText addAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4]} range:NSMakeRange(0, budgetText.length)];
    }
    item.budget = budgetText;
    
    item.expendValue = model.payMoney;
    item.budgetValue = model.budgetMoney;
    
    if (!item.isMajor) {
        if (model.billIds.count == 1) {
            NSDictionary *billInfo = mapping[[model.billIds firstObject]];
            item.progressColorValue = billInfo[@"color"];
        } else if (model.billIds.count > 1) {
            if (item.expendValue <= item.budgetValue) {
                item.progressColorValue = @"0fceb6";
            } else {
                item.progressColorValue = @"ff654c";
            }
        }
    }
    
    return item;
}

@end
