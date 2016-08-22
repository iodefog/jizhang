//
//  SSJLoanListCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/8/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@class SSJLoanModel;

@interface SSJLoanListCellItem : SSJBaseItem

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, copy) NSString *loanTitle;

@property (nonatomic, copy) NSString *memo;

@property (nonatomic, copy) NSString *money;

@property (nonatomic, copy) NSString *date;

@property (nonatomic) BOOL showStamp;

+ (instancetype)itemWithLoanModel:(SSJLoanModel *)model;

@end
