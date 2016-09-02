//
//  SSJLoanCloseOutViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/8/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanCloseOutViewController.h"
#import "SSJNewFundingViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJAddOrEditLoanLabelCell.h"
#import "SSJAddOrEditLoanTextFieldCell.h"
#import "SSJLoanFundAccountSelectionView.h"
#import "SSJLoanDateSelectionView.h"
#import "SSJLoanHelper.h"

static NSString *const kAddOrEditLoanLabelCellId = @"kAddOrEditLoanLabelCellId";
static NSString *const kAddOrEditLoanTextFieldCellId = @"kAddOrEditLoanTextFieldCellId";

static NSUInteger kMoneyTag = 1001;
static NSUInteger kInterestTag = 1002;

@interface SSJLoanCloseOutViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) UIView *footerView;

// 借贷账户
@property (nonatomic, strong) SSJLoanFundAccountSelectionView *fundingSelectionView;

// 结清日
@property (nonatomic, strong) SSJLoanDateSelectionView *endDateSelectionView;

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
    
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = self.footerView;
    
    [self updateAppearance];
    [self loadData];
    
    NSDate *today = [NSDate date];
    NSDate *endDate = [today isLaterThan:_loanModel.borrowDate] ? today : _loanModel.borrowDate;
    _loanModel.endDate = endDate;
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
        return 1;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:0]] == NSOrderedSame) {
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanTextFieldCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@"loan_money"];
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                cell.textLabel.text = @"借出金额";
                break;
                
            case SSJLoanTypeBorrow:
                cell.textLabel.text = @"欠款金额";
                break;
        }
        
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"¥0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        cell.textField.text = [NSString stringWithFormat:@"¥%.2f", _loanModel.jMoney];
        cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
        cell.textField.clearsOnBeginEditing = YES;
        cell.textField.delegate = self;
        cell.textField.tag = kMoneyTag;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:1 inSection:0]] == NSOrderedSame) {
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanTextFieldCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@"loan_yield"];
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                cell.textLabel.text = @"利息收入";
                break;
                
            case SSJLoanTypeBorrow:
                cell.textLabel.text = @"利息支出";
                break;
        }
        
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"¥0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        cell.textField.text = [NSString stringWithFormat:@"¥%.2f", [self caculateInterest]];
        cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
        cell.textField.clearsOnBeginEditing = YES;
        cell.textField.delegate = self;
        cell.textField.tag = kInterestTag;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:1]] == NSOrderedSame) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@"loan_account"];
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                cell.textLabel.text = @"转入账户";
                break;
                
            case SSJLoanTypeBorrow:
                cell.textLabel.text = @"转出账户";
                break;
        }
        
        SSJLoanFundAccountSelectionViewItem *selectedFundItem = [self.fundingSelectionView.items ssj_safeObjectAtIndex:_fundingSelectionView.selectedIndex];
        cell.additionalIcon.image = [UIImage imageNamed:selectedFundItem.image];
        cell.subtitleLabel.text = selectedFundItem.title;
        cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.switchControl.hidden = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        [cell setNeedsLayout];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:2]] == NSOrderedSame) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@"loan_expires"];
        cell.textLabel.text = @"结清日";
        cell.additionalIcon.image = nil;
        cell.subtitleLabel.text = [_loanModel.endDate formattedDateWithFormat:@"yyyy.MM.dd"];
        cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.switchControl.hidden = YES;
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
    
    if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:1]] == NSOrderedSame) {
        [self.view endEditing:YES];
        [self.fundingSelectionView show];
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:2]] == NSOrderedSame) {
        [self.view endEditing:YES];
        [self.endDateSelectionView show];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField.tag == kMoneyTag) {
        NSString *money = [textField.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
        if ([money doubleValue] <= 0) {
            switch (_loanModel.type) {
                case SSJLoanTypeLend:
                    [CDAutoHideMessageHUD showMessage:@"借出金额必须大于0元"];
                    break;
                    
                case SSJLoanTypeBorrow:
                    [CDAutoHideMessageHUD showMessage:@"欠款金额必须大于0元"];
                    break;
            }
            return NO;
        }
        
    } else if (textField.tag == kInterestTag) {
        NSString *interest = [textField.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
        if ([interest doubleValue] < 0) {
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
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == kMoneyTag || textField.tag == kInterestTag) {
        NSString *money = [textField.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
        textField.text = [NSString stringWithFormat:@"¥%.2f", [money doubleValue]];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL shouldChange = YES;
    
    NSString *newStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newStr.length) {
        textField.text = [self formatMoneyString:newStr];
        shouldChange =  NO;
    }
    
    double money = [[newStr stringByReplacingOccurrencesOfString:@"¥" withString:@""] doubleValue];
    
    if (textField.tag == kMoneyTag) {
        _loanModel.jMoney = money;
    } else if (textField.tag == kInterestTag) {
        [self recaculateRateWithInterest:money];
    }
    
    return shouldChange;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField.tag == kMoneyTag) {
        _loanModel.jMoney = 0;
    } else if (textField.tag == kInterestTag) {
        _loanModel.rate = 0;
    }
    
    return YES;
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
        
        [self.view ssj_hideLoadingIndicator];
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
        
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
}

- (double)caculateInterest {
    NSInteger daysFromBorrow = [_loanModel.endDate daysFrom:_loanModel.borrowDate];
    if (daysFromBorrow >= 0) {
        return (daysFromBorrow + 1) * _loanModel.rate / 365;
    } else {
        return 0;
    }
}

- (void)recaculateRateWithInterest:(double)interest {
    NSInteger daysFromBorrow = [_loanModel.endDate daysFrom:_loanModel.borrowDate];
    if (daysFromBorrow >= 0) {
        _loanModel.rate = interest / (daysFromBorrow + 1) * 365;
    }
}

- (NSString *)formatMoneyString:(NSString *)money {
    money = [money stringByReplacingOccurrencesOfString:@"¥" withString:@""];
    if (money.length) {
        money = [NSString stringWithFormat:@"¥%@", money];
    }
    
    NSArray *components = [money componentsSeparatedByString:@"."];
    if (components.count >= 2) {
        NSString *integer = [components objectAtIndex:0];
        NSString *digit = [components objectAtIndex:1];
        if (digit.length > 2) {
            digit = [digit substringToIndex:2];
        }
        money = [NSString stringWithFormat:@"%@.%@", integer, digit];
    }
    return money;
}

#pragma mark - Event
- (void)sureButtonAction {
    if (_loanModel.jMoney <= 0) {
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                [CDAutoHideMessageHUD showMessage:@"借出金额必须大于0元"];
                break;
                
            case SSJLoanTypeBorrow:
                [CDAutoHideMessageHUD showMessage:@"欠款金额必须大于0元"];
                break;
        }
        
        return;
    }
    
    if (!_loanModel.targetFundID.length) {
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                [CDAutoHideMessageHUD showMessage:@"请选择转入账户"];
                break;
                
            case SSJLoanTypeBorrow:
                [CDAutoHideMessageHUD showMessage:@"请选择转转出账户"];
                break;
        }
        return;
    }
    
    if (!_loanModel.endDate) {
        [CDAutoHideMessageHUD showMessage:@"请选择结清日期"];
        return;
    }
    
    if ([_loanModel.endDate compare:_loanModel.borrowDate] == NSOrderedAscending) {
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                [CDAutoHideMessageHUD showMessage:@"结清日不能早于借出日期"];
                break;
                
            case SSJLoanTypeBorrow:
                [CDAutoHideMessageHUD showMessage:@"结清日不能早于借入日期"];
                break;
        }
        return;
    }
    
    self.sureButton.enabled = NO;
    [SSJLoanHelper closeOutLoanModel:_loanModel success:^{
        self.sureButton.enabled = YES;
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError * _Nonnull error) {
        self.sureButton.enabled = YES;
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
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

- (SSJLoanDateSelectionView *)endDateSelectionView {
    if (!_endDateSelectionView) {
        __weak typeof(self) weakSelf = self;
        _endDateSelectionView = [[SSJLoanDateSelectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        _endDateSelectionView.selectedDate = _loanModel.endDate;
        _endDateSelectionView.selectDateAction = ^(SSJLoanDateSelectionView *view) {
            weakSelf.loanModel.endDate = view.selectedDate;
            [weakSelf.tableView reloadData];
        };
        _endDateSelectionView.shouldSelectDateAction = ^BOOL(SSJLoanDateSelectionView *view, NSDate *date) {
            if ([date compare:weakSelf.loanModel.borrowDate] == NSOrderedAscending) {
                switch (weakSelf.loanModel.type) {
                    case SSJLoanTypeLend:
                        [CDAutoHideMessageHUD showMessage:@"结清日不能早于借出日期"];
                        break;
                        
                    case SSJLoanTypeBorrow:
                        [CDAutoHideMessageHUD showMessage:@"结清日不能早于借入日期"];
                        break;
                }
                return NO;
            }
            return YES;
        };
    }
    return _endDateSelectionView;
}

@end
