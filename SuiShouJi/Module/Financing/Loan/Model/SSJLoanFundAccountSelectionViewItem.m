//
//  SSJLoanFundAccountSelectionViewItem.m
//  SuiShouJi
//
//  Created by old lang on 16/8/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanFundAccountSelectionViewItem.h"

@implementation SSJLoanFundAccountSelectionViewItem

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@:%@", self, @{@"image":(_image ?: @""),
                                                        @"loanTitle":(_title ?: @"")}];
}

@end
