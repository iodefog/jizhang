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
#import "SSJLoanChargeDetailViewController.h"
#import "SSJLoanChargeAddOrEditViewController.h"
#import "SSJLoanDetailChargeChangeHeaderView.h"
#import "SSJFinancingDetailHeadeView.h"
#import "SSJLoanDetailCell.h"
#import "SSJLoanChangeChargeSelectionControl.h"
#import "SSJLoanHelper.h"
#import "SSJLocalNotificationStore.h"
#import "SSJDataSynchronizer.h"

static NSString *const kSSJLoanDetailCellID = @"SSJLoanDetailCell";

@interface SSJLoanDetailViewController () <UITableViewDataSource, UITableViewDelegate, SSJFinancingDetailHeadeViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *closeOutBtn;

@property (nonatomic, strong) UIButton *changeBtn;

@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) UIImageView *stampView;

@property (nonatomic, strong) SSJFinancingDetailHeadeView *headerView;

@property (nonatomic, strong) SSJLoanDetailChargeChangeHeaderView *changeSectionHeaderView;

@property (nonatomic, strong) SSJLoanChangeChargeSelectionControl *changeChargeSelectionView;

@property (nonatomic, strong) UIBarButtonItem *editItem;

@property (nonatomic, strong) NSMutableArray <SSJLoanDetailCellItem *>*section1Items;

@property (nonatomic, strong) NSMutableArray <SSJLoanDetailCellItem *>*section2Items;

@property (nonatomic, strong) NSArray *headerItems;

@property (nonatomic, strong) SSJLoanModel *loanModel;

@property (nonatomic, strong) NSArray <SSJLoanCompoundChargeModel *>*chargeModels;

@end

@implementation SSJLoanDetailViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
        self.navigationBarBaseLineColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:0.5];
        self.section1Items = [[NSMutableArray alloc] init];
        self.section2Items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.changeBtn];
    [self.view addSubview:self.deleteBtn];
    [self.view addSubview:self.closeOutBtn];
    [self.tableView addSubview:self.stampView];
    self.stampView.layer.zPosition = 100;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadData];
    [self updateAppearance];
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
    if (section == 0) {
        return self.section1Items.count;
    } else if (section == 1) {
        return self.section2Items.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJLoanDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:kSSJLoanDetailCellID forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.cellItem = [self.section1Items ssj_safeObjectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        cell.cellItem = [self.section2Items ssj_safeObjectAtIndex:indexPath.row];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        SSJLoanDetailCellItem *cellItem = [self.section1Items ssj_safeObjectAtIndex:indexPath.row];
        return cellItem.rowHeight;
    } else if (indexPath.section == 1) {
        SSJLoanDetailCellItem *cellItem = [self.section2Items ssj_safeObjectAtIndex:indexPath.row];
        return cellItem.rowHeight;
    } else {
        return 0;
    }
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
    if (section == 1) {
        return self.changeSectionHeaderView;
    }
    return [UIView new];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        SSJLoanDetailCellItem *item = [self.section2Items ssj_safeObjectAtIndex:indexPath.row];
        if (self.loanModel.closeOut
            || item.chargeType == SSJLoanCompoundChargeTypeCreate
            || item.chargeType == SSJLoanCompoundChargeTypeBalanceIncrease
            || item.chargeType == SSJLoanCompoundChargeTypeBalanceDecrease) {
            
            SSJLoanChargeDetailViewController *chargeDetailController = [[SSJLoanChargeDetailViewController alloc] init];
            chargeDetailController.chargeId = item.chargeId;
            [self.navigationController pushViewController:chargeDetailController animated:YES];
            
        } else {
            
            SSJLoanChargeAddOrEditViewController *chargeEditController = [[SSJLoanChargeAddOrEditViewController alloc] init];
            chargeEditController.edited = YES;
            chargeEditController.chargeId = item.chargeId;
            [self.navigationController pushViewController:chargeEditController animated:YES];
            
        }
    }
}

#pragma mark - SSJSeparatorFormViewDataSource
- (NSUInteger)numberOfRowsInSeparatorFormView:(SSJFinancingDetailHeadeView *)view {
    return _headerItems.count;
}

- (NSUInteger)separatorFormView:(SSJFinancingDetailHeadeView *)view numberOfCellsInRow:(NSUInteger)row {
    return [[_headerItems ssj_safeObjectAtIndex:row] count];
}

- (SSJFinancingDetailHeadeViewCellItem *)separatorFormView:(SSJFinancingDetailHeadeView *)view itemForCellAtIndex:(NSIndexPath *)index {
    return [_headerItems ssj_objectAtIndexPath:index];
}

#pragma mark - Private
- (void)updateAppearance {
    
    _headerView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    [_changeSectionHeaderView updateAppearance];
    [_changeChargeSelectionView updateAppearance];
    
    _closeOutBtn.backgroundColor = _deleteBtn.backgroundColor  = _changeBtn.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
    
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        [_closeOutBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.bookKeepingHomeMutiButtonSelectColor] forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.bookKeepingHomeMutiButtonSelectColor] forState:UIControlStateNormal];
    } else {
        [_closeOutBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
    }
    
    [_changeBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:UIControlStateNormal];
    
    
    [_changeBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    [_closeOutBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    [_deleteBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
}

- (void)organiseHeaderItems {
    double surplus = 0;     // 剩余金额
    double loanSum = 0;     // 借贷总额
    double interest = 0;    // 产生利息
    double payment = 0;     // 已收、已还金额
    
    for (SSJLoanCompoundChargeModel *compoundModel in _chargeModels) {
        switch (compoundModel.chargeModel.chargeType) {
            case SSJLoanCompoundChargeTypeCreate:
                surplus = compoundModel.chargeModel.money;
                loanSum = compoundModel.chargeModel.money;
                break;
                
            case SSJLoanCompoundChargeTypeBalanceIncrease:
                surplus += compoundModel.chargeModel.money;
                loanSum += compoundModel.chargeModel.money;
                break;
                
            case SSJLoanCompoundChargeTypeBalanceDecrease:
                surplus -= compoundModel.chargeModel.money;
                loanSum -= compoundModel.chargeModel.money;
                break;
                
            case SSJLoanCompoundChargeTypeRepayment:
                surplus -= compoundModel.chargeModel.money;
                payment += compoundModel.chargeModel.money;
                break;
                
            case SSJLoanCompoundChargeTypeAdd:
                surplus += compoundModel.chargeModel.money;
                loanSum += compoundModel.chargeModel.money;
                break;
                
            case SSJLoanCompoundChargeTypeCloseOut:
                surplus -= compoundModel.chargeModel.money;
                payment += compoundModel.chargeModel.money;
                break;
                
            case SSJLoanCompoundChargeTypeInterest:
                break;
        }
        
        if (compoundModel.interestChargeModel.money > 0) {
            interest += compoundModel.interestChargeModel.money;
        }
    }
    
    NSString *surplusTitle = nil;
    NSString *surplusValue = nil;
    NSString *sumTitle = nil;
    NSString *interestTitle = nil;
    NSString *paymentTitle = nil;
    NSString *lenderTitle = nil;
    
    switch (self.loanModel.type) {
        case SSJLoanTypeLend: {
            surplusTitle = @"剩余借出款";
            surplusValue = [NSString stringWithFormat:@"%.2f", surplus];
            sumTitle = @"借出总额";
            interestTitle = self.loanModel.closeOut ? @"利息收入" : @"已收利息";
            paymentTitle = @"已收金额";
            lenderTitle = @"被谁借款";
        }
            break;
            
        case SSJLoanTypeBorrow: {
            surplusTitle = @"剩余欠款";
            surplusValue = (surplus == 0) ? [NSString stringWithFormat:@"%.2f", surplus] : [NSString stringWithFormat:@"-%.2f", surplus];
            sumTitle = @"欠款总额";
            interestTitle = self.loanModel.closeOut ? @"利息支出" : @"已还利息";
            paymentTitle = @"已还金额";
            lenderTitle = @"欠谁钱款";
        }
            break;
    }
    
    SSJFinancingDetailHeadeViewCellItem *surplusItem = [SSJFinancingDetailHeadeViewCellItem itemWithTopTitle:surplusTitle
                                                                                   bottomTitle:surplusValue
                                                                                 topTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailSecondaryColor alpha:SSJ_CURRENT_THEME.financingDetailSecondaryAlpha]
                                                                              bottomTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailMainColor alpha:SSJ_CURRENT_THEME.financingDetailMainAlpha]
                                                                                                topTitleFont:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_6]
                                                                               bottomTitleFont:[UIFont ssj_pingFangRegularFontOfSize:24] contentInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    
    SSJFinancingDetailHeadeViewCellItem *sumItem = [SSJFinancingDetailHeadeViewCellItem itemWithTopTitle:sumTitle
                                                                               bottomTitle:[NSString stringWithFormat:@"%.2f", loanSum]
                                                                             topTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailSecondaryColor alpha:SSJ_CURRENT_THEME.financingDetailSecondaryAlpha]
                                                                          bottomTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailMainColor alpha:SSJ_CURRENT_THEME.financingDetailMainAlpha]
                                                                              topTitleFont:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_6]
                                                                           bottomTitleFont:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3]
                                                                             contentInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    
    SSJFinancingDetailHeadeViewCellItem *interestItem = nil;
    if (interest > 0) {
        interestItem = [SSJFinancingDetailHeadeViewCellItem itemWithTopTitle:interestTitle
                                                          bottomTitle:[NSString stringWithFormat:@"%.2f", interest]
                                                        topTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailSecondaryColor alpha:SSJ_CURRENT_THEME.financingDetailSecondaryAlpha]
                                                     bottomTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailMainColor alpha:SSJ_CURRENT_THEME.financingDetailMainAlpha]
                                                         topTitleFont:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_6]
                                                      bottomTitleFont:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3]
                                                        contentInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    } else {
        interestItem = [SSJFinancingDetailHeadeViewCellItem itemWithTopTitle:paymentTitle
                                                          bottomTitle:[NSString stringWithFormat:@"%.2f", payment]
                                                          topTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailSecondaryColor alpha:SSJ_CURRENT_THEME.financingDetailSecondaryAlpha]
                                                          bottomTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailMainColor alpha:SSJ_CURRENT_THEME.financingDetailMainAlpha]
                                                         topTitleFont:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_6]
                                                      bottomTitleFont:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3]
                                                        contentInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    }
    
    SSJFinancingDetailHeadeViewCellItem *lenderItem = [SSJFinancingDetailHeadeViewCellItem itemWithTopTitle:lenderTitle
                                                                                  bottomTitle:self.loanModel.lender
                                                                                topTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailSecondaryColor alpha:SSJ_CURRENT_THEME.financingDetailSecondaryAlpha]
                                                                             bottomTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailMainColor alpha:SSJ_CURRENT_THEME.financingDetailMainAlpha]
                                                                                 topTitleFont:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_6]
                                                                              bottomTitleFont:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3]
                                                                                contentInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    
    _headerItems = @[@[surplusItem], @[sumItem, interestItem, lenderItem]];
}

- (void)reorganiseSection1Items:(void(^)())completion {

    [self.section1Items removeAllObjects];
    
    if (_loanModel.closeOut) {
        
        __block NSString *accountName = nil;
        __block NSString *endAccountName = nil;
        
        [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [SSJLoanHelper queryForFundNameWithID:_loanModel.targetFundID completion:^(NSString * _Nonnull name) {
                accountName = name;
                [subscriber sendCompleted];
            }];
            return nil;
        }] then:^RACSignal *{
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                [SSJLoanHelper queryForFundNameWithID:_loanModel.endTargetFundID completion:^(NSString * _Nonnull name) {
                    endAccountName = name;
                    [subscriber sendCompleted];
                }];
                return nil;
            }];
        }] subscribeCompleted:^{
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
            
            [self.section1Items addObjectsFromArray:@[[SSJLoanDetailCellItem itemWithImage:@"loan_expires" title:@"结清日" subtitle:closeOutDateStr bottomTitle:nil],
                                                      [SSJLoanDetailCellItem itemWithImage:@"loan_calendar" title:loanDayTitle subtitle:borrowDateStr bottomTitle:nil],
                                                      [SSJLoanDetailCellItem itemWithImage:@"loan_closeOut" title:@"结清账户" subtitle:endAccountName bottomTitle:nil],
                                                      [SSJLoanDetailCellItem itemWithImage:@"loan_account" title:loanAccountTitle subtitle:accountName bottomTitle:nil]]];
            
            if (_loanModel.memo.length) {
                [self.section1Items addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_memo" title:@"备注" subtitle:_loanModel.memo bottomTitle:nil]];
            }
            
            if (completion) {
                completion();
            }
        }];
        
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
        [self.section1Items addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_calendar" title:loanDateTitle subtitle:borrowDateStr bottomTitle:nil]];
        
        if (_loanModel.repaymentDate) {
            NSString *repaymentDateStr = [_loanModel.repaymentDate formattedDateWithFormat:@"yyyy.MM.dd"];
            [self.section1Items addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_expires" title:@"还款日" subtitle:repaymentDateStr bottomTitle:nil]];
        } else {
            if (_loanModel.remindID.length) {
                NSString *remindDateStr = @"关闭";
                SSJReminderItem *remindItem = [SSJLocalNotificationStore queryReminderItemForID:_loanModel.remindID];
                if (remindItem.remindState) {
                    remindDateStr = [remindItem.remindDate formattedDateWithFormat:@"yyyy.MM.dd"];
                }
                [self.section1Items addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_remind" title:@"到期日提醒" subtitle:remindDateStr bottomTitle:nil]];
            }
        }
        
        if (_loanModel.interest) {
            if (_loanModel.repaymentDate) {
                double interest = [SSJLoanHelper caculateInterestUntilDate:_loanModel.repaymentDate model:_loanModel chargeModels:_chargeModels];
                NSString *expectedInterestStr = [NSString stringWithFormat:@"%.2f", interest];
                [self.section1Items addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_expectedInterest" title:@"预期利息" subtitle:expectedInterestStr bottomTitle:nil]];
            } else {
                double interest = [SSJLoanHelper caculateInterestForEveryDayWithLoanModel:self.loanModel chargeModels:self.chargeModels];
                NSString *expectedInterestStr = [NSString stringWithFormat:@"¥%.2f", interest];
                [self.section1Items addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_expectedInterest" title:@"每天利息" subtitle:expectedInterestStr bottomTitle:nil]];
            }
        }
        
        if (_loanModel.memo.length) {
            [self.section1Items addObject:[SSJLoanDetailCellItem itemWithImage:@"loan_memo" title:@"备注" subtitle:_loanModel.memo bottomTitle:nil]];
        }
        
        if (completion) {
            completion();
        }
    }
}

- (void)reorganiseSection2Items {
    [self.section2Items removeAllObjects];
    
    if (self.changeSectionHeaderView.expanded) {
        // 把流水列表按照billdate、writedate降序排序，优先级billdate>writedate
        NSArray *tmpModels = [self.chargeModels sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            
            SSJLoanCompoundChargeModel *model1 = obj1;
            SSJLoanCompoundChargeModel *model2 = obj2;
            
            if ([model1.chargeModel.billDate compare:model2.chargeModel.billDate] == NSOrderedAscending) {
                return NSOrderedDescending;
            } else if ([model1.chargeModel.billDate compare:model2.chargeModel.billDate] == NSOrderedDescending) {
                return NSOrderedAscending;
            } else {
                if ([model1.chargeModel.writeDate compare:model2.chargeModel.writeDate] == NSOrderedAscending) {
                    return NSOrderedDescending;
                } else if ([model1.chargeModel.writeDate compare:model2.chargeModel.writeDate] == NSOrderedDescending) {
                    return NSOrderedAscending;
                } else {
                    return NSOrderedSame;
                }
            }
        }];
        
        for (SSJLoanCompoundChargeModel *compoundModel in tmpModels) {
            [self.section2Items addObject:[SSJLoanDetailCellItem cellItemWithChargeModel:compoundModel.chargeModel]];
            if (compoundModel.interestChargeModel) {
                [self.section2Items addObject:[SSJLoanDetailCellItem cellItemWithChargeModel:compoundModel.interestChargeModel]];
            }
        }
    }
}

- (void)loadData {
    [self.view ssj_showLoadingIndicator];
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJLoanHelper queryForLoanModelWithLoanID:_loanID success:^(SSJLoanModel * _Nonnull model) {
            self.loanModel = model;
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [SSJLoanHelper queryLoanChargeModeListWithLoanModel:self.loanModel success:^(NSArray<SSJLoanCompoundChargeModel *> * _Nonnull list) {
                self.chargeModels = list;
                [subscriber sendCompleted];
            } failure:^(NSError * _Nonnull error) {
                [subscriber sendError:error];
            }];
            return nil;
        }];
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [self reorganiseSection1Items:^{
                [self reorganiseSection2Items];
                [self organiseHeaderItems];
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
        [self updateSubViewHidden];
        
        [self.tableView reloadData];
        [self.headerView reloadData];
        
        SSJFinancingGradientColorItem *item = [[SSJFinancingGradientColorItem alloc] init];
        item.startColor = self.loanModel.startColor;
        item.endColor = self.loanModel.endColor;
        self.headerView.colorItem = item;
        self.tableView.tableHeaderView = self.headerView;
        self.changeSectionHeaderView.title = [NSString stringWithFormat:@"变更记录：%d条", (int)self.section2Items.count];
        
        switch (self.loanModel.type) {
            case SSJLoanTypeLend:
                if (self.loanModel.closeOut) {
                    [SSJAnaliyticsManager event:@"loan_end_detail"];
                } else {
                    [SSJAnaliyticsManager event:@"loan_detail"];
                }
                break;
                
            case SSJLoanTypeBorrow:
                if (self.loanModel.closeOut) {
                    [SSJAnaliyticsManager event:@"owed_end_detail"];
                } else {
                    [SSJAnaliyticsManager event:@"owed_detail"];
                }
                break;
        }
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
        self.changeBtn.hidden = YES;
        self.closeOutBtn.hidden = YES;
        self.deleteBtn.hidden = NO;
        self.stampView.hidden = NO;
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    } else {
        self.changeBtn.hidden = NO;
        self.closeOutBtn.hidden = NO;
        self.deleteBtn.hidden = YES;
        self.stampView.hidden = YES;
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
    editLoanVC.loanModel = self.loanModel;
    editLoanVC.chargeModels = self.chargeModels;
    [self.navigationController pushViewController:editLoanVC animated:YES];
    
    switch (_loanModel.type) {
        case SSJLoanTypeLend:
            [SSJAnaliyticsManager event:@"edit_loan"];
            break;
            
        case SSJLoanTypeBorrow:
            [SSJAnaliyticsManager event:@"edit_owed"];
            break;
    }
}

- (void)closeOutBtnAction {
    _loanModel.endTargetFundID = _loanModel.targetFundID;
    SSJLoanCloseOutViewController *closeOutVC = [[SSJLoanCloseOutViewController alloc] init];
    closeOutVC.loanModel = _loanModel;
    [self.navigationController pushViewController:closeOutVC animated:YES];
}

- (void)changeBtnAction {
    [self.changeChargeSelectionView show];
    
    switch (self.loanModel.type) {
        case SSJLoanTypeLend:
            [SSJAnaliyticsManager event:@"loan_modify"];
            break;
            
        case SSJLoanTypeBorrow:
            [SSJAnaliyticsManager event:@"owed_modify"];
            break;
    }
}

- (void)deleteBtnAction {
    __weak typeof(self) wself = self;
    [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"删除该项目后相关的账户流水数据(含转账、利息）将被彻底删除哦。" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:NULL], [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction *action) {
        [wself deleteLoanModel];
    }], nil];
    
    switch (self.loanModel.type) {
        case SSJLoanTypeLend:
            [SSJAnaliyticsManager event:@"loan_delete"];
            break;
            
        case SSJLoanTypeBorrow:
            [SSJAnaliyticsManager event:@"owed_delete"];
            break;
    }
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
        [_tableView registerClass:[SSJLoanDetailCell class] forCellReuseIdentifier:kSSJLoanDetailCellID];
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

- (UIImageView *)stampView {
    if (!_stampView) {
        _stampView = [[UIImageView alloc] initWithImage:[UIImage ssj_themeImageWithName:@"loan_stamp"]];
        _stampView.size = CGSizeMake(70, 70);
        _stampView.center = CGPointMake(self.tableView.width * 0.6, 178);
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

- (SSJFinancingDetailHeadeView *)headerView {
    if (!_headerView) {
        _headerView = [[SSJFinancingDetailHeadeView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, 174)];
        _headerView.backgroundColor = [UIColor clearColor];
        _headerView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
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
            [wself reorganiseSection2Items];
            [wself.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        };
    }
    return _changeSectionHeaderView;
}

- (SSJLoanChangeChargeSelectionControl *)changeChargeSelectionView {
    if (!_changeChargeSelectionView) {
        __weak typeof(self) wself = self;
        NSArray *titles = [NSArray array];
        if (_loanModel.type == SSJLoanTypeLend) {
            titles = @[@[@"收款", @"追加借出"], @[@"取消"]];
        } else if(_loanModel.type == SSJLoanTypeBorrow) {
            titles = @[@[@"还款", @"追加欠款"], @[@"取消"]];
        }
        _changeChargeSelectionView = [[SSJLoanChangeChargeSelectionControl alloc] initWithTitles:titles];
        _changeChargeSelectionView.selectionHandle = ^(NSString * title){
            SSJLoanChargeAddOrEditViewController *addOrEditVC = [[SSJLoanChargeAddOrEditViewController alloc] init];
            addOrEditVC.edited = NO;
            addOrEditVC.loanId = wself.loanID;
            if ([title isEqualToString:@"收款"] || [title isEqualToString:@"还款"]) {
                addOrEditVC.chargeType = SSJLoanCompoundChargeTypeRepayment;
            } else {
                addOrEditVC.chargeType = SSJLoanCompoundChargeTypeAdd;
            }
            [wself.navigationController pushViewController:addOrEditVC animated:YES];
            
            switch (wself.loanModel.type) {
                case SSJLoanTypeLend:
                    if ([title isEqualToString:@"收款"]) {
                        [SSJAnaliyticsManager event:@"loan_refund"];
                    } else if ([title isEqualToString:@"追加借出"]) {
                        [SSJAnaliyticsManager event:@"loan_additional"];
                    }
                    
                    break;
                    
                case SSJLoanTypeBorrow:
                    if ([title isEqualToString:@"还款"]) {
                        [SSJAnaliyticsManager event:@"owed_refund"];
                    } else if ([title isEqualToString:@"追加欠款"]) {
                        [SSJAnaliyticsManager event:@"owed_additional"];
                    }

                    break;
            }
        };
    }
    return _changeChargeSelectionView;
}

@end
