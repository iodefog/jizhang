//
//  SSJLoanFundAccountSelectionCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/8/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@class SSJLoanFundAccountSelectionViewItem;

@interface SSJLoanFundAccountSelectionCellItem : SSJBaseCellItem

@property (nonatomic, copy) NSString *image;

@property (nonatomic, copy) NSString *title;

@property (nonatomic) BOOL showCheckMark;

+ (instancetype)cellItemWithViewItem:(SSJLoanFundAccountSelectionViewItem *)viewItem;

@end
