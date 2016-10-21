//
//  SSJBudgetBillTypeSelectionCellItem.m
//  SuiShouJi
//
//  Created by old lang on 16/9/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetBillTypeSelectionCellItem.h"

@implementation SSJBudgetBillTypeSelectionCellItem

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@:%@", self, @{@"leftImage":(_leftImage ?: [NSNull null]),
                                                        @"billTypeName":(_billTypeName ?: [NSNull null]),
                                                        @"billTypeColor":(_billTypeColor ?: [NSNull null]),
                                                        @"billID":(_billID ?: [NSNull null]),
                                                        @"canSelect":@(_canSelect),
                                                        @"selected":@(_selected)}];
}

@end
