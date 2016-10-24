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
    
    NSDate *today = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day];
    NSDate *endDate = [today isLaterThan:_loanModel.borrowDate] ? today : _loanModel.borrowDate;
    _loanModel.endDate = endDate;
    
    [self organiseTitles];
    [self organiseImages];
    [self organiseCellTags];
    
    [self loadData];
    
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = self.footerView;
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
            SSJAddOrEditLoanTextFieldCell *moneyCell = (SSJAddOrEditLoanTextFieldCell *)cell;
            moneyCell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"¥0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
            moneyCell.textField.text = [NSString stringWithFormat:@"¥%.2f", _loanModel.jMoney];
            moneyCell.textField.keyboardType = UIKeyboardTypeDecimalPad;
            moneyCell.textField.clearsOnBeginEditing = YES;
            moneyCell.textField.delegate = self;
            moneyCell.textField.tag = kMoneyTag;
            
        } else if (tag == kInterestTag) {
            SSJAddOrEditLoanTextFieldCell *interestCell = (SSJAddOrEditLoanTextFieldCell *)cell;
            interestCell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"¥0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
            interestCell.textField.text = [NSString stringWithFormat:@"¥%.2f", [SSJLoanHelper closeOutInterestWithLoanModel:_loanModel]];
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
    
    if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:1]] == NSOrderedSame) {
        [self.view endEditing:YES];
        [self.fundingSelectionView show];
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:2]] == NSOrderedSame) {
        [self.view endEditing:YES];
        self.endDateSelectionView.selectedDate = self.loanModel.endDate;
        [self.endDateSelectionView show];
    }
}

#pragma mark - UITextFieldDelegate
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
//    if (textField.tag == kMoneyTag) {
//        NSString *money = [textField.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
//        if ([money doubleValue] <= 0) {
//            switch (_loanModel.type) {
//                case SSJLoanTypeLend:
//                    [CDAutoHideMessageHUD showMessage:@"借出金额必须大于0元"];
//                    break;
//                    
//                case SSJLoanTypeBorrow:
//                    [CDAutoHideMessageHUD showMessage:@"欠款金额必须大于0元"];
//                    break;
//            }
//            return NO;
//        }
//        
//    } else if (textField.tag == kInterestTag) {
//        NSString *interest = [textField.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
//        if ([interest doubleValue] < 0) {
//            switch (_loanModel.type) {
//                case SSJLoanTypeLend:
//                    [CDAutoHideMessageHUD showMessage:@"利息收入不能小于0元"];
//                    break;
//                    
//                case SSJLoanTypeBorrow:
//                    [CDAutoHideMessageHUD showMessage:@"利息支出不能小于0元"];
//                    break;
//            }
//            return NO;
//        }
//    }
//    
//    return YES;
//}

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
        shouldChange = NO;
    }
    
    double money = [[newStr stringByReplacingOccurrencesOfString:@"¥" withString:@""] doubleValue];
    
    if (textField.tag == kMoneyTag) {
        _loanModel.jMoney = money;
        if ([_tableView numberOfRowsInSection:0] > 1) {
            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    } else if (textField.tag == kInterestTag) {
        [self recaculateRateWithInterest:money];
    }
    
    return shouldChange;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField.tag == kMoneyTag) {
        _loanModel.jMoney = 0;
        if ([_tableView numberOfRowsInSection:0] > 1) {
            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    } else if (textField.tag == kInterestTag) {
        _loanModel.rate = 0;
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
        
        [self.view ssj_hideLoadingIndicator];
        self.fundingSelectionView.items = items;
        for (int i = 0; i < items.count; i ++) {
            SSJLoanFundAccountSelectionViewItem *item = items[i];
            if ([item.ID isEqualToString:_loanModel.endTargetFundID]) {
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

- (void)recaculateRateWithInterest:(double)interest {
    if (_loanModel.jMoney > 0) {
        NSInteger daysFromBorrow = [_loanModel.endDate daysFrom:_loanModel.borrowDate];
        if (daysFromBorrow >= 0) {
            _loanModel.rate = interest / _loanModel.jMoney / daysFromBorrow * 365;
        }
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
    if (tag == kMoneyTag || tag == kInterestTag) {
        return kAddOrEditLoanTextFieldCellId;
    } else if (tag == kFundAccountTag || tag == kClostOutDateTag) {
        return kAddOrEditLoanLabelCellId;
    } else {
        return nil;
    }
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
    
    if (_loanModel.rate < 0) {
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                [CDAutoHideMessageHUD showMessage:@"利息收入不能小于0元"];
                break;
                
            case SSJLoanTypeBorrow:
                [CDAutoHideMessageHUD showMessage:@"利息支出不能小于0元"];
                break;
        }
        
        return;
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
                [weakSelf.tableView reloadData];
                return YES;
            } else if (index == view.items.count - 1) {
                SSJFundingTypeSelectViewController *NewFundingVC = [[SSJFundingTypeSelectViewController alloc]init];
                NewFundingVC.needLoanOrNot = NO;
                NewFundingVC.addNewFundingBlock = ^(SSJBaseItem *item){
                    if ([item isKindOfClass:[SSJFundingItem class]]) {
                        SSJFundingItem *fundItem = (SSJFundingItem *)item;
                        weakSelf.loanModel.targetFundID = fundItem.fundingID;
                        [weakSelf loadData];
                    } else if ([item isKindOfClass:[SSJCreditCardItem class]]){
                        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
                        weakSelf.loanModel.targetFundID = cardItem.cardId;
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
            [weakSelf organiseTitles];
            [weakSelf organiseImages];
            [weakSelf organiseCellTags];
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
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
