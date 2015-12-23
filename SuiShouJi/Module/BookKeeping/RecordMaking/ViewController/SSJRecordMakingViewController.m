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

@interface SSJRecordMakingViewController ()
@property (nonatomic,strong) SSJCustomKeyboard* customKeyBoard;
@property (nonatomic,strong) SSJCategoryCollectionView* collectionView;
@property (nonatomic,strong) UIView* selectedCategoryView;
@property (nonatomic,strong) UIView* inputView;
@property (nonatomic,strong) UIView* inputAccessoryView;
@property (nonatomic,strong) UISegmentedControl *titleSegment;
@property (nonatomic,strong) UILabel* textInput;
@property (nonatomic,strong) UILabel* categoryNameLabel;
@property (nonatomic,strong) UIImageView* categoryImage;
@property (nonatomic,strong) SSJCategoryListView* categoryListView;
@property (nonatomic,strong) SSJDateSelectedView *DateSelectedView;
@property (nonatomic,strong) UIButton *datePickerButton;
@property (nonatomic,strong) SSJFundingTypeSelectView *FundingTypeSelectView;
@property (nonatomic,strong) UIButton *fundingTypeButton;


@property (nonatomic) long selectedYear;
@property (nonatomic) long selectedMonth;
@property (nonatomic) long selectedDay;
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

}
#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
        [self settitleSegment];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _numkeyHavePressed = NO;
    [self getCurrentDate];
    [self.view addSubview:self.selectedCategoryView];
    [self.selectedCategoryView addSubview:self.textInput];
    [self.selectedCategoryView addSubview:self.categoryNameLabel];
    [self.selectedCategoryView addSubview:self.categoryImage];
    [self.view addSubview:self.inputView];
    [self.inputView addSubview:self.customKeyBoard];
    [self.view addSubview:self.inputAccessoryView];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor whiteColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.categoryListView];
    _intPart = @"0";
    _decimalPart = @"00";
}


-(void)viewDidLayoutSubviews{
    self.selectedCategoryView.leftTop = CGPointMake(0, 0);
    self.selectedCategoryView.size = CGSizeMake(self.view.width, 60);
    self.categoryImage.left = 12.0f;
    _decimalCount = 0;
    self.categoryImage.centerY = self.selectedCategoryView.centerY;
    self.textInput.right = self.selectedCategoryView.right - 12;
    self.textInput.centerY = self.categoryImage.centerY;
    self.categoryNameLabel.left = self.categoryImage.right + 5;
    self.categoryNameLabel.centerY = self.categoryImage.centerY;
    self.inputView.bottom = self.view.bottom;
    self.categoryListView.top = self.selectedCategoryView.bottom;
    self.inputAccessoryView.bottom = self.inputView.top;
    self.categoryListView.size = CGSizeMake(self.view.width, self.inputAccessoryView.top - self.selectedCategoryView.bottom);

}

#pragma mark SSJCustomKeyboardDelegate
- (void)didNumKeyPressed:(UIButton *)button{
    if ([_intPart length] > 7 && self.customKeyBoard.decimalModel == NO) {
        return;
    }
    if (self.customKeyBoard.decimalModel == NO) {
        if ([self.textInput.text isEqualToString:@"0.00"]) {
            _intPart = button.titleLabel.text;
            self.textInput.text = [NSString stringWithFormat:@"%@.00",_intPart];
        }else{
        self.textInput.text = [NSString stringWithFormat:@"%@%@.00",_intPart,button.titleLabel.text];
        _intPart = [NSString stringWithFormat:@"%@%@",_intPart,button.titleLabel.text];
        }
    }else{
        if (_decimalCount == 0) {
            _decimalPart = [_decimalPart stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:button.titleLabel.text];
            _decimalCount = _decimalCount + 1;
        }else if (_decimalCount == 1) {
            _decimalPart = [_decimalPart stringByReplacingCharactersInRange:NSMakeRange(1, 1) withString:button.titleLabel.text];
            _decimalCount = _decimalCount + 1;
        }
        self.textInput.text = [NSString stringWithFormat:@"%@.%@",_intPart,_decimalPart];
    _lastPressNum = [button.titleLabel.text integerValue];
    }
}



- (void)didDecimalPointKeyPressed{
    self.customKeyBoard.decimalModel = YES;
}

- (void)didClearKeyPressed{
    self.textInput.text = @"0.00";
    self.customKeyBoard.decimalModel = NO;
    _decimalPart = @"00";
    _intPart = @"0";
    _decimalCount = 0;
}

- (void)didBackspaceKeyPressed{
    NSString *intPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:0];
    NSString *decimalPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:1];
    if (![decimalPart isEqualToString:@"00"]) {
        self.customKeyBoard.decimalModel = YES;
    }
    if (self.customKeyBoard.decimalModel == NO) {
        if ([intPart isEqualToString:@"0"] | ([intPart length] == 1)) {
            self.textInput.text = @"0.00";
            _decimalPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:1];
            _intPart =  [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:0];
            return;
        }
        if ([intPart hasPrefix:@"-"]&&[intPart length] == 2) {
            self.textInput.text = @"0.00";
            _decimalPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:1];
            _intPart =  [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:0];
            return;
        }
        intPart = [intPart substringToIndex:[intPart length] - 1];
        self.textInput.text = [NSString stringWithFormat:@"%@.%@",intPart,decimalPart];
    }else{
        if ([decimalPart isEqualToString:@"00"]) {
            self.customKeyBoard.decimalModel = NO;
            if ([intPart isEqualToString:@"0"]) {
                self.textInput.text = @"0.00";
                _decimalCount = 0;
                return;
            }
            if ([intPart length] == 1) {
                self.textInput.text = @"0.00";
                _decimalCount = 0;
                return;
            }
            intPart = [intPart substringToIndex:[intPart length] - 1];
            self.textInput.text = [NSString stringWithFormat:@"%@.00",intPart];
        }else if ([decimalPart hasSuffix:@"0"]){
            self.textInput.text = [NSString stringWithFormat:@"%@.00",intPart];
            _decimalCount = _decimalCount - 1;
        }else{
            decimalPart = [decimalPart substringToIndex:1];
            self.textInput.text = [NSString stringWithFormat:@"%@.%@0",intPart,decimalPart];
            _decimalCount = _decimalCount - 1;
        }
    }
    _decimalPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:1];
    _intPart =  [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:0];
}

- (void)didPlusKeyPressed{
    self.customKeyBoard.PlusOrMinusModel = YES;
    _caculationValue =_caculationValue + [self.textInput.text floatValue];
    self.textInput.text = @"0.00";
    [self.customKeyBoard.ComfirmButton setTitle:@"=" forState:UIControlStateNormal];
    self.customKeyBoard.decimalModel = NO;
    _decimalPart = @"00";
    _intPart = @"0";
    _decimalCount = 0;
}

- (void)didMinusKeyPressed{
    self.customKeyBoard.PlusOrMinusModel = NO;
    if (_numkeyHavePressed == NO) {
        _caculationValue = [self.textInput.text floatValue];
    }else{
        _caculationValue = _caculationValue - [self.textInput.text floatValue];
    }
    self.textInput.text = @"0.00";
    [self.customKeyBoard.ComfirmButton setTitle:@"=" forState:UIControlStateNormal];
    self.customKeyBoard.decimalModel = NO;
    _decimalPart = @"00";
    _intPart = @"0";
    _decimalCount = 0;
}

- (void)didComfirmKeyPressed:(UIButton*)button{
    if ([button.titleLabel.text isEqualToString:@"确定"]) {
        NSLog(@"确定");
    }else if ([button.titleLabel.text isEqualToString:@"="]){
        if (self.customKeyBoard.PlusOrMinusModel == YES) {
            _caculationValue = _caculationValue + [self.textInput.text floatValue];
            self.textInput.text = [NSString stringWithFormat:@"%.2f",_caculationValue];
            _caculationValue = 0.0f;
            self.customKeyBoard.decimalModel = NO;
            _decimalPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:1];
            _intPart =  [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:0];
            _decimalCount = 0;
        }else{
            _caculationValue = _caculationValue  - [self.textInput.text floatValue];
            self.textInput.text = [NSString stringWithFormat:@"%.2f",_caculationValue];
            _caculationValue = 0.0f;
            self.customKeyBoard.decimalModel = NO;
            _decimalPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:1];
            _intPart =  [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:0];
            _decimalCount = 0;
        }
        [self.customKeyBoard.ComfirmButton setTitle:@"确定" forState:UIControlStateNormal];
    }
}

#pragma mark - Getter
-(SSJCustomKeyboard*)customKeyBoard{
    if (!_customKeyBoard) {
        _customKeyBoard = [[SSJCustomKeyboard alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 210)];
        _customKeyBoard.delegate = self;
    }
    return _customKeyBoard;
}

-(UIView*)selectedCategoryView{
    if (!_selectedCategoryView) {
        _selectedCategoryView = [[UIView alloc]init];
//        _selectedCategoryView.backgroundColor = [UIColor redColor];
        _selectedCategoryView.layer.borderColor = [UIColor ssj_colorWithHex:@"cccccc"].CGColor;
        _selectedCategoryView.layer.borderWidth = 1.0f;
    }
    return _selectedCategoryView;
}

-(SSJCategoryListView*)categoryListView{
    if (_categoryListView == nil) {
        _categoryListView = [[SSJCategoryListView alloc]initWithFrame:CGRectZero];
        _categoryListView.CategorySelected = ^(NSString *categoryTitle , UIImage *categoryImage){
            NSLog(@"%@",categoryTitle);
        };
    }
    return _categoryListView;
}

-(UILabel*)textInput{
    if (!_textInput) {
        _textInput = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
        _textInput.font = [UIFont systemFontOfSize:24];
        _textInput.textAlignment = NSTextAlignmentRight;
        _textInput.text = @"0.00";
    }
    return _textInput;
}

-(UIImageView*)categoryImage{
    if (!_categoryImage) {
        _categoryImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 26, 26)];
        _categoryImage.layer.cornerRadius = 13;
        _categoryImage.layer.masksToBounds = YES;
        _categoryImage.image = [UIImage imageNamed:@"餐饮 测试"];
    }
    return _categoryImage;
}

-(UIView*)inputView{
    if (!_inputView ) {
        _inputView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 210)];
    }
    return _inputView;
}

-(UIView*)inputAccessoryView{
    if (!_inputAccessoryView ) {
        _inputAccessoryView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
        _inputAccessoryView.backgroundColor = [UIColor whiteColor];
        [_inputAccessoryView ssj_setBorderColor:[UIColor ssj_colorWithHex:@"e2e2e2"]];
        [_inputAccessoryView ssj_setBorderStyle:SSJBorderStyleTop];
        _fundingTypeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.width / 2, 50)];
        [_fundingTypeButton setTitle:@"选择资金类型" forState:UIControlStateNormal];
        [_fundingTypeButton setTitleColor:[UIColor ssj_colorWithHex:@"393939"] forState:UIControlStateNormal];
        _fundingTypeButton.titleLabel.font = [UIFont systemFontOfSize:18];
        _fundingTypeButton.layer.borderColor = [UIColor ssj_colorWithHex:@"e2e2e2"].CGColor;
        _fundingTypeButton.layer.borderWidth = 1.0f / 2;
        [_fundingTypeButton addTarget:self action:@selector(fundingTypeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_inputAccessoryView addSubview:_fundingTypeButton];
        self.datePickerButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.width / 2, 0, self.view.width / 2, 50)];
        [self.datePickerButton setTitle:[NSString stringWithFormat:@"%ld月%ld日",_currentMonth,_currentDay] forState:UIControlStateNormal];
        [self.datePickerButton setTitleColor:[UIColor ssj_colorWithHex:@"393939"] forState:UIControlStateNormal];
        self.datePickerButton.titleLabel.font = [UIFont systemFontOfSize:18];
        self.datePickerButton.layer.borderColor = [UIColor ssj_colorWithHex:@"e2e2e2"].CGColor;
        self.datePickerButton.layer.borderWidth = 1.0f / 2;
        [self.datePickerButton addTarget:self action:@selector(datePickerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_inputAccessoryView addSubview:self.datePickerButton];

    }
    return _inputAccessoryView;
}

-(UILabel*)categoryNameLabel{
    if (!_categoryNameLabel) {
        _categoryNameLabel = [[UILabel alloc]init];
        _categoryNameLabel.text = @"餐饮";
        _categoryNameLabel.font = [UIFont systemFontOfSize:24];
        [_categoryNameLabel sizeToFit];
    }
    return _categoryNameLabel;
}


-(SSJDateSelectedView*)DateSelectedView{
    if (!_DateSelectedView) {
        _DateSelectedView = [[SSJDateSelectedView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        __weak typeof(self) weakSelf = self;
        _DateSelectedView.calendarView.DateSelectedBlock = ^(long year , long month ,long day){
            _selectedDay = day;
            _selectedMonth = month;
            _selectedYear = year;
            [weakSelf.datePickerButton setTitle:[NSString stringWithFormat:@"%ld月%ld日",weakSelf.selectedMonth,weakSelf.selectedDay] forState:UIControlStateNormal];
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
        _FundingTypeSelectView.fundingTypeSelectBlock = ^(NSString *fundingTitle){
            [weakSelf.fundingTypeButton setTitle:fundingTitle forState:UIControlStateNormal];
            [weakSelf.FundingTypeSelectView removeFromSuperview];
        };
    }
    return _FundingTypeSelectView;
}
#pragma mark - private
-(void)settitleSegment{
    NSArray *segmentArray = @[@"收入",@"支出"];
    _titleSegment = [[UISegmentedControl alloc]initWithItems:segmentArray];
    _titleSegment.size = CGSizeMake(115, 30);
    _titleSegment.tintColor = [UIColor ssj_colorWithHex:@"47cfbe"];
    NSDictionary *dictForNormal = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor ssj_colorWithHex:@"a7a7a7"],NSForegroundColorAttributeName,[UIFont systemFontOfSize:15],NSFontAttributeName,nil];
    [_titleSegment setTitleTextAttributes:dictForNormal forState:UIControlStateNormal];
    NSDictionary *dictForSelected = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:15],NSFontAttributeName,nil];
    [_titleSegment setTitleTextAttributes:dictForSelected forState:UIControlStateSelected];
    _titleSegment.selectedSegmentIndex = 1;
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
