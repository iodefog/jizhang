//
//  SSJNewBaseTableViewController.h
//  MoneyMore
//
//  Created by cdd on 15/10/9.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

@class SRRefreshView;

@interface SSJNewBaseTableViewController : SSJBaseViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (readonly, nonatomic, strong) SRRefreshView  *slimeView;

@property (nonatomic, assign) BOOL showDragView;  //是否显示下拉加载(默认YES)

- (void)updateRefreshViewTopInset:(CGFloat)topInset;

- (instancetype)initWithTableViewStyle:(UITableViewStyle)tableViewStyle;

/**
 *  开始下拉刷新，需要子类覆写
 */
- (void)startPullRefresh;

/**
 *  开始加载更多，需要子类覆写
 */
- (void)startLoadMore;

@end
