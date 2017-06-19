//
//  SSJFundingTransferViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/12.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingTransferViewController.h"
#import "SSJFundingItem.h"
#import "SSJFundingTypeSelectView.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJHomeDatePickerView.h"
#import "SSJFundingTransferPeriodSelectionView.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "SSJCreditCardItem.h"
#import "SSJChargeCircleModifyCell.h"
#import "SSJFundingTransferListViewController.h"
#import "SSJFundingTypeSelectViewController.h"
#import "FMDB.h"
#import "SSJFundingTransferStore.h"
#import "SSJAnaliyticsManager.h"

static NSString *const kTransOutAcctName = @"转出账户";
static NSString *const kTransInAcctName = @"转入账户";
static NSString *const kMoney = @"转账金额";
static NSString *const kMemo = @"备注";
static NSString *const kTransDate = @"转账日期";
static NSString *const kCyclePeriod = @"循环周期";
static NSString *const kBeginDate = @"周期起始日";
static NSString *const kEndDate = @"周期结束日";

static NSString *const kCreatePeriodTransferTimesKey = @"kCreatePeriodTransferTimesKey";

static NSString * SSJFundingTransferEditeCellIdentifier = @"SSJFundingTransferEditeCellIdentifier";

@interface SSJFundingTransferViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property (nonatomic,strong) UIBarButtonItem *transferRecordsButton;

@property (nonatomic,strong) UIBarButtonItem *deleteButtonItem;

@property (nonatomic,strong) SSJFundingTypeSelectView *transferInFundingTypeSelect;

@property (nonatomic,strong) SSJFundingTypeSelectView *transferOutFundingTypeSelect;

@property(nonatomic, strong) SSJHomeDatePickerView *transferDateSelectionView;

@property (nonatomic, strong) SSJFundingTransferPeriodSelectionView *periodSelectionView;

@property (nonatomic, strong) SSJHomeDatePickerView *beginDateSelectionView;

@property (nonatomic, strong) SSJHomeDatePickerView *endDateSelectionView;

@property (nonatomic, strong) UIView *saveFooterView;

@property (nonatomic, strong) UIButton *saveButton;

@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, strong) NSArray *images;

@property (nonatomic) BOOL alertShowed;

@end

@implementation SSJFundingTransferViewController{
    SSJBaseCellItem *_transferInItem;
    SSJBaseCellItem *_transferOutItem;
    UITextField *_moneyInput;
    UITextField *_memoInput;
}

#pragma mark - Lifecycle
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hideKeyboradWhenTouch = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transferTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [self.view addSubview:self.tableView];
    if (self.item) {
        _transferOutItem = [[SSJFundingItem alloc]init];
        _transferInItem = [[SSJFundingItem alloc]init];
        ((SSJFundingItem *)_transferInItem).fundingID = self.item.transferInId;
        ((SSJFundingItem *)_transferInItem).fundingIcon = self.item.transferInImage;
        ((SSJFundingItem *)_transferInItem).fundingName = self.item.transferInName;
        ((SSJFundingItem *)_transferOutItem).fundingID = self.item.transferOutId;
        ((SSJFundingItem *)_transferOutItem).fundingIcon = self.item.transferOutImage;
        ((SSJFundingItem *)_transferOutItem).fundingName = self.item.transferOutName;
        
        if (_item.cycleType == SSJCyclePeriodTypeOnce) {
            _item.beginDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"];
        } else {
            _item.transferDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"];
        }
        
        self.title = @"编辑转账";
        self.navigationItem.rightBarButtonItem = self.deleteButtonItem;
    }else{
        self.item = [[SSJFundingTransferDetailItem alloc] init];
        self.item.ID = SSJUUID();
        self.item.cycleType = SSJCyclePeriodTypeOnce;
        self.item.transferDate = self.item.beginDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"];
        
        self.title = @"转账";
        self.navigationItem.rightBarButtonItem = self.transferRecordsButton;
    }
    
    _alertShowed = [self shouldShowAlert];
    
    [self updateTitlesAndImages];
    [self.tableView registerClass:[SSJChargeCircleModifyCell class] forCellReuseIdentifier:SSJFundingTransferEditeCellIdentifier];
}

//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    if (self.item != nil) {
//        self.navigationItem.rightBarButtonItem = nil;
//    }else{
//    }
//}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return self.saveFooterView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return 80 ;
    }
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTransOutAcctName]) {
        if ([_transferOutItem isKindOfClass:[SSJFundingItem class]]) {
            self.transferOutFundingTypeSelect.selectFundID = ((SSJFundingItem *)_transferOutItem).fundingID;
        } else if ([_transferInItem isKindOfClass:[SSJCreditCardItem class]]) {
            self.transferOutFundingTypeSelect.selectFundID = ((SSJCreditCardItem *)_transferOutItem).cardId;
        }
        [self.transferOutFundingTypeSelect show];
    } else if ([title isEqualToString:kTransInAcctName]) {
        if ([_transferInItem isKindOfClass:[SSJFundingItem class]]) {
            self.transferInFundingTypeSelect.selectFundID = ((SSJFundingItem *)_transferInItem).fundingID;
        }else if ([_transferInItem isKindOfClass:[SSJCreditCardItem class]]) {
            self.transferInFundingTypeSelect.selectFundID = ((SSJCreditCardItem *)_transferInItem).cardId;
        }
        [self.transferInFundingTypeSelect show];
    } else if ([title isEqualToString:kTransDate]) {
        self.transferDateSelectionView.date = [NSDate dateWithString:self.item.transferDate formatString:@"yyyy-MM-dd"];
        [self.transferDateSelectionView show];
    } else if ([title isEqualToString:kCyclePeriod]) {
        [self.periodSelectionView show];
        [SSJAnaliyticsManager event:@"add_transfer_cycle"];
    } else if ([title isEqualToString:kBeginDate]) {
        self.beginDateSelectionView.date = [NSDate dateWithString:self.item.beginDate formatString:@"yyyy-MM-dd"];
        [self.beginDateSelectionView show];
    } else if ([title isEqualToString:kEndDate]) {
        self.endDateSelectionView.date = [NSDate dateWithString:(self.item.endDate ?: self.item.beginDate) formatString:@"yyyy-MM-dd"];
        [self.endDateSelectionView show];
        [SSJAnaliyticsManager event:@"add_transfer_end_date"];
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.titles[section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    NSString *image = [self.images ssj_objectAtIndexPath:indexPath];
    SSJChargeCircleModifyCell *circleModifyCell = [tableView dequeueReusableCellWithIdentifier:SSJFundingTransferEditeCellIdentifier];
    circleModifyCell.cellTitle = title;
    circleModifyCell.cellImageName = image;
    if ([title isEqualToString:kTransOutAcctName]) {
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        circleModifyCell.cellInput.hidden = YES;
        if (!_transferOutItem) {
            circleModifyCell.cellDetail = @"请选择转出账户";
        }else{
            if ([_transferOutItem isKindOfClass:[SSJFundingItem class]]) {
                circleModifyCell.cellDetail = ((SSJFundingItem *)_transferOutItem).fundingName;
                circleModifyCell.cellTypeImageName = ((SSJFundingItem *)_transferOutItem).fundingIcon;
            }else if ([_transferOutItem isKindOfClass:[SSJCreditCardItem class]]) {
                circleModifyCell.cellDetail = ((SSJCreditCardItem *)_transferOutItem).cardName;
                circleModifyCell.cellTypeImageName = @"ft_creditcard";
            }

        }
//        _moneyInput = circleModifyCell.cellInput;
    }else if ([title isEqualToString:kTransInAcctName]) {
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        circleModifyCell.cellInput.hidden = YES;
        if (!_transferInItem) {
            circleModifyCell.cellDetail = @"请选择转入账户";
        }else{
            if ([_transferInItem isKindOfClass:[SSJFundingItem class]]) {
                circleModifyCell.cellDetail = ((SSJFundingItem *)_transferInItem).fundingName;
                circleModifyCell.cellTypeImageName = ((SSJFundingItem *)_transferInItem).fundingIcon;
            }else if ([_transferInItem isKindOfClass:[SSJCreditCardItem class]]) {
                circleModifyCell.cellDetail = ((SSJCreditCardItem *)_transferInItem).cardName;
                circleModifyCell.cellTypeImageName = @"ft_creditcard";
            }
        }
    }else if ([title isEqualToString:kMoney]) {
        circleModifyCell.cellInput.hidden = NO;
        if (self.item.transferMoney.length) {
            circleModifyCell.cellInput.text = [NSString stringWithFormat:@"%.2f",[self.item.transferMoney doubleValue]];
        }
        circleModifyCell.cellInput.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        circleModifyCell.cellInput.keyboardType = UIKeyboardTypeDecimalPad;
        circleModifyCell.cellInput.delegate = self;
        circleModifyCell.cellInput.tag = 100;
        circleModifyCell.cellInput.clearButtonMode = UITextFieldViewModeNever;
        _moneyInput = circleModifyCell.cellInput;
    }else if ([title isEqualToString:kMemo]) {
        circleModifyCell.cellInput.hidden = NO;
        circleModifyCell.cellInput.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"15个字内(选填)" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        circleModifyCell.cellInput.text = self.item.transferMemo;
        circleModifyCell.cellInput.tag = 101;
        circleModifyCell.cellInput.delegate = self;
        circleModifyCell.cellInput.clearButtonMode = UITextFieldViewModeWhileEditing;
        _memoInput = circleModifyCell.cellInput;
    }else if ([title isEqualToString:kTransDate]) {
        circleModifyCell.cellInput.hidden = YES;
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        circleModifyCell.cellDetail = self.item.transferDate;
    }else if ([title isEqualToString:kCyclePeriod]) {
        circleModifyCell.cellInput.hidden = YES;
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        circleModifyCell.cellDetail = SSJTitleForCycleType(_item.cycleType);
    }else if ([title isEqualToString:kBeginDate]) {
        circleModifyCell.cellInput.hidden = YES;
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        circleModifyCell.cellDetail = self.item.beginDate;
    }else if ([title isEqualToString:kEndDate]) {
        circleModifyCell.cellInput.hidden = YES;
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        circleModifyCell.cellDetail = self.item.endDate ?: @"选填";
    }
    return circleModifyCell;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    if (textField == self.transferIntext || textField == self.transferOuttext) {
//        NSInteger existedLength = textField.text.length;
//        NSInteger selectedLength = range.length;
//        NSInteger replaceLength = string.length;
//        if (existedLength - selectedLength + replaceLength > 10) {
//            [CDAutoHideMessageHUD showMessage:@"金额不能超过10位"];
//            return NO;
//        }
//    }
    //mzl
//    if (textField.tag == 101) {
//        NSString *text = textField.text ? : @"";
//        text = [text stringByReplacingCharactersInRange:range withString:string];
//        if (text.length > 15) {
//            [CDAutoHideMessageHUD showMessage:@"最多只能输入15个字"];
//            return NO;
//        }
//    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag == 100) {
        self.item.transferMoney = textField.text;
    }else if (textField.tag == 101){
        self.item.transferMemo = textField.text;
    }
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Getter
-(UIBarButtonItem *)transferRecordsButton{
    if (!_transferRecordsButton) {
        _transferRecordsButton = [[UIBarButtonItem alloc]initWithTitle:@"转账记录" style:UIBarButtonItemStylePlain target:self action:@selector(transferRecordsButtonAction)];
    }
    return _transferRecordsButton;
}

- (UIBarButtonItem *)deleteButtonItem {
    if (!_deleteButtonItem) {
        _deleteButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteAction)];
    }
    return _deleteButtonItem;
}

-(SSJFundingTypeSelectView *)transferInFundingTypeSelect{
    if (!_transferInFundingTypeSelect) {
        __weak typeof(self) weakSelf = self;
        _transferInFundingTypeSelect = [[SSJFundingTypeSelectView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        if (self.item != nil) {
            _transferOutFundingTypeSelect.selectFundID = self.item.transferInId;
        }
        _transferInFundingTypeSelect.fundingTypeSelectBlock = ^(SSJFundingItem *fundingItem){
            if (![fundingItem.fundingName isEqualToString:@"添加资金新的账户"])
            {
                _transferInItem = fundingItem;
            }else{
                SSJFundingTypeSelectViewController *NewFundingVC = [[SSJFundingTypeSelectViewController alloc]init];
                NewFundingVC.needLoanOrNot = NO;
                NewFundingVC.addNewFundingBlock = ^(SSJBaseCellItem *item){
                    if ([item isKindOfClass:[SSJFundingItem class]]) {
                        SSJFundingItem *fundItem = (SSJFundingItem *)item;
                        _transferInItem = fundItem;
                    }else if ([item isKindOfClass:[SSJCreditCardItem class]]){
                        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
                        _transferInItem = cardItem;
                    }
                };
                [weakSelf.navigationController pushViewController:NewFundingVC animated:YES];
            }
            [weakSelf.tableView reloadData];
            [weakSelf.transferInFundingTypeSelect dismiss];
        };
    }
    return _transferInFundingTypeSelect;
}

-(SSJFundingTypeSelectView *)transferOutFundingTypeSelect{
    if (!_transferOutFundingTypeSelect) {
        __weak typeof(self) weakSelf = self;
        _transferOutFundingTypeSelect = [[SSJFundingTypeSelectView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        if (self.item != nil) {
            _transferOutFundingTypeSelect.selectFundID = self.item.transferOutId;
        }
        _transferOutFundingTypeSelect.fundingTypeSelectBlock = ^(SSJFundingItem *fundingItem){
            if (![fundingItem.fundingName isEqualToString:@"添加资金新的账户"])
            {
                _transferOutItem = fundingItem;
            }else{
                SSJFundingTypeSelectViewController *NewFundingVC = [[SSJFundingTypeSelectViewController alloc]init];
                NewFundingVC.needLoanOrNot = NO;
                NewFundingVC.addNewFundingBlock = ^(SSJBaseCellItem *item){
                    if ([item isKindOfClass:[SSJFundingItem class]]) {
                        SSJFundingItem *fundItem = (SSJFundingItem *)item;
                        _transferOutItem = fundItem;
                    }else if ([item isKindOfClass:[SSJCreditCardItem class]]){
                        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
                        _transferOutItem = cardItem;
                    }
                };
                [weakSelf.navigationController pushViewController:NewFundingVC animated:YES];
            }
            [weakSelf.tableView reloadData];
            [weakSelf.transferOutFundingTypeSelect dismiss];
        };
    }
    return _transferOutFundingTypeSelect;
}

-(TPKeyboardAvoidingTableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[TPKeyboardAvoidingTableView alloc]initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    }
    return _tableView;
}

-(UIView *)saveFooterView{
    if (_saveFooterView == nil) {
        _saveFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 80)];
        self.saveButton.center = CGPointMake(_saveFooterView.width / 2, _saveFooterView.height / 2);
        [_saveFooterView addSubview:self.saveButton];
    }
    return _saveFooterView;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, _saveFooterView.width - 20, 40)];
        _saveButton.layer.cornerRadius = 3.f;
        _saveButton.layer.masksToBounds = YES;
        [_saveButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
        [_saveButton ssj_setBackgroundColor:[[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
        [_saveButton setTitle:nil forState:UIControlStateDisabled];
        [_saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_saveButton addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

-(SSJHomeDatePickerView *)transferDateSelectionView{
    if (!_transferDateSelectionView) {
        _transferDateSelectionView = [[SSJHomeDatePickerView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        _transferDateSelectionView.horuAndMinuBgViewBgColor = [UIColor clearColor];
        _transferDateSelectionView.datePickerMode = SSJDatePickerModeDate;
        _transferDateSelectionView.shouldConfirmBlock = ^(SSJHomeDatePickerView *view, NSDate *selecteDate) {
            NSDate *currentDate = [NSDate date];
            currentDate = [NSDate dateWithYear:currentDate.year month:currentDate.month day:currentDate.day];
            if ([selecteDate compare:currentDate] == NSOrderedDescending) {
                [CDAutoHideMessageHUD showMessage:@"转账时间不能大于当前时间哦"];
                return NO;
            }
            return YES;
        };
        __weak typeof(self) weakSelf = self;
        _transferDateSelectionView.confirmBlock = ^(SSJHomeDatePickerView *view) {
            weakSelf.item.transferDate = [view.date formattedDateWithFormat:@"yyyy-MM-dd"];;
            [weakSelf.tableView reloadData];
        };
    }
    return _transferDateSelectionView;
}

- (SSJFundingTransferPeriodSelectionView *)periodSelectionView {
    if (!_periodSelectionView) {
        _periodSelectionView = [[SSJFundingTransferPeriodSelectionView alloc] init];
        _periodSelectionView.selectedType = _item.cycleType;
        [_periodSelectionView addTarget:self action:@selector(periodSelectionViewAction) forControlEvents:UIControlEventValueChanged];
    }
    return _periodSelectionView;
}

- (SSJHomeDatePickerView *)beginDateSelectionView {
    if (!_beginDateSelectionView) {
        __weak typeof(self) wself = self;
        _beginDateSelectionView = [[SSJHomeDatePickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        _beginDateSelectionView.horuAndMinuBgViewBgColor = [UIColor clearColor];;
        _beginDateSelectionView.datePickerMode = SSJDatePickerModeDate;
        _beginDateSelectionView.shouldConfirmBlock = ^BOOL(SSJHomeDatePickerView *view, NSDate *date) {
            NSDate *currentDate = [NSDate date];
            currentDate = [NSDate dateWithYear:currentDate.year month:currentDate.month day:currentDate.day];
            if ([date compare:currentDate] == NSOrderedAscending) {
                [CDAutoHideMessageHUD showMessage:@"起始日期不能早于今天哦"];
                return NO;
            }
            NSDate *endDate = [NSDate dateWithString:wself.item.endDate formatString:@"yyyy-MM-dd"];
            if ([date compare:endDate] == NSOrderedDescending) {
                [CDAutoHideMessageHUD showMessage:@"起始日期不能晚于结束日期哦"];
                return NO;
            }
            return YES;
        };
        _beginDateSelectionView.confirmBlock = ^(SSJHomeDatePickerView *view) {
            wself.item.beginDate = [view.date formattedDateWithFormat:@"yyyy-MM-dd"];
            [wself.tableView reloadData];
        };
    }
    return _beginDateSelectionView;
}

- (SSJHomeDatePickerView *)endDateSelectionView {
    if (!_endDateSelectionView) {
        __weak typeof(self) weakSelf = self;
        _endDateSelectionView = [[SSJHomeDatePickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        _endDateSelectionView.horuAndMinuBgViewBgColor = [UIColor clearColor];;
        _endDateSelectionView.datePickerMode = SSJDatePickerModeDate;
        _endDateSelectionView.leftButtonItem = [SSJHomeDatePickerViewButtonItem buttonItemWithTitle:@"清空" titleColor:[UIColor ssj_colorWithHex:SSJOverrunRedColorValue] image:nil];
        _endDateSelectionView.shouldConfirmBlock = ^BOOL(SSJHomeDatePickerView *view, NSDate *date) {
            NSDate *beginDate = [NSDate dateWithString:weakSelf.item.beginDate formatString:@"yyyy-MM-dd"];
            if ([date compare:beginDate] == NSOrderedAscending) {
                [CDAutoHideMessageHUD showMessage:@"结束日期不能早于起始日期哦"];
                return NO;
            }
            return YES;
        };
        _endDateSelectionView.confirmBlock = ^(SSJHomeDatePickerView *view) {
            weakSelf.item.endDate = [view.date formattedDateWithFormat:@"yyyy-MM-dd"];
            [weakSelf.tableView reloadData];
        };
        _endDateSelectionView.closeBlock = ^(SSJHomeDatePickerView *view) {
            weakSelf.item.endDate = nil;
            [weakSelf.tableView reloadData];
        };
    }
    return _endDateSelectionView;
}

#pragma mark - Event
- (void)transferRecordsButtonAction {
    SSJFundingTransferListViewController *transferDetailVc = [[SSJFundingTransferListViewController alloc]init];
    [self.navigationController pushViewController:transferDetailVc animated:YES];
}

- (void)deleteAction {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"确定删除该项记录?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SSJFundingTransferStore deleteCycleTransferRecordWithID:_item.ID success:^{
            [self.navigationController popViewControllerAnimated:YES];
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        } failure:NULL];
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

-(void)saveButtonClicked:(id)sender{
    if (_transferInItem == nil || _transferInItem == nil) {
        [CDAutoHideMessageHUD showMessage:@"请选择资金账户"];
        return;
    }
    __block NSString *transferInId;
    __block NSString *transferOutId;
    __block NSString *transferInName;
    __block NSString *transferOutName;
    if ([_transferInItem isKindOfClass:[SSJFundingItem class]]) {
        transferInId = ((SSJFundingItem *)_transferInItem).fundingID;
        transferInName = ((SSJFundingItem *)_transferInItem).fundingName;
    }else{
        transferInId = ((SSJCreditCardItem *)_transferInItem).cardId;
        transferInName = ((SSJCreditCardItem *)_transferInItem).cardName;
    }
    if ([_transferOutItem isKindOfClass:[SSJFundingItem class]]) {
        transferOutId = ((SSJFundingItem *)_transferOutItem).fundingID;
        transferOutName = ((SSJFundingItem *)_transferOutItem).fundingName
        ;
    }else{
        transferOutId = ((SSJCreditCardItem *)_transferOutItem).cardId;
        transferOutName = ((SSJCreditCardItem *)_transferOutItem).cardName;
    }
    if ([transferInId isEqualToString:transferOutId]) {
        [CDAutoHideMessageHUD showMessage:@"请选择不同账户"];
        return;
    }else if ([_moneyInput.text doubleValue] == 0 || [_moneyInput.text isEqualToString:@""]) {
        [CDAutoHideMessageHUD showMessage:@"请输入金额"];
        return;
    }else if (_memoInput.text.length > 15){
        [CDAutoHideMessageHUD showMessage:@"备注最多输入15个字哦"];
        return;
    }
    
    [self.view endEditing:YES];
    if (!_alertShowed && [self shouldShowAlert]) {
        NSDate *date = [NSDate dateWithString:_item.beginDate formatString:@"yyyy-MM-dd"];
        NSString *message = [NSString stringWithFormat:@"每月不一定都有%ld号哦，没有的月份将自动跳过不生成该转账记录哦！", (long)date.day];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self saveWithTransInAcctId:transferInId transOutAcctId:transferOutId];
        }]];
        [self presentViewController:alert animated:YES completion:NULL];
    } else {
        [self saveWithTransInAcctId:transferInId transOutAcctId:transferOutId];
    }
}

- (void)periodSelectionViewAction {
    _item.cycleType = self.periodSelectionView.selectedType;
    [self updateTitlesAndImages];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Private
- (void)updateTitlesAndImages {
    if (_item.cycleType == SSJCyclePeriodTypeOnce) {
        self.titles = @[@[kTransOutAcctName, kTransInAcctName], @[kMoney, kMemo], @[kCyclePeriod, kTransDate]];
        self.images = @[@[@"founds_zhuanchuzhanghu", @"founds_zhuanruzhanghu"], @[@"loan_money", @"loan_memo"], @[@"xuhuan_xuhuan", @"loan_calendar"]];
    } else {
        self.titles = @[@[kTransOutAcctName, kTransInAcctName], @[kMoney, kMemo], @[kCyclePeriod, kBeginDate, kEndDate]];
        self.images = @[@[@"founds_zhuanchuzhanghu", @"founds_zhuanruzhanghu"], @[@"loan_money", @"loan_memo"], @[@"xuhuan_xuhuan", @"loan_calendar", @"xunhuan_end"]];
    }
}

- (void)transferTextDidChange:(NSNotification *)notification {
    if (notification.object == _moneyInput) {
        _moneyInput.text = [_moneyInput.text ssj_reserveDecimalDigits:2 intDigits:9];
        _item.transferMoney = _moneyInput.text;
    } else if (notification.object == _memoInput) {
        _item.transferMemo = _memoInput.text;
    }
}

//-(void)transferTextDidChange{
//    [self setupTextFiledNum:self.transferIntext num:2];
//    [self setupTextFiledNum:self.transferOuttext num:2];
//    if ([self.transferIntext isFirstResponder]) {
//        if (![self.transferIntext.text hasPrefix:@"¥"]&&![self.transferIntext.text isEqualToString:@""]) {
//            self.transferIntext.text = [NSString stringWithFormat:@"¥%@",self.transferIntext.text];
//        }else if ([self.transferIntext.text isEqualToString:@"¥"]){
//            self.transferIntext.text = @"";
//        }
//        self.transferOuttext.text = self.transferIntext.text;
//    }else{
//        if (![self.transferOuttext.text hasPrefix:@"¥"]&&![self.transferIntext.text isEqualToString:@""]) {
//            self.transferOuttext.text = [NSString stringWithFormat:@"¥%@",self.transferOuttext.text];
//        }else if ([self.transferOuttext.text isEqualToString:@"¥"]){
//            self.transferOuttext.text = @"";
//        }
//        self.transferIntext.text = self.transferOuttext.text;
//    }
//}

//-(void)transferOutButtonClicked:(id)sender{
//    [self.transferIntext resignFirstResponder];
//    [self.transferOuttext resignFirstResponder];
//    [self.transferOutFundingTypeSelect show];
//}
//
//-(void)transferInButtonClicked:(id)sender{
//    [self.transferIntext resignFirstResponder];
//    [self.transferOuttext resignFirstResponder];
//    [self.transferInFundingTypeSelect show];
//}


///**
// *   限制输入框小数点(输入框只改变时候调用valueChange)
// *
// *  @param TF  输入框
// *  @param num 小数点后限制位数
// */
//-(void)setupTextFiledNum:(UITextField *)TF num:(int)num
//{
//    NSString *str = [TF.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
//    NSArray *arr = [TF.text componentsSeparatedByString:@"."];
//    if ([str isEqualToString:@"0."] || [str isEqualToString:@"."]) {
//        TF.text = @"0.";
//    }else if (str.length == 2) {
//        if ([str floatValue] == 0) {
//            TF.text = @"0";
//        }else if(arr.count < 2){
//            TF.text = [NSString stringWithFormat:@"%d",[str intValue]];
//        }
//    }
//    
//    if (arr.count > 2) {
//        TF.text = [NSString stringWithFormat:@"%@.%@",arr[0],arr[1]];
//    }
//    
//    if (arr.count == 2) {
//        NSString * lastStr = arr.lastObject;
//        if (lastStr.length > num) {
//            TF.text = [NSString stringWithFormat:@"%@.%@",arr[0],[lastStr substringToIndex:num]];
//        }
//    }
//}

- (BOOL)isFirstTimeCreate {
    NSInteger times = [[NSUserDefaults standardUserDefaults] integerForKey:kCreatePeriodTransferTimesKey];
    return times == 0;
}

- (void)addCreateTiems {
    NSInteger times = [[NSUserDefaults standardUserDefaults] integerForKey:kCreatePeriodTransferTimesKey];
    [[NSUserDefaults standardUserDefaults] setInteger:++times forKey:kCreatePeriodTransferTimesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)showFirstTimeCreateAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"创建成功，修改或查看设置的周期转账可在”转账记录---周期转账“里查看哦！" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

- (void)saveWithTransInAcctId:(NSString *)transInAcctId transOutAcctId:(NSString *)transOutAcctId {
    _saveButton.enabled = NO;
    [_saveButton ssj_showLoadingIndicator];
    NSString *dateStr = _item.cycleType == SSJCyclePeriodTypeOnce ? _item.transferDate : _item.beginDate;
    [SSJFundingTransferStore saveCycleTransferRecordWithID:_item.ID transferInAccountId:transInAcctId transferOutAccountId:transOutAcctId money:[_item.transferMoney doubleValue] memo:_item.transferMemo cyclePeriodType:_item.cycleType beginDate:dateStr endDate:_item.endDate success:^(BOOL isExisted) {
        
        _saveButton.enabled = YES;
        [_saveButton ssj_hideLoadingIndicator];
        
        if ([self isFirstTimeCreate] && _item.cycleType != SSJCyclePeriodTypeOnce) {
            [self addCreateTiems];
            [self showFirstTimeCreateAlert];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        
    } failure:^(NSError * _Nonnull error) {
        _saveButton.enabled = YES;
        [_saveButton ssj_hideLoadingIndicator];
    }];
}

- (BOOL)shouldShowAlert {
    NSDate *date = [NSDate dateWithString:_item.beginDate formatString:@"yyyy-MM-dd"];
    return _item.cycleType == SSJCyclePeriodTypePerMonth && (date.day == 29 || date.day == 30 || date.day == 31);
}

@end
