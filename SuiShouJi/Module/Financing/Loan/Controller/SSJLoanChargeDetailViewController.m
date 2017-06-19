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
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJLoanHelper queryLoanCompoundChangeModelWithChargeId:self.chargeId success:^(SSJLoanCompoundChargeModel * _Nonnull model) {
            self.compoundModel = model;
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [self organiseCellItems:^{
                [subscriber sendCompleted];
            }];
            return nil;
        }];
    }] subscribeError:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showError:error];
    } completed:^{
        [self.view ssj_hideLoadingIndicator];
        [self updateTitle];
        [self.tableView reloadData];
        [self showDeleteItemIfNeeded];
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

- (void)organiseCellItems:(void(^)())completion {
    switch (_compoundModel.chargeModel.chargeType) {
        case SSJLoanCompoundChargeTypeCreate:
            [self organiseChargeTypeCreateItems:completion];
            break;
            
        case SSJLoanCompoundChargeTypeBalanceIncrease:
        case SSJLoanCompoundChargeTypeBalanceDecrease:
            [self organiseChargeTypeBalanceChangeItems:completion];
            break;
            
        case SSJLoanCompoundChargeTypeRepayment:
            [self organiseChargeTypeRepaymentItems:completion];
            break;
            
        case SSJLoanCompoundChargeTypeAdd:
            [self organiseChargeTypeAddItems:completion];
            break;
            
        case SSJLoanCompoundChargeTypeCloseOut:
            [self organiseChargeTypeCloseOutItems:completion];
            break;
            
        case SSJLoanCompoundChargeTypeInterest:
            break;
    }
}

- (void)organiseChargeTypeCreateItems:(void(^)())completion {
    [SSJLoanHelper queryForFundNameWithID:self.compoundModel.targetChargeModel.fundId completion:^(NSString * _Nonnull name) {
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
        
        NSString *accountName = name;
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
        
        if (completion) {
            completion();
        }
    }];
}

- (void)organiseChargeTypeBalanceChangeItems:(void(^)())completion {
    [SSJLoanHelper queryForFundNameWithID:_compoundModel.targetChargeModel.fundId completion:^(NSString * _Nonnull name) {
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
        
        NSString *accountName = name;
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
        
        if (completion) {
            completion();
        }
    }];
}

- (void)organiseChargeTypeRepaymentItems:(void(^)())completion {
    [SSJLoanHelper queryForFundNameWithID:_compoundModel.targetChargeModel.fundId completion:^(NSString * _Nonnull name) {
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
        
        NSString *accountName = name;
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
        
        if (completion) {
            completion();
        }
    }];
}

- (void)organiseChargeTypeAddItems:(void(^)())completion {
    [SSJLoanHelper queryForFundNameWithID:_compoundModel.targetChargeModel.fundId completion:^(NSString * _Nonnull name) {
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
        
        NSString *accountName = name;
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
        
        if (completion) {
            completion();
        }
    }];
}

- (void)organiseChargeTypeCloseOutItems:(void(^)())completion {
    [SSJLoanHelper queryForFundNameWithID:self.compoundModel.targetChargeModel.fundId completion:^(NSString * _Nonnull name) {
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
        
        NSString *accountName = name;
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
        
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Event
- (void)deleteItemAction {
    [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"您确认删除该记录" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:NULL], [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction *action) {
        
        self.deleteItem.enabled = NO;
        
        [SSJLoanHelper deleteLoanCompoundChargeModel:_compoundModel success:^{
            self.deleteItem.enabled = YES;
            [CDAutoHideMessageHUD showMessage:@"删除成功"];
            [self goBackAction];
        } failure:^(NSError * _Nonnull error) {
            self.deleteItem.enabled = YES;
            [SSJAlertViewAdapter showError:error];
        }];
        
    }], nil];
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
