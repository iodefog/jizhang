//
//  SSJRecordMakingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/16.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingViewController.h"
#import "SSJCustomKeyboard.h"
#import "SSJCalendarView.h"
#import "SSJDateSelectedView.h"
#import "SSJFundingTypeSelectView.h"
#import "SSJADDNewTypeViewController.h"
#import "SSJSegmentedControl.h"
#import "SSJSmallCalendarView.h"
#import "SSJNewFundingViewController.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "SSJChargeCircleSelectView.h"
#import "SSJCategoryListHelper.h"
#import "SSJImaageBrowseViewController.h"

#import "SSJRecordMakingBillTypeInputView.h"
#import "SSJRecordMakingBillTypeSelectionView.h"
#import "SSJRecordMakingBillTypeInputAccessoryView.h"
#import "SSJRecordMakingBillTypeSelectionCellItem.h"
#import "YYKeyboardManager.h"

static const NSTimeInterval kAnimationDuration = 0.25;

static NSString *const kIsEverEnteredKey = @"kIsEverEnteredKey";

@interface SSJRecordMakingViewController () <UIScrollViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, YYKeyboardObserver>

@property (nonatomic,strong) SSJSegmentedControl *titleSegment;

@property (nonatomic,strong) UIImage *selectedImage;

@property (nonatomic,strong) SSJDateSelectedView *DateSelectedView;

@property (nonatomic,strong) SSJFundingTypeSelectView *FundingTypeSelectView;

@property (nonatomic,strong) SSJChargeCircleSelectView *ChargeCircleSelectView;
@property (nonatomic) NSInteger selectChargeCircleType;
@property (nonatomic,strong) NSString *chargeMemo;
@property (nonatomic,strong) NSString *categoryID;

@property (nonatomic,strong) SSJFundingItem *selectItem;
@property (nonatomic,strong) SSJFundingItem *defualtItem;

@property (nonatomic, strong) SSJRecordMakingBillTypeInputView *billTypeInputView;

@property (nonatomic, strong) SSJRecordMakingBillTypeSelectionView *billTypeSelectionView;

@property (nonatomic, strong) SSJRecordMakingBillTypeInputAccessoryView *accessoryView;

@property (nonatomic, strong) UIImageView *guideView;


@property (nonatomic) long currentYear;
@property (nonatomic) long currentMonth;
@property (nonatomic) long currentDay;
@end

@implementation SSJRecordMakingViewController{
    long _originaldMonth;
    long _originaldYear;
    long _originaldDay;
}
#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.statisticsTitle = @"记一笔";
        self.hidesBottomBarWhenPushed = YES;
        [[YYKeyboardManager defaultManager] addObserver:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self ssj_showBackButtonWithTarget:self selector:@selector(goBackAction)];
    
    [self initData];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self settitleSegment];
    [self.view addSubview:self.billTypeInputView];
    [self.view addSubview:self.billTypeSelectionView];
    [self.view addSubview:self.accessoryView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getCategoryList];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor whiteColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_billTypeInputView.moneyInput resignFirstResponder];
    [_accessoryView.memoView resignFirstResponder];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _billTypeSelectionView.height = self.view.height - self.billTypeInputView.bottom;
}

#pragma mark - Getter
- (void)updateFundingType {
    [self.accessoryView.accountBtn setTitle:_selectItem.fundingName forState:UIControlStateNormal];
    self.accessoryView.accountBtn.selected = YES;
    self.FundingTypeSelectView.selectFundID = _selectItem.fundingID;
}

-(SSJDateSelectedView*)DateSelectedView{
    if (!_DateSelectedView) {
        _DateSelectedView = [[SSJDateSelectedView alloc]initWithFrame:[UIScreen mainScreen].bounds forYear:self.selectedYear Month:self.selectedMonth Day:self.selectedDay];
        __weak typeof(self) weakSelf = self;
        _DateSelectedView.calendarView.DateSelectedBlock = ^(long year , long month ,long day,  NSString *selectDate){
//            if (weakSelf.selectChargeCircleType != -1
//                && (year < weakSelf.currentYear || month < weakSelf.currentMonth || day < weakSelf.currentDay)) {
//                [CDAutoHideMessageHUD showMessage:@""];
//                return;
//            }
            weakSelf.selectedDay = day;
            weakSelf.selectedMonth = month;
            weakSelf.selectedYear = year;
            [weakSelf.accessoryView.dateBtn setTitle:[NSString stringWithFormat:@"%ld月",weakSelf.selectedMonth] forState:UIControlStateNormal];
            [weakSelf.accessoryView.dateBtn setTitle:[NSString stringWithFormat:@"%ld月%ld日", month, day] forState:UIControlStateNormal];
            [weakSelf.DateSelectedView dismiss];
        };
        _DateSelectedView.dismissBlock = ^{
            [weakSelf.billTypeInputView.moneyInput becomeFirstResponder];
        };
    }
    return _DateSelectedView;
}

-(SSJFundingTypeSelectView *)FundingTypeSelectView{
    if (!_FundingTypeSelectView) {
        __weak typeof(self) weakSelf = self;
        _FundingTypeSelectView = [[SSJFundingTypeSelectView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _FundingTypeSelectView.fundingTypeSelectBlock = ^(SSJFundingItem *fundingItem){
            if (![fundingItem.fundingName isEqualToString:@"添加资金新的账户"]) {
                weakSelf.selectItem = fundingItem;
                [weakSelf updateFundingType];
                 NSData *lastSelectFundingDate = [NSKeyedArchiver archivedDataWithRootObject:fundingItem];
                [[NSUserDefaults standardUserDefaults] setObject:lastSelectFundingDate forKey:SSJLastSelectFundItemKey];
            }else{
                SSJNewFundingViewController *NewFundingVC = [[SSJNewFundingViewController alloc]init];
                NewFundingVC.finishBlock = ^(SSJFundingItem *newFundingItem){
                    [weakSelf.FundingTypeSelectView reloadDate];
                    weakSelf.selectItem = newFundingItem;
                    [weakSelf updateFundingType];
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

-(SSJChargeCircleSelectView *)ChargeCircleSelectView{
    if (!_ChargeCircleSelectView) {
        __weak typeof(self) weakSelf = self;
        _ChargeCircleSelectView = [[SSJChargeCircleSelectView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _ChargeCircleSelectView.selectCircleType = self.selectChargeCircleType;
        _ChargeCircleSelectView.incomeOrExpenture = self.titleSegment.selectedSegmentIndex;
        _ChargeCircleSelectView.shouldDismissWhenSureButtonClick =  ^BOOL(SSJChargeCircleSelectView *circleView) {
            if (weakSelf.selectedYear < weakSelf.currentYear || (weakSelf.selectedYear == weakSelf.currentYear && weakSelf.selectedMonth < weakSelf.currentMonth) ||  (weakSelf.selectedYear == weakSelf.currentYear && weakSelf.selectedMonth == weakSelf.currentMonth && weakSelf.selectedDay < weakSelf.currentDay)) {
                if (circleView.selectCircleType != -1) {
                    [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"抱歉,暂不可设置历史日期的定期收入/支出哦~" action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
                    weakSelf.ChargeCircleSelectView.selectCircleType = -1;
                    weakSelf.selectChargeCircleType = -1;
                    [weakSelf updatePeriodButtonTitle];
                    return NO;
                }
            }
            
            if (weakSelf.selectedDay > 28 && circleView.selectCircleType == 6 && circleView.selectCircleType == 4){
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"抱歉,每月天数不固定,暂不支持每月设置次日期." delegate:weakSelf cancelButtonTitle:@"确定" otherButtonTitles: nil];
                weakSelf.ChargeCircleSelectView.selectCircleType = -1;
                weakSelf.selectChargeCircleType = -1;
                [weakSelf updatePeriodButtonTitle];
                [alert show];
                return NO;
            }
            
            weakSelf.selectChargeCircleType = circleView.selectCircleType;
            [weakSelf updatePeriodButtonTitle];
            return YES;
        };
        _ChargeCircleSelectView.dismissAction = ^(SSJChargeCircleSelectView *circleView) {
            [weakSelf.billTypeInputView.moneyInput becomeFirstResponder];
        };
    }
    return _ChargeCircleSelectView;
}

- (SSJRecordMakingBillTypeInputView *)billTypeInputView {
    if (!_billTypeInputView) {
        _billTypeInputView = [[SSJRecordMakingBillTypeInputView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 91)];
        _billTypeInputView.moneyInput.delegate = self;
        _billTypeInputView.moneyInput.text = _item.money;
    }
    return _billTypeInputView;
}

- (SSJRecordMakingBillTypeSelectionView *)billTypeSelectionView {
    if (!_billTypeSelectionView) {
        __weak typeof(self) wself = self;
        _billTypeSelectionView = [[SSJRecordMakingBillTypeSelectionView alloc] initWithFrame:CGRectMake(0, self.billTypeInputView.bottom, self.view.width, self.view.height - self.billTypeInputView.bottom)];
        _billTypeSelectionView.contentInsets = UIEdgeInsetsMake(0, 0, [SSJCustomKeyboard sharedInstance].height + self.accessoryView.height, 0);
        _billTypeSelectionView.deleteAction = ^(SSJRecordMakingBillTypeSelectionView *selectionView, SSJRecordMakingBillTypeSelectionCellItem *item) {
            [SSJCategoryListHelper deleteCategoryWithCategoryId:item.ID Success:NULL failure:^(NSError *error) {
                [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
            }];
        };
        _billTypeSelectionView.selectAction = ^(SSJRecordMakingBillTypeSelectionView *selectionView, SSJRecordMakingBillTypeSelectionCellItem *item) {
            [wself.billTypeInputView.moneyInput becomeFirstResponder];
            [UIView animateWithDuration:kAnimationDuration animations:^{
                wself.billTypeInputView.billTypeName = item.title;
                wself.billTypeInputView.backgroundColor = [UIColor ssj_colorWithHex:item.colorValue];
            }];
            wself.categoryID = item.ID;
        };
        _billTypeSelectionView.addAction = ^(SSJRecordMakingBillTypeSelectionView *selectionView) {
            SSJADDNewTypeViewController *addNewTypeVc = [[SSJADDNewTypeViewController alloc]init];
            addNewTypeVc.incomeOrExpence = !wself.titleSegment.selectedSegmentIndex;
            addNewTypeVc.addNewCategoryAction = ^(NSString *categoryId){
                wself.categoryID = categoryId;
                [wself getCategoryList];
            };
            [wself.navigationController pushViewController:addNewTypeVc animated:YES];
        };
        _billTypeSelectionView.dragAction = ^(SSJRecordMakingBillTypeSelectionView *selectionView, BOOL isDragUp) {
            if (isDragUp) {
                [wself.billTypeInputView.moneyInput resignFirstResponder];
            } else {
                [wself.billTypeInputView.moneyInput becomeFirstResponder];
            }
        };
        _billTypeSelectionView.beginEditingAction = ^(SSJRecordMakingBillTypeSelectionView *selectionView) {
            UIBarButtonItem *endEditingItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:wself action:@selector(endEditingAction)];
            [wself.navigationItem setRightBarButtonItem:endEditingItem animated:YES];
        };
    }
    return _billTypeSelectionView;
}

- (SSJRecordMakingBillTypeInputAccessoryView *)accessoryView {
    if (!_accessoryView) {
        _accessoryView = [[SSJRecordMakingBillTypeInputAccessoryView alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, 86)];
        _accessoryView.buttonTitleNormalColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        _accessoryView.buttonTitleSelectedColor = [UIColor blackColor];
        [_accessoryView.accountBtn addTarget:self action:@selector(selectFundAccountAction) forControlEvents:UIControlEventTouchUpInside];
        [_accessoryView.dateBtn addTarget:self action:@selector(selectBillDateAction) forControlEvents:UIControlEventTouchUpInside];
        [_accessoryView.photoBtn addTarget:self action:@selector(selectPhotoAction) forControlEvents:UIControlEventTouchUpInside];
        [_accessoryView.periodBtn addTarget:self action:@selector(selectPeriodAction) forControlEvents:UIControlEventTouchUpInside];
        [_accessoryView.dateBtn setTitle:[NSString stringWithFormat:@"%ld月%ld日", _selectedMonth, _selectedDay] forState:UIControlStateNormal];
        [_accessoryView.photoBtn setTitle:@"照片" forState:UIControlStateNormal];
        _accessoryView.memoView.delegate = self;
        _accessoryView.memoView.text = _item.chargeMemo;
        _accessoryView.dateBtn.selected = YES;
        [self updatePeriodButtonTitle];
    }
    return _accessoryView;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (_billTypeInputView.moneyInput == textField) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = [text ssj_reserveDecimalDigits:2 intDigits:10];
        return NO;
    } else if (_accessoryView.memoView == textField) {
        NSString *text = textField.text ? : @"";
        text = [text stringByReplacingCharactersInRange:range withString:string];
        if (string.length > 50) {
            [CDAutoHideMessageHUD showMessage:@"最多只能输入50个字"];
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _billTypeInputView.moneyInput
        || textField == _accessoryView.memoView) {
        [self makeArecord];
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
    [self.view endEditing:YES];
}

-(void)segmentPressed:(id)sender{
    self.ChargeCircleSelectView.incomeOrExpenture = self.titleSegment.selectedSegmentIndex;
    if (self.titleSegment.selectedSegmentIndex == 0) {
        [MobClick event:@"7"];
    }else{
        [MobClick event:@"6"];
    }
    [self getCategoryList];
    [_billTypeSelectionView endEditing];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

- (void)selectFundAccountAction {
    [MobClick event:@"4"];
    [self.FundingTypeSelectView show];
    [_billTypeInputView.moneyInput resignFirstResponder];
    [_accessoryView.memoView resignFirstResponder];
}

- (void)selectBillDateAction {
    [MobClick event:@"5"];
    [self.DateSelectedView show];
    [_billTypeInputView.moneyInput resignFirstResponder];
    [_accessoryView.memoView resignFirstResponder];
}

- (void)selectPhotoAction {
    if (_selectedImage || self.item.chargeImage.length != 0) {
        SSJImaageBrowseViewController *imageBrowserVC = [[SSJImaageBrowseViewController alloc]init];
        __weak typeof(self) weakSelf = self;
        imageBrowserVC.DeleteImageBlock = ^(){
            weakSelf.selectedImage = nil;
            weakSelf.item.chargeImage = @"";
            weakSelf.item.chargeThumbImage = @"";
        };
        imageBrowserVC.NewImageSelectedBlock = ^(UIImage *image){
            weakSelf.selectedImage = image;
        };
        imageBrowserVC.type = SSJImageBrowseVcTypeEdite;
        imageBrowserVC.image = _selectedImage;
        imageBrowserVC.item = self.item;
        [self.navigationController pushViewController:imageBrowserVC animated:YES];
    } else {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄照片" ,@"从相册选择", nil];
        [sheet showInView:self.view];
        [_billTypeInputView.moneyInput resignFirstResponder];
        [_accessoryView.memoView resignFirstResponder];
    }
}

- (void)selectPeriodAction {
    [MobClick event:@"3"];
    self.ChargeCircleSelectView.selectCircleType = _selectChargeCircleType;
    [self.ChargeCircleSelectView show];
    [_billTypeInputView.moneyInput resignFirstResponder];
    [_accessoryView.memoView resignFirstResponder];
}

- (void)endEditingAction {
    [_billTypeSelectionView endEditing];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
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

#pragma mark - private
- (void)initData {
    NSDate *now = [NSDate date];
    _currentYear= now.year;
    _currentDay = now.day;
    _currentMonth = now.month;
    
    if (self.item == nil) {
        if (_selectedYear == 0) {
            self.selectedYear = _currentYear;
        }
        if (_selectedMonth == 0) {
            self.selectedMonth = _currentMonth;
        }
        if (_selectedDay == 0) {
            self.selectedDay = _currentDay;
        }
        self.selectChargeCircleType = -1;
    }else{
        [self getSelectedDateFromDate:self.item.billDate];
        if (self.item.ID == nil) {
            self.selectedYear = _currentYear;
            self.selectedMonth = _currentMonth;
            self.selectedDay = _currentDay;
        }else{
            self.selectedYear = _originaldYear;
            self.selectedMonth = _originaldMonth;
            self.selectedDay = _originaldDay;
        }
        self.categoryID = self.item.billId;
        if ([self.item.configId isEqualToString:@""] || (![self.item.billDate isEqualToString:[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]] && self.item.ID != nil)) {
            self.selectChargeCircleType = -1;
        }else{
            self.selectChargeCircleType = self.item.chargeCircleType;
        }
    }
    
    if (self.item != nil) {
        [self getSelectedFundingType];
    }else{
        if ([[NSUserDefaults standardUserDefaults]objectForKey:SSJLastSelectFundItemKey] == nil) {
            [self getDefualtFudingItem];
        }else{
            NSData *lastSelectFundingData = [[NSUserDefaults standardUserDefaults]objectForKey:SSJLastSelectFundItemKey];
            _selectItem = [NSKeyedUnarchiver unarchiveObjectWithData:lastSelectFundingData];
            [self updateFundingType];
        }
    }
}

-(void)getCategoryList{
    __weak typeof(self) weakSelf = self;
    [self.view ssj_showLoadingIndicator];
    [SSJCategoryListHelper queryForCategoryListWithIncomeOrExpenture:!self.titleSegment.selectedSegmentIndex Success:^(NSMutableArray *result) {
        __block NSInteger selectedIndex = 0;
        dispatch_apply([result count], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t index) {
            SSJRecordMakingBillTypeSelectionCellItem *item = [result ssj_safeObjectAtIndex:index];
            if (_item && _categoryID && [item.ID isEqualToString:_categoryID]) {
                selectedIndex = index;
            }
        });
        weakSelf.billTypeSelectionView.items = result;
        weakSelf.billTypeSelectionView.selectedIndex = selectedIndex;
        
        SSJRecordMakingBillTypeSelectionCellItem *selectedItem = [weakSelf.billTypeSelectionView.items ssj_safeObjectAtIndex:selectedIndex];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            weakSelf.billTypeInputView.backgroundColor = [UIColor ssj_colorWithHex:selectedItem.colorValue];
        }];
        weakSelf.billTypeInputView.billTypeName = selectedItem.title;
        
        if (![self showGuideViewIfNeeded]) {
            [weakSelf.billTypeInputView.moneyInput becomeFirstResponder];
        }
        
        if (!_item) {
            _categoryID = selectedItem.ID;
        }
        
        [self.view ssj_hideLoadingIndicator];
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
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
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
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

-(void)settitleSegment{
    _titleSegment = [[SSJSegmentedControl alloc]initWithItems:@[@"支出",@"收入"]];
    if (self.item == nil) {
        _titleSegment.selectedSegmentIndex = 0;
    }else{
        _titleSegment.selectedSegmentIndex = !self.item.incomeOrExpence;
    }
    _titleSegment.size = CGSizeMake(202, 30);
    _titleSegment.borderColor = [UIColor ssj_colorWithHex:@"CCCCCC"];
    _titleSegment.selectedBorderColor = [UIColor ssj_colorWithHex:@"EB4A64"];
    [_titleSegment setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex: @"a7a7a7"]} forState:UIControlStateNormal];
    [_titleSegment setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"EB4A64"]} forState:UIControlStateSelected];
    [_titleSegment addTarget: self action: @selector(segmentPressed:)forControlEvents: UIControlEventValueChanged];
    self.navigationItem.titleView = _titleSegment;
}

-(void)makeArecord{
    __weak typeof(self) weakSelf = self;
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
    if (self.selectChargeCircleType != -1) {
        NSString *selectDate = [NSString stringWithFormat:@"%ld-%02ld-%02ld",self.selectedYear,self.selectedMonth,self.selectedDay];
        if (![selectDate isEqualToString:[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]]) {
            [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"抱歉,暂不可设置历史日期的定期收入/支出哦~" action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
//            weakSelf.ChargeCircleSelectView.selectCircleType = -1;
//            [weakSelf.accessoryView.dateBtn setTitle:weakSelf.ChargeCircleSelectView.selectedPeriod forState:UIControlStateNormal];
            return;
        }
    }
    if (self.selectItem.fundingID == nil) {
        [CDAutoHideMessageHUD showMessage:@"请先添加资金账户"];
        return;
    }
    self.chargeMemo = _accessoryView.memoView.text;
    [[SSJDatabaseQueue sharedInstance]asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSMutableArray *editeChargeArr = [NSMutableArray arrayWithCapacity:0];
        double chargeMoney = [self.billTypeInputView.moneyInput.text doubleValue];
        NSString *operationTime = [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString *selectDate;
        NSString *userid= SSJUSERID();
        selectDate = [NSString stringWithFormat:@"%ld-%02ld-%02ld",self.selectedYear,self.selectedMonth,self.selectedDay];
        SSJFundingItem *fundingType = weakSelf.selectItem;
        NSString *imageName = SSJUUID();
        NSString *iconfigId;
        if (self.selectChargeCircleType == -1) {
            iconfigId = @"";
        }else{
            iconfigId = SSJUUID();
        }
        if (self.item == nil) {
            //新增流水
            NSString *chargeID = SSJUUID();
            if (weakSelf.titleSegment.selectedSegmentIndex == 0) {
                [db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE - ? WHERE CFUNDID = ? ",[NSNumber numberWithDouble:chargeMoney],fundingType.fundingID];
            }else{
                [db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE + ? WHERE CFUNDID = ? ",[NSNumber numberWithDouble:chargeMoney],fundingType.fundingID];
            }
            [db executeUpdate:@"INSERT INTO BK_USER_CHARGE (ICHARGEID , CUSERID , IMONEY , IBILLID , IFUNSID  , IOLDMONEY , IBALANCE , CWRITEDATE , IVERSION , OPERATORTYPE , CBILLDATE , CMEMO , ICONFIGID) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)",chargeID,userid,[NSNumber numberWithDouble:chargeMoney],weakSelf.categoryID,fundingType.fundingID,[NSNumber numberWithDouble:19.99],[NSNumber numberWithDouble:19.99],operationTime,@(SSJSyncVersion()),[NSNumber numberWithInt:0],selectDate,self.chargeMemo,iconfigId];
            if (weakSelf.selectChargeCircleType != -1) {
                [db executeUpdate:@"insert into BK_CHARGE_PERIOD_CONFIG (ICONFIGID , CUSERID , IBILLID , ITYPE , CBILLDATE , OPERATORTYPE , IVERSION , CWRITEDATE , IMONEY , IFUNSID , CMEMO , ISTATE) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)",iconfigId,userid,weakSelf.categoryID,[NSNumber numberWithInteger:weakSelf.selectChargeCircleType],selectDate,[NSNumber numberWithInt:0],@(SSJSyncVersion()),[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[NSNumber numberWithDouble:chargeMoney],fundingType.fundingID,weakSelf.chargeMemo,[NSNumber numberWithInt:1]];
            }
            if (weakSelf.selectedImage != nil) {
                if (SSJSaveImage(weakSelf.selectedImage, imageName)&&SSJSaveThumbImage(weakSelf.selectedImage, imageName)) {
                    [db executeUpdate:@"update BK_USER_CHARGE set CIMGURL = ? , THUMBURL = ? where ICHARGEID = ? AND CUSERID = ?",[NSString stringWithFormat:@"%@.jpg",imageName],[NSString stringWithFormat:@"%@-thumb.jpg",imageName],chargeID,SSJUSERID()];
                    [db executeUpdate:@"insert into BK_IMG_SYNC (RID , CIMGNAME , CWRITEDATE , OPERATORTYPE , ISYNCTYPE , ISYNCSTATE) values (?,?,?,?,?,?)",chargeID,[NSString stringWithFormat:@"%@.jpg",imageName],[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0]];
                    if (weakSelf.selectChargeCircleType != -1) {
                        [db executeUpdate:@"update BK_CHARGE_PERIOD_CONFIG set CIMGURL = ? where ICONFIGID = ?",[NSString stringWithFormat:@"%@.jpg",imageName],iconfigId];
                    }
                }
            }
            int count = [db intForQuery:@"SELECT COUNT(CBILLDATE) AS COUNT FROM BK_DAILYSUM_CHARGE WHERE CBILLDATE = ? AND CUSERID = ?",selectDate,userid];
            double incomeSum = 0.0;
            double expenseSum = 0.0;
            double sum = 0.0;
            if (count == 0) {
                if (self.titleSegment.selectedSegmentIndex == 0) {
                    expenseSum = expenseSum + chargeMoney;
                    sum = sum - chargeMoney;
                }else{
                    incomeSum = incomeSum + chargeMoney;
                    sum = sum + chargeMoney;
                }
                [db executeUpdate:@"INSERT INTO BK_DAILYSUM_CHARGE (CBILLDATE , EXPENCEAMOUNT , INCOMEAMOUNT  , SUMAMOUNT, ICHARGEID  , IBILLID , CWRITEDATE , CUSERID) VALUES(?,?,?,?,?,?,?,?)",selectDate,[NSNumber numberWithDouble:expenseSum],[NSNumber numberWithDouble:incomeSum],[NSNumber numberWithDouble:sum],@"0",@"-1",[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],userid];
            }else{
                FMResultSet *rs = [db executeQuery:@"SELECT EXPENCEAMOUNT, INCOMEAMOUNT , SUMAMOUNT FROM BK_DAILYSUM_CHARGE WHERE CBILLDATE = ? AND CUSERID = ?",selectDate,userid];
                while ([rs next]) {
                    incomeSum = [rs doubleForColumn:@"INCOMEAMOUNT"];
                    expenseSum = [rs doubleForColumn:@"EXPENCEAMOUNT"];
                    sum = [rs doubleForColumn:@"SUMAMOUNT"];
                }
                if (self.titleSegment.selectedSegmentIndex == 0) {
                    expenseSum = expenseSum + chargeMoney;
                    sum = sum - chargeMoney;
                    [db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET EXPENCEAMOUNT = ? , SUMAMOUNT = ? , CWRITEDATE = ? WHERE CBILLDATE = ? AND CUSERID = ?",[NSNumber numberWithDouble:expenseSum],[NSNumber numberWithDouble:sum],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],selectDate,userid];
                }else{
                    incomeSum = incomeSum + chargeMoney;
                    sum = sum + chargeMoney;
                    [db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET INCOMEAMOUNT = ? , SUMAMOUNT = ? , CWRITEDATE = ? WHERE CBILLDATE = ? AND CUSERID = ?",[NSNumber numberWithDouble:incomeSum],[NSNumber numberWithDouble:sum],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],selectDate,userid];
                }
            }
            SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc]init];
            item.ID = chargeID;
            item.operatorType = 1;
            [editeChargeArr addObject:item];
        }else if (self.item.ID != nil){
            //修改流水
            if ([db intForQuery:@"select operatortype from bk_user_charge where ichargeid = ?",weakSelf.item.ID] == 2) {
                [weakSelf.navigationController popViewControllerAnimated:YES];

                return;
            }
            if ([db executeUpdate:@"UPDATE BK_USER_CHARGE SET IMONEY = ? , IBILLID = ? , IFUNSID = ? , CWRITEDATE = ? , OPERATORTYPE = ? , CBILLDATE = ? , IVERSION = ? , CMEMO = ? WHERE ICHARGEID = ? AND CUSERID = ?",[NSNumber numberWithDouble:chargeMoney],weakSelf.categoryID,fundingType.fundingID,[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[NSNumber numberWithInt:1],selectDate,@(SSJSyncVersion()),self.chargeMemo , self.item.ID,userid]) {
                if (weakSelf.selectChargeCircleType != weakSelf.item.chargeCircleType && weakSelf.selectChargeCircleType != -1) {
                    if ([db executeUpdate:@"update BK_CHARGE_PERIOD_CONFIG set operatortype = 2 where iconfigid = ? and cuserid = ?",weakSelf.item.configId,userid]) {
                        if ([db executeUpdate:@"insert into BK_CHARGE_PERIOD_CONFIG (ICONFIGID , CUSERID , IBILLID , ITYPE , CBILLDATE , OPERATORTYPE , IVERSION , CWRITEDATE , IMONEY , IFUNSID , CMEMO , ISTATE) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)",iconfigId,userid,weakSelf.categoryID,[NSNumber numberWithInteger:weakSelf.selectChargeCircleType],selectDate,[NSNumber numberWithInt:0],@(SSJSyncVersion()),[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[NSNumber numberWithDouble:chargeMoney],fundingType.fundingID,weakSelf.chargeMemo,[NSNumber numberWithInt:1]]) {
                            [db executeUpdate:@"update BK_USER_CHARGE set ICONFIGID = ? where ICHARGEID = ? and CUSERID = ?",iconfigId,weakSelf.item.ID,userid];
                        }
                    }
                }else if (weakSelf.selectChargeCircleType == weakSelf.item.chargeCircleType && weakSelf.selectChargeCircleType != -1){
                    [db executeUpdate:@"update BK_CHARGE_PERIOD_CONFIG set IBILLID = ? , CBILLDATE = ? , OPERATORTYPE = ? , IVERSION = ? , CWRITEDATE = ? , IMONEY = ? , IFUNSID = ? , CMEMO = ? , ISTATE = ? where iconfigid = ? and cuserid = ?",weakSelf.categoryID,selectDate,[NSNumber numberWithInt:1],@(SSJSyncVersion()),[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[NSNumber numberWithDouble:chargeMoney],fundingType.fundingID,weakSelf.chargeMemo,[NSNumber numberWithInt:1],weakSelf.item.configId,userid];
                }else if (weakSelf.selectChargeCircleType == -1 && weakSelf.item.chargeCircleType != -1){
                    if ([db executeUpdate:@"update bk_user_charge set iconfigid = '' where ichargeid = ?",weakSelf.item.ID]) {
                        [db executeUpdate:@"update BK_CHARGE_PERIOD_CONFIG set operatortype = 2 where iconfigid = ?",weakSelf.item.configId];
                    }
                }
                if (weakSelf.selectedImage != nil) {
                    if (SSJSaveImage(weakSelf.selectedImage, imageName)&&SSJSaveThumbImage(weakSelf.selectedImage, imageName)) {
                        [db executeUpdate:@"update BK_USER_CHARGE set CIMGURL = ? , THUMBURL = ? where ICHARGEID = ? AND CUSERID = ?",[NSString stringWithFormat:@"%@.jpg",imageName],[NSString stringWithFormat:@"%@-thumb.jpg",imageName],weakSelf.item.ID,userid];
                        [db executeUpdate:@"insert into BK_IMG_SYNC (RID , CIMGNAME , CWRITEDATE , OPERATORTYPE , ISYNCTYPE , ISYNCSTATE) values (?,?,?,?,?,?)",weakSelf.item.ID,[NSString stringWithFormat:@"%@.jpg",imageName],[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0]];
                        if (weakSelf.item.chargeImage != nil && ![weakSelf.item.chargeImage isEqualToString:@""]) {
                            if (([db intForQuery:@"select * from BK_IMG_SYNC where CIMGNAME = ? and RID <> ?",weakSelf.item.chargeImage,weakSelf.item.ID]+[db intForQuery:@"select * from BK_USER_CHARGE where CIMGURL = ? and ICHARGEID <> ?",weakSelf.item.chargeImage,weakSelf.item.ID] == 0)) {
                                [[NSFileManager defaultManager] removeItemAtPath:SSJImagePath(weakSelf.item.chargeImage) error:nil];
                                [[NSFileManager defaultManager] removeItemAtPath:SSJImagePath(weakSelf.item.chargeThumbImage) error:nil];
                                [db executeUpdate:@"delete from BK_IMG_SYNC where CIMGNAME = ?",weakSelf.item.chargeImage];
                            }
                        }
                    }
                }else if(self.item.chargeImage.length == 0){
                    [db executeUpdate:@"update BK_USER_CHARGE set CIMGURL = ? , THUMBURL = ? where ICHARGEID = ? AND CUSERID = ?",@"",@"",weakSelf.item.ID,userid];
                    [db executeUpdate:@"delete from BK_IMG_SYNC where RID = ?",self.item.ID];
                }
                SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc]init];
                item.ID = self.item.ID;
                item.operatorType = 2;
                [editeChargeArr addObject:item];
            }
            if (self.titleSegment.selectedSegmentIndex == 0) {
                [db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE - ? WHERE CFUNDID = ? AND CUSERID = ?",[NSNumber numberWithDouble:chargeMoney],fundingType.fundingID,userid];
                if([db intForQuery:@"SELECT COUNT(*) FROM BK_DAILYSUM_CHARGE WHERE CBILLDATE = ? AND CUSERID = ?",selectDate,userid]){
                    [db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET SUMAMOUNT = SUMAMOUNT - ? , EXPENCEAMOUNT = EXPENCEAMOUNT + ? , CWRITEDATE = ? WHERE CBILLDATE = ? AND CUSERID = ?",[NSNumber numberWithDouble:chargeMoney],[NSNumber numberWithDouble:chargeMoney],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],selectDate,userid];
                }else{
                    [db executeUpdate:@"INSERT INTO BK_DAILYSUM_CHARGE (CBILLDATE , EXPENCEAMOUNT , INCOMEAMOUNT  , SUMAMOUNT , ICHARGEID  , IBILLID , CWRITEDATE , CUSERID) VALUES(?,?,?,?,?,?,?,?)",selectDate,[NSNumber numberWithDouble:chargeMoney],[NSNumber numberWithDouble:0],[NSNumber numberWithDouble:(-chargeMoney)],@"0",@"-1",[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],userid];
                }
            }else{
                [db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE + ? WHERE CFUNDID = ? AND CUSERID = ?", [NSNumber numberWithDouble:chargeMoney] , fundingType.fundingID,userid];
                if([db intForQuery:@"SELECT COUNT(*) FROM BK_DAILYSUM_CHARGE WHERE CBILLDATE = ? AND CUSERID = ?",selectDate,userid]){
                    [db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET SUMAMOUNT = SUMAMOUNT + ? , INCOMEAMOUNT = INCOMEAMOUNT + ? , CWRITEDATE = ? WHERE CBILLDATE = ? AND CUSERID = ?",[NSNumber numberWithDouble:chargeMoney],[NSNumber numberWithDouble:chargeMoney],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],selectDate,userid];
                }else{
                    [db executeUpdate:@"INSERT INTO BK_DAILYSUM_CHARGE (CBILLDATE , EXPENCEAMOUNT , INCOMEAMOUNT  , SUMAMOUNT , ICHARGEID  , IBILLID , CWRITEDATE , CUSERID) VALUES(?,?,?,?,?,?,?,?)",selectDate,[NSNumber numberWithDouble:0],[NSNumber numberWithDouble:chargeMoney],[NSNumber numberWithDouble:chargeMoney],@"0",@"-1",[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],userid];
                }
            }
            if ([db intForQuery:@"SELECT ITYPE FROM BK_BILL_TYPE WHERE ID = ?",weakSelf.item.billId])
            {
                [db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE + ? WHERE CFUNDID = ? AND CUSERID = ?",[NSNumber numberWithDouble:[self.item.money doubleValue]],weakSelf.item.fundId,userid];
                [db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET SUMAMOUNT = SUMAMOUNT + ? , EXPENCEAMOUNT = EXPENCEAMOUNT - ? ,CWRITEDATE = ? WHERE CBILLDATE = ? AND CUSERID = ?",[NSNumber numberWithDouble:[weakSelf.item.money doubleValue]],[NSNumber numberWithDouble:[weakSelf.item.money doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],weakSelf.item.billDate,userid];
            }else{
                [db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE - ? WHERE CFUNDID = ? AND CUSERID = ?",[NSNumber numberWithDouble:[self.item.money doubleValue]],weakSelf.item.fundId,userid];
                [db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET SUMAMOUNT = SUMAMOUNT - ? , INCOMEAMOUNT = INCOMEAMOUNT - ? , CWRITEDATE = ? WHERE CBILLDATE = ? AND CUSERID = ?",[NSNumber numberWithDouble:[weakSelf.item.money doubleValue]],[NSNumber numberWithDouble:[weakSelf.item.money doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],weakSelf.item.billDate,userid];
            }
            if (SSJSyncSetting() == SSJSyncSettingTypeWIFI) {
                [[SSJDataSynchronizer shareInstance]startSyncWithSuccess:NULL failure:NULL];
            }
        }else{
            //修改循环记账配置
            if ([db intForQuery:@"select operatortype from BK_CHARGE_PERIOD_CONFIG where ICONFIGID = ?",weakSelf.item.configId] == 2) {
                return;
            }
            if (weakSelf.selectChargeCircleType == weakSelf.item.chargeCircleType && weakSelf.selectChargeCircleType != -1){
                [db executeUpdate:@"update BK_CHARGE_PERIOD_CONFIG set IBILLID = ? , ITYPE = ? , OPERATORTYPE = ? , IVERSION = ? , CWRITEDATE = ? , IMONEY = ? , CBILLDATE = ? , IFUNSID = ? , CMEMO = ? where ICONFIGID = ? and CUSERID = ?",weakSelf.categoryID,[NSNumber numberWithInteger:weakSelf.selectChargeCircleType],[NSNumber numberWithInt:1],@(SSJSyncVersion()),[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[NSNumber numberWithDouble:chargeMoney],selectDate,fundingType.fundingID,weakSelf.chargeMemo,weakSelf.item.configId,userid];
                if (weakSelf.selectedImage != nil) {
                    SSJSaveImage(weakSelf.selectedImage, imageName);
                    [db executeUpdate:@"update BK_CHARGE_PERIOD_CONFIG set CIMGURL = ? where ICONFIGID = ? AND CUSERID = ?",[NSString stringWithFormat:@"%@.jpg",imageName],weakSelf.item.configId,userid];
                }else{
                    [db executeUpdate:@"update BK_CHARGE_PERIOD_CONFIG set CIMGURL = ? where ICONFIGID = ? AND CUSERID = ?",@"",weakSelf.item.configId,userid];
                }
            }else{
                if ([db executeUpdate:@"update BK_CHARGE_PERIOD_CONFIG set operatortype = 2, iversion = ? where iconfigid = ? and cuserid = ?", @(SSJSyncVersion()),weakSelf.item.configId,userid]) {
                    [db executeUpdate:@"insert into BK_CHARGE_PERIOD_CONFIG (ICONFIGID , CUSERID , IBILLID , ITYPE , CBILLDATE , OPERATORTYPE , IVERSION , CWRITEDATE , IMONEY , IFUNSID , CMEMO , ISTATE) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)",iconfigId,userid,weakSelf.categoryID,[NSNumber numberWithInteger:weakSelf.selectChargeCircleType],selectDate,[NSNumber numberWithInt:0],@(SSJSyncVersion()),[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[NSNumber numberWithDouble:chargeMoney],fundingType.fundingID,weakSelf.chargeMemo,[NSNumber numberWithInt:1]];
                    if (weakSelf.selectedImage != nil) {
                        SSJSaveImage(weakSelf.selectedImage, imageName);
                     [db executeUpdate:@"insert into BK_IMG_SYNC (RID , CIMGNAME , CWRITEDATE , OPERATORTYPE , ISYNCTYPE , ISYNCSTATE) values (?,?,?,?,?,?)",weakSelf.item.configId,[NSString stringWithFormat:@"%@.jpg",imageName],[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0]];
                    }else{
                    [db executeUpdate:@"insert into BK_IMG_SYNC (RID , CIMGNAME , CWRITEDATE , OPERATORTYPE , ISYNCTYPE , ISYNCSTATE) values (?,?,?,?,?,?)",weakSelf.item.configId,@"",[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0]];
                        if (weakSelf.item.chargeImage != nil && ![weakSelf.item.chargeImage isEqualToString:@""]) {
                            if ([db intForQuery:@"select * from BK_IMG_SYNC where CIMGNAME = ? and RID <> ?",weakSelf.item.chargeImage,weakSelf.item.configId]+[db intForQuery:@"select * from BK_USER_CHARGE where CIMGURL = ? and ICHARGEID <> ?",weakSelf.item.chargeImage,weakSelf.item.ID] == 0) {
                                [[NSFileManager defaultManager] removeItemAtPath:SSJImagePath(weakSelf.item.chargeImage) error:nil];
                                [[NSFileManager defaultManager] removeItemAtPath:SSJImagePath(weakSelf.item.chargeThumbImage) error:nil];
                                [db executeUpdate:@"delete from BK_IMG_SYNC where CIMGNAME = ?",weakSelf.item.chargeImage];
                            }
                        }
                    }
                }
            }
            if (SSJSyncSetting() == SSJSyncSettingTypeWIFI) {
                [[SSJDataSynchronizer shareInstance]startSyncWithSuccess:NULL failure:NULL];
            }
        }
        if (self.addNewChargeBlock) {
            self.addNewChargeBlock(editeChargeArr);
        }
        [db executeUpdate:@"DELETE FROM BK_DAILYSUM_CHARGE WHERE SUMAMOUNT = 0 AND INCOMEAMOUNT = 0 AND EXPENCEAMOUNT = 0"];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:NULL];
        });
    }];
}

-(void)getDefualtFudingItem{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db){
        FMResultSet * rs = [db executeQuery:@"SELECT A.* , B.IBALANCE FROM BK_FUND_INFO  A , BK_FUNS_ACCT B WHERE CPARENT != ? AND A.CFUNDID = B.CFUNDID AND A.OPERATORTYPE <> 2 AND A.CUSERID = ? LIMIT 1",@"root",SSJUSERID()];
        weakSelf.defualtItem = [[SSJFundingItem alloc]init];
        while ([rs next]) {
            weakSelf.defualtItem.fundingColor = [rs stringForColumn:@"CCOLOR"];
            weakSelf.defualtItem.fundingIcon = [rs stringForColumn:@"CICOIN"];
            weakSelf.defualtItem.fundingID = [rs stringForColumn:@"CFUNDID"];
            weakSelf.defualtItem.fundingName = [rs stringForColumn:@"CACCTNAME"];
            weakSelf.defualtItem.fundingParent = [rs stringForColumn:@"CPARENT"];
            weakSelf.defualtItem.fundingBalance = [rs doubleForColumn:@"IBALANCE"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.selectItem = _defualtItem;
            [self updateFundingType];
        });
    }];
}

-(void)getSelectedFundingType{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        FMResultSet * rs = [db executeQuery:@"SELECT A.* , B.IBALANCE FROM BK_FUND_INFO  A , BK_FUNS_ACCT B WHERE A.CFUNDID = B.CFUNDID AND A.CFUNDID = ? AND A.CUSERID = ? AND A.OPERATORTYPE != 2",self.item.fundId,userid];
        _defualtItem = [[SSJFundingItem alloc]init];
        while ([rs next]) {
            weakSelf.defualtItem.fundingColor = [rs stringForColumn:@"CCOLOR"];
            weakSelf.defualtItem.fundingIcon = [rs stringForColumn:@"CICOIN"];
            weakSelf.defualtItem.fundingID = [rs stringForColumn:@"CFUNDID"];
            weakSelf.defualtItem.fundingName = [rs stringForColumn:@"CACCTNAME"];
            weakSelf.defualtItem.fundingParent = [rs stringForColumn:@"CPARENT"];
            weakSelf.defualtItem.fundingBalance = [rs doubleForColumn:@"IBALANCE"];
        }
        if (weakSelf.defualtItem.fundingID == nil) {
            [weakSelf getDefualtFudingItem];
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.selectItem = weakSelf.defualtItem;
            [self updateFundingType];
        });
    }];
}

-(void)getSelectedDateFromDate:(NSString*)date{
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
    [dateFormater setDateFormat:@"yyyy-MM-dd"];
    NSDate *selectDate = [dateFormater dateFromString:date];
    _originaldYear= selectDate.year;
    _originaldDay = selectDate.day;
    _originaldMonth = selectDate.month;
}

- (void)updatePeriodButtonTitle {
    if (self.ChargeCircleSelectView.selectCircleType == -1) {
        [_accessoryView.periodBtn setTitle:@"设置循环" forState:UIControlStateNormal];
        _accessoryView.periodBtn.selected = NO;
    } else {
        [_accessoryView.periodBtn setTitle:self.ChargeCircleSelectView.selectedPeriod forState:UIControlStateNormal];
        _accessoryView.periodBtn.selected = YES;
    }
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
        [UIView transitionWithView:window duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [window addSubview:_guideView];
        } completion:NULL];
    }
    return !isEverEntered;
}

//-(void)closeButtonClicked:(id)sender{
//    [self ssj_backOffAction];
//}

-(void)reloadDataAfterSync{
//    [self.categoryListView reloadData];
}

@end
