//
//  SSJLoadMoreItem.h
//  MoneyMore
//
//  Created by old lang on 15-3-24.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@interface SSJLoadMoreItem : SSJBaseCellItem

@property (nonatomic, copy, readonly) NSString *loadingTitle;

+ (id)itemWithTitle:(NSString*)title;

@end
