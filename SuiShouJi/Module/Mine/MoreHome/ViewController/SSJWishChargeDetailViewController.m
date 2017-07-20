//
//  SSJWishChargeDetailViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/20.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishChargeDetailViewController.h"

#import "TPKeyboardAvoidingTableView.h"
#import "SSJHomeDatePickerView.h"

#import "SSJCreditCardEditeCell.h"
#import "SSJPersonalDetailUserSignatureCell.h"

#import "SSJWishChargeItem.h"

static NSString *const kTitle1 = @"存钱";
static NSString *const kTitle2 = @"日期";
static NSString *const kTitle3 = @"备注";
static NSInteger kWishSignatureLimit = 20;
static NSString *SSJWishChargeDetailCellIdentifier = @"SSJWishChargeDetailViewControllerCellId";
static NSString *SSJWishChargeDetailMemoId = @"SSJWishChargeDetailMemoId";

@interface SSJWishChargeDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
    UITextField *_moneyInput;
}

@property (nonatomic, strong) NSArray *titleArr;
/**tableView*/
@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property(nonatomic, strong) SSJHomeDatePickerView *dateSelectView;

@property (nonatomic, strong) UIView *saveFooterView;

/**model*/
@property (nonatomic, strong) SSJWishChargeItem *chargeItem;

@property (nonatomic, strong) SSJPersonalDetailUserSignatureCellItem *sigItem;
@end

@implementation SSJWishChargeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"心愿流水详情";
    self.titleArr = @[@[kTitle1],@[kTitle2,kTitle3]];
    [self.view addSubview:self.tableView];
    [self updateAppearanceTheme];
}

#pragma mark - Private
- (void)setUpNav {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"wish_charge_detail_delete"] style:UIBarButtonItemStylePlain target:self action:@selector(navRightClick)];
}

- (void)navRightClick {
//    if ([SSJLocalNotificationStore deleteReminderWithItem:self.item error:NULL]) {
//        if (self.deleteReminderAction) {
//            self.deleteReminderAction();
//        }
//        [CDAutoHideMessageHUD showMessage:@"删除成功"];
//        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
//        [self.navigationController popViewControllerAnimated:YES];
//    }else{
//        [CDAutoHideMessageHUD showMessage:@"删除失败"];
//        
//    };
}

- (void)initdata{
    // 如果是新建一套默认的数据
//    if (self.item == nil) {
//        self.item = [[SSJReminderItem alloc]init];
//        self.item.remindDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day hour:20 minute:0 second:0];
//        self.item.remindCycle = 0;
//        self.item.remindType = SSJReminderTypeNormal;
//    }
//    self.item.remindDate = [SSJLocalNotificationHelper calculateNexRemindDateWithStartDate:self.item.remindDate remindCycle:self.item.remindCycle remindAtEndOfMonth:self.item.remindAtTheEndOfMonth];
//    [self.tableView reloadData];
}

#pragma mark - Theme
- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearanceTheme];
}

- (void)updateAppearanceTheme {
    
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
    if (section == [self.tableView numberOfSections] - 1) {
        return self.saveFooterView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == [self.tableView numberOfSections] - 1) {
        return 80 ;
    }
    return 0.1f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSString *title = [self.titleArr ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTitle2]) {
        self.dateSelectView.date = self.chargeItem.remindDate;
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
    SSJCreditCardEditeCell *newReminderCell = [tableView dequeueReusableCellWithIdentifier:SSJWishChargeDetailCellIdentifier];
    NSString *title = [self.titleArr ssj_objectAtIndexPath:indexPath];

    newReminderCell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    
    if ([title isEqualToString:kTitle1]) {
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.cellTitle = title;
        newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入提醒名称" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        newReminderCell.textInput.text = self.chargeItem.amountStr;
        _moneyInput = newReminderCell.textInput;
        newReminderCell.textInput.delegate = self;
        newReminderCell.textInput.tag = 100;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if ([title isEqualToString:kTitle2]) {
        newReminderCell.type = SSJCreditCardCellTypeDetail;
        newReminderCell.cellTitle = title;
        newReminderCell.cellDetail = [self.chargeItem.remindDate formattedDateWithStyle:NSDateFormatterFullStyle];
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if ([title isEqualToString:kTitle3]) {
        SSJPersonalDetailUserSignatureCell *signatureCell = [tableView dequeueReusableCellWithIdentifier:SSJWishChargeDetailMemoId forIndexPath:indexPath];
        self.sigItem = [SSJPersonalDetailUserSignatureCellItem itemWithSignatureLimit:20 signature:@"" title:@"备注" placeholder:@"输入记账小目标，更有利于小目标实现20字"];
        signatureCell.cellItem = self.sigItem;
        return signatureCell;
    }
    return newReminderCell;
}

#pragma mark - UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
//    if (textField.tag == 100) {
//        self.item.remindName = textField.text;
//    }else if (textField.tag == 101){
//        self.item.remindMemo = textField.text;
//    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
//    if (textField.tag == 100) {
//        self.item.remindName = text;
//    }else if (textField.tag == 101){
//        self.item.remindMemo = text;
//    }
    
    return YES;
}

#pragma mark - Event
- (void)saveButtonClicked:(id)sender{
//    self.item.remindName = _nameInput.text;
//    self.item.remindMemo = _memoInput.text;
//    self.item.remindState = NO;
//    if ([self.item.remindDate isEarlierThan:self.item.minimumDate] && self.item.remindType == SSJReminderTypeBorrowing) {
//        [CDAutoHideMessageHUD showMessage:@"提醒日期不能晚于借贷的借款日期"];
//        return;
//    }
//    if (!self.item.remindName.length) {
//        [CDAutoHideMessageHUD showMessage:@"请输入提醒名称"];
//        return;
//    }
//    if (!self.item.remindId.length) {
//        self.item.remindId = SSJUUID();
//    }
//    
//    if (self.needToSave == YES) {
//        if (self.addNewReminderAction) {
//            self.addNewReminderAction(self.item);
//        }
//    } else {
//        self.item.remindState = YES;
//        if (self.addNewReminderAction) {
//            self.addNewReminderAction(self.item);
//        }
//    }
    
    if (self.sigItem.signature.length > kWishSignatureLimit) {
        [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"记账小目标最多只能输入%d个字", (int)kWishSignatureLimit]];
        return;
    }
//    [self.navigationController popViewControllerAnimated:YES];
    
}



#pragma mark - Lazy
- (TPKeyboardAvoidingTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        
        [_tableView registerClass:[SSJCreditCardEditeCell class] forCellReuseIdentifier:SSJWishChargeDetailCellIdentifier];
        [_tableView registerClass:[SSJPersonalDetailUserSignatureCell class] forCellReuseIdentifier:SSJWishChargeDetailMemoId];
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
            NSDate *remindDate = [NSDate dateWithYear:selecteDate.year month:selecteDate.month day:selecteDate.day hour:weakSelf.chargeItem.remindDate.hour minute:weakSelf.chargeItem.remindDate.minute second:weakSelf.chargeItem.remindDate.second];
            if ([remindDate isEarlierThan:[NSDate date]]) {
                [CDAutoHideMessageHUD showMessage:@"不能设置历史日期的提醒哦"];
                return NO;
            }
            return YES;
        };
        _dateSelectView.confirmBlock = ^(SSJHomeDatePickerView *view){
            if (view.date.day > 28) {
                [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"每月不一定都有30号哦，是否将无30号的月份提醒设置跳过？或自动将无30号的月份的提醒设置在每月最后一天？" action:[SSJAlertViewAction actionWithTitle:@"部分月份设在最后一天" handler:^(SSJAlertViewAction * _Nonnull action) {
                    weakSelf.chargeItem.remindAtTheEndOfMonth = 1;
                }],[SSJAlertViewAction actionWithTitle:@"自动跳过" handler:^(SSJAlertViewAction * _Nonnull action) {
                    weakSelf.chargeItem.remindAtTheEndOfMonth = 0;
                }],nil];
            }
            weakSelf.chargeItem.remindDate = [NSDate dateWithYear:view.date.year month:view.date.month day:view.date.day hour:weakSelf.chargeItem.remindDate.hour minute:weakSelf.chargeItem.remindDate.minute second:weakSelf.chargeItem.remindDate.second];
            [weakSelf initdata];
        };
    }
    return _dateSelectView;
}

- (UIView *)saveFooterView {
    if (_saveFooterView == nil) {
        _saveFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 80)];
        UIButton *saveButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, _saveFooterView.width - 20, 40)];
        [saveButton setTitle:@"保存" forState:UIControlStateNormal];
        saveButton.layer.cornerRadius = 3.f;
        saveButton.layer.masksToBounds = YES;
        [saveButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
        [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        saveButton.center = CGPointMake(_saveFooterView.width / 2, _saveFooterView.height / 2);
        [_saveFooterView addSubview:saveButton];
    }
    return _saveFooterView;
}


@end
