//
//  SSJFixedFinanceRedemViewController.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/28.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

@interface SSJFixedFinanceRedemViewController : SSJBaseViewController
/**productid*/
@property (nonatomic, copy) NSString *productid;

/**可赎回金额*/
@property (nonatomic, assign) double canRedemMoney;
@end
