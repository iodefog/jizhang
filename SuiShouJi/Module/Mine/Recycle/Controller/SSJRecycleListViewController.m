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
#import "SSJRecycleListHeaderView.h"
#import "SSJRecycleListModel.h"
#import "SSJRecycleHelper.h"

static NSString *const kHeaderID = @"kHeaderID";
static NSString *const kCellID = @"kCellID";

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
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 75;
    [self.tableView registerClass:[SSJRecycleListCell class] forCellReuseIdentifier:kCellID];
    [self.view addSubview:self.warningHeaderView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarItemAction)];
    [self updateAppearance];
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
    SSJRecycleListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID forIndexPath:indexPath];
    SSJRecycleListModel *model = [self.listModels ssj_safeObjectAtIndex:indexPath.section];
    cell.cellItem = [model.cellItems ssj_safeObjectAtIndex:indexPath.row];
    @weakify(self);
    cell.expandBtnDidClick = ^(SSJRecycleListCell *cell) {
        @strongify(self);
        SSJRecycleListCellItem *item = cell.cellItem;
        if (item.state == SSJRecycleListCellStateNormal) {
            item.state = SSJRecycleListCellStateExpanded;
        } else if (item.state == SSJRecycleListCellStateExpanded) {
            item.state = SSJRecycleListCellStateNormal;
        }
        
        [self.tableView reloadRowsAtIndexPaths:(self.lastExpandedIndexPath ? @[indexPath, self.lastExpandedIndexPath] : @[indexPath]) withRowAnimation:UITableViewRowAnimationFade];
        
        if (item.state == SSJRecycleListCellStateNormal) {
            self.lastExpandedIndexPath = nil;
        } else if (item.state == SSJRecycleListCellStateExpanded) {
            self.lastExpandedIndexPath = indexPath;
        }
    };
    cell.recoverBtnDidClick = ^(SSJRecycleListCell *cell) {
        
    };
    cell.deleteBtnDidClick = ^(SSJRecycleListCell *cell) {
        
    };
    return cell;
}

#pragma mark - UITableViewDelegate
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
    SSJRecycleListCellItem *item = [model.cellItems ssj_safeObjectAtIndex:indexPath.row];
    if (item.state == SSJRecycleListCellStateSelected) {
        item.state = SSJRecycleListCellStateUnselected;
    } else if (item.state == SSJRecycleListCellStateUnselected) {
        item.state = SSJRecycleListCellStateSelected;
    }
    
    [self updateRightBarItemTitle];
}

#pragma mark - Private
- (void)updateAppearance {
    [_warningHeaderView updateAppearanceAccordingToTheme];
    [_deleteBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
    [_deleteBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
}

- (void)rightBarItemAction {
    if (self.editing) {
        // 先遍历数组查看是否所有的model都被选中
        BOOL selectedAll = YES;
        for (SSJRecycleListModel *sectionModel in self.listModels) {
            for (SSJRecycleListCellItem *cellItem in sectionModel.cellItems) {
                if (cellItem.state == SSJRecycleListCellStateUnselected) {
                    selectedAll = NO;
                    break;
                }
            }
            
            if (!selectedAll) {
                break;
            }
        }
        
        // 如果都选中就结束编辑状态，反之就全选所有model
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(selectedAll ? @"取消" : @"全选", nil);
        for (SSJRecycleListModel *sectionModel in self.listModels) {
            for (SSJRecycleListCellItem *cellItem in sectionModel.cellItems) {
                cellItem.state = selectedAll ? SSJRecycleListCellStateNormal : SSJRecycleListCellStateSelected;
            }
        }
        
    } else {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"编辑", nil);
        for (SSJRecycleListModel *sectionModel in self.listModels) {
            for (SSJRecycleListCellItem *cellItem in sectionModel.cellItems) {
                cellItem.state = SSJRecycleListCellStateUnselected;
            }
        }
    }
    self.lastExpandedIndexPath = nil;
}

- (void)updateRightBarItemTitle {
    if (self.editing) {
        BOOL selectedAll = YES;
        for (SSJRecycleListModel *sectionModel in self.listModels) {
            for (SSJRecycleListCellItem *cellItem in sectionModel.cellItems) {
                if (cellItem.state == SSJRecycleListCellStateUnselected) {
                    selectedAll = NO;
                    break;
                }
            }
            
            if (!selectedAll) {
                break;
            }
        }
        
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(selectedAll ? @"取消" : @"全选", nil);
    } else {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"编辑", nil);
    }
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
        [_deleteBtn ssj_setBorderStyle:SSJBorderStyleTop];
        @weakify(self);
        [[_deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
        }];
    }
    return _deleteBtn;
}

@end
