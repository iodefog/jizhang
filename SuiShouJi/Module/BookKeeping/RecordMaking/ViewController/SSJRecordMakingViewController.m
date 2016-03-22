//
//  SSJRecordMakingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/16.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingViewController.h"
#import "SSJCustomKeyboard.h"
#import "SSJCategoryCollectionView.h"
#import "SSJCategoryListView.h"
#import "SSJCalendarView.h"
#import "SSJDateSelectedView.h"
#import "SSJCalendarCollectionViewCell.h"
#import "SSJFundingTypeSelectView.h"
#import "SSJCategoryCollectionViewCell.h"
#import "SSJADDNewTypeViewController.h"
#import "SSJSegmentedControl.h"
#import "SSJSmallCalendarView.h"
#import "SSJRecordMakingAdditionalView.h"
#import "SSJNewFundingViewController.h"
#import "UIButton+WebCache.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "SSJImaageBrowseViewController.h"
#import "SSJChargeCircleSelectView.h"
#import "SSJMemoMakingViewController.h"
#import "FMDB.h"
#import "FMDatabaseAdditions.h"

static const NSTimeInterval kAnimationDuration = 0.2;

@interface SSJRecordMakingViewController ()
@property (nonatomic,strong) SSJCategoryCollectionView* collectionView;
@property (nonatomic,strong) UIView* selectedCategoryView;
@property (nonatomic,strong) SSJRecordMakingAdditionalView* additionalView;
@property (nonatomic,strong) UIView* inputTopView;
@property (nonatomic,strong) SSJSegmentedControl *titleSegment;
@property (nonatomic,strong) UITextField* textInput;
@property (nonatomic,strong) UIImage *selectedImage;
@property (nonatomic,strong) UILabel* categoryNameLabel;
@property (nonatomic,strong) UIImageView* categoryImage;
@property (nonatomic,strong) SSJCategoryListView* categoryListView;
@property (nonatomic,strong) SSJDateSelectedView *DateSelectedView;
@property (nonatomic,strong) UIButton *datePickerButton;
@property (nonatomic,strong) SSJFundingTypeSelectView *FundingTypeSelectView;
@property (nonatomic,strong) UIButton *fundingTypeButton;
@property (nonatomic,strong) SSJSmallCalendarView *calendarView;
@property (nonatomic,strong) SSJChargeCircleSelectView *ChargeCircleSelectView;
@property (nonatomic) NSInteger selectChargeCircleType;
@property (nonatomic,strong) NSString *chargeMemo;
@property (nonatomic,strong) NSString *categoryID;
@property (nonatomic,strong) NSString *defualtID;
@property (nonatomic,strong) SSJFundingItem *selectItem;
@property (nonatomic,strong) SSJFundingItem *defualtItem;



@property (nonatomic) long currentYear;
@property (nonatomic) long currentMonth;
@property (nonatomic) long currentDay;
@end

@implementation SSJRecordMakingViewController{
    BOOL _numkeyHavePressed;
    NSString *_caculationResult;
    NSString *_firstNum;
    float _caculationValue;
    NSInteger _lastPressNum;
    NSString *_intPart;
    NSString *_decimalPart;
    int _decimalCount;
    NSString *_defualtColor;
    NSString *_defualtImage;
    BOOL _defualtType;
    long _originaldMonth;
    long _originaldYear;
    long _originaldDay;
}
#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.textInput becomeFirstResponder];
    [self ssj_showBackButtonWithImage:[UIImage imageNamed:@"close"] target:self selector:@selector(closeButtonClicked:)];
    _numkeyHavePressed = NO;
    [self getCurrentDate];
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
        if (!(self.item.chargeImage == nil || [self.item.chargeImage isEqualToString:@""])) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:SSJImagePath(self.item.chargeImage)]) {
                self.selectedImage = [UIImage imageWithContentsOfFile:SSJImagePath(self.item.chargeImage)];
            }else{
                __weak typeof(self) weakSelf = self;
                [self.additionalView.takePhotoButton sd_setBackgroundImageWithURL:[NSURL URLWithString:SSJGetChargeImageUrl(weakSelf.item.chargeImage)] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"paizhao"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    weakSelf.selectedImage = image;
                }];
            }
        }else{
            self.selectedImage = nil;
        }
        self.chargeMemo = self.item.chargeMemo;
    }
    [self getDefualtColorAndDefualtId];
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
    [self settitleSegment];
    [self.view addSubview:self.selectedCategoryView];
    [self.selectedCategoryView addSubview:self.textInput];
    [self.selectedCategoryView addSubview:self.categoryImage];
    [self.view addSubview:self.additionalView];
    [self.view addSubview:self.inputTopView];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.categoryListView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor whiteColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
}

-(void)viewDidLayoutSubviews{
    self.selectedCategoryView.leftTop = CGPointMake(0, 0);
    self.selectedCategoryView.size = CGSizeMake(self.view.width, 71);
    self.categoryImage.left = 20.0f;
    _decimalCount = 0;
    self.categoryImage.centerY = self.selectedCategoryView.centerY;
    self.textInput.right = self.selectedCategoryView.right - 12;
    self.textInput.centerY = self.categoryImage.centerY;
    self.additionalView.height = 200;
    self.additionalView.bottom = self.view.height;
    self.categoryListView.top = self.selectedCategoryView.bottom;
    self.inputTopView.bottom = self.additionalView.top;
    self.categoryListView.size = CGSizeMake(self.view.width, self.view.height - 260 - self.selectedCategoryView.bottom);
}

#pragma mark - Getter
//-(SSJCustomKeyboard*)customKeyBoard{
//    if (!_customKeyBoard) {
//        _customKeyBoard = [[SSJCustomKeyboard alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 200)];
//    }
//    return _customKeyBoard;
//}

-(UIView*)selectedCategoryView{
    if (!_selectedCategoryView) {
        _selectedCategoryView = [[UIView alloc]init];
//        _selectedCategoryView.backgroundColor = [UIColor redColor];
        _selectedCategoryView.backgroundColor = [UIColor ssj_colorWithHex:_defualtColor];
    }
    return _selectedCategoryView;
}

-(SSJCategoryListView*)categoryListView{
    if (_categoryListView == nil) {
        _categoryListView = [[SSJCategoryListView alloc]initWithFrame:CGRectZero];
        _categoryListView.selectedId = self.defualtID;
        [_categoryListView reloadData];
        if (self.item == nil) {
            _categoryListView.incomeOrExpence = !_titleSegment.selectedSegmentIndex;
        }else{
            _categoryListView.incomeOrExpence = self.item.incomeOrExpence;
        }
        [_categoryListView reloadData];
        __weak typeof(self) weakSelf = self;
        _categoryListView.CategorySelectedBlock = ^(SSJRecordMakingCategoryItem *item){
            weakSelf.categoryID = item.categoryTitle;
            if (![item.categoryTitle isEqualToString:@"添加"]) {
                [UIView animateWithDuration:kAnimationDuration animations:^{
                    weakSelf.categoryNameLabel.text = item.categoryTitle;
                    [weakSelf.categoryNameLabel sizeToFit];
                    weakSelf.selectedCategoryView.backgroundColor = [UIColor ssj_colorWithHex:item.categoryColor];
                    weakSelf.categoryImage.tintColor = [UIColor whiteColor];
                    weakSelf.categoryImage.image = [[UIImage imageNamed:item.categoryImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    weakSelf.categoryID = item.categoryID;
                }];
            }else{
                SSJADDNewTypeViewController *addNewTypeVc = [[SSJADDNewTypeViewController alloc]init];
                addNewTypeVc.incomeOrExpence = !
                weakSelf.titleSegment.selectedSegmentIndex;
                addNewTypeVc.NewCategorySelectedBlock = ^(NSString *categoryID,SSJRecordMakingCategoryItem *item){
                    weakSelf.categoryListView.selectedId = categoryID;
                    weakSelf.categoryID = categoryID;
                    weakSelf.categoryImage.image = [[UIImage imageNamed:item.categoryImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    weakSelf.selectedCategoryView.backgroundColor = [UIColor ssj_colorWithHex:item.categoryColor];
                    [weakSelf.categoryListView reloadData];
                };
                [weakSelf.navigationController pushViewController:addNewTypeVc animated:YES];
            }
        };
    }
    return _categoryListView;
}

-(UITextField*)textInput{
    if (!_textInput) {
        _textInput = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
        _textInput.tintColor = [UIColor whiteColor];
        _textInput.inputView = [SSJCustomKeyboard sharedInstance];
        _textInput.delegate = self;
        _textInput.textColor = [UIColor whiteColor];
        _textInput.font = [UIFont systemFontOfSize:30];
        _textInput.textAlignment = NSTextAlignmentRight;
        _textInput.placeholder = @"0.00";
        [_textInput setValue:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        if (self.item != nil) {
            _textInput.text = [NSString stringWithFormat:@"%.2f",[self.item.money doubleValue]];
            _textInput.textColor = [UIColor whiteColor];
        }
    }
    return _textInput;
}

-(UIImageView*)categoryImage{
    if (!_categoryImage) {
        _categoryImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        _categoryImage.layer.masksToBounds = YES;
        _categoryImage.tintColor = [UIColor whiteColor];
        _categoryImage.image = [[UIImage imageNamed:_defualtImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return _categoryImage;
}

-(SSJRecordMakingAdditionalView*)additionalView{
    if (!_additionalView ) {
        _additionalView = [SSJRecordMakingAdditionalView RecordMakingAdditionalView];
        [_additionalView ssj_setBorderColor:[UIColor ssj_colorWithHex:@"cccccc"]];
        [_additionalView ssj_setBorderStyle:SSJBorderStyleTop];
        _additionalView.selectedImage = self.selectedImage;
        if (![self.item.chargeMemo isEqualToString:@""] && self.item.chargeMemo != nil) {
            _additionalView.hasMemo = YES;
        }else{
            _additionalView.hasMemo = NO;
        }
        if (self.selectChargeCircleType != -1) {
            _additionalView.hasCircle = YES;
        }else{
            _additionalView.hasCircle = NO;
        }
        _additionalView.frame = CGRectMake(0, 0, self.view.width, 200);
        _additionalView.selectedImage = self.selectedImage;
        __weak typeof(self) weakSelf = self;
        _additionalView.btnClickedBlock = ^(NSInteger buttonTag){
            if (buttonTag == 1) {
                if (weakSelf.selectedImage == nil) {
                    UIActionSheet *sheet;
                    sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:weakSelf cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄照片" ,@"从相册选择", nil];
                    [sheet showInView:weakSelf.view];
                }else{
                    SSJImaageBrowseViewController *imageBrowserVC = [[SSJImaageBrowseViewController alloc]init];
                    imageBrowserVC.image = weakSelf.selectedImage;
                    imageBrowserVC.NewImageSelectedBlock = ^(UIImage *image){
                        weakSelf.additionalView.selectedImage = image;
                        weakSelf.selectedImage = image;
                    };
                    imageBrowserVC.DeleteImageBlock = ^(){
                        weakSelf.additionalView.selectedImage = nil;
                        weakSelf.selectedImage = nil;
                    };
                    [weakSelf.navigationController pushViewController:imageBrowserVC animated:YES];
                }
            }else if (buttonTag == 4){
                if ([weakSelf.textInput.text isEqualToString:@"0.00"] || [weakSelf.textInput.text isEqualToString:@""]) {
                    [CDAutoHideMessageHUD showMessage:@"记账金额不能为0"];
                    return;
                }
                [weakSelf makeArecord];
            }else if (buttonTag == 3){
                [[UIApplication sharedApplication].keyWindow addSubview:weakSelf.ChargeCircleSelectView];
            }else if (buttonTag == 2){
                SSJMemoMakingViewController *memoMakingVC = [[SSJMemoMakingViewController alloc]init];
                memoMakingVC.oldMemo = weakSelf.chargeMemo;
                memoMakingVC.MemoMakingBlock = ^(NSString *newMemo){
                    if (![newMemo isEqualToString:@""]) {
                        weakSelf.chargeMemo = newMemo;
                        weakSelf.additionalView.hasMemo = YES;
                    }else{
                        weakSelf.additionalView.hasMemo = NO;
                    }
                };
                [weakSelf.navigationController pushViewController:memoMakingVC animated:YES];
            }
        };
    }
    return _additionalView;
}

-(UIView*)inputTopView{
    if (!_inputTopView ) {
        _inputTopView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
        _inputTopView.backgroundColor = [UIColor whiteColor];
        [_inputTopView addSubview:self.fundingTypeButton];
        self.datePickerButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.width / 2 + 10, 0, self.view.width / 2 - 30, 40)];
        _datePickerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.datePickerButton setTitle:[NSString stringWithFormat:@"%ld月",self.selectedMonth] forState:UIControlStateNormal];
        [self.datePickerButton setTitleColor:[UIColor ssj_colorWithHex:@"393939"] forState:UIControlStateNormal];
        self.datePickerButton.titleLabel.font = [UIFont systemFontOfSize:14];
        self.datePickerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 60, 0, 30);
        [self.datePickerButton addTarget:self action:@selector(datePickerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_inputTopView addSubview:self.datePickerButton];
        self.calendarView.currentDay = [NSString stringWithFormat:@"%02ld",self.selectedDay];
        self.calendarView.frame = CGRectMake(self.datePickerButton.width - 20, 0, 24, 24);
        self.calendarView.centerY = self.datePickerButton.height / 2;
        [self.datePickerButton addSubview:self.calendarView];
    }
    return _inputTopView;
}

- (UIButton *)fundingTypeButton {
    if (!_fundingTypeButton) {
        _fundingTypeButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, self.view.width / 2, 40)];
        [_fundingTypeButton setTitleColor:[UIColor ssj_colorWithHex:@"393939"] forState:UIControlStateNormal];
        _fundingTypeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _fundingTypeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _fundingTypeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [_fundingTypeButton addTarget:self action:@selector(fundingTypeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fundingTypeButton;
}

- (void)updateFundingType {
    [self.fundingTypeButton setTitle:_selectItem.fundingName forState:UIControlStateNormal];
    [self.fundingTypeButton setImage:[UIImage imageNamed:_selectItem.fundingIcon] forState:UIControlStateNormal];
    self.FundingTypeSelectView.selectFundID = _selectItem.fundingID;
}

-(SSJDateSelectedView*)DateSelectedView{
    if (!_DateSelectedView) {
        _DateSelectedView = [[SSJDateSelectedView alloc]initWithFrame:[UIScreen mainScreen].bounds forYear:self.selectedYear Month:self.selectedMonth Day:self.selectedDay];
        __weak typeof(self) weakSelf = self;
        _DateSelectedView.calendarView.DateSelectedBlock = ^(long year , long month ,long day,  NSString *selectDate){
            weakSelf.selectedDay = day;
            weakSelf.selectedMonth = month;
            weakSelf.selectedYear = year;
            [weakSelf.datePickerButton setTitle:[NSString stringWithFormat:@"%ld月",weakSelf.selectedMonth] forState:UIControlStateNormal];
            weakSelf.calendarView.currentDay = [NSString stringWithFormat:@"%02ld",weakSelf.selectedDay];
            for (int i = 0; i < [self.DateSelectedView.calendarView.calendar.visibleCells count]; i ++) {
                if ([((SSJCalendarCollectionViewCell*)[weakSelf.DateSelectedView.calendarView.calendar.visibleCells objectAtIndex:i]).currentDay integerValue] == day && ((SSJCalendarCollectionViewCell*)[weakSelf.DateSelectedView.calendarView.calendar.visibleCells objectAtIndex:i]).selectable == YES) {
                    ((SSJCalendarCollectionViewCell*)[weakSelf.DateSelectedView.calendarView.calendar.visibleCells objectAtIndex:i]).isSelected = YES;
                }else{
                    ((SSJCalendarCollectionViewCell*)[weakSelf.DateSelectedView.calendarView.calendar.visibleCells objectAtIndex:i]).isSelected = NO;
                }
            }
            [weakSelf.DateSelectedView removeFromSuperview];
            [weakSelf.textInput becomeFirstResponder];
        };
    }
    return _DateSelectedView;
}

-(SSJCategoryCollectionView*)collectionView{
    if (!_collectionView) {
        _collectionView = [[SSJCategoryCollectionView alloc]init];
        _collectionView.frame = CGRectMake(0, 0, self.view.width, 230);
    }
    return _collectionView;
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
                    [weakSelf.fundingTypeButton setTitle:newFundingItem.fundingName forState:UIControlStateNormal];
                    [weakSelf.fundingTypeButton setImage:[UIImage imageNamed:newFundingItem.fundingIcon] forState:UIControlStateNormal];
                    weakSelf.selectItem = newFundingItem;
                    [weakSelf updateFundingType];
                };
                [weakSelf.navigationController pushViewController:NewFundingVC animated:YES];
            }
            [weakSelf.FundingTypeSelectView removeFromSuperview];
            [weakSelf.textInput becomeFirstResponder];
        };
    }
    return _FundingTypeSelectView;
}

-(SSJSmallCalendarView *)calendarView{
    if (!_calendarView) {
        _calendarView = [[SSJSmallCalendarView alloc]init];
    }
    return _calendarView;
}

-(SSJChargeCircleSelectView *)ChargeCircleSelectView{
    if (!_ChargeCircleSelectView) {
        _ChargeCircleSelectView = [[SSJChargeCircleSelectView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _ChargeCircleSelectView.selectCircleType = self.selectChargeCircleType;
        _ChargeCircleSelectView.incomeOrExpenture = self.titleSegment.selectedSegmentIndex;
        __weak typeof(self) weakSelf = self;
        _ChargeCircleSelectView.chargeCircleSelectBlock = ^(NSInteger chargeCircleType){
            if (weakSelf.selectedYear < weakSelf.currentYear || (weakSelf.selectedYear == weakSelf.currentYear && weakSelf.selectedMonth < weakSelf.currentMonth) ||  (weakSelf.selectedYear == weakSelf.currentYear && weakSelf.selectedMonth == weakSelf.currentMonth && weakSelf.selectedDay < weakSelf.currentDay) ) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"抱歉,暂不可设置历史日期的定期收入/支出哦~" delegate:weakSelf cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
                weakSelf.ChargeCircleSelectView.selectCircleType = -1;
                weakSelf.additionalView.hasCircle = NO;
            }else if (weakSelf.selectedDay > 28 && chargeCircleType != 6 && chargeCircleType == 4){
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"抱歉,每月天数不固定,暂不支持每月设置次日期." delegate:weakSelf cancelButtonTitle:@"确定" otherButtonTitles: nil];
                weakSelf.ChargeCircleSelectView.selectCircleType = -1;
                weakSelf.additionalView.hasCircle = NO;
                [alert show];
            }else{
                weakSelf.selectChargeCircleType = chargeCircleType;
                if (chargeCircleType == -1) {
                    weakSelf.additionalView.hasCircle = NO;
                }else{
                    weakSelf.additionalView.hasCircle = YES;

                }
            }
        };
    }
    return _ChargeCircleSelectView;
}

#pragma mark - UITextFieldDelegate
-(void)textFieldDidChange:(id)sender{
    [self setupTextFiledNum:self.textInput num:2];
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
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.additionalView.selectedImage = image;
    _selectedImage = image;
}


#pragma mark - private
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
    _titleSegment.size = CGSizeMake(115, 30);
    _titleSegment.tintColor = [UIColor ssj_colorWithHex:@"CCCCCC"];
    NSDictionary *dictForNormal = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor ssj_colorWithHex: @"a7a7a7"],NSForegroundColorAttributeName,[UIFont systemFontOfSize:15],NSFontAttributeName,nil];
    [_titleSegment setTitleTextAttributes:dictForNormal forState:UIControlStateNormal];
    NSDictionary *dictForSelected = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor ssj_colorWithHex:@"47cfbe"],NSForegroundColorAttributeName,[UIFont systemFontOfSize:15],NSFontAttributeName,nil];
    [_titleSegment setTitleTextAttributes:dictForSelected forState:UIControlStateSelected];
    [_titleSegment addTarget: self action: @selector(segmentPressed:)forControlEvents: UIControlEventValueChanged];
    self.navigationItem.titleView = _titleSegment;
}

-(void)datePickerButtonClicked:(UIButton*)button{
    [[UIApplication sharedApplication].keyWindow addSubview:self.DateSelectedView];
    [self.textInput resignFirstResponder];
}

-(void)fundingTypeButtonClicked:(UIButton*)button{
    [[UIApplication sharedApplication].keyWindow addSubview:self.FundingTypeSelectView];
    [self.textInput resignFirstResponder];
}

-(void)getCurrentDate{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    _currentYear= [dateComponent year];
    _currentDay = [dateComponent day];
    _currentMonth = [dateComponent month];
}

-(void)makeArecord{
    __weak typeof(self) weakSelf = self;
    if (self.selectChargeCircleType != -1) {
        NSString *selectDate = [NSString stringWithFormat:@"%ld-%02ld-%02ld",self.selectedYear,self.selectedMonth,self.selectedDay];
        if (![selectDate isEqualToString:[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"抱歉,暂不可设置历史日期的定期收入/支出哦~" delegate:weakSelf cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            weakSelf.ChargeCircleSelectView.selectCircleType = -1;
            weakSelf.additionalView.hasCircle = NO;
            return;
        }
    }
    if (self.selectItem.fundingID == nil) {
        [CDAutoHideMessageHUD showMessage:@"请先添加资金账户"];
        return;
    }
    [[SSJDatabaseQueue sharedInstance]asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        double chargeMoney = [self.textInput.text doubleValue];
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
            if (!weakSelf.categoryID) {
                weakSelf.categoryID = weakSelf.defualtID;
            }
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
        }else if (self.item.ID != nil){
            //修改流水
            if ([db intForQuery:@"select operatortype from bk_user_charge where ichargeid = ?",weakSelf.item.ID] == 2) {
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
                }
                if (weakSelf.selectedImage != nil) {
                    if (SSJSaveImage(weakSelf.selectedImage, imageName)&&SSJSaveThumbImage(weakSelf.selectedImage, imageName)) {
                        [db executeUpdate:@"update BK_USER_CHARGE set CIMGURL = ? , THUMBURL = ? where ICHARGEID = ? AND CUSERID = ?",[NSString stringWithFormat:@"%@.jpg",imageName],[NSString stringWithFormat:@"%@-thumb.jpg",imageName],weakSelf.item.ID,userid];
                        [db executeUpdate:@"insert into BK_IMG_SYNC (RID , CIMGNAME , CWRITEDATE , OPERATORTYPE , ISYNCTYPE , ISYNCSTATE) values (?,?,?,?,?,?)",weakSelf.item.ID,[NSString stringWithFormat:@"%@.jpg",imageName],[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0]];
                        if ([db intForQuery:@"select * from BK_IMG_SYNC where CIMGNAME = ? and RID <> ?",weakSelf.item.chargeImage,weakSelf.item.ID]+[db intForQuery:@"select * from BK_USER_CHARGE where CIMGURL = ? and ICHARGEID <> ?",weakSelf.item.chargeImage,weakSelf.item.ID] == 0) {
                            [[NSFileManager defaultManager] removeItemAtPath:SSJImagePath(weakSelf.item.chargeImage) error:nil];
                            [[NSFileManager defaultManager] removeItemAtPath:SSJImagePath(weakSelf.item.chargeThumbImage) error:nil];
                            [db executeUpdate:@"delete from BK_IMG_SYNC where CIMGNAME = ?",weakSelf.item.chargeImage];
                        }
                    }
                }else{
                    [db executeUpdate:@"update BK_USER_CHARGE set CIMGURL = ? , THUMBURL = ? where ICHARGEID = ? AND CUSERID = ?",@"",@"",weakSelf.item.ID,userid];
                    [db executeUpdate:@"delete from BK_IMG_SYNC where RID = ?",self.item.ID];
                }
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
                        if ([db intForQuery:@"select * from BK_IMG_SYNC where CIMGNAME = ? and RID <> ?",weakSelf.item.chargeImage,weakSelf.item.configId]+[db intForQuery:@"select * from BK_USER_CHARGE where CIMGURL = ? and ICHARGEID <> ?",weakSelf.item.chargeImage,weakSelf.item.ID] == 0) {
                            [[NSFileManager defaultManager] removeItemAtPath:SSJImagePath(weakSelf.item.chargeImage) error:nil];
                            [[NSFileManager defaultManager] removeItemAtPath:SSJImagePath(weakSelf.item.chargeThumbImage) error:nil];
                            [db executeUpdate:@"delete from BK_IMG_SYNC where CIMGNAME = ?",weakSelf.item.chargeImage];
                        }
                    }
                }
            }
        }
        [db executeUpdate:@"DELETE FROM BK_DAILYSUM_CHARGE WHERE SUMAMOUNT = 0 AND INCOMEAMOUNT = 0 AND EXPENCEAMOUNT = 0"];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    }];
    if (SSJSyncSetting() == SSJSyncSettingTypeWIFI) {
        [[SSJDataSynchronizer shareInstance]startSyncWithSuccess:^(){
            
        }failure:^(NSError *error) {
            
        }];
    }
}

-(void)segmentPressed:(id)sender{
    self.categoryListView.incomeOrExpence = !self.titleSegment.selectedSegmentIndex;
    self.categoryListView.scrollView.contentOffset = CGPointMake(0, 0);
    [self getDefualtColorAndDefualtId];
    self.categoryListView.selectedId = self.defualtID;
    self.selectedCategoryView.backgroundColor = [UIColor ssj_colorWithHex:_defualtColor];
    self.categoryImage.image = [[UIImage imageNamed:_defualtImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.ChargeCircleSelectView.incomeOrExpenture = self.titleSegment.selectedSegmentIndex;
}

-(void)getDefualtColorAndDefualtId{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db){
        if (weakSelf.item == nil) {
            FMResultSet *rs = [db executeQuery:@"SELECT ID , CCOLOR , CCOIN FROM BK_BILL_TYPE WHERE ITYPE = ? AND ISTATE = 1 LIMIT 1",[NSNumber numberWithDouble:!weakSelf.titleSegment.selectedSegmentIndex]];
            while([rs next]) {
                _defualtColor = [rs stringForColumn:@"CCOLOR"];
                _defualtID = [rs stringForColumn:@"ID"];
                _defualtImage = [rs stringForColumn:@"CCOIN"];
            }
            [rs close];
        }else{
            _defualtColor = weakSelf.item.colorValue;
            _defualtID = weakSelf.item.billId;
            _defualtImage = weakSelf.item.imageName;
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            [UIView animateWithDuration:kAnimationDuration animations:^{
                weakSelf.selectedCategoryView.backgroundColor = [UIColor ssj_colorWithHex:_defualtColor];
                weakSelf.categoryImage.image = [[UIImage imageNamed:_defualtImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }];
            weakSelf.categoryListView.selectedId = _defualtID;
            [weakSelf.categoryListView reloadData];
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
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:selectDate];
    _originaldYear= [dateComponent year];
    _originaldDay = [dateComponent day];
    _originaldMonth = [dateComponent month];
}

-(void)closeButtonClicked:(id)sender{
    [self ssj_backOffAction];
}

-(void)reloadDataAfterSync{
    [self.categoryListView reloadData];
}


/**
 *   限制输入框小数点(输入框只改变时候调用valueChange)
 *
 *  @param TF  输入框
 *  @param num 小数点后限制位数
 */
-(void)setupTextFiledNum:(UITextField *)TF num:(int)num
{
    NSArray *arr = [TF.text componentsSeparatedByString:@"."];
    
    if ([TF.text isEqualToString:@"0."] || [TF.text isEqualToString:@"."]) {
        TF.text = @"0.";
    }else if (TF.text.length == 2) {
        if ([TF.text floatValue] == 0) {
            TF.text = @"0";
        }else if(arr.count < 2){
            TF.text = [NSString stringWithFormat:@"%d",[TF.text intValue]];
        }
    }
    
    if (arr.count > 2) {
        TF.text = [NSString stringWithFormat:@"%@.%@",arr[0],arr[1]];
    }
    
    if (arr.count == 2) {
        NSString * lastStr = arr.lastObject;
        if (lastStr.length > num) {
            TF.text = [NSString stringWithFormat:@"%@.%@",arr[0],[lastStr substringToIndex:num]];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
