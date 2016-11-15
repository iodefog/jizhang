//
//  SSJLoanChargeDetailViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/11/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanChargeDetailViewController.h"
#import "SSJLoanDetailCell.h"
#import "SSJLoanChargeModel.h"
#import "SSJLoanCompoundChargeModel.h"
#import "SSJLoanHelper.h"

static NSString *const kSSJLoanDetailCellID = @"SSJLoanDetailCell";

@interface SSJLoanChargeDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIBarButtonItem *deleteItem;

@property (nonatomic, strong) NSMutableArray *cellItems;

@property (nonatomic, strong) SSJLoanCompoundChargeModel *compoundModel;

@end

@implementation SSJLoanChargeDetailViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _cellItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateTitle];
    [self showDeleteItemIfNeeded];
    [self.view addSubview:self.tableView];
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
- (void)loadData {
    [self.view ssj_showLoadingIndicator];
    [SSJLoanHelper queryLoanCompoundChangeModelWithChargeId:self.chargeId success:^(SSJLoanCompoundChargeModel * _Nonnull model) {
        [self.view ssj_hideLoadingIndicator];
        self.compoundModel = model;
        [self organiseCellItems];
        [self.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        [self.view ssj_hideLoadingIndicator];
        [self showError:error];
    }];
}

- (void)updateAppearance {
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}

- (void)showDeleteItemIfNeeded {
    // 只有未结清状态下，并且是余额变更才能显示删除按钮
    if (!self.compoundModel.closeOut) {
        if (self.compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceIncrease
            || self.compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceDecrease) {
            [self.navigationItem setRightBarButtonItem:self.deleteItem animated:YES];
        }
    }
}

- (void)updateTitle {
    switch (_compoundModel.chargeModel.chargeType) {
        case SSJLoanCompoundChargeTypeCreate: {
            switch (_compoundModel.chargeModel.type) {
                case SSJLoanTypeLend:
                    self.title = @"借出款";
                    break;
                    
                case SSJLoanTypeBorrow:
                    self.title = @"欠款";
                    break;
            }
        }
            break;
            
        case SSJLoanCompoundChargeTypeBalanceIncrease:
        case SSJLoanCompoundChargeTypeBalanceDecrease: {
            self.title = @"详情";
        }
            break;
            
        case SSJLoanCompoundChargeTypeRepayment: {
            switch (_compoundModel.chargeModel.type) {
                case SSJLoanTypeLend:
                    self.title = @"收款";
                    break;
                    
                case SSJLoanTypeBorrow:
                    self.title = @"还款";
                    break;
            }
        }
            break;
            
        case SSJLoanCompoundChargeTypeAdd: {
            switch (_compoundModel.chargeModel.type) {
                case SSJLoanTypeLend:
                    self.title = @"追加借出";
                    break;
                    
                case SSJLoanTypeBorrow:
                    self.title = @"追加还款";
                    break;
            }
        }
            break;
            
        case SSJLoanCompoundChargeTypeCloseOut:
            self.title = @"结清";
            break;
            
        case SSJLoanCompoundChargeTypeInterest:
            break;
    }
}

- (void)organiseCellItems {
    switch (_compoundModel.chargeModel.chargeType) {
        case SSJLoanCompoundChargeTypeCreate:
            [self organiseChargeTypeCreateItems];
            break;
            
        case SSJLoanCompoundChargeTypeBalanceIncrease:
        case SSJLoanCompoundChargeTypeBalanceDecrease:
            [self organiseChargeTypeBalanceChangeItems];
            break;
            
        case SSJLoanCompoundChargeTypeRepayment:
            [self organiseChargeTypeRepaymentItems];
            break;
            
        case SSJLoanCompoundChargeTypeAdd:
            [self organiseChargeTypeAddItems];
            break;
            
        case SSJLoanCompoundChargeTypeCloseOut:
            [self organiseChargeTypeCloseOutItems];
            break;
            
        case SSJLoanCompoundChargeTypeInterest:
            break;
    }
}

- (void)organiseChargeTypeCreateItems {
    
    NSString *moneyTitle = nil;
    NSString *dateTitle = nil;
    NSString *accountTitle = nil;
    NSString *lenderTitle = nil;
    
    switch (self.compoundModel.chargeModel.type) {
        case SSJLoanTypeLend:
            moneyTitle = @"借出金额";
            dateTitle = @"借出日期";
            accountTitle = @"转入账户";
            lenderTitle = @"被谁借款";
            break;
            
        case SSJLoanTypeBorrow:
            moneyTitle = @"欠款金额";
            dateTitle = @"欠款日期";
            accountTitle = @"转出账户";
            lenderTitle = @"欠谁钱款";
            break;
    }
    
    NSMutableArray *section_1 = [[NSMutableArray alloc] init];
    NSMutableArray *section_2 = [[NSMutableArray alloc] init];
    
    NSString *money = [NSString stringWithFormat:@"%.2f", self.compoundModel.chargeModel.money];
    [section_1 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_money"
                                                        title:moneyTitle
                                                     subtitle:money
                                                  bottomTitle:nil]];
    
    NSString *accountName = [SSJLoanHelper queryForFundNameWithID:self.compoundModel.targetChargeModel.fundId];
    [section_1 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_account"
                                                        title:accountTitle
                                                     subtitle:accountName
                                                  bottomTitle:nil]];
    
    if (self.compoundModel.chargeModel.memo.length) {
        [section_2 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_memo"
                                                            title:@"备注"
                                                         subtitle:self.compoundModel.chargeModel.memo
                                                      bottomTitle:nil]];
    }
    
    NSString *dateStr = [self.compoundModel.chargeModel.billDate formattedDateWithFormat:@"yyyy.MM.dd"];
    [section_2 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_calendar"
                                                        title:dateTitle
                                                     subtitle:dateStr
                                                  bottomTitle:nil]];
    
    [section_2 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_person"
                                                        title:lenderTitle
                                                     subtitle:self.compoundModel.lender
                                                  bottomTitle:nil]];
    
    [_cellItems removeAllObjects];
    [_cellItems addObject:section_1];
    [_cellItems addObject:section_2];
}

- (void)organiseChargeTypeBalanceChangeItems {
    
    NSString *moneyTitle = nil;
    NSString *accountTitle = @"账户";
    NSString *memoTitle = @"备注";
    NSString *dateTitle = @"更改日期";
    NSString *lenderTitle = nil;
    
    switch (self.compoundModel.chargeModel.type) {
        case SSJLoanTypeLend:
            moneyTitle = @"剩余借出款余额变更";
            lenderTitle = @"被谁借款";
            break;
            
        case SSJLoanTypeBorrow:
            moneyTitle = @"剩余欠款余额变更";
            lenderTitle = @"欠谁钱款";
            break;
    }
    
    NSMutableArray *section_1 = [[NSMutableArray alloc] init];
    NSMutableArray *section_2 = [[NSMutableArray alloc] init];
    
    NSString *money = [NSString stringWithFormat:@"%.2f", self.compoundModel.chargeModel.money];
    [section_1 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_money"
                                                        title:moneyTitle
                                                     subtitle:money
                                                  bottomTitle:nil]];
    
    NSString *accountName = [SSJLoanHelper queryForFundNameWithID:_compoundModel.targetChargeModel.fundId];
    [section_1 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_account"
                                                        title:accountTitle
                                                     subtitle:accountName
                                                  bottomTitle:nil]];
    
    if (self.compoundModel.chargeModel.memo.length) {
        [section_2 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_memo"
                                                            title:memoTitle
                                                         subtitle:self.compoundModel.chargeModel.memo
                                                      bottomTitle:nil]];
    }
    
    NSString *dateStr = [self.compoundModel.chargeModel.billDate formattedDateWithFormat:@"yyyy.MM.dd"];
    [section_2 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_calendar"
                                                        title:dateTitle
                                                     subtitle:dateStr
                                                  bottomTitle:nil]];
    
    [section_2 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_person"
                                                        title:lenderTitle
                                                     subtitle:self.compoundModel.lender
                                                  bottomTitle:nil]];
    
    [_cellItems removeAllObjects];
    [_cellItems addObject:section_1];
    [_cellItems addObject:section_2];
}

- (void)organiseChargeTypeRepaymentItems {
    
    NSString *moneyTitle = nil;
    NSString *interestTitle = nil;
    NSString *accountTitle = nil;
    NSString *memoTitle = @"备注";
    NSString *dateTitle = nil;
    NSString *lenderTitle = nil;
    
    switch (self.compoundModel.chargeModel.type) {
        case SSJLoanTypeLend:
            moneyTitle = @"收款金额";
            interestTitle = @"利息收入";
            accountTitle = @"转入账户";
            dateTitle = @"收款日期";
            lenderTitle = @"被谁借款";
            break;
            
        case SSJLoanTypeBorrow:
            moneyTitle = @"还款金额";
            interestTitle = @"利息支出";
            accountTitle = @"转出账户";
            dateTitle = @"还款日期";
            lenderTitle = @"欠谁钱款";
            break;
    }
    
    NSMutableArray *section_1 = [[NSMutableArray alloc] init];
    NSMutableArray *section_2 = [[NSMutableArray alloc] init];
    
    NSString *money = [NSString stringWithFormat:@"%.2f", self.compoundModel.targetChargeModel.money];
    [section_1 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_money"
                                                        title:moneyTitle
                                                     subtitle:money
                                                  bottomTitle:nil]];
    
    if (_compoundModel.interestChargeModel.money) {
        NSString *interest = [NSString stringWithFormat:@"%.2f", self.compoundModel.interestChargeModel.money];
        [section_1 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_yield"
                                                            title:interestTitle
                                                         subtitle:interest
                                                      bottomTitle:nil]];
    }
    
    NSString *accountName = [SSJLoanHelper queryForFundNameWithID:_compoundModel.targetChargeModel.fundId];
    [section_1 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_account"
                                                        title:accountTitle
                                                     subtitle:accountName
                                                  bottomTitle:nil]];
    
    if (self.compoundModel.chargeModel.memo.length) {
        [section_2 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_memo"
                                                            title:memoTitle
                                                         subtitle:self.compoundModel.chargeModel.memo
                                                      bottomTitle:nil]];
    }
    
    NSString *dateStr = [self.compoundModel.chargeModel.billDate formattedDateWithFormat:@"yyyy.MM.dd"];
    [section_2 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_calendar"
                                                        title:dateTitle
                                                     subtitle:dateStr
                                                  bottomTitle:nil]];
    
    [section_2 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_person"
                                                        title:lenderTitle
                                                     subtitle:_compoundModel.lender
                                                  bottomTitle:nil]];
    
    [_cellItems removeAllObjects];
    [_cellItems addObject:section_1];
    [_cellItems addObject:section_2];
}

- (void)organiseChargeTypeAddItems {
    
    NSString *moneyTitle = nil;
    NSString *accountTitle = nil;
    NSString *memoTitle = @"备注";
    NSString *dateTitle = @"日期";
    NSString *lenderTitle = nil;
    
    switch (self.compoundModel.chargeModel.type) {
        case SSJLoanTypeLend:
            moneyTitle = @"追加借出金额";
            accountTitle = @"转出账户";
            lenderTitle = @"被谁借款";
            break;
            
        case SSJLoanTypeBorrow:
            moneyTitle = @"追加欠款金额";
            accountTitle = @"转入账户";
            lenderTitle = @"欠谁钱款";
            break;
    }
    
    NSMutableArray *section_1 = [[NSMutableArray alloc] init];
    NSMutableArray *section_2 = [[NSMutableArray alloc] init];
    
    NSString *money = [NSString stringWithFormat:@"%.2f", self.compoundModel.chargeModel.money];
    [section_1 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_money"
                                                        title:moneyTitle
                                                     subtitle:money
                                                  bottomTitle:nil]];
    
    NSString *accountName = [SSJLoanHelper queryForFundNameWithID:_compoundModel.targetChargeModel.fundId];
    [section_1 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_account"
                                                        title:accountTitle
                                                     subtitle:accountName
                                                  bottomTitle:nil]];
    
    if (self.compoundModel.chargeModel.memo.length) {
        [section_2 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_memo"
                                                            title:memoTitle
                                                         subtitle:self.compoundModel.chargeModel.memo
                                                      bottomTitle:nil]];
    }
    
    NSString *dateStr = [self.compoundModel.chargeModel.billDate formattedDateWithFormat:@"yyyy.MM.dd"];
    [section_2 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_calendar"
                                                        title:dateTitle
                                                     subtitle:dateStr
                                                  bottomTitle:nil]];
    
    [section_2 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_person"
                                                        title:lenderTitle
                                                     subtitle:_compoundModel.lender
                                                  bottomTitle:nil]];
    
    [_cellItems removeAllObjects];
    [_cellItems addObject:section_1];
    [_cellItems addObject:section_2];
}

- (void)organiseChargeTypeCloseOutItems {
    
    NSString *moneyTitle = nil;
    NSString *interestTitle = nil;
    NSString *accountTitle = nil;
    NSString *dateTitle = @"结清日";
    NSString *lenderTitle = nil;
    
    switch (self.compoundModel.chargeModel.type) {
        case SSJLoanTypeLend:
            moneyTitle = @"借出款金额";
            interestTitle = @"利息收入";
            accountTitle = @"结清转入账户";
            lenderTitle = @"被谁借款";
            break;
            
        case SSJLoanTypeBorrow:
            moneyTitle = @"欠款金额";
            interestTitle = @"利息支出";
            accountTitle = @"结清转出账户";
            lenderTitle = @"欠谁钱款";
            break;
    }
    
    NSMutableArray *section_1 = [[NSMutableArray alloc] init];
    NSMutableArray *section_2 = [[NSMutableArray alloc] init];
    
    NSString *money = [NSString stringWithFormat:@"%.2f", self.compoundModel.targetChargeModel.money];
    [section_1 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_money"
                                                        title:moneyTitle
                                                     subtitle:money
                                                  bottomTitle:nil]];
    
    if (_compoundModel.interestChargeModel.money) {
        NSString *interest = [NSString stringWithFormat:@"%.2f", self.compoundModel.interestChargeModel.money];
        [section_1 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_yield"
                                                            title:interestTitle
                                                         subtitle:interest
                                                      bottomTitle:nil]];
    }
    
    NSString *accountName = [SSJLoanHelper queryForFundNameWithID:self.compoundModel.targetChargeModel.fundId];
    [section_1 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_account"
                                                        title:accountTitle
                                                     subtitle:accountName
                                                  bottomTitle:nil]];
    
    NSString *dateStr = [self.compoundModel.chargeModel.billDate formattedDateWithFormat:@"yyyy.MM.dd"];
    [section_2 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_calendar"
                                                        title:dateTitle
                                                     subtitle:dateStr
                                                  bottomTitle:nil]];
    
    [section_2 addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_person"
                                                        title:lenderTitle
                                                     subtitle:self.compoundModel.lender
                                                  bottomTitle:nil]];
    
    [_cellItems removeAllObjects];
    [_cellItems addObject:section_1];
    [_cellItems addObject:section_2];
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

#pragma mark - Event
- (void)deleteItemAction {
    self.deleteItem.enabled = NO;
    [SSJLoanHelper deleteLoanCompoundChargeModel:_compoundModel success:^{
        self.deleteItem.enabled = YES;
        [CDAutoHideMessageHUD showMessage:@"删除成功"];
        [self goBackAction];
    } failure:^(NSError * _Nonnull error) {
        self.deleteItem.enabled = YES;
        NSString *message = nil;
#ifdef DEBUG
        message = [error localizedDescription];
#else
        message = SSJ_ERROR_MESSAGE;
#endif
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:message action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        _tableView.sectionFooterHeight = 0;
        _tableView.rowHeight = 54;
        [_tableView registerClass:[SSJLoanDetailCell class] forCellReuseIdentifier:kSSJLoanDetailCellID];
    }
    return _tableView;
}

- (UIBarButtonItem *)deleteItem {
    if (!_deleteItem) {
        _deleteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteItemAction)];
    }
    return _deleteItem;
}

@end
