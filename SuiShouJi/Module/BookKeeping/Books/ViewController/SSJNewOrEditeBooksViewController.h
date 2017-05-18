//
//  SSJNewOrEditeBooksViewController.h
//  SuiShouJi
//
//  Created by yi cai on 2017/5/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

@interface SSJNewOrEditeBooksViewController : SSJBaseViewController

@property (nonatomic, strong) __kindof SSJBaseCellItem *bookItem;

@property (nonatomic, copy) void (^saveBooksBlock)(NSString *booksId);
@end
