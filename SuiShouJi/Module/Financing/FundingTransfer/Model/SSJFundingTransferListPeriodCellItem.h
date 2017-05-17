//
//  SSJFundingTransferListPeriodCellItem.h
//  SuiShouJi
//
//  Created by old lang on 17/2/11.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@class SSJFundingTransferDetailItem;

@interface SSJFundingTransferListPeriodCellItem : SSJBaseCellItem

@property (nonatomic, strong) NSString *transferId;

@property (nonatomic, strong) UIImage *fundLogo;

@property (nonatomic, strong) NSString *transferTitle;

@property (nonatomic, strong) NSString *cycleTitle;

@property (nonatomic, strong) NSString *memo;

@property (nonatomic, strong) NSString *date;

@property (nonatomic, strong) NSString *money;

@property (nonatomic) BOOL opened;

+ (instancetype)cellItemWithTransferDetailItem:(SSJFundingTransferDetailItem *)item;

@end
