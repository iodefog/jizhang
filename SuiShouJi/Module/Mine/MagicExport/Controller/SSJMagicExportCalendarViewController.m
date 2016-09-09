//
//  SSJMagicExportCalendarViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/4/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportCalendarViewController.h"
#import "SSJMagicExportCalendarSwitchStartAndEndDateControl.h"
#import "SSJMagicExportCalendarView.h"
#import "SSJMagicExportStore.h"
#import "SSJUserTableManager.h"

@interface SSJMagicExportCalendarViewController () <SSJMagicExportCalendarViewDelegate>

@property (nonatomic, strong) SSJMagicExportCalendarSwitchStartAndEndDateControl *dateSwitchControl;

@property (nonatomic, strong) SSJMagicExportCalendarView *calendarView;

@property (nonatomic, strong) NSArray *billDates;

@end

@implementation SSJMagicExportCalendarViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.navigationItem.title = @"选择导出时间";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view ssj_showLoadingIndicator];
    [SSJMagicExportStore queryAllBillDateWithBillType:_billType booksId:_booksId success:^(NSArray<NSDate *> *result) {
        [self.view ssj_hideLoadingIndicator];
        if (result.count) {
            _billDates = result;
            [self.view addSubview:self.dateSwitchControl];
            [self.view addSubview:self.calendarView];
            [self updateAppearance];
            
            [self.calendarView reload];
            [self.calendarView scrollToDate:_beginDate];
        }
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.calendarView.height = self.view.height - self.dateSwitchControl.bottom;
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
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
    if (_endDate && [date isSameDay:_endDate]) {
        return @"结束";
    } else if (_beginDate && [date isSameDay:_beginDate]) {
        return @"开始";
    } else {
        return nil;
    }
}

- (UIColor *)calendarView:(SSJMagicExportCalendarView *)calendarView colorForDate:(NSDate *)date {
    NSDate *nowDate = [NSDate date];
    nowDate = [NSDate dateWithYear:nowDate.year month:nowDate.month day:nowDate.day];
    
    if ([nowDate compare:date] == NSOrderedAscending
        || (_beginDate && [_beginDate compare:date] == NSOrderedDescending)
        || (_endDate && [_endDate compare:date] == NSOrderedAscending)) {
        return [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    
    return [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
}

- (BOOL)calendarView:(SSJMagicExportCalendarView *)calendarView shouldSelectDate:(NSDate *)date {
    if (_beginDate && [_beginDate compare:date] == NSOrderedDescending) {
        [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"亲，不能选择早于起始日期的时间哦" action:[SSJAlertViewAction actionWithTitle:@"确认" handler:NULL], nil];
        return NO;
    }
    
    NSDate *nowDate = [NSDate date];
    nowDate = [NSDate dateWithYear:nowDate.year month:nowDate.month day:nowDate.day];
    if ([nowDate compare:date] == NSOrderedAscending) {
        [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"亲，起始日期不能晚于今天哦" action:[SSJAlertViewAction actionWithTitle:@"确认" handler:NULL], nil];
        return NO;
    }
    
    return YES;
}

- (void)calendarView:(SSJMagicExportCalendarView *)calendarView didSelectDate:(NSDate *)date {
    if (!_beginDate) {
        _beginDate = date;
        _dateSwitchControl.beginDate = date;
        [_calendarView reload];
    } else {
        _endDate = date;
        _dateSwitchControl.endDate = date;
        _calendarView.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_completion) {
                _completion(_beginDate, _endDate);
            }
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

#pragma mark - Private
- (void)updateAppearance {
    _dateSwitchControl.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    _calendarView.highlightColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    [_calendarView reload];
    [_calendarView updateAppearance];
}

#pragma mark - Getter
- (SSJMagicExportCalendarSwitchStartAndEndDateControl *)dateSwitchControl {
    if (!_dateSwitchControl) {
        __weak typeof(self) wself = self;
        _dateSwitchControl = [[SSJMagicExportCalendarSwitchStartAndEndDateControl alloc] initWithFrame:CGRectMake(0, 10 + SSJ_NAVIBAR_BOTTOM, self.view.width, 68)];
        _dateSwitchControl.beginDate = _beginDate;
        _dateSwitchControl.endDate = _endDate;
        _dateSwitchControl.clickBeginDateAction = ^{
            if (wself.beginDate) {
                [wself.calendarView deselectDates:@[wself.beginDate]];
                wself.beginDate = nil;
                wself.dateSwitchControl.beginDate = nil;
                [wself.calendarView reload];
            }
        };
    }
    return _dateSwitchControl;
}

- (SSJMagicExportCalendarView *)calendarView {
    if (!_calendarView) {
        NSMutableArray *selectedDates = [@[] mutableCopy];
        if (_beginDate) {
            [selectedDates addObject:_beginDate];
        }
        if (_endDate) {
            [selectedDates addObject:_endDate];
        }
        _calendarView = [[SSJMagicExportCalendarView alloc] initWithFrame:CGRectMake(0, self.dateSwitchControl.bottom, self.view.width, self.view.height - self.dateSwitchControl.bottom)];
        _calendarView.delegate = self;
        _calendarView.selectedDates = selectedDates;
        _calendarView.selectedDateColor = [UIColor whiteColor];
    }
    return _calendarView;
}

@end
