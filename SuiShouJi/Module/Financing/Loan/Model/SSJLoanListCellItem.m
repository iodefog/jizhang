//
//  SSJLoanListCellItem.m
//  SuiShouJi
//
//  Created by old lang on 16/8/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanListCellItem.h"
#import "SSJLoanModel.h"
#import "SSJFixedFinanceProductItem.h"
#import "SSJFixedFinanceProductStore.h"
#import "SSJFixedFinanceProductChargeItem.h"

@implementation SSJLoanListCellItem

+ (instancetype)itemWithLoanModel:(SSJLoanModel *)model {
    SSJLoanListCellItem *item = [[SSJLoanListCellItem alloc] init];
    item.icon = model.image;
    item.memo = model.memo;
    item.showStamp = model.closeOut;
    
    NSString *borrowDate = [model.borrowDate formattedDateWithFormat:@"yyyy.MM.dd"];
    switch (model.type) {
        case SSJLoanTypeLend:
            if (model.jMoney >= 0) {
                item.money = [NSString stringWithFormat:@"+%.2f", ABS(model.jMoney)];
            } else {
                item.money = [NSString stringWithFormat:@"-%.2f", ABS(model.jMoney)];
            }
            item.loanTitle = [NSString stringWithFormat:@"被%@借", model.lender];
            item.date = [NSString stringWithFormat:@"借出日期：%@", borrowDate];
            break;
            
        case SSJLoanTypeBorrow:
            if (model.jMoney >= 0) {
                item.money = [NSString stringWithFormat:@"-%.2f", ABS(model.jMoney)];
            } else {
                item.money = [NSString stringWithFormat:@"+%.2f", ABS(model.jMoney)];
            }
            item.loanTitle = [NSString stringWithFormat:@"欠%@钱款", model.lender];
            item.date = [NSString stringWithFormat:@"欠款日期：%@", borrowDate];
            break;
    }
    
    return item;
}

+ (instancetype)itemForFixedFinanceProductModel:(SSJFixedFinanceProductItem *)model {
    SSJLoanListCellItem *item = [[SSJLoanListCellItem alloc] init];
    item.icon = model.productIcon;
    item.memo = model.memo;
    item.loanTitle = model.productName;
    double money = 0;
    NSArray *array = [SSJFixedFinanceProductStore queryFixedFinanceProductAddAndRedemChargeListWithModel:model error:nil];
    for (SSJFixedFinanceProductChargeItem *tempItem in array) {
        money += tempItem.money;
    }
    if (model.isend) {
        double jiesuanlixi = [SSJFixedFinanceProductStore queryForFixedFinanceProduceJieSuanInterestiothWithProductID:model.productid];
        double benJinMoney = money + jiesuanlixi;
        item.money = [NSString stringWithFormat:@"%.2f",benJinMoney];
    } else {
        item.money = [NSString stringWithFormat:@"%.2f",money + [SSJFixedFinanceProductStore queryForFixedFinanceProduceCurrentMoneyWothWithProductID:model.productid]];
    }
    
    item.date = [NSString stringWithFormat:@"起息日期：%@",model.startdate];
    item.showStamp = model.isend;
    item.imageName = @"fixed_jiesuan";
    item.showStateL = [[model.enddate ssj_dateWithFormat:@"yyyy-MM-dd"] isEarlierThanOrEqualTo:[NSDate date]];
    item.descStr = model.isend ? @"到账金额" : @"当前余额";
    //[[model.enddate ssj_dateWithFormat:@"yyyy-MM-dd"] compare:[NSDate date]];
    return item;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@:%@", self, @{@"icon":(_icon ?: [NSNull null]),
                                                        @"loanTitle":(_loanTitle ?: [NSNull null]),
                                                        @"memo":(_memo ?: [NSNull null]),
                                                        @"money":(_money ?: [NSNull null]),
                                                        @"date":(_date ?: [NSNull null])}];
}

@end
