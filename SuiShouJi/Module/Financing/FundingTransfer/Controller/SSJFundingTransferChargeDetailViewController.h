//
//  SSJFundingTransferChargeDetailViewController.h
//  SuiShouJi
//
//  Created by old lang on 17/2/12.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class SSJFundingTransferDetailItem;
@class SSJBillingChargeCellItem;

@interface SSJFundingTransferChargeDetailViewController : SSJBaseViewController

/**
 从转账记录列表页面进入时必穿
 */
@property(nonatomic, strong, nullable) SSJFundingTransferDetailItem *item;

/**
 从资金详情页的流水列表中进入时必穿
 */
@property(nonatomic, strong, nullable) SSJBillingChargeCellItem *chargeItem;

@end

NS_ASSUME_NONNULL_END
