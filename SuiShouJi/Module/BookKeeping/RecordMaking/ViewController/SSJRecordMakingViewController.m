//
//  SSJRecordMakingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/16.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingViewController.h"
#import "SSJNavigationController.h"
#import "SSJADDNewTypeViewController.h"
#import "SSJSegmentedControl.h"
#import "SSJSmallCalendarView.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "SSJChargeCircleSelectView.h"
#import "SSJCategoryListHelper.h"
#import "SSJImaageBrowseViewController.h"
#import "SSJMemberSelectView.h"
#import "SSJMemberManagerViewController.h"
#import "SSJNewMemberViewController.h"
#import "SSJFundingTypeSelectViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "SSJBooksEditeOrNewViewController.h"
#import "SSJCustomKeyboard.h"
#import "SSJCalendarView.h"
//#import "SSJDateSelectedView.h"
#import "SSJFundingTypeSelectView.h"
#import "SSJRecordMakingBillTypeInputView.h"
#import "SSJRecordMakingBillTypeSelectionView.h"
#import "SSJRecordMakingBillTypeInputAccessoryView.h"
#import "SSJRecordMakingCustomNavigationBar.h"
#import "SSJBooksParentSelectView.h"
#import "SSJRecordMakingBillTypeSelectionCellItem.h"
#import "SSJChargeMemBerItem.h"
#import "YYKeyboardManager.h"
#import "SSJRecordMakingStore.h"
#import "SSJBooksTypeStore.h"
#import "SSJCreditCardItem.h"
#import "SSJHomeDatePickerView.h"
#define INPUT_DEFAULT_COLOR [UIColor ssj_colorWithHex:@"#dddddd"]

static const NSTimeInterval kAnimationDuration = 0.25;

static NSString *const kIsEverEnteredKey = @"kIsEverEnteredKey";

static NSString *const kIsAlertViewShowedKey = @"kIsAlertViewShowedKey";

@interface SSJRecordMakingViewController () <UIScrollViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, YYKeyboardObserver>

@property (nonatomic, strong) SSJRecordMakingCustomNavigationBar *customNaviBar;

@property (nonatomic,strong) UIImage *selectedImage;

@property (nonatomic,strong) SSJHomeDatePickerView *dateSelectedView;

@property (nonatomic,strong) SSJFundingTypeSelectView *FundingTypeSelectView;

@property(nonatomic, strong) SSJMemberSelectView *memberSelectView;

@property (nonatomic) NSInteger selectChargeCircleType;

@property (nonatomic,strong) NSString *chargeMemo;

@property (nonatomic,strong) NSString *categoryID;

@property (nonatomic, strong) SSJRecordMakingBillTypeInputView *billTypeInputView;

@property (nonatomic, strong) SSJRecordMakingBillTypeSelectionView *paymentTypeView;

@property (nonatomic, strong) SSJRecordMakingBillTypeSelectionView *incomeTypeView;

@property (nonatomic, strong) SSJRecordMakingBillTypeInputAccessoryView *accessoryView;

@property (nonatomic, strong) SSJBooksParentSelectView *parentSelectView;

@property (nonatomic, strong) UIImageView *guideView;

@property (nonatomic, strong) UITextField *currentInput;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic) NSInteger lastSelectedIndex;

@property (nonatomic, strong) NSArray *booksIds;

@property (nonatomic) long currentYear;
@property (nonatomic) long currentMonth;
@property (nonatomic) long currentDay;
@end

@implementation SSJRecordMakingViewController{
    BOOL _needToDismiss;
}
#pragma mark - Lifecycle
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.statisticsTitle = @"记一笔";
        self.hidesBottomBarWhenPushed = YES;
        self.hidesNavigationBarWhenPushed = YES;
        [[YYKeyboardManager defaultManager] addObserver:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _needToDismiss = YES;
    
    if (!self.item) {
        self.item = [[SSJBillingChargeCellItem alloc] init];
    }
    
    // 如果没有账本id就传当前账本（从首页进入没有传账本id）
    if (!self.item.booksId) {
        self.item.booksId = SSJGetCurrentBooksType();
    }
    
    [self initData];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.customNaviBar];
    [self.view addSubview:self.billTypeInputView];
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.accessoryView];
    [self.scrollView addSubview:self.paymentTypeView];
    [self.scrollView addSubview:self.incomeTypeView];
    
    if (self.item.ID.length && self.item.incomeOrExpence == 0) {
        _lastSelectedIndex = 1;
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.width, 0)];
        self.customNaviBar.selectedBillType = SSJBillTypeIncome;
    }
    
    [self updateNavigationRightItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadCategoryAndBooksList];
    [self reloadMenberItems];
    if (![self showGuideViewIfNeeded]) {
        [self.FundingTypeSelectView dismiss];
        //        [self.dateSelectedView dismiss];
        if (_needToDismiss) {
            [self.memberSelectView dismiss];
            [self.billTypeInputView.moneyInput becomeFirstResponder];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_billTypeInputView.moneyInput resignFirstResponder];
    [_accessoryView.memoView resignFirstResponder];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _scrollView.contentSize = CGSizeMake(self.view.width * 2, self.view.height - self.billTypeInputView.bottom);
    _paymentTypeView.height = _incomeTypeView.height = _scrollView.height = self.view.height - self.billTypeInputView.bottom;
}

#pragma mark - Getter
- (SSJRecordMakingCustomNavigationBar *)customNaviBar {
    if (!_customNaviBar) {
        __weak typeof(self) wself = self;
        _customNaviBar = [[SSJRecordMakingCustomNavigationBar alloc] init];
        _customNaviBar.titles = @[@"test1", @"test2"];
        _customNaviBar.selectBookHandle = ^(SSJRecordMakingCustomNavigationBar *naviBar) {
            [SSJAnaliyticsManager event:@"addRecord_changeBooks"];//记一笔-切换账本
            wself.item.booksId = [wself.booksIds ssj_safeObjectAtIndex:naviBar.selectedTitleIndex];
            [wself.currentInput becomeFirstResponder];
            [wself loadCategoryAndBooksList];
        };
        _customNaviBar.addNewBookHandle = ^(SSJRecordMakingCustomNavigationBar *naviBar) {
            [self.view endEditing:YES];
            [wself.parentSelectView show];
        };
        _customNaviBar.selectBillTypeHandle = ^(SSJRecordMakingCustomNavigationBar *naviBar) {
            [wself segmentPressed];
        };
        _customNaviBar.backOffHandle = ^(SSJRecordMakingCustomNavigationBar *naviBar) {
            [wself goBackAction];
        };
        _customNaviBar.managementHandle = ^(SSJRecordMakingCustomNavigationBar *naviBar) {
            [wself managerItemAction];
        };
    }
    return _customNaviBar;
}

- (SSJHomeDatePickerView *)dateSelectedView {
    if (!_dateSelectedView) {
        _dateSelectedView = [[SSJHomeDatePickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 288)];
        _dateSelectedView.horuAndMinuBgViewBgColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainFillColor alpha:1];
        _dateSelectedView.datePickerMode = SSJDatePickerModeYearDateAndTime;
        _dateSelectedView.warningDate = [NSDate date];
        _dateSelectedView.maxDate = [NSDate date];
        __weak typeof(self) weakSelf = self;
        _dateSelectedView.shouldConfirmBlock = ^BOOL(SSJHomeDatePickerView *view, NSDate *selecteDate) {
            if ([[NSDate date] compare:selecteDate] == NSOrderedAscending) {
                [CDAutoHideMessageHUD showMessage:@"不能记未来日期的账哦"];
                return NO;
            }
            return YES;
        };
        _dateSelectedView.confirmBlock = ^(SSJHomeDatePickerView *view) {
            NSDate *currentDetailDate = [NSDate dateWithString:weakSelf.item.billDetailDate formatString:@"HH:mm"];
            if (view.date.hour != currentDetailDate.hour || view.date.minute != currentDetailDate.minute) {
                [SSJAnaliyticsManager event:@"add_record_time_select"];
            }
            weakSelf.selectedDay = view.date.day;
            weakSelf.selectedMonth = view.date.month;
            weakSelf.selectedYear = view.date.year;
            weakSelf.item.billDate = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",(long)view.date.year,(long)view.date.month,(long)view.date.day];
            weakSelf.item.billDetailDate = [NSString stringWithFormat:@"%02ld:%02ld",(long)view.date.hour,(long)view.date.minute];
            [weakSelf.accessoryView.dateBtn setTitle:[NSString stringWithFormat:@"%ld月%ld日", weakSelf.selectedMonth, weakSelf.selectedDay] forState:SSJButtonStateNormal];
            [weakSelf.dateSelectedView dismiss];
        };
        _dateSelectedView.dismissBlock = ^(SSJHomeDatePickerView *view) {
            [weakSelf.billTypeInputView.moneyInput becomeFirstResponder];
        };
    }
    return _dateSelectedView;
}

-(SSJFundingTypeSelectView *)FundingTypeSelectView{
    if (!_FundingTypeSelectView) {
        __weak typeof(self) weakSelf = self;
        _FundingTypeSelectView = [[SSJFundingTypeSelectView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _FundingTypeSelectView.fundingTypeSelectBlock = ^(SSJFundingItem *fundingItem){
            if (![fundingItem.fundingName isEqualToString:@"添加资金新的账户"]) {
                weakSelf.item.fundId = fundingItem.fundingID;
                weakSelf.item.fundName = fundingItem.fundingName;
                weakSelf.item.fundOperatorType = 1;
                [weakSelf updateFundingType];
            }else{
                SSJFundingTypeSelectViewController *NewFundingVC = [[SSJFundingTypeSelectViewController alloc]init];
                NewFundingVC.needLoanOrNot = NO;
                NewFundingVC.addNewFundingBlock = ^(SSJBaseItem *item){
                    if ([item isKindOfClass:[SSJFundingItem class]]) {
                        SSJFundingItem *fundItem = (SSJFundingItem *)item;
                        [weakSelf.FundingTypeSelectView reloadDate];
                        weakSelf.item.fundId = fundItem.fundingID;
                        weakSelf.item.fundName = fundItem.fundingName;
                        weakSelf.item.fundOperatorType = 0;
                        [weakSelf updateFundingType];
                    }else if ([item isKindOfClass:[SSJCreditCardItem class]]){
                        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
                        [weakSelf.FundingTypeSelectView reloadDate];
                        weakSelf.item.fundId = cardItem.cardId;
                        weakSelf.item.fundName = cardItem.cardName;
                        weakSelf.item.fundOperatorType = 0;
                        [weakSelf updateFundingType];
                    }

                };
                [weakSelf.navigationController pushViewController:NewFundingVC animated:YES];
            }
            [weakSelf.FundingTypeSelectView dismiss];
        };
        _FundingTypeSelectView.dismissBlock = ^{
            [weakSelf.billTypeInputView.moneyInput becomeFirstResponder];
        };
    }
    return _FundingTypeSelectView;
}

- (SSJRecordMakingBillTypeInputView *)billTypeInputView {
    if (!_billTypeInputView) {
        _billTypeInputView = [[SSJRecordMakingBillTypeInputView alloc] initWithFrame:CGRectMake(0, self.customNaviBar.bottom, self.view.width, 70)];
        _billTypeInputView.fillColor = INPUT_DEFAULT_COLOR;
        _billTypeInputView.moneyInput.delegate = self;
        if (_item.money) {
            _billTypeInputView.moneyInput.text = [NSString stringWithFormat:@"%.2f", [_item.money doubleValue]];
        }
    }
    return _billTypeInputView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.billTypeInputView.bottom, self.view.width, self.view.height - self.billTypeInputView.bottom)];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (SSJRecordMakingBillTypeSelectionView *)paymentTypeView {
    if (!_paymentTypeView) {
        _paymentTypeView = [[SSJRecordMakingBillTypeSelectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - self.billTypeInputView.bottom)];
        [self initBillTypeView:_paymentTypeView];
    }
    return _paymentTypeView;
}

- (SSJRecordMakingBillTypeSelectionView *)incomeTypeView {
    if (!_incomeTypeView) {
        _incomeTypeView = [[SSJRecordMakingBillTypeSelectionView alloc] initWithFrame:CGRectMake(self.view.width, 0, self.view.width, self.view.height - self.billTypeInputView.bottom)];
        [self initBillTypeView:_incomeTypeView];
    }
    return _incomeTypeView;
}

-(SSJMemberSelectView *)memberSelectView{
    if (!_memberSelectView) {
        __weak typeof(self) weakSelf = self;
        _memberSelectView = [[SSJMemberSelectView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _memberSelectView.dismissBlock = ^(){
            if ([[weakSelf.navigationController.viewControllers lastObject] isKindOfClass:[SSJRecordMakingViewController class]]) {
                [weakSelf.billTypeInputView.moneyInput becomeFirstResponder];
            }
        };
        _memberSelectView.showBlock = ^(){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf -> _needToDismiss = YES;
        };
        _memberSelectView.selectedMemberDidChangeBlock = ^(NSArray *selectedMemberItems){
            weakSelf.item.membersItem = [selectedMemberItems mutableCopy];
            [weakSelf updateMembers];
        };
        _memberSelectView.manageBlock = ^(NSMutableArray *items){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf -> _needToDismiss = YES;
            [weakSelf.billTypeInputView.moneyInput resignFirstResponder];
            [weakSelf.accessoryView.memoView resignFirstResponder];
            SSJMemberManagerViewController *membermanageVc = [[SSJMemberManagerViewController alloc]init];
            membermanageVc.items = items;
            [weakSelf.navigationController pushViewController:membermanageVc animated:YES];
        };
        _memberSelectView.addNewMemberBlock = ^(){
            [weakSelf.memberSelectView dismiss];
            SSJNewMemberViewController *newMemberVc = [[SSJNewMemberViewController alloc]init];
            newMemberVc.addNewMemberAction = ^(SSJChargeMemberItem *item){
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (item.memberId.length) {
                    [weakSelf.item.membersItem addObject:item];
                }
                [weakSelf updateMembers];
                weakSelf.memberSelectView.selectedMemberItems = [weakSelf.item.membersItem mutableCopy];
                weakSelf.memberSelectView.chargeId = weakSelf.item.ID;
                [weakSelf.memberSelectView show];
                strongSelf -> _needToDismiss = NO;
            };
            [weakSelf.navigationController pushViewController:newMemberVc animated:YES];
        };
    }
    return _memberSelectView;
}

- (SSJRecordMakingBillTypeInputAccessoryView *)accessoryView {
    if (!_accessoryView) {
        _accessoryView = [[SSJRecordMakingBillTypeInputAccessoryView alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, 86)];
        _accessoryView.buttonTitleNormalColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _accessoryView.buttonTitleSelectedColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [_accessoryView.accountBtn addTarget:self action:@selector(selectFundAccountAction) forControlEvents:UIControlEventTouchUpInside];
        [_accessoryView.dateBtn addTarget:self action:@selector(selectBillDateAction) forControlEvents:UIControlEventTouchUpInside];
        [_accessoryView.photoBtn addTarget:self action:@selector(selectPhotoAction) forControlEvents:UIControlEventTouchUpInside];
        [_accessoryView.memberBtn addTarget:self action:@selector(selectMemberAction) forControlEvents:UIControlEventTouchUpInside];
        [_accessoryView.dateBtn setTitle:[NSString stringWithFormat:@"%ld月%ld日", _selectedMonth, _selectedDay] forState:SSJButtonStateNormal];
        [_accessoryView.photoBtn setTitle:@"照片" forState:SSJButtonStateNormal];
        _accessoryView.memoView.delegate = self;
        _accessoryView.memoView.text = _item.chargeMemo;
        _accessoryView.dateBtn.selected = YES;
        _accessoryView.photoBtn.selected = _item.chargeImage.length;
    }
    return _accessoryView;
}

- (SSJBooksParentSelectView *)parentSelectView{
    if (!_parentSelectView) {
        _parentSelectView = [[SSJBooksParentSelectView alloc] initWithFrame:self.view.frame];
        __weak typeof(self) weakSelf = self;
        _parentSelectView.parentSelectBlock = ^(NSInteger selectParent) {
            [weakSelf.parentSelectView dismiss];
            
            SSJBooksTypeItem *item = [[SSJBooksTypeItem alloc]init];
            item.booksParent = selectParent;
            
            SSJBooksEditeOrNewViewController *booksEditeVc = [[SSJBooksEditeOrNewViewController alloc] init];
            booksEditeVc.item = item;
            booksEditeVc.saveBooksBlock = ^(NSString *booksId) {
                weakSelf.item.booksId = booksId;
            };
            [weakSelf.navigationController pushViewController:booksEditeVc animated:YES];
        };
    }
    return _parentSelectView;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [super textFieldDidBeginEditing:textField];
    _currentInput = textField;
    _paymentTypeView.editing = NO;
    _incomeTypeView.editing = NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (_billTypeInputView.moneyInput == textField) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = [text ssj_reserveDecimalDigits:2 intDigits:9];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _billTypeInputView.moneyInput
        || textField == _accessoryView.memoView) {
        [self makeArecord];
        [SSJAnaliyticsManager event:@"addRecord_save"];
    }
    return YES;
}

#pragma mark - UIActionSheetDelegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:  //打开照相机拍照
            [self takePhoto];
            break;
        case 1:  //打开本地相册
            [self localPhoto];
            break;
        case 2:  //打开本地相册
            [self.billTypeInputView.moneyInput becomeFirstResponder];
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    _selectedImage = image;
    [self.billTypeInputView.moneyInput becomeFirstResponder];
    _accessoryView.photoBtn.selected = YES;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _scrollView) {
        NSInteger currentSelectedIndex = scrollView.contentOffset.x / scrollView.width;
        if (_lastSelectedIndex != currentSelectedIndex) {
            _lastSelectedIndex = currentSelectedIndex;
            
            if (_lastSelectedIndex == 0) {
                _customNaviBar.selectedBillType = SSJBillTypePay;
            } else if (_lastSelectedIndex == 1) {
                _customNaviBar.selectedBillType = SSJBillTypeIncome;
            }
            
            _paymentTypeView.editing = NO;
            _incomeTypeView.editing = NO;
            [self updateBillTypeSelectionViewAndInputView];
            [self updateNavigationRightItem];
        }
    }
}

#pragma mark - YYKeyboardObserver
- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    if (transition.toVisible) {
        if ([_billTypeInputView.moneyInput isFirstResponder]
            || [_accessoryView.memoView isFirstResponder]) {
            _accessoryView.top = self.view.height;
            [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
                _accessoryView.bottom = self.view.height - transition.toFrame.size.height;
            } completion:NULL];
        }
    } else {
        [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
            _accessoryView.top = self.view.height;
        } completion:NULL];
    }
}

#pragma mark - Event
- (void)goBackAction {
    [super goBackAction];
    _paymentTypeView.editing = NO;
    _incomeTypeView.editing = NO;
    [self.view endEditing:YES];
}

- (void)segmentPressed {
    if (_customNaviBar.selectedBillType == SSJBillTypePay) {
        [SSJAnaliyticsManager event:@"addRecord_type_out"];
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else if (_customNaviBar.selectedBillType == SSJBillTypeIncome) {
        [SSJAnaliyticsManager event:@"addRecord_type_in"];
        [_scrollView setContentOffset:CGPointMake(_scrollView.width, 0) animated:YES];
    }
    
    _paymentTypeView.editing = NO;
    _incomeTypeView.editing = NO;
    [self updateBillTypeSelectionViewAndInputView];
    [self updateNavigationRightItem];
}

- (void)selectFundAccountAction {
    [SSJAnaliyticsManager event:@"addRecord_fund"];
    [self.FundingTypeSelectView show];
    [_billTypeInputView.moneyInput resignFirstResponder];
    [_accessoryView.memoView resignFirstResponder];
}

- (void)selectBillDateAction {
    NSString *currentDateStr = [NSString stringWithFormat:@"%@ %@",self.item.billDate,self.item.billDetailDate];
    NSDate *currentDate = [NSDate dateWithString:currentDateStr formatString:@"yyyy-MM-dd HH:mm"];
    [SSJAnaliyticsManager event:@"addRecord_calendar"];
    self.dateSelectedView.date = currentDate;
    [self.dateSelectedView show];
    [_billTypeInputView.moneyInput resignFirstResponder];
    [_accessoryView.memoView resignFirstResponder];
}

- (void)selectPhotoAction {
    if (_selectedImage || self.item.chargeImage.length != 0) {
        SSJImaageBrowseViewController *imageBrowserVC = [[SSJImaageBrowseViewController alloc]init];
        __weak typeof(self) weakSelf = self;
        [SSJAnaliyticsManager event:@"addRecord_camera"];
        imageBrowserVC.DeleteImageBlock = ^(){
            weakSelf.selectedImage = nil;
            weakSelf.item.chargeImage = @"";
            weakSelf.item.chargeThumbImage = @"";
            weakSelf.accessoryView.photoBtn.selected = NO;
        };
        imageBrowserVC.NewImageSelectedBlock = ^(UIImage *image){
            weakSelf.selectedImage = image;
        };
        imageBrowserVC.type = SSJImageBrowseVcTypeEdite;
        if (_selectedImage) {
            imageBrowserVC.image = _selectedImage;
        } else {
            imageBrowserVC.item = self.item;
        }
        [self.navigationController pushViewController:imageBrowserVC animated:YES];
    } else {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄照片" ,@"从相册选择", nil];
        [sheet showInView:self.view];
        [_billTypeInputView.moneyInput resignFirstResponder];
        [_accessoryView.memoView resignFirstResponder];
    }
}

- (void)selectMemberAction{
    [SSJAnaliyticsManager event:@"addRecord_member"];
    self.memberSelectView.selectedMemberItems = [self.item.membersItem mutableCopy];
    self.memberSelectView.chargeId = self.item.ID;
    [self.memberSelectView show];
    [_billTypeInputView.moneyInput resignFirstResponder];
    [_accessoryView.memoView resignFirstResponder];
}

//- (void)selectPeriodAction {
//    [SSJAnaliyticsManager event:@"addRecord_cycle"];
//    self.ChargeCircleSelectView.selectCircleType = _selectChargeCircleType;
//    [self.ChargeCircleSelectView show];
//    [_billTypeInputView.moneyInput resignFirstResponder];
//    [_accessoryView.memoView resignFirstResponder];
//}

- (void)endEditingAction {
    _paymentTypeView.editing = NO;
    _incomeTypeView.editing = NO;
    [self updateNavigationRightItem];
}

- (void)hideGuideView {
    if (_guideView.superview) {
        [UIView transitionWithView:_guideView.superview duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [_guideView removeFromSuperview];
            _guideView = nil;
        } completion:^(BOOL finished) {
            [_billTypeInputView.moneyInput becomeFirstResponder];
        }];
    }
}

- (void)managerItemAction {
    switch (_customNaviBar.selectedBillType) {
        case SSJBillTypePay:
            _paymentTypeView.editing = !_customNaviBar.managed;
            break;
            
        case SSJBillTypeIncome:
            _incomeTypeView.editing = !_customNaviBar.managed;
            break;
            
        case SSJBillTypeUnknown:
        case SSJBillTypeSurplus:
            SSJPRINT(@"未定义选项");
            break;
    }
    
    if (_customNaviBar.managed) {
        [SSJAnaliyticsManager event:@"addRecord_manage"];
    } else {
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    }
}

#pragma mark - private
- (void)initData {
    NSDate *now = [NSDate date];
    _currentYear= now.year;
    _currentDay = now.day;
    _currentMonth = now.month;
    //获取日期
    if (self.item.ID.length == 0) {
        if (_selectedYear == 0) {
            self.selectedYear = _currentYear;
        }
        if (_selectedMonth == 0) {
            self.selectedMonth = _currentMonth;
        }
        if (_selectedDay == 0) {
            self.selectedDay = _currentDay;
        }
        self.item.billDetailDate = [[NSDate date] formattedDateWithFormat:@"HH:mm"];
    }else{
        if (self.item.ID.length == 0) {
            self.selectedYear = _currentYear;
            self.selectedMonth = _currentMonth;
            self.selectedDay = _currentDay;
        }else{
            self.selectedYear = [[self.item.billDate substringWithRange:NSMakeRange(0, 4)] integerValue];
            self.selectedMonth = [[self.item.billDate substringWithRange:NSMakeRange(5, 2)] integerValue];
            self.selectedDay = [[self.item.billDate substringWithRange:NSMakeRange(8, 2)] integerValue];
        }
    }
    self.item.billDate = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",self.selectedYear,self.selectedMonth,self.selectedDay];
    [self loadFundData];
    [self getmembersForTheCharge];
}

/**
 加载收支类别和账本数据
 */
- (void)loadCategoryAndBooksList {
    if (_customNaviBar.selectedBillType != SSJBillTypePay
         && _customNaviBar.selectedBillType != SSJBillTypeIncome) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.view ssj_showLoadingIndicator];
    [SSJCategoryListHelper queryForCategoryListWithIncomeOrExpenture:_customNaviBar.selectedBillType booksId:self.item.booksId Success:^(NSMutableArray *categoryList) {
        
        [SSJBooksTypeStore queryForBooksListWithSuccess:^(NSMutableArray<SSJBooksTypeItem *> *bookList) {
            
            [self.view ssj_hideLoadingIndicator];
            
            __block SSJRecordMakingBillTypeSelectionCellItem *selectedItem = nil;
            dispatch_apply([categoryList count], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t index) {
                SSJRecordMakingBillTypeSelectionCellItem *item = [categoryList ssj_safeObjectAtIndex:index];
                if (weakSelf.item.billId && [item.ID isEqualToString:weakSelf.item.billId]) {
                    item.selected = YES;
                    selectedItem = item;
                }
            });
            
            if (!selectedItem) {
                selectedItem = [categoryList firstObject];
                selectedItem.selected = YES;
                weakSelf.item.billId = selectedItem.ID;
            }
            
            if (_customNaviBar.selectedBillType == SSJBillTypePay) {
                weakSelf.paymentTypeView.items = categoryList;
            } else if (_customNaviBar.selectedBillType == SSJBillTypeIncome) {
                weakSelf.incomeTypeView.items = categoryList;
            }
            
            if (selectedItem) {
                [UIView animateWithDuration:kAnimationDuration animations:^{
                    weakSelf.billTypeInputView.fillColor = [UIColor ssj_colorWithHex:selectedItem.colorValue];
                }];
                weakSelf.billTypeInputView.billTypeName = selectedItem.title;
            }
            
            NSInteger selectedIndex = -1;
            NSMutableArray *bookTitles = [[NSMutableArray alloc] initWithCapacity:bookList.count];
            NSMutableArray *bookIds = [[NSMutableArray alloc] initWithCapacity:bookList.count];
            
            for (int i = 0; i < bookList.count; i ++) {
                SSJBooksTypeItem *item = bookList[i];
                if (item.booksId) {
                    [bookTitles addObject:item.booksName];
                    [bookIds addObject:item.booksId];
                    
                    if ([item.booksId isEqualToString:self.item.booksId]) {
                        selectedIndex = i;
                    }
                }
            }
            
            _booksIds = [bookIds copy];
            _customNaviBar.titles = bookTitles;
            _customNaviBar.selectedTitleIndex = selectedIndex;
            
        } failure:^(NSError *error) {
            [self.view ssj_hideLoadingIndicator];
            [self showError:error];
        }];
        
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [self showError:error];
    }];
}

- (void)showError:(NSError *)error {
    NSString *message = nil;
#ifdef DEBUG
    message = [error localizedDescription];
#else
    message = SSJ_ERROR_MESSAGE;
#endif
    [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:message action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
}

// 获取选中的资金账户
- (void)loadFundData {
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        if (weakSelf.item.ID.length != 0) {
            if (!weakSelf.item.fundName.length) {
                if ([db intForQuery:@"select operatortype from bk_fund_info where cfundid = ?",weakSelf.item.fundId] == 2) {
                    weakSelf.item.fundName = @"选择账户";
                    weakSelf.item.fundOperatorType = 2;
                }else{
                    weakSelf.item.fundName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ? and cuserid = ? and operatortype <> 2",weakSelf.item.fundId,userId];
                    weakSelf.item.fundOperatorType = [db intForQuery:@"select operatortype from bk_fund_info where cfundid = ? and cuserid = ?",weakSelf.item.fundId,userId];
                }
            }
        }else{
            if (![db stringForQuery:@"select lastselectfundid from bk_user where cuserid = ?",userId].length) {
                weakSelf.item.fundId = [db stringForQuery:@"select cfundid from bk_fund_info where cparent != 'root' and cparent != '10' and cparent != '11' and operatortype <> 2 and cuserid = ? order by iorder limit 1",userId];
                weakSelf.item.fundName = [db stringForQuery:@"select cacctname from bk_fund_info where cparent != 'root' and cparent != '10' and cparent != '11' and operatortype <> 2 and cuserid = ? order by iorder limit 1",userId];
            }else{
                if ([db intForQuery:@"select operatortype from bk_fund_info where cfundid = (select lastselectfundid from bk_user where cuserid = ?)",userId] == 2) {
                    weakSelf.item.fundId = [db stringForQuery:@"select cfundid from bk_fund_info where cparent != 'root' and operatortype <> 2 and cuserid = ? limit 1",userId];
                    weakSelf.item.fundName = [db stringForQuery:@"select cacctname from bk_fund_info where cparent != 'root' and operatortype <> 2 and cuserid = ? limit 1",userId];
                }else{
                    weakSelf.item.fundId = [db stringForQuery:@"select lastselectfundid from bk_user as a where a.cuserid = ? and a.lastselectfundid in (select cfundid from bk_fund_info where cuserid = ? and operatortype <> 2 and cparent != 'root')",userId,userId];
                    weakSelf.item.fundName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ? and cuserid = ? and operatortype <> 2",weakSelf.item.fundId,userId];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            [weakSelf updateFundingType];
        });
    }];
}

- (void)reloadMenberItems {
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        for (SSJChargeMemberItem *memberItem in weakSelf.item.membersItem) {
            FMResultSet *result = [db executeQuery:@"select * from bk_member where cmemberid = ?",memberItem.memberId];
            while ([result next]) {
                memberItem.memberId = [result stringForColumn:@"cmemberid"];
                memberItem.memberName = [result stringForColumn:@"cname"];
                memberItem.memberColor = [result stringForColumn:@"ccolor"];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateMembers];
        });
    }];
}

-(void)getmembersForTheCharge{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        if (weakSelf.item.ID.length) {
            if ([db intForQuery:@"select count(1) from bk_member_charge where ichargeid = ? and operatortype <> 2",weakSelf.item.ID]) {
                FMResultSet *result = [db executeQuery:@"select * from bk_member_charge as a , bk_member as b  where a.ichargeid = ? and a.operatortype <> 2 and b.cuserid = ? and a.cmemberid = b.cmemberid",weakSelf.item.ID,SSJUSERID()];
                NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
                while ([result next]) {
                    SSJChargeMemberItem *memberItem = [[SSJChargeMemberItem alloc]init];
                    memberItem.memberId = [result stringForColumn:@"cmemberid"];
                    memberItem.memberName = [result stringForColumn:@"cname"];
                    memberItem.memberColor = [result stringForColumn:@"ccolor"];
                    [tempArr addObject:memberItem];
                }
                weakSelf.item.membersItem= tempArr;
            }else{
                SSJChargeMemberItem *memberItem = [[SSJChargeMemberItem alloc]init];
                memberItem.memberId = [NSString stringWithFormat:@"%@-0",SSJUSERID()];
                memberItem.memberName = [db stringForQuery:@"select cname from bk_member where cmemberid = ?",memberItem.memberId];
                memberItem.memberColor = [db stringForQuery:@"select ccolor from bk_member where cmemberid = ?",memberItem.memberId];
                weakSelf.item.membersItem = [NSMutableArray arrayWithObjects:memberItem, nil];
            }
        }else{
            SSJChargeMemberItem *memberItem = [[SSJChargeMemberItem alloc]init];
            memberItem.memberId = [NSString stringWithFormat:@"%@-0",SSJUSERID()];
            memberItem.memberName = [db stringForQuery:@"select cname from bk_member where cmemberid = ?",memberItem.memberId];
            memberItem.memberColor = [db stringForQuery:@"select ccolor from bk_member where cmemberid = ?",memberItem.memberId];
            weakSelf.item.membersItem = [NSMutableArray arrayWithObjects:memberItem, nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateMembers];
        });
    }];
}

-(void)takePhoto{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:^{}];
    }else
    {
        SSJPRINT(@"模拟其中无法打开照相机,请在真机中使用");
    }
}

-(void)localPhoto{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:^{}];
}

-(void)makeArecord{
    __weak typeof(self) weakSelf = self;
    if (!_item.billId.length) {
        [_billTypeInputView.moneyInput becomeFirstResponder];
        [CDAutoHideMessageHUD showMessage:@"请添加并选择一个类别"];
        return;
    }
    
    if ([_billTypeInputView.moneyInput.text doubleValue] == 0) {
        [_billTypeInputView.moneyInput becomeFirstResponder];
        [CDAutoHideMessageHUD showMessage:@"金额不能为0"];
        return;
    }
    
    if ([_billTypeInputView.moneyInput.text doubleValue] < 0) {
        [_billTypeInputView.moneyInput becomeFirstResponder];
        [CDAutoHideMessageHUD showMessage:@"金额不能小于0"];
        return;
    }
    
    if (self.item.fundOperatorType == 2) {
        [_billTypeInputView.moneyInput becomeFirstResponder];
        [CDAutoHideMessageHUD showMessage:@"请先添加资金账户"];
        return;
    }
    
    if (_accessoryView.memoView.text.length > 500) {
        [CDAutoHideMessageHUD showMessage:@"备注最多只能输入500个字"];
        return;
    }
    
    self.item.incomeOrExpence = _customNaviBar.selectedBillType;
    self.item.money = _billTypeInputView.moneyInput.text;
    self.item.chargeMemo = _accessoryView.memoView.text;
    
    if (self.item.chargeMemo && self.item.ID.length) {
        [SSJAnaliyticsManager event:@"addRecord_memo"];
    }
    
    if (_selectedImage != nil) {
        NSString *imageName = SSJUUID();
        if (SSJSaveImage(_selectedImage, imageName) && SSJSaveThumbImage(_selectedImage, imageName)) {
            weakSelf.item.chargeImage = imageName;
        }
    }
    
    [SSJRecordMakingStore saveChargeWithChargeItem:self.item Success:^(SSJBillingChargeCellItem *editeItem){
        BOOL hasChangeBooksType = NO;
        if (![editeItem.booksId isEqualToString:SSJGetCurrentBooksType()]) {
            SSJSelectBooksType(editeItem.booksId);
            hasChangeBooksType = YES;
        }
        if (weakSelf.addNewChargeBlock) {
            weakSelf.addNewChargeBlock(@[editeItem],hasChangeBooksType);
        }
        [weakSelf goBackAction];
    } failure:^{
        
    }];
}

- (BOOL)showGuideViewIfNeeded {
    BOOL isEverEntered = [[NSUserDefaults standardUserDefaults] boolForKey:kIsEverEnteredKey];
    if (!isEverEntered) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsEverEnteredKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (!_guideView) {
            _guideView = [[UIImageView alloc] initWithImage:[UIImage ssj_compatibleImageNamed:@"record_making_guide"]];
            _guideView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideGuideView)];
            [_guideView addGestureRecognizer:tap];
        }
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        _guideView.frame = window.bounds;
        [UIView transitionWithView:window duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [window addSubview:_guideView];
        } completion:NULL];
    }
    return !isEverEntered;
}

- (void)initBillTypeView:(SSJRecordMakingBillTypeSelectionView *)billTypeView {
    __weak typeof(self) wself = self;
    billTypeView.contentInsets = UIEdgeInsetsMake(0, 0, [SSJCustomKeyboard sharedInstance].height + self.accessoryView.height, 0);
    
    billTypeView.deleteAction = ^(SSJRecordMakingBillTypeSelectionView *selectionView, SSJRecordMakingBillTypeSelectionCellItem *item) {
        [wself deleteItem:item ofItems:selectionView.items];
        [SSJAnaliyticsManager event:@"bill_type_delete"];
    };
    
    billTypeView.shouldDeleteAction = ^(SSJRecordMakingBillTypeSelectionView *selectionView, SSJRecordMakingBillTypeSelectionCellItem *item) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:kIsAlertViewShowedKey]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsAlertViewShowedKey];
            [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"该类别将被移动到添加类别页哦。" action:[SSJAlertViewAction actionWithTitle:@"知道了" handler:^(SSJAlertViewAction * _Nonnull action) {
                [selectionView deleteItem:item];
                [wself deleteItem:item ofItems:selectionView.items];
            }], nil];
            
            return NO;
        }
        
        return YES;
    };
    
    billTypeView.selectAction = ^(SSJRecordMakingBillTypeSelectionView *selectionView, SSJRecordMakingBillTypeSelectionCellItem *item) {
        [wself.billTypeInputView.moneyInput becomeFirstResponder];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            wself.billTypeInputView.billTypeName = item.title;
            wself.billTypeInputView.fillColor = [UIColor ssj_colorWithHex:item.colorValue];
        }];
        wself.item.billId = item.ID;
    };
    
    billTypeView.addAction = ^(SSJRecordMakingBillTypeSelectionView *selectionView) {
        SSJADDNewTypeViewController *addNewTypeVc = [[SSJADDNewTypeViewController alloc]init];
        addNewTypeVc.booksId = wself.item.booksId;
        addNewTypeVc.incomeOrExpence = wself.customNaviBar.selectedBillType;
        addNewTypeVc.addNewCategoryAction = ^(NSString *categoryId, BOOL incomeOrExpence){
            wself.item.billId = categoryId;
            wself.customNaviBar.selectedBillType = incomeOrExpence;
            
            if (wself.customNaviBar.selectedBillType == SSJBillTypePay) {
                [wself.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            } else if (wself.customNaviBar.selectedBillType == SSJBillTypeIncome) {
                [wself.scrollView setContentOffset:CGPointMake(wself.scrollView.width, 0) animated:YES];
            }
            
            [wself updateNavigationRightItem];
        };
        [wself.navigationController pushViewController:addNewTypeVc animated:YES];
    };
    
    billTypeView.dragAction = ^(SSJRecordMakingBillTypeSelectionView *selectionView, BOOL isDragUp) {
        if (!selectionView.editing) {
            [wself.currentInput resignFirstResponder];
        }
    };
    
    billTypeView.beginEditingAction = ^(SSJRecordMakingBillTypeSelectionView *selectionView) {
        wself.customNaviBar.managed = YES;
        [wself.currentInput resignFirstResponder];
    };
    
    billTypeView.endEditingAction = ^(SSJRecordMakingBillTypeSelectionView *selectionView) {
        [wself.currentInput becomeFirstResponder];
        wself.customNaviBar.managed = NO;
        [SSJCategoryListHelper updateCategoryOrderWithItems:selectionView.items success:NULL failure:^(NSError *error) {
            [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
        }];
    };
}

- (void)updateBillTypeSelectionViewAndInputView {
    if (_customNaviBar.selectedBillType == SSJBillTypePay) {
        if (_paymentTypeView.items.count == 0) {
            [self loadCategoryAndBooksList];
        } else {
            for (SSJRecordMakingBillTypeSelectionCellItem *item in _paymentTypeView.items) {
                if (item.selected) {
                    [UIView animateWithDuration:kAnimationDuration animations:^{
                        _billTypeInputView.fillColor = [UIColor ssj_colorWithHex:item.colorValue];
                    }];
                    _billTypeInputView.billTypeName = item.title;
                    break;
                }
            }
        }
    } else if (_customNaviBar.selectedBillType == SSJBillTypeIncome) {
        if (_incomeTypeView.items.count == 0) {
            [self loadCategoryAndBooksList];
        } else {
            for (SSJRecordMakingBillTypeSelectionCellItem *item in _incomeTypeView.items) {
                if (item.selected) {
                    [UIView animateWithDuration:kAnimationDuration animations:^{
                        _billTypeInputView.fillColor = [UIColor ssj_colorWithHex:item.colorValue];
                    }];
                    _billTypeInputView.billTypeName = item.title;
                    break;
                }
            }
        }
    }
}

-(void)updateMembers{
    if (self.item.membersItem.count == 1) {
        SSJChargeMemberItem *item = [self.item.membersItem ssj_safeObjectAtIndex:0];
        [self.accessoryView.memberBtn setTitle:item.memberName forState:SSJButtonStateNormal];
    }else{
        [self.accessoryView.memberBtn setTitle:[NSString stringWithFormat:@"%ld人",self.item.membersItem.count] forState:SSJButtonStateNormal];
    }
}

- (void)updateFundingType {
    [self.accessoryView.accountBtn setTitle:self.item.fundName forState:SSJButtonStateNormal];
    self.accessoryView.accountBtn.selected = YES;
    self.FundingTypeSelectView.selectFundID = self.item.fundId;
}

- (void)updateNavigationRightItem {
    if (_customNaviBar.selectedBillType == SSJBillTypePay) {
        _customNaviBar.managed = _paymentTypeView.editing;
    } else if (_customNaviBar.selectedBillType == SSJBillTypeIncome) {
        _customNaviBar.managed = _incomeTypeView.editing;
    }
}

- (void)deleteItem:(SSJRecordMakingBillTypeSelectionCellItem *)item ofItems:(NSArray *)items {
    int order = [SSJCategoryListHelper queryForBillTypeMaxOrderWithState:0 type:_customNaviBar.selectedBillType booksId:self.item.booksId] + 1;
    
    [SSJCategoryListHelper updateCategoryWithID:item.ID
                                           name:item.title
                                          color:item.colorValue
                                          image:item.imageName
                                          order:order
                                          state:0
                                        booksId:self.item.booksId
                                        Success:NULL
                                        failure:^(NSError *error) {
                                            [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了"
                                                                                message:[error localizedDescription]
                                                                                 action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
                                        }];
    
    for (SSJRecordMakingBillTypeSelectionCellItem *item in items) {
        if (item.selected) {
            [UIView animateWithDuration:kAnimationDuration animations:^{
                self.billTypeInputView.billTypeName = item.title;
                self.billTypeInputView.fillColor = [UIColor ssj_colorWithHex:item.colorValue];
            }];
            self.item.billId = item.ID;
        }
    }
    
    if (items.count == 0) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.billTypeInputView.billTypeName = nil;
            self.billTypeInputView.fillColor = INPUT_DEFAULT_COLOR;
        }];
        self.item.billId = nil;
    }
}

//-(void)closeButtonClicked:(id)sender{
//    [self ssj_backOffAction];
//}

-(void)reloadDataAfterSync{
//    [self.categoryListView reloadData];
}

@end
