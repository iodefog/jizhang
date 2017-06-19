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
#import "SSJMagicExportCalendarDateView.h"
#import "SSJMagicExportCalendarIndexPath.h"
#import "SSJDatePeriod.h"

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJMagicExportCalendarWeekView
#pragma mark -

@interface SSJMagicExportCalendarWeekView : UIView

@property (nonatomic, strong) NSMutableArray *labelArr;

@end

@interface SSJMagicExportCalendarWeekView ()

@end

@implementation SSJMagicExportCalendarWeekView

- (void)dealloc {
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        NSArray *weekArr = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
        _labelArr = [[NSMutableArray alloc] initWithCapacity:weekArr.count];
        for (NSString *week in weekArr) {
            UILabel *lab = [[UILabel alloc] init];
            lab.backgroundColor = [UIColor clearColor];
            lab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
            lab.text = week;
            lab.textAlignment = NSTextAlignmentCenter;
            lab.textColor = [UIColor blackColor];
            [_labelArr addObject:lab];
            [self addSubview:lab];
        }
    }
    
    return self;
}

- (void)layoutSubviews {
    CGFloat width = self.width / _labelArr.count;
    for (int i = 0; i < _labelArr.count; i ++) {
        UILabel *lab = _labelArr[i];
        lab.frame = CGRectMake(width * i, 0, width, self.height);
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJMagicExportCalendarView
#pragma mark -

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

@property (nonatomic, strong) NSMutableSet<NSDate *> *innerSelectedDates;

@end

@implementation SSJMagicExportCalendarView

- (void)dealloc {
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _items = [[NSMutableArray alloc] init];
        _dateIndexMapping = [[NSMutableDictionary alloc] init];
        _innerSelectedDates = [NSMutableSet set];
        
        [self addSubview:self.weekView];
        [self addSubview:self.tableView];
        
        self.backgroundColor = [UIColor clearColor];
        [self updateAppearance];
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
    __weak typeof(self) weakSelf = self;
    SSJMagicExportCalendarViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCalendarCellId forIndexPath:indexPath];
    cell.dateItems = [_items ssj_objectAtIndexPath:indexPath];
    cell.clickBlock = ^(SSJMagicExportCalendarViewCell *cell, SSJMagicExportCalendarDateView *dateView) {
        if (!weakSelf.delegate) {
            return;
        }
        
        BOOL shouldSelect = YES;
        if ([weakSelf.delegate respondsToSelector:@selector(calendarView:shouldSelectDate:)]) {
            shouldSelect = [weakSelf.delegate calendarView:weakSelf shouldSelectDate:dateView.item.date];
        }
        
        if (shouldSelect) {
            if ([weakSelf.delegate respondsToSelector:@selector(calendarView:willSelectDate:)]) {
                [weakSelf.delegate calendarView:weakSelf willSelectDate:dateView.item.date];
            }
            [weakSelf selectDates:@[dateView.item.date]];
            if ([weakSelf.delegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
                [weakSelf.delegate calendarView:weakSelf didSelectDate:dateView.item.date];
            }
            SSJMagicExportCalendarIndexPath *indexPath = [weakSelf.dateIndexMapping objectForKey:dateView.item.date];
            if (indexPath) {
                SSJMagicExportCalendarDateViewItem *item = [weakSelf.items ssj_objectAtCalendarIndexPath:indexPath];
                [weakSelf updateColorsOfItem:item selected:YES];
            }
        }
    };
    return cell;
}

#pragma mark - UITableViewDelegate
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SSJMagicExportCalendarHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kCalendarHeaderId];
    SSJMagicExportCalendarIndexPath *indexPath = [SSJMagicExportCalendarIndexPath indexPathForSection:section row:1 index:0];
    SSJMagicExportCalendarDateViewItem *item = [_items ssj_objectAtCalendarIndexPath:indexPath];
    headerView.textLabel.text = [item.date formattedDateWithFormat:@"yyyy年M月"];
    return headerView;
}

#pragma mark - Public
- (void)setDateColor:(UIColor *)dateColor {
    if (!CGColorEqualToColor(dateColor.CGColor, _dateColor.CGColor)) {
        _dateColor = dateColor;
        if (!_delegate || ![_delegate respondsToSelector:@selector(calendarView:titleColorForDate:selected:)]) {
            [self enumerateItemsWithBlock:^(SSJMagicExportCalendarDateViewItem *item) {
                item.dateColor = dateColor;
            }];
        }
    }
}

- (void)setMarkerColor:(UIColor *)markerColor {
    if (!CGColorEqualToColor(markerColor.CGColor, _markerColor.CGColor)) {
        _markerColor = markerColor;
        if (!_delegate || ![_delegate respondsToSelector:@selector(calendarView:titleColorForDate:selected:)]) {
            [self enumerateItemsWithBlock:^(SSJMagicExportCalendarDateViewItem *item) {
                item.markerColor = markerColor;
            }];
        }
    }
}

- (void)setDescriptionColor:(UIColor *)descriptionColor {
    if (!CGColorEqualToColor(descriptionColor.CGColor, _descriptionColor.CGColor)) {
        _descriptionColor = descriptionColor;
        if (!_delegate || ![_delegate respondsToSelector:@selector(calendarView:titleColorForDate:selected:)]) {
            [self enumerateItemsWithBlock:^(SSJMagicExportCalendarDateViewItem *item) {
                item.descColor = descriptionColor;
            }];
        }
    }
}

- (void)setFillColor:(UIColor *)fillColor {
    if (!CGColorEqualToColor(fillColor.CGColor, _fillColor.CGColor)) {
        _fillColor = fillColor;
        if (!_delegate || ![_delegate respondsToSelector:@selector(calendarView:titleColorForDate:selected:)]) {
            [self enumerateItemsWithBlock:^(SSJMagicExportCalendarDateViewItem *item) {
                item.fillColor = fillColor;
            }];
        }
    }
}

- (void)setSelectedDates:(NSArray<NSDate *> *)selectedDates {
    _selectedDates = selectedDates;
    [_innerSelectedDates removeAllObjects];
    if (selectedDates) {
        [_innerSelectedDates addObjectsFromArray:selectedDates];
    }
    
    [self enumerateItemsWithBlock:^(SSJMagicExportCalendarDateViewItem *item) {
        [self updateColorsOfItem:item selected:[_innerSelectedDates containsObject:item.date]];
    }];
}

- (void)reloadData {
    if (!_dataSource || ![_dataSource respondsToSelector:@selector(periodForCalendarView:)]) {
        return;
    }
    
    [_items removeAllObjects];
    [_dateIndexMapping removeAllObjects];
    [_innerSelectedDates removeAllObjects];
    
    NSDictionary *periodInfo = [_dataSource periodForCalendarView:self];
    NSDate *tmpStartDate = periodInfo[SSJMagicExportCalendarViewBeginDateKey];
    NSDate *tmpEndDate = periodInfo[SSJMagicExportCalendarViewEndDateKey];
    
    // periodsBetweenDate方法返回的周期是从tmpStartDate之后开始的，所以要加上tmpStartDate的周期
    SSJDatePeriod *firstPeriod = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeMonth date:tmpStartDate];
    SSJDatePeriod *lastPeriod = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeMonth date:tmpEndDate];
    NSArray *otherPeriods = [lastPeriod periodsFromPeriod:firstPeriod];
    
    NSMutableArray *periods = [[NSMutableArray alloc] initWithCapacity:(otherPeriods.count + 1)];
    [periods addObject:firstPeriod];
    [periods addObjectsFromArray:otherPeriods];
    
    _startDate = firstPeriod.startDate;
    _endDate = ((SSJDatePeriod *)[periods lastObject]).endDate;
    
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
                NSDate *date = [NSDate dateWithYear:period.startDate.year month:period.startDate.month day:day];
                
                SSJMagicExportCalendarDateViewItem *item = [[SSJMagicExportCalendarDateViewItem alloc] init];
                
                item.hidden = ([date compare:period.startDate] == NSOrderedAscending || [date compare:period.endDate] == NSOrderedDescending);
                
                if (!item.hidden) {
                    item.date = date;
                    
                    if ([_dataSource respondsToSelector:@selector(calendarView:shouldShowMarkerForDate:)]) {
                        item.showMarker = [_dataSource calendarView:self shouldShowMarkerForDate:date];
                    }
                    [self updateColorsOfItem:item selected:NO];
                    
                    SSJMagicExportCalendarIndexPath *indexPath = [SSJMagicExportCalendarIndexPath indexPathForSection:section row:rowIndex index:dateIndex];
                    [_dateIndexMapping setObject:indexPath forKey:item.date];
                }
                
                [dateItems addObject:item];
            }
            
            [monthItems addObject:dateItems];
        }
        
        [_items addObject:monthItems];
        section ++;
    }];
    
    [self.tableView reloadData];
}

- (void)reloadDates:(NSArray<NSDate *> *)dates {
    if (!_dataSource) {
        return;
    }
    
    for (NSDate *date in dates) {
        @autoreleasepool {
            NSDate *tmpDate = [NSDate dateWithYear:date.year month:date.month day:date.day];
            SSJMagicExportCalendarIndexPath *indexPath = [_dateIndexMapping objectForKey:tmpDate];
            if (!indexPath) {
                continue;
            }
            
            SSJMagicExportCalendarDateViewItem *item = [_items ssj_objectAtCalendarIndexPath:indexPath];
            if (!item) {
                continue;
            }
            
            if ([_dataSource respondsToSelector:@selector(calendarView:shouldShowMarkerForDate:)]) {
                item.showMarker = [_dataSource calendarView:self shouldShowMarkerForDate:tmpDate];
            }
            
            [self updateColorsOfItem:item selected:[_innerSelectedDates containsObject:item.date]];
        }
    }
}

- (void)selectDates:(NSArray<NSDate *> *)dates {
    NSMutableArray *tmpDatesArr = [_selectedDates mutableCopy];
    if (!tmpDatesArr) {
        tmpDatesArr = [[NSMutableArray alloc] init];
    }
    
    for (NSDate *date in dates) {
        @autoreleasepool {
            NSDate *tmpDate = [NSDate dateWithYear:date.year month:date.month day:date.day];
            if ([tmpDate compare:_startDate] == NSOrderedAscending
                || [tmpDate compare:_endDate] == NSOrderedDescending) {
                SSJPRINT(@"警告：超出时间范围");
                continue;
            }
            
            if (![tmpDatesArr containsObject:tmpDate]) {
                [tmpDatesArr addObject:tmpDate];
                [_innerSelectedDates addObject:tmpDate];
            }
        }
    }
    _selectedDates = [tmpDatesArr copy];
}

- (void)deselectDates:(NSArray<NSDate *> *)dates {
    NSMutableArray *tmpDates = [_selectedDates mutableCopy];
    [tmpDates removeObjectsInArray:dates];
    _selectedDates = [tmpDates copy];
    
    for (NSDate *date in dates) {
        [_innerSelectedDates removeObject:date];
    }
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated {
    if (date) {
        NSDate *tmpDate = [NSDate dateWithYear:date.year month:date.month day:date.day];
        SSJMagicExportCalendarIndexPath *indexPath = [_dateIndexMapping objectForKey:tmpDate];
        if (indexPath) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionMiddle animated:animated];
        }
    }
}

#pragma mark - Private
- (void)updateColorsOfItem:(SSJMagicExportCalendarDateViewItem *)item selected:(BOOL)selected {
    if (item.hidden) {
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(calendarView:titleColorForDate:selected:)]) {
        item.dateColor = [_delegate calendarView:self titleColorForDate:item.date selected:selected];
    } else {
        item.dateColor = _dateColor;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(calendarView:markerColorForDate:selected:)]) {
        item.markerColor = [_delegate calendarView:self markerColorForDate:item.date selected:selected];
    } else {
        item.markerColor = _markerColor;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(calendarView:descriptionColorForDate:selected:)]) {
        item.descColor = [_delegate calendarView:self descriptionColorForDate:item.date selected:selected];
    } else {
        item.descColor = _descriptionColor;
    }
    
    if (selected) {
        if (_delegate && [_delegate respondsToSelector:@selector(calendarView:fillColorForSelectedDate:)]) {
            item.fillColor = [_delegate calendarView:self fillColorForSelectedDate:item.date];
        } else {
            item.fillColor = _fillColor;
        }
        
        if ([_delegate respondsToSelector:@selector(calendarView:descriptionForSelectedDate:)]) {
            item.desc = [_delegate calendarView:self descriptionForSelectedDate:item.date];
        } else {
            item.desc = nil;
        }
    } else {
        item.fillColor = nil;
        item.desc = nil;
    }
}

- (void)enumerateItemsWithBlock:(void(^)(SSJMagicExportCalendarDateViewItem *item))block {
    for (NSArray *monthList in _items) {
        for (NSArray *weekList in monthList) {
            for (SSJMagicExportCalendarDateViewItem *dateItem in weekList) {
                block(dateItem);
            }
        }
    }
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
        [_tableView ssj_clearExtendSeparator];
        [_tableView registerClass:[SSJMagicExportCalendarViewCell class] forCellReuseIdentifier:kCalendarCellId];
        [_tableView registerClass:[SSJMagicExportCalendarHeaderView class] forHeaderFooterViewReuseIdentifier:kCalendarHeaderId];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    return _tableView;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJMagicExportCalendarView
#pragma mark -

@implementation SSJMagicExportCalendarView (SSJTheme)

- (void)updateAppearance {
    self.weekView.backgroundColor = SSJ_MAIN_BACKGROUND_COLOR;
    for (UILabel *lab in self.weekView.labelArr) {
        lab.textColor = ([lab.text isEqualToString:@"日"] || [lab.text isEqualToString:@"六"]) ? SSJ_MARCATO_COLOR : SSJ_MAIN_COLOR;
    }
    
    _tableView.separatorColor = SSJ_CELL_SEPARATOR_COLOR;
    if (![[SSJThemeSetting currentThemeModel].ID isEqualToString:SSJDefaultThemeID]) {
        _tableView.backgroundColor = [UIColor clearColor];
    } else {
        _tableView.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
    }
}

@end
