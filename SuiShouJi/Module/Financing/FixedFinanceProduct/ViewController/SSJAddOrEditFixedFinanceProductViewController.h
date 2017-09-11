//
//  SSJAddOrEditFixedFinanceProductViewController.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
@class SSJFixedFinanceProductCompoundItem;
@class SSJFixedFinanceProductChargeItem;

NS_ASSUME_NONNULL_BEGIN

@class SSJFixedFinanceProductItem;

@interface SSJAddOrEditFixedFinanceProductViewController : SSJBaseViewController

@property (nonatomic, strong, nullable) SSJFixedFinanceProductItem *model;

/**
 的流水列表
 注意：新建不用传，编辑必须传
 */
@property (nonatomic, strong, nullable) NSArray <SSJFixedFinanceProductCompoundItem *>*chargeModels;

@property (nonatomic, strong, nullable) SSJFixedFinanceProductChargeItem *chargeItem;

// 是否是编辑
@property (nonatomic) BOOL edited;

@end
NS_ASSUME_NONNULL_END
