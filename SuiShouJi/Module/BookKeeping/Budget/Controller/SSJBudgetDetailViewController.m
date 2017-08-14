//
//  SSJBudgetDetailViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetDetailViewController.h"
#import "SSJBudgetEditViewController.h"
#import "SSJBillingChargeViewController.h"
#import "SSJBudgetDetailPeriodSwitchControl.h"
#import "SSJBudgetDetailHeaderView.h"
#import "SSJBudgetDetailMiddleTitleView.h"
#import "SSJBorderButton.h"
#import "SSJPercentCircleView.h"
#import "SSJBudgetNodataRemindView.h"
#import "SSJReportFormsIncomeAndPayCell.h"
#import "SSJBudgetDatabaseHelper.h"
#import "SSJReportFormsItem.h"
#import "SSJDatePeriod.h"

static NSString *const kDateFomat = @"yyyy-MM-dd";

static NSString *const kIncomeAndPayCellID = @"incomeAndPayCellID";

@interface SSJBudgetDetailViewController () <UITableViewDataSource, UITableViewDelegate>

//  导航栏标题视图
@property (nonatomic, strong) SSJBudgetDetailPeriodSwitchControl *titleView;

//  包含本月预算、距结算日、已花、超支、波浪图表的视图
@property (nonatomic, strong) SSJBudgetDetailHeaderView *headerView;

@property (nonatomic, strong) UITableView *tableView;

//  没有消费记录的提示视图
@property (nonatomic, strong) SSJBudgetNodataRemindView *noDataRemindView;

@property (nonatomic, strong) UIBarButtonItem *editItem;

//  预算数据模型
@property (nonatomic, strong) SSJBudgetModel *budgetModel;

@property (nonatomic, strong) SSJBudgetDetailHeaderViewItem *headerItem;

@property (nonatomic, strong) NSArray *cellItems;

@property (nonatomic, strong) NSArray *budgetIDs;

@property (nonatomic, strong) NSArray *budgetPeriods;

//  周期类型
//@property (nonatomic) SSJBudgetPeriodType periodType;

@end

@implementation SSJBudgetDetailViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = self.titleView;
    self.navigationItem.rightBarButtonItem = self.editItem;
    [self.view addSubview:self.tableView];
//    self.tableView.tableHeaderView = self.headerView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadAllData];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self.titleView updateAppearance];
    [self.headerView updateAppearance];
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJReportFormsIncomeAndPayCell *incomeAndPayCell = [tableView dequeueReusableCellWithIdentifier:kIncomeAndPayCellID forIndexPath:indexPath];
    incomeAndPayCell.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    [incomeAndPayCell setCellItem:[self.cellItems ssj_safeObjectAtIndex:indexPath.row]];
    return incomeAndPayCell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.cellItems.count > indexPath.row) {
        SSJReportFormsItem *item = self.cellItems[indexPath.row];
        NSDate *beginDate = [NSDate dateWithString:_budgetModel.beginDate formatString:@"yyyy-MM-dd"];
        NSDate *endDate = [NSDate dateWithString:_budgetModel.endDate formatString:@"yyyy-MM-dd"];
        
        SSJBillingChargeViewController *billingChargeVC = [[SSJBillingChargeViewController alloc] init];
        billingChargeVC.billId = item.ID;
        billingChargeVC.period = [SSJDatePeriod datePeriodWithStartDate:beginDate endDate:endDate];
        [self.navigationController pushViewController:billingChargeVC animated:YES];
    }
}

#pragma mark - Event
- (void)editButtonAction {
    SSJBudgetEditViewController *budgetEditVC = [[SSJBudgetEditViewController alloc] init];
    budgetEditVC.isEdit = YES;
    budgetEditVC.model = self.budgetModel;
    [self.navigationController pushViewController:budgetEditVC animated:YES];
}

- (void)changeSelectedMonth {
    NSString *budgetId = [self.budgetIDs ssj_safeObjectAtIndex:self.titleView.selectedIndex];
    if (!budgetId.length) {
        self.budgetModel = nil;
        [self updateView];
        return;
    }
    
    UIBarButtonItem *item = [budgetId isEqualToString:_budgetId] ? self.editItem : nil;
    [self.navigationItem setRightBarButtonItem:item animated:YES];
    
    [self.view ssj_showLoadingIndicator];
    [SSJBudgetDatabaseHelper queryForBudgetDetailWithID:budgetId success:^(NSDictionary * _Nonnull result) {
        [self.view ssj_hideLoadingIndicator];
        self.budgetModel = result[SSJBudgetModelKey];
        self.headerItem = result[SSJBudgetDetailHeaderViewItemKey];
        self.cellItems = result[SSJBudgetListCellItemKey];
        [self updateView];
    } failure:^(NSError * _Nullable error) {
        [self.view ssj_hideLoadingIndicator];
        SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:SSJ_ERROR_MESSAGE action:action, nil];
    }];
}

#pragma mark - Private
- (void)updateTitle {
    switch (self.budgetModel.type) {
        case SSJBudgetPeriodTypeWeek:
        case SSJBudgetPeriodTypeMonth:
            self.titleView.titleSize = 21;
            break;
            
        case SSJBudgetPeriodTypeYear:
            self.titleView.titleSize = 13;
            break;
    }
    
    self.titleView.titles = self.budgetPeriods;
    self.titleView.selectedIndex = self.titleView.titles.count - 1;
}

- (void)loadAllData {
    [self.view ssj_showLoadingIndicator];
    [SSJBudgetDatabaseHelper queryForBudgetDetailWithID:self.budgetId success:^(NSDictionary * _Nonnull result) {
        
        self.budgetModel = result[SSJBudgetModelKey];
        self.headerItem = result[SSJBudgetDetailHeaderViewItemKey];
        self.cellItems = result[SSJBudgetListCellItemKey];
        
        [SSJBudgetDatabaseHelper queryForBudgetIdListWithType:self.budgetModel.type billIds:self.budgetModel.billIds success:^(NSDictionary * _Nonnull result) {
            [self.view ssj_hideLoadingIndicator];
            
            self.budgetIDs = result[SSJBudgetIDKey];
            self.budgetPeriods = result[SSJBudgetPeriodKey];
            
            if (![self.budgetIDs containsObject:self.budgetId]) {
                SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
                [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:SSJ_ERROR_MESSAGE action:action, nil];
                return;
            }
            
            [self updateTitle];
            [self updateView];
        } failure:^(NSError * _Nonnull error) {
            [self.view ssj_hideLoadingIndicator];
            SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
            [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:SSJ_ERROR_MESSAGE action:action, nil];
        }];
        
        if (![self.budgetModel.billIds containsObject:SSJAllBillTypeId]) {
            [SSJAnaliyticsManager event:@"budget_part_detail"];
        }
        
    } failure:^(NSError * _Nullable error) {
        
        [self.view ssj_hideLoadingIndicator];
        SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:SSJ_ERROR_MESSAGE action:action, nil];
        
    }];
}

- (void)updateView {
    NSString *tStr = nil;
    switch (self.budgetModel.type) {
        case 0:
            tStr = @"周";
            break;
            
        case 1:
            tStr = @"月";
            break;
            
        case 2:
            tStr = @"年";
            break;
    }
    
    if (!self.budgetModel) {
        self.tableView.hidden = YES;
        self.noDataRemindView.title = [NSString stringWithFormat:@"您在这个%@没有设置预算哦", tStr];
        [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
        return;
    }
    
    self.tableView.hidden = NO;
    [self.tableView reloadData];
    self.headerView.item = self.headerItem;
    self.tableView.tableHeaderView = nil;
    self.tableView.tableHeaderView = self.headerView;
}

#pragma mark - Getter
- (SSJBudgetDetailPeriodSwitchControl *)titleView {
    if (!_titleView) {
        _titleView = [[SSJBudgetDetailPeriodSwitchControl alloc] init];
        [_titleView addTarget:self action:@selector(changeSelectedMonth) forControlEvents:UIControlEventValueChanged];
    }
    return _titleView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 54;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView registerClass:[SSJReportFormsIncomeAndPayCell class] forCellReuseIdentifier:kIncomeAndPayCellID];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    }
    return _tableView;
}

- (SSJBudgetDetailHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[SSJBudgetDetailHeaderView alloc] init];
    }
    return _headerView;
}

- (UIBarButtonItem *)editItem {
    if (!_editItem) {
        _editItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonAction)];
    }
    return _editItem;
}

- (SSJBudgetNodataRemindView *)noDataRemindView {
    if (!_noDataRemindView) {
        _noDataRemindView = [[SSJBudgetNodataRemindView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 260)];
        _noDataRemindView.image = @"budget_no_data";
    }
    return _noDataRemindView;
}

@end
