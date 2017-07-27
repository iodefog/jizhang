//
//  SSJWishSaveAndWithdrawMoneyViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/24.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishWithdrawMoneyViewController.h"
#import "SSJWishProgressViewController.h"

#import "TPKeyboardAvoidingTableView.h"
#import "SSJHomeDatePickerView.h"
#import "SSJInviteCodeJoinSuccessView.h"

#import "SSJCreditCardEditeCell.h"
#import "SSJPersonalDetailUserSignatureCell.h"

#import "SSJWishChargeItem.h"
#import "SSJWishModel.h"

#import "SSJWishHelper.h"

static NSString *const kTitle1 = @"存钱";
static NSString *const kTitle2 = @"日期";
static NSString *const kTitle3 = @"备注";

static NSString *SSJWishWithdrawCellIdentifier = @"SSJWishWithdrawCellId";
static NSString *SSJWishWithdrawMemoId = @"SSJWishWithdrawMemoId";

@interface SSJWishWithdrawMoneyViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
    UITextField *_moneyInput;
}


@property (nonatomic, strong) NSArray *titleArr;
/**tableView*/
@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property(nonatomic, strong) SSJHomeDatePickerView *dateSelectView;

@property (nonatomic, strong) SSJPersonalDetailUserSignatureCellItem *sigItem;

@property (nonatomic, strong) SSJWishChargeItem *chargeItem;

@property (nonatomic, strong) UIView *saveFooterView;

@property (nonatomic, strong) UILabel *saveL;

@property (nonatomic, strong) UILabel *targetL;

/**金币*/
@property (nonatomic, strong) UIImageView *goldCoinsImageView;

/**存满后弹框*/
@property (nonatomic, strong) SSJInviteCodeJoinSuccessView *fillWishSuccessView;
@end

@implementation SSJWishWithdrawMoneyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"存钱";
    [self updateAppearanceTheme];
    [self initdata];
    [self.view addSubview:self.tableView];
}


- (void)initdata {
    self.chargeItem.remindDateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"];
    self.titleArr = @[@[kTitle1],@[kTitle2,kTitle3]];
}

#pragma mark - Theme
- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearanceTheme];
}

- (void)updateAppearanceTheme {
    [self.saveFooterView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    self.saveL.textColor = self.targetL.textColor = SSJ_MAIN_COLOR;
}

#pragma mark - Event
- (void)saveMoneyButtonClicked {
    if (!self.wishModel.wishId) return;
    if (!_moneyInput.text.length) {
        [CDAutoHideMessageHUD showMessage:@"请输入心愿金额"];
        return;
    }

    self.chargeItem.wishId = self.wishModel.wishId;
    self.chargeItem.money = _moneyInput.text;
    self.chargeItem.memo = self.sigItem.signature;
    @weakify(self);
    [SSJWishHelper saveWishChargeWithWishChargeModel:self.chargeItem type:SSJWishChargeBillTypeSave success:^{
        //金币动画
        [self goldCoinsAnim];
    } failure:^(NSError *error) {
        [CDAutoHideMessageHUD showMessage:@"操作失败"];
    }];
    
}

- (void)goldCoinsAnim {
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:1 animations:^{
        CGFloat aa = self.saveFooterView.height -
        weakSelf.goldCoinsImageView.height * (([weakSelf.wishModel.wishSaveMoney doubleValue] + [_moneyInput.text doubleValue]) / [weakSelf.wishModel.wishMoney doubleValue]);
        weakSelf.goldCoinsImageView.top = aa;
        //掉金币
    } completion:^(BOOL finished) {
        if (weakSelf.saveMoneyType == SSJSaveMoneyTypeNormal) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else if (weakSelf.saveMoneyType == SSJSaveMoneyTypeList) {
            //跳转到心愿进度页面并从堆栈中删除存钱页面
            SSJWishProgressViewController *progressVC = [[SSJWishProgressViewController alloc] init];
            progressVC.wishId = self.wishModel.wishId;
            [weakSelf.navigationController pushViewController:progressVC animated:YES];
            NSMutableArray *marr = [[NSMutableArray alloc]initWithArray:weakSelf.navigationController.viewControllers];
            for (UIViewController *vc in marr) {
                if ([vc isKindOfClass:[SSJWishWithdrawMoneyViewController class]]) {
                    [marr removeObject:vc];
                    break;
                }
            }
            weakSelf.navigationController.viewControllers = marr;
        }
        //显示完成心愿弹框
        if ([weakSelf.wishModel.wishSaveMoney doubleValue] + [_moneyInput.text doubleValue] >= [weakSelf.wishModel.wishMoney doubleValue]) {
            [self.fillWishSuccessView showWithDesc:@"心愿目标金额已达成～"];
        }
    }];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _moneyInput.clearsOnInsertion = YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (_moneyInput == textField) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = [text ssj_reserveDecimalDigits:2 intDigits:9];
        return NO;
    }
    return YES;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self.titleArr ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTitle3]) {
        return 100;
    } else {
        return 55;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return [[UIView alloc] init];
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 10;
    }
    return 0.1f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.titleArr ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTitle2]) {
        self.dateSelectView.date = [self.chargeItem.remindDateStr ssj_dateWithFormat:@"yyyy-MM-dd"];
        [self.dateSelectView show];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titleArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.titleArr ssj_safeObjectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJCreditCardEditeCell *newReminderCell = [tableView dequeueReusableCellWithIdentifier:SSJWishWithdrawCellIdentifier];
    NSString *title = [self.titleArr ssj_objectAtIndexPath:indexPath];
    
    newReminderCell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    
    if ([title isEqualToString:kTitle1]) {
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.cellTitle = title;
        newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入心愿金额" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        newReminderCell.textInput.text = self.chargeItem.money;
        newReminderCell.textInput.keyboardType = UIKeyboardTypeDecimalPad;
        _moneyInput = newReminderCell.textInput;
        newReminderCell.textInput.delegate = self;
        newReminderCell.textInput.tag = 100;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if ([title isEqualToString:kTitle2]) {
        newReminderCell.type = SSJCreditCardCellTypeDetail;
        newReminderCell.cellTitle = title;
        newReminderCell.cellDetail = self.chargeItem.remindDateStr;
        //        [self.chargeItem.remindDate formattedDateWithStyle:NSDateFormatterFullStyle];
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if ([title isEqualToString:kTitle3]) {
        SSJPersonalDetailUserSignatureCell *signatureCell = [tableView dequeueReusableCellWithIdentifier:SSJWishWithdrawMemoId forIndexPath:indexPath];
        self.sigItem = [SSJPersonalDetailUserSignatureCellItem itemWithSignatureLimit:20 signature:self.chargeItem.memo title:@"备注" placeholder:@"输入记账小目标，更有利于小目标实现20字"];
        signatureCell.cellItem = self.sigItem;
        return signatureCell;
    }
    return newReminderCell;
}

#pragma mark - Lazy
- (TPKeyboardAvoidingTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        _tableView.tableFooterView = self.saveFooterView;
        [_tableView registerClass:[SSJCreditCardEditeCell class] forCellReuseIdentifier:SSJWishWithdrawCellIdentifier];
        [_tableView registerClass:[SSJPersonalDetailUserSignatureCell class] forCellReuseIdentifier:SSJWishWithdrawMemoId];
    }
    return _tableView;
}


- (SSJHomeDatePickerView *)dateSelectView{
    if (!_dateSelectView) {
        _dateSelectView = [[SSJHomeDatePickerView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 360)];
        _dateSelectView.horuAndMinuBgViewBgColor = [UIColor clearColor];
        _dateSelectView.datePickerMode = SSJDatePickerModeDate;
        __weak typeof(self) weakSelf = self;
        _dateSelectView.shouldConfirmBlock = ^BOOL(SSJHomeDatePickerView *view, NSDate *selecteDate){
            if ([selecteDate isEarlierThan:[NSDate dateWithString:weakSelf.wishModel.startDate formatString:@"yyyy-MM-dd HH:mm:ss.SSS"]]) {
                [CDAutoHideMessageHUD showMessage:@"不能早于心愿开始日期哦"];
                return NO;
            }
            if ([selecteDate isLaterThan:[NSDate date]]) {
                [CDAutoHideMessageHUD showMessage:@"不能晚于当前日期哦"];
                return NO;
            }
            return YES;
        };
        _dateSelectView.confirmBlock = ^(SSJHomeDatePickerView *view){
            weakSelf.chargeItem.remindDateStr = [view.date formattedDateWithFormat:@"yyyy-MM-dd"];
            weakSelf.chargeItem.cbillDate = [view.date formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        };
    }
    return _dateSelectView;
}

- (UIView *)saveFooterView {
    if (_saveFooterView == nil) {
        _saveFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 400)];
        [_saveFooterView ssj_setBorderWidth:1];
        [_saveFooterView ssj_setBorderStyle:SSJBorderStyleBottom];

        [_saveFooterView addSubview:self.saveL];
        [_saveFooterView addSubview:self.targetL];
        
        UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [saveButton setBackgroundImage:[UIImage imageNamed:@"wish_withdraw_btn_image"] forState:UIControlStateNormal];
        saveButton.size = CGSizeMake(83, 83);
        saveButton.titleLabel.font = [UIFont ssj_pingFangMediumFontOfSize:24];
        [saveButton setTitle:@"投入" forState:UIControlStateNormal];
        [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(saveMoneyButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        saveButton.centerX = _saveFooterView.width * 0.5;
        saveButton.top = 70;
        [_saveFooterView addSubview:self.goldCoinsImageView];
        _saveFooterView.layer.masksToBounds = YES;
//        self.goldCoinsImageView.bottom = _saveFooterView.bottom + 50;
        self.goldCoinsImageView.top = _saveFooterView.bottom -
        self.goldCoinsImageView.height * ([self.wishModel.wishSaveMoney doubleValue] / [self.wishModel.wishMoney doubleValue]);
        [_saveFooterView addSubview:saveButton];
    }
    return _saveFooterView;
}


- (UIImageView *)goldCoinsImageView {
    if (!_goldCoinsImageView) {
        _goldCoinsImageView = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"wish_withdraw_gold_coins"];
        CGSize imageSize = image.size;
        _goldCoinsImageView.image = image;
        _goldCoinsImageView.size = CGSizeMake(SSJSCREENWITH, imageSize.height * SSJSCREENWITH / imageSize.width);
    }
    return _goldCoinsImageView;
}

- (UILabel *)saveL {
    if (!_saveL) {
        _saveL = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SSJSCREENWITH * 0.5 - 15, 30)];
        _saveL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _saveL.text = [NSString stringWithFormat:@"目标金额：%.2lf",[self.wishModel.wishMoney doubleValue]];
    }
    return _saveL;
}


- (UILabel *)targetL {
    if (!_targetL) {
        _targetL = [[UILabel alloc] initWithFrame:CGRectMake(SSJSCREENWITH * 0.5, 0, SSJSCREENWITH * 0.5 - 15, 30)];
        _targetL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _targetL.text = [NSString stringWithFormat:@"离实现心愿还有：%.2lf元",[self.wishModel.wishMoney doubleValue]-[self.wishModel.wishSaveMoney doubleValue]];
    }
    return _targetL;
}


- (SSJInviteCodeJoinSuccessView *)fillWishSuccessView {
    if (!_fillWishSuccessView) {
        _fillWishSuccessView = [[SSJInviteCodeJoinSuccessView alloc] initWithFrame:CGRectMake(0, 0, 280, 328)];
    }
    return _fillWishSuccessView;
}


- (SSJWishChargeItem *)chargeItem {
    if (!_chargeItem) {
        _chargeItem = [[SSJWishChargeItem alloc] init];
    }
    return _chargeItem;
}

@end
