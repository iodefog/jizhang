//
//  SSJCalenderDetailViewController.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNewBaseTableViewController.h"
#import "SSJBillingChargeCellItem.h"

@interface SSJCalenderDetailViewController :SSJNewBaseTableViewController<UIAlertViewDelegate>
@property (nonatomic,strong) SSJBillingChargeCellItem *item;
@end
