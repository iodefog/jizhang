//
//  SSJFixedFinanctAddViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/25.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanctAddViewController.h"
#import "SSJFundingTypeSelectViewController.h"

#import "TPKeyboardAvoidingTableView.h"
#import "SSJHomeDatePickerView.h"
#import "SSJLoanFundAccountSelectionView.h"
#import "SSJAddOrEditLoanTextFieldCell.h"
#import "SSJAddOrEditLoanLabelCell.h"

#import "SSJFixedFinanceProductItem.h"
#import "SSJFixedFinanceProductCompoundItem.h"

#import "SSJTextFieldToolbarManager.h"
#import "SSJFixedFinanceProductStore.h"

static NSString *const kAddOrEditFinanceLabelCellId = @"kAddOrEditFinanceLabelCellId";
static NSString *const kAddOrEditFinanceTextFieldCellId = @"kAddOrEditFinanceTextFieldCellId";

static NSUInteger kMoneyTag = 2001;
static NSUInteger kInterestTag = 2002;
static NSUInteger kAccountTag = 2003;
static NSUInteger kMemoTag = 2004;
static NSUInteger kDateTag = 2005;

@interface SSJFixedFinanctAddViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;
// 转出账户
@property (nonatomic, strong) SSJLoanFundAccountSelectionView *fundingSelectionView;
// 日期选择控件
@property (nonatomic, strong) SSJHomeDatePickerView *dateSelectionView;

@property (nonatomic, strong) SSJFixedFinanceProductItem *financeModel;

@property (nonatomic, strong) SSJFixedFinanceProductCompoundItem *compoundModel;

@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) NSArray *cellTags;
@end

@implementation SSJFixedFinanctAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"追加购买";
    [self organiseCellTags];
    [self.view addSubview:self.tableView];
    [self loadData];
}

- (void)loadData {
    
    //查询转出账户列表
}

#pragma mark - UITextFieldDelegate
//- (void)textFieldDidEndEditing:(UITextField *)textField {
//    if (textField.tag == kMoneyTag
//        || textField.tag == kInterestTag) {
//        NSString *money = [textField.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
//        textField.text = [NSString stringWithFormat:@"¥%.2f", [money doubleValue]];
//    }
//}

// 有些输入框的clearsOnBeginEditing设为YES，只要获取焦点文本内容就会清空，这种情况下不会收到文本改变的通知，所以在这个代理函数中进行了处理
- (BOOL)textFieldShouldClear:(UITextField *)textField {
//    if (textField.tag == kMoneyTag) {
//        self.compoundModel.chargeModel.money = 0;
//        self.compoundModel.targetChargeModel.money = 0;
//    } else if (textField.tag == kInterestTag) {
//        self.compoundModel.interestChargeModel.money = 0;
//    } else if (textField.tag == kMemoTag) {
//        self.compoundModel.chargeModel.memo = @"";
//        self.compoundModel.targetChargeModel.memo = @"";
//        self.compoundModel.interestChargeModel.memo = @"";
//    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cellTags.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.cellTags ssj_safeObjectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger tag = [[self.cellTags ssj_objectAtIndexPath:indexPath] unsignedIntegerValue];
    if (tag == kMoneyTag) {
        
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFinanceTextFieldCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:@"loan_money"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.textLabel.text = [self titleForCellTag:tag];
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"¥0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        cell.textField.text = [NSString stringWithFormat:@"¥%.2f", self.compoundModel.chargeModel.money];
        cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
        cell.textField.clearsOnBeginEditing = YES;
        cell.textField.delegate = self;
        cell.textField.tag = kMoneyTag;
        [cell.textField ssj_installToolbar];
        [cell setNeedsLayout];
        return cell;
        
    } else if (tag == kAccountTag) {
        
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFinanceLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:@"loan_account"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.textLabel.text = [self titleForCellTag:tag];
        
        if (self.fundingSelectionView.selectedIndex >= 0) {
            SSJLoanFundAccountSelectionViewItem *selectedFundItem = [self.fundingSelectionView.items ssj_safeObjectAtIndex:self.fundingSelectionView.selectedIndex];
            cell.additionalIcon.image = [UIImage imageNamed:selectedFundItem.image];
            cell.subtitleLabel.text = selectedFundItem.title;
        } else {
            cell.additionalIcon.image = nil;
            cell.subtitleLabel.text = @"请选择账户";
        }
        
        cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.switchControl.hidden = YES;
        cell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
        [cell setNeedsLayout];
        return cell;
        
    } else if (tag == kMemoTag) {
        
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFinanceTextFieldCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:@"loan_memo"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.textLabel.text = [self titleForCellTag:tag];
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"选填" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        cell.textField.text = self.compoundModel.chargeModel.memo;
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.textField.returnKeyType = UIReturnKeyDone;
        cell.textField.clearsOnBeginEditing = NO;
        cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        cell.textField.delegate = self;
        cell.textField.tag = kMemoTag;
        [cell setNeedsLayout];
        return cell;
        
    } else if (tag == kDateTag) {
        
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFinanceLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:@"loan_calendar"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.textLabel.text = [self titleForCellTag:tag];
        cell.additionalIcon.image = nil;
        cell.subtitleLabel.text = [self.compoundModel.chargeModel.billDate formattedDateWithFormat:@"yyyy.MM.dd"];
        cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.switchControl.hidden = YES;
        cell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
        [cell setNeedsLayout];
        return cell;
        
    } else {
        return [[UITableViewCell alloc] init];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger tag = [[self.cellTags ssj_objectAtIndexPath:indexPath] unsignedIntegerValue];
    if (tag == kAccountTag) {
        [self.view endEditing:YES];
        [self.fundingSelectionView show];
    } else if (tag == kDateTag) {
        [self.view endEditing:YES];
        self.dateSelectionView.date = self.compoundModel.chargeModel.billDate;
        [self.dateSelectionView show];
    }
}


#pragma mark - Private
- (void)organiseCellTags {
    _cellTags = @[@[@(kMoneyTag),
                    @(kAccountTag)],
                  @[@(kDateTag),
                    @(kMemoTag)]];
}

- (NSString *)titleForCellTag:(NSUInteger)tag {
    if (tag == kMoneyTag) {
        return @"追购金额";
    } else if (tag == kAccountTag) {
        return @"转出账户";
    } else if (tag == kMemoTag) {
        return @"备注";
    } else if (tag == kDateTag) {
        return @"追购日期";
    }
    return nil;
}

#pragma mark - Action
- (void)sureButtonAction {
//
//    if (self.surplus == 0 && self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
//        switch (self.loanModel.type) {
//            case SSJLoanTypeLend:
//                [CDAutoHideMessageHUD showMessage:@"你的剩余借出款为0，无需再收款了"];
//                break;
//                
//            case SSJLoanTypeBorrow:
//                [CDAutoHideMessageHUD showMessage:@"你的剩余欠款为0，无需再还款了"];
//                break;
//        }
//        return;
//    }
//    
//    if (self.compoundModel.chargeModel.money <= 0) {
//        switch (self.loanModel.type) {
//            case SSJLoanTypeLend:
//                [CDAutoHideMessageHUD showMessage:@"收款金额必须大于0元"];
//                break;
//                
//            case SSJLoanTypeBorrow:
//                [CDAutoHideMessageHUD showMessage:@"还款金额必须大于0元"];
//                break;
//        }
//        return;
//    }
//    
//    if (!self.compoundModel.targetChargeModel.fundId.length) {
//        if (self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
//            switch (self.loanModel.type) {
//                case SSJLoanTypeLend:
//                    [CDAutoHideMessageHUD showMessage:@"请选择转入账户"];
//                    break;
//                    
//                case SSJLoanTypeBorrow:
//                    [CDAutoHideMessageHUD showMessage:@"请选择转出账户"];
//                    break;
//            }
//        } else if (self.chargeType == SSJLoanCompoundChargeTypeAdd) {
//            switch (self.loanModel.type) {
//                case SSJLoanTypeLend:
//                    [CDAutoHideMessageHUD showMessage:@"请选择转出账户"];
//                    break;
//                    
//                case SSJLoanTypeBorrow:
//                    [CDAutoHideMessageHUD showMessage:@"请选择转入账户"];
//                    break;
//            }
//        }
//        
//        return;
//    }
//    
//    if (self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
//        
//        if (self.compoundModel.chargeModel.money > self.surplus) {
//            self.compoundModel.chargeModel.money = self.surplus;
//            self.compoundModel.targetChargeModel.money = self.surplus;
//            [self updateInterest];
//            switch (self.loanModel.type) {
//                case SSJLoanTypeLend:
//                    [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"修改后的金额需要≤%.2f，否则剩余借出款会为负哦", self.surplus]];
//                    break;
//                    
//                case SSJLoanTypeBorrow:
//                    [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"修改后的金额需要≤%.2f，否则剩余欠款会为正哦", self.surplus]];
//                    break;
//            }
//            
//            return;
//        }
//        
//        if (self.compoundModel.chargeModel.money == self.surplus) {
//            // 因为金额输入框的clearsOnBeginEditing设为YES，系统弹窗出现后输入框会失去焦点，弹窗消失后又会重新获取焦，输入框内容被清空，导致调用[self saveLoanCharge]方法保存的金额就变成0了，所以这里强制取消焦点
//            [self.view endEditing:YES];
//            
//            NSString *message = nil;
//            switch (self.compoundModel.chargeModel.type) {
//                case SSJLoanTypeLend:
//                    message = @"您的收款金额等于剩余借出金额，是否立即结清该笔欠款？";
//                    break;
//                    
//                case SSJLoanTypeBorrow:
//                    message = @"您的还款金额等于剩余欠款金额，是否立即结清该笔欠款？";
//                    break;
//            }
//            
//            SSJAlertViewAction *cancelAction = [SSJAlertViewAction actionWithTitle:@"取消" handler:^(SSJAlertViewAction * _Nonnull action) {
//                if (![self showInterestTypeAlertIfNeeded]) {
//                    [self saveLoanCharge];
//                }
//            }];
//            SSJAlertViewAction *sureAction = [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction * _Nonnull action) {
//                SSJLoanCloseOutViewController *closeOutController = [[SSJLoanCloseOutViewController alloc] init];
//                closeOutController.loanModel = self.loanModel;
//                closeOutController.loanModel.endTargetFundID = self.compoundModel.targetChargeModel.fundId;
//                closeOutController.loanModel.endDate = self.compoundModel.targetChargeModel.billDate;
//                
//                NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];
//                [controllers removeObject:self];
//                [controllers addObject:closeOutController];
//                [self.navigationController setViewControllers:controllers animated:YES];
//            }];
//            [SSJAlertViewAdapter showAlertViewWithTitle:nil message:message action:cancelAction, sureAction, nil];
//            
//            return;
//        }
//    }
//    
//    if (self.chargeType == SSJLoanCompoundChargeTypeAdd) {
//        if (self.surplus + self.compoundModel.chargeModel.money < 0) {
//            
//            double money = ABS(self.surplus);
//            
//            self.compoundModel.chargeModel.money = money;
//            self.compoundModel.targetChargeModel.money = money;
//            [self updateInterest];
//            
//            switch (self.loanModel.type) {
//                case SSJLoanTypeLend:
//                    [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"修改后的金额需要≥%.2f，否则剩余借出款会为负哦", money]];
//                    break;
//                    
//                case SSJLoanTypeBorrow:
//                    [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"修改后的金额需要≥%.2f，否则剩余欠款会为正哦", money]];
//                    break;
//            }
//            
//            return;
//        }
//    }
//    
//    if (![self showInterestTypeAlertIfNeeded]) {
//        [self saveLoanCharge];
//    }
}

#pragma mark - Lazy
- (TPKeyboardAvoidingTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_tableView registerClass:[SSJAddOrEditLoanLabelCell class] forCellReuseIdentifier:kAddOrEditFinanceLabelCellId];
        [_tableView registerClass:[SSJAddOrEditLoanTextFieldCell class] forCellReuseIdentifier:kAddOrEditFinanceTextFieldCellId];
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
                        weakSelf.compoundModel.targetChargeModel.fundId = fundItem.fundingID;
                        weakSelf.compoundModel.interestChargeModel.fundId = fundItem.fundingID;
                    } else if (0){//[item isKindOfClass:[SSJCreditCardItem class]]
//                        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
//                        weakSelf.compoundModel.targetChargeModel.fundId = cardItem.cardId;
//                        weakSelf.compoundModel.interestChargeModel.fundId = cardItem.cardId;
                    }
                    
//                    if (weakSelf.edited) {
//                        [weakSelf loadLoanModelAndFundListWithLoanId:weakSelf.compoundModel.chargeModel.loanId];
//                    } else {
//                        [weakSelf loadLoanModelAndFundListWithLoanId:weakSelf.loanId];
//                    }
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

- (SSJHomeDatePickerView *)dateSelectionView {
    if (!_dateSelectionView) {
        __weak typeof(self) weakSelf = self;
        _dateSelectionView = [[SSJHomeDatePickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        _dateSelectionView.horuAndMinuBgViewBgColor = [UIColor clearColor];
        _dateSelectionView.datePickerMode = SSJDatePickerModeDate;
        _dateSelectionView.date = self.compoundModel.chargeModel.billDate;
        _dateSelectionView.shouldConfirmBlock = ^BOOL(SSJHomeDatePickerView *view, NSDate *date) {
            if ([date compare:weakSelf.financeModel.startDate] == NSOrderedAscending) {
//                if (weakSelf.chargeType == SSJLoanCompoundChargeTypeRepayment) {
//                    switch (weakSelf.loanModel.type) {
//                        case SSJLoanTypeLend:
//                            [CDAutoHideMessageHUD showMessage:@"收款日期不能早于借出日期"];
//                            break;
//                            
//                        case SSJLoanTypeBorrow:
//                            [CDAutoHideMessageHUD showMessage:@"还款日期不能早于欠款日期"];
//                            break;
//                    }
//                } else if (weakSelf.chargeType == SSJLoanCompoundChargeTypeAdd) {
//                    [CDAutoHideMessageHUD showMessage:@"日期不能早于欠款日期"];
//                }
                
                return NO;
            }
            return YES;
        };
        _dateSelectionView.confirmBlock = ^(SSJHomeDatePickerView *view) {
            weakSelf.compoundModel.chargeModel.billDate = view.date;
            weakSelf.compoundModel.targetChargeModel.billDate = view.date;
            weakSelf.compoundModel.interestChargeModel.billDate = view.date;
//            [weakSelf updateInterest];
            [weakSelf.tableView reloadData];
        };
    }
    return _dateSelectionView;
}

@end
