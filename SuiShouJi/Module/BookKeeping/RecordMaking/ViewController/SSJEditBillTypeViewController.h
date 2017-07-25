//
//  SSJEditBillTypeViewController.h
//  SuiShouJi
//
//  Created by old lang on 16/8/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class SSJBillModel;

SSJ_DEPRECATED
@interface SSJEditBillTypeViewController : SSJBaseViewController

@property (nonatomic, copy) SSJBillModel *model;

// 完成编辑的回调
@property (nonatomic, copy) void (^editSuccessHandle)(SSJEditBillTypeViewController *controller, SSJBillModel *model);

// 有同名类别，返回记一笔页面选中该类别的回调
@property (nonatomic, copy) void (^addNewCategoryAction)(NSString *categoryId, BOOL incomeOrExpence);

@property(nonatomic, strong) NSString *booksId;

@end    

NS_ASSUME_NONNULL_END
