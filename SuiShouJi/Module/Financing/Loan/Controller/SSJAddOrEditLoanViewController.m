//
//  SSJAddOrEditLoanViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/8/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJAddOrEditLoanViewController.h"
#import "SSJNewFundingViewController.h"
#import "SSJAddOrEditLoanLabelCell.h"
#import "SSJAddOrEditLoanTextFieldCell.h"
#import "SSJAddOrEditLoanMultiLabelCell.h"
#import "SSJLoanFundAccountSelectionView.h"
#import "SSJChargeCircleTimeSelectView.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJLoanHelper.h"
#import "SSJLocalNotificationStore.h"

static NSString *const kAddOrEditLoanLabelCellId = @"SSJAddOrEditLoanLabelCell";
static NSString *const kAddOrEditLoanTextFieldCellId = @"SSJAddOrEditLoanTextFieldCell";
static NSString *const kAddOrEditLoanMultiLabelCellId = @"SSJAddOrEditLoanMultiLabelCell";

const NSInteger kLenderTag = 1001;
const NSInteger kMoneyTag = 1002;
const NSInteger kMemoTag = 1003;
const NSInteger kRateTag = 1004;

@interface SSJAddOrEditLoanViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) UIButton *sureButton;

// 借贷账户
@property (nonatomic, strong) SSJLoanFundAccountSelectionView *fundingSelectionView;

// 借贷日
@property (nonatomic, strong) SSJChargeCircleTimeSelectView *borrowDateSelectionView;

// 期限日
@property (nonatomic, strong) SSJChargeCircleTimeSelectView *repaymentDateSelectionView;

@property (nonatomic, strong) SSJReminderItem *reminderItem;

@property (nonatomic, strong) UITextField *lenderField;

@end

@implementation SSJAddOrEditLoanViewController

#pragma mark - Lifecycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_loanModel.ID.length) {
        self.title = @"编辑借出款";
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonClicked)];
        self.navigationItem.rightBarButtonItem = rightItem;
    } else {
        self.title = @"新建借出款";
    }
    
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 3;
    } else if (section == 2) {
        return _loanModel.interest ? 2 : 1;
    } else if (section == 3) {
        return 1;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:0]] == NSOrderedSame) {
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanTextFieldCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                cell.textLabel.text = @"被谁借款";
                break;
                
            case SSJLoanTypeBorrow:
                cell.textLabel.text = @"欠谁钱款";
                break;
        }
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"必填" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        cell.textField.text = _loanModel.lender;
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.textField.tag = kLenderTag;
        [cell setNeedsLayout];
        
        _lenderField = cell.textField;
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:1 inSection:0]] == NSOrderedSame) {
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanTextFieldCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                cell.textLabel.text = @"借出金额";
                break;
                
            case SSJLoanTypeBorrow:
                cell.textLabel.text = @"欠款金额";
                break;
        }
        
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"¥0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        cell.textField.text = [NSString stringWithFormat:@"%.2f", [_loanModel.jMoney doubleValue]];
        cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
        cell.textField.tag = kMoneyTag;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:2 inSection:0]] == NSOrderedSame) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        switch (_loanModel.type) {
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
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:1]] == NSOrderedSame) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                cell.textLabel.text = @"借出日期";
                break;
                
            case SSJLoanTypeBorrow:
                cell.textLabel.text = @"借入日期";
                break;
        }
        
        cell.additionalIcon.image = nil;
        cell.subtitleLabel.text = [_loanModel.borrowDate ssj_dateStringFromFormat:@"yyyy-MM-dd" toFormat:@"yyyy.MM.dd"];
        cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.switchControl.hidden = YES;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:1 inSection:1]] == NSOrderedSame) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                cell.textLabel.text = @"借款期限日";
                break;
                
            case SSJLoanTypeBorrow:
                cell.textLabel.text = @"还款期限日";
                break;
        }
        
        cell.additionalIcon.image = nil;
        cell.subtitleLabel.text = [_loanModel.repaymentDate ssj_dateStringFromFormat:@"yyyy-MM-dd" toFormat:@"yyyy.MM.dd"];
        cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.switchControl.hidden = YES;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:2 inSection:1]] == NSOrderedSame) {
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanTextFieldCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        cell.textLabel.text = @"备注";
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"选填" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        cell.textField.text = _loanModel.memo;
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.textField.tag = kMemoTag;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:2]] == NSOrderedSame) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        cell.textLabel.text = @"计息";
        cell.additionalIcon.image = nil;
        cell.subtitleLabel.text = nil;
        cell.switchControl.hidden = NO;
        [cell.switchControl setOn:_loanModel.interest animated:YES];
        [cell.switchControl addTarget:self action:@selector(interestSwitchAction:) forControlEvents:UIControlEventValueChanged];
        cell.customAccessoryType = UITableViewCellAccessoryNone;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:1 inSection:2]] == NSOrderedSame) {
        SSJAddOrEditLoanMultiLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanMultiLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        cell.textLabel.text = @"年收益率";
        
        NSString *interestStr = [NSString stringWithFormat:@"%.2f", [self caculateInterest]];
        NSMutableAttributedString *richText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"预期利息为%@元", interestStr]];
        [richText setAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]} range:[richText.string rangeOfString:interestStr]];
        cell.subtitleLabel.attributedText = richText;
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"0.0%" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        if (_loanModel.rate) {
            cell.textField.text = [NSString stringWithFormat:@"%@", _loanModel.rate];
        }
        cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
        cell.textField.tag = kRateTag;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:3]] == NSOrderedSame) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        cell.textLabel.text = @"到期日提醒";
        cell.subtitleLabel.text = [_reminderItem.remindDate formattedDateWithFormat:@"yyyy.MM.dd"];
        cell.additionalIcon.image = nil;
        cell.customAccessoryType = UITableViewCellAccessoryNone;
        cell.switchControl.hidden = NO;
        cell.switchControl.on = _reminderItem.remindState;
        [cell.switchControl addTarget:self action:@selector(remindSwitchAction:) forControlEvents:UIControlEventValueChanged];
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
        [self.borrowDateSelectionView show];
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:1 inSection:1]] == NSOrderedSame) {
        [self.view endEditing:YES];
        [self.repaymentDateSelectionView show];
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:2]] == NSOrderedSame) {
        if (_reminderItem) {
#warning 跳转编辑提醒页面
        }
    }
}

#pragma mark - Event
- (void)deleteButtonClicked {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [SSJLoanHelper deleteLoanModel:_loanModel success:^{
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError * _Nonnull error) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [CDAutoHideMessageHUD showMessage:[error localizedDescription]];
    }];
}

- (void)sureButtonAction {
    _sureButton.enabled = NO;
    [_sureButton ssj_showLoadingIndicator];
    [SSJLoanHelper saveLoanModel:_loanModel remindModel:_reminderItem success:^{
        _sureButton.enabled = YES;
        [_sureButton ssj_hideLoadingIndicator];
    } failure:^(NSError * _Nonnull error) {
        _sureButton.enabled = YES;
        [_sureButton ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:[error localizedDescription]];
    }];
}

- (void)interestSwitchAction:(UISwitch *)switchCtrl {
    _loanModel.interest = switchCtrl.on;
    [_tableView beginUpdates];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
}

- (void)remindSwitchAction:(UISwitch *)switchCtrl {
    if (_reminderItem) {
        _reminderItem.remindState = switchCtrl.on;
    } else {
#warning 跳转设置提醒页面
    }
}

- (void)textDidChange {
    if ([_lenderField isFirstResponder]) {
        NSLog(@"%@", _lenderField.text);
    }
}

#pragma mark - Private
- (void)updateAppearance {
    [_sureButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
    [_sureButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor alpha:0.5] forState:UIControlStateDisabled];
    
    CGFloat alpha = [[SSJThemeSetting currentThemeModel].ID isEqualToString:SSJDefaultThemeID] ? 0 : 0.1;
    _tableView.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:alpha];
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}

- (void)loadData {
    [self.view ssj_showLoadingIndicator];
    [SSJLoanHelper queryFundModelListWithSuccess:^(NSArray <SSJLoanFundAccountSelectionViewItem *>*items) {
        
        if (_loanModel.remindID.length) {
            _reminderItem = [SSJLocalNotificationStore queryReminderItemForID:_loanModel.remindID];
        }
        
        _tableView.hidden = NO;
        [self.view ssj_hideLoadingIndicator];
        
        if (!_loanModel.ID.length) {
            _loanModel.ID = SSJUUID();
            _loanModel.userID = SSJUSERID();
            _loanModel.chargeID = SSJUUID();
            _loanModel.targetChargeID = SSJUUID();
            _loanModel.targetFundID = [items firstObject].ID;
            _loanModel.remindID = _reminderItem.remindId;
            _loanModel.borrowDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"];
            _loanModel.repaymentDate = [[[NSDate date] dateByAddingMonths:1] formattedDateWithFormat:@"yyyy-MM-dd"];
            _loanModel.rate = @"0";
            _loanModel.interest = YES;
            _loanModel.operatorType = 0;
        }
        
        self.fundingSelectionView.items = items;
        for (int i = 0; i < items.count; i ++) {
            SSJLoanFundAccountSelectionViewItem *item = items[i];
            if ([item.ID isEqualToString:_loanModel.targetFundID]) {
                self.fundingSelectionView.selectedIndex = i;
                break;
            }
        }
        [_tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        _tableView.hidden = NO;
        [self.view ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:[error localizedDescription]];
    }];
}

- (float)caculateInterest {
    NSDate *borrowDate = [NSDate dateWithString:_loanModel.borrowDate formatString:@"yyyy-MM-dd"];
    NSDate *repaymentDate = [NSDate dateWithString:_loanModel.repaymentDate formatString:@"yyyy-MM-dd"];
    if (borrowDate && repaymentDate) {
        NSUInteger interval = [repaymentDate daysFrom:borrowDate] + 1;
        return interval * ([_loanModel.rate floatValue] / 365);
    }
    
    return 0;
}

#pragma mark - Getter
- (TPKeyboardAvoidingTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
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
        _sureButton.frame = CGRectMake((self.footerView.width - 296) * 0.5, 30, 296, 48);
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
                weakSelf.loanModel.targetFundID = item.ID;
                [weakSelf.tableView reloadData];
                return YES;
            } else if (index == view.items.count - 1) {
                SSJNewFundingViewController *newFundingVC = [[SSJNewFundingViewController alloc] init];
                newFundingVC.finishBlock = ^(SSJFundingItem *newFundingItem) {
                    weakSelf.loanModel.targetFundID = newFundingItem.fundingID;
                    [weakSelf loadData];
                };
                [weakSelf.navigationController pushViewController:newFundingVC animated:YES];
                return NO;
            } else {
                SSJPRINT(@"警告：selectedIndex大于数组范围");
                return NO;
            }
        };
    }
    return _fundingSelectionView;
}

- (SSJChargeCircleTimeSelectView *)borrowDateSelectionView {
    if (!_borrowDateSelectionView) {
        __weak typeof(self) weakSelf = self;
        _borrowDateSelectionView = [[SSJChargeCircleTimeSelectView alloc] initWithFrame:self.view.bounds];
        _borrowDateSelectionView.currentDate = [NSDate dateWithString:_loanModel.borrowDate formatString:@"yyyy-MM-dd"];
        _borrowDateSelectionView.timerSetBlock = ^(NSString *dateStr) {
            weakSelf.loanModel.borrowDate = dateStr;
            [weakSelf.tableView reloadData];
        };
    }
    return _borrowDateSelectionView;
}

- (SSJChargeCircleTimeSelectView *)repaymentDateSelectionView {
    if (!_repaymentDateSelectionView) {
        __weak typeof(self) weakSelf = self;
        _repaymentDateSelectionView = [[SSJChargeCircleTimeSelectView alloc] initWithFrame:self.view.bounds];
        _repaymentDateSelectionView.currentDate = [NSDate dateWithString:_loanModel.repaymentDate formatString:@"yyyy-MM-dd"];
        _repaymentDateSelectionView.timerSetBlock = ^(NSString *dateStr) {
            weakSelf.loanModel.repaymentDate = dateStr;
            [weakSelf.tableView reloadData];
        };
    }
    return _repaymentDateSelectionView;
}

@end
