//
//  SSJCreateOrEditBillTypeViewController.h
//  SuiShouJi
//
//  Created by old lang on 2017/7/20.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

//  新建／编辑收支类别
#import "SSJBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSJCreateOrEditBillTypeViewController : SSJBaseViewController

/**
 当前账本id（编辑、新建都要传）
 */
@property (nonatomic, copy) NSString *booksId;

/**
 收支类别id（编辑必传，新建不用）
 */
@property (nonatomic, copy, nullable) NSString *billId;

/**
 是否支出（新建必传，编辑不用）
 */
@property (nonatomic) BOOL expended;

@end

NS_ASSUME_NONNULL_END
