//
//  SSJBudgetListCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/2/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@interface SSJBudgetListCellItem : SSJBaseItem

@property (nonatomic, copy) NSString *typeName;

@property (nonatomic, copy) NSString *beginDate;

@property (nonatomic) double payment;

@property (nonatomic) double budget;

@end
