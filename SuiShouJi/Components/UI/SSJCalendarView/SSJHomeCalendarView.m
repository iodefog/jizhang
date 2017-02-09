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

@property (nonatomic, strong) NSDateFormatter *formatter;

/**
 年数组
 */
@property (nonatomic, strong) NSArray *yearArray;
//@property (nonatomic, strong) NSArray *monthArray;
@property (nonatomic, strong) NSMutableArray *monthDayWeekArray;
@property (nonatomic, strong) NSArray *hourArray;
@property (nonatomic, strong) NSArray *minuteArray;
/**
 数据源
 */
@property (nonatomic, strong) NSArray *dataArray;
/**
 <#注释#>
 */
@property (nonatomic, strong) NSCalendar *calendar;
@end

@implementation SSJHomeCalendarView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        [self addSubview:self.datePicker];
    }
    return self;
}



#pragma mark - Lazy
- (UIPickerView *)datePicker
{
    if (!_datePicker) {
        _datePicker = [[UIPickerView alloc] initWithFrame:self.bounds];
        _datePicker.delegate = self;
        _datePicker.dataSource = self;
        NSDate *cuDate = self.date ? self.date : [NSDate date];
        self.formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [self.formatter setDateFormat:@"yyyy-MM月dd日 EEE"];
        NSString *dateStr = [self.formatter stringFromDate:cuDate];
        NSDate *seleDate = [self.formatter dateFromString:dateStr];
        NSInteger integer = [self.monthDayWeekArray indexOfObject:seleDate];
        [self pickerView:_datePicker didSelectRow:integer inComponent:1];//选中
        [_datePicker selectRow:integer inComponent:1 animated:YES];
        [_datePicker selectRow:[self.hourArray indexOfObject:[NSString stringWithFormat:@"%02ld",[self componentsWithDate:cuDate].hour]] inComponent:2 animated:YES];
        NSInteger min = [self.minuteArray indexOfObject:[NSString stringWithFormat:@"%02ld",[self componentsWithDate:cuDate].minute]];
        [_datePicker selectRow:min inComponent:3 animated:YES];
    }
    return _datePicker;
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
        self.formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
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
        _dataArray = @[self.yearArray,self.monthDayWeekArray,self.hourArray,self.minuteArray];//[NSMutableArray arrayWithObjects:self.yearArray,self.monthDayWeekArray,self.hourArray,self.minuteArray, nil];
        [self.datePicker reloadAllComponents];
    }
    return _dataArray;
}

#pragma mark - Action

#pragma mark - Private
- (void)setDatePickerMode:(SSJDatePickerMode)datePickerMode
{
//    switch (datePickerMode) {
//        case SSJDatePickerModeTime:
//            self.datePickerMode = UIDatePickerModeTime;
//            break;
//        case SSJDatePickerModeDate:
//            self.datePickerMode = UIDatePickerModeDate;
//            break;
//        case SSJDatePickerModeDateAndTime:
//            self.datePickerMode = UIDatePickerModeDateAndTime;
//            break;
//        default:
//            self.datePickerMode = UIDatePickerModeDateAndTime;
//            break;
//    }
}

- (void)dateToDateStr:(NSDate *)date
{
}
//- (void)setDate:(NSDate *)date animated:(BOOL)animated
//{
//    [self.datePicker setDate:date animated:animated];
//}

- (void)setTitleColor:(UIColor *)color forComponent:(SSJDatePickerComponent)component
{
    
}

- (void)setFillColor:(UIColor *)color forComponent:(SSJDatePickerComponent)component
{
    
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
        return 90;
    }else if (component == 1){
        return 170;
    }
    return (self.width - 270) / 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
//        NSDate *date = [self.formatter dateFromString:[self.yearArray firstObject]];
//        return [NSString stringWithFormat:@"%ld年",date.year];
        return [self.yearArray firstObject];
    } else if (component == 1) {
        self.formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [self.formatter setDateFormat:@"MM月dd日 EEE"];
        return [self.formatter stringFromDate:self.monthDayWeekArray[row]];
    }
    return [[self.dataArray ssj_safeObjectAtIndex:component] ssj_safeObjectAtIndex:row];
}

//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
//{
//    if (component == 0) {
//        UIView *volat = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
//        volat.backgroundColor = [UIColor redColor];
//        return volat;
//    }
//    return [[UIView alloc] init];
//}

@end
