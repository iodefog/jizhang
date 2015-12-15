//
//  SSJTableView.m
//  SuiShouJi
//
//  Created by old lang on 15/10/26.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJTableView.h"

@implementation UITableView (SSJCategory)

- (void)ssj_clearExtendSeparator {
    if (!self.tableFooterView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor clearColor];
        [self setTableFooterView:view];
    }
}

@end
