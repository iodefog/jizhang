//
//  SSJEveryInverestDetailViewController.h
//  SuiShouJi
//
//  Created by yi cai on 2017/9/6.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
@class SSJFixedFinanceProductItem;
@class SSJFixedFinanceProductChargeItem;

@interface SSJEveryInverestDetailViewController : SSJBaseViewController

/**<#注释#>*/
@property (nonatomic, strong) SSJFixedFinanceProductChargeItem *chargeItem;

/**<#注释#>*/
@property (nonatomic, strong) SSJFixedFinanceProductItem *productItem;

@end
