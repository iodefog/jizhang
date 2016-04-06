//
//  SSJMagicExportCalendarViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/4/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportCalendarViewController.h"
#import "SSJMagicExportCalendarView.h"

@interface SSJMagicExportCalendarViewController () <SSJMagicExportCalendarViewDelegate>

@property (nonatomic, strong) SSJMagicExportCalendarView *calendarView;

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
    
    [self.view addSubview:self.calendarView];
    [self.calendarView reload];
}

#pragma mark - SSJMagicExportCalendarViewDelegate
- (NSDictionary<NSString *, NSDate *>*)periodForCalendarView:(SSJMagicExportCalendarView *)calendarView {
    return @{SSJMagicExportCalendarViewBeginDateKey:[NSDate dateWithYear:2016 month:1 day:1],
             SSJMagicExportCalendarViewEndDateKey:[NSDate dateWithYear:2016 month:2 day:1]};
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
