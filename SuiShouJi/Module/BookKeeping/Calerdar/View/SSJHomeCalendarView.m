//
//  SSJHomeCalendarView.m
//  SuiShouJi
//
//  Created by yi cai on 2017/2/8.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJHomeCalendarView.h"
#import "NSDate+DateTools.h"
@interface SSJHomeCalendarView() <UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *datePicker;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *comfirmButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSDateFormatter *formatter;

/**
 年数组
 */
@property (nonatomic, strong) NSArray *yearArray;
@property (nonatomic, strong) NSMutableArray *monthDayWeekArray;
@property (nonatomic, strong) NSArray *hourArray;
@property (nonatomic, strong) NSArray *minuteArray;
/**
 数据源
 */
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSCalendar *calendar;
@end

@implementation SSJHomeCalendarView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        [self addSubview:self.topView];
        [self addSubview:self.datePicker];
        //主题通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellAppearanceAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];
        [self themeChanged];//主题颜色
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.topView.frame = CGRectMake(0,0,self.width,70);
    self.datePicker.frame = CGRectMake(0,self.topView.height,self.width,self.height - self.topView.height);
    self.titleLabel.centerX = self.centerX;
    self.titleLabel.centerY = self.closeButton.centerY;
}

#pragma mark - Lazy
- (UIView *)topView
{
    if (!_topView) {
        _topView = [[UIView alloc] init];
        [_topView addSubview:self.titleLabel];
        [_topView addSubview:self.closeButton];
        [_topView addSubview:self.comfirmButton];
    }
    return _topView;
}
- (UIPickerView *)datePicker
{
    if (!_datePicker) {
        _datePicker = [[UIPickerView alloc] init];
        _datePicker.delegate = self;
        _datePicker.dataSource = self;
        [self defaultSelectedcomponents];//设置默认选中行和列
    }
    return _datePicker;
}

- (UIButton *)comfirmButton
{
    if (!_comfirmButton) {
        _comfirmButton = [[UIButton alloc]initWithFrame:CGRectMake(self.width - 50, 15, 35, 35)];
        [_comfirmButton setImage:[[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_comfirmButton addTarget:self action:@selector(comfirmButtonClicked) forControlEvents:UIControlEventTouchUpInside];;
        
    }
    return _comfirmButton;
}

- (UIButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(15, 15, 35, 35)];
        [_closeButton setImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"时间";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:18];
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

- (void)defaultSelectedcomponents
{
    NSDate *cuDate = self.date ? self.date : [NSDate date];
    [self.formatter setDateFormat:@"yyyy-MM月dd日 EEE"];
    NSString *dateStr = [self.formatter stringFromDate:cuDate];
    NSDate *seleDate = [self.formatter dateFromString:dateStr];
    NSInteger integer = [self.monthDayWeekArray indexOfObject:seleDate];
    [self pickerView:_datePicker didSelectRow:integer inComponent:1];//选中
    [_datePicker selectRow:integer inComponent:1 animated:YES];
    [_datePicker selectRow:[self.hourArray indexOfObject:[NSString stringWithFormat:@"%02ld",[self componentsWithDate:cuDate].hour]] inComponent:2 animated:YES];
    NSInteger min = [self.minuteArray indexOfObject:[NSString stringWithFormat:@"%02ld",[self componentsWithDate:cuDate].minute]];
    [_datePicker selectRow:min inComponent:4 animated:YES];
}

- (NSCalendar *)calendar
{
    if (!_calendar) {
        _calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    }
    return _calendar;
}

- (NSDateComponents *)componentsWithDate:(NSDate *)date
{
      NSDateComponents *components = [self.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekOfYear fromDate:date];
    return components;
}

- (NSDateFormatter *)formatter
{
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        self.formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    }
    return _formatter;
}

- (NSArray *)yearArray
{
    if (!_yearArray) {
        _yearArray = @[@" "];
    }
    return _yearArray;
}


- (NSMutableArray *)monthDayWeekArray
{
    if (!_monthDayWeekArray) {
        _monthDayWeekArray = [NSMutableArray array];
        //默认年份在2001-2038之间
        if (!self.minDate) {
            self.minDate = [NSDate dateWithYear:2001 month:1 day:1];
        }
        if (!self.maxDate) {
            self.maxDate = [NSDate dateWithYear:2038 month:1 day:1];
        }
        [self.formatter setDateFormat:@"yyyy-MM月dd日 EEE"];
        NSDate *date = self.minDate;
        while ([date compare:self.maxDate] != NSOrderedDescending) {
            NSString *string = [self.formatter stringFromDate:date];
            NSDate *date1 = [self.formatter dateFromString:string];
            [_monthDayWeekArray addObject:date1];
            date = [date dateByAddingDays:1];
        }
    }
    return _monthDayWeekArray;
}

- (NSArray *)hourArray
{
    if (!_hourArray) {
        _hourArray = @[@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24"];
    }
    return _hourArray;
}

- (NSArray *)minuteArray
{
    if (!_minuteArray) {
        NSMutableArray *tempArr = [NSMutableArray array];
        for (NSInteger i=0; i<60; i++) {
            [tempArr addObject:[NSString stringWithFormat:@"%02ld",(long)i]];
        }
        _minuteArray = [tempArr copy];
    }
    return _minuteArray;
}

- (NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = @[self.yearArray,self.monthDayWeekArray,self.hourArray,@[@"时"],self.minuteArray,@[@"分"]];
        [self.datePicker reloadAllComponents];
    }
    return _dataArray;
}

#pragma mark - Action
- (void)closeButtonClicked
{
    [self dismiss];
}

- (void)comfirmButtonClicked
{
    [self dismiss];
    if (_confirmBlock) {
        //选择的时间
        NSDate *date = [self.monthDayWeekArray ssj_safeObjectAtIndex:[self.datePicker selectedRowInComponent:1]];
        [self.formatter setDateFormat:@"yyyy年MM月dd日 EEE"];
        NSString *yearMonDayStr = [self.formatter stringFromDate:date];
        NSString *hourStr = [self.hourArray ssj_safeObjectAtIndex:[self.datePicker selectedRowInComponent:2]];
        NSString *minuStr = [self.minuteArray ssj_safeObjectAtIndex:[self.datePicker selectedRowInComponent:4]];
        NSString *dateStr = [NSString stringWithFormat:@"%@ %@时%@分",yearMonDayStr,hourStr,minuStr];
        NSDate *selectedDate = [NSDate dateWithString:dateStr formatString:@"yyyy年MM月dd日 EEEHH时mm分"];
        _confirmBlock(selectedDate);
    }
}

- (void)show
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    self.top = keyWindow.height;
    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.3 target:self touchAction:@selector(dismiss) animation:^{
        self.bottom = keyWindow.height;
    } timeInterval:0.25 fininshed:^(BOOL complation) {
        if (_showBlock) {
            _showBlock();
        }
    }];
}

- (void)dismiss
{
    if (!self.superview)return;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [self.superview ssj_hideBackViewForView:self animation:^{
        self.top = keyWindow.bottom;
    } timeInterval:0.25 fininshed:^(BOOL complation) {
        if (_dismissBlock) {
            _dismissBlock();
        }
    }];
}
#pragma mark - Private
- (void)setTitleColor:(UIColor *)color forComponent:(SSJDatePickerComponent)component
{}

- (void)setFillColor:(UIColor *)color forComponent:(SSJDatePickerComponent)component
{}

// 改变分割线的颜色
- (void)changeSpearatorLineColor
{
    for(UIView *speartorView in self.datePicker.subviews)
    {
        if (speartorView.frame.size.height < 1)//取出分割线view
        {
            speartorView.backgroundColor = [UIColor ssj_colorWithHex:self.separatorColor ? self.separatorColor : SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        }
    }
}

#pragma mark - UIPickerViewDelegate
// 选中某一行的时候调用
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //取出时间
    if (component == 1) {
        [self.formatter setDateFormat:@"yyyy年"];
        NSString *dateStr = [self.formatter stringFromDate:[self.monthDayWeekArray ssj_safeObjectAtIndex:row]];
        //显示年
        self.yearArray = @[dateStr];
        [self.datePicker reloadComponent:0];
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.dataArray.count;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return ((NSArray *)[self.dataArray ssj_safeObjectAtIndex:component]).count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == 0) {
        return 50;
    }else if (component == 1){
        return 140;
    }else if (component == 3 || component == 5) {
        return 20;
    }
    return (self.width - 230) / 3;
}

//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    if (component == 0) {
//        return [self.yearArray firstObject];
//    } else if (component == 1) {
//        [self.formatter setDateFormat:@"MM月dd日 EEE"];
//        return [self.formatter stringFromDate:self.monthDayWeekArray[row]];
//    }
//    return [[self.dataArray ssj_safeObjectAtIndex:component] ssj_safeObjectAtIndex:row];
//}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    CGFloat width = [pickerView rowSizeForComponent:component].width;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 40)];
    label.textAlignment = NSTextAlignmentCenter;
        if (component == 0 ) {
            label.font = systemFontSize(11);
            label.textColor = [UIColor ssj_colorWithHex:self.mainColor ? self.mainColor : SSJ_CURRENT_THEME.mainColor];
        }else if (component == 1){
            label.font = systemFontSize(19);
            label.textColor = [UIColor ssj_colorWithHex:self.mainColor ? self.mainColor : SSJ_CURRENT_THEME.mainColor];
        }else if (component == 2 || component == 4) {
            label.font = systemFontSize(21);
            label.textColor = [UIColor ssj_colorWithHex:self.mainColor ? self.mainColor : SSJ_CURRENT_THEME.mainColor];
        }else {
            label.font = systemFontSize(11);
            label.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        }
    
    if (component == 0) {
        label.text = [self.yearArray firstObject];
    } else if (component == 1) {
        [self.formatter setDateFormat:@"MM月dd日 EEE"];
        label.text = [self.formatter stringFromDate:self.monthDayWeekArray[row]];
    }else {
        label.text = [[self.dataArray ssj_safeObjectAtIndex:component] ssj_safeObjectAtIndex:row];
    }
    
    //分割线颜色
    [self changeSpearatorLineColor];
    return label;
}


/*
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSDictionary * attrDic = nil;
    NSString *string = nil;
    if (component == 0) {
        string = [self.yearArray firstObject];
        attrDic = @{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor],
                    NSFontAttributeName:systemFontSize(11)};
    } else if (component == 1) {
        [self.formatter setDateFormat:@"MM月dd日 EEE"];
        string = [self.formatter stringFromDate:self.monthDayWeekArray[row]];
        attrDic = @{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor],
                    NSFontAttributeName:systemFontSize(19)};
    } else if (component == 2 || component == 4){
        string = [[self.dataArray ssj_safeObjectAtIndex:component] ssj_safeObjectAtIndex:row];
        attrDic = @{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor],
                    NSFontAttributeName:systemFontSize(21)};
    } else {
        string = [[self.dataArray ssj_safeObjectAtIndex:component] ssj_safeObjectAtIndex:row];
        attrDic = @{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor],
                    NSFontAttributeName:systemFontSize(11)};
    }
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:string attributes:attrDic];
    return attString;
}
 */

- (void)updateCellAppearanceAfterThemeChanged
{
    [self themeChanged];
}


- (void)themeChanged
{
    self.closeButton.imageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    self.comfirmButton.imageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    
    self.titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
