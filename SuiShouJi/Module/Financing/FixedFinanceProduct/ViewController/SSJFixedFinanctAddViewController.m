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
#import "SSJLoanHelper.h"
#import "SSJDataSynchronizer.h"

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

//@property (nonatomic, strong) SSJFixedFinanceProductChargeItem *chargeModel;

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
    [self initCompoundModel];
    [self updateAppearance];
}

- (void)loadData {
    MJWeakSelf;
    [SSJFixedFinanceProductStore queryForFixedFinanceProduceWithProductID:self.productid success:^(SSJFixedFinanceProductItem * _Nonnull model) {
        weakSelf.financeModel = model;
    } failure:^(NSError * _Nonnull error) {
         [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
    
    //查询转出账户列表
    [SSJLoanHelper queryFundModelListWithSuccess:^(NSArray <SSJLoanFundAccountSelectionViewItem *>*items) {
        weakSelf.tableView.hidden = NO;
        [weakSelf.view ssj_hideLoadingIndicator];
        
        // 新建借贷设置默认账户
        weakSelf.fundingSelectionView.items = items;
        weakSelf.fundingSelectionView.selectedIndex = -1;
//        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        _tableView.hidden = NO;
        [weakSelf.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];

}

#pragma mark - Theme
- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    [_sureButton ssj_setBackgroundColor:SSJ_BUTTON_NORMAL_COLOR forState:UIControlStateNormal];
    [_sureButton ssj_setBackgroundColor:SSJ_BUTTON_DISABLE_COLOR forState:UIControlStateDisabled];
    _tableView.separatorColor = SSJ_CELL_SEPARATOR_COLOR;
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    UITextField *field = [self.view viewWithTag:kMoneyTag];
    if (field == textField) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = [text ssj_reserveDecimalDigits:2 intDigits:9];
        return NO;
    }
    return YES;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellTags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger tag = [[self.cellTags ssj_safeObjectAtIndex:indexPath.row] unsignedIntegerValue];
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
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"最多可输入10个字符" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
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
        cell.subtitleLabel.text = [self.compoundModel.chargeModel.billDate formattedDateWithFormat:@"yyyy-MM-dd"];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger tag = [[self.cellTags ssj_safeObjectAtIndex:indexPath.row] unsignedIntegerValue];
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
    _cellTags = @[@(kMoneyTag),@(kAccountTag),@(kDateTag),@(kMemoTag)];
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

- (BOOL)checkIfNeedClick {
    UITextField *moneyF = [self.view viewWithTag:kMoneyTag];
    UITextField *memoF = [self.view viewWithTag:kMemoTag];
    if (moneyF.text.length <=0 && [moneyF.text doubleValue] <=0) {
        [CDAutoHideMessageHUD showMessage:@"请输入追购金额"];
        return NO;
    }
    if (self.fundingSelectionView.selectedIndex == -1) {
        [CDAutoHideMessageHUD showMessage:@"请选择转出账户"];
        return NO;
    }
    if (self.fundingSelectionView.selectedIndex == -1) {
        [CDAutoHideMessageHUD showMessage:@"请选择转出账户"];
        return NO;
    }
    if (!self.compoundModel.chargeModel.billDate) {
        [CDAutoHideMessageHUD showMessage:@"请选择追购日期"];
        return NO;
    }
    
    self.compoundModel.chargeModel.money = [moneyF.text doubleValue];
    self.compoundModel.chargeModel.memo = memoF.text.length ? memoF.text : @"";
    self.compoundModel.chargeModel.fundId = self.financeModel.thisfundid;
    
    self.compoundModel.targetChargeModel.money = [moneyF.text doubleValue];
    self.compoundModel.targetChargeModel.memo = memoF.text.length ? memoF.text : @"";
    return YES;
}

#pragma mark - Action
- (void)sureButtonAction {
    if (![self checkIfNeedClick]) return;
    MJWeakSelf;
    //保存流水
    NSMutableArray *saveChargeModels = [@[self.compoundModel] mutableCopy];
    [SSJFixedFinanceProductStore addOrRedemptionInvestmentWithProductModel:self.financeModel   type:1 chargeModels:saveChargeModels success:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
    
}

#pragma mark - Lazy
- (TPKeyboardAvoidingTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_tableView registerClass:[SSJAddOrEditLoanLabelCell class] forCellReuseIdentifier:kAddOrEditFinanceLabelCellId];
        [_tableView registerClass:[SSJAddOrEditLoanTextFieldCell class] forCellReuseIdentifier:kAddOrEditFinanceTextFieldCellId];
        _tableView.sectionFooterHeight = 0;
        _tableView.tableFooterView = self.footerView;
    }
    return _tableView;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sureButton setTitle:@"结算" forState:UIControlStateNormal];
        [_sureButton setTitle:@"" forState:UIControlStateDisabled];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(sureButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _sureButton.frame = CGRectMake(15 , 30, self.view.width - 30, 44);
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
                weakSelf.fundingSelectionView.selectedIndex = index;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                return YES;
            } else if (index == view.items.count - 1) {
                SSJFundingTypeSelectViewController *NewFundingVC = [[SSJFundingTypeSelectViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
                NewFundingVC.needLoanOrNot = NO;
                NewFundingVC.addNewFundingBlock = ^(SSJBaseCellItem *item){
                    
                    if ([item isKindOfClass:[SSJFundingItem class]]) {
                        SSJFundingItem *fundItem = (SSJFundingItem *)item;
                        weakSelf.compoundModel.targetChargeModel.fundId = fundItem.fundingID;
//                        weakSelf.compoundModel.interestChargeModel.fundId = fundItem.fundingID;
                    } else if (0){
                        //[item isKindOfClass:[SSJCreditCardItem class]]
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
//        _dateSelectionView.shouldConfirmBlock = ^BOOL(SSJHomeDatePickerView *view, NSDate *date) {
//            if ([date compare:weakSelf.financeModel.startDate] == NSOrderedAscending) {
               //                return NO;
//            }
//            return YES;
//        };
        _dateSelectionView.confirmBlock = ^(SSJHomeDatePickerView *view) {
            weakSelf.compoundModel.chargeModel.billDate = view.date;
            weakSelf.compoundModel.targetChargeModel.billDate = view.date;
//            weakSelf.compoundModel.interestChargeModel.billDate = view.date;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        };
    }
    return _dateSelectionView;
}

- (void)initCompoundModel {
    if (!_compoundModel) {
        NSString *chargeBillId = nil;
        NSString *targetChargeBillId = nil;
        
        chargeBillId = @"15";
        targetChargeBillId = @"16";
        NSDate *today = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day];
        NSDate *billDate = [today compare:self.financeModel.startDate] == NSOrderedAscending ? self.financeModel.startDate : today;

        SSJFixedFinanceProductChargeItem *chargeModel = [[SSJFixedFinanceProductChargeItem alloc] init];
        chargeModel.chargeId = SSJUUID();
        chargeModel.billId = chargeBillId;
        chargeModel.userId = SSJUSERID();
        chargeModel.billDate = billDate;
        chargeModel.cid = [NSString stringWithFormat:@"%@_%ld",self.productid,[SSJFixedFinanceProductStore queryMaxChargeChargeIdSuffixWithProductId:self.productid]];
        chargeModel.chargeType = SSJLoanCompoundChargeTypeAdd;
        
        SSJFixedFinanceProductChargeItem *targetChargeModel = [[SSJFixedFinanceProductChargeItem alloc] init];
        targetChargeModel.chargeId = SSJUUID();
        targetChargeModel.billId = targetChargeBillId;
        targetChargeModel.userId = SSJUSERID();
        targetChargeModel.billDate = billDate;
        targetChargeModel.cid = chargeModel.cid;
        targetChargeModel.chargeType = SSJLoanCompoundChargeTypeRepayment;
        
        _compoundModel = [[SSJFixedFinanceProductCompoundItem alloc] init];
        _compoundModel.chargeModel = chargeModel;
        _compoundModel.targetChargeModel = targetChargeModel;
        
    }
}


@end
