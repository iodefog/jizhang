//
//  SSJBudgetBillTypeSelectionViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/9/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetBillTypeSelectionViewController.h"
#import "SSJADDNewTypeViewController.h"
#import "SSJBudgetBillTypeSelectionCell.h"
#import "SSJBudgetDatabaseHelper.h"
#import "SSJBudgetModel.h"

static NSString *const kBudgetBillTypeSelectionCellId = @"kBudgetBillTypeSelectionCellId";

@interface SSJBudgetBillTypeSelectionViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, copy) NSArray *originalBillIds;

@end

@implementation SSJBudgetBillTypeSelectionViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"选择类别";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    
    if (_edited) {
        self.originalBillIds = self.budgetModel.billIds;
    }
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
//                [self.tableView selectRowAtIndexPath:selectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
                [self.tableView scrollToRowAtIndexPath:selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                break;
            }
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
}

- (void)goBackAction {
    if (_budgetModel.billIds.count == 0) {
        [CDAutoHideMessageHUD showMessage:@"至少选择一个类别"];
        return;
    }
    
    if (self.originalBillIds && ![self.originalBillIds isEqualToArray:self.budgetModel.billIds]) {
        [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"更改类别后，该预算的历史预算数据将清除重置哦" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:^(SSJAlertViewAction * _Nonnull action) {
            self.budgetModel.billIds = self.originalBillIds;
            BOOL allSelect = [self.budgetModel.billIds isEqualToArray:@[@"all"]];
            for (SSJBudgetBillTypeSelectionCellItem *item in self.items) {
                if (allSelect) {
                    item.selected = YES;
                } else {
                    item.selected = [self.budgetModel.billIds containsObject:item.billID];
                }
            }
            [self.tableView reloadData];
        }], [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction * _Nonnull action) {
            [super goBackAction];
        }], nil];
    } else {
        [super goBackAction];
    }
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
    
    SSJBudgetBillTypeSelectionCellItem *selectedItem = [self.items ssj_safeObjectAtIndex:indexPath.row];
    if (selectedItem.canSelect) {
        
        selectedItem.selected = !selectedItem.selected;
        
        if ([selectedItem.billID isEqualToString:@"all"]) {
            for (SSJBudgetBillTypeSelectionCellItem *item in self.items) {
                if (item.canSelect) {
                    item.selected = selectedItem.selected;
                }
            }
        } else {
            if (selectedItem.selected) {
                BOOL isSelectedAll = YES;
                for (SSJBudgetBillTypeSelectionCellItem *item in self.items) {
                    if ([item.billID isEqualToString:@"all"] || !item.canSelect) {
                        continue;
                    }
                    
                    if (!item.selected) {
                        isSelectedAll = NO;
                        break;
                    }
                }
                
                if (isSelectedAll) {
                    SSJBudgetBillTypeSelectionCellItem *allItem = [self.items firstObject];
                    allItem.selected = YES;
                }
                
            } else {
                SSJBudgetBillTypeSelectionCellItem *allItem = [self.items firstObject];
                allItem.selected = NO;
            }
        }
        
        [self updateSelectedBillIds];
        
    } else {
        // 添加类别
        __weak typeof(self) wself = self;
        SSJADDNewTypeViewController *addNewTypeVc = [[SSJADDNewTypeViewController alloc] init];
        addNewTypeVc.incomeOrExpence = 1;
        addNewTypeVc.addNewCategoryAction = ^(NSString *categoryId, BOOL incomeOrExpence){
            if (incomeOrExpence) {
                NSMutableArray *tmpBillIds = [wself.budgetModel.billIds mutableCopy];
                [tmpBillIds addObject:categoryId];
                wself.budgetModel.billIds = tmpBillIds;
            }
        };
        [self.navigationController pushViewController:addNewTypeVc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
//    SSJBudgetBillTypeSelectionCellItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
//    if (item.canSelect) {
//        item.selected = NO;
//        if ([_budgetModel.billIds containsObject:item.billID]) {
//            NSMutableArray *tmpBillIds = [_budgetModel.billIds mutableCopy];
//            [tmpBillIds removeObject:item.billID];
//            _budgetModel.billIds = [tmpBillIds copy];
//        }
//    }
//}

#pragma mark - Private
- (void)updateSelectedBillIds {
    NSMutableArray *billIds = [NSMutableArray array];
    for (SSJBudgetBillTypeSelectionCellItem *item in self.items) {
        if (item.selected) {
            if ([item.billID isEqualToString:@"all"]) {
                [billIds addObject:@"all"];
                break;
            }
            
            if (item.billID) {
                [billIds addObject:item.billID];
            }
        }
    }
    
    _budgetModel.billIds = [billIds copy];
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
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
