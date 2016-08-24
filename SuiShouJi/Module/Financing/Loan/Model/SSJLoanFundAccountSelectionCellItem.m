//
//  SSJLoanFundAccountSelectionCellItem.m
//  SuiShouJi
//
//  Created by old lang on 16/8/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanFundAccountSelectionCellItem.h"
#import "SSJLoanFundAccountSelectionViewItem.h"

@implementation SSJLoanFundAccountSelectionCellItem

+ (instancetype)cellItemWithViewItem:(SSJLoanFundAccountSelectionViewItem *)viewItem {
    SSJLoanFundAccountSelectionCellItem *cellItem = [[SSJLoanFundAccountSelectionCellItem alloc] init];
    cellItem.title = viewItem.title;
    cellItem.image = viewItem.image;
    return cellItem;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@:%@", self, @{@"image":(_image ?: @""),
                                                        @"loanTitle":(_title ?: @""),
                                                        @"showCheckMark":@(_showCheckMark)}];
}

@end
