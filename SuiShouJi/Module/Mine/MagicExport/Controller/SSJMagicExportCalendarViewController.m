//
//  SSJMagicExportCalendarViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/4/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportCalendarViewController.h"
#import "SSJMagicExportCalendarSwitchStartAndEndDateControl.h"
#import "UIViewController+MMDrawerController.h"
#import "SSJMagicExportCalendarView.h"
#import "SSJMagicExportStore.h"
#import "SSJUserTableManager.h"

@interface SSJMagicExportCalendarViewController () <SSJMagicExportCalendarViewDataSource, SSJMagicExportCalendarViewDelegate>

@property (nonatomic, strong) SSJMagicExportCalendarSwitchStartAndEndDateControl *dateSwitchControl;

@property (nonatomic, strong) SSJMagicExportCalendarView *calendarView;

@property (nonatomic, strong) NSArray *billDates;

@end

@implementation SSJMagicExportCalendarViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _billType = SSJBillTypeSurplus;
        self.navigationItem.title = @"选择导出时间";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view ssj_showLoadingIndicator];
    [SSJMagicExportStore queryAllBillDateWithBillId:self.billTypeId billName:self.billName billType:self.billType booksId:self.booksId userId:self.userId containsSpecialCharges:self.containsSpecialCharges success:^(NSArray<NSDate *> * _Nonnull result) {
        [self.view ssj_hideLoadingIndicator];
        if (result.count) {
            _billDates = result;
            [self.view addSubview:self.dateSwitchControl];
            [self.view addSubview:self.calendarView];
            [self updateAppearance];
            
            [self.calendarView reloadData];
            NSMutableArray *selectedDates = [@[] mutableCopy];
            if (self.selectedBeginDate) {
                [selectedDates addObject:self.selectedBeginDate];
            }
            if (self.selectedEndDate) {
                [selectedDates addObject:self.selectedEndDate];
            }
            self.calendarView.selectedDates = selectedDates;
            [self.calendarView scrollToDate:self.selectedBeginDate animated:NO];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showError:error];
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

#pragma mark - SSJMagicExportCalendarViewDataSource
- (NSDictionary<NSString *, NSDate *>*)periodForCalendarView:(SSJMagicExportCalendarView *)calendarView {
    return @{SSJMagicExportCalendarViewBeginDateKey:[_billDates firstObject],
             SSJMagicExportCalendarViewEndDateKey:[_billDates lastObject]};
}

- (BOOL)calendarView:(SSJMagicExportCalendarView *)calendarView shouldShowMarkerForDate:(NSDate *)date {
    return [self.billDates containsObject:date];
}

- (NSString *)calendarView:(SSJMagicExportCalendarView *)calendarView descriptionForSelectedDate:(NSDate *)date {
    if (_selectedEndDate && [date isSameDay:_selectedEndDate]) {
        return @"结束";
    } else if (_selectedBeginDate && [date isSameDay:_selectedBeginDate]) {
        return @"开始";
    } else {
        return nil;
    }
}

#pragma mark - SSJMagicExportCalendarViewDelegate
- (void)calendarView:(SSJMagicExportCalendarView *)calendarView willSelectDate:(NSDate *)date {
    if (!_selectedBeginDate) {
        _selectedBeginDate = date;
        _dateSwitchControl.beginDate = date;
    } else if ((_selectedBeginDate && [date compare:_selectedBeginDate] == NSOrderedAscending)) {
        NSDate *lastBeginDate = _selectedBeginDate;
        _selectedBeginDate = date;
        _dateSwitchControl.beginDate = date;
        [calendarView deselectDates:@[lastBeginDate]];
        [calendarView reloadDates:@[lastBeginDate]];
    } else {
        _selectedEndDate = date;
        _dateSwitchControl.endDate = date;
        _calendarView.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_completion) {
                _completion(_selectedBeginDate, _selectedEndDate);
            }
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

- (UIColor *)calendarView:(SSJMagicExportCalendarView *)calendarView titleColorForDate:(NSDate *)date selected:(BOOL)selected {
    if ((_selectedBeginDate && [_selectedBeginDate compare:date] == NSOrderedSame)
        || (_selectedEndDate && [_selectedEndDate compare:date] == NSOrderedSame)) {
        return [UIColor whiteColor];
    } else {
        return SSJ_MAIN_COLOR;
    }
}

- (UIColor *)calendarView:(SSJMagicExportCalendarView *)calendarView markerColorForDate:(NSDate *)date selected:(BOOL)selected {
    return selected ? [UIColor whiteColor] : SSJ_MARCATO_COLOR;
}

#pragma mark - Private
- (void)updateAppearance {
    _dateSwitchControl.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    [_calendarView reloadData];
    [_calendarView updateAppearance];
}

#pragma mark - Getter
- (SSJMagicExportCalendarSwitchStartAndEndDateControl *)dateSwitchControl {
    if (!_dateSwitchControl) {
        __weak typeof(self) wself = self;
        _dateSwitchControl = [[SSJMagicExportCalendarSwitchStartAndEndDateControl alloc] initWithFrame:CGRectMake(0, 10 + SSJ_NAVIBAR_BOTTOM, self.view.width, 68)];
        _dateSwitchControl.beginDate = _selectedBeginDate;
        _dateSwitchControl.endDate = _selectedEndDate;
        _dateSwitchControl.clickBeginDateAction = ^{
            if (wself.selectedBeginDate) {
                [wself.calendarView deselectDates:@[wself.selectedBeginDate]];
                [wself.calendarView reloadDates:@[wself.selectedBeginDate]];
                wself.selectedBeginDate = nil;
                wself.dateSwitchControl.beginDate = nil;
                [wself.calendarView reloadData];
            }
        };
    }
    return _dateSwitchControl;
}

- (SSJMagicExportCalendarView *)calendarView {
    if (!_calendarView) {
        _calendarView = [[SSJMagicExportCalendarView alloc] initWithFrame:CGRectMake(0, self.dateSwitchControl.bottom, self.view.width, self.view.height - self.dateSwitchControl.bottom)];
        _calendarView.dataSource = self;
        _calendarView.delegate = self;
        _calendarView.descriptionColor = SSJ_MARCATO_COLOR;
        _calendarView.fillColor = SSJ_MARCATO_COLOR;
    }
    return _calendarView;
}

@end
