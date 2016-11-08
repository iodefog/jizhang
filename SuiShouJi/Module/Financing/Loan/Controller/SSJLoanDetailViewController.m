//
//  SSJLoanDetailViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/8/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanDetailViewController.h"
#import "SSJAddOrEditLoanViewController.h"
#import "SSJLoanCloseOutViewController.h"
#import "SSJLoanDetailChargeChangeHeaderView.h"
#import "SSJSeparatorFormView.h"
#import "SSJLoanDetailCell.h"
#import "SSJLoanHelper.h"
#import "SSJLocalNotificationStore.h"
#import "SSJDataSynchronizer.h"

static NSString *const kSSJLoanDetailCellID = @"SSJLoanDetailCell";

@interface SSJLoanDetailViewController () <UITableViewDataSource, UITableViewDelegate, SSJSeparatorFormViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *closeOutBtn;

@property (nonatomic, strong) UIButton *revertBtn;

@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) UIImageView *stampView;

@property (nonatomic, strong) SSJSeparatorFormView *headerView;

@property (nonatomic, strong) SSJLoanDetailChargeChangeHeaderView *changeSectionHeaderView;

@property (nonatomic, strong) UIBarButtonItem *editItem;

@property (nonatomic, strong) NSArray *cellItems;

@property (nonatomic, strong) NSArray *headerItems;

@property (nonatomic, strong) SSJLoanModel *loanModel;

@end

@implementation SSJLoanDetailViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.revertBtn];
    [self.view addSubview:self.deleteBtn];
    [self.view addSubview:self.closeOutBtn];
    [self.tableView addSubview:self.stampView];
    self.tableView.tableHeaderView = self.headerView;
    
    [self updateAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadLoanModel];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _cellItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_cellItems ssj_safeObjectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJLoanDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:kSSJLoanDetailCellID forIndexPath:indexPath];
    cell.cellItem = [_cellItems ssj_objectAtIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 40;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return self.changeSectionHeaderView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - SSJSeparatorFormViewDataSource
- (NSUInteger)numberOfRowsInSeparatorFormView:(SSJSeparatorFormView *)view {
    return _headerItems.count;
}

- (NSUInteger)separatorFormView:(SSJSeparatorFormView *)view numberOfCellsInRow:(NSUInteger)row {
    return [[_headerItems ssj_safeObjectAtIndex:row] count];
}

- (SSJSeparatorFormViewCellItem *)separatorFormView:(SSJSeparatorFormView *)view itemForCellAtIndex:(NSIndexPath *)index {
    return [_headerItems ssj_objectAtIndexPath:index];
}

#pragma mark - Private
- (void)updateAppearance {
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    
    [_closeOutBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
    
    if ([SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID]) {
        [_revertBtn setTitleColor:[UIColor ssj_colorWithHex:@"#373737"] forState:UIControlStateNormal];
        [_revertBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"#CCCCCC"] forState:UIControlStateNormal];
        
        [_deleteBtn setTitleColor:[UIColor ssj_colorWithHex:@"#E54747"] forState:UIControlStateNormal];
        [_deleteBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"#FFFFFF"] forState:UIControlStateNormal];
    } else {
        [_revertBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] forState:UIControlStateNormal];
        [_revertBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor] forState:UIControlStateNormal];
        
        [_deleteBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] forState:UIControlStateNormal];
        [_deleteBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"#FFFFFF" alpha:0.3] forState:UIControlStateNormal];
    }
    
    [_revertBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    [_deleteBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
}

- (void)organiseHeaderItems {
    double loanSum = 0;     // 借贷总额
    double interest = 0;    // 产生利息
    double payment = 0;     // 已收、已还金额
    
    for (SSJLoanChargeModel *chargeModel in self.loanModel.chargeModels) {
        if (chargeModel.chargeType == SSJLoanCompoundChargeTypeCreate) {
            loanSum = chargeModel.money;
        } else if (chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceIncrease) {
            loanSum += chargeModel.money;
        } else if (chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceDecrease) {
            loanSum -= chargeModel.money;
        } else if (chargeModel.chargeType == SSJLoanCompoundChargeTypeAdd) {
            loanSum += chargeModel.money;
        } else if (chargeModel.chargeType == SSJLoanCompoundChargeTypeInterest) {
            interest += chargeModel.money;
        } else if (chargeModel.chargeType == SSJLoanCompoundChargeTypeRepayment) {
            payment += chargeModel.money;
        }
    }
    
    NSString *surplusTitle = nil;
    NSString *sumTitle = nil;
    NSString *interestTitle = nil;
    NSString *paymentTitle = nil;
    NSString *lenderTitle = nil;
    
    switch (self.loanModel.type) {
        case SSJLoanTypeLend: {
            surplusTitle = @"剩余借出款";
            sumTitle = @"借出总额";
            interestTitle = @"利息收入";
            paymentTitle = @"已收金额";
            lenderTitle = @"被谁借款";
        }
            break;
            
        case SSJLoanTypeBorrow: {
            surplusTitle = @"剩余欠款";
            sumTitle = @"欠款总额";
            interestTitle = @"利息支出";
            paymentTitle = @"已还金额";
            lenderTitle = @"欠谁钱款";
        }
            break;
    }
    
    SSJSeparatorFormViewCellItem *surplusItem = [SSJSeparatorFormViewCellItem itemWithTopTitle:surplusTitle
                                                                                   bottomTitle:[NSString stringWithFormat:@"%.2f", self.loanModel.jMoney]
                                                                                 topTitleColor:[UIColor whiteColor]
                                                                              bottomTitleColor:[UIColor whiteColor]
                                                                                  topTitleFont:[UIFont systemFontOfSize:11]
                                                                               bottomTitleFont:[UIFont systemFontOfSize:24]];
    
    SSJSeparatorFormViewCellItem *sumItem = [SSJSeparatorFormViewCellItem itemWithTopTitle:sumTitle
                                                                               bottomTitle:[NSString stringWithFormat:@"%.2f", loanSum]
                                                                             topTitleColor:[UIColor whiteColor]
                                                                          bottomTitleColor:[UIColor whiteColor]
                                                                              topTitleFont:[UIFont systemFontOfSize:11]
                                                                           bottomTitleFont:[UIFont systemFontOfSize:15]];
    
    SSJSeparatorFormViewCellItem *interestItem = nil;
    if (interest > 0) {
        interestItem = [SSJSeparatorFormViewCellItem itemWithTopTitle:interestTitle
                                                          bottomTitle:[NSString stringWithFormat:@"%.2f", interest]
                                                        topTitleColor:[UIColor whiteColor]
                                                     bottomTitleColor:[UIColor whiteColor]
                                                         topTitleFont:[UIFont systemFontOfSize:11]
                                                      bottomTitleFont:[UIFont systemFontOfSize:15]];
    } else {
        interestItem = [SSJSeparatorFormViewCellItem itemWithTopTitle:paymentTitle
                                                          bottomTitle:[NSString stringWithFormat:@"%.2f", payment]
                                                        topTitleColor:[UIColor whiteColor]
                                                     bottomTitleColor:[UIColor whiteColor]
                                                         topTitleFont:[UIFont systemFontOfSize:11]
                                                      bottomTitleFont:[UIFont systemFontOfSize:15]];
    }
    
    SSJSeparatorFormViewCellItem *lenderItem = [SSJSeparatorFormViewCellItem itemWithTopTitle:lenderTitle
                                                                                  bottomTitle:self.loanModel.lender
                                                                                topTitleColor:[UIColor whiteColor]
                                                                             bottomTitleColor:[UIColor whiteColor]
                                                                                 topTitleFont:[UIFont systemFontOfSize:11]
                                                                              bottomTitleFont:[UIFont systemFontOfSize:15]];
    
    _headerItems = @[@[surplusItem], @[sumItem, interestItem, lenderItem]];
}

- (void)organiseCellItems {
    
    NSMutableArray *section1 = [[NSMutableArray alloc] init];
    
    if (_loanModel.closeOut) {
        
        NSString *accountName = [SSJLoanHelper queryForFundNameWithID:_loanModel.targetFundID];
        NSString *endAccountName = [SSJLoanHelper queryForFundNameWithID:_loanModel.endTargetFundID];
        NSString *borrowDateStr = [_loanModel.borrowDate formattedDateWithFormat:@"yyyy.MM.dd"];
        NSString *closeOutDateStr = [_loanModel.endDate formattedDateWithFormat:@"yyyy.MM.dd"];
        
        NSString *loanDayTitle = nil;
        NSString *loanAccountTitle = nil;
        
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                loanDayTitle = @"借款日";
                loanAccountTitle = @"借出账户";
                break;
                
            case SSJLoanTypeBorrow:
                loanDayTitle = @"欠款日";
                loanAccountTitle = @"借入账户";
                break;
        }
        
        [section1 addObjectsFromArray:@[[SSJLoanDetailCellItem itemWithImage:@"loan_expires" title:@"结清日" subtitle:closeOutDateStr bottomTitle:nil],
                                        [SSJLoanDetailCellItem itemWithImage:@"loan_calendar" title:loanDayTitle subtitle:borrowDateStr bottomTitle:nil],
                                        [SSJLoanDetailCellItem itemWithImage:@"loan_closeOut" title:@"结清账户" subtitle:endAccountName bottomTitle:nil],
                                        [SSJLoanDetailCellItem itemWithImage:@"loan_account" title:loanAccountTitle subtitle:accountName bottomTitle:nil]]];
        
        if (_loanModel.memo.length) {
            [section1 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_memo" title:@"备注" subtitle:_loanModel.memo bottomTitle:nil]];
        }
        
    } else {
        
        NSString *loanDateTitle = nil;
        
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                loanDateTitle = @"借款日";
                break;
                
            case SSJLoanTypeBorrow:
                loanDateTitle = @"欠款日";
                break;
        }
        
        NSString *borrowDateStr = [_loanModel.borrowDate formattedDateWithFormat:@"yyyy.MM.dd"];
        [section1 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_calendar" title:loanDateTitle subtitle:borrowDateStr bottomTitle:nil]];
        
        if (_loanModel.repaymentDate) {
            NSString *repaymentDateStr = [_loanModel.repaymentDate formattedDateWithFormat:@"yyyy.MM.dd"];
            [section1 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_expires" title:@"还款日" subtitle:repaymentDateStr bottomTitle:nil]];
            
            NSString *expectedInterestStr = [NSString stringWithFormat:@"¥%.2f", [SSJLoanHelper expectedInterestWithLoanModel:_loanModel]];
            [section1 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_expectedInterest" title:@"预期利息" subtitle:expectedInterestStr bottomTitle:nil]];
        } else {
            NSString *remindDateStr = @"关闭";
            if (_loanModel.remindID.length) {
                SSJReminderItem *remindItem = [SSJLocalNotificationStore queryReminderItemForID:_loanModel.remindID];
                if (remindItem.remindState) {
                    remindDateStr = [remindItem.remindDate formattedDateWithFormat:@"yyyy.MM.dd"];
                }
            }
            [section1 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_remind" title:@"到期日提醒" subtitle:remindDateStr bottomTitle:nil]];
            
            NSString *expectedInterestStr = [NSString stringWithFormat:@"¥%.2f", [SSJLoanHelper interestForEverydayWithLoanModel:_loanModel]];
            [section1 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_expectedInterest" title:@"每天利息" subtitle:expectedInterestStr bottomTitle:nil]];
        }
        
        if (_loanModel.memo.length) {
            [section1 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_memo" title:@"备注" subtitle:_loanModel.memo bottomTitle:nil]];
        }
    }
    
    NSMutableArray *section2 = [[NSMutableArray alloc] init];
    if (self.changeSectionHeaderView.expanded) {
        for (SSJLoanChargeModel *chargeModel in self.loanModel.chargeModels) {
            [section2 addObject:[SSJLoanDetailCellItem cellItemWithChargeModel:chargeModel]];
        }
    }
    
    _cellItems = @[section1, section2];
}

- (void)loadLoanModel {
    [self.view ssj_showLoadingIndicator];
    [SSJLoanHelper queryForLoanModelWithLoanID:_loanID success:^(SSJLoanModel * _Nonnull model) {
        [self.view ssj_hideLoadingIndicator];
        self.loanModel = model;
        [self updateTitle];
        [self updateSubViewHidden];
        [self organiseCellItems];
        [self.tableView reloadData];
        [self organiseHeaderItems];
        [self.headerView reloadData];
        self.headerView.backgroundColor = [UIColor ssj_colorWithHex:[SSJLoanHelper queryForFundColorWithID:self.loanModel.fundID]];
        self.changeSectionHeaderView.title = [NSString stringWithFormat:@"变更记录：%d条", (int)self.loanModel.chargeModels.count];
        
        switch (self.loanModel.type) {
            case SSJLoanTypeLend:
                if (self.loanModel.closeOut) {
                    [MobClick event:@"loan_end_detail"];
                } else {
                    [MobClick event:@"loan_detail"];
                }
                break;
                
            case SSJLoanTypeBorrow:
                if (self.loanModel.closeOut) {
                    [MobClick event:@"owed_end_detail"];
                } else {
                    [MobClick event:@"owed_detail"];
                }
                break;
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:nil], nil];
    }];
}

- (void)deleteLoanModel {
    self.deleteBtn.enabled = NO;
    [SSJLoanHelper deleteLoanModel:_loanModel success:^{
        self.deleteBtn.enabled = YES;
        [self.navigationController popViewControllerAnimated:YES];
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError * _Nonnull error) {
        self.deleteBtn.enabled = YES;
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
}

- (void)updateSubViewHidden {
    if (_loanModel.closeOut) {
        self.revertBtn.hidden = NO;
        self.deleteBtn.hidden = NO;
        self.stampView.hidden = NO;
        self.closeOutBtn.hidden = YES;
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    } else {
        self.revertBtn.hidden = YES;
        self.deleteBtn.hidden = YES;
        self.stampView.hidden = YES;
        self.closeOutBtn.hidden = NO;
        [self.navigationItem setRightBarButtonItem:self.editItem animated:YES];
    }
}

- (void)updateTitle {
    switch (_loanModel.type) {
        case SSJLoanTypeLend:
            self.title = @"借出款详情";
            break;
            
        case SSJLoanTypeBorrow:
            self.title = @"欠款详情";
            break;
    }
}

#pragma mark - Event
- (void)editAction {
    SSJAddOrEditLoanViewController *editLoanVC = [[SSJAddOrEditLoanViewController alloc] init];
    editLoanVC.loanModel = _loanModel;
    [self.navigationController pushViewController:editLoanVC animated:YES];
    
    switch (_loanModel.type) {
        case SSJLoanTypeLend:
            [MobClick event:@"edit_loan"];
            break;
            
        case SSJLoanTypeBorrow:
            [MobClick event:@"edit_owed"];
            break;
    }
}

- (void)closeOutBtnAction {
    _loanModel.endTargetFundID = _loanModel.targetFundID;
    SSJLoanCloseOutViewController *closeOutVC = [[SSJLoanCloseOutViewController alloc] init];
    closeOutVC.loanModel = _loanModel;
    [self.navigationController pushViewController:closeOutVC animated:YES];
}

- (void)revertBtnAction {
    self.revertBtn.enabled = NO;
    [SSJLoanHelper recoverLoanModel:_loanModel success:^{
        _loanModel.closeOut = NO;
        self.revertBtn.enabled = YES;
        [self organiseCellItems];
        [self updateSubViewHidden];
        [self.tableView reloadData];
        [CDAutoHideMessageHUD showMessage:@"恢复项目成功"];
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError * _Nonnull error) {
        self.revertBtn.enabled = YES;
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
}

- (void)deleteBtnAction {
    __weak typeof(self) wself = self;
    [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"删除该项目后相关的账户流水数据(含转账、利息）将被彻底删除哦。" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:NULL], [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction *action) {
        [wself deleteLoanModel];
    }], nil];
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM - 54) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_tableView setTableFooterView:[[UIView alloc] init]];
        [_tableView registerClass:[SSJLoanDetailCell class] forCellReuseIdentifier:kSSJLoanDetailCellID];
        _tableView.rowHeight = 54;
        _tableView.sectionFooterHeight = 0;
    }
    return _tableView;
}

- (UIButton *)closeOutBtn {
    if (!_closeOutBtn) {
        _closeOutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeOutBtn.frame = CGRectMake(0, self.view.height - 54, self.view.width, 54);
        _closeOutBtn.titleLabel.font = [UIFont systemFontOfSize:22];
        [_closeOutBtn setTitle:@"结清" forState:UIControlStateNormal];
        [_closeOutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_closeOutBtn addTarget:self action:@selector(closeOutBtnAction) forControlEvents:UIControlEventTouchUpInside];
        _closeOutBtn.hidden = YES;
    }
    return _closeOutBtn;
}

- (UIButton *)revertBtn {
    if (!_revertBtn) {
        _revertBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _revertBtn.frame = CGRectMake(0, self.view.height - 54, self.view.width * 0.6, 54);
        _revertBtn.titleLabel.font = [UIFont systemFontOfSize:22];
        [_revertBtn setTitle:@"恢复项目" forState:UIControlStateNormal];
        [_revertBtn addTarget:self action:@selector(revertBtnAction) forControlEvents:UIControlEventTouchUpInside];
        _revertBtn.hidden = YES;
        [_revertBtn ssj_setBorderWidth:1];
        [_revertBtn ssj_setBorderStyle:SSJBorderStyleTop];
    }
    return _revertBtn;
}

- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.frame = CGRectMake(self.view.width * 0.6, self.view.height - 54, self.view.width * 0.4, 54);
        _deleteBtn.titleLabel.font = [UIFont systemFontOfSize:22];
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteBtnAction) forControlEvents:UIControlEventTouchUpInside];
        _deleteBtn.hidden = YES;
        [_deleteBtn ssj_setBorderWidth:1];
        [_deleteBtn ssj_setBorderStyle:SSJBorderStyleTop];
    }
    return _deleteBtn;
}

- (UIImageView *)stampView {
    if (!_stampView) {
        _stampView = [[UIImageView alloc] initWithImage:[UIImage ssj_themeImageWithName:@"loan_stamp"]];
        _stampView.size = CGSizeMake(134, 134);
        _stampView.center = CGPointMake(self.tableView.width * 0.5, self.tableView.height * 0.32);
        _stampView.hidden = YES;
    }
    return _stampView;
}

- (UIBarButtonItem *)editItem {
    if (!_editItem) {
        _editItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editAction)];
    }
    return _editItem;
}

- (SSJSeparatorFormView *)headerView {
    if (!_headerView) {
        _headerView = [[SSJSeparatorFormView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, 174)];
        _headerView.backgroundColor = [UIColor ssj_colorWithHex:@""];
        _headerView.separatorColor = [UIColor whiteColor];
        _headerView.horizontalSeparatorInset = UIEdgeInsetsMake(0, 42, 0, 42);
        _headerView.verticalSeparatorInset = UIEdgeInsetsMake(22, 0, 22, 0);
        _headerView.dataSource = self;
    }
    return _headerView;
}

- (SSJLoanDetailChargeChangeHeaderView *)changeSectionHeaderView {
    if (!_changeSectionHeaderView) {
        __weak typeof(self) wself = self;
        _changeSectionHeaderView = [[SSJLoanDetailChargeChangeHeaderView alloc] init];
        _changeSectionHeaderView.expanded = YES;
        _changeSectionHeaderView.tapHandle = ^(SSJLoanDetailChargeChangeHeaderView *view) {
            NSMutableArray *section = [wself.cellItems ssj_safeObjectAtIndex:1];
            [section removeAllObjects];
            if (view.expanded) {
                if (wself.changeSectionHeaderView.expanded) {
                    for (SSJLoanChargeModel *chargeModel in wself.loanModel.chargeModels) {
                        [section addObject:[SSJLoanDetailCellItem cellItemWithChargeModel:chargeModel]];
                    }
                }
            }
            [wself.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        };
    }
    return _changeSectionHeaderView;
}

@end
