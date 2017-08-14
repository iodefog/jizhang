//
//  SSJBudgetBillTypeSelectionViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/9/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetBillTypeSelectionViewController.h"
#import "SSJBudgetEditViewController.h"
#import "SSJCreateOrEditBillTypeViewController.h"
#import "SSJBudgetBillTypeSelectionCell.h"
#import "SSJBudgetDatabaseHelper.h"
#import "SSJBudgetModel.h"
#import "SSJDatePeriod.h"
#import "SSJUserTableManager.h"

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
        self.title = NSLocalizedString(@"选择类别", nil) ;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    
    if (_edited) {
        self.originalBillIds = self.selectedTypeList;
    }
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"保存", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadData];
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
        
        if ([selectedItem.billID isEqualToString:SSJAllBillTypeId]) {
            for (SSJBudgetBillTypeSelectionCellItem *item in self.items) {
                if (item.canSelect) {
                    item.selected = selectedItem.selected;
                }
            }
        } else {
            if (selectedItem.selected) {
                BOOL isSelectedAll = YES;
                for (SSJBudgetBillTypeSelectionCellItem *item in self.items) {
                    if ([item.billID isEqualToString:SSJAllBillTypeId] || !item.canSelect) {
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
        SSJCreateOrEditBillTypeViewController *addTypeVC = [[SSJCreateOrEditBillTypeViewController alloc] init];
        addTypeVC.created = YES;
        addTypeVC.expended = YES;
        addTypeVC.saveHandler = ^(NSString * _Nonnull billID) {
            if (![wself.selectedTypeList containsObject:SSJAllBillTypeId]) {
                NSMutableArray *tmpBillIds = [wself.selectedTypeList mutableCopy];
                [tmpBillIds addObject:billID];
                wself.selectedTypeList = tmpBillIds;
            }
        };
        [self.navigationController pushViewController:addTypeVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

#pragma mark - Event
- (void)saveAction {
    if (self.selectedTypeList.count == 0) {
        [CDAutoHideMessageHUD showMessage:@"至少选择一个类别"];
        return;
    }
    
    if (self.enterFromBudgetList) {
        [SSJUserTableManager currentBooksId:^(NSString * _Nonnull booksId) {
            SSJDatePeriod *period = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeMonth date:[NSDate date]];
            SSJBudgetModel *budgetModel = [[SSJBudgetModel alloc] init];
            budgetModel.ID = SSJUUID();
            budgetModel.userId = SSJUSERID();
            budgetModel.booksId = booksId;
            budgetModel.billIds = self.selectedTypeList;
            budgetModel.type = 1;
            budgetModel.budgetMoney = 3000;
            budgetModel.remindMoney = 300;
            budgetModel.beginDate = [period.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
            budgetModel.endDate = [period.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
            budgetModel.isAutoContinued = YES;
            budgetModel.isRemind = YES;
            budgetModel.isAlreadyReminded = NO;
            budgetModel.isLastDay = YES;
            
            SSJBudgetEditViewController *newBudgetController = [[SSJBudgetEditViewController alloc] init];
            newBudgetController.model = budgetModel;
            
            NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
            [viewControllers removeObject:self];
            [viewControllers addObject:newBudgetController];
            [self.navigationController setViewControllers:viewControllers animated:YES];
        } failure:^(NSError * _Nonnull error) {
            [SSJAlertViewAdapter showError:error];
        }];
        
        return;
    }
    
    if (self.originalBillIds && ![self.originalBillIds isEqualToArray:self.selectedTypeList]) {
        
        [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"更改类别后，该预算的历史预算数据将清除重置哦" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:^(SSJAlertViewAction * _Nonnull action) {
            
            self.selectedTypeList = self.originalBillIds;
            BOOL allSelect = [self.selectedTypeList containsObject:SSJAllBillTypeId];
            for (SSJBudgetBillTypeSelectionCellItem *item in self.items) {
                if (allSelect) {
                    item.selected = YES;
                } else {
                    item.selected = [self.selectedTypeList containsObject:item.billID];
                }
            }
            [self.tableView reloadData];
            
        }], [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction * _Nonnull action) {
            
            if (self.saveHandle) {
                self.saveHandle(self);
            }
            [self goBackAction];
            
        }], nil];
        
    } else {
        if (self.saveHandle) {
            self.saveHandle(self);
        }
        [self goBackAction];
    }
}

- (void)goBack {
    
}

#pragma mark - Private
- (void)updateSelectedBillIds {
    NSMutableArray *billIds = [NSMutableArray array];
    for (SSJBudgetBillTypeSelectionCellItem *item in self.items) {
        if (item.selected) {
            if ([item.billID isEqualToString:SSJAllBillTypeId]) {
                [billIds removeAllObjects];
                [billIds addObject:SSJAllBillTypeId];
                break;
            }
            
            if (item.billID) {
                [billIds addObject:item.billID];
            }
        }
    }
    
    self.selectedTypeList = [billIds copy];
}

- (void)loadData {
    [self.view ssj_showLoadingIndicator];
    [SSJBudgetDatabaseHelper queryBudgetBillTypeSelectionItemListWithSelectedTypeList:self.selectedTypeList booksId:nil success:^(NSArray<SSJBudgetBillTypeSelectionCellItem *> * _Nonnull list) {
        
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
        [self showError:error];
    }];
}

- (void)showError:(NSError *)error {
    NSString *message = nil;
#ifdef DEBUG
    message = [error localizedDescription];
#else
    message = SSJ_ERROR_MESSAGE;
#endif
    [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:message action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
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
