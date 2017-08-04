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
#import "SSJWishModel.h"

#import "SSJWishHelper.h"
#import "SSJDataSynchronizer.h"


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

//@property (nonatomic, assign) SSJWishChargeBillType billType;

@property (nonatomic, strong) SSJPersonalDetailUserSignatureCellItem *sigItem;
@end

@implementation SSJWishChargeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"心愿流水详情";
    [self updateAppearanceTheme];
    [self initdata];
    [self.view addSubview:self.tableView];
    [self setUpNav];
}

#pragma mark - Private
- (void)setUpNav {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"wish_charge_detail_delete"] style:UIBarButtonItemStylePlain target:self action:@selector(navRightClick)];
}

- (void)navRightClick {
    [SSJWishHelper deleteWishChargeWithWishChargeItem:self.chargeItem success:^{
        [CDAutoHideMessageHUD showMessage:@"删除成功"];
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        [self.navigationController popViewControllerAnimated:YES];

    } failure:^(NSError *error) {
        [CDAutoHideMessageHUD showMessage:@"删除失败"];
    }];
}

- (void)initdata {
    // 如果是新建一套默认的数据
    //    if (!self.chargeItem.chargeId.length) {
    //        self.chargeItem = [[SSJWishChargeItem alloc] init];
    //        self.chargeItem.cbillDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    //        self.titleArr = @[@[kTitle0],@[kTitle2,kTitle3]];
    //        self.chargeItem.itype = SSJWishChargeBillTypeWithdraw;//取钱
    //        self.chargeItem.wishId = self.wishModel.wishId;
    //    } else {
    self.titleArr = @[@[kTitle1],@[kTitle2,kTitle3]];
    self.chargeItem.itype = SSJWishChargeBillTypeSave;//存钱
    //    }
}

#pragma mark - Theme
- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearanceTheme];
}

- (void)updateAppearanceTheme {
    
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
    if (section == [self.tableView numberOfSections] - 1) {
        return self.saveFooterView;
    } else if (section == 0) {
        return [[UIView alloc] init];
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == [self.tableView numberOfSections] - 1) {
        return 80 ;
    } else if (section == 0) {
        return 10;
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
        newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入心愿金额" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        newReminderCell.textInput.text = self.chargeItem.money;
        _moneyInput = newReminderCell.textInput;
        newReminderCell.textInput.keyboardType = UIKeyboardTypeDecimalPad;
        newReminderCell.textInput.delegate = self;
        newReminderCell.textInput.tag = 100;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if ([title isEqualToString:kTitle2]) {
        newReminderCell.type = SSJCreditCardCellTypeDetail;
        newReminderCell.cellTitle = title;
        newReminderCell.cellDetail = [self.chargeItem.cbillDate ssj_dateStringFromFormat:@"yyyy-MM-dd HH:mm:ss.SSS" toFormat:@"yyyy-MM-dd"];
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
        newReminderCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if ([title isEqualToString:kTitle3]) {
        SSJPersonalDetailUserSignatureCell *signatureCell = [tableView dequeueReusableCellWithIdentifier:SSJWishChargeDetailMemoId forIndexPath:indexPath];
        self.sigItem = [SSJPersonalDetailUserSignatureCellItem itemWithSignatureLimit:kWishSignatureLimit signature:self.chargeItem.memo title:@"备注" placeholder:@"输入记账小目标，更有利于小目标实现20字"];
        signatureCell.cellItem = self.sigItem;
        return signatureCell;
    }
    return newReminderCell;
}


#pragma mark - Event
- (void)saveWishCharge:(UIButton *)btn {
    if (!_moneyInput.text.length) {
        [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"请输入心愿金额"]];
        return;
    }
    if (self.sigItem.signature.length > kWishSignatureLimit) {
        [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"记账小目标最多只能输入%d个字", (int)kWishSignatureLimit]];
        return;
    }
    double money = [_moneyInput.text doubleValue];
    self.chargeItem.money = [NSString stringWithFormat:@"%.2lf",money];
    self.chargeItem.memo = self.sigItem.signature;
    //取钱，修改
    @weakify(self);
    [SSJWishHelper saveWishChargeWithWishChargeModel:self.chargeItem type:self.chargeItem.itype success:^{
        @strongify(self);
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    }];
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
            
            NSString *finalDateStr = [weakSelf.wishModel.startDate ssj_dateStringFromFormat:@"yyyy-MM-dd HH:mm:ss.SSS" toFormat:@"yyyy-MM-dd"];
            NSDate *finalDate = [NSDate dateWithString:finalDateStr formatString:@"yyyy-MM-dd"];
            if ([selecteDate isEarlierThan:finalDate]) {
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
            weakSelf.chargeItem.cbillDate = [view.date formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
        saveButton.center = CGPointMake(_saveFooterView.width / 2, _saveFooterView.height / 2);
        [saveButton addTarget:self action:@selector(saveWishCharge:) forControlEvents:UIControlEventTouchUpInside];
        [_saveFooterView addSubview:saveButton];
    }
    return _saveFooterView;
}



@end
