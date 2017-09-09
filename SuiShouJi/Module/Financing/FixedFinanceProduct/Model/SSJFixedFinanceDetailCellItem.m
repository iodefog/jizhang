//
//  SSJFixedFinanceDetailCellId.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/25.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanceDetailCellItem.h"
#import "SSJFixedFinanceProductChargeItem.h"
#import "SSJFixedFinanceProductItem.h"

@implementation SSJFixedFinanceDetailCellItem
+ (instancetype)cellItemWithChargeModel:(SSJFixedFinanceProductChargeItem *)model productItem:(SSJFixedFinanceProductItem *)productItem {
    SSJFixedFinanceDetailCellItem *item = [[SSJFixedFinanceDetailCellItem alloc] init];
    item.titmeStr = [model.billDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *icon = @"";
    NSString *name = @"";
    NSString *money = @"";
    double surplus = 0;     // 当前余额
    switch (model.chargeType) {
        case SSJFixedFinCompoundChargeTypeCreate://新建
            icon = @"fixed_finance_benjin";
            name = @"投资本金";
            money = [NSString stringWithFormat:@"+%.2f",model.money];
            surplus += model.money;
            break;
        case SSJFixedFinCompoundChargeTypeAdd://追加
            icon = @"fixed_finance_add";
            name = @"追加投资";
            money = [NSString stringWithFormat:@"+%.2f",model.money];
            surplus += model.money;
            break;
        case SSJFixedFinCompoundChargeTypeRedemption://赎回
            icon = @"fixed_finance_shu";
            name = @"部分赎回";
            money = [NSString stringWithFormat:@"-%.2f",model.money];
            surplus -= model.money;
            break;
        case SSJFixedFinCompoundChargeTypeBalanceInterestIncrease://利息转入
            icon = @"fixed_finance_lixi";
            money = [NSString stringWithFormat:@"+%.2f",model.money];
            name = @"结算利息转入";
            surplus += model.money;
            break;
        case SSJFixedFinCompoundChargeTypeBalanceInterestDecrease://利息转出
            money = [NSString stringWithFormat:@"-%.2f",model.money];
            icon = @"fixed_finance_lixi";
            name = @"结算利息转出";
            surplus -= model.money;
            break;
        case SSJFixedFinCompoundChargeTypeInterest://固收理财派发利息流水
            icon = @"fixed_finance_lixi";
                switch (productItem.interesttype) {
                    case SSJMethodOfInterestEveryDay:
                        name = @"每日利息";
                        break;
                    case SSJMethodOfInterestOncePaid:
                        name = @"到期利息";
                        break;
                    case SSJMethodOfInterestEveryMonth:
                        name = @"每月利息";
                        break;
                        
                    default:
                        break;
                }
            money = [NSString stringWithFormat:@"+%.2f",model.money];
            surplus -= model.money;
            break;
            
        case SSJFixedFinCompoundChargeTypeCloseOutInterest://结算利息
            icon = @"fixed_finance_lixi";
            name = @"手续费";
            money = [NSString stringWithFormat:@"-%.2f",model.money];
            surplus -= model.money;
            break;
        case SSJFixedFinCompoundChargeTypeCloseOut://结清
            icon = @"fixed_finance_lixi";
            name = @"结算本金";
            money = [NSString stringWithFormat:@"-%.2f",model.money];
            surplus -= model.money;
            break;
        case SSJFixedFinCompoundChargeTypePinZhangBalanceIncrease://固收理财平账收入
            icon = @"fixed_finance_lixi";
            name = @"利息平账收入";
            money = [NSString stringWithFormat:@"+%.2f",model.money];
            surplus += model.money;
            break;
        case SSJFixedFinCompoundChargeTypePinZhangBalanceDecrease://固收理财平账支出
            icon = @"fixed_finance_lixi";
            name = @"利息平账支出";
            money = [NSString stringWithFormat:@"-%.2f",model.money];
            surplus -= model.money;
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

+ (NSAttributedString *)bottomTitleWithOldMoney:(double)oldMoney {
    NSString *money = [NSString stringWithFormat:@"%.2f", oldMoney];
    NSString *bottomStr = [NSString stringWithFormat:@"由原先的%@元变更", money];
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:bottomStr];
    [attributeStr setAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]} range:[bottomStr rangeOfString:money]];
    return attributeStr;
}

@end
