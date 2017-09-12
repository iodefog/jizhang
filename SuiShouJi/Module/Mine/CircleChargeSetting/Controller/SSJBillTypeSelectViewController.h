//
//  SSJBillTypeSelectViewController.h
//  SuiShouJi
//
//  Created by ricky on 16/6/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNewBaseTableViewController.h"
#import "SSJRecordMakingBillTypeSelectionCellItem.h"

@interface SSJBillTypeSelectViewController : SSJNewBaseTableViewController

@property (nonatomic) BOOL incomeOrExpenture;

@property(nonatomic, strong) NSString *selectedId;

typedef void (^typeSelectBlock)(SSJRecordMakingBillTypeSelectionCellItem *item);

@property (nonatomic, strong) NSString *booksId;

@property(nonatomic, copy) typeSelectBlock typeSelectBlock;


@end
