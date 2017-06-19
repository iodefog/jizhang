//
//  SSJFundingTypeSelectViewController.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNewBaseTableViewController.h"
#import "SSJBaseCellItem.h"
#import "SSJFundingItem.h"

@interface SSJFundingTypeSelectViewController : SSJNewBaseTableViewController

typedef void (^addNewFundingBlock)(SSJBaseCellItem *item);

@property(nonatomic,copy) addNewFundingBlock addNewFundingBlock;

//是否需要借贷
@property(nonatomic) BOOL needLoanOrNot;

@property (nonatomic, copy) void (^fundingParentSelectBlock)(SSJFundingItem *selectItem);

@end
