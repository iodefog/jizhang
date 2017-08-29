//
//  SSJFixedFinanctAddViewController.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/25.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "SSJFixedFinanceProductChargeItem.h"

@interface SSJFixedFinanctAddViewController : SSJBaseViewController

/**productid*/
@property (nonatomic, copy) NSString *productid;
/**
 指定是追加还是还款，只有SSJLoanCompoundChargeTypeRepayment和SSJLoanCompoundChargeTypeAdd两个值有效
 注意：新建必传，编辑不传
 */
//@property (nonatomic) SSJFixedFinCompoundChargeType chargeType;
@end
