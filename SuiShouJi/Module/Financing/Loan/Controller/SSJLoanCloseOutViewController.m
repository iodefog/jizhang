//
//  SSJLoanCloseOutViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/8/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanCloseOutViewController.h"
#import "SSJFundingTypeSelectViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJAddOrEditLoanLabelCell.h"
#import "SSJAddOrEditLoanTextFieldCell.h"
#import "SSJLoanFundAccountSelectionView.h"
#import "SSJLoanDateSelectionView.h"
#import "SSJLoanHelper.h"
#import "SSJDataSynchronizer.h"
#import "SSJFundingItem.h"
#import "SSJCreditCardItem.h"

static NSString *const kAddOrEditLoanLabelCellId = @"kAddOrEditLoanLabelCellId";
static NSString *const kAddOrEditLoanTextFieldCellId = @"kAddOrEditLoanTextFieldCellId";

static NSUInteger kMoneyTag = 1001;
static NSUInteger kInterestTag = 1002;
static NSUInteger kFundAccountTag = 1003;
static NSUInteger kClostOutDateTag = 1004;

@interface SSJLoanCloseOutViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) UIView *footerView;

// 借贷账户
@property (nonatomic, strong) SSJLoanFundAccountSelectionView *fundingSelectionView;

// 结清日
@property (nonatomic, strong) SSJLoanDateSelectionView *endDateSelectionView;

@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, strong) NSArray *images;

@property (nonatomic, strong) NSArray *cellTags;

@property (nonatomic, strong) SSJLoanCompoundChargeModel *compoundModel;

@property (nonatomic, strong) NSArray <SSJLoanCompoundChargeModel *>*chargeModels;

@end

@implementation SSJLoanCloseOutViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"结清";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
    
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = self.footerView;
    self.tableView.hidden = YES;
    [self updateAppearance];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _cellTags.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectonArr = [_cellTags ssj_safeObjectAtIndex:section];
    return sectonArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger tag = [[_cellTags ssj_objectAtIndexPath:indexPath] unsignedIntegerValue];
    NSString *cellId = [self cellIdentifierForTag:tag];
    
    if (cellId) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifierForTag:tag] forIndexPath:indexPath];
        cell.textLabel.text = [_titles ssj_objectAtIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:[_images ssj_objectAtIndexPath:indexPath]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [cell setNeedsLayout];
        
        if (tag == kMoneyTag) {
            
            SSJAddOrEditLoanLabelCell *moneyCell = (SSJAddOrEditLoanLabelCell *)cell;
            moneyCell.additionalIcon.image = nil;
            moneyCell.subtitleLabel.text = [NSString stringWithFormat:@"¥%.2f", _loanModel.jMoney];;
            moneyCell.customAccessoryType = UITableViewCellAccessoryNone;
            moneyCell.switchControl.hidden = YES;
            moneyCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        } else if (tag == kInterestTag) {
            
            SSJAddOrEditLoanTextFieldCell *interestCell = (SSJAddOrEditLoanTextFieldCell *)cell;
            interestCell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"¥0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
            interestCell.textField.text = [NSString stringWithFormat:@"¥%.2f", self.compoundModel.interestChargeModel.money];
            interestCell.textField.keyboardType = UIKeyboardTypeDecimalPad;
            interestCell.textField.clearsOnBeginEditing = YES;
            interestCell.textField.delegate = self;
            interestCell.textField.tag = kInterestTag;
            
        } else if (tag == kFundAccountTag) {
            
            SSJAddOrEditLoanLabelCell *accountCell = (SSJAddOrEditLoanLabelCell *)cell;
            SSJLoanFundAccountSelectionViewItem *selectedFundItem = [self.fundingSelectionView.items ssj_safeObjectAtIndex:_fundingSelectionView.selectedIndex];
            accountCell.additionalIcon.image = [UIImage imageNamed:selectedFundItem.image];
            accountCell.subtitleLabel.text = selectedFundItem.title;
            accountCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
            accountCell.switchControl.hidden = YES;
            accountCell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
            
        } else if (tag == kClostOutDateTag) {
            
            SSJAddOrEditLoanLabelCell *dateCell = (SSJAddOrEditLoanLabelCell *)cell;
            dateCell.additionalIcon.image = nil;
            dateCell.subtitleLabel.text = [_loanModel.endDate formattedDateWithFormat:@"yyyy.MM.dd"];
            dateCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
            dateCell.switchControl.hidden = YES;
            dateCell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
            
        }
        
        return cell;
    }
    
    return [[UITableViewCell alloc] init];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:0]] == NSOrderedSame) {
        [CDAutoHideMessageHUD showMessage:@"结清金额须等于剩余借出款金额哦。"];
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:1]] == NSOrderedSame) {
        [self.view endEditing:YES];
        [self.fundingSelectionView show];
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:2]] == NSOrderedSame) {
        [self.view endEditing:YES];
        self.endDateSelectionView.selectedDate = self.loanModel.endDate;
        [self.endDateSelectionView show];
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == kInterestTag) {
        NSString *money = [textField.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
        textField.text = [NSString stringWithFormat:@"¥%.2f", [money doubleValue]];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == kInterestTag) {
        NSString *tmpMoneyStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
        tmpMoneyStr = [tmpMoneyStr stringByReplacingOccurrencesOfString:@"¥" withString:@""];
        tmpMoneyStr = [tmpMoneyStr ssj_reserveDecimalDigits:2 intDigits:0];
        textField.text = [NSString stringWithFormat:@"¥%@", tmpMoneyStr];
        self.compoundModel.interestChargeModel.money = [tmpMoneyStr doubleValue];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Private
- (void)updateAppearance {
    [_sureButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
    [_sureButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor alpha:0.5] forState:UIControlStateDisabled];
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}

- (void)loadData {
    [self.view ssj_showLoadingIndicator];
    
    [SSJLoanHelper queryFundModelListWithSuccess:^(NSArray <SSJLoanFundAccountSelectionViewItem *>*items) {
        
        self.fundingSelectionView.items = items;
        for (int i = 0; i < items.count; i ++) {
            SSJLoanFundAccountSelectionViewItem *item = items[i];
            if ([item.ID isEqualToString:self.loanModel.endTargetFundID]) {
                self.fundingSelectionView.selectedIndex = i;
                break;
            }
        }
        
        [SSJLoanHelper queryLoanChargeModeListWithLoanModel:self.loanModel success:^(NSArray<SSJLoanCompoundChargeModel *> * _Nonnull list) {
            
            [self.view ssj_hideLoadingIndicator];
            
            self.chargeModels = list;
            
            [self initEndDate];
            [self initCompoundModel];
            
            self.compoundModel.interestChargeModel.money = [SSJLoanHelper caculateInterestUntilDate:self.loanModel.endDate model:self.loanModel chargeModels:self.chargeModels];
            
            [self organiseTitles];
            [self organiseImages];
            [self organiseCellTags];
            
            [self.tableView reloadData];
            self.tableView.hidden = NO;
            
        } failure:^(NSError * _Nonnull error) {
            [self.view ssj_hideLoadingIndicator];
            [self showError:error];
        }];
        
    } failure:^(NSError * _Nonnull error) {
        [self.view ssj_hideLoadingIndicator];
        [self showError:error];
    }];
}

- (BOOL)needToDisplayInterest {
    return (_loanModel.interest && [_loanModel.endDate compare:_loanModel.borrowDate] == NSOrderedDescending);
}

- (void)organiseTitles {
    switch (_loanModel.type) {
        case SSJLoanTypeLend:
            if ([self needToDisplayInterest]) {
                _titles = @[@[@"借出金额", @"利息收入"], @[@"结清转入账户"], @[@"结清日"]];
            } else {
                _titles = @[@[@"借出金额"], @[@"结清转入账户"], @[@"结清日"]];
            }
            break;
            
        case SSJLoanTypeBorrow:
            if ([self needToDisplayInterest]) {
                _titles = @[@[@"欠款金额", @"利息支出"], @[@"结清转出账户"], @[@"结清日"]];
            } else {
                _titles = @[@[@"欠款金额"], @[@"结清转出账户"], @[@"结清日"]];
            }
            break;
    }
}

- (void)organiseImages {
    if ([self needToDisplayInterest]) {
        _images = @[@[@"loan_money", @"loan_yield"], @[@"loan_account"], @[@"loan_expires"]];
    } else {
        _images = @[@[@"loan_money"], @[@"loan_account"], @[@"loan_expires"]];
    }
}

- (void)organiseCellTags {
    if ([self needToDisplayInterest]) {
        _cellTags = @[@[@(kMoneyTag), @(kInterestTag)], @[@(kFundAccountTag)], @[@(kClostOutDateTag)]];
    } else {
        _cellTags = @[@[@(kMoneyTag)], @[@(kFundAccountTag)], @[@(kClostOutDateTag)]];
    }
}

- (NSString *)cellIdentifierForTag:(NSUInteger)tag {
    if (tag == kInterestTag) {
        return kAddOrEditLoanTextFieldCellId;
    } else if (tag == kMoneyTag
               || tag == kFundAccountTag
               || tag == kClostOutDateTag) {
        return kAddOrEditLoanLabelCellId;
    } else {
        return nil;
    }
}

// 如果外部没有传入结清日期，就取当天和所有变更流水中最大的日期
- (void)initEndDate {
    if (!_loanModel.endDate) {
        NSDate *endDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day];
        for (SSJLoanCompoundChargeModel *compoundModel in self.chargeModels) {
            endDate = [endDate isLaterThan:compoundModel.chargeModel.billDate] ? endDate : compoundModel.chargeModel.billDate;
        }
        _loanModel.endDate = endDate;
    }
}

- (void)initCompoundModel {
    if (!_compoundModel) {
        NSString *chargeBillId = nil;
        NSString *targetChargeBillId = nil;
        NSString *interestChargeBillId = nil;
        
        switch (self.loanModel.type) {
            case SSJLoanTypeLend:
                chargeBillId = @"4";
                targetChargeBillId = @"3";
                interestChargeBillId = @"5";
                break;
                
            case SSJLoanTypeBorrow:
                chargeBillId = @"3";
                targetChargeBillId = @"4";
                interestChargeBillId = @"6";
                break;
        }
        
        SSJLoanChargeModel *chargeModel = [[SSJLoanChargeModel alloc] init];
        chargeModel.chargeId = SSJUUID();
        chargeModel.fundId = self.loanModel.fundID;
        chargeModel.billId = chargeBillId;
        chargeModel.loanId = self.loanModel.ID;
        chargeModel.userId = SSJUSERID();
        chargeModel.billDate = self.loanModel.endDate;
        chargeModel.money = self.loanModel.jMoney;
        
        SSJLoanChargeModel *targetChargeModel = [[SSJLoanChargeModel alloc] init];
        targetChargeModel.chargeId = SSJUUID();
        targetChargeModel.fundId = self.loanModel.endTargetFundID;
        targetChargeModel.billId = targetChargeBillId;
        targetChargeModel.loanId = self.loanModel.ID;
        targetChargeModel.userId = SSJUSERID();
        targetChargeModel.billDate = self.loanModel.endDate;
        targetChargeModel.money = self.loanModel.jMoney;
        
        SSJLoanChargeModel *interestModel = [[SSJLoanChargeModel alloc] init];
        interestModel.chargeId = SSJUUID();
        interestModel.fundId = self.loanModel.endTargetFundID;
        interestModel.billId = interestChargeBillId;
        interestModel.loanId = self.loanModel.ID;
        interestModel.userId = SSJUSERID();
        interestModel.billDate = self.loanModel.endDate;
        
        _compoundModel = [[SSJLoanCompoundChargeModel alloc] init];
        _compoundModel.chargeModel = chargeModel;
        _compoundModel.targetChargeModel = targetChargeModel;
        _compoundModel.interestChargeModel = interestModel;
    }
}

- (BOOL)checkLoanModelValid {
    if (self.compoundModel.interestChargeModel.money < 0) {
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                [CDAutoHideMessageHUD showMessage:@"利息收入不能小于0元"];
                break;
                
            case SSJLoanTypeBorrow:
                [CDAutoHideMessageHUD showMessage:@"利息支出不能小于0元"];
                break;
        }
        
        return NO;
    }
    
    if (!_loanModel.endTargetFundID.length) {
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                [CDAutoHideMessageHUD showMessage:@"请选择转入账户"];
                break;
                
            case SSJLoanTypeBorrow:
                [CDAutoHideMessageHUD showMessage:@"请选择转转出账户"];
                break;
        }
        
        return NO;
    }
    
    if (!_loanModel.endDate) {
        [CDAutoHideMessageHUD showMessage:@"请选择结清日期"];
        return NO;
    }
    
    if (![self validateEndDate:self.loanModel.endDate]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateEndDate:(NSDate *)endDate {
    for (SSJLoanCompoundChargeModel *compoundModel in self.chargeModels) {
        
        if ([self.loanModel.endDate compare:compoundModel.chargeModel.billDate] == NSOrderedAscending) {
            switch (self.loanModel.type) {
                case SSJLoanTypeLend:
                    if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeCreate
                        || compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceIncrease
                        || compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceDecrease) {
                        [CDAutoHideMessageHUD showMessage:@"结清日不能早于借出日期"];
                    } else if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeRepayment) {
                        [CDAutoHideMessageHUD showMessage:@"结清日不能早于收款日期"];
                    } else if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeAdd) {
                        [CDAutoHideMessageHUD showMessage:@"结清日不能早于追加借出日期"];
                    }
                    
                    break;
                    
                case SSJLoanTypeBorrow:
                    if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeCreate
                        || compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceIncrease
                        || compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceDecrease) {
                        [CDAutoHideMessageHUD showMessage:@"结清日不能早于借入日期"];
                    } else if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeRepayment) {
                        [CDAutoHideMessageHUD showMessage:@"结清日不能早于还款日期"];
                    } else if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeAdd) {
                        [CDAutoHideMessageHUD showMessage:@"结清日不能早于追加欠款日期"];
                    }
                    
                    break;
            }
            
            return NO;
        }
    }
    
    return YES;
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
- (void)sureButtonAction {
    if ([self checkLoanModelValid]) {
        
        for (SSJLoanCompoundChargeModel *compoundModel in self.chargeModels) {
            if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeCreate) {
                self.loanModel.jMoney = compoundModel.chargeModel.money;
            } else if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceIncrease) {
                self.loanModel.jMoney += compoundModel.chargeModel.money;
            } else if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceDecrease) {
                self.loanModel.jMoney -= compoundModel.chargeModel.money;
            } else if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeAdd) {
                self.loanModel.jMoney += compoundModel.chargeModel.money;
            }
        }
        
        self.sureButton.enabled = NO;
        [SSJLoanHelper closeOutLoanModel:self.loanModel chargeModel:self.compoundModel success:^{
            self.sureButton.enabled = YES;
            [self.navigationController popViewControllerAnimated:YES];
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
            
            switch (_loanModel.type) {
                case SSJLoanTypeLend:
                    [MobClick event:@"end_loan"];
                    break;
                    
                case SSJLoanTypeBorrow:
                    [MobClick event:@"end_owed"];
                    break;
            }
        } failure:^(NSError * _Nonnull error) {
            self.sureButton.enabled = YES;
            [self showError:error];
        }];
    }
}

#pragma mark - Getter
- (TPKeyboardAvoidingTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_tableView registerClass:[SSJAddOrEditLoanLabelCell class] forCellReuseIdentifier:kAddOrEditLoanLabelCellId];
        [_tableView registerClass:[SSJAddOrEditLoanTextFieldCell class] forCellReuseIdentifier:kAddOrEditLoanTextFieldCellId];
        _tableView.rowHeight = 54;
        _tableView.sectionFooterHeight = 0;
    }
    return _tableView;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_sureButton setTitle:@"" forState:UIControlStateDisabled];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(sureButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _sureButton.frame = CGRectMake(self.view.width * 0.11 , 30, self.view.width * 0.78, 48);
        _sureButton.clipsToBounds = YES;
        _sureButton.layer.cornerRadius = 3;
    }
    return _sureButton;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 108)];
        _footerView.backgroundColor = [UIColor clearColor];
        [_footerView addSubview:self.sureButton];
    }
    return _footerView;
}

- (SSJLoanFundAccountSelectionView *)fundingSelectionView {
    if (!_fundingSelectionView) {
        __weak typeof(self) weakSelf = self;
        _fundingSelectionView = [[SSJLoanFundAccountSelectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        _fundingSelectionView.shouldSelectAccountAction = ^BOOL(SSJLoanFundAccountSelectionView *view, NSUInteger index) {
            if (index < view.items.count - 1) {
                SSJLoanFundAccountSelectionViewItem *item = [view.items objectAtIndex:index];
                weakSelf.loanModel.endTargetFundID = item.ID;
                weakSelf.compoundModel.targetChargeModel.fundId = item.ID;
                weakSelf.compoundModel.interestChargeModel.fundId = item.ID;
                [weakSelf.tableView reloadData];
                return YES;
            } else if (index == view.items.count - 1) {
                SSJFundingTypeSelectViewController *NewFundingVC = [[SSJFundingTypeSelectViewController alloc]init];
                NewFundingVC.needLoanOrNot = NO;
                NewFundingVC.addNewFundingBlock = ^(SSJBaseItem *item){
                    if ([item isKindOfClass:[SSJFundingItem class]]) {
                        SSJFundingItem *fundItem = (SSJFundingItem *)item;
                        weakSelf.loanModel.targetFundID = fundItem.fundingID;
                        weakSelf.compoundModel.targetChargeModel.fundId = fundItem.fundingID;
                        weakSelf.compoundModel.interestChargeModel.fundId = fundItem.fundingID;
                        [weakSelf loadData];
                    } else if ([item isKindOfClass:[SSJCreditCardItem class]]){
                        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
                        weakSelf.loanModel.targetFundID = cardItem.cardId;
                        weakSelf.compoundModel.targetChargeModel.fundId = cardItem.cardId;
                        weakSelf.compoundModel.interestChargeModel.fundId = cardItem.cardId;
                        [weakSelf loadData];
                    }
                };
                [weakSelf.navigationController pushViewController:NewFundingVC animated:YES];
                
                return NO;
            } else {
                SSJPRINT(@"警告：selectedIndex大于数组范围");
                return NO;
            }
        };
    }
    return _fundingSelectionView;
}

- (SSJLoanDateSelectionView *)endDateSelectionView {
    if (!_endDateSelectionView) {
        __weak typeof(self) weakSelf = self;
        _endDateSelectionView = [[SSJLoanDateSelectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        _endDateSelectionView.selectedDate = _loanModel.endDate;
        _endDateSelectionView.selectDateAction = ^(SSJLoanDateSelectionView *view) {
            
            weakSelf.loanModel.endDate = view.selectedDate;
            weakSelf.compoundModel.chargeModel.billDate = view.selectedDate;
            weakSelf.compoundModel.targetChargeModel.billDate = view.selectedDate;
            weakSelf.compoundModel.interestChargeModel.billDate = view.selectedDate;
            
            [weakSelf organiseTitles];
            [weakSelf organiseImages];
            [weakSelf organiseCellTags];
            
            weakSelf.compoundModel.interestChargeModel.money = [SSJLoanHelper caculateInterestUntilDate:weakSelf.loanModel.endDate model:weakSelf.loanModel chargeModels:weakSelf.chargeModels];
            
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
        };
        _endDateSelectionView.shouldSelectDateAction = ^BOOL(SSJLoanDateSelectionView *view, NSDate *date) {
            return [weakSelf validateEndDate:date];
        };
    }
    return _endDateSelectionView;
}

@end
