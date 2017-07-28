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

SSJ_DEPRECATED
@interface SSJADDNewTypeViewController : SSJBaseViewController

// 是否是支出
@property (nonatomic) BOOL incomeOrExpence;

/**
 选择新的记账类型回调 categoryId:类别id incomeOrExpence:是否支出
 */
@property (nonatomic, copy) void (^addNewCategoryAction)(NSString *categoryId, BOOL incomeOrExpence);

@property(nonatomic, strong) NSString *booksId;

@end
