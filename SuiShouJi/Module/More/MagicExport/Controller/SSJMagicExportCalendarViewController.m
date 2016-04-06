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
        self.billDates = result;
        [self.view addSubview:self.calendarView];
        [self.calendarView reload];
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
    return @{SSJMagicExportCalendarViewBeginDateKey:self.beginDate,
             SSJMagicExportCalendarViewEndDateKey:self.endDate};
}

- (BOOL)calendarView:(SSJMagicExportCalendarView *)calendarView shouldShowMarkerForDate:(NSDate *)date {
    return YES;
}

- (NSString *)calendarView:(SSJMagicExportCalendarView *)calendarView descriptionForSelectedDate:(NSDate *)date {
    return nil;
}

- (void)calendarView:(SSJMagicExportCalendarView *)calendarView didSelectedDate:(NSDate *)date {
    
}

- (void)calendarView:(SSJMagicExportCalendarView *)calendarView didDeselectedDate:(NSDate *)date {
    
}

#pragma mark - Getter
- (SSJMagicExportCalendarView *)calendarView {
    if (!_calendarView) {
        _calendarView = [[SSJMagicExportCalendarView alloc] initWithFrame:self.view.bounds];
        _calendarView.delegate = self;
    }
    return _calendarView;
}

@end
