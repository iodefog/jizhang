//
//  SSJAddOrEditLoanViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/8/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJAddOrEditLoanViewController.h"
#import "SSJReminderEditeViewController.h"
#import "SSJLoanListViewController.h"
#import "SSJLoanListViewController.h"
#import "SSJFundingTypeSelectViewController.h"
#import "SSJAddOrEditLoanLabelCell.h"
#import "SSJAddOrEditLoanTextFieldCell.h"
#import "SSJAddOrEditLoanMultiLabelCell.h"
#import "SSJLoanFundAccountSelectionView.h"
#import "SSJLoanDateSelectionView.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJLoanHelper.h"
#import "SSJLocalNotificationStore.h"
#import "SSJDataSynchronizer.h"
#import "SSJCreditCardItem.h"
#import "SSJFundingItem.h"

static NSString *const kAddOrEditLoanLabelCellId = @"SSJAddOrEditLoanLabelCell";
static NSString *const kAddOrEditLoanTextFieldCellId = @"SSJAddOrEditLoanTextFieldCell";
static NSString *const kAddOrEditLoanMultiLabelCellId = @"SSJAddOrEditLoanMultiLabelCell";

const NSInteger kLenderTag = 1001;
const NSInteger kMoneyTag = 1002;
const NSInteger kMemoTag = 1003;
const NSInteger kRateTag = 1004;

const int kLenderMaxLength = 7;
const int kMemoMaxLength = 13;

@interface SSJAddOrEditLoanViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) UIButton *sureButton;

// 借贷账户
@property (nonatomic, strong) SSJLoanFundAccountSelectionView *fundingSelectionView;

// 借贷日
@property (nonatomic, strong) SSJLoanDateSelectionView *borrowDateSelectionView;

// 期限日
@property (nonatomic, strong) SSJLoanDateSelectionView *repaymentDateSelectionView;

@property (nonatomic, strong) SSJReminderItem *reminderItem;

@property (nonatomic, strong) UILabel *interestLab;

@property (nonatomic) BOOL edited;

// 原始的借贷金额，只有在编辑记录此金额
@property (nonatomic) double originalMoney;

// 创建借贷时产生的流水
@property (nonatomic, strong) SSJLoanCompoundChargeModel *createCompoundModel;

// 编辑借贷金额新产生的余额变更流水
@property (nonatomic, strong) SSJLoanCompoundChargeModel *changeCompoundModel;

@property (nonatomic, strong) NSMutableArray <SSJLoanCompoundChargeModel *>*savedChargeModels;

@end

@implementation SSJAddOrEditLoanViewController

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
    
    _edited = (_loanModel && _chargeModels);
    
    if (_loanModel.remindID.length) {
        _reminderItem = [SSJLocalNotificationStore queryReminderItemForID:_loanModel.remindID];
    }
    
    [self loadData];
    [self updateTitle];
    
    if (_edited) {
        self.originalMoney = _loanModel.jMoney;
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonClicked)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = self.footerView;
    self.tableView.hidden = YES;
    
    [self updateAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_tableView reloadData];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 3;
    } else if (section == 2) {
        return self.loanModel.interest ? 2 : 1;
    } else if (section == 3) {
        return 1;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:0]] == NSOrderedSame) {
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanTextFieldCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:@"loan_person"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        switch (self.loanModel.type) {
            case SSJLoanTypeLend:
                cell.textLabel.text = @"被谁借款";
                break;
                
            case SSJLoanTypeBorrow:
                cell.textLabel.text = @"欠谁钱款";
                break;
        }
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"必填" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        cell.textField.text = self.loanModel.lender;
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.textField.delegate = self;
        cell.textField.clearsOnBeginEditing = YES;
        cell.textField.tag = kLenderTag;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:1 inSection:0]] == NSOrderedSame) {
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanTextFieldCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:@"loan_money"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        switch (self.loanModel.type) {
            case SSJLoanTypeLend:
                cell.textLabel.text = @"借出金额";
                break;
                
            case SSJLoanTypeBorrow:
                cell.textLabel.text = @"欠款金额";
                break;
        }
        
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"¥0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        cell.textField.text = [NSString stringWithFormat:@"¥%.2f", self.loanModel.jMoney];
        cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
        cell.textField.clearsOnBeginEditing = YES;
        cell.textField.delegate = self;
        cell.textField.tag = kMoneyTag;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:2 inSection:0]] == NSOrderedSame) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:@"loan_account"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        switch (self.loanModel.type) {
            case SSJLoanTypeLend:
                cell.textLabel.text = @"借出账户";
                break;
                
            case SSJLoanTypeBorrow:
                cell.textLabel.text = @"借入账户";
                break;
        }
        
        SSJLoanFundAccountSelectionViewItem *selectedFundItem = [self.fundingSelectionView.items ssj_safeObjectAtIndex:_fundingSelectionView.selectedIndex];
        cell.additionalIcon.image = [UIImage imageNamed:selectedFundItem.image];
        cell.subtitleLabel.text = selectedFundItem.title;
        cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.switchControl.hidden = YES;
        cell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:1]] == NSOrderedSame) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:@"loan_calendar"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        switch (self.loanModel.type) {
            case SSJLoanTypeLend:
                cell.textLabel.text = @"借款日";
                break;
                
            case SSJLoanTypeBorrow:
                cell.textLabel.text = @"欠款日";
                break;
        }
        
        cell.additionalIcon.image = nil;
        cell.subtitleLabel.text = [self.loanModel.borrowDate formattedDateWithFormat:@"yyyy.MM.dd"];
        cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.switchControl.hidden = YES;
        cell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:1 inSection:1]] == NSOrderedSame) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:@"loan_expires"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.textLabel.text = @"还款日";
        
        cell.additionalIcon.image = nil;
        if (self.loanModel.repaymentDate) {
            cell.subtitleLabel.text = [self.loanModel.repaymentDate formattedDateWithFormat:@"yyyy.MM.dd"];
            cell.subtitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        } else {
            cell.subtitleLabel.text = @"选填";
            cell.subtitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        }
        cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.switchControl.hidden = YES;
        cell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:2 inSection:1]] == NSOrderedSame) {
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanTextFieldCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:@"loan_memo"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.textLabel.text = @"备注";
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"选填" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        cell.textField.text = self.loanModel.memo;
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.textField.clearsOnBeginEditing = NO;
        cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        cell.textField.delegate = self;
        cell.textField.tag = kMemoTag;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:2]] == NSOrderedSame) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:@"loan_interest"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.textLabel.text = @"计息";
        cell.additionalIcon.image = nil;
        cell.subtitleLabel.text = nil;
        cell.switchControl.hidden = NO;
        [cell.switchControl setOn:self.loanModel.interest animated:YES];
        [cell.switchControl addTarget:self action:@selector(interestSwitchAction:) forControlEvents:UIControlEventValueChanged];
        cell.customAccessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:1 inSection:2]] == NSOrderedSame) {
        SSJAddOrEditLoanMultiLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanMultiLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:@"loan_yield"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.textLabel.text = @"年化收益率";
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"0.0" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        if (self.loanModel.rate) {
            cell.textField.text = [NSString stringWithFormat:@"%.1f", self.loanModel.rate * 100];
        }
        cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
        cell.textField.delegate = self;
        cell.textField.tag = kRateTag;
        [cell setNeedsLayout];
        
        _interestLab = cell.subtitleLabel;
        [self updateInterest];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:3]] == NSOrderedSame) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:@"loan_remind"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.textLabel.text = @"到期日提醒";
        cell.subtitleLabel.text = [_reminderItem.remindDate formattedDateWithFormat:@"yyyy.MM.dd"];
        cell.additionalIcon.image = nil;
        cell.customAccessoryType = UITableViewCellAccessoryNone;
        cell.switchControl.hidden = NO;
        cell.switchControl.on = _reminderItem.remindState;
        [cell.switchControl addTarget:self action:@selector(remindSwitchAction:) forControlEvents:UIControlEventValueChanged];
        cell.selectionStyle = _reminderItem ? SSJ_CURRENT_THEME.cellSelectionStyle : UITableViewCellSelectionStyleNone;
        [cell setNeedsLayout];
        
        return cell;
        
    } else {
        return [[UITableViewCell alloc] init];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare:[NSIndexPath indexPathForRow:1 inSection:2]] == NSOrderedSame) {
        return 74;
    } else {
        return 54;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([indexPath compare:[NSIndexPath indexPathForRow:2 inSection:0]] == NSOrderedSame) {
        [self.view endEditing:YES];
        [self.fundingSelectionView show];
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:1]] == NSOrderedSame) {
        [self.view endEditing:YES];
        self.borrowDateSelectionView.selectedDate = self.loanModel.borrowDate;
        [self.borrowDateSelectionView show];
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:1 inSection:1]] == NSOrderedSame) {
        [self.view endEditing:YES];
        self.repaymentDateSelectionView.selectedDate = [self paymentDate];
        [self.repaymentDateSelectionView show];
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:3]] == NSOrderedSame) {
        if (_reminderItem) {
            [self enterReminderVC];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == kMoneyTag) {
        NSString *money = [textField.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
        textField.text = [NSString stringWithFormat:@"¥%.2f", [money doubleValue]];
    } else if (textField.tag == kRateTag) {
        textField.text = [NSString stringWithFormat:@"%.1f", [textField.text doubleValue]];
    }
}

// 有些输入框的clearsOnBeginEditing设为YES，只要获取焦点文本内容就会清空，这种情况下不会收到文本改变的通知，所以在这个代理函数中进行了处理
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField.tag == kLenderTag) {
        self.loanModel.lender = @"";
        [self updateRemindName];
    } else if (textField.tag == kMoneyTag) {
        self.loanModel.jMoney = 0;
        
        [self updateRemindName];
        [self updateInterest];
    } else if (textField.tag == kMemoTag) {
        self.loanModel.memo = @"";
    } else if (textField.tag == kRateTag) {
        self.loanModel.rate = 0;
        [self updateInterest];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Event
- (void)textDidChange:(NSNotification *)notification {
    UITextField *textField = notification.object;
    if ([textField isKindOfClass:[UITextField class]]) {
        
        if (textField.tag == kLenderTag) {
            
            self.loanModel.lender = textField.text;
            [self updateRemindName];
            
        } else if (textField.tag == kMoneyTag) {
            
            NSString *tmpMoneyStr = [textField.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
            if (tmpMoneyStr.length) {
                tmpMoneyStr = [NSString stringWithFormat:@"¥%@", tmpMoneyStr];
            }
            textField.text = [self reserveDecimal:tmpMoneyStr digits:2];
            self.loanModel.jMoney = [[textField.text stringByReplacingOccurrencesOfString:@"¥" withString:@""] doubleValue];
            
            if (_edited) {
                [self updateBalanceChangeMoney];
            } else {
                self.createCompoundModel.chargeModel.money = self.loanModel.jMoney;
                self.createCompoundModel.targetChargeModel.money = self.loanModel.jMoney;
            }
            
            [self updateRemindName];
            [self updateInterest];
            
        } else if (textField.tag == kMemoTag) {
            
            self.loanModel.memo = textField.text;
            
        } else if (textField.tag == kRateTag) {
            
            textField.text = [self reserveDecimal:textField.text digits:1];
            self.loanModel.rate = [textField.text doubleValue] * 0.01;
            [self updateInterest];
            
        }
    }
}

- (void)deleteButtonClicked {
    __weak typeof(self) wself = self;
    [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"删除该项目后相关的账户流水数据(含转账、利息）将被彻底删除哦。" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:NULL], [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction *action) {
        [wself deleteLoanModel];
    }], nil];
}

- (void)sureButtonAction {
    if ([self checkLoanModelIsValid]) {
        
        _sureButton.enabled = NO;
        [_sureButton ssj_showLoadingIndicator];
        
        // 保存流水，包括创建借贷产生的流水，如果是编辑，还要包括余额变更流水
        NSMutableArray *saveChargeModels = [@[self.createCompoundModel] mutableCopy];
        if (_edited) {
            if (self.changeCompoundModel.chargeModel.money > 0) {
                [saveChargeModels addObject:self.changeCompoundModel];
            }
            
            // 编辑可能会更改目标账户、日期，所以要保存所有余额变更流水
            for (SSJLoanCompoundChargeModel *compoundModel in self.chargeModels) {
                if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceIncrease
                    || compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceDecrease) {
                    [saveChargeModels addObject:compoundModel];
                }
            }
        }
        
        [SSJLoanHelper saveLoanModel:self.loanModel chargeModels:saveChargeModels remindModel:_reminderItem success:^{
            
            _sureButton.enabled = YES;
            [_sureButton ssj_hideLoadingIndicator];
            
            if (_enterFromFundTypeList) {
                UIViewController *homeController = [self.navigationController.viewControllers firstObject];
                
                SSJFinancingHomeitem *item = [[SSJFinancingHomeitem alloc] init];
                item.fundingID = self.loanModel.fundID;
                switch (self.loanModel.type) {
                    case SSJLoanTypeLend:
                        item.fundingParent = @"10";
                        item.fundingName = @"借出款";
                        break;
                        
                    case SSJLoanTypeBorrow:
                        item.fundingParent = @"11";
                        item.fundingName = @"欠款";
                        break;
                }
                SSJLoanListViewController *loanListController = [[SSJLoanListViewController alloc] init];
                loanListController.item = item;
                
                [self.navigationController setViewControllers:@[homeController, loanListController] animated:YES];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
            
            if (!_edited && self.loanModel.remindID.length) {
                [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"添加成功，提醒详情请在“更多-提醒”查看" action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
            }
            
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
            
        } failure:^(NSError * _Nonnull error) {
            _sureButton.enabled = YES;
            [_sureButton ssj_hideLoadingIndicator];
            [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
        }];
    }
}

- (void)interestSwitchAction:(UISwitch *)switchCtrl {
    self.loanModel.interest = switchCtrl.on;
    [_tableView beginUpdates];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
    
    if (switchCtrl.on) {
        switch (self.loanModel.type) {
            case SSJLoanTypeLend:
                [MobClick event:@"loan_interest"];
                break;
                
            case SSJLoanTypeBorrow:
                [MobClick event:@"owed_interest"];
                break;
        }
    }
}

- (void)remindSwitchAction:(UISwitch *)switchCtrl {
    if (_reminderItem) {
        _reminderItem.remindState = switchCtrl.on;
    } else {
        [self enterReminderVC];
    }
    
    if (switchCtrl.on) {
        switch (self.loanModel.type) {
            case SSJLoanTypeLend:
                [MobClick event:@"loan_remind"];
                break;
                
            case SSJLoanTypeBorrow:
                [MobClick event:@"owed_remind"];
                break;
        }
    }
}

#pragma mark - Private
- (void)updateTitle {
    switch (self.loanModel.type) {
        case SSJLoanTypeLend:
            self.title = _edited ? @"编辑借出款" : @"添加借出款";
            break;
            
        case SSJLoanTypeBorrow:
            self.title = _edited ? @"编辑欠款" : @"添加欠款";
            break;
    }
}

- (void)updateAppearance {
    [_sureButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
    [_sureButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor alpha:0.5] forState:UIControlStateDisabled];
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}

- (void)loadData {
    [self.view ssj_showLoadingIndicator];
    [SSJLoanHelper queryFundModelListWithSuccess:^(NSArray <SSJLoanFundAccountSelectionViewItem *>*items) {
        
        _tableView.hidden = NO;
        [self.view ssj_hideLoadingIndicator];
        
        if (!_edited) {
            NSString *targetFundId = [items firstObject].ID;
            
            if (!self.loanModel.targetFundID) {
                self.loanModel.targetFundID = targetFundId;
            }
            
            if (!self.createCompoundModel.targetChargeModel.fundId) {
                self.createCompoundModel.targetChargeModel.fundId = targetFundId;
            }
        }
        
        self.fundingSelectionView.items = items;
        for (int i = 0; i < items.count; i ++) {
            SSJLoanFundAccountSelectionViewItem *item = items[i];
            if ([item.ID isEqualToString:self.loanModel.targetFundID]) {
                self.fundingSelectionView.selectedIndex = i;
                break;
            }
        }
        [_tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        _tableView.hidden = NO;
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
}

// 返回计算预期利息需要的流水列表
- (NSArray *)chargeModelsAccordingToEditState {
    if (_edited) {
        NSMutableArray *models = [NSMutableArray arrayWithArray:_chargeModels];
        if (self.changeCompoundModel.chargeModel.money) {
            [models addObject:self.changeCompoundModel];
        }
        return models;
    } else {
        return @[self.createCompoundModel];
    }
}

- (void)updateInterest {
    if (self.loanModel.repaymentDate) {
        double interest = [SSJLoanHelper expectedInterestWithLoanModel:self.loanModel chargeModels:[self chargeModelsAccordingToEditState]];
        NSString *interestStr = [NSString stringWithFormat:@"%.2f", interest];
        NSMutableAttributedString *richText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"T+1计息，预期利息为%@元", interestStr]];
        [richText setAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]} range:[richText.string rangeOfString:interestStr]];
        _interestLab.attributedText = richText;
    } else {
        NSString *interestStr = [NSString stringWithFormat:@"%.2f", [SSJLoanHelper interestWithPrincipal:self.loanModel.jMoney rate:self.loanModel.rate days:1]];
        NSMutableAttributedString *richText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"每天利息为%@元", interestStr]];
        [richText setAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]} range:[richText.string rangeOfString:interestStr]];
        _interestLab.attributedText = richText;
    }
}

- (BOOL)checkLoanModelIsValid {
    switch (self.loanModel.type) {
        case SSJLoanTypeLend:
            if (self.loanModel.lender.length == 0) {
                [CDAutoHideMessageHUD showMessage:@"请输入借款人"];
                return NO;
            }
            
            if (self.loanModel.lender.length > kLenderMaxLength) {
                [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"借款人不能超过%d个字", kLenderMaxLength]];
                return NO;
            }
            
            if (self.loanModel.jMoney <= 0) {
                [CDAutoHideMessageHUD showMessage:@"借出金额必须大于0"];
                return NO;
            }
            
            if (self.loanModel.targetFundID.length == 0) {
                [CDAutoHideMessageHUD showMessage:@"请选择借出账户"];
                return NO;
            }
            
            if (!self.loanModel.borrowDate) {
                [CDAutoHideMessageHUD showMessage:@"请选择借出日期"];
                return NO;
            }
            
            break;
            
        case SSJLoanTypeBorrow:
            if (self.loanModel.lender.length == 0) {
                [CDAutoHideMessageHUD showMessage:@"请输入欠款人"];
                return NO;
            }
            
            if (self.loanModel.lender.length > kLenderMaxLength) {
                [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"欠款人不能超过%d个字", kLenderMaxLength]];
                return NO;
            }
            
            if (self.loanModel.jMoney <= 0) {
                [CDAutoHideMessageHUD showMessage:@"欠款金额必须大于0"];
                return NO;
            }
            
            if (self.loanModel.targetFundID.length == 0) {
                [CDAutoHideMessageHUD showMessage:@"请选择借入账户"];
                return NO;
            }
            
            if (!self.loanModel.borrowDate) {
                [CDAutoHideMessageHUD showMessage:@"请选择欠款日"];
                return NO;
            }
            
            break;
    }
    
    if (self.loanModel.memo.length > kMemoMaxLength) {
        [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"备注不能超过%d个字", kMemoMaxLength]];
        return NO;
    }
    
    if (self.loanModel.interest && self.loanModel.rate <= 0) {
        [CDAutoHideMessageHUD showMessage:@"收益率必须大于0"];
        return NO;
    }
    
    return YES;
}

- (void)enterReminderVC {
    SSJReminderItem *tmpRemindItem = _reminderItem;
    
    if (!tmpRemindItem) {
        NSDate *paymentDate = [self paymentDate];
        
        tmpRemindItem = [[SSJReminderItem alloc] init];
        switch (self.loanModel.type) {
            case SSJLoanTypeLend:
                tmpRemindItem.remindName = [NSString stringWithFormat:@"被%@借%.2f元", self.loanModel.lender, self.loanModel.jMoney];
                break;
                
            case SSJLoanTypeBorrow:
                tmpRemindItem.remindName = [NSString stringWithFormat:@"欠%@钱款%.2f元", self.loanModel.lender, self.loanModel.jMoney];
                break;
        }
        tmpRemindItem.remindCycle = 7;
        tmpRemindItem.remindType = SSJReminderTypeBorrowing;
        tmpRemindItem.remindDate = [NSDate dateWithYear:paymentDate.year month:paymentDate.month day:paymentDate.day hour:20 minute:0 second:0];
        tmpRemindItem.minimumDate = self.loanModel.borrowDate;
        tmpRemindItem.remindState = YES;
        tmpRemindItem.borrowtarget = self.loanModel.lender;
        switch (self.loanModel.type) {
            case SSJLoanTypeLend:
                tmpRemindItem.borrowtOrLend = @"1";
                break;
                
            case SSJLoanTypeBorrow:
                tmpRemindItem.borrowtOrLend = @"0";
                break;
        }
    }
    
    __weak typeof(self) wself = self;
    SSJReminderEditeViewController *reminderVC = [[SSJReminderEditeViewController alloc] init];
    reminderVC.needToSave = NO;
    reminderVC.item = tmpRemindItem;
    reminderVC.addNewReminderAction = ^(SSJReminderItem *item) {
        wself.reminderItem = item;
        wself.loanModel.remindID = item.remindId;
        [wself.tableView reloadData];
    };
    [self.navigationController pushViewController:reminderVC animated:YES];
}

- (void)updateRemindName {
    if (_reminderItem) {
        switch (self.loanModel.type) {
            case SSJLoanTypeLend:
                _reminderItem.remindName = [NSString stringWithFormat:@"被%@借%.2f元", self.loanModel.lender ?: @"", self.loanModel.jMoney];
                break;
                
            case SSJLoanTypeBorrow:
                _reminderItem.remindName = [NSString stringWithFormat:@"欠%@钱款%.2f元", self.loanModel.lender ?: @"", self.loanModel.jMoney];
                break;
        }
    }
}

- (void)deleteLoanModel {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [SSJLoanHelper deleteLoanModel:self.loanModel success:^{
        self.navigationItem.rightBarButtonItem.enabled = YES;
        UIViewController *listVC = [self ssj_previousViewControllerBySubtractingIndex:2];
        if ([listVC isKindOfClass:[SSJLoanListViewController class]]) {
            [self.navigationController popToViewController:listVC animated:YES];
        }
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError * _Nonnull error) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
}

- (NSString *)reserveDecimal:(NSString *)decimal digits:(int)digits {
    NSArray *components = [decimal componentsSeparatedByString:@"."];
    if (components.count >= 2) {
        NSString *integer = [components objectAtIndex:0];
        NSString *digit = [components objectAtIndex:1];
        if (digit.length > digits) {
            digit = [digit substringToIndex:digits];
        }
        return [NSString stringWithFormat:@"%@.%@", integer, digit];
    }
    
    return decimal;
}

- (NSDate *)paymentDate {
    return self.loanModel.repaymentDate ?: [self.loanModel.borrowDate dateByAddingMonths:1];
}

// 更新余额变更流水的金额
- (void)updateBalanceChangeMoney {
    if (self.loanModel.jMoney > self.originalMoney) {
        
        self.changeCompoundModel.chargeModel.money = self.loanModel.jMoney - self.originalMoney;
        self.changeCompoundModel.targetChargeModel.money = self.loanModel.jMoney - self.originalMoney;
        self.changeCompoundModel.chargeModel.chargeType = SSJLoanCompoundChargeTypeBalanceIncrease;
        
        switch (_type) {
            case SSJLoanTypeLend:
                self.changeCompoundModel.chargeModel.billId = @"9";
                self.changeCompoundModel.targetChargeModel.billId = @"10";
                break;
                
            case SSJLoanTypeBorrow:
                self.changeCompoundModel.chargeModel.billId = @"10";
                self.changeCompoundModel.targetChargeModel.billId = @"9";
                break;
        }
        
    } else if (self.loanModel.jMoney < self.originalMoney) {
        
        self.changeCompoundModel.chargeModel.money = self.originalMoney - self.loanModel.jMoney;
        self.changeCompoundModel.targetChargeModel.money = self.originalMoney - self.loanModel.jMoney;
        self.changeCompoundModel.chargeModel.chargeType = SSJLoanCompoundChargeTypeBalanceDecrease;
        
        switch (_type) {
            case SSJLoanTypeLend:
                self.changeCompoundModel.chargeModel.billId = @"10";
                self.changeCompoundModel.targetChargeModel.billId = @"9";
                break;
                
            case SSJLoanTypeBorrow:
                self.changeCompoundModel.chargeModel.billId = @"9";
                self.changeCompoundModel.targetChargeModel.billId = @"10";
                break;
        }
        
    } else {
        self.changeCompoundModel.chargeModel.money = 0;
        self.changeCompoundModel.targetChargeModel.money = 0;
    }
}

// 更新借贷的目标账户id、借贷产生的依赖目标账户流水的账户id
- (void)updateTargetFundId:(NSString *)fundId {
    self.loanModel.targetFundID = fundId;
    self.createCompoundModel.targetChargeModel.fundId = fundId;
    if (self.edited) {
        self.changeCompoundModel.targetChargeModel.fundId = fundId;
        for (SSJLoanCompoundChargeModel *compoundModel in self.chargeModels) {
            if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceIncrease
                || compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceDecrease) {
                compoundModel.targetChargeModel.fundId = fundId;
            }
        }
    }
}

- (NSString *)fundId {
    switch (_type) {
        case SSJLoanTypeLend:
            return [NSString stringWithFormat:@"%@-5", SSJUSERID()];
            break;
            
        case SSJLoanTypeBorrow:
            return [NSString stringWithFormat:@"%@-6", SSJUSERID()];
            break;
    }
}

#pragma mark - Getter
- (SSJLoanModel *)loanModel {
    if (!_loanModel) {
        _loanModel = [[SSJLoanModel alloc] init];
        _loanModel.ID = SSJUUID();
        _loanModel.userID = SSJUSERID();
        _loanModel.borrowDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day];
        _loanModel.repaymentDate = nil;
        _loanModel.interest = NO;
        _loanModel.lender = @"";
        _loanModel.memo = @"";
        _loanModel.operatorType = 0;
        _loanModel.fundID = [self fundId];
        _loanModel.type = self.type;
    }
    return _loanModel;
}

- (SSJLoanCompoundChargeModel *)createCompoundModel {
    if (!_createCompoundModel) {
        if (_edited) {
            for (SSJLoanCompoundChargeModel *compoundModel in _chargeModels) {
                if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeCreate) {
                    _createCompoundModel = compoundModel;
                }
            }
        } else {
            NSString *chargeBillId = nil;
            NSString *targetChargeBillId = nil;
            
            switch (_type) {
                case SSJLoanTypeLend:
                    chargeBillId = @"3";
                    targetChargeBillId = @"4";
                    break;
                    
                case SSJLoanTypeBorrow:
                    chargeBillId = @"4";
                    targetChargeBillId = @"3";
                    break;
            }
            
            NSDate *billDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day];
            
            SSJLoanChargeModel *chargeModel = [[SSJLoanChargeModel alloc] init];
            chargeModel.chargeId = SSJUUID();
            chargeModel.fundId = [self fundId];
            chargeModel.billId = chargeBillId;
            chargeModel.loanId = self.loanModel.ID;
            chargeModel.userId = SSJUSERID();
            chargeModel.billDate = billDate;
            chargeModel.type = _type;
            chargeModel.chargeType = SSJLoanCompoundChargeTypeCreate;
            
            SSJLoanChargeModel *targetChargeModel = [[SSJLoanChargeModel alloc] init];
            targetChargeModel.chargeId = SSJUUID();
            targetChargeModel.billId = targetChargeBillId;
            targetChargeModel.loanId = self.loanModel.ID;
            targetChargeModel.userId = SSJUSERID();
            targetChargeModel.billDate = billDate;
            targetChargeModel.type = _type;
            targetChargeModel.chargeType = SSJLoanCompoundChargeTypeCreate;
            
            _createCompoundModel = [[SSJLoanCompoundChargeModel alloc] init];
            _createCompoundModel.chargeModel = chargeModel;
            _createCompoundModel.targetChargeModel = targetChargeModel;
        }
    }
    return _createCompoundModel;
}

- (SSJLoanCompoundChargeModel *)changeCompoundModel {
    if (!_changeCompoundModel) {
        
        NSDate *billDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day];
        
        SSJLoanChargeModel *chargeModel = [[SSJLoanChargeModel alloc] init];
        chargeModel.chargeId = SSJUUID();
        chargeModel.fundId = [self fundId];
        chargeModel.loanId = self.loanModel.ID;
        chargeModel.userId = SSJUSERID();
        chargeModel.billDate = billDate;
        chargeModel.type = _type;
        
        SSJLoanChargeModel *targetChargeModel = [[SSJLoanChargeModel alloc] init];
        targetChargeModel.chargeId = SSJUUID();
        targetChargeModel.fundId = self.loanModel.targetFundID;
        targetChargeModel.loanId = self.loanModel.ID;
        targetChargeModel.userId = SSJUSERID();
        targetChargeModel.billDate = billDate;
        targetChargeModel.type = _type;
        
        _changeCompoundModel = [[SSJLoanCompoundChargeModel alloc] init];
        _changeCompoundModel.chargeModel = chargeModel;
        _changeCompoundModel.targetChargeModel = targetChargeModel;
    }
    
    return _changeCompoundModel;
}

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
        [_tableView registerClass:[SSJAddOrEditLoanMultiLabelCell class] forCellReuseIdentifier:kAddOrEditLoanMultiLabelCellId];
        _tableView.sectionHeaderHeight = 10;
        _tableView.sectionFooterHeight = 0;
    }
    return _tableView;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 108)];
        _footerView.backgroundColor = [UIColor clearColor];
        [_footerView addSubview:self.sureButton];
    }
    return _footerView;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sureButton setTitle:@"立借条" forState:UIControlStateNormal];
        [_sureButton setTitle:@"" forState:UIControlStateDisabled];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(sureButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _sureButton.frame = CGRectMake(self.footerView.width * 0.1, 30, self.footerView.width * 0.8, 48);
        _sureButton.clipsToBounds = YES;
        _sureButton.layer.cornerRadius = 3;
    }
    return _sureButton;
}

- (SSJLoanFundAccountSelectionView *)fundingSelectionView {
    if (!_fundingSelectionView) {
        __weak typeof(self) weakSelf = self;
        _fundingSelectionView = [[SSJLoanFundAccountSelectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        _fundingSelectionView.shouldSelectAccountAction = ^BOOL(SSJLoanFundAccountSelectionView *view, NSUInteger index) {
            if (index < view.items.count - 1) {
                SSJLoanFundAccountSelectionViewItem *item = [view.items objectAtIndex:index];
                [weakSelf updateTargetFundId:item.ID];
                [weakSelf.tableView reloadData];
                return YES;
            } else if (index == view.items.count - 1) {
                SSJFundingTypeSelectViewController *NewFundingVC = [[SSJFundingTypeSelectViewController alloc]init];
                NewFundingVC.needLoanOrNot = NO;
                NewFundingVC.addNewFundingBlock = ^(SSJBaseItem *item){
                    if ([item isKindOfClass:[SSJFundingItem class]]) {
                        SSJFundingItem *fundItem = (SSJFundingItem *)item;
                        [weakSelf updateTargetFundId:fundItem.fundingID];
                        [weakSelf loadData];
                    } else if ([item isKindOfClass:[SSJCreditCardItem class]]){
                        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
                        [weakSelf updateTargetFundId:cardItem.cardId];
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

- (SSJLoanDateSelectionView *)borrowDateSelectionView {
    if (!_borrowDateSelectionView) {
        __weak typeof(self) wself = self;
        _borrowDateSelectionView = [[SSJLoanDateSelectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        _borrowDateSelectionView.selectDateAction = ^(SSJLoanDateSelectionView *view) {
            
            wself.loanModel.borrowDate = view.selectedDate;
            wself.createCompoundModel.chargeModel.billDate = view.selectedDate;
            wself.createCompoundModel.targetChargeModel.billDate = view.selectedDate;
            if (wself.edited) {
                wself.changeCompoundModel.chargeModel.billDate = view.selectedDate;
                wself.changeCompoundModel.targetChargeModel.billDate = view.selectedDate;
            }
            
            if (wself.reminderItem.remindDate && [view.selectedDate compare:wself.reminderItem.remindDate] == NSOrderedDescending) {
                wself.reminderItem.remindDate = view.selectedDate;
            }
            
            [wself.tableView reloadData];
            
            switch (wself.loanModel.type) {
                case SSJLoanTypeLend:
                    [MobClick event:@"loan_change_borrow_date"];
                    break;
                    
                case SSJLoanTypeBorrow:
                    [MobClick event:@"owed_change_borrow_date"];
                    break;
            }
        };
        _borrowDateSelectionView.shouldSelectDateAction = ^BOOL(SSJLoanDateSelectionView *view, NSDate *date) {
            if ([date compare:wself.loanModel.repaymentDate] == NSOrderedDescending) {
                switch (wself.loanModel.type) {
                    case SSJLoanTypeLend:
                        [CDAutoHideMessageHUD showMessage:@"借款日不能晚于还款日"];
                        break;
                        
                    case SSJLoanTypeBorrow:
                        [CDAutoHideMessageHUD showMessage:@"欠款日不能晚于还款日"];
                        break;
                }
                return NO;
            }
            
            return YES;
        };
    }
    return _borrowDateSelectionView;
}

- (SSJLoanDateSelectionView *)repaymentDateSelectionView {
    if (!_repaymentDateSelectionView) {
        __weak typeof(self) weakSelf = self;
        _repaymentDateSelectionView = [[SSJLoanDateSelectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        _repaymentDateSelectionView.selectDateAction = ^(SSJLoanDateSelectionView *view) {
            if (weakSelf.reminderItem) {
                weakSelf.reminderItem.remindDate = view.selectedDate;
            }
            weakSelf.loanModel.repaymentDate = view.selectedDate;
            [weakSelf.tableView reloadData];
            
            switch (weakSelf.loanModel.type) {
                case SSJLoanTypeLend:
                    [MobClick event:@"loan_change_pay_date"];
                    break;
                    
                case SSJLoanTypeBorrow:
                    [MobClick event:@"owed_change_pay_date"];
                    break;
            }
        };
        _repaymentDateSelectionView.shouldSelectDateAction = ^BOOL(SSJLoanDateSelectionView *view, NSDate *date) {
            if ([date compare:weakSelf.loanModel.borrowDate] == NSOrderedAscending) {
                switch (weakSelf.loanModel.type) {
                    case SSJLoanTypeLend:
                        [CDAutoHideMessageHUD showMessage:@"还款日不能早于借款日"];
                        break;
                        
                    case SSJLoanTypeBorrow:
                        [CDAutoHideMessageHUD showMessage:@"还款日不能早于欠款日"];
                        break;
                }
                return NO;
            }
            return YES;
        };
        
        __weak typeof(_repaymentDateSelectionView) weakDateSelectionView = _repaymentDateSelectionView;
        _repaymentDateSelectionView.leftButtonItem = [SSJLoanDateSelectionButtonItem buttonItemWithTitle:@"清空"
                                                                                                   image:nil
                                                                                                   color:[UIColor ssj_colorWithHex:SSJOverrunRedColorValue]
                                                                                                  action:^{
                                                                                                      weakSelf.reminderItem.remindDate = [weakSelf paymentDate];
                                                                                                      weakSelf.loanModel.repaymentDate = nil;
                                                                                                      [weakSelf.tableView reloadData];
                                                                                                      [weakDateSelectionView dismiss];
        }];
    }
    return _repaymentDateSelectionView;
}

@end
