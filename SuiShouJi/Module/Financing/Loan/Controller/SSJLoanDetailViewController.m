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
#import "SSJLoanDetailCell.h"
#import "SSJLoanHelper.h"
#import "SSJLocalNotificationStore.h"
#import "SSJDataSynchronizer.h"

static NSString *const kSSJLoanDetailCellID = @"SSJLoanDetailCell";

@interface SSJLoanDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *closeOutBtn;

@property (nonatomic, strong) UIButton *revertBtn;

@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) UIImageView *stampView;

@property (nonatomic, strong) UIBarButtonItem *editItem;

@property (nonatomic, strong) NSArray *cellItems;

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
    return 10;
}

#pragma mark - Private
- (void)updateAppearance {
    
    CGFloat alpha = [[SSJThemeSetting currentThemeModel].ID isEqualToString:SSJDefaultThemeID] ? 0 : 0.1;
    _tableView.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:alpha];
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    
    [_closeOutBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
    
    [_revertBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:UIControlStateNormal];
    [_revertBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor] forState:UIControlStateNormal];
    
    [_deleteBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
    [_deleteBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor] forState:UIControlStateNormal];
}

- (void)organiseCellItems {
    if (_loanModel.closeOut) {
        
        NSString *borrowMoneyStr = [NSString stringWithFormat:@"¥%.2f", _loanModel.jMoney];
        
        double interest = 0;
        if ([_loanModel.endDate compare:_loanModel.borrowDate] != NSOrderedAscending) {
            interest = ([_loanModel.endDate daysFrom:_loanModel.borrowDate] + 1) * _loanModel.rate * _loanModel.jMoney / 365;
        }
        NSString *interestStr = [NSString stringWithFormat:@"¥%.2f", interest];
        
        NSString *accountName = [SSJLoanHelper queryForFundNameWithID:_loanModel.targetFundID];
        NSString *endAccountName = [SSJLoanHelper queryForFundNameWithID:_loanModel.endTargetFundID];
        
        NSString *borrowDateStr = [_loanModel.borrowDate formattedDateWithFormat:@"yyyy.MM.dd"];
        
        NSString *closeOutDateStr = [_loanModel.endDate formattedDateWithFormat:@"yyyy.MM.dd"];
        
        int overlapDays = (int)[_loanModel.endDate daysFrom:_loanModel.repaymentDate];
        NSString *overlapDaysStr = [NSString stringWithFormat:@"%d天", MAX(overlapDays, 0)];
        
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                _cellItems = @[@[[SSJLoanDetailCellItem itemWithImage:@"loan_person" title:@"借款人" subtitle:_loanModel.lender],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_money" title:@"借出金额" subtitle:borrowMoneyStr]],
                               @[[SSJLoanDetailCellItem itemWithImage:@"loan_yield" title:@"利息收入" subtitle:interestStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_account" title:@"借出账户" subtitle:accountName],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_closeOut" title:@"结清账户" subtitle:endAccountName]],
                               @[[SSJLoanDetailCellItem itemWithImage:@"loan_calendar" title:@"借款日" subtitle:borrowDateStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_expires" title:@"结清日" subtitle:closeOutDateStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_clock" title:@"超出还款日" subtitle:overlapDaysStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_memo" title:@"备注" subtitle:_loanModel.memo]]];
                break;
                
            case SSJLoanTypeBorrow:
                _cellItems = @[@[[SSJLoanDetailCellItem itemWithImage:@"loan_person" title:@"欠谁钱款" subtitle:_loanModel.lender],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_money" title:@"欠款金额" subtitle:borrowMoneyStr]],
                               @[[SSJLoanDetailCellItem itemWithImage:@"loan_yield" title:@"利息收入" subtitle:interestStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_account" title:@"借入账户" subtitle:accountName],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_closeOut" title:@"结清账户" subtitle:endAccountName]],
                               @[[SSJLoanDetailCellItem itemWithImage:@"loan_calendar" title:@"欠款日" subtitle:borrowDateStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_expires" title:@"结算日" subtitle:closeOutDateStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_clock" title:@"超出还款日" subtitle:overlapDaysStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_memo" title:@"备注" subtitle:_loanModel.memo]]];
                break;
        }
    } else {
        
        NSString *borrowMoneyStr = [NSString stringWithFormat:@"¥%.2f", _loanModel.jMoney];
        
        NSDate *today = [NSDate date];
        today = [NSDate dateWithYear:today.year month:today.month day:today.day];
        
        NSString *interestStr = @"¥0.00";
        if ([today compare:_loanModel.borrowDate] != NSOrderedAscending) {
            double interest = ([today daysFrom:_loanModel.borrowDate] + 1) * _loanModel.rate / 365;
            interestStr = [NSString stringWithFormat:@"¥%.2f", interest];
        }
        
        double expectedInterest = ([_loanModel.repaymentDate daysFrom:_loanModel.borrowDate] + 1) * _loanModel.rate * _loanModel.jMoney / 365;
        NSString *expectedInterestStr = [NSString stringWithFormat:@"¥%.2f", expectedInterest];
        
        NSString *accountName = [SSJLoanHelper queryForFundNameWithID:_loanModel.targetFundID];
        
        NSString *borrowDateStr = [_loanModel.borrowDate formattedDateWithFormat:@"yyyy.MM.dd"];
        NSString *repaymentDateStr = [_loanModel.repaymentDate formattedDateWithFormat:@"yyyy.MM.dd"];
        
        NSString *daysFromRepaymentTitle = nil;
        NSString *daysFromRepaymentDateStr = nil;
        if ([today compare:_loanModel.repaymentDate] == NSOrderedAscending) {
            daysFromRepaymentTitle = @"距还款日";
            daysFromRepaymentDateStr = [NSString stringWithFormat:@"%d天", (int)[_loanModel.repaymentDate daysFrom:today]];
        } else {
            daysFromRepaymentTitle = @"超出还款日";
            daysFromRepaymentDateStr = [NSString stringWithFormat:@"%d天", (int)[today daysFrom:_loanModel.repaymentDate]];
        }
        
        NSString *remindDateStr = @"关闭";
        if (_loanModel.remindID.length) {
            SSJReminderItem *remindItem = [SSJLocalNotificationStore queryReminderItemForID:_loanModel.remindID];
            if (remindItem.remindState) {
                remindDateStr = [remindItem.remindDate formattedDateWithFormat:@"yyyy.MM.dd"];
            }
        }
        
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                _cellItems = @[@[[SSJLoanDetailCellItem itemWithImage:@"loan_person" title:@"借款人" subtitle:_loanModel.lender],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_money" title:@"借出金额" subtitle:borrowMoneyStr]],
                               @[[SSJLoanDetailCellItem itemWithImage:@"loan_yield" title:@"已产生利息" subtitle:interestStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_expectedInterest" title:@"预期利息" subtitle:expectedInterestStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_account" title:@"借出账户" subtitle:accountName]],
                               @[[SSJLoanDetailCellItem itemWithImage:@"loan_calendar" title:@"借款日" subtitle:borrowDateStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_expires" title:@"还款日" subtitle:repaymentDateStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_clock" title:daysFromRepaymentTitle subtitle:daysFromRepaymentDateStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_memo" title:@"备注" subtitle:_loanModel.memo]],
                               @[[SSJLoanDetailCellItem itemWithImage:@"loan_remind" title:@"到期日提醒" subtitle:remindDateStr]]];
                break;
                
            case SSJLoanTypeBorrow:
                _cellItems = @[@[[SSJLoanDetailCellItem itemWithImage:@"loan_person" title:@"欠谁钱款" subtitle:_loanModel.lender],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_money" title:@"欠款金额" subtitle:borrowMoneyStr]],
                               @[[SSJLoanDetailCellItem itemWithImage:@"loan_yield" title:@"已产生利息" subtitle:interestStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_expectedInterest" title:@"预期利息" subtitle:expectedInterestStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_account" title:@"借入账户" subtitle:accountName]],
                               @[[SSJLoanDetailCellItem itemWithImage:@"loan_calendar" title:@"欠款日" subtitle:borrowDateStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_expires" title:@"还款日" subtitle:repaymentDateStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_clock" title:daysFromRepaymentTitle subtitle:daysFromRepaymentDateStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"loan_memo" title:@"备注" subtitle:_loanModel.memo]],
                               @[[SSJLoanDetailCellItem itemWithImage:@"loan_remind" title:@"到期日提醒" subtitle:remindDateStr]]];
                break;
        }
    }
}

- (void)loadLoanModel {
    [self.view ssj_showLoadingIndicator];
    [SSJLoanHelper queryForLoanModelWithLoanID:_loanID success:^(SSJLoanModel * _Nonnull model) {
        [self.view ssj_hideLoadingIndicator];
        self.loanModel = model;
        [self updateTitle];
        [self organiseCellItems];
        [self updateSubViewHidden];
        [self.tableView reloadData];
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
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError * _Nonnull error) {
        self.revertBtn.enabled = YES;
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
}

- (void)deleteBtnAction {
    __weak typeof(self) wself = self;
    [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"确认要删除此项目么？" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:NULL], [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction *action) {
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
    }
    return _deleteBtn;
}

- (UIImageView *)stampView {
    if (!_stampView) {
        _stampView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loan_stamp"]];
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

@end
