//
//  SSJFundingTransferListPeriodCellItem.h
//  SuiShouJi
//
//  Created by old lang on 17/2/11.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"
#import <UIKit/UIKit.h>

@interface SSJFundingTransferListPeriodCellItem : SSJBaseItem

@property (nonatomic, strong) UIImage *fundLogo;

@property (nonatomic, strong) NSString *transferTitle;

@property (nonatomic, strong) NSString *cycleTitle;

@property (nonatomic, strong) NSString *memo;

@property (nonatomic, strong) NSString *date;

@property (nonatomic, strong) NSString *money;

@property (nonatomic) BOOL opened;

@end
