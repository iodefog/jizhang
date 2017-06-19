//
//  SSJHomeCalendarView.m
//  SuiShouJi
//
//  Created by yi cai on 2017/2/8.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJHomeDatePickerView.h"
#import "NSDate+DateTools.h"
@interface SSJHomeDatePickerView() <UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *datePicker;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *comfirmButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *horuAndMinuBgView;//时，分对应的背景颜色
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSCalendar *calendar;

/**
 内容数组
 */
@property (nonatomic, strong) NSMutableArray<NSString *> *yearArray;
@property (nonatomic, strong) NSMutableArray<NSDate *> *monthDayWeekArray;
@property (nonatomic, strong) NSArray<NSString *> *hourArray;
@property (nonatomic, strong) NSArray<NSString *> *minuteArray;
@property (nonatomic, strong) NSArray<NSString *> *monthArray;
@property (nonatomic, strong) NSMutableArray<NSString *> *dayArray;
@property (nonatomic, strong) NSArray<NSString *> *amPmArray;

/**
 数据源
 */
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SSJHomeDatePickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        [self addSubview:self.topView];
        [self addSubview:self.horuAndMinuBgView];
        [self addSubview:self.datePicker];
        //主题通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellAppearanceAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];
        [self themeChanged];//主题颜色
        [self sizeToFit];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake(SSJSCREENWITH, 260);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.topView.frame = CGRectMake(0,0,SSJSCREENWITH,45);
    self.datePicker.frame = CGRectMake(0,self.topView.height,SSJSCREENWITH,self.height - self.topView.height);
    self.titleLabel.centerX = self.centerX;
    self.titleLabel.centerY = self.closeButton.centerY;
    self.horuAndMinuBgView.frame = CGRectMake(200,self.topView.height + self.datePicker.height * 0.5 - 22, self.width - 200, 43);
    self.horuAndMinuBgView.centerY = self.datePicker.centerY;
    self.closeButton.leftTop = CGPointMake(15, 15);
    self.comfirmButton.rightTop = CGPointMake(self.width - 15, 15);
}

- (void)setLeftButtonItem:(SSJHomeDatePickerViewButtonItem *)leftButtonItem {
    if (_leftButtonItem != leftButtonItem) {
        _leftButtonItem = leftButtonItem;
        [self setNeedsLayout];
        if (_leftButtonItem) {
            [self updateButton:self.closeButton buttonItem:self.leftButtonItem];
        } else {
            [_closeButton setImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        }
    }
}

- (void)setRightButtonItem:(SSJHomeDatePickerViewButtonItem *)rightButtonItem {
    if (_rightButtonItem != rightButtonItem) {
        _rightButtonItem = rightButtonItem;
        [self setNeedsLayout];
        if (_rightButtonItem) {
            [self updateButton:self.comfirmButton buttonItem:self.rightButtonItem];
        } else {
            [_comfirmButton setImage:[[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        }
    }
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
    }
    return _datePicker;
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    [self defaultSelectedcomponents];//设置默认选中行和列
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
        _titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

- (UIView *)horuAndMinuBgView
{
    if (!_horuAndMinuBgView) {
        _horuAndMinuBgView = [[UIView alloc] init];
    }
    return _horuAndMinuBgView;
}

- (void)defaultSelectedcomponents
{
    NSDate *systemDate = [NSDate date];
    NSDate *cuDate = self.date ? self.date : systemDate;
    
    NSInteger year = cuDate.year;
    NSInteger month = cuDate.month;
    NSInteger day = cuDate.day;
    NSInteger hour = cuDate.hour;
    NSInteger minute = cuDate.minute;
    NSInteger amPmIndex = hour < 12 ? 0 : 1;//上午下午
    if (self.datePickerMode == SSJDatePickerModeTime) {
        NSString *hourStr = (hour == 0) ? @"12" : [NSString stringWithFormat:@"%ld",(long)(hour > 12 ? hour - 12 : hour)];
        NSInteger row2 = [self.hourArray indexOfObject:hourStr];
        NSInteger row3 = [self.minuteArray indexOfObject:[NSString stringWithFormat:@"%02ld",(long)minute]];
        [self.datePicker selectRow:amPmIndex inComponent:0 animated:YES];
        [self.datePicker selectRow:row2 inComponent:1 animated:YES];
        [self.datePicker selectRow:row3 inComponent:2 animated:YES];
    } else if (self.datePickerMode == SSJDatePickerModeDate) {
        NSInteger row1 = [self.yearArray indexOfObject:[NSString stringWithFormat:@"%ld年",(long)year]];
        if (row1>self.yearArray.count-1)return;
        NSInteger row2 = [self.monthArray indexOfObject:[NSString stringWithFormat:@"%ld月",(long)month]];
        if (row2>self.monthArray.count-1)return;
        NSInteger row3 = [self.dayArray indexOfObject:[NSString stringWithFormat:@"%ld日",(long)day]];
        if (row3>self.dayArray.count-1)return;
        [self.datePicker selectRow:row1 inComponent:0 animated:YES];
        [self.datePicker selectRow:row2 inComponent:1 animated:YES];
        [self pickerView:_datePicker didSelectRow:row2 inComponent:1];
        [self.datePicker selectRow:row3 inComponent:2 animated:YES];
    } else if (self.datePickerMode == SSJDatePickerModeDateAndTime) {
        [self.formatter setDateFormat:@"yyyy-MM月dd日 EEE"];
        NSString *dateStr = [self.formatter stringFromDate:cuDate];
        NSDate *seleDate = [self.formatter dateFromString:dateStr];
        NSInteger integer = [self.monthDayWeekArray indexOfObject:seleDate];
        if (integer>self.monthDayWeekArray.count-1)return;
        [self pickerView:_datePicker didSelectRow:integer inComponent:0];//选中
        [_datePicker selectRow:integer inComponent:0 animated:YES];
        NSInteger row2 = [self.hourArray indexOfObject:[NSString stringWithFormat:@"%ld",(long)(hour > 12 ? hour - 12 : hour)]];
        if (row2>self.hourArray.count-1)return;
        NSInteger row3 = [self.minuteArray indexOfObject:[NSString stringWithFormat:@"%02ld",(long)minute]];
        if (row3>self.minuteArray.count-1)return;
        [_datePicker selectRow:amPmIndex inComponent:1 animated:YES];
        [_datePicker selectRow:row2 inComponent:2 animated:YES];
        [_datePicker selectRow:row3 inComponent:3 animated:YES];
        
    } else if (self.datePickerMode == SSJDatePickerModeYearDateAndTime) {
        [self.formatter setDateFormat:@"yyyy-MM月dd日 EEE"];
        NSString *dateStr = [self.formatter stringFromDate:cuDate];
        NSDate *seleDate = [self.formatter dateFromString:dateStr];
        NSInteger integer = [self.monthDayWeekArray indexOfObject:seleDate];
        if (integer>self.monthDayWeekArray.count-1)return;
        [self pickerView:_datePicker didSelectRow:integer inComponent:1];//选中
        [_datePicker selectRow:integer inComponent:1 animated:YES];
        NSInteger row2 = [self.hourArray indexOfObject:[NSString stringWithFormat:@"%02ld",(long)[self componentsWithDate:cuDate].hour]];
        if (row2>self.hourArray.count-1)return;
        [_datePicker selectRow:row2 inComponent:2 animated:YES];
        NSInteger min = [self.minuteArray indexOfObject:[NSString stringWithFormat:@"%02ld",(long)[self componentsWithDate:cuDate].minute]];
        if (min>self.minuteArray.count-1)return;
        [_datePicker selectRow:min inComponent:4 animated:YES];
    }
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
    }
    return _formatter;
}


- (NSMutableArray<NSString *> *)yearArray
{
    if (!_yearArray) {
        _yearArray = [NSMutableArray array];
        if (self.datePickerMode == SSJDatePickerModeYearDateAndTime) {
            [_yearArray addObject:@" "];
        } else if(self.datePickerMode == SSJDatePickerModeDate) {
            [self setUpYearArray];
        }
    }
    return _yearArray;
}


- (NSMutableArray<NSDate *> *)monthDayWeekArray
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
//            NSString *string = [self.formatter stringFromDate:date];
//            NSDate *date1 = [self.formatter dateFromString:string];
            [_monthDayWeekArray addObject:date];
            date = [date dateByAddingDays:1];
        }
    }
    return _monthDayWeekArray;
}

- (NSArray<NSString *> *)hourArray
{
    
    if (!_hourArray) {
        if (self.datePickerMode == SSJDatePickerModeTime || self.datePickerMode == SSJDatePickerModeDateAndTime) {
            _hourArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12"];
        } else {
            _hourArray = @[@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23"];
        }
    }
    return _hourArray;
}

- (NSArray<NSString *> *)minuteArray
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

- (NSArray<NSString *> *)monthArray
{
    if (!_monthArray) {
        _monthArray = @[@"1月",@"2月",@"3月",@"4月",@"5月",@"6月",@"7月",@"8月",@"9月",@"10月",@"11月",@"12月"];
    }
    return _monthArray;
}

- (NSMutableArray<NSString *> *)dayArray
{
    if (!_dayArray) {
        _dayArray = [NSMutableArray array];
        //默认当前月的天数
        NSDate *currentDate = self.date ? self.date : [NSDate date];
        NSInteger days = [self howManyDaysInThisYear:currentDate.year withMonth:currentDate.month];
        _dayArray = [self setUpDayArrayWithDays:days];
    }
    return _dayArray;
}

- (NSArray<NSString *> *)amPmArray
{
    if (!_amPmArray) {
        _amPmArray = @[@"上午",@"下午"];
    }
    return _amPmArray;
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray  = [NSMutableArray array];
        if (self.datePickerMode == SSJDatePickerModeTime) {
            [_dataArray addObject:self.amPmArray];
            [_dataArray addObject:self.hourArray];
            [_dataArray addObject:self.minuteArray];
        } else if (self.datePickerMode == SSJDatePickerModeDate) {
            [_dataArray addObject:self.yearArray];
            [_dataArray addObject:self.monthArray];
            [_dataArray addObject:self.dayArray];
        } else if (self.datePickerMode == SSJDatePickerModeDateAndTime) {
            [_dataArray addObject:self.monthDayWeekArray];
            [_dataArray addObject:self.amPmArray];
            [_dataArray addObject:self.hourArray];
            [_dataArray addObject:self.minuteArray];
        } else if (self.datePickerMode == SSJDatePickerModeYearDateAndTime) {
            [_dataArray addObject:self.yearArray];
            [_dataArray addObject:self.monthDayWeekArray];
            [_dataArray addObject:self.hourArray];
            [_dataArray addObject:@[@"时"]];
            [_dataArray addObject:self.minuteArray];
            [_dataArray addObject:@[@"分"]];
        }
    }
    return _dataArray;
}

#pragma mark - Action
- (void)closeButtonClicked
{
    if (_closeBlock) {
        _closeBlock(self);
    }
    [self dismiss];
}

- (void)comfirmButtonClicked
{
    NSDate *cuDate = [NSDate date];
    //    NSString *language = [self getPreferredLanguage];
    NSString *amStr = [[NSCalendar currentCalendar] AMSymbol];
    NSString *pmStr = [[NSCalendar currentCalendar] PMSymbol];
    //    NSString *amStr = @"上午";
    //    NSString *pmStr = @"下午";
    //    if ([language containsString:@"en"]) {
    //        amStr = @"AM";
    //        pmStr = @"PM";
    //    }
    NSDate *selectedDate = nil;//选择的时间
    if (self.datePickerMode == SSJDatePickerModeTime) {
        NSInteger index1 = [self.datePicker selectedRowInComponent:0];//上午下午
        NSInteger index2 = [self.datePicker selectedRowInComponent:1];//时
        NSInteger index3 = [self.datePicker selectedRowInComponent:2];//分
        [self.formatter setDateFormat:@"yyyy年MM月dd日"];
        if ([self checkDateSetting24Hours] == YES) {//24小时制
            NSString *hourStr = [self.hourArray ssj_safeObjectAtIndex:index2];
            if (index1 == 0) {//上午
                hourStr = hourStr;
            } else {//下午
                NSInteger hourValue = [hourStr integerValue] + 12;
                hourStr = [NSString stringWithFormat:@"%ld",(long)hourValue];
            }
            NSString *dateStr = [NSString stringWithFormat:@"%@ %@:%@",[self.formatter stringFromDate:cuDate],hourStr,[self.minuteArray ssj_safeObjectAtIndex:index3]];
            selectedDate = [NSDate dateWithString:dateStr formatString:@"yyyy年MM月dd日 HH:mm"];
        } else { //12小时制
            NSString *dateStr = [NSString stringWithFormat:@"%@ %@ %@:%@",[self.formatter stringFromDate:cuDate],index1 == 0 ? amStr : pmStr,[self.hourArray ssj_safeObjectAtIndex:index2],[self.minuteArray ssj_safeObjectAtIndex:index3]];
            selectedDate = [NSDate dateWithString:dateStr formatString:@"yyyy年MM月dd日 aa h:mm"];
        }
        //
    } else if (self.datePickerMode == SSJDatePickerModeDate) {
        NSInteger index1 = [self.datePicker selectedRowInComponent:0];//年
        NSInteger index2 = [self.datePicker selectedRowInComponent:1];//月
        NSInteger index3 = [self.datePicker selectedRowInComponent:2];//日
        NSString *indexStr1 = [self.yearArray ssj_safeObjectAtIndex:index1];
        NSString *indexStr2 = [self.monthArray ssj_safeObjectAtIndex:index2];
        NSString *indexStr3 = [self.dayArray ssj_safeObjectAtIndex:index3];
        selectedDate = [NSDate dateWithYear:[[indexStr1 substringToIndex:indexStr1.length - 1] integerValue] month:[[indexStr2 substringToIndex:indexStr2.length - 1] integerValue] day:[[indexStr3 substringToIndex:indexStr3.length - 1] integerValue] hour:0 minute:0 second:0];
    } else if (self.datePickerMode == SSJDatePickerModeDateAndTime) {
        NSInteger index1 = [self.datePicker selectedRowInComponent:0];//月日周
        NSInteger index2 = [self.datePicker selectedRowInComponent:1];//上午，下午
        NSInteger index3 = [self.datePicker selectedRowInComponent:2];//时
        NSInteger index4 = [self.datePicker selectedRowInComponent:3];//分
        NSDate *indexStr1 = [self.monthDayWeekArray ssj_safeObjectAtIndex:index1];
        [self.formatter setDateFormat:@"yyyy年MM月dd日 EEE"];
        NSString *str = [self.formatter stringFromDate:indexStr1];
        if ([self checkDateSetting24Hours] == YES) {//24小时制
            NSString *hourStr = [self.hourArray ssj_safeObjectAtIndex:index3];
            if (index1 == 0) {//上午
                hourStr = hourStr;
            } else {//下午
                NSInteger hourValue = [hourStr integerValue] + 12;
                hourStr = [NSString stringWithFormat:@"%ld",(long)hourValue];
            }
            NSString *dateStr = [NSString stringWithFormat:@"%@ %@:%@",[self.formatter stringFromDate:cuDate],hourStr,[self.minuteArray ssj_safeObjectAtIndex:index4]];
            selectedDate = [NSDate dateWithString:dateStr formatString:@"yyyy年MM月dd日 HH:mm"];
        } else { //12小时制
            NSString *dateStr = [NSString stringWithFormat:@"%@ %@:%@ %@",str,[self.hourArray ssj_safeObjectAtIndex:index3],[self.minuteArray ssj_safeObjectAtIndex:index4],index2 == 0 ? amStr : pmStr];
            selectedDate = [NSDate dateWithString:dateStr formatString:@"yyyy年MM月dd日 EEE h:mm aa"];
        }
    } else if (self.datePickerMode == SSJDatePickerModeYearDateAndTime) {
        //选择的时间
        NSDate *date = [self.monthDayWeekArray ssj_safeObjectAtIndex:[self.datePicker selectedRowInComponent:1]];
        [self.formatter setDateFormat:@"yyyy年MM月dd日 EEE"];
        NSString *yearMonDayStr = [self.formatter stringFromDate:date];
        NSString *hourStr = [self.hourArray ssj_safeObjectAtIndex:[self.datePicker selectedRowInComponent:2]];
        NSString *minuStr = [self.minuteArray ssj_safeObjectAtIndex:[self.datePicker selectedRowInComponent:4]];
        
        NSString *dateStr = [NSString stringWithFormat:@"%@ %@时%@分",yearMonDayStr,hourStr,minuStr];
        selectedDate = [NSDate dateWithString:dateStr formatString:@"yyyy年MM月dd日 EEEHH时mm分"];
    }
    
    BOOL shouldConfirm = YES;
    if (_shouldConfirmBlock) {
        shouldConfirm = _shouldConfirmBlock(self, selectedDate);
    }
    
    if (shouldConfirm) {
        self.date = selectedDate;
        [self dismiss];
        if (_confirmBlock) {
            _confirmBlock(self);
        }
    } else {
        [self defaultSelectedcomponents];
    }
}

- (void)show
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    self.top = keyWindow.height;
    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.3 target:self touchAction:@selector(dismiss) animation:^{
        self.bottom = keyWindow.height;
    } timeInterval:0.25 fininshed:^(BOOL finished) {
        if (_showBlock) {
            _showBlock(self);
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
            _dismissBlock(self);
        }
    }];
}
#pragma mark - Private

/**
 遍历取出所有的年
 */
- (void)setUpYearArray
{
    //默认年份在2001-2038之间
    if (!self.minDate) {
        self.minDate = [NSDate dateWithYear:2001 month:1 day:1];
    }
    if (!self.maxDate) {
        self.maxDate = [NSDate dateWithYear:2038 month:1 day:1];
    }
    for (NSInteger i = self.minDate.year; i <= self.maxDate.year; i++) {
        [_yearArray addObject:[NSString stringWithFormat:@"%ld年",(long)i]];
    }
}


- (NSMutableArray *)setUpDayArrayWithDays:(NSInteger)day
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 1;i <= day; i++) {
        [array addObject:[NSString stringWithFormat:@"%ld日",(long)i]];
    }
    return array;
}

/**
 获取某年某月的天数
 @param NSInteger <#NSInteger description#>
 @return <#return value description#>
 */
- (NSInteger)howManyDaysInThisYear:(NSInteger)year withMonth:(NSInteger)month{
    if((month == 1) || (month == 3) || (month == 5) || (month == 7) || (month == 8) || (month == 10) || (month == 12))
        return 31 ;
    
    if((month == 4) || (month == 6) || (month == 9) || (month == 11))
        return 30;
    
    if((year % 4 == 1) || (year % 4 == 2) || (year % 4 == 3))
    {
        return 28;
    }
    
    if(year % 400 == 0)
        return 29;
    
    if(year % 100 == 0)
        return 28;
    
    return 29;
}

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

/**
 *得到本机现在用的语言
 * en:英文  zh-Hans:简体中文   zh-Hant:繁体中文    ja:日本  ......
 */
- (NSString*)getPreferredLanguage
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages ssj_safeObjectAtIndex:0];
    return preferredLang;
}

- (void)updateButton:(UIButton *)button buttonItem:(SSJHomeDatePickerViewButtonItem *)item {
    [button setTitle:item.title forState:UIControlStateNormal];
    [button setTitleColor:item.titleColor forState:UIControlStateNormal];
    [button setImage:item.image forState:UIControlStateNormal];
    [button sizeToFit];
}

#pragma mark - UIPickerViewDelegate
// 选中某一行的时候调用
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.datePickerMode == SSJDatePickerModeTime) {
        
        return;
    }
    if (self.datePickerMode == SSJDatePickerModeDate && component == 1) {//选中月份
        NSInteger yearIndex = [pickerView selectedRowInComponent:0];//取出选中的年
        NSString *yearStr = [self.yearArray ssj_safeObjectAtIndex:yearIndex];
        NSInteger year = [[yearStr substringToIndex:yearStr.length - 1] integerValue];
        //月
        NSString *monthStr = [self.monthArray ssj_safeObjectAtIndex:row];
        NSInteger month = [[monthStr substringToIndex:monthStr.length - 1] integerValue];
        //计算日数组
        NSInteger days = [self howManyDaysInThisYear:year withMonth:month];
        //更新日数组
        self.dayArray = [self setUpDayArrayWithDays:days];
        //刷新日所在的列
        [pickerView reloadComponent:2];
        return;
    }
    if (self.datePickerMode == SSJDatePickerModeDateAndTime) {
        
        return;
    }
    if (self.datePickerMode == SSJDatePickerModeYearDateAndTime) {
        //取出时间
        if (component == 1) {
            [self.formatter setDateFormat:@"yyyy年"];
            NSString *dateStr = [self.formatter stringFromDate:[self.monthDayWeekArray ssj_safeObjectAtIndex:row]];
            //显示年
            self.yearArray = [NSMutableArray arrayWithObject:dateStr];
            [self.datePicker reloadComponent:0];
        }
        return;
    }
}

- (BOOL)checkDateSetting24Hours{
    BOOL is24Hours = YES;
    NSString *dateStr = [[NSDate date] descriptionWithLocale:[NSLocale currentLocale]];
    NSArray  *sysbols = @[[[NSCalendar currentCalendar] AMSymbol],[[NSCalendar currentCalendar] PMSymbol]];
    for (NSString *symbol in sysbols) {
        if ([dateStr rangeOfString:symbol].location != NSNotFound) {//find
            is24Hours = NO;
            break;
        }
    }
    return is24Hours;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.dataArray.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 2 && self.datePickerMode == SSJDatePickerModeDate) {
        return self.dayArray.count;
    }
    return ((NSArray *)[self.dataArray ssj_safeObjectAtIndex:component]).count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (self.datePickerMode == SSJDatePickerModeDateAndTime) {
        if (component == 0) {
            return 180;
        }else if (component == 1){
            return 40;
        }
        return (self.width - 240) / 2;
    }

    if (self.datePickerMode == SSJDatePickerModeYearDateAndTime) {
        if (component == 0) {
            return 45;
        }else if (component == 1){
            return 150;
        }else if (component == 3 || component == 5) {
            return 20;
        }
        return (self.width - 220) / 3;
    }
    return self.width / 3;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    CGFloat width = [pickerView rowSizeForComponent:component].width;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 40)];
    label.textAlignment = NSTextAlignmentCenter;
    if (self.datePickerMode == SSJDatePickerModeTime) {
        [self datePickerModeTime:label viewForRow:row forComponent:component];
    } else if (self.datePickerMode == SSJDatePickerModeDate) {
        [self datePickerModeDate:label viewForRow:row forComponent:component];
    } else if (self.datePickerMode == SSJDatePickerModeDateAndTime) {
        [self datePickerModeDateAndTime:label viewForRow:row forComponent:component];
    } else if (self.datePickerMode == SSJDatePickerModeYearDateAndTime) {
        [self datePickerModeYearDateAndTime:label viewForRow:row forComponent:component];
    }
    return label;
}

- (void)datePickerModeTime:(UIView *)view viewForRow:(NSInteger)row forComponent:(NSInteger)component
{
    UILabel *label = (UILabel *)view;
    label.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
    label.textColor = [UIColor ssj_colorWithHex:self.mainColor ? self.mainColor : SSJ_CURRENT_THEME.mainColor];
    label.text = [[self.dataArray ssj_safeObjectAtIndex:component] ssj_safeObjectAtIndex:row];
}
- (void)datePickerModeDate:(UIView *)view viewForRow:(NSInteger)row forComponent:(NSInteger)component
{
    UILabel *label = (UILabel *)view;
    label.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
    label.textColor = [UIColor ssj_colorWithHex:self.mainColor ? self.mainColor : SSJ_CURRENT_THEME.mainColor];
    if (component == 2) {
        label.text = [self.dayArray ssj_safeObjectAtIndex:row];
    } else {
        label.text = [[self.dataArray ssj_safeObjectAtIndex:component] ssj_safeObjectAtIndex:row];
    }
}
- (void)datePickerModeDateAndTime:(UIView *)view viewForRow:(NSInteger)row forComponent:(NSInteger)component
{
    UILabel *label = (UILabel *)view;
    label.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
    label.textColor = [UIColor ssj_colorWithHex:self.mainColor ? self.mainColor : SSJ_CURRENT_THEME.mainColor];
    if (component == 0) {
        BOOL isToday = [self.monthDayWeekArray[row] isSameDay:[NSDate date]];
        if (isToday) {
            label.text = @"今天";
        } else {
            [self.formatter setDateFormat:@"MM月dd日 EEE"];
            label.text = [self.formatter stringFromDate:self.monthDayWeekArray[row]];
        }
        
    } else {
        label.text = [[self.dataArray ssj_safeObjectAtIndex:component] ssj_safeObjectAtIndex:row];
    }
    
}
- (void)datePickerModeYearDateAndTime:(UIView *)view viewForRow:(NSInteger)row forComponent:(NSInteger)component
{
    UILabel *label = (UILabel *)view;
    if (component == 0 ) {
        label.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_6];
        label.textColor = [UIColor ssj_colorWithHex:self.mainColor ? self.mainColor : SSJ_CURRENT_THEME.mainColor];
    }else if (component == 1){
        label.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        label.textColor = [UIColor ssj_colorWithHex:self.mainColor ? self.mainColor : SSJ_CURRENT_THEME.mainColor];
    }else if (component == 2 || component == 4) {
        label.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
        label.textAlignment = NSTextAlignmentRight;
        label.textColor = [UIColor ssj_colorWithHex:self.mainColor ? self.mainColor : SSJ_CURRENT_THEME.mainColor];
    }else {
        label.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_6];
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
//    self.horuAndMinuBgView.backgroundColor = self.horuAndMinuBgViewBgColor ? self.horuAndMinuBgViewBgColor : [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainFillColor alpha:1];
}
- (void)setHoruAndMinuBgViewBgColor:(UIColor *)horuAndMinuBgViewBgColor
{
    _horuAndMinuBgViewBgColor = horuAndMinuBgViewBgColor;
    self.horuAndMinuBgView.backgroundColor = horuAndMinuBgViewBgColor;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

@implementation SSJHomeDatePickerViewButtonItem

+ (instancetype)buttonItemWithTitle:(nullable NSString *)title
                         titleColor:(nullable UIColor *)titleColor
                              image:(nullable UIImage *)image {
    
    SSJHomeDatePickerViewButtonItem *item = [[SSJHomeDatePickerViewButtonItem alloc] init];
    item.title = title;
    item.titleColor = titleColor;
    item.image = image;
    return item;
}

@end
