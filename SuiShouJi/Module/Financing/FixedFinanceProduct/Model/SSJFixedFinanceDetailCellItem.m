//
//  SSJFixedFinanceDetailCellId.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/25.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanceDetailCellItem.h"
#import "SSJFixedFinanceProductChargeItem.h"

@implementation SSJFixedFinanceDetailCellItem
+ (instancetype)cellItemWithChargeModel:(SSJFixedFinanceProductChargeItem *)model {
    SSJFixedFinanceDetailCellItem *item = [[SSJFixedFinanceDetailCellItem alloc] init];
    item.titmeStr = [model.writeDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *icon = @"";
    NSString *name = @"";
    NSString *money = @"";
    switch (model.chargeType) {
        case SSJFixedFinCompoundChargeTypeCreate://新建
            icon = @"fixed_finance_benjin";
            name = @"固收理财本金";
            money = [NSString stringWithFormat:@"+%.2f",model.money];
            break;
        case SSJFixedFinCompoundChargeTypeAdd://追加
            icon = @"fixed_finance_add";
            name = @"固收理财追加购买";
            money = [NSString stringWithFormat:@"+%.2f",model.money];
            break;
        case SSJFixedFinCompoundChargeTypeRedemption://赎回
            icon = @"fixed_finance_shu";
            name = @"固收理财部分赎回";
            money = [NSString stringWithFormat:@"-%.2f",model.money];
            break;
        case SSJFixedFinCompoundChargeTypeBalanceIncrease://余额转入
            icon = @"fixed_finance_edit";
            name = @"固收理财余额变更";
            money = [NSString stringWithFormat:@"+%.2f",model.money];
            break;
        case SSJFixedFinCompoundChargeTypeBalanceDecrease://余额转出
            icon = @"fixed_finance_edit";
            name = @"固收理财余额变更";
            money = [NSString stringWithFormat:@"-%.2f",model.money];
            break;
        case SSJFixedFinCompoundChargeTypeBalanceInterestIncrease://利息转入
            icon = @"fixed_finance_lixi";
            money = [NSString stringWithFormat:@"+%.2f",model.money];
            name = @"固收理财日息";
            break;
        case SSJFixedFinCompoundChargeTypeBalanceInterestDecrease://利息转出
            money = [NSString stringWithFormat:@"-%.2f",model.money];
            icon = @"fixed_finance_lixi";
            name = @"固收理财日息";
            break;
        case SSJFixedFinCompoundChargeTypeInterest://固收理财派发利息流水
            icon = @"fixed_finance_lixi";
            name = @"到期利息";
            money = [NSString stringWithFormat:@"+%.2f",model.money];
            break;
            
        case SSJFixedFinCompoundChargeTypeCloseOutInterest://结算利息
            icon = @"fixed_finance_lixi";
            name = @"部分赎回手续费";
            money = [NSString stringWithFormat:@"-%.2f",model.money];
            break;
        case SSJFixedFinCompoundChargeTypeCloseOut://结清
            icon = @"fixed_finance_lixi";
            name = @"固收理财结算";
            money = [NSString stringWithFormat:@"+%.2f",model.money];
            break;
            
        default:
            break;
    }
    item.iconStr = icon;
    item.nameStr = name;
    item.subStr = model.memo;
    item.amountStr = money;
    return item;
}

@end
