//
//  SSJRepaymentDetailViewController.h
//  SuiShouJi
//
//  Created by ricky on 2016/12/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJRepaymentModel.h"

@interface SSJInstalmentEditeViewController : SSJBaseViewController

@property(nonatomic, strong) SSJBillingChargeCellItem *chargeItem;

@property(nonatomic, strong) SSJRepaymentModel *repaymentModel;

@property(nonatomic, strong) SSJRepaymentModel *originalRepaymentModel;

@end
