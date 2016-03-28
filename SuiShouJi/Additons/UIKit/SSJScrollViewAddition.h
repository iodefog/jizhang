//
//  SSJScrollViewAddition.h
//  MoneyMore
//
//  Created by old lang on 15-6-4.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (SSJCategory)

- (void)scrollSubview:(UIView *)view toContentPosition:(UITableViewScrollPosition)position animated:(BOOL)animated;

- (void)scrollSubview:(UIView *)view toContentPositionIfNeeded:(UITableViewScrollPosition)position animated:(BOOL)animated;

@end