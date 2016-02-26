//
//  SSJBudgetListViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetListViewController.h"
#import "SSJBudgetEditViewController.h"
#import "SSJBudgetDetailViewController.h"
#import "SSJBudgetListCell.h"
#import "SSJBudgetDatabaseHelper.h"

static NSString *const kBudgetListCellId = @"kBudgetListCellId";

@interface SSJBudgetListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataList;

@end

@implementation SSJBudgetListViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.navigationItem.title = @"预算";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAddBarButtonItem];
    [self.view addSubview:self.tableView];
    
    [SSJBudgetDatabaseHelper supplementBudgetRecordWithSuccess:^{
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view ssj_showLoadingIndicator];
    
    [SSJBudgetDatabaseHelper queryForCurrentBudgetListWithSuccess:^(NSArray<SSJBudgetModel *> * _Nonnull result) {
        [self.view ssj_hideLoadingIndicator];
        self.dataList = result;
        [self.tableView reloadData];
    } failure:^(NSError * _Nullable error) {
        [self.view ssj_hideLoadingIndicator];
        SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:SSJ_ERROR_MESSAGE action:action, nil];
    }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBudgetListCell *cell = [tableView dequeueReusableCellWithIdentifier:kBudgetListCellId forIndexPath:indexPath];
    SSJBudgetListCellItem *cellItem = [self convertCellItemFromModel:[self.dataList ssj_safeObjectAtIndex:indexPath.section]];
    [cell setCellItem:cellItem];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SSJBudgetDetailViewController *detailVC = [[SSJBudgetDetailViewController alloc] init];
    SSJBudgetModel *model = [self.dataList ssj_safeObjectAtIndex:indexPath.section];
    detailVC.budgetId = model.ID;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - Event
- (void)addNewBudgetAction {
    SSJBudgetEditViewController *newBudgetVC = [[SSJBudgetEditViewController alloc] init];
    [self.navigationController pushViewController:newBudgetVC animated:YES];
}

#pragma mark - Private
- (SSJBudgetListCellItem *)convertCellItemFromModel:(SSJBudgetModel *)model {
    SSJBudgetListCellItem *cellItem = [[SSJBudgetListCellItem alloc] init];
    switch (model.type) {
        case 0:
            cellItem.typeName = @"周预算";
            break;
            
        case 1:
            cellItem.typeName = @"月预算";
            break;
            
        case 2:
            cellItem.typeName = @"年预算";
            break;
    }
    cellItem.beginDate = [model.beginDate ssj_dateStringFromFormat:@"yyyy-MM-dd" toFormat:@"yyyy年mm月dd日"];
    cellItem.payment = model.payMoney;
    cellItem.budget = model.budgetMoney;
    return cellItem;
}

- (void)setupAddBarButtonItem {
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(addNewBudgetAction)];
    self.navigationItem.rightBarButtonItem = addItem;
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
        _tableView.separatorColor = SSJ_DEFAULT_SEPARATOR_COLOR;
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_tableView setTableFooterView:[[UIView alloc] init]];
        [_tableView registerClass:[SSJBudgetListCell class] forCellReuseIdentifier:kBudgetListCellId];
        _tableView.rowHeight = 100;
        _tableView.sectionHeaderHeight = 10;
    }
    return _tableView;
}

@end
