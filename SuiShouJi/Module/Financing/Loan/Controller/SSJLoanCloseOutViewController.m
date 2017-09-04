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
#import "SSJHomeDatePickerView.h"
#import "SSJTextFieldToolbarManager.h"
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
@property (nonatomic, strong) SSJHomeDatePickerView *endDateSelectionView;

@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, strong) NSArray *images;

@property (nonatomic, strong) NSArray *cellTags;

@property (nonatomic, strong) SSJLoanCompoundChargeModel *compoundModel;

@property (nonatomic, strong) NSArray<SSJLoanCompoundChargeModel *> *chargeModels;

@end

@implementation SSJLoanCloseOutViewController

#pragma mark - Lifecycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"结清";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = self.footerView;
    self.tableView.hidden = YES;
    [self updateAppearance];
    [self loadData];
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
            [interestCell.textField ssj_installToolbar];
            
        } else if (tag == kFundAccountTag) {
            
            SSJAddOrEditLoanLabelCell *accountCell = (SSJAddOrEditLoanLabelCell *)cell;
            SSJLoanFundAccountSelectionViewItem *selectedFundItem = [self.fundingSelectionView.items ssj_safeObjectAtIndex:_fundingSelectionView.selectedIndex];
            
            if (_fundingSelectionView.selectedIndex >= 0) {
                accountCell.additionalIcon.image = [UIImage imageNamed:selectedFundItem.image];
                accountCell.subtitleLabel.text = selectedFundItem.title;
            } else {
                accountCell.additionalIcon.image = nil;
                accountCell.subtitleLabel.text = @"请选择账户";
            }
            
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
        self.endDateSelectionView.date = self.loanModel.endDate;
        [self.endDateSelectionView show];
    }
}

#pragma mark - UITextFieldDelegate
// 有些输入框的clearsOnBeginEditing设为YES，只要获取焦点文本内容就会清空，这种情况下不会收到文本改变的通知，所以在这个代理函数中进行了处理
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField.tag == kInterestTag) {
        self.compoundModel.interestChargeModel.money = 0;
    }
    
    return YES;
}

#pragma mark - Private
- (void)updateAppearance {
    [_sureButton ssj_setBackgroundColor:SSJ_BUTTON_NORMAL_COLOR forState:UIControlStateNormal];
    [_sureButton ssj_setBackgroundColor:SSJ_BUTTON_DISABLE_COLOR forState:UIControlStateDisabled];
    _tableView.separatorColor = SSJ_CELL_SEPARATOR_COLOR;
}

- (void)loadData {
    [self.view ssj_showLoadingIndicator];

    [[[self loadCompoundChargeModels] then:^RACSignal *{
        return [self loadFundModels];
    }] subscribeError:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showError:error];
    } completed:^{
        [self organiseTitles];
        [self organiseImages];
        [self organiseCellTags];
        [self.tableView reloadData];
        self.tableView.hidden = NO;
        [self.view ssj_hideLoadingIndicator];
    }];
}

- (RACSignal *)loadFundModels {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJLoanHelper queryFundModelListWithSuccess:^(NSArray <SSJLoanFundAccountSelectionViewItem *>*items) {
            self.fundingSelectionView.items = items;
            self.fundingSelectionView.selectedIndex = -1;
            
            BOOL hasSelectedFund = NO;
            for (int i = 0; i < items.count; i ++) {
                SSJLoanFundAccountSelectionViewItem *item = items[i];
                if ([item.ID isEqualToString:self.loanModel.endTargetFundID]) {
                    self.fundingSelectionView.selectedIndex = i;
                    hasSelectedFund = YES;
                    break;
                }
            }
            
            // 如果此借贷的目标资金账户不在现有账户列表中，就置为nil，在保存的时候会监测endTargetFundID，空的话会提示用户选择账户
            if (!hasSelectedFund) {
                self.loanModel.endTargetFundID = nil;
            }
            
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (RACSignal *)loadCompoundChargeModels {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJLoanHelper queryLoanChargeModeListWithLoanID:self.loanModel.ID success:^(NSArray<SSJLoanCompoundChargeModel *> * _Nonnull list) {
            self.chargeModels = list;
            [self initEndDate];
            [self initCompoundModel];
            self.compoundModel.interestChargeModel.money = [SSJLoanHelper caculateInterestUntilDate:self.loanModel.endDate model:self.loanModel chargeModels:self.chargeModels];

            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (BOOL)needToDisplayInterest {
//    return (_loanModel.interest && [_loanModel.endDate compare:_loanModel.borrowDate] == NSOrderedDescending);
    return _loanModel.interest;
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
        _compoundModel = [[SSJLoanCompoundChargeModel alloc] init];
        
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
        
        NSString *preChargeID = SSJUUID();
        
        _compoundModel.chargeModel = [[SSJLoanChargeModel alloc] init];
        _compoundModel.chargeModel.chargeId = [NSString stringWithFormat:@"%@_%@", preChargeID, chargeBillId];
        _compoundModel.chargeModel.fundId = self.loanModel.fundID;
        _compoundModel.chargeModel.billId = chargeBillId;
        _compoundModel.chargeModel.userId = SSJUSERID();
        _compoundModel.chargeModel.loanId = self.loanModel.ID;
        _compoundModel.chargeModel.billDate = self.loanModel.endDate;
        _compoundModel.chargeModel.money = self.loanModel.jMoney;
        
        _compoundModel.targetChargeModel = [[SSJLoanChargeModel alloc] init];
        _compoundModel.targetChargeModel.chargeId = [NSString stringWithFormat:@"%@_%@", preChargeID, targetChargeBillId];
        _compoundModel.targetChargeModel.fundId = self.loanModel.endTargetFundID;
        _compoundModel.targetChargeModel.billId = targetChargeBillId;
        _compoundModel.targetChargeModel.userId = SSJUSERID();
        _compoundModel.targetChargeModel.loanId = self.loanModel.ID;
        _compoundModel.targetChargeModel.billDate = self.loanModel.endDate;
        _compoundModel.targetChargeModel.money = self.loanModel.jMoney;
        
        _compoundModel.interestChargeModel = [[SSJLoanChargeModel alloc] init];
        _compoundModel.interestChargeModel.chargeId = [NSString stringWithFormat:@"%@_%@", preChargeID, interestChargeBillId];
        _compoundModel.interestChargeModel.fundId = self.loanModel.endTargetFundID;
        _compoundModel.interestChargeModel.billId = interestChargeBillId;
        _compoundModel.interestChargeModel.userId = SSJUSERID();
        _compoundModel.interestChargeModel.loanId = self.loanModel.ID;
        _compoundModel.interestChargeModel.billDate = self.loanModel.endDate;
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
        
        if ([endDate compare:compoundModel.chargeModel.billDate] == NSOrderedAscending) {
            switch (self.loanModel.type) {
                case SSJLoanTypeLend:
                    if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeCreate
                        || compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceIncrease
                        || compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceDecrease) {
                        [CDAutoHideMessageHUD showMessage:@"结清日不能早于借出日期"];
                    } else if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeRepayment) {
                        [CDAutoHideMessageHUD showMessage:@"结清日不能早于收款流水日期"];
                    } else if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeAdd) {
                        [CDAutoHideMessageHUD showMessage:@"结清日不能早于追加借出日期"];
                    }
                    
                    break;
                    
                case SSJLoanTypeBorrow:
                    if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeCreate
                        || compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceIncrease
                        || compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceDecrease) {
                        [CDAutoHideMessageHUD showMessage:@"结清日不能早于欠款日期"];
                    } else if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeRepayment) {
                        [CDAutoHideMessageHUD showMessage:@"结清日不能早于还款流水日期"];
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
        
        // 利息金额为0的话，清空利息模型
        if (self.compoundModel.interestChargeModel.money == 0) {
            self.compoundModel.interestChargeModel = nil;
        }
        
        self.sureButton.enabled = NO;
        [SSJLoanHelper closeOutLoanModel:self.loanModel chargeModel:self.compoundModel success:^{
            self.sureButton.enabled = YES;
            [self.navigationController popViewControllerAnimated:YES];
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
            
            switch (_loanModel.type) {
                case SSJLoanTypeLend:
                    [SSJAnaliyticsManager event:@"end_loan"];
                    break;
                    
                case SSJLoanTypeBorrow:
                    [SSJAnaliyticsManager event:@"end_owed"];
                    break;
            }
        } failure:^(NSError * _Nonnull error) {
            self.sureButton.enabled = YES;
            [self showError:error];
        }];
    }
}

- (void)textDidChange:(NSNotification *)notification {
    UITextField *textField = notification.object;
    if ([textField isKindOfClass:[UITextField class]]) {
        
        if (textField.tag == kInterestTag) {
            
            NSString *tmpMoneyStr = [textField.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
            tmpMoneyStr = [tmpMoneyStr ssj_reserveDecimalDigits:2 intDigits:9];
            textField.text = [NSString stringWithFormat:@"¥%@", tmpMoneyStr];
            self.compoundModel.interestChargeModel.money = [tmpMoneyStr doubleValue];
        }
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
                SSJFundingTypeSelectViewController *NewFundingVC = [[SSJFundingTypeSelectViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
                NewFundingVC.needLoanOrNot = NO;
                NewFundingVC.addNewFundingBlock = ^(SSJBaseCellItem *item){
                    if ([item isKindOfClass:[SSJFundingItem class]]) {
                        SSJFundingItem *fundItem = (SSJFundingItem *)item;
                        weakSelf.loanModel.endTargetFundID = fundItem.fundingID;
                        weakSelf.compoundModel.targetChargeModel.fundId = fundItem.fundingID;
                        weakSelf.compoundModel.interestChargeModel.fundId = fundItem.fundingID;
                        [[weakSelf loadFundModels] subscribeError:^(NSError *error) {
                            [CDAutoHideMessageHUD showError:error];
                        }];
                    } else if ([item isKindOfClass:[SSJCreditCardItem class]]){
                        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
                        weakSelf.loanModel.endTargetFundID = cardItem.fundingID;
                        weakSelf.compoundModel.targetChargeModel.fundId = cardItem.fundingID;
                        weakSelf.compoundModel.interestChargeModel.fundId = cardItem.fundingID;
                        [[weakSelf loadFundModels] subscribeError:^(NSError *error) {
                            [CDAutoHideMessageHUD showError:error];
                        }];
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

- (SSJHomeDatePickerView *)endDateSelectionView {
    if (!_endDateSelectionView) {
        __weak typeof(self) weakSelf = self;
        _endDateSelectionView = [[SSJHomeDatePickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        _endDateSelectionView.horuAndMinuBgViewBgColor = [UIColor clearColor];
        _endDateSelectionView.datePickerMode = SSJDatePickerModeDate;
        _endDateSelectionView.date = _loanModel.endDate;
        _endDateSelectionView.confirmBlock = ^(SSJHomeDatePickerView *view) {
            weakSelf.loanModel.endDate = view.date;
            weakSelf.compoundModel.chargeModel.billDate = view.date;
            weakSelf.compoundModel.targetChargeModel.billDate = view.date;
            weakSelf.compoundModel.interestChargeModel.billDate = view.date;
            
//            [weakSelf organiseTitles];
//            [weakSelf organiseImages];
//            [weakSelf organiseCellTags];
            
            weakSelf.compoundModel.interestChargeModel.money = [SSJLoanHelper caculateInterestUntilDate:weakSelf.loanModel.endDate model:weakSelf.loanModel chargeModels:weakSelf.chargeModels];
            
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
        };
        _endDateSelectionView.shouldConfirmBlock = ^BOOL(SSJHomeDatePickerView *view, NSDate *date) {
            return [weakSelf validateEndDate:date];
        };
    }
    return _endDateSelectionView;
}

@end
