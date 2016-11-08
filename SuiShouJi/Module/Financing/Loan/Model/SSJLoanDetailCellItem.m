//
//  SSJLoanDetailCellItem.m
//  SuiShouJi
//
//  Created by old lang on 16/8/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanDetailCellItem.h"
#import "SSJLoanChargeModel.h"

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

- (CGFloat)cellHeight {
    if (self.bottomTitle.length) {
        return 74;
    } else {
        return 54;
    }
}

+ (SSJLoanDetailCellItem *)cellItemWithChargeModel:(SSJLoanChargeModel *)model {
    NSString *title = nil;
    NSString *subtitle = nil;
    NSAttributedString *bottomTitle = nil;
    
    switch (model.type) {
        case SSJLoanTypeLend:
            switch (model.chargeType) {
                case SSJLoanCompoundChargeTypeCreate:
                    title = @"借出";
                    subtitle = [NSString stringWithFormat:@"＋%.2f", model.money];
                    break;
                    
                case SSJLoanCompoundChargeTypeBalanceIncrease:
                    title = @"剩余借出款余额变更";
                    subtitle = [NSString stringWithFormat:@"＋%.2f", model.money];
                    bottomTitle = [self bottomTitleWithChargeModel:model];
                    break;
                case SSJLoanCompoundChargeTypeBalanceDecrease:
                    title = @"剩余借出款余额变更";
                    subtitle = [NSString stringWithFormat:@"－%.2f", model.money];
                    bottomTitle = [self bottomTitleWithChargeModel:model];
                    break;
                    
                case SSJLoanCompoundChargeTypeRepayment:
                    title = @"收款";
                    subtitle = [NSString stringWithFormat:@"－%.2f", model.money];
                    break;
                    
                case SSJLoanCompoundChargeTypeAdd:
                    title = @"追加借出";
                    subtitle = [NSString stringWithFormat:@"＋%.2f", model.money];
                    break;
                    
                case SSJLoanCompoundChargeTypeCloseOut:
                    title = @"借出款结清";
                    subtitle = [NSString stringWithFormat:@"－%.2f", model.money];
                    break;
                    
                case SSJLoanCompoundChargeTypeInterest:
                    title = @"利息收入";
                    subtitle = [NSString stringWithFormat:@"＋%.2f", model.money];
                    break;
            }
            break;
            
        case SSJLoanTypeBorrow:
            switch (model.chargeType) {
                case SSJLoanCompoundChargeTypeCreate:
                    title = @"欠款";
                    subtitle = [NSString stringWithFormat:@"－%.2f", model.money];
                    break;
                    
                case SSJLoanCompoundChargeTypeBalanceIncrease:
                    title = @"剩余借出款余额变更";
                    subtitle = [NSString stringWithFormat:@"－%.2f", model.money];
                    bottomTitle = [self bottomTitleWithChargeModel:model];
                    break;
                case SSJLoanCompoundChargeTypeBalanceDecrease:
                    title = @"剩余借出款余额变更";
                    subtitle = [NSString stringWithFormat:@"＋%.2f", model.money];
                    bottomTitle = [self bottomTitleWithChargeModel:model];
                    break;
                    
                case SSJLoanCompoundChargeTypeRepayment:
                    title = @"还款";
                    subtitle = [NSString stringWithFormat:@"＋%.2f", model.money];
                    break;
                    
                case SSJLoanCompoundChargeTypeAdd:
                    title = @"追加欠款";
                    subtitle = [NSString stringWithFormat:@"－%.2f", model.money];
                    break;
                    
                case SSJLoanCompoundChargeTypeCloseOut:
                    title = @"欠款结清";
                    subtitle = [NSString stringWithFormat:@"＋%.2f", model.money];
                    break;
                    
                case SSJLoanCompoundChargeTypeInterest:
                    title = @"利息支出";
                    subtitle = [NSString stringWithFormat:@"－%.2f", model.money];
                    break;
            }
            break;
    }
    
    return [SSJLoanDetailCellItem itemWithImage:model.icon title:title subtitle:subtitle bottomTitle:bottomTitle];
}

+ (NSAttributedString *)bottomTitleWithChargeModel:(SSJLoanChargeModel *)model {
    NSString *money = [NSString stringWithFormat:@"%.2f", model.oldMoney];
    NSString *bottomStr = [NSString stringWithFormat:@"由原先的%@元变更", money];
    return [[NSMutableAttributedString alloc] initWithString:bottomStr attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]}];
}

@end
