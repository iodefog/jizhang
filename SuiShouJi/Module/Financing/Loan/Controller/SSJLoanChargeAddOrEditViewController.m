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
#import "SSJLoanDateSelectionView.h"
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
@property (nonatomic, strong) SSJLoanDateSelectionView *dateSelectionView;

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
    
    [self showDeleteItemIfNeeded];
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = self.footerView;
    self.tableView.hidden = YES;
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
        [cell setNeedsLayout];
        return cell;
        
    } else if (tag == kInterestTag) {
        
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanTextFieldCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:@"loan_yield"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.textLabel.text = [self titleForCellTag:tag];
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"¥0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        cell.textField.text = [NSString stringWithFormat:@"¥%.2f", self.compoundModel.interestChargeModel.money];
        cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
        cell.textField.clearsOnBeginEditing = YES;
        cell.textField.delegate = self;
        cell.textField.tag = kInterestTag;
        [cell setNeedsLayout];
        return cell;
        
    } else if (tag == kAccountTag) {
        
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:@"loan_account"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.textLabel.text = [self titleForCellTag:tag];
        SSJLoanFundAccountSelectionViewItem *selectedFundItem = [self.fundingSelectionView.items ssj_safeObjectAtIndex:self.fundingSelectionView.selectedIndex];
        cell.additionalIcon.image = [UIImage imageNamed:selectedFundItem.image];
        cell.subtitleLabel.text = selectedFundItem.title;
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
        self.dateSelectionView.selectedDate = self.compoundModel.chargeModel.billDate;
        [self.dateSelectionView show];
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == kMoneyTag
        || textField.tag == kInterestTag) {
        NSString *money = [textField.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
        textField.text = [NSString stringWithFormat:@"¥%.2f", [money doubleValue]];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == kMoneyTag && self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
        
        NSString *moneyStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
        moneyStr = [moneyStr stringByReplacingOccurrencesOfString:@"¥" withString:@""];
        
        if ([moneyStr doubleValue] > self.surplus) {
            
            self.compoundModel.chargeModel.money = self.surplus;
            self.compoundModel.targetChargeModel.money = self.surplus;
            [self updateInterest];
            textField.text = [NSString stringWithFormat:@"¥%.2f", self.surplus];
            
            switch (self.loanModel.type) {
                case SSJLoanTypeLend:
                    [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"收款金额不能大于剩余借出额%.2f元", self.surplus]];
                    break;
                    
                case SSJLoanTypeBorrow:
                    [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"还款金额不能大于剩余欠款%.2f元", self.surplus]];
                    break;
            }
            
            return NO;
        }
    }
    return YES;
}

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
    if ([self checkCompoundModelValid]) {
        if (self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
            self.loanModel.jMoney = self.surplus - self.compoundModel.chargeModel.money;
        } else if (self.chargeType == SSJLoanCompoundChargeTypeAdd) {
            self.loanModel.jMoney = self.surplus + self.compoundModel.chargeModel.money;
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
}

- (void)textDidChange:(NSNotification *)notification {
    UITextField *textField = notification.object;
    if ([textField isKindOfClass:[UITextField class]]) {
        
        if (textField.tag == kMoneyTag) {

            NSString *tmpMoneyStr = [textField.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
            tmpMoneyStr = [tmpMoneyStr ssj_reserveDecimalDigits:2 intDigits:0];
            textField.text = [NSString stringWithFormat:@"¥%@", tmpMoneyStr];
            double money = [tmpMoneyStr doubleValue];
            self.compoundModel.chargeModel.money = money;
            self.compoundModel.targetChargeModel.money = money;
            [self updateInterest];
            
        } else if (textField.tag == kInterestTag) {
            
            NSString *tmpMoneyStr = [textField.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
            tmpMoneyStr = [tmpMoneyStr ssj_reserveDecimalDigits:2 intDigits:0];
            textField.text = [NSString stringWithFormat:@"¥%@", tmpMoneyStr];
            self.compoundModel.interestChargeModel.money = [tmpMoneyStr doubleValue];
            
        } else if (textField.tag == kMemoTag) {
            
            self.compoundModel.chargeModel.memo = textField.text;
            self.compoundModel.targetChargeModel.memo = textField.text;
            self.compoundModel.interestChargeModel.memo = textField.text;
        }
    }
}

#pragma mark - Private
- (void)updateAppearance {
    [_sureButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
    [_sureButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor alpha:0.5] forState:UIControlStateDisabled];
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
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
            for (int i = 0; i < items.count; i ++) {
                SSJLoanFundAccountSelectionViewItem *item = items[i];
                if ([item.ID isEqualToString:self.compoundModel.targetChargeModel.fundId]) {
                    self.fundingSelectionView.selectedIndex = i;
                    break;
                }
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
#ifdef DEBUG
    message = [error localizedDescription];
#else
    message = SSJ_ERROR_MESSAGE;
#endif
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

- (BOOL)checkCompoundModelValid {
    if (self.compoundModel.chargeModel.money <= 0) {
        switch (self.loanModel.type) {
            case SSJLoanTypeLend:
                [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"收款金额必须大于0元"]];
                break;
                
            case SSJLoanTypeBorrow:
                [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"还款金额必须大于0元"]];
                break;
        }
        
        return NO;
    }
    
    if (self.chargeType == SSJLoanCompoundChargeTypeRepayment) {
        
        if (self.compoundModel.chargeModel.money > self.surplus) {
            self.compoundModel.chargeModel.money = self.surplus;
            self.compoundModel.targetChargeModel.money = self.surplus;
            [self updateInterest];
            switch (self.loanModel.type) {
                case SSJLoanTypeLend:
                    [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"收款金额不能大于剩余借出额%.2f元", self.surplus]];
                    break;
                    
                case SSJLoanTypeBorrow:
                    [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"还款金额不能大于剩余欠款%.2f元", self.surplus]];
                    break;
            }
            
            return NO;
        }
        
        if (self.compoundModel.chargeModel.money == self.surplus) {
            NSString *message = nil;
            switch (self.compoundModel.chargeModel.type) {
                case SSJLoanTypeLend:
                    message = @"您的收款金额等于剩余借出金额，是否立即结清该笔欠款？";
                    break;
                    
                case SSJLoanTypeBorrow:
                    message = @"您的还款金额等于剩余欠款金额，是否立即结清该笔欠款？";
                    break;
            }
            SSJAlertViewAction *cancelAction = [SSJAlertViewAction actionWithTitle:@"取消" handler:NULL];
            SSJAlertViewAction *sureAction = [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction * _Nonnull action) {
                SSJLoanCloseOutViewController *closeOutController = [[SSJLoanCloseOutViewController alloc] init];
                closeOutController.loanModel = self.loanModel;
                closeOutController.loanModel.endTargetFundID = self.compoundModel.targetChargeModel.fundId;
                closeOutController.loanModel.endDate = self.compoundModel.targetChargeModel.billDate;
                [self.navigationController pushViewController:closeOutController animated:YES];
            }];
            [SSJAlertViewAdapter showAlertViewWithTitle:nil message:message action:cancelAction, sureAction, nil];
            
            return NO;
        }
    }
    
    return YES;
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
                NewFundingVC.addNewFundingBlock = ^(SSJBaseItem *item){
                    if ([item isKindOfClass:[SSJFundingItem class]]) {
                        SSJFundingItem *fundItem = (SSJFundingItem *)item;
                        weakSelf.compoundModel.targetChargeModel.fundId = fundItem.fundingID;
                        weakSelf.compoundModel.interestChargeModel.fundId = fundItem.fundingID;
                        [weakSelf loadData];
                    } else if ([item isKindOfClass:[SSJCreditCardItem class]]){
                        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
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

- (SSJLoanDateSelectionView *)dateSelectionView {
    if (!_dateSelectionView) {
        __weak typeof(self) weakSelf = self;
        _dateSelectionView = [[SSJLoanDateSelectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        _dateSelectionView.selectedDate = self.compoundModel.chargeModel.billDate;
        _dateSelectionView.selectDateAction = ^(SSJLoanDateSelectionView *view) {
            weakSelf.compoundModel.chargeModel.billDate = view.selectedDate;
            weakSelf.compoundModel.targetChargeModel.billDate = view.selectedDate;
            weakSelf.compoundModel.interestChargeModel.billDate = view.selectedDate;
            [weakSelf updateInterest];
            [weakSelf.tableView reloadData];
        };
        _dateSelectionView.shouldSelectDateAction = ^BOOL(SSJLoanDateSelectionView *view, NSDate *date) {
            if ([date compare:weakSelf.loanModel.borrowDate] == NSOrderedAscending) {
                if (weakSelf.chargeType == SSJLoanCompoundChargeTypeRepayment) {
                    switch (weakSelf.loanModel.type) {
                        case SSJLoanTypeLend:
                            [CDAutoHideMessageHUD showMessage:@"收款日期不能早于借出日期"];
                            break;
                            
                        case SSJLoanTypeBorrow:
                            [CDAutoHideMessageHUD showMessage:@"还款日期不能早于借入日期"];
                            break;
                    }
                } else if (weakSelf.chargeType == SSJLoanCompoundChargeTypeAdd) {
                    [CDAutoHideMessageHUD showMessage:@"日期不能早于借入日期"];
                }
                
                return NO;
            }
            return YES;
        };
    }
    return _dateSelectionView;
}

@end
