//
//  SSJADDNewTypeViewController.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//
//添加新的资金类型

#import "SSJRecordMakingCategoryItem.h"
#import "SSJBaseViewController.h"

@interface SSJADDNewTypeViewController : SSJBaseViewController<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic) BOOL incomeOrExpence;

/**
 *  选择新的记账类型回调
 *
 *  @param categoryID 记账类型id
 *  @param item       记账类型的item
 */
typedef void (^NewCategorySelectedBlock)(NSString *categoryID , SSJRecordMakingCategoryItem *item);


@property (nonatomic, copy) NewCategorySelectedBlock NewCategorySelectedBlock;


@end
