//
//  SSJFixedFinanceProductDetailViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanceProductDetailViewController.h"

#import "SSJFixedFinanceProductDetailCell.h"

@interface SSJFixedFinanceProductDetailViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *closeOutBtn;

@property (nonatomic, strong) UIButton *changeBtn;

@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) UIBarButtonItem *editItem;
@end

@implementation SSJFixedFinanceProductDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.view addSubview:self.tableView];
    [self.view addSubview:self.changeBtn];
    [self.view addSubview:self.deleteBtn];
    [self.view addSubview:self.closeOutBtn];
    [self updateAppearance];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadData];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (section == 0) {
//        return self.section1Items.count;
//    } else if (section == 1) {
//        return self.section2Items.count;
//    } else {
//        return 0;
//    }
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   SSJFixedFinanceProductDetailCell *cell = [SSJFixedFinanceProductDetailCell cellWithTableView:tableView];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 40;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    if (section == 1) {
//        return self.changeSectionHeaderView;
//    }
    return [UIView new];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {}


#pragma mark - Private
- (void)loadData {
    
}

- (void)updateAppearance {
//    self.headerView.separatorColor = [SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID] ? [UIColor whiteColor] : SSJ_CELL_SEPARATOR_COLOR;
//    self.headerView.backgroundColor = SSJ_MAIN_BACKGROUND_COLOR;
    
    _tableView.separatorColor = SSJ_CELL_SEPARATOR_COLOR;
//    [_changeSectionHeaderView updateAppearance];
//    [_changeChargeSelectionView updateAppearance];
    
    _closeOutBtn.backgroundColor = _deleteBtn.backgroundColor  = _changeBtn.backgroundColor = SSJ_SECONDARY_FILL_COLOR;
    
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        [_closeOutBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.bookKeepingHomeMutiButtonSelectColor] forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.bookKeepingHomeMutiButtonSelectColor] forState:UIControlStateNormal];
    } else {
        [_closeOutBtn setTitleColor:SSJ_MARCATO_COLOR forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:SSJ_MARCATO_COLOR forState:UIControlStateNormal];
    }
    
    [_changeBtn setTitleColor:SSJ_MAIN_COLOR forState:UIControlStateNormal];
    [_changeBtn ssj_setBorderColor:SSJ_CELL_SEPARATOR_COLOR];
    [_closeOutBtn ssj_setBorderColor:SSJ_CELL_SEPARATOR_COLOR];
    [_deleteBtn ssj_setBorderColor:SSJ_CELL_SEPARATOR_COLOR];
}



#pragma mark - Event
- (void)editAction {
//    SSJAddOrEditLoanViewController *editLoanVC = [[SSJAddOrEditLoanViewController alloc] init];
//    editLoanVC.loanModel = self.loanModel;
//    editLoanVC.chargeModels = self.chargeModels;
//    [self.navigationController pushViewController:editLoanVC animated:YES];
//    
//    switch (_loanModel.type) {
//        case SSJLoanTypeLend:
//            [SSJAnaliyticsManager event:@"edit_loan"];
//            break;
//            
//        case SSJLoanTypeBorrow:
//            [SSJAnaliyticsManager event:@"edit_owed"];
//            break;
//    }
}

- (void)closeOutBtnAction {
//    _loanModel.endTargetFundID = _loanModel.targetFundID;
//    SSJLoanCloseOutViewController *closeOutVC = [[SSJLoanCloseOutViewController alloc] init];
//    closeOutVC.loanModel = _loanModel;
//    [self.navigationController pushViewController:closeOutVC animated:YES];
}

- (void)changeBtnAction {
//    [self.changeChargeSelectionView show];
//    
//    switch (self.loanModel.type) {
//        case SSJLoanTypeLend:
//            [SSJAnaliyticsManager event:@"loan_modify"];
//            break;
//            
//        case SSJLoanTypeBorrow:
//            [SSJAnaliyticsManager event:@"owed_modify"];
//            break;
//    }
}

- (void)deleteBtnAction {
//    __weak typeof(self) wself = self;
//    [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"删除该项目后相关的账户流水数据(含转账、利息）将被彻底删除哦。" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:NULL], [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction *action) {
//        [wself deleteLoanModel];
//    }], nil];
//    
//    switch (self.loanModel.type) {
//        case SSJLoanTypeLend:
//            [SSJAnaliyticsManager event:@"loan_delete"];
//            break;
//            
//        case SSJLoanTypeBorrow:
//            [SSJAnaliyticsManager event:@"owed_delete"];
//            break;
//    }
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM - 54) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView setTableFooterView:[[UIView alloc] init]];
//        [_tableView registerClass:[SSJLoanDetailCell class] forCellReuseIdentifier:kSSJLoanDetailCellID];
        _tableView.sectionFooterHeight = 0;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 12, 0, 0);
    }
    return _tableView;
}

- (UIButton *)changeBtn {
    if (!_changeBtn) {
        _changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeBtn.frame = CGRectMake(0, self.view.height - 54, self.view.width * 0.6, 54);
        _changeBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_changeBtn setTitle:@"变更" forState:UIControlStateNormal];
        [_changeBtn addTarget:self action:@selector(changeBtnAction) forControlEvents:UIControlEventTouchUpInside];
        _changeBtn.hidden = YES;
        [_changeBtn ssj_setBorderWidth:1];
        [_changeBtn ssj_setBorderStyle:SSJBorderStyleTop];
    }
    return _changeBtn;
}

- (UIButton *)closeOutBtn {
    if (!_closeOutBtn) {
        _closeOutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeOutBtn.frame = CGRectMake(self.view.width * 0.6, self.view.height - 54, self.view.width * 0.4, 54);
        _closeOutBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_closeOutBtn setTitle:@"结清" forState:UIControlStateNormal];
        [_closeOutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_closeOutBtn addTarget:self action:@selector(closeOutBtnAction) forControlEvents:UIControlEventTouchUpInside];
        _closeOutBtn.hidden = YES;
        [_closeOutBtn ssj_setBorderWidth:1];
        [_closeOutBtn ssj_setBorderStyle:SSJBorderStyleTop | SSJBorderStyleLeft];
    }
    return _closeOutBtn;
}

- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.frame = CGRectMake(0, self.view.height - 54, self.view.width, 54);
        _deleteBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteBtnAction) forControlEvents:UIControlEventTouchUpInside];
        _deleteBtn.hidden = YES;
        [_deleteBtn ssj_setBorderWidth:1];
        [_deleteBtn ssj_setBorderStyle:SSJBorderStyleTop];
    }
    return _deleteBtn;
}

- (UIBarButtonItem *)editItem {
    if (!_editItem) {
        _editItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editAction)];
    }
    return _editItem;
}

@end
