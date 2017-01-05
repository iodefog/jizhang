//
//  SSJLoanDetailCellItem.m
//  SuiShouJi
//
//  Created by old lang on 16/8/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanDetailCellItem.h"

@implementation SSJLoanDetailCellItem

+ (instancetype)itemWithImage:(NSString *)image
                        title:(NSString *)title
                     subtitle:(NSString *)subtitle
                  bottomTitle:(NSAttributedString *)bottomTitle {
    
    SSJLoanDetailCellItem *item = [[SSJLoanDetailCellItem alloc] init];
    item.image = image;
    item.title = title;
    item.subtitle = subtitle;
    item.bottomTitle = bottomTitle;
    return item;
}

- (CGFloat)rowHeight {
    if (self.bottomTitle.length) {
        return 74;
    } else {
        return 54;
    }
}

+ (SSJLoanDetailCellItem *)cellItemWithChargeModel:(SSJLoanChargeModel *)model {
    NSString *icon = nil;
    NSString *title = nil;
    NSString *subtitle = nil;
    NSAttributedString *bottomTitle = nil;
    
    switch (model.type) {
        case SSJLoanTypeLend:
            switch (model.chargeType) {
                case SSJLoanCompoundChargeTypeCreate:
                    icon = @"loan_lend";
                    title = @"借出";
                    subtitle = [NSString stringWithFormat:@"＋%.2f", model.money];
                    break;
                    
                case SSJLoanCompoundChargeTypeBalanceIncrease:
                    icon = @"loan_balance";
                    title = @"剩余借出款更改";
                    subtitle = [NSString stringWithFormat:@"＋%.2f", model.money];
                    bottomTitle = [self bottomTitleWithChargeModel:model];
                    break;
                case SSJLoanCompoundChargeTypeBalanceDecrease:
                    icon = @"loan_balance";
                    title = @"剩余借出款更改";
                    subtitle = [NSString stringWithFormat:@"－%.2f", model.money];
                    bottomTitle = [self bottomTitleWithChargeModel:model];
                    break;
                    
                case SSJLoanCompoundChargeTypeRepayment:
                    icon = @"loan_receipt";
                    title = @"收款";
                    subtitle = [NSString stringWithFormat:@"－%.2f", model.money];
                    if (model.memo) {
                        bottomTitle = [[NSAttributedString alloc] initWithString:model.memo];
                    }
                    break;
                    
                case SSJLoanCompoundChargeTypeAdd:
                    icon = @"loan_append";
                    title = @"追加借出";
                    subtitle = [NSString stringWithFormat:@"＋%.2f", model.money];
                    if (model.memo) {
                        bottomTitle = [[NSAttributedString alloc] initWithString:model.memo];
                    }
                    break;
                    
                case SSJLoanCompoundChargeTypeCloseOut:
                    icon = @"loan_lend";
                    title = @"借出款结清";
                    subtitle = [NSString stringWithFormat:@"－%.2f", model.money];
                    break;
                    
                case SSJLoanCompoundChargeTypeInterest:
                    icon = @"loan_interest_charge";
                    title = @"利息收入";
                    subtitle = [NSString stringWithFormat:@"＋%.2f", model.money];
                    break;
            }
            break;
            
        case SSJLoanTypeBorrow:
            switch (model.chargeType) {
                case SSJLoanCompoundChargeTypeCreate:
                    icon = @"loan_debt";
                    title = @"欠款";
                    subtitle = [NSString stringWithFormat:@"－%.2f", model.money];
                    break;
                    
                case SSJLoanCompoundChargeTypeBalanceIncrease:
                    icon = @"loan_balance";
                    title = @"剩余欠款更改";
                    subtitle = [NSString stringWithFormat:@"－%.2f", model.money];
                    bottomTitle = [self bottomTitleWithChargeModel:model];
                    break;
                case SSJLoanCompoundChargeTypeBalanceDecrease:
                    icon = @"loan_balance";
                    title = @"剩余欠款更改";
                    subtitle = [NSString stringWithFormat:@"＋%.2f", model.money];
                    bottomTitle = [self bottomTitleWithChargeModel:model];
                    break;
                    
                case SSJLoanCompoundChargeTypeRepayment:
                    icon = @"loan_repayment";
                    title = @"还款";
                    subtitle = [NSString stringWithFormat:@"＋%.2f", model.money];
                    if (model.memo) {
                        bottomTitle = [[NSAttributedString alloc] initWithString:model.memo];
                    }
                    break;
                    
                case SSJLoanCompoundChargeTypeAdd:
                    icon = @"loan_append";
                    title = @"追加欠款";
                    subtitle = [NSString stringWithFormat:@"－%.2f", model.money];
                    if (model.memo) {
                        bottomTitle = [[NSAttributedString alloc] initWithString:model.memo];
                    }
                    break;
                    
                case SSJLoanCompoundChargeTypeCloseOut:
                    icon = @"loan_debt";
                    title = @"欠款结清";
                    subtitle = [NSString stringWithFormat:@"＋%.2f", model.money];
                    break;
                    
                case SSJLoanCompoundChargeTypeInterest:
                    icon = @"loan_interest_charge";
                    title = @"利息支出";
                    subtitle = [NSString stringWithFormat:@"－%.2f", model.money];
                    break;
            }
            break;
    }
    
    SSJLoanDetailCellItem *item = [SSJLoanDetailCellItem itemWithImage:icon title:title subtitle:subtitle bottomTitle:bottomTitle];
    item.chargeId = model.chargeId;
    item.chargeType = model.chargeType;
    
    return item;
}

+ (NSAttributedString *)bottomTitleWithChargeModel:(SSJLoanChargeModel *)model {
    NSString *money = [NSString stringWithFormat:@"%.2f", model.oldMoney];
    NSString *bottomStr = [NSString stringWithFormat:@"由原先的%@元变更", money];
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:bottomStr];
    [attributeStr setAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]} range:[bottomStr rangeOfString:money]];
    return attributeStr;
}

@end
