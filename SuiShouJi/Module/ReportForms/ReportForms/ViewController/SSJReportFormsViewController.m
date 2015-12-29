//
//  SSJReportFormsViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/11.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJReportFormsViewController.h"
#import "SCYUnlimitedScrollView.h"
#import "SSJReportFormsPercentCircle.h"
#import "SSJReportFormsSwitchYearControl.h"
#import "SCYPageControl.h"
#import "SSJReportFormsIncomeAndPayCell.h"

#import "SSJReportFormsUtil.h"

static const CGFloat kHeaderFirstPartHeight = 49;
static const CGFloat kHeaderSecondPartHeight = 40;
static const CGFloat kHeaderThirdPartHeight = 79;

static NSString *const kIncomeAndPayCellID = @"incomeAndPayCellID";

static NSString *const kSegmentTitlePay = @"支出";
static NSString *const kSegmentTitleIncome = @"收入";
static NSString *const kSegmentTitleSurplus = @"盈余";

@interface SSJReportFormsViewController () <UITableViewDataSource, UITableViewDelegate, SCYUnlimitedScrollViewDataSource, SCYUnlimitedScrollViewDelegate, SSJReportFormsPercentCircleDataSource>

@property (nonatomic, strong) UISegmentedControl *segmentControl;

@property (nonatomic, strong) SSJReportFormsSwitchYearControl *switchYearControl;

@property (nonatomic, strong) SCYUnlimitedScrollView *scrollView;

@property (nonatomic, strong) SSJReportFormsPercentCircle *monthCircleView;

@property (nonatomic, strong) SSJReportFormsPercentCircle *yearCircleView;

@property (nonatomic, strong) SCYPageControl *pageControl;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *datas;

@end

@implementation SSJReportFormsViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[SSJReportFormsIncomeAndPayCell class] forCellReuseIdentifier:kIncomeAndPayCellID];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.datas = [SSJReportFormsUtil queryForIncomeOrPayType:[self currentType] inYear:@"2015"];
    
}

- (void)viewDidLayoutSubviews {
    self.tableView.frame = self.view.bounds;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJReportFormsIncomeAndPayCell *incomeAndPayCell = [tableView dequeueReusableCellWithIdentifier:kIncomeAndPayCellID forIndexPath:indexPath];
    return incomeAndPayCell;
}

#pragma mark - UITableViewDelegate

#pragma mark - SCYUnlimitedScrollViewDataSource
- (NSUInteger)numberOfPagesInScrollView:(SCYUnlimitedScrollView *)scrollView {
    return 2;
}

- (UIView *)scrollView:(SCYUnlimitedScrollView *)scrollView subViewAtPageIndex:(NSUInteger)index {
    if (index == 0) {
        return self.monthCircleView;
    } else if (index == 1) {
        return self.yearCircleView;
    } else {
        return nil;
    }
}

#pragma mark - SCYUnlimitedScrollViewDelegate
- (void)scrollView:(SCYUnlimitedScrollView *)scrollView didScrollAtPageIndex:(NSUInteger)index {
    
}

#pragma mark - SSJReportFormsPercentCircleDataSource
- (NSUInteger)numberOfComponentsInPercentCircle:(SSJReportFormsPercentCircle *)circle {
    return self.datas.count;
}

- (SSJReportFormsPercentCircleItem *)percentCircle:(SSJReportFormsPercentCircle *)circle itemForComponentAtIndex:(NSUInteger)index {
    
    if (self.datas.count > index) {
        SSJReportFormsItem *model = self.datas[index];
        
        SSJReportFormsPercentCircleItem *circleItem = [[SSJReportFormsPercentCircleItem alloc] init];
        circleItem.scale = model.scale;
        circleItem.image = [UIImage imageNamed:model.imageName];
        circleItem.color = [UIColor ssj_colorWithHex:model.colorValue];
        return circleItem;
    }
    
    return nil;
}

#pragma mark - Event
- (void)segmentControlValueDidChange {
    self.datas = [SSJReportFormsUtil queryForIncomeOrPayType:[self currentType] inYear:@"2015"];
    
    [self.tableView reloadData];
    if (self.scrollView.currentIndex == 0) {
        [self.monthCircleView reloadData];
    } else if (self.scrollView.currentIndex == 1) {
        [self.yearCircleView reloadData];
    }
}

#pragma mark - Private
- (SSJReportFormsIncomeOrPayType)currentType {
    NSString *selectedTitle = [self.segmentControl titleForSegmentAtIndex:self.segmentControl.selectedSegmentIndex];
    
    if ([selectedTitle isEqualToString:kSegmentTitlePay]) {
        return SSJReportFormsIncomeOrPayTypePay;
    } else if ([selectedTitle isEqualToString:kSegmentTitleIncome]) {
        return SSJReportFormsIncomeOrPayTypeIncome;
    } else if ([selectedTitle isEqualToString:kSegmentTitleSurplus]) {
        return SSJReportFormsIncomeOrPayTypeSurplus;
    } else {
        return SSJReportFormsIncomeOrPayTypeUnknown;
    }
}

#pragma mark - Getter
- (UISegmentedControl *)segmentControl {
    if (!_segmentControl) {
        _segmentControl = [[UISegmentedControl alloc] initWithItems:@[kSegmentTitlePay,kSegmentTitleIncome,kSegmentTitleSurplus]];
        _segmentControl.center = CGPointMake(self.headerView.width * 0.5, kHeaderFirstPartHeight * 0.5);
        _segmentControl.tintColor = [UIColor ssj_colorWithHex:@"#47cfbe"];
        [_segmentControl addTarget:self action:@selector(segmentControlValueDidChange) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentControl;
}

- (SSJReportFormsSwitchYearControl *)switchYearControl {
    if (!_switchYearControl) {
        _switchYearControl = [[SSJReportFormsSwitchYearControl alloc] initWithFrame:CGRectMake(0, kHeaderFirstPartHeight, self.headerView.width, kHeaderSecondPartHeight)];
        _switchYearControl.title = @"2015";
        _switchYearControl.preAction = ^(SSJReportFormsSwitchYearControl *switchYearControl) {
            
        };
        _switchYearControl.nextAction = ^(SSJReportFormsSwitchYearControl *switchYearControl) {
            
        };
    }
    return _switchYearControl;
}

- (SCYUnlimitedScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[SCYUnlimitedScrollView alloc] initWithFrame:CGRectMake(0, kHeaderFirstPartHeight + kHeaderSecondPartHeight, self.headerView.width, kHeaderThirdPartHeight)];
        _scrollView.dataSource = self;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (SSJReportFormsPercentCircle *)monthCircleView {
    if (!_monthCircleView) {
        _monthCircleView = [[SSJReportFormsPercentCircle alloc] initWithFrame:CGRectZero];
        _monthCircleView.circleInsets = UIEdgeInsetsMake(15, 80, 60, 80);
        _monthCircleView.circleWidth = 78;
        _monthCircleView.dataSource = self;
    }
    return _monthCircleView;
}

- (SSJReportFormsPercentCircle *)yearCircleView {
    if (!_yearCircleView) {
        _yearCircleView = [[SSJReportFormsPercentCircle alloc] initWithFrame:CGRectZero];
        _yearCircleView.circleInsets = UIEdgeInsetsMake(15, 80, 60, 80);
        _yearCircleView.circleWidth = 78;
        _monthCircleView.dataSource = self;
    }
    return _yearCircleView;
}

- (SCYPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[SCYPageControl alloc] init];
        _pageControl.centerX = self.headerView.width * 0.5;
        _pageControl.bottom = 25;
        _pageControl.numberOfPages = 2;
        _pageControl.spaceBetweenPages = 10;
    }
    return _pageControl;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kHeaderFirstPartHeight + kHeaderSecondPartHeight + kHeaderThirdPartHeight)];
        _headerView.backgroundColor = [UIColor whiteColor];
        [_headerView addSubview:self.segmentControl];
        [_headerView addSubview:self.switchYearControl];
        [_headerView addSubview:self.scrollView];
    }
    return _headerView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableHeaderView = self.headerView;
        _tableView.rowHeight = 55;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

@end
