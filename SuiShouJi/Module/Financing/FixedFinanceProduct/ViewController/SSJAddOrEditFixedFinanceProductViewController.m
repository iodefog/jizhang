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
#import "SSJJiXiMethodTableViewCell.h"
#import "SSJHomeDatePickerView.h"

#import "SSJFixedFinanceProductItem.h"
#import "SSJReminderItem.h"

#import "SSJLoanHelper.h"

#import "SSJTextFieldToolbarManager.h"
#import "SSJGeTuiManager.h"
#import "NSString+MoneyDisplayFormat.h"

static NSString *KTitle1 = @"投资名称";
static NSString *KTitle2 = @"投资金额";
static NSString *KTitle3 = @"转出账户";
static NSString *KTitle4 = @"起息时间";
static NSString *KTitle5 = @"利率";
static NSString *KTitle6 = @"期限";
static NSString *KTitle7 = @"派息方式";
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

// 计息方式
@property (nonatomic, strong) SSJLoanFundAccountSelectionView *jiXiMethodSelectionView;

// 气息时间
@property (nonatomic, strong) SSJHomeDatePickerView *borrowDateSelectionView;

@property (nonatomic, strong) NSArray<NSString *> *imageItems;

@property (nonatomic, strong) NSArray<NSString *> *titleItems;

@property (nonatomic, strong) UITextField *nameTextF;

@property (nonatomic, strong) UITextField *moneyTextF;

@property (nonatomic, strong) UITextField *liLvTextF;

@property (nonatomic, strong) UITextField *qiXianTextF;

@property (nonatomic, strong) UITextField *memoTextF;

// 提醒开关
@property (nonatomic, strong) UISwitch *remindSwitch;

@end

@implementation SSJAddOrEditFixedFinanceProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加固收理财";
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = self.footerView;
    [self loadData];
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

#pragma mark - Private
- (void)loadData {
    [self.view ssj_showLoadingIndicator];
    self.jiXiMethodSelectionView.selectedIndex = -1;
    [SSJLoanHelper queryFundModelListWithSuccess:^(NSArray <SSJLoanFundAccountSelectionViewItem *>*items) {
        
        _tableView.hidden = NO;
        [self.view ssj_hideLoadingIndicator];
        
        // 新建借贷设置默认账户
        self.fundingSelectionView.items = items;
        self.fundingSelectionView.selectedIndex = -1;
        [_tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        _tableView.hidden = NO;
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
}

- (BOOL)remindLocation {
    //如果已经弹出过授权弹框开启通知
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SSJNoticeAlertKey]) {//弹出过授权弹框
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f) {
            UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
            if (UIUserNotificationTypeNone == setting.types) {
                //推送关闭(去设置)
                self.remindSwitch.on = NO;
                [SSJAlertViewAdapter showAlertViewWithTitle:@"哎呀，未开启推送通知" message:@"这样会错过您设定的提醒，墙裂建议您打开吆" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:NULL],[SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction * _Nonnull action) {
                    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    
                    if([[UIApplication sharedApplication] canOpenURL:url]) {
                        
                        NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];           [[UIApplication sharedApplication] openURL:url];
                    }
                    
                }],nil];
            }else{
                //推送打开去设置提醒详情
                return YES;
            }
        }
        
    } else { //没有弹出过授权弹框
        //弹出授权弹框
        self.remindSwitch.on = NO;
        [[SSJGeTuiManager shareManager] registerRemoteNotificationWithDelegate:[UIApplication sharedApplication]];//远程通知
    }
    return NO;
}


#pragma mark - Action
- (void)sureButtonAction {
//    if (self.sureAction) {
//        self.sureAction(self);
//    }
    
    if (!self.nameTextF.text.length) {
        [CDAutoHideMessageHUD showMessage:@"请输入投资名称"];
        return;
    }
    
    if (!self.nameTextF.text.length) {
        [CDAutoHideMessageHUD showMessage:@"请输入投资金额"];
        return;
    }
    
    if (self.fundingSelectionView.selectedIndex < 0) {
        [CDAutoHideMessageHUD showMessage:@"请选择起息时间"];
        return;
    }
    
    if (!self.liLvTextF.text.length || [self.liLvTextF.text doubleValue] <= 0) {
        [CDAutoHideMessageHUD showMessage:@"请输入利率"];
        return;
    }
    
    if (self.qiXianTextF.text.length || [self.qiXianTextF.text doubleValue] <= 0) {
        [CDAutoHideMessageHUD showMessage:@"请输入期限"];
        return;
    }
    
    if (self.jiXiMethodSelectionView.selectedIndex < 0) {
        [CDAutoHideMessageHUD showMessage:@"请选择派息方式"];
        return;
    }
    
    //保存固定收益理财
    //保存固定理财的提醒
}

//- (void)remindSwitchAction:(UISwitch *)switchCtrl {
//    if (_reminderItem) {
//        _reminderItem.remindState = switchCtrl.on;
//    } else {
//        [self enterReminderVC];
//    }
//}

- (void)switchValueChanged:(UISwitch *)switchc {
    if (!switchc.isOn) return;
    //判断有没有授权
    if ([self remindLocation]) {
        SSJReminderEditeViewController *remindEditeVc = [[SSJReminderEditeViewController alloc] init];
        remindEditeVc.needToSave = YES;
        __weak typeof(self) weakSelf = self;
        remindEditeVc.addNewReminderAction = ^(SSJReminderItem *item) {
            weakSelf.remindSwitch.on = YES;
            item.remindType = SSJFixedFinaProduct;
            weakSelf.reminderItem = item;
        };
        
        remindEditeVc.notSaveReminderAction = ^{
            weakSelf.remindSwitch.on = NO;
        };
        remindEditeVc.needToSave = YES;
        [self.navigationController pushViewController:remindEditeVc animated:YES];
    }
}



- (void)enterReminderVC {
    SSJReminderItem *tmpRemindItem = _reminderItem;
    
    if (!tmpRemindItem) {
        NSDate *paymentDate = [self paymentDate];
        
        tmpRemindItem = [[SSJReminderItem alloc] init];
        tmpRemindItem.remindName = [NSString stringWithFormat:@"投资名称+投资到期"];
        
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

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.titleItems ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:KTitle3]) {
        [self.view endEditing:YES];
        
        [self.fundingSelectionView show];
    } else if ([title isEqualToString:KTitle4]) {
        [self.view endEditing:YES];
        self.borrowDateSelectionView.date = [NSDate date];
        [self.borrowDateSelectionView show];
    } else if ([title isEqualToString:KTitle7]) {
        [self.view endEditing:YES];
        [self.jiXiMethodSelectionView show];
    } else if ([title isEqualToString:KTitle8]) {
        if (_reminderItem) {
            [self enterReminderVC];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self.titleItems ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:KTitle5] || [title isEqualToString:KTitle6] || [title isEqualToString:KTitle7]) {
        return 75;
    }
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
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
    self.nameTextF = cell.textField;
    [cell setNeedsLayout];
    return cell;
}

- (__kindof UITableViewCell *)cellOfKTitle2WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixedFinanceProTextFieldCellId forIndexPath:indexPath];
    cell.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.textLabel.text = title;
    cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    cell.textField.text = [NSString stringWithFormat:@"¥%.2f", [self.model.money doubleValue]];
    cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
    cell.textField.returnKeyType = UIReturnKeyDone;
    cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    cell.textField.delegate = self;
    self.moneyTextF = cell.textField;
    [cell setNeedsLayout];
    [cell.textField ssj_installToolbar];
    return cell;
}

- (__kindof UITableViewCell *)cellOfKTitle3WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixedFinanceProLabelCellId forIndexPath:indexPath];
    cell.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.textLabel.text = title;
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
    cell.textLabel.text = title;
    cell.additionalIcon.image = nil;
    cell.subtitleLabel.text = self.model.startdate ? [self.model.startdate ssj_dateStringFromFormat:@"yyyy.MM.dd HH:mm:ss.SSS" toFormat:@"yyyy-MM-dd"] : [[NSDate date] ssj_dateStringWithFormat:@"yyyy-MM-dd"];
    cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.switchControl.hidden = YES;
    cell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
    [cell setNeedsLayout];
    
    return cell;
}

- (__kindof UITableViewCell *)cellOfKTitle5WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJFixedFinanceProDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixefFinanceProSegmentTextFieldCellId forIndexPath:indexPath];
    cell.leftImageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入利率" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
    cell.textField.delegate = self;
    cell.nameL.text = @"利率";
    self.liLvTextF = cell.textField;
    NSString *oldStr = [NSString stringWithFormat:@"每月10号该账户将生成50.00元的利息流水"];
    cell.subNameL.text = oldStr;
    //    cell.subtitleLabel.attributedText = [NSMutableAttributedString attr];
    cell.hasPercentageL = YES;
    return cell;
}

- (__kindof UITableViewCell *)cellOfKTitle6WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJFixedFinanceProDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixefFinanceProSegmentTextFieldCellId forIndexPath:indexPath];
    cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入整数" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    cell.textField.keyboardType = UIKeyboardTypeNumberPad;
    cell.textField.returnKeyType = UIReturnKeyDone;
    cell.textField.delegate = self;
    self.qiXianTextF = cell.textField;
    cell.leftImageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.nameL.text = @"期限";
    cell.segmentControl.selectedSegmentIndex = 2;
    
    return cell;
}

- (__kindof UITableViewCell *)cellOfKTitle7WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJJiXiMethodTableViewCell *cell = [SSJJiXiMethodTableViewCell cellWithTableView:tableView];
    cell.additionalIcon.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.nameLabel.text = title;
    if (_jiXiMethodSelectionView.selectedIndex >= 0) {
        SSJLoanFundAccountSelectionViewItem *selectedFundItem = [self.jiXiMethodSelectionView.items ssj_safeObjectAtIndex:_jiXiMethodSelectionView.selectedIndex];
        cell.detailL.text = selectedFundItem.title;
    } else {
        cell.detailL.text = @"请选择派息方式";
    }
    NSString *oldStr = [NSString stringWithFormat:@"T（成交日）+1日计息，每天产生利息2.00元"];
    cell.subtitleLabel.text = oldStr;
//    cell.subtitleLabel.attributedText = [NSMutableAttributedString attr];
    [cell setNeedsLayout];
    return cell;

}

- (__kindof UITableViewCell *)cellOfKTitle8WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixedFinanceProLabelCellId forIndexPath:indexPath];
    cell.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.textLabel.text = title;
    cell.subtitleLabel.text = [_reminderItem.remindDate formattedDateWithFormat:@"yyyy.MM.dd"];
    cell.additionalIcon.image = nil;
    cell.customAccessoryType = UITableViewCellAccessoryNone;
    cell.switchControl.hidden = NO;
    cell.switchControl.on = _reminderItem.remindState;
    [cell.switchControl removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
    [cell.switchControl addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    cell.selectionStyle = _reminderItem ? SSJ_CURRENT_THEME.cellSelectionStyle : UITableViewCellSelectionStyleNone;
    self.remindSwitch = cell.switchControl;
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
    self.memoTextF = cell.textField;
    [cell setNeedsLayout];
    
    return cell;

}

#pragma mark - UITextFieldDelegate
// 有些输入框的clearsOnBeginEditing设为YES，只要获取焦点文本内容就会清空，这种情况下不会收到文本改变的通知，所以在这个代理函数中进行了处理
- (BOOL)textFieldShouldClear:(UITextField *)textField {
//    if (textField.tag == kLenderTag) {
//        self.loanModel.lender = @"";
//        [self updateRemindName];
//    } else if (textField.tag == kMoneyTag) {
//        self.loanModel.jMoney = 0;
//        [self updateRemindName];
//        [self updateInterest];
//    } else if (textField.tag == kMemoTag) {
//        self.loanModel.memo = @"";
//    } else if (textField.tag == kRateTag) {
//        self.loanModel.rate = 0;
//        [self updateInterest];
//    }
    
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
        
        if (textField == self.nameTextF) {
            
//            self.loanModel.lender = textField.text;
            self.reminderItem.borrowtarget = textField.text;
//            [self updateRemindName];
            
        } else if (textField == self.moneyTextF) {
            
            NSString *tmpMoneyStr = textField.text;
            tmpMoneyStr = [tmpMoneyStr ssj_reserveDecimalDigits:2 intDigits:9];
            textField.text = [NSString stringWithFormat:@"%@", tmpMoneyStr];
//            self.loanModel.jMoney = [tmpMoneyStr doubleValue];
            
//            [self updateRemindName];
//            [self updateInterest];
            
        } else if (textField == self.liLvTextF) {
            
//            self.loanModel.memo = textField.text;
            
        } else if (textField == self.memoTextF) {
            
            NSString *moneyStr = textField.text;
            if ([moneyStr doubleValue] > 100) {
                moneyStr = @"100.0";
                [CDAutoHideMessageHUD showMessage:@"收益率不能大于100％"];
            }
//            textField.text = [moneyStr ssj_reserveDecimalDigits:1 intDigits:0];
//            self.loanModel.rate = [textField.text doubleValue] * 0.01;
//            [self updateInterest];
            
        }
    }
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
                SSJFundingTypeSelectViewController *NewFundingVC = [[SSJFundingTypeSelectViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
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


- (SSJLoanFundAccountSelectionView *)jiXiMethodSelectionView {
    if (!_jiXiMethodSelectionView) {
        __weak typeof(self) weakSelf = self;
        NSArray *titleArr = @[@"一次性还本付息",@"每日付息，到期还本",@"每月付息，到期还本"];
        NSMutableArray *itemArr = [NSMutableArray array];
        for (NSString *title in titleArr) {
            SSJLoanFundAccountSelectionViewItem *item = [[SSJLoanFundAccountSelectionViewItem alloc] init];
            item.title = title;
            [itemArr addObject:item];
        }
        
        _jiXiMethodSelectionView = [[SSJLoanFundAccountSelectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 192)];
        
        _jiXiMethodSelectionView.title = @"派息方式";
        _jiXiMethodSelectionView.items = itemArr;
        _jiXiMethodSelectionView.shouldSelectAccountAction = ^BOOL(SSJLoanFundAccountSelectionView *view, NSUInteger index) {
            if (index <= view.items.count - 1) {
                SSJLoanFundAccountSelectionViewItem *item = [view.items objectAtIndex:index];
                weakSelf.model.interesttype = index;
                [weakSelf.tableView reloadData];
                return YES;
            } else {
                SSJPRINT(@"警告：selectedIndex大于数组范围");
                return NO;
            }
        };
    }
    return _jiXiMethodSelectionView;
}


- (SSJHomeDatePickerView *)borrowDateSelectionView {
    if (!_borrowDateSelectionView) {
        __weak typeof(self) wself = self;
        _borrowDateSelectionView = [[SSJHomeDatePickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        
        _borrowDateSelectionView.horuAndMinuBgViewBgColor = [UIColor clearColor];
        _borrowDateSelectionView.datePickerMode = SSJDatePickerModeDate;
        _borrowDateSelectionView.shouldConfirmBlock = ^BOOL(SSJHomeDatePickerView *view, NSDate *date) {
            //                                   return [wself validateBorrowDate:date];
            return [NSDate date];
        };
        _borrowDateSelectionView.confirmBlock = ^(SSJHomeDatePickerView *view) {
            
            //                                   wself.loanModel.borrowDate = view.date;
            
            if (wself.reminderItem.remindDate && [view.date compare:wself.reminderItem.remindDate] == NSOrderedDescending) {
                wself.reminderItem.remindDate = view.date;
            }
            
            [wself.tableView reloadData];
            
        };
    }
    return _borrowDateSelectionView;
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

- (SSJReminderItem *)reminderItem {
    if (!_reminderItem) {
        _reminderItem = [[SSJReminderItem alloc] init];
    }
    return _reminderItem;
}


- (UISwitch *)remindSwitch {
    if (!_remindSwitch) {
        _remindSwitch = [[UISwitch alloc] init];
        [_remindSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _remindSwitch;
}
@end
