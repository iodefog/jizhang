//
//  SSJMagicExportCalendarView.m
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportCalendarView.h"
#import "SSJMagicExportCalendarViewCell.h"
#import "SSJMagicExportCalendarHeaderView.h"
#import "SSJMagicExportCalendarWeekView.h"
#import "SSJMagicExportCalendarDateView.h"
#import "SSJMagicExportCalendarViewCellItem.h"
#import "SSJMagicExportCalendarIndexPath.h"
#import "SSJDatePeriod.h"

NSString *const SSJMagicExportCalendarViewBeginDateKey = @"SSJMagicExportCalendarViewBeginDateKey";
NSString *const SSJMagicExportCalendarViewEndDateKey = @"SSJMagicExportCalendarViewEndDateKey";

static NSString *const kCalendarCellId = @"kCalendarCellId";
static NSString *const kCalendarHeaderId = @"kCalendarHeaderId";

@interface SSJMagicExportCalendarView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) SSJMagicExportCalendarWeekView *weekView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, strong) NSMutableDictionary *dateIndexMapping;

@end

@implementation SSJMagicExportCalendarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _items = [[NSMutableArray alloc] init];
        _dateIndexMapping = [[NSMutableDictionary alloc] init];
        
        [self addSubview:self.weekView];
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layoutSubviews {
    self.weekView.frame = CGRectMake(0, 0, self.width, 40);
    self.tableView.frame = CGRectMake(0, self.weekView.bottom, self.width, self.height - self.weekView.bottom);
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_items ssj_safeObjectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJMagicExportCalendarViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCalendarCellId forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
//    cell.willSelectBlock = ^(SSJMagicExportCalendarViewCell *cell, SSJMagicExportCalendarDateView *dateView) {
//        if (!weakSelf.delegate) {
//            return;
//        }
//        
//        if ([weakSelf.delegate respondsToSelector:@selector(calendarView:willSelectDate:)]) {
//            [weakSelf.delegate calendarView:weakSelf willSelectDate:dateView.item.date];
//        }
//        if ([weakSelf.delegate respondsToSelector:@selector(calendarView:descriptionForSelectedDate:)]) {
//            NSString *desc = [weakSelf.delegate calendarView:weakSelf descriptionForSelectedDate:dateView.item.date];
//            dateView.item.desc = desc;
//            [weakSelf.tableView reloadData];
//        }
//    };
    cell.didSelectBlock = ^(SSJMagicExportCalendarViewCell *cell, SSJMagicExportCalendarDateView *dateView) {
        if (!weakSelf.delegate) {
            return;
        }
        if (dateView.item.selected) {
            if (![weakSelf.selectedDates containsObject:dateView.item.date]) {
                NSMutableArray *tmpDates = [weakSelf.selectedDates mutableCopy];
                [tmpDates addObject:dateView.item.date];
                weakSelf.selectedDates = [tmpDates copy];
            }
            
            if ([weakSelf.delegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
                [weakSelf.delegate calendarView:weakSelf didSelectDate:dateView.item.date];
            }
            
            if ([weakSelf.delegate respondsToSelector:@selector(calendarView:descriptionForSelectedDate:)]) {
                NSString *desc = [weakSelf.delegate calendarView:weakSelf descriptionForSelectedDate:dateView.item.date];
                dateView.item.desc = desc;
                [weakSelf.tableView reloadData];
            }
        }
    };
    cell.dateItems = [_items ssj_objectAtIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SSJMagicExportCalendarHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kCalendarHeaderId];
    SSJMagicExportCalendarIndexPath *indexPath = [SSJMagicExportCalendarIndexPath indexPathForSection:section row:1 index:0];
    SSJMagicExportCalendarViewCellItem *item = [_items ssj_objectAtCalendarIndexPath:indexPath];
    headerView.textLabel.text = [item.date formattedDateWithFormat:@"yyyy年M月"];
    return headerView;
}

#pragma mark - Public
- (void)setSelectedDates:(NSArray<NSDate *> *)selectedDates {
    _selectedDates = selectedDates;
    for (NSArray *monthList in _items) {
        for (NSArray *weekList in monthList) {
            for (SSJMagicExportCalendarViewCellItem *dateItem in weekList) {
                if ([_selectedDates containsObject:dateItem.date]) {
                    dateItem.selected = YES;
                    if (_delegate && [_delegate respondsToSelector:@selector(calendarView:descriptionForSelectedDate:)]) {
                        dateItem.desc = [_delegate calendarView:self descriptionForSelectedDate:dateItem.date];
                    }
                } else {
                    dateItem.selected = NO;
                    dateItem.desc = nil;
                }
                
            }
        }
    }
    [self.tableView reloadData];
}

- (void)reload {
    if (!_delegate) {
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(periodForCalendarView:)]) {
        NSDictionary *periodInfo = [_delegate periodForCalendarView:self];
        _startDate = periodInfo[SSJMagicExportCalendarViewBeginDateKey];
        _endDate = periodInfo[SSJMagicExportCalendarViewEndDateKey];
    }
    
    if (![self checkStartDate:_startDate] || ![self checkEndDate:_endDate]) {
        return;
    }
    
    // 应为periodsBetweenDate方法返回的周期是从_startDate之后开始的，所以要加上_startDate的周期
    SSJDatePeriod *firstPeriod = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeMonth date:_startDate];
    NSArray *otherPeriods = [SSJDatePeriod periodsBetweenDate:_startDate andAnotherDate:_endDate periodType:SSJDatePeriodTypeMonth];
    
    NSMutableArray *periods = [[NSMutableArray alloc] initWithCapacity:(otherPeriods.count + 1)];
    [periods addObject:firstPeriod];
    [periods addObjectsFromArray:otherPeriods];
    
    [_items removeAllObjects];
    [_dateIndexMapping removeAllObjects];
    
    __block int section = 0;
    [periods enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SSJDatePeriod *period = obj;
        NSInteger firstDayIndex = [period.startDate weekday] - 1;
        NSInteger itemCount = firstDayIndex + [period daysCount];
        NSInteger rowCount = itemCount / 7;
        if (itemCount % 7) {
            rowCount ++;
        }
        
        NSMutableArray *monthItems = [[NSMutableArray alloc] initWithCapacity:rowCount];
        for (int rowIndex = 0; rowIndex < rowCount; rowIndex ++) {
            
            NSMutableArray *dateItems = [[NSMutableArray alloc] initWithCapacity:7];
            for (int dateIndex = 0; dateIndex < 7; dateIndex ++) {
                int day = (int)(rowIndex * 7 + dateIndex - firstDayIndex + 1);
                
                SSJMagicExportCalendarViewCellItem *item = [[SSJMagicExportCalendarViewCellItem alloc] init];
                item.date = [NSDate dateWithYear:period.startDate.year month:period.startDate.month day:day];
                item.selected = [_selectedDates containsObject:item.date];
                if (item.selected && [_delegate respondsToSelector:@selector(calendarView:descriptionForSelectedDate:)]) {
                    item.desc = [_delegate calendarView:self descriptionForSelectedDate:item.date];
                }
                item.showMarker = [_delegate calendarView:self shouldShowMarkerForDate:item.date];
                item.showContent = ([item.date compare:period.startDate] != NSOrderedAscending && [item.date compare:period.endDate] != NSOrderedDescending);
                item.canSelect = item.showContent;
                if (item.showContent) {
                    if (_delegate && [_delegate respondsToSelector:@selector(calendarView:canSelectDate:)]) {
                        item.canSelect = [_delegate calendarView:self canSelectDate:item.date];
                        item.dateColor = item.canSelect ? [UIColor ssj_colorWithHex:@"393939"] : [UIColor ssj_colorWithHex:@"929292"];
                    }
                }
                
                [dateItems addObject:item];
                
                SSJMagicExportCalendarIndexPath *indexPath = [SSJMagicExportCalendarIndexPath indexPathForSection:section row:rowIndex index:dateIndex];
                [_dateIndexMapping setObject:indexPath forKey:[item.date formattedDateWithFormat:@"yyyy-MM-dd"]];
            }
            
            [monthItems addObject:dateItems];
        }
        
        [_items addObject:monthItems];
        section ++;
    }];
    
    [self.tableView reloadData];
}

- (void)deselectDates:(NSArray<NSDate *> *)dates {
    NSMutableArray *tmpDates = [_selectedDates mutableCopy];
    [tmpDates removeObjectsInArray:dates];
    _selectedDates = [tmpDates copy];
    
    for (NSDate *date in dates) {
        SSJMagicExportCalendarIndexPath *indexPath = [_dateIndexMapping objectForKey:[date formattedDateWithFormat:@"yyyy-MM-dd"]];
        SSJMagicExportCalendarViewCellItem *item = [_items ssj_objectAtCalendarIndexPath:indexPath];
        item.selected = NO;
        item.desc = nil;
    }
    [self.tableView reloadData];
}

- (void)scrollToDate:(NSDate *)date {
    if (date) {
        SSJMagicExportCalendarIndexPath *indexPath = [_dateIndexMapping objectForKey:[date formattedDateWithFormat:@"yyyy-MM-dd"]];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

#pragma mark - Private
- (BOOL)checkStartDate:(NSDate *)startDate {
    SSJDatePeriod *startPeriod = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeMonth date:startDate];
    if (_endDate) {
        SSJDatePeriod *endPeriod = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeMonth date:_endDate];
        if ([startPeriod compareWithPeriod:endPeriod] == SSJDatePeriodComparisonResultDescending) {
            NSLog(@">>> 错误，启始月大于终止月");
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)checkEndDate:(NSDate *)endDate {
    SSJDatePeriod *endPeriod = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeMonth date:endDate];
    if (_startDate) {
        SSJDatePeriod *startPeriod = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeMonth date:_startDate];
        if ([startPeriod compareWithPeriod:endPeriod] == SSJDatePeriodComparisonResultDescending) {
            NSLog(@">>> 错误，启始月大于终止月");
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Getter
- (SSJMagicExportCalendarWeekView *)weekView {
    if (!_weekView) {
        _weekView = [[SSJMagicExportCalendarWeekView alloc] initWithFrame:CGRectMake(0, 0, self.width, 40)];
    }
    return _weekView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, self.width, self.height - 40) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 60;
        _tableView.sectionHeaderHeight = 45;
        _tableView.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
        _tableView.separatorColor = SSJ_DEFAULT_SEPARATOR_COLOR;
        [_tableView ssj_clearExtendSeparator];
        [_tableView registerClass:[SSJMagicExportCalendarViewCell class] forCellReuseIdentifier:kCalendarCellId];
        [_tableView registerClass:[SSJMagicExportCalendarHeaderView class] forHeaderFooterViewReuseIdentifier:kCalendarHeaderId];
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    return _tableView;
}

@end
