//
//  SSJFixedFinancesSettlementViewController.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/28.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
@class SSJFixedFinanceProductItem;
@class SSJFixedFinanceProductChargeItem;

@interface SSJFixedFinancesSettlementViewController : SSJBaseViewController

/**<#注释#>*/
@property (nonatomic, strong) SSJFixedFinanceProductItem *financeModel;

/**编辑*/
@property (nonatomic, strong) SSJFixedFinanceProductChargeItem *chargeItem;
@end
