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
 默认选中的账本标签
 */
@property (nonatomic) SSJBooksType booksType;

/**
 默认选中的类别颜色
 */
@property (nonatomic, strong) UIColor *billTypeColor;

/**
 默认选中的类别图标
 */
@property (nonatomic, strong) UIImage *billTypeIcon;

/**
 默认的类别名称
 */
@property (nonatomic, copy) NSString *billTypeName;

/**
 是否支出
 */
@property (nonatomic) BOOL expended;

@end

NS_ASSUME_NONNULL_END
