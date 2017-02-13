//
//  SSJFundingTransferListPeriodCellItem.m
//  SuiShouJi
//
//  Created by old lang on 17/2/11.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFundingTransferListPeriodCellItem.h"
#import "SSJFundingTransferDetailItem.h"

@implementation SSJFundingTransferListPeriodCellItem

+ (instancetype)cellItemWithTransferDetailItem:(SSJFundingTransferDetailItem *)item {
    SSJFundingTransferListPeriodCellItem *cellItem = [[SSJFundingTransferListPeriodCellItem alloc] init];
    cellItem.transferId = item.ID;
    cellItem.fundLogo = [UIImage imageNamed:item.transferInImage];
    cellItem.transferTitle = [NSString stringWithFormat:@"%@到%@", item.transferOutName, item.transferInName];
    cellItem.cycleTitle = SSJTitleForCycleType(item.cycleType);
    cellItem.memo = item.transferMemo;
    cellItem.date = [NSString stringWithFormat:@"设于%@", item.beginDate];
    cellItem.money = [NSString stringWithFormat:@"%.2f", [item.transferMoney doubleValue]];
    cellItem.opened = item.opened;
    return cellItem;
}

@end
