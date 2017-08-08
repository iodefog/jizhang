//
//  SSJWishChargeDetailViewController.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/20.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
@class SSJWishChargeItem;
@class SSJWishModel;

@interface SSJWishChargeDetailViewController : SSJBaseViewController

@property (nonatomic, strong) SSJWishChargeItem *chargeItem;
//编辑心愿流水(存钱)and取钱
@property (nonatomic, strong) SSJWishModel *wishModel;

@end
