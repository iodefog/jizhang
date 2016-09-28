//
//  SSJBudgetBillTypeSelectionViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/9/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetBillTypeSelectionViewController.h"
#import "SSJBudgetBillTypeSelectionCell.h"
#import "SSJBudgetDatabaseHelper.h"
#import "SSJBudgetModel.h"

static NSString *const kBudgetBillTypeSelectionCellId = @"kBudgetBillTypeSelectionCellId";

@interface SSJBudgetBillTypeSelectionViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *items;

@end

@implementation SSJBudgetBillTypeSelectionViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"选择类别";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view ssj_showLoadingIndicator];
    [SSJBudgetDatabaseHelper queryBudgetBillTypeSelectionItemListWithBudgetModel:_budgetModel success:^(NSArray<SSJBudgetBillTypeSelectionCellItem *> * _Nonnull list) {
        [self.view ssj_hideLoadingIndicator];
        self.items = list;
        [self.tableView reloadData];
        
        for (SSJBudgetBillTypeSelectionCellItem *item in list) {
            if (item.selected) {
                NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:[list indexOfObject:item] inSection:0];
                [self.tableView selectRowAtIndexPath:selectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
            }
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBudgetBillTypeSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:kBudgetBillTypeSelectionCellId forIndexPath:indexPath];
    cell.cellItem = [self.items ssj_safeObjectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SSJBudgetBillTypeSelectionCellItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    if (item.canSelect) {
        item.selected = YES;
        if (![_budgetModel.billIds containsObject:item.billID]) {
            NSMutableArray *tmpBillIds = [_budgetModel.billIds mutableCopy];
            [tmpBillIds addObject:item.billID];
            _budgetModel.billIds = [tmpBillIds copy];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBudgetBillTypeSelectionCellItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    if (item.canSelect) {
        item.selected = NO;
        if ([_budgetModel.billIds containsObject:item.billID]) {
            NSMutableArray *tmpBillIds = [_budgetModel.billIds mutableCopy];
            [tmpBillIds removeObject:item.billID];
            _budgetModel.billIds = [tmpBillIds copy];
        }
    }
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
        [_tableView registerClass:[SSJBudgetBillTypeSelectionCell class] forCellReuseIdentifier:kBudgetBillTypeSelectionCellId];
        _tableView.rowHeight = 54;
        _tableView.allowsMultipleSelection = YES;
    }
    return _tableView;
}

@end
