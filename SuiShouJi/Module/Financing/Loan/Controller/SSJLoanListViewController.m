//
//  SSJLoanListViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/8/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanListViewController.h"
#import "SSJAddOrEditLoanViewController.h"
#import "SCYSlidePagingHeaderView.h"
#import "SSJLoanListSectionHeaderAmountView.h"
#import "SSJLoanListCell.h"
#import "SSJLoanHelper.h"

static NSString *const kLoanListCellId = @"kLoanListCellId";

@interface SSJLoanListViewController () <UITableViewDataSource, UITableViewDelegate, SCYSlidePagingHeaderViewDelegate>

@property (nonatomic, strong) NSArray *list;

@property (nonatomic, strong) SCYSlidePagingHeaderView *headerSegmentView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIImageView *noDataRemindView;

@property (nonatomic, strong) SSJLoanListSectionHeaderAmountView *amountView;

@end

@implementation SSJLoanListViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _item.fundingName;
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tianjia"] style:UIBarButtonItemStylePlain target:self action:@selector(rightItemAction)];
    self.navigationItem.rightBarButtonItem = addItem;
    
    [self.view addSubview:self.headerSegmentView];
//    [self.view addSubview:self.amountView];
    [self.view addSubview:self.tableView];
    
    [self updateAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self isMovingToParentViewController]) {
        // 默认显示未结清的数据，如果没有未结清就显示全部的
        [self.view ssj_showLoadingIndicator];
        [SSJLoanHelper queryForLoanModelsWithFundID:_item.fundingID colseOutState:0 success:^(NSArray<SSJLoanModel *> * _Nonnull list) {
            if (list.count == 0) {
                [SSJLoanHelper queryForLoanModelsWithFundID:_item.fundingID colseOutState:2 success:^(NSArray<SSJLoanModel *> * _Nonnull list) {
                    [self.view ssj_hideLoadingIndicator];
                    self.list = list;
                    [self.tableView reloadData];
                    self.amountView.amount = [self.list valueForKeyPath:@"@sum.jMoney"];
                    if (list.count == 0) {
                        [self.view ssj_showWatermarkWithImageName:@"" animated:YES target:nil action:NULL];
                    } else {
                        [self.view ssj_hideWatermark:YES];
                    }
                } failure:^(NSError * _Nonnull error) {
                    [self.view ssj_hideLoadingIndicator];
                    [CDAutoHideMessageHUD showMessage:[error localizedDescription]];
                }];
            } else {
                [self.view ssj_hideLoadingIndicator];
                self.list = list;
                [self.tableView reloadData];
                self.amountView.amount = [self.list valueForKeyPath:@"@sum.jMoney"];
            }
        } failure:^(NSError * _Nonnull error) {
            [self.view ssj_hideLoadingIndicator];
            [CDAutoHideMessageHUD showMessage:[error localizedDescription]];
        }];
    } else {
        [self reloadDataAccordingToHeaderViewIndex];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _list.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJLoanListCell *cell = [tableView dequeueReusableCellWithIdentifier:kLoanListCellId forIndexPath:indexPath];
//    cell.cellItem =
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
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    [self reloadDataAccordingToHeaderViewIndex];
}

#pragma mark - Event
- (void)rightItemAction {
    SSJAddOrEditLoanViewController *addLoanVC = [[SSJAddOrEditLoanViewController alloc] init];
    [self.navigationController pushViewController:addLoanVC animated:YES];
}

#pragma mark - Private
- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    _headerSegmentView.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    _headerSegmentView.titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _headerSegmentView.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    [_headerSegmentView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    CGFloat alpha = [[SSJThemeSetting currentThemeModel].ID isEqualToString:SSJDefaultThemeID] ? 1 : 0.1;
    _tableView.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:alpha];
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    
    [_amountView updateAppearance];
}

- (void)reloadDataAccordingToHeaderViewIndex {
    [self.view ssj_showLoadingIndicator];
    [SSJLoanHelper queryForLoanModelsWithFundID:_item.fundingID colseOutState:(int)_headerSegmentView.selectedIndex success:^(NSArray<SSJLoanModel *> * _Nonnull list) {
        [self.view ssj_hideLoadingIndicator];
        self.list = list;
        [self.tableView reloadData];
        self.amountView.amount = [self.list valueForKeyPath:@"@sum.jMoney"];
    } failure:^(NSError * _Nonnull error) {
        [self.view ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:[error localizedDescription]];
    }];
}

#pragma mark - Getter
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
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.headerSegmentView.bottom, self.view.width, self.view.height - self.headerSegmentView.bottom) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_tableView setTableFooterView:[[UIView alloc] init]];
        [_tableView registerClass:[SSJLoanListCell class] forCellReuseIdentifier:kLoanListCellId];
        _tableView.rowHeight = 90;
    }
    return _tableView;
}

- (SSJLoanListSectionHeaderAmountView *)amountView {
    if (!_amountView) {
        _amountView = [[SSJLoanListSectionHeaderAmountView alloc] initWithFrame:CGRectMake(0, self.headerSegmentView.bottom, self.view.width, 40)];
        if ([_item.fundingParent isEqualToString:@"10"]) {
            _amountView.title = @"累计借出款";
        } else if ([_item.fundingParent isEqualToString:@"11"]) {
            _amountView.title = @"累计欠款";
        } else {
            SSJPRINT(@"警告：借贷父账户ID错误：_item.fundingParent，有效值只能为10、11");
        }
    }
    return _amountView;
}

@end
