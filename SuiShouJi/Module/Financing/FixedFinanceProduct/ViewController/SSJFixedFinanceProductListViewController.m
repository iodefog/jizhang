//
//  SSJFixedFinanceProductViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanceProductListViewController.h"

#import "SCYSlidePagingHeaderView.h"
#import "SSJBudgetNodataRemindView.h"
#import "SSJLoanListSectionHeaderAmountView.h"

#import "SSJFixedFinancePrductListTableViewCell.h"

#import "SSJFixedFinanceProductStore.h"
#import "SSJFixedFinanceProductItem.h"

@interface SSJFixedFinanceProductListViewController ()<UITableViewDataSource, UITableViewDelegate,SCYSlidePagingHeaderViewDelegate>

@property (nonatomic, strong) SCYSlidePagingHeaderView *headerSegmentView;

@property (nonatomic, strong) SSJBudgetNodataRemindView *noDataRemindView;

@property (nonatomic, strong) SSJLoanListSectionHeaderAmountView *amountView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIBarButtonItem *addItem;

@property (nonatomic, strong) NSArray<SSJFixedFinanceProductItem *> *dataItems;
@end

@implementation SSJFixedFinanceProductListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.headerSegmentView];
    [self.view addSubview:self.tableView];
    [self setUpNav];
    [self updateAppearance];
}

#pragma mark - Private
- (void)setUpNav {
    self.title = @"固收理财";
    [self.navigationItem setRightBarButtonItem:self.addItem animated:YES];
}

- (void)reloadDataAccordingToHeaderViewIndex {
    [self.view ssj_showLoadingIndicator];
    [SSJFixedFinanceProductStore queryFixedFinanceProductWithFundID:self.item.productid Type:(int)_headerSegmentView.selectedIndex success:^(NSArray<SSJFixedFinanceProductItem *> * _Nonnull resultList) {
        [self.view ssj_hideLoadingIndicator];
        self.dataItems = resultList;
        [self.tableView reloadData];
        if (self.dataItems.count == 0) {
            [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
        } else {
            [self.view ssj_hideWatermark:YES];
        }

    } failure:^(NSError * _Nonnull error) {
        [self.view ssj_hideLoadingIndicator];
    }];
}

#pragma mark - Action
- (void)addItemAction {

}

#pragma mark - Theme
- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.dataItems ssj_safeObjectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJFixedFinancePrductListTableViewCell *cell = [SSJFixedFinancePrductListTableViewCell cellWithTableView:tableView];
    cell.cellItem = [self.dataItems ssj_objectAtIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 40;
    } else {
        return 10;
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.amountView;
    } else {
        return [[UIView alloc] init];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SSJFixedFinanceProductItem *model = [self.dataItems ssj_safeObjectAtIndex:indexPath.section];
//    [SSJLoanHelper queryForFundColorWithID:model.fundID completion:^(NSString * _Nonnull color) {
//        SSJLoanDetailViewController *loanDetailVC = [[SSJLoanDetailViewController alloc] init];
//        loanDetailVC.loanID = model.ID;
//        loanDetailVC.fundColor = color;
//        [self.navigationController pushViewController:loanDetailVC animated:YES];
//    }];
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    [self reloadDataAccordingToHeaderViewIndex];
    
    if (index == 0) {
        
    } else if (index == 1) {
        
    } else if (index == 2) {
    }

}


#pragma mark - Lazy
- (SCYSlidePagingHeaderView *)headerSegmentView {
    if (!_headerSegmentView) {
        _headerSegmentView = [[SCYSlidePagingHeaderView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, 36)];
        _headerSegmentView.customDelegate = self;
        _headerSegmentView.buttonClickAnimated = YES;
        _headerSegmentView.titles = @[@"未结清", @"已结清", @"全部"];
        [_headerSegmentView setTabSize:CGSizeMake(_headerSegmentView.width / _headerSegmentView.titles.count, 3)];
        [_headerSegmentView ssj_setBorderWidth:1];
        [_headerSegmentView ssj_setBorderStyle:(SSJBorderStyleTop | SSJBorderStyleBottom)];
    }
    return _headerSegmentView;
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        _tableView.sectionFooterHeight = 0;
        _tableView.rowHeight = 54;
//        [_tableView registerClass:[SSJLoanDetailCell class] forCellReuseIdentifier:kSSJLoanDetailCellID];
    }
    return _tableView;
}

- (SSJLoanListSectionHeaderAmountView *)amountView {
    if (!_amountView) {
        _amountView = [[SSJLoanListSectionHeaderAmountView alloc] initWithFrame:CGRectMake(0, self.headerSegmentView.bottom, self.view.width, 40)];
            _amountView.title = @"累计理财";
    }
    return _amountView;
}

- (SSJBudgetNodataRemindView *)noDataRemindView {
    if (!_noDataRemindView) {
        _noDataRemindView = [[SSJBudgetNodataRemindView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 260)];
        _noDataRemindView.image = @"loan_noDataRemind";
        _noDataRemindView.title = @"暂无记录哦";
    }
    return _noDataRemindView;
}

- (UIBarButtonItem *)addItem {
    if (!_addItem) {
        _addItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add"] style:UIBarButtonItemStylePlain target:self action:@selector(addItemAction)];
    }
    return _addItem;
}

- (NSArray<SSJFixedFinanceProductItem *> *)dataItems {
    if (!_dataItems) {
        _dataItems = [NSArray array];
    }
    return _dataItems;
}

@end
