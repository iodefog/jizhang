//
//  SSJLoanDetailViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/8/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanDetailViewController.h"
#import "SSJAddOrEditLoanViewController.h"
#import "SSJLoanDetailCell.h"
#import "SSJLoanHelper.h"
#import "SSJLocalNotificationStore.h"

static NSString *const kSSJLoanDetailCellID = @"SSJLoanDetailCell";

@interface SSJLoanDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *closeOutBtn;

@property (nonatomic, strong) UIButton *revertBtn;

@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) UIImageView *stampView;

@property (nonatomic, strong) NSArray *cellItems;

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
    
    switch (_loanModel.type) {
        case SSJLoanTypeLend:
            self.title = @"借出款详情";
            break;
            
        case SSJLoanTypeBorrow:
            self.title = @"欠款详情";
            break;
    }
    
    [self.view addSubview:self.tableView];
    
    if (_loanModel.closeOut) {
        [self.view addSubview:self.revertBtn];
        [self.view addSubview:self.deleteBtn];
        [self.view addSubview:self.stampView];
    } else {
        [self.view addSubview:self.closeOutBtn];
        
        UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editAction)];
        self.navigationItem.rightBarButtonItem = editItem;
    }
    
    [self updateAppearance];
    [self organiseCellItems];
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
        
        NSDate *borrowDate = [NSDate dateWithString:_loanModel.borrowDate formatString:@"yyyy-MM-dd"];
        NSDate *repaymentDate = [NSDate dateWithString:_loanModel.repaymentDate formatString:@"yyyy-MM-dd"];
        NSDate *closeOutDate = [NSDate dateWithString:_loanModel.endDate formatString:@"yyyy-MM-dd"];
        
        double interest = 0;
        if ([closeOutDate compare:borrowDate] != NSOrderedAscending) {
            interest = ([closeOutDate daysFrom:borrowDate] + 1) * _loanModel.rate / 365;
        }
        NSString *interestStr = [NSString stringWithFormat:@"¥%.2f", interest];
        
        NSString *accountName = [SSJLoanHelper queryForFundNameWithID:_loanModel.targetFundID];
        
        NSString *borrowDateStr = [borrowDate formattedDateWithFormat:@"yyyy.MM.dd"];
        
        NSString *closeOutDateStr = [closeOutDate formattedDateWithFormat:@"yyyy.MM.dd"];
        
        int overlapDays = (int)[closeOutDate daysFrom:repaymentDate];
        NSString *overlapDaysStr = [NSString stringWithFormat:@"%d天", MIN(overlapDays, 0)];
        
        
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                _cellItems = @[@[[SSJLoanDetailCellItem itemWithImage:@"" title:@"借款人" subtitle:_loanModel.lender],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:@"借出金额" subtitle:borrowMoneyStr]],
                               @[[SSJLoanDetailCellItem itemWithImage:@"" title:@"利息收入" subtitle:interestStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:@"借出账户" subtitle:accountName]],
                               @[[SSJLoanDetailCellItem itemWithImage:@"" title:@"借款日" subtitle:borrowDateStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:@"结清日" subtitle:closeOutDateStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:@"超出还款日" subtitle:overlapDaysStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:@"备注" subtitle:_loanModel.memo]]];
                break;
                
            case SSJLoanTypeBorrow:
                _cellItems = @[@[[SSJLoanDetailCellItem itemWithImage:@"" title:@"向谁借款" subtitle:_loanModel.lender],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:@"借入金额" subtitle:borrowMoneyStr]],
                               @[[SSJLoanDetailCellItem itemWithImage:@"" title:@"利息收入" subtitle:interestStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:@"借入账户" subtitle:accountName]],
                               @[[SSJLoanDetailCellItem itemWithImage:@"" title:@"借款日" subtitle:borrowDateStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:@"结算日" subtitle:closeOutDateStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:@"超出还款日" subtitle:overlapDaysStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:@"备注" subtitle:_loanModel.memo]]];
                break;
        }
    } else {
        
        NSString *borrowMoneyStr = [NSString stringWithFormat:@"¥%.2f", _loanModel.jMoney];
        
        NSDate *borrowDate = [NSDate dateWithString:_loanModel.borrowDate formatString:@"yyyy-MM-dd"];
        NSDate *repaymentDate = [NSDate dateWithString:_loanModel.repaymentDate formatString:@"yyyy-MM-dd"];
        
        NSDate *today = [NSDate date];
        today = [NSDate dateWithYear:today.year month:today.month day:today.day];
        
        NSString *interestStr = @"¥0.00";
        if ([today compare:borrowDate] != NSOrderedAscending) {
            double interest = ([today daysFrom:borrowDate] + 1) * _loanModel.rate / 365;
            interestStr = [NSString stringWithFormat:@"¥%.2f", interest];
        }
        
        double expectedInterest = ([repaymentDate daysFrom:borrowDate] + 1) * _loanModel.rate / 365;
        NSString *expectedInterestStr = [NSString stringWithFormat:@"¥%.2f", expectedInterest];
        
        NSString *accountName = [SSJLoanHelper queryForFundNameWithID:_loanModel.targetFundID];
        
        NSString *borrowDateStr = [borrowDate formattedDateWithFormat:@"yyyy.MM.dd"];
        NSString *repaymentDateStr = [repaymentDate formattedDateWithFormat:@"yyyy.MM.dd"];
        
        NSString *daysFromRepaymentTitle = nil;
        NSString *daysFromRepaymentDateStr = nil;
        if ([today compare:repaymentDate] == NSOrderedAscending) {
            daysFromRepaymentTitle = @"距还款日";
            daysFromRepaymentDateStr = [NSString stringWithFormat:@"%d天", (int)[repaymentDate daysFrom:today]];
        } else {
            daysFromRepaymentTitle = @"超出还款日";
            daysFromRepaymentDateStr = [NSString stringWithFormat:@"%d天", (int)[today daysFrom:repaymentDate]];
        }
        
        NSString *remindDateStr = @"未设置";
        if (_loanModel.remindID.length) {
            SSJReminderItem *remindItem = [SSJLocalNotificationStore queryReminderItemForID:_loanModel.remindID];
            if (remindItem.remindState) {
                remindDateStr = [remindItem.remindDate formattedDateWithFormat:@"yyyy.MM.dd"];
            } else {
                remindDateStr = @"关闭";
            }
        }
        
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                _cellItems = @[@[[SSJLoanDetailCellItem itemWithImage:@"" title:@"借款人" subtitle:_loanModel.lender],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:@"借出金额" subtitle:borrowMoneyStr]],
                               @[[SSJLoanDetailCellItem itemWithImage:@"" title:@"已产生利息" subtitle:interestStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:@"预期利息" subtitle:expectedInterestStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:@"借出账户" subtitle:accountName]],
                               @[[SSJLoanDetailCellItem itemWithImage:@"" title:@"借款日" subtitle:borrowDateStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:@"还款日" subtitle:repaymentDateStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:daysFromRepaymentTitle subtitle:daysFromRepaymentDateStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:@"备注" subtitle:_loanModel.memo]],
                               @[[SSJLoanDetailCellItem itemWithImage:@"" title:@"到期日提醒" subtitle:remindDateStr]]];
                break;
                
            case SSJLoanTypeBorrow:
                _cellItems = @[@[[SSJLoanDetailCellItem itemWithImage:@"" title:@"欠谁欠款" subtitle:_loanModel.lender],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:@"借入金额" subtitle:borrowMoneyStr]],
                               @[[SSJLoanDetailCellItem itemWithImage:@"" title:@"已产生利息" subtitle:interestStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:@"预期利息" subtitle:expectedInterestStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:@"借入账户" subtitle:accountName]],
                               @[[SSJLoanDetailCellItem itemWithImage:@"" title:@"借款日" subtitle:borrowDateStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:@"还款日" subtitle:repaymentDateStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:daysFromRepaymentTitle subtitle:daysFromRepaymentDateStr],
                                 [SSJLoanDetailCellItem itemWithImage:@"" title:@"备注" subtitle:_loanModel.memo]],
                               @[[SSJLoanDetailCellItem itemWithImage:@"" title:@"到期日提醒" subtitle:remindDateStr]]];
                break;
        }
    }
}

#pragma mark - Event
- (void)editAction {
    SSJAddOrEditLoanViewController *editLoanVC = [[SSJAddOrEditLoanViewController alloc] init];
    editLoanVC.loanModel = _loanModel;
    [self.navigationController pushViewController:editLoanVC animated:YES];
}

- (void)closeOutBtnAction {
    
}

- (void)revertBtnAction {
    
}

- (void)deleteBtnAction {
    
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
    }
    return _deleteBtn;
}

- (UIImageView *)stampView {
    if (!_stampView) {
        _stampView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        _stampView.center = CGPointMake(self.tableView.width * 0.5, self.tableView.height * 0.32);
    }
    return _stampView;
}

@end
