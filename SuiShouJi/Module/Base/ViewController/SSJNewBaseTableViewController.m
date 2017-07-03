//
//  SSJNewBaseTableViewController.m
//  MoneyMore
//
//  Created by cdd on 15/10/9.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJNewBaseTableViewController.h"
#import "SRRefreshView.h"
#import "SSJLoadMoreCell.h"

@interface SSJNewBaseTableViewController ()<SRRefreshDelegate>

@property (nonatomic, assign) UITableViewStyle tableViewStyle;
@property (nonatomic, strong) SRRefreshView  *slimeView;//readwrite,

// tableview的初始内凹
@property (nonatomic) UIEdgeInsets originalContentInset;

// 是否正在刷新
@property (nonatomic) BOOL isRefreshing;

@end

@implementation SSJNewBaseTableViewController
@synthesize tableView=_tableView;

- (void)dealloc {
    [_slimeView removeFromSuperview];
    _tableView.delegate = nil;
    _tableView.dataSource=nil;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setUpInitWithTableViewStyle:UITableViewStylePlain];
    }
    return self;
}

- (instancetype)initWithTableViewStyle:(UITableViewStyle)tableViewStyle{
    self = [super init];
    if (self) {
        [self setUpInitWithTableViewStyle:tableViewStyle];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setUpInitWithTableViewStyle:UITableViewStylePlain];
    }
    return self;
}

- (void)setUpInitWithTableViewStyle:(UITableViewStyle)tableViewStyle{
    _tableViewStyle= tableViewStyle;
    self.showDragView = NO;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    if (self.showDragView) {
        [self.tableView addSubview:self.slimeView];
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        [self.slimeView update:64];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (UIEdgeInsetsEqualToEdgeInsets(self.originalContentInset, UIEdgeInsetsZero)) {
        self.originalContentInset = self.tableView.contentInset;
    }
}

- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:_tableViewStyle];
        _tableView.dataSource=self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        [_tableView ssj_clearExtendSeparator];
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    return _tableView;
}

- (SRRefreshView *)slimeView{
    if (_slimeView==nil) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor orangeColor];
        _slimeView.slime.skinColor = [UIColor whiteColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.activityIndicationView.color = [UIColor orangeColor];
        _slimeView.slime.viscous=50;
    }
    return _slimeView;
}

#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.showDragView) {
        [self.slimeView scrollViewDidScroll];
        
//        * 解决在有sectionHeaderView的情况下，下拉刷新控件没有使sectionHeaderView置于最顶部的问题 *
        if (self.isRefreshing) {
            
            CGRect insetRect = UIEdgeInsetsInsetRect(self.tableView.bounds, self.tableView.contentInset);
            if (self.tableView.contentSize.height < CGRectGetHeight(insetRect)) {
                return;
            }
            
            if (self.tableView.contentOffset.y >= -(32 + self.originalContentInset.top)
                && self.tableView.contentOffset.y < 0) {
                // 在下拉刷新后的内凹范围内滚动
                // 注意:修改scrollView.contentInset时，若使当前界面显示位置发生变化，会触发scrollViewDidScroll:，从而导致死循环
                // 因此此处scrollView.contentInset.top必须为-scrollView.contentOffset.y
                UIEdgeInsets newContentInset = self.originalContentInset;
                newContentInset.top = -self.tableView.contentOffset.y;
                self.tableView.contentInset = newContentInset;
                return;
            }
            
            
            if (self.tableView.contentOffset.y >= -self.originalContentInset.top) {
                // headerView已经在tableView最上方，把顶部内凹设置回原始值
                self.tableView.contentInset = self.originalContentInset;
                return;
            }
            
        } else {
            if (self.tableView.tracking
                || self.tableView.dragging
                || self.tableView.decelerating) {
                
                if (self.tableView.contentOffset.y >= -self.originalContentInset.top) {
                    self.tableView.contentInset = self.originalContentInset;
                }
            }
        }
        
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.showDragView) {
        [self.slimeView scrollViewDidEndDraging];
    }
}

#pragma mark - slimeRefresh delegate
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView{
    self.isRefreshing = YES;
    [self startPullRefresh];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [[UITableViewCell alloc]init];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[SSJLoadMoreCell class]]) {
        [self startLoadMore];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48.0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    [super serverDidFinished:service];
    self.isRefreshing = NO;
    if (self.showDragView) {
        [self.slimeView endRefresh];
    }
}

- (void)serverDidCancel:(SSJBaseNetworkService *)service {
    [super serverDidCancel:service];
    self.isRefreshing = NO;
    if (self.showDragView) {
        [self.slimeView endRefresh];
    }
}

- (void)server:(SSJBaseNetworkService *)service didFailLoadWithError:(NSError*)error {
    [super server:service didFailLoadWithError:error];
    self.isRefreshing = NO;
    if (self.showDragView) {
        [self.slimeView endRefresh];
    }
}

- (void)updateRefreshViewTopInset:(CGFloat)topInset{
    [self.slimeView update:topInset];
}

#pragma mark - Public
- (void)startPullRefresh {
    
}

- (void)startLoadMore {
}

@end
