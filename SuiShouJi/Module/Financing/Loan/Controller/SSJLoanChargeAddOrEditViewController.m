//
//  SSJLoanChargeAddOrEditViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/11/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanChargeAddOrEditViewController.h"
#import "SSJFundingTypeSelectViewController.h"
#import "SSJLoanCloseOutViewController.h"
#import "SSJAddOrEditLoanLabelCell.h"
#import "SSJAddOrEditLoanTextFieldCell.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJLoanFundAccountSelectionView.h"
#import "SSJHomeDatePickerView.h"
#import "SSJLoanInterestTypeAlertView.h"
#import "UIView+SSJViewAnimatioin.h"
#import "SSJTextFieldToolbarManager.h"
#import "SSJFundingItem.h"
#import "SSJCreditCardItem.h"
#import "SSJLoanHelper.h"


static NSString *const kAddOrEditLoanLabelCellId = @"SSJAddOrEditLoanLabelCell";
static NSString *const kAddOrEditLoanTextFieldCellId = @"SSJAddOrEditLoanTextFieldCell";

static NSUInteger kMoneyTag = 1001;
static NSUInteger kInterestTag = 1002;
static NSUInteger kAccountTag = 1003;
static NSUInteger kMemoTag = 1004;
static NSUInteger kDateTag = 1005;

@interface SSJLoanChargeAddOrEditViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) UIView *footerView;

// 借贷账户
@property (nonatomic, strong) SSJLoanFundAccountSelectionView *fundingSelectionView;

// 日期选择控件
@property (nonatomic, strong) SSJHomeDatePickerView *dateSelectionView;

@property (nonatomic, strong) SSJLoanInterestTypeAlertView *interestTypeAlertView;

@property (nonatomic, strong) SSJLoanModel *loanModel;

@property (nonatomic, strong) SSJLoanCompoundChargeModel *compoundModel;

@property (nonatomic, strong) NSArray *cellTags;

// 剩余金额（排除本次流水金额）
@property (nonatomic) double surplus;

@end

@implementation SSJLoanChargeAddOrEditViewController

#pragma mark - Lifecycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
    
    [self showDeleteItemIfNeeded];
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
    return self.cellTags.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.cellTags ssj_safeObjectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger tag = [[self.cellTags ssj_objectAtIndexPath:indexPath] unsignedIntegerValue];
    if (tag == kMoneyTag) {
        
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanTextFieldCellId forIndexPath:indexPath];
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
        
    } else if (tag == kInterestTag) {
        
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanTextFieldCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:@"loan_yield"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.textLabel.text = [self titleForCellTag:tag];
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"¥0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        cell.textField.text = [NSString stringWithFormat:@"¥%.2f", self.compoundModel.interestChargeModel.money];
        cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
        [cell.textField ssj_installToolbar];
        cell.textField.clearsOnBeginEditing = YES;
        cell.textField.delegate = self;
        cell.textField.tag = kInterestTag;
        [cell setNeedsLayout];
        return cell;
        
    } else if (tag == kAccountTag) {
        
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
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
        
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanTextFieldCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:@"loan_memo"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.textLabel.text = [self titleForCellTag:tag];
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"选填" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        cell.textField.text = self.compoundModel.chargeModel.memo;
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.textField.clearsOnBeginEditing = NO;
        cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        cell.textField.delegate = self;
        cell.textField.tag = kMemoTag;
        [cell setNeedsLayout];
        return cell;
        
    } else if (tag == kDateTag) {
        
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
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
    if (textField.tag == kMoneyTag) {
        self.compoundModel.chargeModel.money = 0;
        self.compoundModel.targetChargeModel.money = 0;
        [self updateInterest];
    } else if (textField.tag == kInterestTag) {
        self.compoundModel.interestChargeModel.money = 0;
    } else if (textField.tag == kMemoTag) {
        self.compoundModel.chargeModel.memo = @"";
        self.compoundModel.targetChargeModel.memo = @"";
        self.compoundModel.interestChargeModel.memo = @"";
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Event
- (void)deleteItemAction {
    [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"您确认删除该记录" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:NULL], [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction *action) {
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [SSJLoanHelper deleteLoanCompoundChargeModel:self.compoundModel success:^{
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [CDAutoHideMessageHUD showMessage:@"删除成功"];
            [self goBackAction];
        } failure:^(NSError * _Nonnull error) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [self showError:error];
        }];
        
    }], nil];
}

- (void)sureButtonAction {
    
    if (self.surplus == 0 && self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
        switch (self.loanModel.type) {
            case SSJLoanTypeLend:
                [CDAutoHideMessageHUD showMessage:@"你的剩余借出款为0，无需再收款了"];
                break;
                
            case SSJLoanTypeBorrow:
                [CDAutoHideMessageHUD showMessage:@"你的剩余欠款为0，无需再还款了"];
                break;
        }
        return;
    }
    
    if (self.compoundModel.chargeModel.money <= 0) {
        switch (self.loanModel.type) {
            case SSJLoanTypeLend:
                [CDAutoHideMessageHUD showMessage:@"收款金额必须大于0元"];
                break;
                
            case SSJLoanTypeBorrow:
                [CDAutoHideMessageHUD showMessage:@"还款金额必须大于0元"];
                break;
        }
        return;
    }
    
    if (!self.compoundModel.targetChargeModel.fundId.length) {
        if (self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
            switch (self.loanModel.type) {
                case SSJLoanTypeLend:
                    [CDAutoHideMessageHUD showMessage:@"请选择转入账户"];
                    break;
                    
                case SSJLoanTypeBorrow:
                    [CDAutoHideMessageHUD showMessage:@"请选择转出账户"];
                    break;
            }
        } else if (self.chargeType == SSJLoanCompoundChargeTypeAdd) {
            switch (self.loanModel.type) {
                case SSJLoanTypeLend:
                    [CDAutoHideMessageHUD showMessage:@"请选择转出账户"];
                    break;
                    
                case SSJLoanTypeBorrow:
                    [CDAutoHideMessageHUD showMessage:@"请选择转入账户"];
                    break;
            }
        }
        
        return;
    }
    
    if (self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
        
        if (self.compoundModel.chargeModel.money > self.surplus) {
            self.compoundModel.chargeModel.money = self.surplus;
            self.compoundModel.targetChargeModel.money = self.surplus;
            [self updateInterest];
            switch (self.loanModel.type) {
                case SSJLoanTypeLend:
                    [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"修改后的金额需要≤%.2f，否则剩余借出款会为负哦", self.surplus]];
                    break;
                    
                case SSJLoanTypeBorrow:
                    [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"修改后的金额需要≤%.2f，否则剩余欠款会为正哦", self.surplus]];
                    break;
            }
            
            return;
        }
        
        if (self.compoundModel.chargeModel.money == self.surplus) {
            // 因为金额输入框的clearsOnBeginEditing设为YES，系统弹窗出现后输入框会失去焦点，弹窗消失后又会重新获取焦，输入框内容被清空，导致调用[self saveLoanCharge]方法保存的金额就变成0了，所以这里强制取消焦点
            [self.view endEditing:YES];
            
            NSString *message = nil;
            switch (self.compoundModel.chargeModel.type) {
                case SSJLoanTypeLend:
                    message = @"您的收款金额等于剩余借出金额，是否立即结清该笔欠款？";
                    break;
                    
                case SSJLoanTypeBorrow:
                    message = @"您的还款金额等于剩余欠款金额，是否立即结清该笔欠款？";
                    break;
            }
            
            SSJAlertViewAction *cancelAction = [SSJAlertViewAction actionWithTitle:@"取消" handler:^(SSJAlertViewAction * _Nonnull action) {
                if (![self showInterestTypeAlertIfNeeded]) {
                    [self saveLoanCharge];
                }
            }];
            SSJAlertViewAction *sureAction = [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction * _Nonnull action) {
                SSJLoanCloseOutViewController *closeOutController = [[SSJLoanCloseOutViewController alloc] init];
                closeOutController.loanModel = self.loanModel;
                closeOutController.loanModel.endTargetFundID = self.compoundModel.targetChargeModel.fundId;
                closeOutController.loanModel.endDate = self.compoundModel.targetChargeModel.billDate;
                
                NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];
                [controllers removeObject:self];
                [controllers addObject:closeOutController];
                [self.navigationController setViewControllers:controllers animated:YES];
            }];
            [SSJAlertViewAdapter showAlertViewWithTitle:nil message:message action:cancelAction, sureAction, nil];
            
            return;
        }
    }
    
    if (self.chargeType == SSJLoanCompoundChargeTypeAdd) {
        if (self.surplus + self.compoundModel.chargeModel.money < 0) {
            
            double money = ABS(self.surplus);
            
            self.compoundModel.chargeModel.money = money;
            self.compoundModel.targetChargeModel.money = money;
            [self updateInterest];
            
            switch (self.loanModel.type) {
                case SSJLoanTypeLend:
                    [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"修改后的金额需要≥%.2f，否则剩余借出款会为负哦", money]];
                    break;
                    
                case SSJLoanTypeBorrow:
                    [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"修改后的金额需要≥%.2f，否则剩余欠款会为正哦", money]];
                    break;
            }
            
            return;
        }
    }
    
    if (![self showInterestTypeAlertIfNeeded]) {
        [self saveLoanCharge];
    }
}

- (void)textDidChange:(NSNotification *)notification {
    UITextField *textField = notification.object;
    if ([textField isKindOfClass:[UITextField class]]) {
        
        if (textField.tag == kMoneyTag) {
            
            NSString *tmpMoneyStr = [textField.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
            tmpMoneyStr = [tmpMoneyStr ssj_reserveDecimalDigits:2 intDigits:0];
            
            if (self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
                if (self.surplus - [tmpMoneyStr doubleValue] < 0) {
                    
                    tmpMoneyStr = [NSString stringWithFormat:@"%.2f", self.surplus];
                    
                    switch (self.loanModel.type) {
                        case SSJLoanTypeLend:
                            [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"修改后的金额需要≤%.2f，否则剩余借出款会为负哦", self.surplus]];
                            break;
                            
                        case SSJLoanTypeBorrow:
                            [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"修改后的金额需要≤%.2f，否则剩余欠款会为正哦", self.surplus]];
                            break;
                    }
                }
            }
            
            textField.text = [NSString stringWithFormat:@"¥%@", tmpMoneyStr];
            
            double money = [tmpMoneyStr doubleValue];
            self.compoundModel.chargeModel.money = money;
            self.compoundModel.targetChargeModel.money = money;
            [self updateInterest];
            
        } else if (textField.tag == kInterestTag) {
            
            NSString *tmpMoneyStr = [textField.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
            tmpMoneyStr = [tmpMoneyStr ssj_reserveDecimalDigits:2 intDigits:9];
            textField.text = [NSString stringWithFormat:@"¥%@", tmpMoneyStr];
            self.compoundModel.interestChargeModel.money = [tmpMoneyStr doubleValue];
            
        } else if (textField.tag == kMemoTag) {
            if (textField.text.length > 15) {
                textField.text = [textField.text substringToIndex:15];
            }
            self.compoundModel.chargeModel.memo = textField.text;
            self.compoundModel.targetChargeModel.memo = textField.text;
            self.compoundModel.interestChargeModel.memo = textField.text;
        }
    }
}

#pragma mark - Private
- (void)updateAppearance {
    [_sureButton ssj_setBackgroundColor:SSJ_BUTTON_NORMAL_COLOR forState:UIControlStateNormal];
    [_sureButton ssj_setBackgroundColor:SSJ_BUTTON_DISABLE_COLOR forState:UIControlStateDisabled];
    _tableView.separatorColor = SSJ_CELL_SEPARATOR_COLOR;
}

- (void)updateTitle {
    switch (self.loanModel.type) {
        case SSJLoanTypeLend:
            if (self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
                self.title = @"收款";
            } else if (self.chargeType == SSJLoanCompoundChargeTypeAdd) {
                self.title = @"追加借出";
            }
            break;
            
        case SSJLoanTypeBorrow:
            if (self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
                self.title = @"还款";
            } else if (self.chargeType == SSJLoanCompoundChargeTypeAdd) {
                self.title = @"追加欠款";
            }
            break;
    }
}

- (void)showDeleteItemIfNeeded {
    if (_edited) {
        UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteItemAction)];
        self.navigationItem.rightBarButtonItem = deleteItem;
    }
}

- (void)loadData {
    [self.view ssj_showLoadingIndicator];
    
    if (self.edited) {
        [SSJLoanHelper queryLoanCompoundChangeModelWithChargeId:self.chargeId success:^(SSJLoanCompoundChargeModel * _Nonnull model) {
            self.compoundModel = model;
            self.chargeType = self.compoundModel.chargeModel.chargeType;
            [self loadLoanModelAndFundListWithLoanId:self.compoundModel.chargeModel.loanId];
        } failure:^(NSError * _Nonnull error) {
            [self.view ssj_hideLoadingIndicator];
            [self showError:error];
        }];
    } else {
        [self loadLoanModelAndFundListWithLoanId:self.loanId];
    }
}

- (void)loadLoanModelAndFundListWithLoanId:(NSString *)loanId {
    [SSJLoanHelper queryForLoanModelWithLoanID:loanId success:^(SSJLoanModel * _Nonnull model) {
        [SSJLoanHelper queryFundModelListWithSuccess:^(NSArray <SSJLoanFundAccountSelectionViewItem *>*items) {
            
            [self.view ssj_hideLoadingIndicator];
            
            self.loanModel = model;
            
            if (!_edited) {
                [self initCompoundModel];
            }
            
            if (self.surplus == 0) {
                if (self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
                    self.surplus = self.loanModel.jMoney + self.compoundModel.chargeModel.money;
                } else if (self.chargeType == SSJLoanCompoundChargeTypeAdd) {
                    self.surplus = self.loanModel.jMoney - self.compoundModel.chargeModel.money;
                }
            }
            
            [self updateTitle];
            [self organiseCellTags];
            [self.tableView reloadData];
            self.tableView.hidden = NO;
            
            self.fundingSelectionView.items = items;
            self.fundingSelectionView.selectedIndex = -1;
            
            BOOL hasSelectedFund = NO;  // 目标账户是否在现有的资金列表中
            for (int i = 0; i < items.count; i ++) {
                SSJLoanFundAccountSelectionViewItem *item = items[i];
                if ([item.ID isEqualToString:self.compoundModel.targetChargeModel.fundId]) {
                    self.fundingSelectionView.selectedIndex = i;
                    hasSelectedFund = YES;
                    break;
                }
            }
            
            // 如果目标账户不在现有的资金列表中，将目标账户置为nil
            if (!hasSelectedFund) {
                self.compoundModel.targetChargeModel.fundId = nil;
            }
            
        } failure:^(NSError * _Nonnull error) {
            [self.view ssj_hideLoadingIndicator];
            [self showError:error];
        }];
        
    } failure:^(NSError * _Nonnull error) {
        [self.view ssj_hideLoadingIndicator];
        [self showError:error];
    }];
}

- (void)showError:(NSError *)error {
    NSString *message = nil;
    if (error.code == 1) {
        message = @"该流水暂不能删除哦，可先编辑收款或追加借出金额再操作。";
    } else {
#ifdef DEBUG
        message = [error localizedDescription];
#else
        message = SSJ_ERROR_MESSAGE;
#endif
    }

    [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:message action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
}

- (void)initCompoundModel {
    if (!_compoundModel) {
        NSString *chargeBillId = nil;
        NSString *targetChargeBillId = nil;
        NSString *interestChargeBillId = nil;
        
        switch (self.loanModel.type) {
            case SSJLoanTypeLend:
                if (self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
                    chargeBillId = @"8";
                    targetChargeBillId = @"7";
                    interestChargeBillId = @"5";
                } else if (self.chargeType == SSJLoanCompoundChargeTypeAdd) {
                    chargeBillId = @"7";
                    targetChargeBillId = @"8";
                }
                break;
                
            case SSJLoanTypeBorrow:
                if (self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
                    chargeBillId = @"7";
                    targetChargeBillId = @"8";
                    interestChargeBillId = @"6";
                } else if (self.chargeType == SSJLoanCompoundChargeTypeAdd) {
                    chargeBillId = @"8";
                    targetChargeBillId = @"7";
                }
                break;
        }
        
        NSDate *today = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day];
        NSDate *billDate = [today compare:self.loanModel.borrowDate] == NSOrderedAscending ? self.loanModel.borrowDate : today;
        
        SSJLoanChargeModel *chargeModel = [[SSJLoanChargeModel alloc] init];
        chargeModel.chargeId = SSJUUID();
        chargeModel.fundId = self.loanModel.fundID;
        chargeModel.billId = chargeBillId;
        chargeModel.loanId = self.loanModel.ID;
        chargeModel.userId = SSJUSERID();
        chargeModel.billDate = billDate;
        chargeModel.chargeType = self.chargeType;
        
        SSJLoanChargeModel *targetChargeModel = [[SSJLoanChargeModel alloc] init];
        targetChargeModel.chargeId = SSJUUID();
        targetChargeModel.fundId = self.loanModel.targetFundID;
        targetChargeModel.billId = targetChargeBillId;
        targetChargeModel.loanId = self.loanModel.ID;
        targetChargeModel.userId = SSJUSERID();
        targetChargeModel.billDate = billDate;
        targetChargeModel.chargeType = self.chargeType;
        
        _compoundModel = [[SSJLoanCompoundChargeModel alloc] init];
        _compoundModel.chargeModel = chargeModel;
        _compoundModel.targetChargeModel = targetChargeModel;
        
        // 新建还款流水并且此借贷开启计息，创建一个利息流水模型
        if (!_edited
            && self.loanModel.interest
            && self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
            
            SSJLoanChargeModel *interestModel = [[SSJLoanChargeModel alloc] init];
            interestModel.chargeId = SSJUUID();
            interestModel.fundId = self.loanModel.targetFundID;
            interestModel.billId = interestChargeBillId;
            interestModel.loanId = self.loanModel.ID;
            interestModel.userId = SSJUSERID();
            interestModel.billDate = billDate;
            interestModel.chargeType = SSJLoanCompoundChargeTypeInterest;
            
            _compoundModel.interestChargeModel = interestModel;
        }
    }
}

- (void)organiseCellTags {
    if (self.compoundModel.interestChargeModel) {
        _cellTags = @[@[@(kMoneyTag),
                        @(kInterestTag),
                        @(kAccountTag)],
                      @[@(kMemoTag),
                        @(kDateTag)]];
    } else {
        _cellTags = @[@[@(kMoneyTag),
                        @(kAccountTag)],
                      @[@(kMemoTag),
                        @(kDateTag)]];
    }
}

- (NSString *)titleForCellTag:(NSUInteger)tag {
    if (tag == kMoneyTag) {
        switch (self.loanModel.type) {
            case SSJLoanTypeLend:
                if (self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
                    return @"收款金额";
                } else if (self.chargeType == SSJLoanCompoundChargeTypeAdd) {
                    return @"追加借出金额";
                }
                break;
                
            case SSJLoanTypeBorrow:
                if (self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
                    return @"还款金额";
                } else if (self.chargeType == SSJLoanCompoundChargeTypeAdd) {
                    return @"追加欠款金额";
                }
                break;
        }
    } else if (tag == kInterestTag) {
        switch (self.loanModel.type) {
            case SSJLoanTypeLend:
                return @"利息收入";
                break;
                
            case SSJLoanTypeBorrow:
                return @"利息支出";
                break;
        }
    } else if (tag == kAccountTag) {
        switch (self.loanModel.type) {
            case SSJLoanTypeLend:
                if (self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
                    return @"转入账户";
                } else if (self.chargeType == SSJLoanCompoundChargeTypeAdd) {
                    return @"转出账户";
                }
                break;
                
            case SSJLoanTypeBorrow:
                if (self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
                    return @"转出账户";
                } else if (self.chargeType == SSJLoanCompoundChargeTypeAdd) {
                    return @"转入账户";
                }
                break;
        }
    } else if (tag == kMemoTag) {
        return @"备注";
    } else if (tag == kDateTag) {
        if (self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
            switch (self.loanModel.type) {
                case SSJLoanTypeLend:
                    return @"收款日期";
                    break;
                    
                case SSJLoanTypeBorrow:
                    return @"还款日期";
                    break;
            }
        } else if (self.chargeType == SSJLoanCompoundChargeTypeAdd) {
            return @"日期";
        }
    }
    
    return nil;
}

- (void)updateInterest {
    if (self.compoundModel.interestChargeModel) {
        double principal = self.compoundModel.chargeModel.money;
        double rate = self.loanModel.rate;
        int days = (int)[self.compoundModel.chargeModel.billDate daysFrom:self.loanModel.borrowDate];
        days = MAX(days, 0);
        self.compoundModel.interestChargeModel.money = [SSJLoanHelper interestWithPrincipal:principal rate:rate days:days];
        
        if ([self.tableView numberOfRowsInSection:0] > 1) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (BOOL)showInterestTypeAlertIfNeeded {
    if (self.loanModel.interest
        && self.loanModel.interestType == SSJLoanInterestTypeUnknown) {
        
        [self.view endEditing:YES];
        
        NSString *title = nil;
        switch (self.loanModel.type) {
            case SSJLoanTypeLend:
                title = @"剩余借出款变更后计息是否变化？";
                break;
                
            case SSJLoanTypeBorrow:
                title = @"剩余欠款变更后计息是否变化？";
                break;
        }
        
        NSString *buttonTitle1 = [NSString stringWithFormat:@"仍按%.2f元计息", self.surplus];
        
        NSString *date = nil;
        if ([self.compoundModel.chargeModel.billDate isSameDay:[NSDate date]]) {
            date = @"今日";
        } else {
            date = [self.compoundModel.chargeModel.billDate formattedDateWithFormat:@"yyyy-MM-dd"];
        }
        
        double newPrincipal = 0;
        if (self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
            newPrincipal = self.surplus - self.compoundModel.chargeModel.money;
        } else if (self.chargeType == SSJLoanCompoundChargeTypeAdd) {
            newPrincipal = self.surplus + self.compoundModel.chargeModel.money;
        }
        
        NSString *buttonTitle2 = [NSString stringWithFormat:@"由%@起按%.2f元计息", date, newPrincipal];
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        
        self.interestTypeAlertView.title = title;
        self.interestTypeAlertView.originalPrincipalButtonTitle = buttonTitle1;
        self.interestTypeAlertView.changePrincipalButtonTitle = buttonTitle2;
        [self.interestTypeAlertView ssj_popupInView:window completion:NULL];
        
        return YES;
    }
    
    return NO;
}

- (void)saveLoanCharge {
    
    // 更新借贷的剩余金额
    if (self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
        self.loanModel.jMoney = self.surplus - self.compoundModel.chargeModel.money;
    } else if (self.chargeType == SSJLoanCompoundChargeTypeAdd) {
        self.loanModel.jMoney = self.surplus + self.compoundModel.chargeModel.money;
    }
    
    // 利息金额为0的话，清空利息模型
    if (self.compoundModel.interestChargeModel.money == 0) {
        self.compoundModel.interestChargeModel = nil;
    }
    
    self.sureButton.enabled = NO;
    [self.sureButton ssj_showLoadingIndicator];
    [SSJLoanHelper saveLoanModel:self.loanModel chargeModels:@[self.compoundModel] remindModel:nil success:^{
        self.sureButton.enabled = YES;
        [self.sureButton ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:@"保存成功"];
        [self goBackAction];
    } failure:^(NSError * _Nonnull error) {
        self.sureButton.enabled = YES;
        [self.sureButton ssj_hideLoadingIndicator];
        [self showError:error];
    }];
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
                SSJFundingTypeSelectViewController *NewFundingVC = [[SSJFundingTypeSelectViewController alloc]init];
                NewFundingVC.needLoanOrNot = NO;
                NewFundingVC.addNewFundingBlock = ^(SSJBaseCellItem *item){
                    
                    if ([item isKindOfClass:[SSJFundingItem class]]) {
                        SSJFundingItem *fundItem = (SSJFundingItem *)item;
                        weakSelf.compoundModel.targetChargeModel.fundId = fundItem.fundingID;
                        weakSelf.compoundModel.interestChargeModel.fundId = fundItem.fundingID;
                    } else if ([item isKindOfClass:[SSJCreditCardItem class]]){
                        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
                        weakSelf.compoundModel.targetChargeModel.fundId = cardItem.cardId;
                        weakSelf.compoundModel.interestChargeModel.fundId = cardItem.cardId;
                    }
                    
                    if (weakSelf.edited) {
                        [weakSelf loadLoanModelAndFundListWithLoanId:weakSelf.compoundModel.chargeModel.loanId];
                    } else {
                        [weakSelf loadLoanModelAndFundListWithLoanId:weakSelf.loanId];
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

- (SSJHomeDatePickerView *)dateSelectionView {
    if (!_dateSelectionView) {
        __weak typeof(self) weakSelf = self;
        _dateSelectionView = [[SSJHomeDatePickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        _dateSelectionView.horuAndMinuBgViewBgColor = [UIColor clearColor];
        _dateSelectionView.datePickerMode = SSJDatePickerModeDate;
        _dateSelectionView.date = self.compoundModel.chargeModel.billDate;
        _dateSelectionView.shouldConfirmBlock = ^BOOL(SSJHomeDatePickerView *view, NSDate *date) {
            if ([date compare:weakSelf.loanModel.borrowDate] == NSOrderedAscending) {
                if (weakSelf.chargeType == SSJLoanCompoundChargeTypeRepayment) {
                    switch (weakSelf.loanModel.type) {
                        case SSJLoanTypeLend:
                            [CDAutoHideMessageHUD showMessage:@"收款日期不能早于借出日期"];
                            break;
                            
                        case SSJLoanTypeBorrow:
                            [CDAutoHideMessageHUD showMessage:@"还款日期不能早于欠款日期"];
                            break;
                    }
                } else if (weakSelf.chargeType == SSJLoanCompoundChargeTypeAdd) {
                    [CDAutoHideMessageHUD showMessage:@"日期不能早于欠款日期"];
                }
                
                return NO;
            }
            return YES;
        };
        _dateSelectionView.confirmBlock = ^(SSJHomeDatePickerView *view) {
            weakSelf.compoundModel.chargeModel.billDate = view.date;
            weakSelf.compoundModel.targetChargeModel.billDate = view.date;
            weakSelf.compoundModel.interestChargeModel.billDate = view.date;
            [weakSelf updateInterest];
            [weakSelf.tableView reloadData];
        };
    }
    return _dateSelectionView;
}

- (SSJLoanInterestTypeAlertView *)interestTypeAlertView {
    if (!_interestTypeAlertView) {
        __weak typeof(self) wself = self;
        _interestTypeAlertView = [[SSJLoanInterestTypeAlertView alloc] init];
        _interestTypeAlertView.interestType = SSJLoanInterestTypeAlertViewTypeOriginalPrincipal;
        _interestTypeAlertView.sureAction = ^(SSJLoanInterestTypeAlertView *alert) {
            [alert ssj_dismiss:NULL];
            wself.loanModel.interestType = (SSJLoanInterestType)alert.interestType;
            [wself saveLoanCharge];
        };
    }
    return _interestTypeAlertView;
}

@end
