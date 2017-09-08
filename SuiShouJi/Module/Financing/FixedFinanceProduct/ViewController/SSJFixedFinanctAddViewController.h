//
//  SSJFixedFinanctAddViewController.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/25.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

@class SSJFixedFinanceProductChargeItem;
@class SSJFixedFinanceProductItem;

@interface SSJFixedFinanctAddViewController : SSJBaseViewController

///**productid*/
//@property (nonatomic, copy) NSString *productid;

@property (nonatomic, strong) SSJFixedFinanceProductItem *financeModel;

/**点击进入详情的时候必须传新建不用传*/
@property (nonatomic, strong)  SSJFixedFinanceProductChargeItem *chargeItem;
@end
