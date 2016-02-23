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
#import "SSJNewFundingViewController.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"

#import "FMDB.h"
#import "FMDatabaseAdditions.h"

static const NSTimeInterval kAnimationDuration = 0.2;

@interface SSJRecordMakingViewController ()
@property (nonatomic,strong) SSJCategoryCollectionView* collectionView;
@property (nonatomic,strong) UIView* selectedCategoryView;
@property (nonatomic,strong) UIView* inputView1;
//@property (nonatomic,strong) UIView* inputAccessoryView;
@property (nonatomic,strong) SSJSegmentedControl *titleSegment;
@property (nonatomic,strong) UITextField* textInput;
@property (nonatomic,strong) UILabel* categoryNameLabel;
@property (nonatomic,strong) UIImageView* categoryImage;
@property (nonatomic,strong) SSJCategoryListView* categoryListView;
@property (nonatomic,strong) SSJDateSelectedView *DateSelectedView;
@property (nonatomic,strong) UIButton *datePickerButton;
@property (nonatomic,strong) SSJFundingTypeSelectView *FundingTypeSelectView;
@property (nonatomic,strong) UIButton *fundingTypeButton;
@property (nonatomic,strong) UIView *rightbuttonView;
@property (nonatomic,strong) SSJSmallCalendarView *calendarView;

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
    NSString *_categoryID;
    NSString *_defualtColor;
    NSString *_defualtID;
    NSString *_defualtImage;
    SSJFundingItem *_selectItem;
    SSJFundingItem *_defualtItem;
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
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:self.rightbuttonView];
    self.navigationItem.rightBarButtonItem = rightBarButton;
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
    }else{
        [self getSelectedDateFromDate:self.item.billDate];
        self.selectedYear = _originaldYear;
        self.selectedMonth = _originaldMonth;
        self.selectedDay = _originaldDay;
        _categoryID = self.item.billId;
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
//    [self.view addSubview:self.inputView1];
//    [self.view addSubview:self.inputAccessoryView];
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
    self.categoryImage.left = 12.0f;
    _decimalCount = 0;
    self.categoryImage.centerY = self.selectedCategoryView.centerY;
    self.textInput.right = self.selectedCategoryView.right - 12;
    self.textInput.centerY = self.categoryImage.centerY;
    self.inputView1.bottom = self.view.bottom;
    self.categoryListView.top = self.selectedCategoryView.bottom;
    self.categoryListView.height = self.inputView1.top - self.selectedCategoryView.bottom;
//    self.inputAccessoryView.bottom = self.inputView1.top;
    self.categoryListView.size = CGSizeMake(self.view.width, self.view.height - 260 - self.selectedCategoryView.bottom);
}

#pragma mark SSJCustomKeyboardDelegate
//- (void)didNumKeyPressed:(UIButton *)button{
//    self.textInput.textColor = [UIColor whiteColor];
//    if ([_intPart length] > 7 && self.customKeyBoard.decimalModel == NO) {
//        return;
//    }
//    if (self.customKeyBoard.decimalModel == NO) {
//        if ([self.textInput.text isEqualToString:@"0.00"]) {
//            _intPart = button.titleLabel.text;
//            self.textInput.text = [NSString stringWithFormat:@"%@.00",_intPart];
//            if ([self.textInput.text isEqualToString:@"0.00"]) {
//                _textInput.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
//            }
//        }else{
//        self.textInput.text = [NSString stringWithFormat:@"%@%@.00",_intPart,button.titleLabel.text];
//        _intPart = [NSString stringWithFormat:@"%@%@",_intPart,button.titleLabel.text];
//        }
//    }else{
//        if (_decimalCount == 0) {
//            _decimalPart = [_decimalPart stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:button.titleLabel.text];
//            _decimalCount = _decimalCount + 1;
//        }else if (_decimalCount == 1) {
//            _decimalPart = [_decimalPart stringByReplacingCharactersInRange:NSMakeRange(1, 1) withString:button.titleLabel.text];
//            _decimalCount = _decimalCount + 1;
//        }
//        self.textInput.text = [NSString stringWithFormat:@"%@.%@",_intPart,_decimalPart];
//    _lastPressNum = [button.titleLabel.text integerValue];
//    }
//}

//- (void)didDecimalPointKeyPressed{
//    self.customKeyBoard.decimalModel = YES;
//}

//- (void)didClearKeyPressed{
//    self.textInput.text = @"0.00";
//    self.customKeyBoard.decimalModel = NO;
//    _decimalPart = @"00";
//    _intPart = @"0";
//    _decimalCount = 0;
//}

//- (void)didBackspaceKeyPressed{
//    self.textInput.textColor = [UIColor whiteColor];
//    NSString *intPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:0];
//    NSString *decimalPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:1];
//    if (![decimalPart isEqualToString:@"00"]) {
//        self.customKeyBoard.decimalModel = YES;
//    }
//    if (self.customKeyBoard.decimalModel == NO) {
//        if ([intPart isEqualToString:@"0"] | ([intPart length] == 1)) {
//            self.textInput.text = @"0.00";
//            _textInput.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
//            _decimalPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:1];
//            _intPart =  [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:0];
//            return;
//        }
//        if ([intPart hasPrefix:@"-"]&&[intPart length] == 2) {
//            self.textInput.text = @"0.00";
//            _textInput.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
//            _textInput.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
//            _decimalPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:1];
//            _intPart =  [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:0];
//            return;
//        }
//        intPart = [intPart substringToIndex:[intPart length] - 1];
//        self.textInput.text = [NSString stringWithFormat:@"%@.%@",intPart,decimalPart];
//    }else{
//        if ([decimalPart isEqualToString:@"00"]) {
//            self.customKeyBoard.decimalModel = NO;
//            if ([intPart isEqualToString:@"0"]) {
//                self.textInput.text = @"0.00";
//                _textInput.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
//                _textInput.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
//                _decimalCount = 0;
//                return;
//            }
//            if ([intPart length] == 1) {
//                self.textInput.text = @"0.00";
//                _textInput.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
//                _decimalCount = 0;
//                return;
//            }
//            intPart = [intPart substringToIndex:[intPart length] - 1];
//            self.textInput.text = [NSString stringWithFormat:@"%@.00",intPart];
//        }else if ([decimalPart hasSuffix:@"0"]){
//            self.textInput.text = [NSString stringWithFormat:@"%@.00",intPart];
//            _textInput.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
//            _decimalCount = _decimalCount - 1;
//        }else{
//            decimalPart = [decimalPart substringToIndex:1];
//            self.textInput.text = [NSString stringWithFormat:@"%@.%@0",intPart,decimalPart];
//            _decimalCount = _decimalCount - 1;
//        }
//    }
//    _decimalPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:1];
//    _intPart =  [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:0];
//}

//- (void)didPlusKeyPressed{
//    self.customKeyBoard.PlusOrMinusModel = YES;
//    _caculationValue =_caculationValue + [self.textInput.text floatValue];
//    self.textInput.text = @"0.00";
//    [self.customKeyBoard.ComfirmButton setTitle:@"=" forState:UIControlStateNormal];
//    self.customKeyBoard.decimalModel = NO;
//    _decimalPart = @"00";
//    _intPart = @"0";
//    _decimalCount = 0;
//}
//
//- (void)didMinusKeyPressed{
//    self.customKeyBoard.PlusOrMinusModel = NO;
//    if (_numkeyHavePressed == NO) {
//        _caculationValue = [self.textInput.text floatValue];
//    }else{
//        _caculationValue = _caculationValue - [self.textInput.text floatValue];
//    }
//    self.textInput.text = @"0.00";
//    [self.customKeyBoard.ComfirmButton setTitle:@"=" forState:UIControlStateNormal];
//    self.customKeyBoard.decimalModel = NO;
//    _decimalPart = @"00";
//    _intPart = @"0";
//    _decimalCount = 0;
//}

- (void)comfirmButtonClick:(id)sender{
    if ([self.textInput.text isEqualToString:@"0.00"]) {
        [CDAutoHideMessageHUD showMessage:@"记账金额不能为0"];
        return;
    }
    [self makeArecord];
//    }else if ([button.titleLabel.text isEqualToString:@"="]){
//        if (self.customKeyBoard.PlusOrMinusModel == YES) {
//            _caculationValue = _caculationValue + [self.textInput.text floatValue];
//            self.textInput.text = [NSString stringWithFormat:@"%.2f",_caculationValue];
//            _caculationValue = 0.0f;
//            self.customKeyBoard.decimalModel = NO;
//            _decimalPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:1];
//            _intPart =  [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:0];
//            _decimalCount = 0;
//        }else{
//            _caculationValue = _caculationValue  - [self.textInput.text floatValue];
//            self.textInput.text = [NSString stringWithFormat:@"%.2f",_caculationValue];
//            _caculationValue = 0.0f;
//            self.customKeyBoard.decimalModel = NO;
//            _decimalPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:1];
//            _intPart =  [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:0];
//            _decimalCount = 0;
//        }
//        [self.customKeyBoard.ComfirmButton setTitle:@"确定" forState:UIControlStateNormal];
//    }
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
        _categoryListView.selectedId = _defualtID;
        [_categoryListView reloadData];
        if (self.item == nil) {
            _categoryListView.incomeOrExpence = !_titleSegment.selectedSegmentIndex;
        }else{
            _categoryListView.incomeOrExpence = self.item.incomeOrExpence;
        }
        [_categoryListView reloadData];
        __weak typeof(self) weakSelf = self;
        _categoryListView.CategorySelectedBlock = ^(SSJRecordMakingCategoryItem *item){
            _categoryID = item.categoryTitle;
            if (![item.categoryTitle isEqualToString:@"添加"]) {
                [UIView animateWithDuration:kAnimationDuration animations:^{
                    weakSelf.categoryNameLabel.text = item.categoryTitle;
                    [weakSelf.categoryNameLabel sizeToFit];
                    weakSelf.selectedCategoryView.backgroundColor = [UIColor ssj_colorWithHex:item.categoryColor];
                    weakSelf.categoryImage.tintColor = [UIColor whiteColor];
                    weakSelf.categoryImage.image = [[UIImage imageNamed:item.categoryImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    _categoryID = item.categoryID;
                }];
            }else{
                SSJADDNewTypeViewController *addNewTypeVc = [[SSJADDNewTypeViewController alloc]init];
                addNewTypeVc.incomeOrExpence = !
                weakSelf.titleSegment.selectedSegmentIndex;
                addNewTypeVc.NewCategorySelectedBlock = ^(NSString *categoryID,SSJRecordMakingCategoryItem *item){
                    weakSelf.categoryListView.selectedId = categoryID;
                    _categoryID = categoryID;
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
        _categoryImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 26, 26)];
        _categoryImage.layer.masksToBounds = YES;
        _categoryImage.tintColor = [UIColor whiteColor];
        _categoryImage.image = [[UIImage imageNamed:_defualtImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return _categoryImage;
}

-(UIView*)inputView1{
    if (!_inputView1 ) {
        _inputView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 200)];
    }
    return _inputView1;
}

//-(UIView*)inputAccessoryView{
//    if (!_inputAccessoryView ) {
//        _inputAccessoryView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
//        _inputAccessoryView.backgroundColor = [UIColor whiteColor];
//        
//        [_inputAccessoryView addSubview:self.fundingTypeButton];
//        self.datePickerButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.width / 2 + 10, 0, self.view.width / 2 - 30, 40)];
//        _datePickerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//        [self.datePickerButton setTitle:[NSString stringWithFormat:@"%ld月",self.selectedMonth] forState:UIControlStateNormal];
//        [self.datePickerButton setTitleColor:[UIColor ssj_colorWithHex:@"393939"] forState:UIControlStateNormal];
//        self.datePickerButton.titleLabel.font = [UIFont systemFontOfSize:18];
//        self.datePickerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 60, 0, 20);
//        [self.datePickerButton addTarget:self action:@selector(datePickerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [_inputAccessoryView addSubview:self.datePickerButton];
//        self.calendarView.currentDay = [NSString stringWithFormat:@"%02ld",self.selectedDay];
//        self.calendarView.frame = CGRectMake(self.datePickerButton.width - 20, 0, 24, 24);
//        self.calendarView.centerY = self.datePickerButton.height / 2;
//        [self.datePickerButton addSubview:self.calendarView];
//    }
//    return _inputAccessoryView;
//}

- (UIButton *)fundingTypeButton {
    if (!_fundingTypeButton) {
        _fundingTypeButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, self.view.width / 2, 40)];
        _fundingTypeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_fundingTypeButton setTitleColor:[UIColor ssj_colorWithHex:@"393939"] forState:UIControlStateNormal];
        _fundingTypeButton.titleLabel.font = [UIFont systemFontOfSize:18];
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
        _DateSelectedView.calendarView.DateSelectedBlock = ^(long year , long month ,long day){
            _selectedDay = day;
            _selectedMonth = month;
            _selectedYear = year;
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
                _selectItem = fundingItem;
                [weakSelf updateFundingType];
                 NSData *lastSelectFundingDate = [NSKeyedArchiver archivedDataWithRootObject:fundingItem];
                [[NSUserDefaults standardUserDefaults] setObject:lastSelectFundingDate forKey:SSJLastSelectFundItemKey];
            }else{
                SSJNewFundingViewController *NewFundingVC = [[SSJNewFundingViewController alloc]init];
                NewFundingVC.finishBlock = ^(SSJFundingItem *newFundingItem){
                    [weakSelf.FundingTypeSelectView reloadDate];
                    [weakSelf.fundingTypeButton setTitle:newFundingItem.fundingName forState:UIControlStateNormal];
                    [weakSelf.fundingTypeButton setImage:[UIImage imageNamed:newFundingItem.fundingIcon] forState:UIControlStateNormal];
                    _selectItem = newFundingItem;
                    [weakSelf updateFundingType];
                };
                [weakSelf.navigationController pushViewController:NewFundingVC animated:YES];
            }
            [weakSelf.FundingTypeSelectView removeFromSuperview];
        };
    }
    return _FundingTypeSelectView;
}

-(UIView *)rightbuttonView{
    if (!_rightbuttonView) {
        _rightbuttonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        UIButton *comfirmButton = [[UIButton alloc]init];
        comfirmButton.frame = CGRectMake(0, 0, 44, 44);
        [comfirmButton setImage:[UIImage imageNamed:@"record_ok"] forState:UIControlStateNormal];
        [comfirmButton addTarget:self action:@selector(comfirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_rightbuttonView addSubview:comfirmButton];
    }
    return _rightbuttonView;
}

-(SSJSmallCalendarView *)calendarView{
    if (!_calendarView) {
        _calendarView = [[SSJSmallCalendarView alloc]init];
    }
    return _calendarView;
}

#pragma mark - private
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
}

-(void)fundingTypeButtonClicked:(UIButton*)button{
    [[UIApplication sharedApplication].keyWindow addSubview:self.FundingTypeSelectView];
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
    [[SSJDatabaseQueue sharedInstance]asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        double chargeMoney = [self.textInput.text doubleValue];
        NSString *operationTime = [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString *selectDate;
        selectDate = [NSString stringWithFormat:@"%ld-%02ld-%02ld",self.selectedYear,self.selectedMonth,self.selectedDay];
        SSJFundingItem *fundingType = _selectItem;
        if (self.item == nil) {
            if (!_categoryID) {
                _categoryID = _defualtID;
            }
            NSString *chargeID = SSJUUID();
            NSString *userID = SSJUSERID();
            if (self.titleSegment.selectedSegmentIndex == 0) {
                [db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE - ? WHERE CFUNDID = ? ",[NSNumber numberWithDouble:chargeMoney],fundingType.fundingID];
            }else{
                [db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE + ? WHERE CFUNDID = ? ",[NSNumber numberWithDouble:chargeMoney],fundingType.fundingID];
            }
            [db executeUpdate:@"INSERT INTO BK_USER_CHARGE (ICHARGEID , CUSERID , IMONEY , IBILLID , IFUNSID  , IOLDMONEY , IBALANCE , CWRITEDATE , IVERSION , OPERATORTYPE , CBILLDATE) VALUES(?,?,?,?,?,?,?,?,?,?,?)",chargeID,userID,[NSNumber numberWithDouble:chargeMoney],_categoryID,fundingType.fundingID,[NSNumber numberWithDouble:19.99],[NSNumber numberWithDouble:19.99],operationTime,@(SSJSyncVersion()),[NSNumber numberWithInt:0],selectDate];
            int count = [db intForQuery:@"SELECT COUNT(CBILLDATE) AS COUNT FROM BK_DAILYSUM_CHARGE WHERE CBILLDATE = ? AND CUSERID = ?",selectDate,SSJUSERID()];
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
                [db executeUpdate:@"INSERT INTO BK_DAILYSUM_CHARGE (CBILLDATE , EXPENCEAMOUNT , INCOMEAMOUNT  , SUMAMOUNT, ICHARGEID  , IBILLID , CWRITEDATE , CUSERID) VALUES(?,?,?,?,?,?,?,?)",selectDate,[NSNumber numberWithDouble:expenseSum],[NSNumber numberWithDouble:incomeSum],[NSNumber numberWithDouble:sum],@"0",@"-1",[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],SSJUSERID()];
            }else{
                FMResultSet *rs = [db executeQuery:@"SELECT EXPENCEAMOUNT, INCOMEAMOUNT , SUMAMOUNT FROM BK_DAILYSUM_CHARGE WHERE CBILLDATE = ? AND CUSERID = ?",selectDate,SSJUSERID()];
                while ([rs next]) {
                    incomeSum = [rs doubleForColumn:@"INCOMEAMOUNT"];
                    expenseSum = [rs doubleForColumn:@"EXPENCEAMOUNT"];
                    sum = [rs doubleForColumn:@"SUMAMOUNT"];
                }
                if (self.titleSegment.selectedSegmentIndex == 0) {
                    expenseSum = expenseSum + chargeMoney;
                    sum = sum - chargeMoney;
                    [db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET EXPENCEAMOUNT = ? , SUMAMOUNT = ? , CWRITEDATE = ? WHERE CBILLDATE = ? AND CUSERID = ?",[NSNumber numberWithDouble:expenseSum],[NSNumber numberWithDouble:sum],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],selectDate,SSJUSERID()];
                }else{
                    incomeSum = incomeSum + chargeMoney;
                    sum = sum + chargeMoney;
                    [db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET INCOMEAMOUNT = ? , SUMAMOUNT = ? , CWRITEDATE = ? WHERE CBILLDATE = ? AND CUSERID = ?",[NSNumber numberWithDouble:incomeSum],[NSNumber numberWithDouble:sum],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],selectDate,SSJUSERID()];
                }
            }
        }else{
            [db executeUpdate:@"UPDATE BK_USER_CHARGE SET IMONEY = ? , IBILLID = ? , IFUNSID = ? , CWRITEDATE = ? , OPERATORTYPE = ? , CBILLDATE = ? , IVERSION = ? WHERE ICHARGEID = ? AND CUSERID = ?",[NSNumber numberWithDouble:chargeMoney],_categoryID,fundingType.fundingID,[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[NSNumber numberWithInt:1],selectDate,@(SSJSyncVersion()),self.item.ID,SSJUSERID()];
            if (self.titleSegment.selectedSegmentIndex == 0) {
                [db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE - ? WHERE CFUNDID = ? AND CUSERID = ?",[NSNumber numberWithDouble:chargeMoney],fundingType.fundingID,SSJUSERID()];
                if([db intForQuery:@"SELECT COUNT(*) FROM BK_DAILYSUM_CHARGE WHERE CBILLDATE = ? AND CUSERID = ?",selectDate,SSJUSERID()]){
                    [db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET SUMAMOUNT = SUMAMOUNT - ? , EXPENCEAMOUNT = EXPENCEAMOUNT + ? , CWRITEDATE = ? WHERE CBILLDATE = ? AND CUSERID = ?",[NSNumber numberWithDouble:chargeMoney],[NSNumber numberWithDouble:chargeMoney],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],selectDate,SSJUSERID()];
                }else{
                    [db executeUpdate:@"INSERT INTO BK_DAILYSUM_CHARGE (CBILLDATE , EXPENCEAMOUNT , INCOMEAMOUNT  , SUMAMOUNT , ICHARGEID  , IBILLID , CWRITEDATE , CUSERID) VALUES(?,?,?,?,?,?,?,?)",selectDate,[NSNumber numberWithDouble:chargeMoney],[NSNumber numberWithDouble:0],[NSNumber numberWithDouble:(-chargeMoney)],@"0",@"-1",[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],SSJUSERID()];
                }
            }else{
                [db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE + ? WHERE CFUNDID = ? AND CUSERID = ?", [NSNumber numberWithDouble:chargeMoney] , fundingType.fundingID,SSJUSERID()];
                if([db intForQuery:@"SELECT COUNT(*) FROM BK_DAILYSUM_CHARGE WHERE CBILLDATE = ? AND CUSERID = ?",selectDate,SSJUSERID()]){
                    [db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET SUMAMOUNT = SUMAMOUNT + ? , INCOMEAMOUNT = INCOMEAMOUNT + ? , CWRITEDATE = ? WHERE CBILLDATE = ? AND CUSERID = ?",[NSNumber numberWithDouble:chargeMoney],[NSNumber numberWithDouble:chargeMoney],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],selectDate,SSJUSERID()];
                }else{
                    [db executeUpdate:@"INSERT INTO BK_DAILYSUM_CHARGE (CBILLDATE , EXPENCEAMOUNT , INCOMEAMOUNT  , SUMAMOUNT , ICHARGEID  , IBILLID , CWRITEDATE , CUSERID) VALUES(?,?,?,?,?,?,?,?)",selectDate,[NSNumber numberWithDouble:0],[NSNumber numberWithDouble:chargeMoney],[NSNumber numberWithDouble:chargeMoney],@"0",@"-1",[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],SSJUSERID()];
                }
            }
            if ([db intForQuery:@"SELECT ITYPE FROM BK_BILL_TYPE WHERE ID = ?",self.item.billId])
            {
                [db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE + ? WHERE CFUNDID = ? AND CUSERID = ?",[NSNumber numberWithDouble:[self.item.money doubleValue]],self.item.fundId,SSJUSERID()];
                [db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET SUMAMOUNT = SUMAMOUNT + ? , EXPENCEAMOUNT = EXPENCEAMOUNT - ? ,CWRITEDATE = ? WHERE CBILLDATE = ? AND CUSERID = ?",[NSNumber numberWithDouble:[self.item.money doubleValue]],[NSNumber numberWithDouble:[self.item.money doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],self.item.billDate,SSJUSERID()];
            }else{
                [db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE - ? WHERE CFUNDID = ? AND CUSERID = ?",[NSNumber numberWithDouble:[self.item.money doubleValue]],self.item.fundId,SSJUSERID()];
                [db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET SUMAMOUNT = SUMAMOUNT - ? , INCOMEAMOUNT = INCOMEAMOUNT - ? , CWRITEDATE = ? WHERE CBILLDATE = ? AND CUSERID = ?",[NSNumber numberWithDouble:[self.item.money doubleValue]],[NSNumber numberWithDouble:[self.item.money doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],self.item.billDate,SSJUSERID()];
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
    self.categoryListView.selectedId = _defualtID;
    self.selectedCategoryView.backgroundColor = [UIColor ssj_colorWithHex:_defualtColor];
    self.categoryImage.image = [[UIImage imageNamed:_defualtImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
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
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db){
        FMResultSet * rs = [db executeQuery:@"SELECT A.* , B.IBALANCE FROM BK_FUND_INFO  A , BK_FUNS_ACCT B WHERE CPARENT != ? AND A.CFUNDID = B.CFUNDID AND A.OPERATORTYPE <> 2 AND A.CUSERID = ? LIMIT 1",@"root",SSJUSERID()];
        _defualtItem = [[SSJFundingItem alloc]init];
        while ([rs next]) {
            _defualtItem.fundingColor = [rs stringForColumn:@"CCOLOR"];
            _defualtItem.fundingIcon = [rs stringForColumn:@"CICOIN"];
            _defualtItem.fundingID = [rs stringForColumn:@"CFUNDID"];
            _defualtItem.fundingName = [rs stringForColumn:@"CACCTNAME"];
            _defualtItem.fundingParent = [rs stringForColumn:@"CPARENT"];
            _defualtItem.fundingBalance = [rs doubleForColumn:@"IBALANCE"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            _selectItem = _defualtItem;
            [self updateFundingType];
        });
    }];
}

-(void)getSelectedFundingType{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:@"SELECT A.* , B.IBALANCE FROM BK_FUND_INFO  A , BK_FUNS_ACCT B WHERE A.CFUNDID = B.CFUNDID AND A.CFUNDID = ?",self.item.fundId];
        _defualtItem = [[SSJFundingItem alloc]init];
        while ([rs next]) {
            _defualtItem.fundingColor = [rs stringForColumn:@"CCOLOR"];
            _defualtItem.fundingIcon = [rs stringForColumn:@"CICOIN"];
            _defualtItem.fundingID = [rs stringForColumn:@"CFUNDID"];
            _defualtItem.fundingName = [rs stringForColumn:@"CACCTNAME"];
            _defualtItem.fundingParent = [rs stringForColumn:@"CPARENT"];
            _defualtItem.fundingBalance = [rs doubleForColumn:@"IBALANCE"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            _selectItem = _defualtItem;
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

-(void)textFieldDidChange:(id)sender{
    [self setupTextFiledNum:self.textInput num:2];
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
