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
#import "SSJBudgetListSecondaryCell.h"
#import "SSJBudgetDatabaseHelper.h"

static NSString *const kBudgetListCellId = @"kBudgetListCellId";
static NSString *const kBudgetListSecondaryCellId = @"kBudgetListSecondaryCellId";

@interface SSJBudgetListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataList;

@property (nonatomic, strong) NSDictionary *billTypeMapping;

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view ssj_showLoadingIndicator];
    
    [SSJBudgetDatabaseHelper queryForCurrentBudgetListWithSuccess:^(NSArray<SSJBudgetModel *> * _Nonnull result) {
        [SSJBudgetDatabaseHelper queryBillTypeMapWithSuccess:^(NSDictionary * _Nonnull billTypeMap) {
            [self.view ssj_hideLoadingIndicator];
            self.billTypeMapping = billTypeMap;
            self.dataList = result;
            [self.tableView reloadData];
        } failure:^(NSError * _Nonnull error) {
            [self.view ssj_hideLoadingIndicator];
            SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
            [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:[error localizedDescription] action:action, nil];
        }];
    } failure:^(NSError * _Nullable error) {
        [self.view ssj_hideLoadingIndicator];
        SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:[error localizedDescription] action:action, nil];
    }];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBudgetModel *model = [self.dataList ssj_safeObjectAtIndex:indexPath.section];
    if ([model.billIds isEqualToArray:@[@"all"]]) {
        SSJBudgetListCell *cell = [tableView dequeueReusableCellWithIdentifier:kBudgetListCellId forIndexPath:indexPath];
        SSJBudgetListCellItem *cellItem = [self convertCellItemFromModel:[self.dataList ssj_safeObjectAtIndex:indexPath.section]];
        [cell setCellItem:cellItem];
        return cell;
    } else {
        SSJBudgetListSecondaryCell *cell = [tableView dequeueReusableCellWithIdentifier:kBudgetListSecondaryCellId forIndexPath:indexPath];
        SSJBudgetListCellItem *cellItem = [self convertCellItemFromModel:[self.dataList ssj_safeObjectAtIndex:indexPath.section]];
        [cell setCellItem:cellItem];
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

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
    cellItem.typeName = [self typeNameWithModel:model];
    cellItem.period = [NSString stringWithFormat:@"%@——%@", model.beginDate, model.endDate];
    cellItem.payment = model.payMoney;
    cellItem.budget = model.budgetMoney;
    return cellItem;
}

- (NSString *)typeNameWithModel:(SSJBudgetModel *)model {
    NSMutableString *name = [NSMutableString string];
    switch (model.type) {
        case 0:
            [name appendString:@"周"];
            break;
            
        case 1:
            [name appendString:@"月"];
            break;
            
        case 2:
            [name appendString:@"年"];
            break;
    }
    
    if ([[model.billIds firstObject] isEqualToString:@"all"]) {
        [name appendString:@"总预算"];
    } else {
        NSMutableArray *billTypeNames = [NSMutableArray array];
        for (int i = 0; i < model.billIds.count; i ++) {
            if (i < 4) {
                NSString *billID = model.billIds[i];
                if (billID) {
                    [billTypeNames addObject:self.billTypeMapping[billID]];
                }
            }
        }
        
        [name appendString:@"分类预算："];
        [name appendString:[billTypeNames componentsJoinedByString:@","]];
        if (model.billIds.count > 4) {
            [name appendString:@"等"];
        }
    }
    
    return name;
}

- (void)setupAddBarButtonItem {
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"budget_add"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewBudgetAction)];
    self.navigationItem.rightBarButtonItem = addItem;
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_tableView setTableFooterView:[[UIView alloc] init]];
        [_tableView registerClass:[SSJBudgetListCell class] forCellReuseIdentifier:kBudgetListCellId];
        [_tableView registerClass:[SSJBudgetListSecondaryCell class] forCellReuseIdentifier:kBudgetListSecondaryCellId];
        _tableView.rowHeight = 314;
    }
    return _tableView;
}

@end
