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
#import "SSJFixedFinanceProductChargeItem.h"
#import "SSJLoanFundAccountSelectionViewItem.h"

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

@property (nonatomic, strong) SSJFixedFinanceProductCompoundItem *compoundModel;

//@property (nonatomic, strong) SSJFixedFinanceProductChargeItem *chargeModel;

@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) NSArray *cellTags;

@property (nonatomic, strong) SSJFixedFinanceProductChargeItem *otherChareItem;

/**编辑的时候输入框的金额*/
@property (nonatomic, assign) double oldMoney;

/**m*/
@property (nonatomic, copy) NSString *moneyStr;

/**<#注释#>*/
@property (nonatomic, copy) NSString *memoStr;
@end

@implementation SSJFixedFinanctAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self organiseCellTags];
    [self.view addSubview:self.tableView];
    [self loadData];
    [self setUpNav];
    [self updateUI];
    if (!self.chargeItem) {
        [self initCompoundModel];
    }
    self.oldMoney = self.chargeItem.money;
    self.memoStr = [NSString stringWithFormat:@"%.2f",self.chargeItem.money];
    self.memoStr = self.chargeItem.memo;
    [self updateAppearance];
}

- (void)loadData {
    MJWeakSelf;
    if (self.chargeItem) {
        //查询当前charid对应的另外一跳流水
        //通过另一条流水的fundid查找名称
        [SSJFixedFinanceProductStore queryOtherFixedFinanceProductChargeItemWithChareItem:self.chargeItem success:^(NSArray<SSJFixedFinanceProductChargeItem *> * _Nonnull charegItemArr) {
            for (SSJFixedFinanceProductChargeItem *chargeItem in charegItemArr) {
                if (![chargeItem.billId isEqualToString:weakSelf.chargeItem.billId]) {
                    weakSelf.otherChareItem = chargeItem;
                }
            }
            
            NSString *fundid;
            if (self.isEnterFromFinance == YES) {
                fundid = self.otherChareItem.fundId;
            } else {
                fundid = self.chargeItem.fundId;
            }
            SSJLoanFundAccountSelectionViewItem *funditem = [SSJFixedFinanceProductStore queryfundNameWithFundid:fundid];
            [self initEditCompoundModel];
            [weakSelf funditem:funditem];
            
        } failure:^(NSError * _Nonnull error) {
            [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
        }];
    } else {
        
        [self funditem:nil];
    }
}

- (void)funditem:(SSJLoanFundAccountSelectionViewItem *)funditem {
    MJWeakSelf;
    
    //查询转出账户列表
    [SSJLoanHelper queryFundModelListWithSuccess:^(NSArray <SSJLoanFundAccountSelectionViewItem *>*items) {
        weakSelf.tableView.hidden = NO;
        [weakSelf.view ssj_hideLoadingIndicator];
        
        // 新建借贷设置默认账户
        weakSelf.fundingSelectionView.items = items;
        if (!funditem) {
            weakSelf.fundingSelectionView.selectedIndex = -1;
        }else {
            for (NSInteger i=0; i<items.count; i++) {
                SSJLoanFundAccountSelectionViewItem *fund = [items ssj_safeObjectAtIndex:i];
                if ([fund.ID isEqualToString:funditem.ID]) {
                    weakSelf.fundingSelectionView.selectedIndex = i;
                    break;
                }
            }
            if (self.isEnterFromFinance) {
                weakSelf.compoundModel.targetChargeModel.fundId = funditem.ID;
            } else {
                weakSelf.compoundModel.chargeModel.fundId = funditem.ID;
            }
            
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } failure:^(NSError * _Nonnull error) {
        _tableView.hidden = NO;
        [weakSelf.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];

}

- (void)setUpNav {
    if (self.chargeItem) {
        self.title = @"追加购买详情";
    } else {
        self.title = @"追加购买";
    }
    //不是新建并且没有结算的时候
    if (self.financeModel.isend != 1 && self.chargeItem) {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonClicked)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

- (void)updateUI {
    if (self.financeModel.isend != 1) {
        self.tableView.tableFooterView = self.footerView;
    }
    
    
}

- (void)deleteButtonClicked {
    MJWeakSelf;
    
    //判断是否可以删除此条追加
    //查询所有可以影响到本金变化
    //1、查询出当前日期之前的所有本金和 --- a
    //2、（查询出此billdate日期中的除了本条赎回以外所有追加和赎回的和并入之前的本金中可为正负）----b
    //3、以及当前日期后的第一条追加之间的所有赎回金额的和 ---c
    //判断条件 a+b >= c
    
    NSArray *addAndRedChargeArr = [SSJFixedFinanceProductStore queryFixedFinanceProductAddAndRedemChargeListWithModel:self.financeModel error:nil];
    double benjin = 0;
    for (SSJFixedFinanceProductChargeItem *chargeItem in addAndRedChargeArr) {
        
        if ([self.chargeItem.billDate isSameDay:chargeItem.billDate]) {
            break;
        }
        
        if (chargeItem.chargeType == SSJFixedFinCompoundChargeTypeCreate) {
            benjin += chargeItem.money;
        } else if (chargeItem.chargeType == SSJFixedFinCompoundChargeTypeRedemption) {
            benjin += chargeItem.money;
        } else if (chargeItem.chargeType == SSJFixedFinCompoundChargeTypeAdd) {
            benjin += chargeItem.money;
        }
        
    }
    
    //查询某一天的所有流水
    NSArray *oneDayChargeArr = [SSJFixedFinanceProductStore queryOneDayFixedFinanceProductAddAndRedemChargeListWithModel:self.financeModel billDate:self.chargeItem.billDate error:nil];
    double oneDaybenjin = 0;
    for (SSJFixedFinanceProductChargeItem *chargeItem in oneDayChargeArr) {
        if (chargeItem.chargeType == SSJFixedFinCompoundChargeTypeCreate) {
            oneDaybenjin += chargeItem.money;
        } else if (chargeItem.chargeType == SSJFixedFinCompoundChargeTypeRedemption) {
            oneDaybenjin -= chargeItem.money;
            double poundage = [SSJFixedFinanceProductStore queryRedemPoundageMoneyWithRedmModel:chargeItem error:nil];
            oneDaybenjin -= poundage;
        } else if (chargeItem.chargeType == SSJFixedFinCompoundChargeTypeAdd) {
            oneDaybenjin += chargeItem.money;
        }
    }
    //本天的金额总和（除去将要删除的流水金额，可正可负）归入积累本金中
    double oneDayMoney = oneDaybenjin - self.chargeItem.money;
    double lastTotalMoney = oneDayMoney + benjin;
    
//    以及当前日期后的第一条追加之间的所有赎回金额的和
    double redemMoney = 0;
    if (addAndRedChargeArr.count == 1) {
        SSJFixedFinanceProductChargeItem *chargeItem = [addAndRedChargeArr firstObject];
        if ((chargeItem.money - self.chargeItem.money) < 0) {
            [CDAutoHideMessageHUD showMessage:@"当前赎回金额大于可赎回金额"];
            return;
        }
    } else if(addAndRedChargeArr.count > 1) {
        for (SSJFixedFinanceProductChargeItem *chargeItem in addAndRedChargeArr) {
            if ([self.chargeItem.billDate isLaterThanOrEqualTo:chargeItem.billDate]) {
                continue;
            }
            if (chargeItem.chargeType == SSJFixedFinCompoundChargeTypeAdd) {
                break;
            }
            
            if (chargeItem.chargeType == SSJFixedFinCompoundChargeTypeRedemption) {
                redemMoney += chargeItem.money;
            }
        }
        
        if ((lastTotalMoney + redemMoney) < 0) {
            [CDAutoHideMessageHUD showMessage:@"删除后金额将为负数"];
            return;
        }
    }

    [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"您确定要删除此条流水吗？" action:[SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction * _Nonnull action) {
        
        [SSJFixedFinanceProductStore deleteFixedFinanceProductChargeWithModel:self.chargeItem productModel:self.financeModel success:^{
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError * _Nonnull error) {
            [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
        }];
        
    }],[SSJAlertViewAction actionWithTitle:@"取消" handler:^(SSJAlertViewAction * _Nonnull action) {
        [weakSelf.sureButton ssj_hideLoadingIndicator];
        return ;
    }],nil];
    
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
    UITextField *memo = [self.view viewWithTag:kMemoTag];
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (field == textField) {
        self.moneyStr = textField.text = [text ssj_reserveDecimalDigits:2 intDigits:9];
        
        return NO;
    } else if(memo == textField) {
        self.memoStr = text;
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
        cell.textField.text = self.moneyStr;
        cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
        cell.textField.clearsOnBeginEditing = YES;
        cell.textField.delegate = self;
        cell.textField.tag = kMoneyTag;
        if (self.financeModel.isend) {
            cell.textField.textColor = SSJ_SECONDARY_COLOR;
        }
        [cell.textField ssj_installToolbar];
        [cell setNeedsLayout];
        cell.userInteractionEnabled = !self.financeModel.isend;
        return cell;
        
    } else if (tag == kAccountTag) {
        
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFinanceLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:@"fixed_finance_out"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.textLabel.text = [self titleForCellTag:tag];
        
//        if (self.chargeItem) {
//            //查询当前charid对应的另外一跳流水
//            //通过另一条流水的fundid查找名称
//            SSJLoanFundAccountSelectionViewItem *funditem = [SSJFixedFinanceProductStore queryfundNameWithFundid:self.otherChareItem.fundId];
//            cell.subtitleLabel.text = funditem.title;
//        } else {
            if (self.fundingSelectionView.selectedIndex >= 0) {
                SSJLoanFundAccountSelectionViewItem *selectedFundItem = [self.fundingSelectionView.items ssj_safeObjectAtIndex:self.fundingSelectionView.selectedIndex];
                cell.additionalIcon.image = [UIImage imageNamed:selectedFundItem.image];
                cell.subtitleLabel.text = selectedFundItem.title;
                if (self.chargeItem) {
                    cell.subtitleLabel.textColor = SSJ_SECONDARY_COLOR;
                }
            } else {
                cell.additionalIcon.image = nil;
                cell.subtitleLabel.text = @"请选择账户";
            }
//        }
        
        if (self.financeModel.isend) {
            cell.customAccessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        cell.switchControl.hidden = YES;
        cell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
        [cell setNeedsLayout];
        cell.userInteractionEnabled = !self.financeModel.isend;
        return cell;
        
    } else if (tag == kMemoTag) {
        
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFinanceTextFieldCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:@"loan_memo"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.textLabel.text = [self titleForCellTag:tag];
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"最多可输入10个字符" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        cell.textField.text = self.memoStr;
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.textField.returnKeyType = UIReturnKeyDone;
        cell.textField.clearsOnBeginEditing = NO;
        cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        cell.textField.delegate = self;
        cell.textField.tag = kMemoTag;
        if (self.financeModel.isend) {
            cell.textField.textColor = SSJ_SECONDARY_COLOR;
        }
        [cell setNeedsLayout];
        cell.userInteractionEnabled = !self.financeModel.isend;
        return cell;
        
    } else if (tag == kDateTag) {
        
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFinanceLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:@"fixed_finance_qixi"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.textLabel.text = [self titleForCellTag:tag];
        cell.additionalIcon.image = nil;
        if (self.chargeItem) {
            cell.subtitleLabel.text = [self.chargeItem.billDate formattedDateWithFormat:@"yyyy-MM-dd"];
            cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            if ([self.compoundModel.chargeModel.billDate formattedDateWithFormat:@"yyyy-MM-dd"].length) {
                cell.subtitleLabel.text = [self.compoundModel.chargeModel.billDate formattedDateWithFormat:@"yyyy-MM-dd"];
            } else {
                cell.subtitleLabel.text = @"请选择日期";
            }
            cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        if (self.financeModel.isend) {
            cell.customAccessoryType = UITableViewCellAccessoryNone;
            cell.subtitleLabel.textColor = SSJ_SECONDARY_COLOR;
        }
        cell.descLabel.text = @"T(追购日)+1日起息，输入起息日即追购后的次日";
        
        cell.switchControl.hidden = YES;
        cell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
        [cell setNeedsLayout];
        cell.userInteractionEnabled = !self.financeModel.isend;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger tag = [[self.cellTags ssj_safeObjectAtIndex:indexPath.row] unsignedIntegerValue];
    if (tag == kDateTag) {
        return 75;
    }
    return 44;
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
    if (moneyF.text.length <=0 || [moneyF.text doubleValue] <=0) {
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
    
    if ([self.compoundModel.chargeModel.billDate isLaterThan:[NSDate date]]) {
        [CDAutoHideMessageHUD showMessage:@"不能输入未来时间"];
        return NO;
    }
    
    if (self.memoStr.length > 10) {
        [CDAutoHideMessageHUD showMessage:@"备注最大可输入10个字符"];
        return NO;
    }
    
    self.compoundModel.chargeModel.money = [moneyF.text doubleValue];
    self.compoundModel.chargeModel.oldMoney = self.compoundModel.chargeModel.money;
    self.compoundModel.chargeModel.memo = memoF.text.length ? memoF.text : @"";
    self.compoundModel.chargeModel.fundId = self.financeModel.thisfundid;
    
    self.compoundModel.targetChargeModel.money = [moneyF.text doubleValue];
    self.compoundModel.targetChargeModel.oldMoney = self.compoundModel.targetChargeModel.money;
    self.compoundModel.targetChargeModel.memo = memoF.text.length ? memoF.text : @"";
    
    if (self.chargeItem) {
        self.compoundModel.targetChargeModel.billDate = self.compoundModel.chargeModel.billDate = self.chargeItem.billDate;
    }
    //如果是编辑的时候
    if (self.chargeItem) {
        if (self.oldMoney >= [moneyF.text doubleValue]) {//为负数
            self.compoundModel.chargeModel.oldMoney = [moneyF.text doubleValue] - self.oldMoney;
        } else {
            self.compoundModel.chargeModel.oldMoney = [moneyF.text doubleValue] - self.oldMoney;
        }
        
    }
    if (!self.chargeItem) {
        NSString *cid = [NSString stringWithFormat:@"%@_%.f",self.financeModel.productid,[self.compoundModel.chargeModel.billDate timeIntervalSince1970]];
        self.compoundModel.chargeModel.cid = self.compoundModel.targetChargeModel.cid = cid;
    }
    return YES;
}

#pragma mark - Action
- (void)sureButtonAction {
    if (![self checkIfNeedClick]) return;
    
    MJWeakSelf;
    //保存流水
    NSMutableArray *saveChargeModels = [@[self.compoundModel] mutableCopy];
    
    [SSJFixedFinanceProductStore addOrRedemptionInvestmentWithProductModel:self.financeModel type:1 chargeModels:saveChargeModels success:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
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
        [_tableView ssj_clearExtendSeparator];
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
                NewFundingVC.addNewFundingBlock = ^(SSJFinancingHomeitem *item){
                    weakSelf.compoundModel.targetChargeModel.fundId = item.fundingID;
                    SSJLoanFundAccountSelectionViewItem *funItem = [[SSJLoanFundAccountSelectionViewItem alloc] init];
                    funItem.title = item.fundingName;
                    funItem.image = item.fundingIcon;
                    funItem.ID = item.fundingID;
                    [weakSelf funditem:funItem];
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
//        NSDate *compDate = [SSJFixedFinanceProductStore queryLastAddOrRedemDateWithProductModel:self.financeModel];
        _dateSelectionView.shouldConfirmBlock = ^BOOL(SSJHomeDatePickerView *view, NSDate *date) {
            if ([date compare:weakSelf.financeModel.startDate] == NSOrderedAscending) {
                [CDAutoHideMessageHUD showMessage:@"时间不能早于开始时间"];
                return NO;
            }
            
            if ([date compare:[weakSelf.financeModel.enddate ssj_dateWithFormat:@"yyyy-MM-dd"]] == NSOrderedDescending) {
                [CDAutoHideMessageHUD showMessage:@"时间不能晚于结束时间"];
                return NO;
            }
            
            if ([date compare:[NSDate date]] == NSOrderedDescending) {
                [CDAutoHideMessageHUD showMessage:@"时间不能晚于当前时间"];
                return NO;
            }
            
//            if ([date isEarlierThan:compDate] && compDate && !self.chargeItem) {//非编辑
//                [CDAutoHideMessageHUD showMessage:@"时间不能晚于最新一条追加或者赎回时间"];
//                return NO;
//            } else if(self.chargeItem && [date isLaterThan:compDate] && compDate){ //编辑
//                [CDAutoHideMessageHUD showMessage:@"时间不能早于最新一条追加或者赎回时间"];
//                return NO;
//            }
            
            return YES;
        };
        _dateSelectionView.confirmBlock = ^(SSJHomeDatePickerView *view) {
            weakSelf.compoundModel.chargeModel.billDate = view.date;
            weakSelf.compoundModel.targetChargeModel.billDate = view.date;
            weakSelf.chargeItem.billDate = view.date;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        };
    }
    return _dateSelectionView;
}

- (void)initCompoundModel {
    if (!_compoundModel) {
        NSString *chargeBillId = @"15";
        NSString *targetChargeBillId = @"16";

        NSString *uuid = SSJUUID();
        SSJFixedFinanceProductChargeItem *chargeModel = [[SSJFixedFinanceProductChargeItem alloc] init];
        chargeModel.chargeId = [NSString stringWithFormat:@"%@_%@",uuid,chargeBillId];
        chargeModel.billId = chargeBillId;
        chargeModel.userId = SSJUSERID();

        SSJFixedFinanceProductChargeItem *targetChargeModel = [[SSJFixedFinanceProductChargeItem alloc] init];
        targetChargeModel.chargeId = [NSString stringWithFormat:@"%@_%@",uuid,targetChargeBillId];
        targetChargeModel.billId = targetChargeBillId;
        targetChargeModel.userId = SSJUSERID();
        
        _compoundModel = [[SSJFixedFinanceProductCompoundItem alloc] init];
        _compoundModel.chargeModel = chargeModel;
        _compoundModel.targetChargeModel = targetChargeModel;
    }
}

- (void)initEditCompoundModel {
    if (!_compoundModel) {
        _compoundModel = [[SSJFixedFinanceProductCompoundItem alloc] init];
        if (self.isEnterFromFinance) {
            _compoundModel.chargeModel = self.chargeItem;
            _compoundModel.targetChargeModel = self.otherChareItem;
        } else {
            _compoundModel.chargeModel = self.otherChareItem;
            _compoundModel.targetChargeModel = self.chargeItem;
        }
    }
}


@end
