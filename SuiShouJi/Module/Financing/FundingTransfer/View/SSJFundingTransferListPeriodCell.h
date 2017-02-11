//
//  SSJFundingTransferListPeriodCell.h
//  SuiShouJi
//
//  Created by old lang on 17/2/10.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
#import "SSJFundingTransferListPeriodCellItem.h"

@interface SSJFundingTransferListPeriodCell : SSJBaseTableViewCell

@property (nonatomic, copy) void (^switchCtrlAction)(BOOL, SSJFundingTransferListPeriodCell *);

@end
