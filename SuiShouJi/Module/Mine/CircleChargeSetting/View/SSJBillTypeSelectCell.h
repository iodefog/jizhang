//
//  SSJBillTypeSelectCell.h
//  SuiShouJi
//
//  Created by ricky on 16/6/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
#import "SSJRecordMakingBillTypeSelectionCellItem.h"

@interface SSJBillTypeSelectCell : SSJBaseTableViewCell

@property(nonatomic, strong) SSJRecordMakingBillTypeSelectionCellItem *item;

@property(nonatomic) BOOL isSelected;

@end
