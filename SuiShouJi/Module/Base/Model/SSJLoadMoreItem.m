//
//  SSJLoadMoreItem.m
//  MoneyMore
//
//  Created by old lang on 15-3-24.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJLoadMoreItem.h"

@interface SSJLoadMoreItem ()

@property (nonatomic, copy) NSString *loadingTitle;

@end

@implementation SSJLoadMoreItem

+ (id)itemWithTitle:(NSString *)title {
    SSJLoadMoreItem *item = [[self alloc] init];
    item.loadingTitle = title;
    return item;
}

@end
