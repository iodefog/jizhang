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
 是否新建
 */
@property (nonatomic) BOOL created;

/**
 是否支出（编辑、新建都要传）
 */
@property (nonatomic) BOOL expended;

/**
 当前账本id；如果不传默认用户当前账本
 */
@property (nonatomic, copy, nullable) NSString *booksId;

/**
 收支类别id（编辑必传，新建不用）
 */
@property (nonatomic, copy, nullable) NSString *billId;

/**
 收支类别图标（编辑必传，新建不用）
 */
@property (nonatomic, copy, nullable) NSString *icon;

/**
 收支类别名称（编辑必传，新建不用）
 */
@property (nonatomic, copy, nullable) NSString *name;

/**
 收支类别颜色（编辑必传，新建不用）
 */
@property (nonatomic, copy, nullable) NSString *color;

/**
 保存成功后的回调
 */
@property (nonatomic, copy) void (^saveHandler)(NSString *billID);

@end

NS_ASSUME_NONNULL_END
