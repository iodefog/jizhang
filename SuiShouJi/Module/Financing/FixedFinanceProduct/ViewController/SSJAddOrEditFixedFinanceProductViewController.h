//
//  SSJAddOrEditFixedFinanceProductViewController.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
@class SSJFixedFinanceProductCompoundItem;

NS_ASSUME_NONNULL_BEGIN

@class SSJFixedFinanceProductItem;

@interface SSJAddOrEditFixedFinanceProductViewController : SSJBaseViewController

@property (nonatomic, copy, nullable) SSJFixedFinanceProductItem *model;

/**
 借贷产生的流水列表
 注意：新建不用传，编辑必须传
 */
@property (nonatomic, copy, nullable) NSArray <SSJFixedFinanceProductCompoundItem *>*chargeModels;

@end
NS_ASSUME_NONNULL_END
