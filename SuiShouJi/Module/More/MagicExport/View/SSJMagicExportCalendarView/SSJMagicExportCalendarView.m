//
//  SSJMagicExportCalendarView.m
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportCalendarView.h"
#import "SSJMagicExportCalendarViewCell.h"
#import "SSJDatePeriod.h"

static NSString *const kCalendarCellId = @"kCalendarCellId";

@interface SSJMagicExportCalendarView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) NSCalendar *calendar;

@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, strong) NSMutableArray *items;


@end

@implementation SSJMagicExportCalendarView

- (instancetype)initWithFrame:(CGRect)frame startDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    if (self = [super initWithFrame:frame]) {
        if ([self checkStartDate:startDate]) {
            _startDate = startDate;
        }
        if ([self checkEndDate:endDate]) {
            _endDate = endDate;
        }
        
        if (_startDate && _endDate) {
            _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            
            [self orginaseItems];
            [self addSubview:self.collectionView];
        }
    }
    return self;
}

- (void)layoutSubviews {
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _items.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[_items ssj_safeObjectAtIndex:section] count];
}

//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    SSJMagicExportCalendarViewCell *cell = [collectionView ]
//}
//
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    
//}

#pragma mark - Private
- (BOOL)checkStartDate:(NSDate *)startDate {
    SSJDatePeriod *startPeriod = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeMonth date:startDate];
//    SSJDatePeriod *currentPeriod = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeMonth date:[NSDate date]];
//    if ([startPeriod compareWithPeriod:currentPeriod] == SSJDatePeriodComparisonResultDescending) {
//        NSLog(@">>> 错误，启始月大于当前月");
//        return NO;
//    }
    
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
//    SSJDatePeriod *currentPeriod = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeMonth date:[NSDate date]];
//    if ([endPeriod compareWithPeriod:currentPeriod] == SSJDatePeriodComparisonResultAscending) {
//        NSLog(@">>> 错误，启始月大于当前月");
//        return NO;
//    }
    
    if (_startDate) {
        SSJDatePeriod *startPeriod = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeMonth date:_startDate];
        if ([startPeriod compareWithPeriod:endPeriod] == SSJDatePeriodComparisonResultDescending) {
            NSLog(@">>> 错误，启始月大于终止月");
            return NO;
        }
    }
    
    return YES;
}

- (void)orginaseItems {
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
    }
    
    NSDate *now = [NSDate date];
    NSArray *periods = [SSJDatePeriod periodsBetweenDate:_startDate andAnotherDate:_endDate periodType:SSJDatePeriodTypeMonth];
    for (SSJDatePeriod *period in periods) {
        NSInteger firstDayIndex = [period.startDate weekday] - 1;
        NSInteger itemCount = firstDayIndex + [period daysCount];
        NSInteger rowCount = itemCount / 7;
        if (itemCount % 7) {
            rowCount ++;
        }
        NSInteger fullCount = rowCount * 7;
        NSMutableArray *monthItems = [[NSMutableArray alloc] initWithCapacity:fullCount];
        
        for (int i = 0; i < fullCount; i ++) {
            SSJMagicExportCalendarViewCellItem *item = [[SSJMagicExportCalendarViewCellItem alloc] init];
            if (i >= firstDayIndex && i < itemCount) {
                item.date = [NSDate dateWithYear:period.startDate.year month:period.startDate.month day:(i - firstDayIndex + 1)];
                item.canSelect = ([item.date compare:now] != NSOrderedDescending);
                item.selected = ([item.date compare:_selectedBeginDate] == NSOrderedSame || [item.date compare:_selectedEndDate] == NSOrderedSame);
                item.showContent = YES;
            } else {
                item.showContent = NO;
                item.canSelect = NO;
            }
            [monthItems addObject:item];
        }
        [_items addObject:monthItems];
    }
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.allowsMultipleSelection = NO;
        [_collectionView registerClass:[SSJMagicExportCalendarViewCell class] forCellWithReuseIdentifier:kCalendarCellId];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)layout {
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.minimumLineSpacing = 0;
        _layout.minimumInteritemSpacing = 0;
        _layout.itemSize = CGSizeMake(self.width / 7, 60);
        _layout.headerReferenceSize = CGSizeMake(self.width, 45);
    }
    return _layout;
}

@end
