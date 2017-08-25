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
#import "SSJRecycleListModel.h"
#import "SSJRecycleHelper.h"

static NSString *const kHeaderID = @"kHeaderID";
static NSString *const kRecycleListCellID = @"SSJRecycleListCell";
static NSString *const kRecycleRecoverClearCellID = @"RecycleRecoverClearCell";

@interface SSJRecycleListViewController ()

@property (nonatomic) BOOL editing;

@property (nonatomic, strong) NSIndexPath *lastExpandedIndexPath;

@property (nonatomic, strong) NSArray<SSJRecycleListModel *> *listModels;

@property (nonatomic, strong) SSJSyncSettingWarningFooterView *warningHeaderView;

@property (nonatomic, strong) UIButton *deleteBtn;

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
    
    [self.tableView registerClass:[SSJRecycleListCell class] forCellReuseIdentifier:kRecycleListCellID];
    [self.tableView registerClass:[SSJRecycleRecoverClearCell class] forCellReuseIdentifier:kRecycleRecoverClearCellID];
    [self.view addSubview:self.warningHeaderView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarItemAction)];
    [self updateAppearance];
    [self.view setNeedsUpdateConstraints];
    
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
                item.state = SSJRecycleListCellStateExpanded;
            } else if (item.state == SSJRecycleListCellStateExpanded) {
                item.state = SSJRecycleListCellStateNormal;
            }
            
            if (item.state == SSJRecycleListCellStateNormal) {
                [self deleteLastExpandedCellIfNeeded];
            } else if (item.state == SSJRecycleListCellStateExpanded) {
                NSIndexPath *expandedIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
                [self.tableView beginUpdates];
                [self insertEditCellAtIndexPath:expandedIndexPath];
                [self deleteLastExpandedCellIfNeeded];
                [self.tableView endUpdates];
                self.lastExpandedIndexPath = expandedIndexPath;
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
            }];
        };
        cell.deleteBtnDidClick = ^(SSJRecycleRecoverClearCell *cell) {
            @strongify(self);
            SSJRecycleRecoverClearCellItem *item = cell.cellItem;
            item.recoverBtnLoading = YES;
            [self clearData:@[item.recycleID] completion:^(BOOL success) {
                item.recoverBtnLoading = NO;
            }];
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
- (void)updateAppearance {
    [_warningHeaderView updateAppearanceAccordingToTheme];
    [_deleteBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
    [_deleteBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
}

- (void)rightBarItemAction {
    self.editing = !self.editing;
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(self.editing ? @"编辑" : @"取消", nil);
    [self deleteLastExpandedCellIfNeeded];
    
    for (SSJRecycleListModel *sectionModel in self.listModels) {
        for (SSJRecycleListCellItem *cellItem in sectionModel.cellItems) {
            cellItem.state = self.editing ? SSJRecycleListCellStateUnselected : SSJRecycleListCellStateNormal;
        }
    }
}

- (void)insertEditCellAtIndexPath:(NSIndexPath *)indexPath {
    SSJRecycleRecoverClearCellItem *item = [[SSJRecycleRecoverClearCellItem alloc] init];
    item.recycleID = item.recycleID;
    
    SSJRecycleListModel *model = [self.listModels ssj_safeObjectAtIndex:indexPath.section];
    [model.cellItems insertObject:item atIndex:indexPath.row];
    
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)deleteLastExpandedCellIfNeeded {
    if (self.lastExpandedIndexPath) {
        SSJRecycleListModel *model = [self.listModels ssj_safeObjectAtIndex:self.lastExpandedIndexPath.section];
        [model.cellItems removeObjectAtIndex:self.lastExpandedIndexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[self.lastExpandedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        self.lastExpandedIndexPath = nil;
    }
}

- (RACSignal *)loadDataSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJRecycleHelper queryRecycleListModelsWithSuccess:^(NSArray<SSJRecycleListModel *> * _Nonnull models) {
            self.listModels = models;
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
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJRecycleHelper recoverRecycleIDs:recycleIDs success:^{
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }] then:^RACSignal *{
        return [self loadDataSignal];
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
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJRecycleHelper clearRecycleIDs:recycleIDs success:^{
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }] then:^RACSignal *{
        return [self loadDataSignal];
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
            NSMutableArray *selectedIDs = [NSMutableArray array];
            for (SSJRecycleListModel *model in self.listModels) {
                for (SSJRecycleListCellItem *cellItem in model.cellItems) {
                    if (cellItem.state == SSJRecycleListCellStateSelected) {
                        [selectedIDs addObject:cellItem.recycleID];
                    }
                }
            }
            
            [button ssj_showLoadingIndicator];
            [self clearData:selectedIDs completion:^(BOOL success) {
                [button ssj_hideLoadingIndicator];
            }];
        }];
    }
    return _deleteBtn;
}

@end
