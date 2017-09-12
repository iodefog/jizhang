//
//  SSJRecycleListViewController.m
//  SuiShouJi
//
//  Created by old lang on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJRecycleListViewController.h"
#import "SSJSyncSettingWarningFooterView.h"
#import "SSJRecycleListCell.h"
#import "SSJRecycleRecoverClearCell.h"
#import "SSJRecycleListHeaderView.h"
#import "SSJBudgetNodataRemindView.h"
#import "SSJRecycleRecoverAlertView.h"
#import "SSJBooksTypeDeletionAuthCodeAlertView.h"
#import "SSJRecycleListModel.h"
#import "SSJRecycleHelper.h"
#import "SSJRewardViewController.h"

static NSString *const kHeaderID = @"kHeaderID";
static NSString *const kRecycleListCellID = @"SSJRecycleListCell";
static NSString *const kRecycleRecoverClearCellID = @"RecycleRecoverClearCell";

@interface SSJRecycleListViewController ()

@property (nonatomic) BOOL editing;

@property (nonatomic, strong) NSMutableArray<SSJRecycleListModel *> *listModels;

@property (nonatomic, strong) SSJSyncSettingWarningFooterView *warningHeaderView;

@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) UIBarButtonItem *editButtonItem;

@property (nonatomic, strong) SSJBudgetNodataRemindView *noDataRemindView;

@property (nonatomic, strong) SSJRecycleRecoverAlertView *rewardAlertView;

@property (nonatomic, strong) SSJBooksTypeDeletionAuthCodeAlertView *authCodeAlertView;

@end

@implementation SSJRecycleListViewController

#pragma mark - Lifecycle
- (void)dealloc {
    
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"回收站";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.warningHeaderView];
    [self.view addSubview:self.deleteBtn];
    [self.view addSubview:self.noDataRemindView];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    [self.tableView registerClass:[SSJRecycleListCell class] forCellReuseIdentifier:kRecycleListCellID];
    [self.tableView registerClass:[SSJRecycleRecoverClearCell class] forCellReuseIdentifier:kRecycleRecoverClearCellID];
    [self.tableView registerClass:[SSJRecycleListHeaderView class] forHeaderFooterViewReuseIdentifier:kHeaderID];
    
    [self updateAppearance];
    [self.view setNeedsUpdateConstraints];
    
    [self setupBindings];
    [self loadData];
}

- (void)updateViewConstraints {
    [self.warningHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(SSJ_NAVIBAR_BOTTOM);
        make.left.width.mas_equalTo(self.view);
        make.height.mas_equalTo(36);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.warningHeaderView.mas_bottom);
        make.left.right.bottom.mas_equalTo(self.view);
    }];
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.width.mas_equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    [self.noDataRemindView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(SSJ_NAVIBAR_BOTTOM);
        make.left.bottom.right.mas_equalTo(self.view);
    }];
    [super updateViewConstraints];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.listModels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    SSJRecycleListModel *model = [self.listModels ssj_safeObjectAtIndex:section];
    return model.cellItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJRecycleListModel *model = [self.listModels ssj_safeObjectAtIndex:indexPath.section];
    SSJBaseCellItem *cellItem = [model.cellItems ssj_safeObjectAtIndex:indexPath.row];
    
    if ([cellItem isKindOfClass:[SSJRecycleListCellItem class]]) {
        SSJRecycleListCell *cell = [tableView dequeueReusableCellWithIdentifier:kRecycleListCellID forIndexPath:indexPath];
        cell.cellItem = cellItem;
        @weakify(self);
        cell.expandBtnDidClick = ^(SSJRecycleListCell *cell) {
            @strongify(self);
            
            SSJRecycleListCellItem *item = cell.cellItem;
            if (item.state == SSJRecycleListCellStateNormal) {
                
                [self deleteExpandedCell];
                
                item.state = SSJRecycleListCellStateExpanded;
                [self.tableView beginUpdates];
                NSIndexPath *currentIndexPath = [self indexPathForCellItem:item];
                NSIndexPath *expandedIndexPath = [NSIndexPath indexPathForRow:currentIndexPath.row + 1 inSection:currentIndexPath.section];
                [self insertEditCellAtIndexPath:expandedIndexPath recycleID:item.recycleID];
                
                [self.tableView endUpdates];
            } else {
                [self deleteExpandedCell];
            }
        };
        return cell;
        
    } else if ([cellItem isKindOfClass:[SSJRecycleRecoverClearCellItem class]]) {
        SSJRecycleRecoverClearCell *cell = [tableView dequeueReusableCellWithIdentifier:kRecycleRecoverClearCellID forIndexPath:indexPath];
        cell.cellItem = cellItem;
        @weakify(self);
        cell.recoverBtnDidClick = ^(SSJRecycleRecoverClearCell *cell) {
            @strongify(self);
            SSJRecycleRecoverClearCellItem *item = cell.cellItem;
            item.recoverBtnLoading = YES;
            [self recoverData:@[item.recycleID] completion:^(BOOL success) {
                item.recoverBtnLoading = NO;
                if (success) {
                    [self deleteCellsWithRecycleIDs:@[item.recycleID]];
                    
                    static BOOL rewardAlertShowed = NO;
                    if (!rewardAlertShowed) {
                        rewardAlertShowed = YES;
                        [self.rewardAlertView show];
                    }
                }
            }];
        };
        cell.deleteBtnDidClick = ^(SSJRecycleRecoverClearCell *cell) {
            @strongify(self);
            [self.authCodeAlertView show];
            self.authCodeAlertView.finishVerification = ^{
                @strongify(self);
                SSJRecycleRecoverClearCellItem *item = cell.cellItem;
                item.recoverBtnLoading = YES;
                [self clearData:@[item.recycleID] completion:^(BOOL success) {
                    item.recoverBtnLoading = NO;
                    if (success) {
                        [self deleteCellsWithRecycleIDs:@[item.recycleID]];
                    }
                }];
            };
        };
        return cell;
        
    } else {
        return [UITableViewCell new];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJRecycleListModel *model = [self.listModels ssj_safeObjectAtIndex:indexPath.section];
    SSJBaseCellItem *cellItem = [model.cellItems ssj_safeObjectAtIndex:indexPath.row];
    if ([cellItem isKindOfClass:[SSJRecycleListCellItem class]]) {
        return 75;
    } else if ([cellItem isKindOfClass:[SSJRecycleRecoverClearCellItem class]]) {
        return 44;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SSJRecycleListHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderID];
    SSJRecycleListModel *model = [self.listModels ssj_safeObjectAtIndex:section];
    headerView.dateStr = model.dateStr;
    return headerView;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SSJRecycleListModel *model = [self.listModels ssj_safeObjectAtIndex:indexPath.section];
    SSJBaseCellItem *item = [model.cellItems ssj_safeObjectAtIndex:indexPath.row];
    
    if ([item isKindOfClass:[SSJRecycleListCellItem class]]) {
        SSJRecycleListCellItem *cellItem = (SSJRecycleListCellItem *)item;
        if (cellItem.state == SSJRecycleListCellStateSelected) {
            cellItem.state = SSJRecycleListCellStateUnselected;
        } else if (cellItem.state == SSJRecycleListCellStateUnselected) {
            cellItem.state = SSJRecycleListCellStateSelected;
        }
    }
}

#pragma mark - Private
- (void)setupBindings {
    @weakify(self);
    RAC(self.deleteBtn, hidden) = [[RACSignal merge:@[RACObserve(self, editing), RACObserve(self, listModels)]] map:^id(NSNumber *value) {
        @strongify(self);
        return @(!self.editing || self.listModels.count == 0);
    }];
    
    [[RACSignal merge:@[RACObserve(self, listModels)]] subscribeNext:^(id value) {
        @strongify(self);
        self.warningHeaderView.hidden = self.listModels.count == 0;
        self.noDataRemindView.hidden = self.listModels.count > 0;
        [self.navigationItem setRightBarButtonItem:(self.listModels.count == 0 ? nil : self.editButtonItem) animated:YES];
    }];
}

- (void)updateAppearance {
    [self.warningHeaderView updateAppearanceAccordingToTheme];
    self.deleteBtn.backgroundColor = SSJ_SECONDARY_FILL_COLOR;
    [self.deleteBtn setTitleColor:SSJ_MARCATO_COLOR forState:UIControlStateNormal];
    [self.deleteBtn ssj_setBorderColor:SSJ_CELL_SEPARATOR_COLOR];
    [self.noDataRemindView updateAppearance];
    [self.rewardAlertView updateAppearanceAccordingToTheme];
}

- (void)rightBarItemAction {
    self.editing = !self.editing;
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(self.editing ? @"取消" : @"编辑", nil);
    [self deleteExpandedCell];
    
    for (SSJRecycleListModel *sectionModel in self.listModels) {
        for (SSJRecycleListCellItem *cellItem in sectionModel.cellItems) {
            cellItem.state = self.editing ? SSJRecycleListCellStateUnselected : SSJRecycleListCellStateNormal;
        }
    }
}

- (void)insertEditCellAtIndexPath:(NSIndexPath *)indexPath recycleID:(NSString *)recycleID {
    SSJRecycleRecoverClearCellItem *item = [[SSJRecycleRecoverClearCellItem alloc] init];
    item.recycleID = recycleID;
    
    SSJRecycleListModel *model = [self.listModels ssj_safeObjectAtIndex:indexPath.section];
    [model.cellItems insertObject:item atIndex:indexPath.row];
    
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)deleteExpandedCell {
    __block NSIndexPath *expandedIndexPath = nil;
    [self.listModels enumerateObjectsUsingBlock:^(SSJRecycleListModel *model, NSUInteger section, BOOL * _Nonnull stop_1) {
        [model.cellItems enumerateObjectsUsingBlock:^(SSJBaseCellItem *cellItem, NSUInteger row, BOOL * _Nonnull stop_2) {
            if ([cellItem isKindOfClass:[SSJRecycleListCellItem class]]) {
                SSJRecycleListCellItem *listCellItem = (SSJRecycleListCellItem *)cellItem;
                if (listCellItem.state == SSJRecycleListCellStateExpanded) {
                    listCellItem.state = SSJRecycleListCellStateNormal;
                    expandedIndexPath = [NSIndexPath indexPathForRow:row + 1 inSection:section];
                    *stop_2 = *stop_1 = YES;
                }
            }
        }];
    }];
    
    if (expandedIndexPath) {
        SSJRecycleListModel *model = [self.listModels ssj_safeObjectAtIndex:expandedIndexPath.section];
        [model.cellItems removeObjectAtIndex:expandedIndexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[expandedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)deleteCellsWithRecycleIDs:(NSArray<NSString *> *)recycleIDs {
    [self.tableView beginUpdates];
    for (NSString *recycleID in recycleIDs) {
        NSMutableArray *deleteSections = [NSMutableArray array];
        [self.listModels enumerateObjectsUsingBlock:^(SSJRecycleListModel *model, NSUInteger section, BOOL * _Nonnull stop_1) {
            NSMutableArray *deleteIndexPaths = [NSMutableArray array];
            [model.cellItems enumerateObjectsUsingBlock:^(SSJBaseCellItem<SSJRecycleCellItem> *item, NSUInteger row, BOOL * _Nonnull stop_2) {
                if ([recycleID isEqualToString:item.recycleID]) {
                    [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
                }
            }];
            
            [deleteIndexPaths enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
                [model.cellItems ssj_safeRemoveObjectAtIndex:indexPath.row];
            }];
            
            [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
            
            if (!model.cellItems.count) {
                [deleteSections addObject:@(section)];
            }
        }];
        
        [deleteSections enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSNumber *section, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.listModels ssj_safeRemoveObjectAtIndex:[section intValue]];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:[section intValue]] withRowAnimation:UITableViewRowAnimationFade];
        }];
    }
    
    self.listModels = [self.listModels mutableCopy];
    
    [self.tableView endUpdates];
}

- (NSIndexPath *)indexPathForCellItem:(SSJBaseCellItem *)item {
    __block NSIndexPath *expandedIndexPath = nil;
    [self.listModels enumerateObjectsUsingBlock:^(SSJRecycleListModel *model, NSUInteger section, BOOL * _Nonnull stop_1) {
        [model.cellItems enumerateObjectsUsingBlock:^(SSJBaseCellItem *cellItem, NSUInteger row, BOOL * _Nonnull stop_2) {
            if (item == cellItem) {
                expandedIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
                *stop_2 = *stop_1 = YES;
            }
        }];
    }];
    return expandedIndexPath;
}

- (RACSignal *)loadDataSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJRecycleHelper queryRecycleListModelsWithSuccess:^(NSArray<SSJRecycleListModel *> * _Nonnull models) {
            self.listModels = [models mutableCopy];
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (void)loadData {
    [self.view ssj_showLoadingIndicator];
    [[self loadDataSignal] subscribeError:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showError:error];
    } completed:^{
        [self.view ssj_hideLoadingIndicator];
        [self.tableView reloadData];
    }];
}

- (void)recoverData:(NSArray *)recycleIDs completion:(void(^)(BOOL success))completion {
    [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJRecycleHelper recoverRecycleIDs:recycleIDs success:^{
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }] subscribeError:^(NSError *error) {
        [CDAutoHideMessageHUD showError:error];
        if (completion) {
            completion(NO);
        }
    } completed:^{
        if (completion) {
            completion(YES);
        }
    }];
}

- (void)clearData:(NSArray *)recycleIDs completion:(void(^)(BOOL success))completion {
    [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJRecycleHelper clearRecycleIDs:recycleIDs success:^{
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }] subscribeError:^(NSError *error) {
        [CDAutoHideMessageHUD showError:error];
        if (completion) {
            completion(NO);
        }
    } completed:^{
        if (completion) {
            completion(YES);
        }
    }];
}

#pragma mark - Lazy
- (SSJSyncSettingWarningFooterView *)warningHeaderView {
    if (!_warningHeaderView) {
        _warningHeaderView = [[SSJSyncSettingWarningFooterView alloc] init];
        _warningHeaderView.warningText = @"回收站文件不占内存";
    }
    return _warningHeaderView;
}

- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_deleteBtn setTitle:NSLocalizedString(@"彻底删除", nil) forState:UIControlStateNormal];
        [_deleteBtn setTitle:nil forState:UIControlStateDisabled];
        [_deleteBtn ssj_setBorderStyle:SSJBorderStyleTop];
        @weakify(self);
        [[_deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *button) {
            @strongify(self);
            [self.authCodeAlertView show];
            self.authCodeAlertView.finishVerification = ^{
                @strongify(self);
                NSMutableArray *selectedIDs = [NSMutableArray array];
                for (SSJRecycleListModel *model in self.listModels) {
                    for (SSJRecycleListCellItem *cellItem in model.cellItems) {
                        if (![cellItem isKindOfClass:[SSJRecycleListCellItem class]]) {
                            continue;
                        }
                        if (cellItem.state == SSJRecycleListCellStateSelected) {
                            [selectedIDs addObject:cellItem.recycleID];
                        }
                    }
                }
                
                [button ssj_showLoadingIndicator];
                [self clearData:selectedIDs completion:^(BOOL success) {
                    [button ssj_hideLoadingIndicator];
                    if (success) {
                        [self deleteCellsWithRecycleIDs:selectedIDs];
                    }
                }];
            };
        }];
    }
    return _deleteBtn;
}

- (UIBarButtonItem *)editButtonItem {
    if (!_editButtonItem) {
        _editButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarItemAction)];
    }
    return _editButtonItem;
}

- (SSJBudgetNodataRemindView *)noDataRemindView {
    if (!_noDataRemindView) {
        _noDataRemindView = [[SSJBudgetNodataRemindView alloc] init];
        _noDataRemindView.image = @"budget_no_data";
        _noDataRemindView.title = @"空空如也～";
    }
    return _noDataRemindView;
}

- (SSJRecycleRecoverAlertView *)rewardAlertView {
    if (!_rewardAlertView) {
        _rewardAlertView = [SSJRecycleRecoverAlertView alertView];
        @weakify(self);
        _rewardAlertView.confirmBlock = ^{
            @strongify(self);
            SSJRewardViewController *rewardVC = [[SSJRewardViewController alloc] init];
            [self.navigationController pushViewController:rewardVC animated:YES];
        };
    }
    return _rewardAlertView;
}

- (SSJBooksTypeDeletionAuthCodeAlertView *)authCodeAlertView {
    if (!_authCodeAlertView) {
        __weak typeof(self) wself = self;
        _authCodeAlertView = [[SSJBooksTypeDeletionAuthCodeAlertView alloc] init];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 5;
        style.alignment = NSTextAlignmentCenter;
        _authCodeAlertView.message = [[NSAttributedString alloc] initWithString:@"数据将彻底删除，无法恢复！\n仍然删除，请输入下列验证码" attributes:@{NSParagraphStyleAttributeName:style}];
    }
    return _authCodeAlertView;
}

@end
