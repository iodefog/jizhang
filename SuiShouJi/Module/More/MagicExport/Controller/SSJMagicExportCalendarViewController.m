//
//  SSJMagicExportCalendarViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/4/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportCalendarViewController.h"
#import "SSJMagicExportCalendarView.h"
#import "SSJMagicExportStore.h"

@interface SSJMagicExportCalendarViewController () <SSJMagicExportCalendarViewDelegate>

@property (nonatomic, strong) NSDate *selectBeginDate;

@property (nonatomic, strong) NSDate *selectEndDate;

@property (nonatomic, strong) SSJMagicExportCalendarView *calendarView;

@property (nonatomic, strong) NSArray *billDates;

@end

@implementation SSJMagicExportCalendarViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.navigationItem.title = @"选择导出时间";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self.view ssj_showLoadingIndicator];
    
    [SSJMagicExportStore queryAllBillDateWithSuccess:^(NSArray<NSDate *> *result) {
        [self.view ssj_hideLoadingIndicator];
        _billDates = result;
        if (_billDates) {
            [self.view addSubview:self.calendarView];
            [self.calendarView reload];
            [self.calendarView scrollToDate:_beginDate];
        } else {
            
        }
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.calendarView.frame = CGRectMake(0, 10, self.view.width, self.view.height - 10);
}

#pragma mark - SSJMagicExportCalendarViewDelegate
- (NSDictionary<NSString *, NSDate *>*)periodForCalendarView:(SSJMagicExportCalendarView *)calendarView {
    return @{SSJMagicExportCalendarViewBeginDateKey:[_billDates firstObject],
             SSJMagicExportCalendarViewEndDateKey:[_billDates lastObject]};
}

- (BOOL)calendarView:(SSJMagicExportCalendarView *)calendarView shouldShowMarkerForDate:(NSDate *)date {
    return [self.billDates containsObject:date];
}

- (NSString *)calendarView:(SSJMagicExportCalendarView *)calendarView descriptionForSelectedDate:(NSDate *)date {
    if ((_selectBeginDate && [date isSameDay:_selectBeginDate])
        || (_beginDate && [date isSameDay:_beginDate])) {
        return @"开始";
    } else if ((_selectEndDate && [date isSameDay:_selectEndDate])
               || (_endDate && [date isSameDay:_endDate])) {
        return @"结束";
    } else {
        return nil;
    }
}

- (void)calendarView:(SSJMagicExportCalendarView *)calendarView willSelectDate:(NSDate *)date {
    if (_selectBeginDate) {
        if ([_selectBeginDate compare:date] == NSOrderedDescending) {
            // 选择的日期在开始日期之前
            [calendarView deselectDates:@[_selectBeginDate]];
            _selectBeginDate = date;
        } else {
            // 选择结束日期
            _selectEndDate = date;
            if (_completion) {
                _completion(_selectBeginDate, _selectEndDate);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        // 第一次选择开始日期
        _selectBeginDate = date;
        [calendarView deselectDates:@[_beginDate, _endDate]];
    }
}

- (void)calendarView:(SSJMagicExportCalendarView *)calendarView didSelectDate:(NSDate *)date {
    
}

#pragma mark - Getter
- (SSJMagicExportCalendarView *)calendarView {
    if (!_calendarView) {
        _calendarView = [[SSJMagicExportCalendarView alloc] initWithFrame:self.view.bounds];
        _calendarView.delegate = self;
        _calendarView.selectedDates = @[self.beginDate, self.endDate];
    }
    return _calendarView;
}

@end
