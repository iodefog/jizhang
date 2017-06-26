//
//  SSJFundingTransferDetailViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/5/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingTransferListViewController.h"
#import "SSJFundingTransferStore.h"
#import "SSJFundingTransferDetailCell.h"
#import "SSJFundingTransferDetailItem.h"
#import "SSJTransferDetailHeader.h"
#import "SCYSlidePagingHeaderView.h"
#import "SCYSlidePagingHeaderView+SSJTheme.h"
#import "SSJFundingTransferListPeriodCell.h"
#import "SSJFundingTransferViewController.h"
#import "SSJFundingTransferChargeDetailViewController.h"

static NSString * SSJTransferDetailCellIdentifier = @"transferDetailCell";
static NSString * SSJTransferPeriodCellIdentifier = @"SSJTransferPeriodCellIdentifier";

static NSString *const kNormalTransferTitle = @"转账流水";
static NSString *const kPeriodTransferTitle = @"周期转账";


@interface SSJFundingTransferListViewController () <SCYSlidePagingHeaderViewDelegate>

@property (nonatomic, strong) NSArray *datas;

@property (nonatomic, strong) SCYSlidePagingHeaderView *segmentHeaderCtrl;

@end

@implementation SSJFundingTransferListViewController
#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"转账记录";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.segmentHeaderCtrl];
    self.tableView.top = self.segmentHeaderCtrl.bottom;
    self.tableView.height = self.view.height - self.tableView.top;
    [self.tableView registerClass:[SSJFundingTransferDetailCell class] forCellReuseIdentifier:SSJTransferDetailCellIdentifier];
    [self.tableView registerClass:[SSJFundingTransferListPeriodCell class] forCellReuseIdentifier:SSJTransferPeriodCellIdentifier];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadDataAccordingToCurrentIndex];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self.segmentHeaderCtrl updateAppearanceAccordingToTheme];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectZero];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *monthInfo = [self.datas ssj_safeObjectAtIndex:indexPath.section];
    NSArray *items = [monthInfo objectForKey:SSJFundingTransferStoreListKey];
    SSJFundingTransferDetailItem *item = [items ssj_safeObjectAtIndex:indexPath.row];
    
    NSString *selectedTitle = [_segmentHeaderCtrl.titles ssj_safeObjectAtIndex:_segmentHeaderCtrl.selectedIndex];
    if ([selectedTitle isEqualToString:kNormalTransferTitle]) {
        SSJFundingTransferChargeDetailViewController *transferVC = [[SSJFundingTransferChargeDetailViewController alloc] init];
        transferVC.item = item;
        [self.navigationController pushViewController:transferVC animated:YES];
    } else if ([selectedTitle isEqualToString:kPeriodTransferTitle]) {
        SSJFundingTransferViewController *periodTransferVC = [[SSJFundingTransferViewController alloc] init];
        periodTransferVC.item = item;
        [self.navigationController pushViewController:periodTransferVC animated:YES];
        [SSJAnaliyticsManager event:@"auto_transfer_detail"];
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *monthInfo = [self.datas ssj_safeObjectAtIndex:section];
    NSArray *items = [monthInfo objectForKey:SSJFundingTransferStoreListKey];
    return items.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *monthInfo = [self.datas ssj_safeObjectAtIndex:indexPath.section];
    NSArray *items = [monthInfo objectForKey:SSJFundingTransferStoreListKey];
    SSJFundingTransferDetailItem *item = [items ssj_safeObjectAtIndex:indexPath.row];
    
    NSString *selectedTitle = [_segmentHeaderCtrl.titles ssj_safeObjectAtIndex:_segmentHeaderCtrl.selectedIndex];
    if ([selectedTitle isEqualToString:kNormalTransferTitle]) {
        SSJFundingTransferDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:SSJTransferDetailCellIdentifier forIndexPath:indexPath];
        cell.item = item;
        return cell;
    } else if ([selectedTitle isEqualToString:kPeriodTransferTitle]) {
        SSJFundingTransferListPeriodCell *periodCell = [tableView dequeueReusableCellWithIdentifier:SSJTransferPeriodCellIdentifier forIndexPath:indexPath];
        periodCell.cellItem = [SSJFundingTransferListPeriodCellItem cellItemWithTransferDetailItem:item];
        periodCell.switchCtrlAction = ^(BOOL opened, SSJFundingTransferListPeriodCell *cell) {
            SSJFundingTransferListPeriodCellItem *periodItem = cell.cellItem;
            [SSJFundingTransferStore updateCycleTransferRecordStateWithID:periodItem.transferId opened:opened success:NULL failure:NULL];
        };
        return periodCell;
    } else {
        return [UITableViewCell new];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSDictionary *monthInfo = [self.datas ssj_safeObjectAtIndex:section];
    SSJTransferDetailHeader *header = [[SSJTransferDetailHeader alloc] init];
    header.date = [monthInfo objectForKey:SSJFundingTransferStoreMonthKey];
    return header;
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    [self loadDataAccordingToCurrentIndex];
    if (index == 1) {
        [SSJAnaliyticsManager event:@"transfer_record_cycle"];
    }
}

#pragma mark - Private
- (void)loadDataAccordingToCurrentIndex {
    if (!_datas.count) {
        [self.view ssj_showLoadingIndicator];
    }
    
    NSString *selectedTitle = [_segmentHeaderCtrl.titles ssj_safeObjectAtIndex:_segmentHeaderCtrl.selectedIndex];
    if ([selectedTitle isEqualToString:kNormalTransferTitle]) {
        [SSJFundingTransferStore queryForFundingTransferListWithSuccess:^(NSArray<NSDictionary *> * _Nonnull result) {
            _datas = result;
            [self.tableView reloadData];
            [self.view ssj_hideLoadingIndicator];
            if (result.count) {
                [self.view ssj_hideWatermark:YES];
            } else {
                [self.view ssj_showWatermarkWithImageName:@"founds_transfer_none" animated:NO target:self action:NULL];
            }
        } failure:NULL];
    } else if ([selectedTitle isEqualToString:kPeriodTransferTitle]) {
        [SSJFundingTransferStore queryCycleTransferRecordsListWithSuccess:^(NSArray<NSDictionary *> * _Nonnull result) {
            _datas = result;
            [self.tableView reloadData];
            [self.view ssj_hideLoadingIndicator];
            if (result.count) {
                [self.view ssj_hideWatermark:YES];
            } else {
                [self.view ssj_showWatermarkWithImageName:@"founds_transfer_none" animated:NO target:self action:NULL];
            }
        } failure:NULL];
    } else {
        SSJPRINT(@"未定义控件下标触发的行为");
    }
}

#pragma mark - LazyLoading
- (SCYSlidePagingHeaderView *)segmentHeaderCtrl {
    if (!_segmentHeaderCtrl) {
        _segmentHeaderCtrl = [[SCYSlidePagingHeaderView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, 36)];
        _segmentHeaderCtrl.customDelegate = self;
        _segmentHeaderCtrl.buttonClickAnimated = YES;
        _segmentHeaderCtrl.titles = @[kNormalTransferTitle, kPeriodTransferTitle];
        [_segmentHeaderCtrl setTabSize:CGSizeMake(_segmentHeaderCtrl.width * 0.5, 3)];
        [_segmentHeaderCtrl ssj_setBorderWidth:1];
        [_segmentHeaderCtrl ssj_setBorderStyle:SSJBorderStyleBottom];
        [_segmentHeaderCtrl updateAppearanceAccordingToTheme];
    }
    return _segmentHeaderCtrl;
}

@end
