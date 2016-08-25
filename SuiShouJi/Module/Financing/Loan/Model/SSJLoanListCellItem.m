//
//  SSJLoanListCellItem.m
//  SuiShouJi
//
//  Created by old lang on 16/8/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanListCellItem.h"
#import "SSJLoanModel.h"

@implementation SSJLoanListCellItem

+ (instancetype)itemWithLoanModel:(SSJLoanModel *)model {
    SSJLoanListCellItem *item = [[SSJLoanListCellItem alloc] init];
    item.icon = @"";
    item.memo = model.memo;
    item.money = [NSString stringWithFormat:@"%.2f", model.jMoney];
    item.showStamp = model.closeOut;
    switch (model.type) {
        case SSJLoanTypeLend:
            item.loanTitle = [NSString stringWithFormat:@"被%@借", model.lender];
            item.date = [NSString stringWithFormat:@"借出日期：%@", model.borrowDate];
            break;
            
        case SSJLoanTypeBorrow:
            item.loanTitle = [NSString stringWithFormat:@"向%@借", model.lender];
            item.date = [NSString stringWithFormat:@"借入日期：%@", model.borrowDate];
            break;
    }
    
    return item;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@:%@", self, @{@"icon":(_icon ?: @""),
                                                        @"loanTitle":(_loanTitle ?: @""),
                                                        @"memo":(_memo ?: @""),
                                                        @"money":(_money ?: @""),
                                                        @"date":(_date ?: @"")}];
}

@end
