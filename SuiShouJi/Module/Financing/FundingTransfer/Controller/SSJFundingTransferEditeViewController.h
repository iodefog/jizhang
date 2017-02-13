//
//  SSJFundingTransferEditeViewController.h
//  SuiShouJi
//
//  Created by ricky on 16/6/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNewBaseTableViewController.h"
#import "SSJFundingTransferDetailItem.h"
#import "SSJBillingChargeCellItem.h"

SSJ_DEPRECATED

@interface SSJFundingTransferEditeViewController : SSJNewBaseTableViewController<UIActionSheetDelegate>
@property(nonatomic, strong) SSJFundingTransferDetailItem *item;
@property(nonatomic, strong) SSJBillingChargeCellItem *chargeItem;
@end
