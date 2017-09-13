//
//  SSJLoanListCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/8/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@class SSJLoanModel;
@class SSJFixedFinanceProductItem;

@interface SSJLoanListCellItem : SSJBaseCellItem

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, copy) NSString *loanTitle;

@property (nonatomic, copy) NSString *memo;

@property (nonatomic, copy) NSString *money;

@property (nonatomic, copy) NSString *date;

/**<#注释#>*/
@property (nonatomic, copy) NSString *descStr;

@property (nonatomic) BOOL showStamp;

/**<#注释#>*/
@property (nonatomic, assign) BOOL showStateL;

/**<#注释#>*/
@property (nonatomic, copy) NSString *imageName;

+ (instancetype)itemWithLoanModel:(SSJLoanModel *)model;

+ (instancetype)itemForFixedFinanceProductModel:(SSJFixedFinanceProductItem *)model;
@end
