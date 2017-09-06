//
//  SSJFixedFinancesSettlementViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/28.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinancesSettlementViewController.h"
#import "SSJFundingTypeSelectViewController.h"

#import "TPKeyboardAvoidingTableView.h"
#import "SSJLoanFundAccountSelectionView.h"
#import "SSJHomeDatePickerView.h"
#import "SSJAddOrEditLoanLabelCell.h"
#import "SSJAddOrEditLoanTextFieldCell.h"
#import "SSJFixedFinanceProDetailTableViewCell.h"

#import "SSJFixedFinanceProductItem.h"
#import "SSJFixedFinanceProductCompoundItem.h"
#import "SSJFixedFinanceProductItem.h"
#import "SSJCreditCardItem.h"

#import "SSJTextFieldToolbarManager.h"
#import "SSJFixedFinanceProductStore.h"
#import "SSJLoanHelper.h"
#import "SSJDataSynchronizer.h"

static NSString *kAddOrEditFixedFinanceProLabelCellId = @"kAddOrEditFixedFinanceProLabelCellId";
static NSString *kAddOrEditFixedFinanceProTextFieldCellId = @"kAddOrEditFixedFinanceProTextFieldCellId";
static NSString *kAddOrEditFixefFinanceProSegmentTextFieldCellId = @"kAddOrEditFixefFinanceProSegmentTextFieldCellId";
static NSString *const kAddOrEditFinanceTextFieldCellId = @"kAddOrEditFinanceTextFieldCellId";

static NSString *kTitle1 = @"投资本金";
static NSString *kTitle2 = @"利息收入";
static NSString *kTitle3 = @"手续费";
static NSString *kTitle4 = @"金额";
static NSString *kTitle5 = @"计算转入账户";
static NSString *kTitle6 = @"结算日期";

@interface SSJFixedFinancesSettlementViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property (nonatomic, strong) SSJLoanFundAccountSelectionView *fundingSelectionView;

// 日期选择控件
@property (nonatomic, strong) SSJHomeDatePickerView *dateSelectionView;

@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) NSArray *imageItems;

@property (nonatomic, strong) NSArray *titleItems;

@property (nonatomic, strong) UITextField *moneyTextF;

@property (nonatomic, strong) UITextField *liXiTextF;

@property (nonatomic, strong) UITextField *poundageTextF;

@property (nonatomic, strong) UILabel *subL;

@property (nonatomic, strong) UITextField *memoTextF;

// 利息开关
@property (nonatomic, strong) UISwitch *liXiSwitch;

@property (nonatomic, strong) SSJFixedFinanceProductCompoundItem *compoundModel;
//利息
@property (nonatomic, strong) SSJFixedFinanceProductCompoundItem *lixicompoundModel;

@property (nonatomic, strong) SSJFixedFinanceProductItem *financeModel;

/**是否计算利息*/
@property (nonatomic, assign) BOOL isLiXiOn;

/**<#注释#>*/
@property (nonatomic, copy) NSString *moneyStr;

@property (nonatomic, copy) NSString *lixiStr;

@end

@implementation SSJFixedFinancesSettlementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self orangeData];
    [self loadData];
    [self setUpNav];
    [self setBind];
    [self updateAppearance];
}

- (void)setUpNav {
    self.title = @"结算";
}

- (void)orangeData {
    self.titleItems = @[@[kTitle1,kTitle2,kTitle3],@[kTitle5,kTitle6]];
    self.imageItems = @[@[@"loan_money",@"loan_money",@"loan_money"],@[@"loan_money",@"loan_money"]];
}

- (void)setBind {
    
}

#pragma mark - Theme
- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    [self.sureButton ssj_setBackgroundColor:SSJ_BUTTON_NORMAL_COLOR forState:UIControlStateNormal];
    [self.sureButton ssj_setBackgroundColor:SSJ_BUTTON_DISABLE_COLOR forState:UIControlStateDisabled];
    self.tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    textField.text = [text ssj_reserveDecimalDigits:2 intDigits:9];
    if (self.moneyTextF == textField || self.poundageTextF == textField) {
        if (self.moneyTextF == textField) {
            self.moneyStr = text;
            [self updateSubTitle];
        } else {
            [self updateSubTitle];
        }
        return NO;
    }
    
    if (self.liXiTextF == textField) {
        self.lixiStr = text;
        return NO;
    }
    return YES;
}

- (void)updateSubTitle {
    NSString *targetStr = [NSString stringWithFormat:@"%.2f",([self.moneyStr doubleValue] - [self.poundageTextF.text doubleValue])];
    NSString *oldStr = [NSString stringWithFormat:@"到账金额为：%@元",targetStr];
    self.subL.attributedText = [oldStr attributeStrWithTargetStr:targetStr range:NSMakeRange(0, 0) color:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]];
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titleItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = [self.titleItems ssj_safeObjectAtIndex:section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self.titleItems ssj_objectAtIndexPath:indexPath];
    NSString *imageName = [self.imageItems  ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString: kTitle1] || [title isEqualToString:kTitle2]) {
        
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixedFinanceProTextFieldCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.textLabel.text = title;
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"¥0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        
        cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
        cell.textField.clearsOnBeginEditing = YES;
        cell.textField.delegate = self;
        [cell.textField ssj_installToolbar];
        if ([title isEqualToString:kTitle1]) {
            cell.textField.text = self.moneyStr;
            self.moneyTextF = cell.textField;
        } else if([title isEqualToString:kTitle2]) {
            cell.textField.text = self.lixiStr;
            self.liXiTextF = cell.textField;
        }
        
        [cell setNeedsLayout];
        return cell;
        
    } else if ([title isEqualToString:kTitle5]) {
        
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixedFinanceProLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.textLabel.text = title;
        
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
        
    } else if ([title isEqualToString:kTitle6]) {
        
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixedFinanceProLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.textLabel.text = title;
        cell.additionalIcon.image = nil;
        cell.subtitleLabel.text = self.compoundModel.chargeModel.billDate ? [self.compoundModel.chargeModel.billDate formattedDateWithFormat:@"yyyy-MM-dd"] : [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"];
        cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.switchControl.hidden = YES;
        cell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
        [cell setNeedsLayout];
        return cell;
        
    } else if ([title isEqualToString:kTitle3]) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixedFinanceProLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.textLabel.text = title;
        cell.additionalIcon.image = nil;
        cell.customAccessoryType = UITableViewCellAccessoryNone;
        cell.switchControl.hidden = NO;
        [cell.switchControl removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
        cell.switchControl.on = _isLiXiOn;
        [cell.switchControl addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        //        self.liXiSwitch = cell.switchControl;
        [cell setNeedsLayout];
        
        return cell;
    } else if ([title isEqualToString:kTitle4]) {
        SSJFixedFinanceProDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixefFinanceProSegmentTextFieldCellId forIndexPath:indexPath];
        cell.leftImageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入金额" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
        cell.textField.clearsOnBeginEditing = YES;
        cell.textField.delegate = self;
        [cell.textField ssj_installToolbar];
        cell.textField.text = [NSString stringWithFormat:@"¥%.2f", self.compoundModel.chargeModel.money];
        self.poundageTextF = cell.textField;
        cell.nameL.text = title;
        cell.hasPercentageL = NO;
        cell.hasNotSegment = YES;
        self.subL = cell.subNameL;
        return cell;
        
    } else {
        return [[UITableViewCell alloc] init];
    }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.titleItems ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTitle5]) {
        [self.view endEditing:YES];
        [self.fundingSelectionView show];
    } else if ([title isEqualToString:kTitle6]) {
        [self.view endEditing:YES];
        self.dateSelectionView.date = self.compoundModel.chargeModel.billDate;
        [self.dateSelectionView show];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self.titleItems ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTitle4]) {
        return 75;
    } else if ([title isEqualToString:kTitle5] || [title isEqualToString:kTitle3]) {
        return 55;
    }
    return 50;
}

#pragma mark - Private
- (void)loadData {
    MJWeakSelf;
    [SSJFixedFinanceProductStore queryForFixedFinanceProduceWithProductID:self.productid success:^(SSJFixedFinanceProductItem * _Nonnull model) {
        weakSelf.financeModel = model;
        [weakSelf initCompoundModel];
        [weakSelf initLixicompoundModel];
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
    
    
    [self.view ssj_showLoadingIndicator];
    [SSJLoanHelper queryFundModelListWithSuccess:^(NSArray <SSJLoanFundAccountSelectionViewItem *>*items) {
        _tableView.hidden = NO;
        [self.view ssj_hideLoadingIndicator];
        
        // 设置默认账户
        self.fundingSelectionView.items = items;
        self.fundingSelectionView.selectedIndex = -1;
        [_tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        _tableView.hidden = NO;
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
}



- (BOOL)checkIfNeedCheck {
    if (!self.moneyTextF.text.length || [self.moneyTextF.text doubleValue] <=0) {
        [CDAutoHideMessageHUD showMessage:@"请先输入投资本金"];
        return NO;
    }
    
    if (_isLiXiOn) {
        if (!self.poundageTextF.text.length) {
            [CDAutoHideMessageHUD showMessage:@"请输入金额"];
            return NO;
        }
    }
    
    if (self.fundingSelectionView.selectedIndex < 0) {
        [CDAutoHideMessageHUD showMessage:@"请选择账户"];
        return NO;
    }
    
    if ([self.moneyTextF.text doubleValue] > [self.financeModel.money doubleValue]) {
        [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:[NSString stringWithFormat:@"你结算时的本金需等于累计投资本金金额%.2f元，请重新输入",[self.financeModel.money doubleValue]] action:[SSJAlertViewAction actionWithTitle:@"知道了" handler:NULL],nil];
        return NO;
    }
    
    if ([self.poundageTextF.text doubleValue] > [self.financeModel.money doubleValue]) {
        [CDAutoHideMessageHUD showMessage:@"手续费不能大于本金哦"];
        return NO;
    }
    
    
    return YES;
}

- (void)updateModel {
    self.compoundModel.chargeModel.money = self.compoundModel.targetChargeModel.money = [self.moneyTextF.text doubleValue];
    self.compoundModel.interestChargeModel.money = [self.poundageTextF.text doubleValue];//手续费
    self.compoundModel.chargeModel.memo = self.compoundModel.targetChargeModel.memo = self.compoundModel.interestChargeModel.memo = self.memoTextF.text.length ? self.memoTextF.text : @"";
    
    self.lixicompoundModel.chargeModel.money = self.lixicompoundModel.targetChargeModel.money = [self.liXiTextF.text doubleValue];
    self.lixicompoundModel.chargeModel.memo = self.lixicompoundModel.targetChargeModel.memo = self.memoTextF.text.length ? self.memoTextF.text : @"";
}

#pragma mark - Action
- (void)sureButtonAction {
    if (![self checkIfNeedCheck]) return;
    [self updateModel];
    MJWeakSelf;
    //保存流水
    NSArray *chargArr = @[self.compoundModel,self.lixicompoundModel];
    [SSJFixedFinanceProductStore settlementWithProductModel:self.financeModel chargeModels:chargArr success:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
         [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
}

- (void)switchValueChanged:(UISwitch *)swit {
    _isLiXiOn = !_isLiXiOn;
    if (_isLiXiOn) {
        self.titleItems = @[@[kTitle1,kTitle2,kTitle3,kTitle4],@[kTitle5,kTitle6]];
        self.imageItems = @[@[@"loan_money",@"loan_money",@"loan_money",@"loan_money"],@[@"loan_money",@"loan_money"]];
    } else {
        self.titleItems = @[@[kTitle1,kTitle2,kTitle3],@[kTitle5,kTitle6]];
        self.imageItems = @[@[@"loan_money",@"loan_money",@"loan_money"],@[@"loan_money",@"loan_money"]];
    }
    
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
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
        [_tableView registerClass:[SSJAddOrEditLoanLabelCell class] forCellReuseIdentifier:kAddOrEditFixedFinanceProLabelCellId];
        [_tableView registerClass:[SSJAddOrEditLoanTextFieldCell class] forCellReuseIdentifier:kAddOrEditFixedFinanceProTextFieldCellId];
        [_tableView registerClass:[SSJFixedFinanceProDetailTableViewCell class] forCellReuseIdentifier:kAddOrEditFixefFinanceProSegmentTextFieldCellId];
        _tableView.tableFooterView = self.footerView;
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
        [_sureButton setTitle:@"结算" forState:UIControlStateNormal];
        [_sureButton setTitle:@"" forState:UIControlStateDisabled];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(sureButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _sureButton.frame = CGRectMake(15, 30, self.footerView.width - 30, 44);
        _sureButton.clipsToBounds = YES;
        _sureButton.layer.cornerRadius = 6;
    }
    return _sureButton;
}

- (SSJHomeDatePickerView *)dateSelectionView {
    if (!_dateSelectionView) {
        __weak typeof(self) weakSelf = self;
        _dateSelectionView = [[SSJHomeDatePickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        NSDate *newdate = [[SSJFixedFinanceProductStore queryFixedFinanceProductNewChargeBillDateWithModel:self.financeModel]
        ssj_dateWithFormat:@"yyyy-MM-dd"];
        
        _dateSelectionView.horuAndMinuBgViewBgColor = [UIColor clearColor];
        _dateSelectionView.datePickerMode = SSJDatePickerModeDate;
        _dateSelectionView.date = self.compoundModel.chargeModel.billDate;
        _dateSelectionView.shouldConfirmBlock = ^BOOL(SSJHomeDatePickerView *view, NSDate *date) {
            if ([date compare:newdate] == NSOrderedAscending) {
                [CDAutoHideMessageHUD showMessage:@"日期不能早于最新流水日期哦"];
                //日期不能早于该账户有效流水日期
                
                return NO;
            }
            return YES;
        };
        _dateSelectionView.confirmBlock = ^(SSJHomeDatePickerView *view) {
            weakSelf.compoundModel.chargeModel.billDate = view.date;
            weakSelf.compoundModel.targetChargeModel.billDate = view.date;
            weakSelf.compoundModel.interestChargeModel.billDate = view.date;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        };
    }
    return _dateSelectionView;
}

- (SSJLoanFundAccountSelectionView *)fundingSelectionView {
    if (!_fundingSelectionView) {
        __weak typeof(self) weakSelf = self;
        _fundingSelectionView = [[SSJLoanFundAccountSelectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        _fundingSelectionView.shouldSelectAccountAction = ^BOOL(SSJLoanFundAccountSelectionView *view, NSUInteger index) {
            if (index < view.items.count - 1) {
                SSJLoanFundAccountSelectionViewItem *item = [view.items objectAtIndex:index];
                weakSelf.compoundModel.targetChargeModel.fundId = item.ID;
                //结算账户
                weakSelf.financeModel.etargetfundid = item.ID;
                weakSelf.fundingSelectionView.selectedIndex = index;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                return YES;
            } else if (index == view.items.count - 1) {
                SSJFundingTypeSelectViewController *NewFundingVC = [[SSJFundingTypeSelectViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
                NewFundingVC.needLoanOrNot = NO;
                NewFundingVC.addNewFundingBlock = ^(SSJFinancingHomeitem *item){
                        weakSelf.financeModel.targetfundid = item.fundingID;
                        [weakSelf loadData];
//                    else if ([item isKindOfClass:[SSJCreditCardItem class]]){
//                        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
//                        weakSelf.financeModel.targetfundid = cardItem.cardId;
//                        [weakSelf loadData];
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

- (void)initCompoundModel {
    if (!_compoundModel) {
        NSString *chargeBillId = nil;
        NSString *targetChargeBillId = nil;
        NSString *interestChargeBillId = nil;
        chargeBillId = @"4";
        targetChargeBillId = @"3";
        interestChargeBillId = @"22";
        NSDate *today = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day];
        NSDate *billDate = [today compare:self.financeModel.startDate] == NSOrderedAscending ? self.financeModel.startDate : today;
        
        SSJFixedFinanceProductChargeItem *chargeModel = [[SSJFixedFinanceProductChargeItem alloc] init];
        chargeModel.chargeId = SSJUUID();
        chargeModel.fundId = self.financeModel.thisfundid;
        chargeModel.billId = chargeBillId;
        chargeModel.userId = SSJUSERID();
        chargeModel.billDate = billDate;
        chargeModel.chargeType = SSJLoanCompoundChargeTypeRepayment;
        
        SSJFixedFinanceProductChargeItem *targetChargeModel = [[SSJFixedFinanceProductChargeItem alloc] init];
        targetChargeModel.chargeId = SSJUUID();
        targetChargeModel.fundId = self.financeModel.targetfundid;
        targetChargeModel.billId = targetChargeBillId;
        targetChargeModel.userId = SSJUSERID();
        targetChargeModel.billDate = billDate;
        targetChargeModel.chargeType = SSJLoanCompoundChargeTypeAdd;
        
        SSJFixedFinanceProductChargeItem *interestChargeModel = [[SSJFixedFinanceProductChargeItem alloc] init];
        interestChargeModel.chargeId = SSJUUID();
        interestChargeModel.fundId = self.financeModel.thisfundid;
        interestChargeModel.billId = interestChargeBillId;
        interestChargeModel.userId = SSJUSERID();
        interestChargeModel.billDate = billDate;
        interestChargeModel.chargeType = SSJLoanCompoundChargeTypeInterest;
        
        _compoundModel = [[SSJFixedFinanceProductCompoundItem alloc] init];
        _compoundModel.chargeModel = chargeModel;
        _compoundModel.targetChargeModel = targetChargeModel;
        _compoundModel.interestChargeModel = interestChargeModel;
        
    }
}

- (void)initLixicompoundModel {
    if (!_lixicompoundModel) {//利息
        NSString *chargeBillId = @"20";
        NSString *targetChargeBillId = @"19";
        
        NSDate *today = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day];
        NSDate *billDate = [today compare:self.financeModel.startDate] == NSOrderedAscending ? self.financeModel.startDate : today;
        
        SSJFixedFinanceProductChargeItem *chargeModel = [[SSJFixedFinanceProductChargeItem alloc] init];
        chargeModel.chargeId = SSJUUID();
        chargeModel.fundId = self.financeModel.thisfundid;
        chargeModel.billId = chargeBillId;
        chargeModel.userId = SSJUSERID();
        chargeModel.billDate = billDate;
        
        SSJFixedFinanceProductChargeItem *targetChargeModel = [[SSJFixedFinanceProductChargeItem alloc] init];
        targetChargeModel.chargeId = SSJUUID();
        targetChargeModel.fundId = self.financeModel.targetfundid;
        targetChargeModel.billId = targetChargeBillId;
        targetChargeModel.userId = SSJUSERID();
        targetChargeModel.billDate = billDate;

        _lixicompoundModel = [[SSJFixedFinanceProductCompoundItem alloc] init];
        _lixicompoundModel.chargeModel = chargeModel;
        _lixicompoundModel.targetChargeModel = targetChargeModel;
        
    }
}

@end
