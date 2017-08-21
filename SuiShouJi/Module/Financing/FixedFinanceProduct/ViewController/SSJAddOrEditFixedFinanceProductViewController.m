//
//  SSJAddOrEditFixedFinanceProductViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJAddOrEditFixedFinanceProductViewController.h"
#import "SSJFundingTypeSelectViewController.h"
#import "SSJReminderEditeViewController.h"

#import "TPKeyboardAvoidingTableView.h"
#import "SSJLoanFundAccountSelectionView.h"
#import "SSJAddOrEditLoanLabelCell.h"
#import "SSJAddOrEditLoanTextFieldCell.h"
#import "SSJAddOrEditLoanMultiLabelCell.h"
#import "SSJFixedFinanceProDetailTableViewCell.h"

#import "SSJFixedFinanceProductItem.h"
#import "SSJReminderItem.h"

#import "SSJTextFieldToolbarManager.h"

static NSString *KTitle1 = @"投资名称";
static NSString *KTitle2 = @"投资金额";
static NSString *KTitle3 = @"转出账户";
static NSString *KTitle4 = @"起息时间";
static NSString *KTitle5 = @"利率";
static NSString *KTitle6 = @"期限";
static NSString *KTitle7 = @"计息方式";
static NSString *KTitle8 = @"提醒";
static NSString *KTitle9 = @"备注";

static NSString *kAddOrEditFixedFinanceProLabelCellId = @"kAddOrEditFixedFinanceProLabelCellId";
static NSString *kAddOrEditFixedFinanceProTextFieldCellId = @"kAddOrEditFixedFinanceProTextFieldCellId";
//static NSString *kAddOrEditFixedFinanceProMultiLabelCellId = @"kAddOrEditFixedFinanceProMultiLabelCellId";
static NSString *kAddOrEditFixefFinanceProSegmentTextFieldCellId = @"kAddOrEditFixefFinanceProSegmentTextFieldCellId";

@interface SSJAddOrEditFixedFinanceProductViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) SSJReminderItem *reminderItem;

// 转出账户
@property (nonatomic, strong) SSJLoanFundAccountSelectionView *fundingSelectionView;

@property (nonatomic, strong) NSArray<NSString *> *imageItems;

@property (nonatomic, strong) NSArray<NSString *> *titleItems;

@end

@implementation SSJAddOrEditFixedFinanceProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加固收理财";
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = self.footerView;
    [self updateAppearance];
}


#pragma mark - Theme
- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
    [self.tableView reloadData];
}

- (void)updateAppearance {
    [_sureButton ssj_setBackgroundColor:SSJ_BUTTON_NORMAL_COLOR forState:UIControlStateNormal];
    [_sureButton ssj_setBackgroundColor:SSJ_BUTTON_DISABLE_COLOR forState:UIControlStateDisabled];
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}

#pragma mark - Action
- (void)sureButtonAction {
//    if (self.sureAction) {
//        self.sureAction(self);
//    }
}

- (void)remindSwitchAction:(UISwitch *)switchCtrl {
    if (_reminderItem) {
        _reminderItem.remindState = switchCtrl.on;
    } else {
        [self enterReminderVC];
    }
}


- (void)enterReminderVC {
    SSJReminderItem *tmpRemindItem = _reminderItem;
    
    if (!tmpRemindItem) {
        NSDate *paymentDate = [self paymentDate];
        
        tmpRemindItem = [[SSJReminderItem alloc] init];
        tmpRemindItem.remindName = [NSString stringWithFormat:@"欠钱款元"];
        
        tmpRemindItem.remindCycle = 7;
        tmpRemindItem.remindType = SSJReminderTypeBorrowing;
        tmpRemindItem.remindDate = [NSDate dateWithYear:paymentDate.year month:paymentDate.month day:paymentDate.day hour:20 minute:0 second:0];
        tmpRemindItem.minimumDate = [NSDate date];
        tmpRemindItem.remindState = YES;
//        tmpRemindItem.borrowtarget = self.loanModel.lender;
    }
    
    __weak typeof(self) wself = self;
    SSJReminderEditeViewController *reminderVC = [[SSJReminderEditeViewController alloc] init];
    reminderVC.needToSave = NO;
    reminderVC.item = tmpRemindItem;
    reminderVC.addNewReminderAction = ^(SSJReminderItem *item) {
        wself.reminderItem = item;
        wself.model.remindid = item.remindId;
        [wself.tableView reloadData];
    };
    reminderVC.deleteReminderAction = ^{
        wself.reminderItem = nil;
        wself.reminderItem.remindId = nil;
        [wself.tableView reloadData];
    };
    [self.navigationController pushViewController:reminderVC animated:YES];
}

- (NSDate *)paymentDate {
//    return self.loanModel.repaymentDate ?: [self.loanModel.borrowDate dateByAddingMonths:1];
    return [NSDate date];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titleItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.titleItems ssj_safeObjectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self.titleItems ssj_objectAtIndexPath:indexPath];
    NSString *imageName = [self.imageItems ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:KTitle1]) {
        return [self cellOfKTitle1WithTableView:tableView indexPath:indexPath title:title image:imageName];
    } else if ([title isEqualToString:KTitle2]){
        return [self cellOfKTitle2WithTableView:tableView indexPath:indexPath title:title image:imageName];
    } else if ([title isEqualToString:KTitle3]){
        return [self cellOfKTitle3WithTableView:tableView indexPath:indexPath title:title image:imageName];
    } else if ([title isEqualToString:KTitle4]){
        return [self cellOfKTitle4WithTableView:tableView indexPath:indexPath title:title image:imageName];
    } else if ([title isEqualToString:KTitle5]){
        return [self cellOfKTitle5WithTableView:tableView indexPath:indexPath title:title image:imageName];
    } else if ([title isEqualToString:KTitle6]){
        return [self cellOfKTitle6WithTableView:tableView indexPath:indexPath title:title image:imageName];
    } else if ([title isEqualToString:KTitle7]){
        return [self cellOfKTitle7WithTableView:tableView indexPath:indexPath title:title image:imageName];
    } else if ([title isEqualToString:KTitle8]){
        return [self cellOfKTitle8WithTableView:tableView indexPath:indexPath title:title image:imageName];
    } else if ([title isEqualToString:KTitle9]){
        return [self cellOfKTitle9WithTableView:tableView indexPath:indexPath title:title image:imageName];
    }
    return nil;
}

- (__kindof UITableViewCell *)cellOfKTitle1WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixedFinanceProTextFieldCellId forIndexPath:indexPath];
    cell.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.textLabel.text = title;
    cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"必填" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    //        cell.textField.text = self.loanModel.lender;
    cell.textField.keyboardType = UIKeyboardTypeDefault;
    cell.textField.returnKeyType = UIReturnKeyDone;
    cell.textField.delegate = self;
    cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    //        cell.textField.tag = kLenderTag;
    [cell setNeedsLayout];
    return cell;
}

- (__kindof UITableViewCell *)cellOfKTitle2WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixedFinanceProTextFieldCellId forIndexPath:indexPath];
    cell.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    cell.textField.text = [NSString stringWithFormat:@"¥%.2f", [self.model.money doubleValue]];
    cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
    cell.textField.returnKeyType = UIReturnKeyDone;
    cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    cell.textField.delegate = self;
//    cell.textField.tag = kMoneyTag;
    [cell setNeedsLayout];
    [cell.textField ssj_installToolbar];
    return cell;
}

- (__kindof UITableViewCell *)cellOfKTitle3WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixedFinanceProLabelCellId forIndexPath:indexPath];
    cell.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    if (_fundingSelectionView.selectedIndex >= 0) {
        SSJLoanFundAccountSelectionViewItem *selectedFundItem = [self.fundingSelectionView.items ssj_safeObjectAtIndex:_fundingSelectionView.selectedIndex];
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
}

- (__kindof UITableViewCell *)cellOfKTitle4WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixedFinanceProLabelCellId forIndexPath:indexPath];
    cell.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.additionalIcon.image = nil;
    cell.subtitleLabel.text = [self.model.startdate ssj_dateStringFromFormat:@"yyyy.MM.dd HH:mm:ss.SSS" toFormat:@"yyyy-MM-dd"];
    cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.switchControl.hidden = YES;
    cell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
    [cell setNeedsLayout];
    
    return cell;
}

- (__kindof UITableViewCell *)cellOfKTitle5WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJFixedFinanceProDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixefFinanceProSegmentTextFieldCellId forIndexPath:indexPath];
    return cell;
}

- (__kindof UITableViewCell *)cellOfKTitle6WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJFixedFinanceProDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixefFinanceProSegmentTextFieldCellId forIndexPath:indexPath];
    return cell;
}

- (__kindof UITableViewCell *)cellOfKTitle7WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixedFinanceProLabelCellId forIndexPath:indexPath];
    cell.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    if (_fundingSelectionView.selectedIndex >= 0) {
        SSJLoanFundAccountSelectionViewItem *selectedFundItem = [self.fundingSelectionView.items ssj_safeObjectAtIndex:_fundingSelectionView.selectedIndex];
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

}

- (__kindof UITableViewCell *)cellOfKTitle8WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixedFinanceProLabelCellId forIndexPath:indexPath];
    cell.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.textLabel.text = @"到期日提醒";
    cell.subtitleLabel.text = [_reminderItem.remindDate formattedDateWithFormat:@"yyyy.MM.dd"];
    cell.additionalIcon.image = nil;
    cell.customAccessoryType = UITableViewCellAccessoryNone;
    cell.switchControl.hidden = NO;
    cell.switchControl.on = _reminderItem.remindState;
    [cell.switchControl removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
    [cell.switchControl addTarget:self action:@selector(remindSwitchAction:) forControlEvents:UIControlEventValueChanged];
    cell.selectionStyle = _reminderItem ? SSJ_CURRENT_THEME.cellSelectionStyle : UITableViewCellSelectionStyleNone;
    [cell setNeedsLayout];
    
    return cell;

}

- (__kindof UITableViewCell *)cellOfKTitle9WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixedFinanceProTextFieldCellId forIndexPath:indexPath];
    cell.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.textLabel.text = @"备注";
    cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"备注说明" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    cell.textField.text = self.model.memo;
    cell.textField.keyboardType = UIKeyboardTypeDefault;
    cell.textField.returnKeyType = UIReturnKeyDone;
    cell.textField.clearsOnBeginEditing = NO;
    cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    cell.textField.delegate = self;
//    cell.textField.tag = kMemoTag;
    [cell setNeedsLayout];
    
    return cell;

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
        [_tableView registerClass:[SSJAddOrEditLoanLabelCell class] forCellReuseIdentifier:kAddOrEditFixedFinanceProLabelCellId];
        [_tableView registerClass:[SSJAddOrEditLoanTextFieldCell class] forCellReuseIdentifier:kAddOrEditFixedFinanceProTextFieldCellId];
        [_tableView registerClass:[SSJFixedFinanceProDetailTableViewCell class] forCellReuseIdentifier:kAddOrEditFixefFinanceProSegmentTextFieldCellId];
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
        _sureButton.frame = CGRectMake(15, 30, self.footerView.width - 30, 44);
        _sureButton.clipsToBounds = YES;
        _sureButton.layer.cornerRadius = 6;
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
                weakSelf.model.targetfundid = item.ID;
                [weakSelf.tableView reloadData];
                return YES;
            } else if (index == view.items.count - 1) {
                SSJFundingTypeSelectViewController *NewFundingVC = [[SSJFundingTypeSelectViewController alloc]init];
                NewFundingVC.needLoanOrNot = NO;
                NewFundingVC.addNewFundingBlock = ^(SSJBaseCellItem *item){
                    if ([item isKindOfClass:[SSJFundingItem class]]) {
                        SSJFundingItem *fundItem = (SSJFundingItem *)item;
                        weakSelf.model.targetfundid = fundItem.fundingID;
//                        [weakSelf loadData];
                    } else if (0){//[item isKindOfClass:[SSJCreditCardItem class]]
//                        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
//                        weakSelf.model.targetfundid = cardItem.cardId;
//                        [weakSelf loadData];
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

- (NSArray<NSString *> *)imageItems {
    if (!_imageItems) {
        _imageItems = @[@[@"loan_person",@"loan_money",@"loan_account"],@[@"loan_account",@"loan_account",@"loan_account",@"loan_account"],@[@"loan_remind",@"loan_memo"]];
    }
    return _imageItems;
}

- (NSArray<NSString *> *)titleItems {
    if (!_titleItems) {
        _titleItems = @[@[KTitle1,KTitle2,KTitle3],@[KTitle4,KTitle5,KTitle6,KTitle7],@[KTitle8,KTitle9]];
    }
    return _titleItems;
}
@end
