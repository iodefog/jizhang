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
#import "SSJMagicExportCalendarViewCellItem.h"
#import "SSJDatePeriod.h"

NSString *const SSJMagicExportCalendarViewBeginDateKey = @"SSJMagicExportCalendarViewBeginDateKey";
NSString *const SSJMagicExportCalendarViewEndDateKey = @"SSJMagicExportCalendarViewEndDateKey";

static NSString *const kCalendarCellId = @"kCalendarCellId";
static NSString *const kCalendarHeaderId = @"kCalendarHeaderId";

@interface SSJMagicExportCalendarView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) SSJMagicExportCalendarWeekView *weekView;

//@property (nonatomic, strong) UICollectionView *collectionView;
//
//@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation SSJMagicExportCalendarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _items = [[NSMutableArray alloc] init];
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
    cell.dateItems = [_items ssj_objectAtIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SSJMagicExportCalendarHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kCalendarHeaderId];
    headerView.textLabel.text = [[_startDate dateByAddingMonths:section] formattedDateWithFormat:@"yyyy年M月"];
    return headerView;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!_delegate) {
        return;
    }
    
    SSJMagicExportCalendarViewCellItem *item = [_items ssj_objectAtIndexPath:indexPath];
    if (item.selected) {
        if ([_delegate respondsToSelector:@selector(calendarView:descriptionForSelectedDate:)]) {
            item.desc = [_delegate calendarView:self descriptionForSelectedDate:item.date];
            [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
    } else {
        item.desc = nil;
    }
}

#pragma mark - Public
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
    
    NSDate *now = [NSDate date];
    // 应为periodsBetweenDate方法返回的周期是从_startDate之后开始的，所以要加上_startDate的周期
    NSMutableArray *periods = [[SSJDatePeriod periodsBetweenDate:_startDate andAnotherDate:_endDate periodType:SSJDatePeriodTypeMonth] mutableCopy];
    if (!periods) {
        periods = [[NSMutableArray alloc] init];
    }
    [periods addObject:[SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeMonth date:_startDate]];
    
    for (SSJDatePeriod *period in periods) {
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
                int day = rowIndex * 7 + dateIndex - firstDayIndex + 1;
                
                SSJMagicExportCalendarViewCellItem *item = [[SSJMagicExportCalendarViewCellItem alloc] init];
                item.date = [NSDate dateWithYear:period.startDate.year month:period.startDate.month day:day];
                item.dateColor = [item.date compare:now] == NSOrderedDescending ? [UIColor ssj_colorWithHex:@"929292"] : [UIColor ssj_colorWithHex:@"393939"];
                item.canSelect = ([item.date compare:now] != NSOrderedDescending);
                for (NSDate *selectedDate in _selectedDates) {
                    item.selected = [item.date compare:selectedDate] == NSOrderedSame;
                }
                item.showMarker = [_delegate calendarView:self shouldShowMarkerForDate:item.date];
                item.showContent = ([item.date compare:period.startDate] != NSOrderedAscending && [item.date compare:period.endDate] != NSOrderedDescending);
                [dateItems addObject:item];
            }
            
            [monthItems addObject:dateItems];
        }
        
        [_items addObject:monthItems];
    }
    
//    [self.collectionView reloadData];
    [self.tableView reloadData];
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
        [_tableView registerClass:[SSJMagicExportCalendarViewCell class] forCellReuseIdentifier:kCalendarCellId];
        [_tableView registerClass:[SSJMagicExportCalendarHeaderView class] forHeaderFooterViewReuseIdentifier:kCalendarHeaderId];
    }
    return _tableView;
}

//- (UICollectionView *)collectionView {
//    if (_collectionView == nil) {
//        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.layout];
//        _collectionView.backgroundColor = [UIColor whiteColor];
//        _collectionView.dataSource = self;
//        _collectionView.delegate = self;
//        _collectionView.allowsMultipleSelection = NO;
//        [_collectionView registerClass:[SSJMagicExportCalendarViewCell class] forCellWithReuseIdentifier:kCalendarCellId];
//        [_collectionView registerClass:[SSJMagicExportCalendarHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCalendarHeaderId];
//    }
//    return _collectionView;
//}
//
//- (UICollectionViewFlowLayout *)layout {
//    if (!_layout) {
//        _layout = [[UICollectionViewFlowLayout alloc] init];
//        _layout.minimumLineSpacing = 0;
//        _layout.minimumInteritemSpacing = 0;
//        _layout.itemSize = CGSizeMake(self.width / 7, 60);
//        _layout.headerReferenceSize = CGSizeMake(self.width, 45);
//        _layout.sectionHeadersPinToVisibleBounds = YES;
//    }
//    return _layout;
//}

@end
