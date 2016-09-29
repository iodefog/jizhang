//
//  SSJBudgetListSecondaryCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/9/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@class SSJBudgetModel;

@interface SSJBudgetListSecondaryCellItem : SSJBaseItem

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *billTypeName;

@property (nonatomic, copy) NSString *period;

@property (nonatomic, copy) NSAttributedString *expend;

@property (nonatomic, copy) NSAttributedString *budget;

@property (nonatomic, copy) NSString *progressTitle;

@property (nonatomic) CGFloat expendValue;

@property (nonatomic) CGFloat budgetValue;

+ (instancetype)cellItemWithBudgetModel:(SSJBudgetModel *)model;

@end
