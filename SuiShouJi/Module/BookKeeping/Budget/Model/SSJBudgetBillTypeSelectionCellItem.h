//
//  SSJBudgetBillTypeSelectionCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/9/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@interface SSJBudgetBillTypeSelectionCellItem : SSJBaseCellItem

@property (nonatomic, copy) NSString *leftImage;

@property (nonatomic, copy) NSString *billTypeName;

@property (nonatomic, copy) NSString *billTypeColor;

@property (nonatomic, copy) NSString *billID;

@property (nonatomic) BOOL canSelect;

@property (nonatomic) BOOL selected;

@end
