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
#import "SSJSegmentedControl.h"
#import "SSJReportFormsSurplusView.h"
#import "SSJReportFormsIncomeAndPayCell.h"

#import "SSJBillingChargeViewController.h"
#import "SSJReportFormsUtil.h"

static const CGFloat kHeaderFirstPartHeight = 49;
static const CGFloat kHeaderSecondPartHeight = 40;
static const CGFloat kHeaderThirdPartHeight = 247;

static NSString *const kIncomeAndPayCellID = @"incomeAndPayCellID";

static NSString *const kSegmentTitlePay = @"支出";
static NSString *const kSegmentTitleIncome = @"收入";
static NSString *const kSegmentTitleSurplus = @"盈余";

@interface SSJReportFormsViewController () <UITableViewDataSource, UITableViewDelegate, SCYUnlimitedScrollViewDataSource, SCYUnlimitedScrollViewDelegate, SSJReportFormsPercentCircleDataSource>

//  收入、支出、盈余切换控件
@property (nonatomic, strong) SSJSegmentedControl *segmentControl;

//  切换年份、月份控件
@property (nonatomic, strong) SSJReportFormsSwitchYearControl *switchYearControl;

//  装载年份、月份收支图表的滚动视图
@property (nonatomic, strong) SCYUnlimitedScrollView *scrollView;

//  月份收支图表
@property (nonatomic, strong) SSJReportFormsPercentCircle *monthCircleView;

//  年份收支图表
@property (nonatomic, strong) SSJReportFormsPercentCircle *yearCircleView;

//
@property (nonatomic, strong) SCYPageControl *pageControl;

//  盈余金额视图
@property (nonatomic, strong) SSJReportFormsSurplusView *surplusView;

//  装载segmentControl、switchYearControl、scrollView的头部视图
@property (nonatomic, strong) UIView *headerView;

//
@property (nonatomic, strong) UITableView *tableView;

//  数据源
@property (nonatomic, strong) NSArray *datas;

//  圆环数据源
@property (nonatomic, strong) NSMutableArray *circleItems;

//  计算年份、月份的工具
@property (nonatomic, strong) SSJReportFormsCalendarUtil *calendarUtil;

@end

@implementation SSJReportFormsViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.circleItems = [NSMutableArray array];
        self.calendarUtil = [[SSJReportFormsCalendarUtil alloc] init];
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[SSJReportFormsIncomeAndPayCell class] forCellReuseIdentifier:kIncomeAndPayCellID];
    [self updateSurplusViewTitle];
    [self updateSwithDateControlTitle];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self reloadDatas];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *selectedTitle = [self.segmentControl titleForSegmentAtIndex:self.segmentControl.selectedSegmentIndex];
    
    if ([selectedTitle isEqualToString:kSegmentTitlePay]
        || [selectedTitle isEqualToString:kSegmentTitleIncome]) {
        return self.datas.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJReportFormsIncomeAndPayCell *incomeAndPayCell = [tableView dequeueReusableCellWithIdentifier:kIncomeAndPayCellID forIndexPath:indexPath];
    [incomeAndPayCell setCellItem:[self.datas ssj_safeObjectAtIndex:indexPath.row]];
    return incomeAndPayCell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.datas.count > indexPath.row) {
        SSJReportFormsItem *item = self.datas[indexPath.row];
        SSJBillingChargeViewController *billingChargeVC = [[SSJBillingChargeViewController alloc] init];
        billingChargeVC.billTypeID = item.ID;
        billingChargeVC.year = self.calendarUtil.year;
        if (self.scrollView.currentIndex == 0) {
            billingChargeVC.month = self.calendarUtil.month;
        }
        [self.navigationController pushViewController:billingChargeVC animated:YES];
    }
}

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
    [self reloadDatas];
    [self updateSurplusViewTitle];
    [self updateSwithDateControlTitle];
}

#pragma mark - SSJReportFormsPercentCircleDataSource
- (NSUInteger)numberOfComponentsInPercentCircle:(SSJReportFormsPercentCircle *)circle {
    return self.circleItems.count;
}

- (SSJReportFormsPercentCircleItem *)percentCircle:(SSJReportFormsPercentCircle *)circle itemForComponentAtIndex:(NSUInteger)index {
    
    if (index < self.circleItems.count) {
        return self.circleItems[index];
    }
    return nil;
    
//    if (self.circleItems.count > index) {
//        
//        SSJReportFormsItem *model = self.circleItems[index];
//        
//        NSString *selectedTitle = [self.segmentControl titleForSegmentAtIndex:self.segmentControl.selectedSegmentIndex];
//        
//        if ([selectedTitle isEqualToString:kSegmentTitlePay]
//            || [selectedTitle isEqualToString:kSegmentTitleIncome]) {
//            //  收入、支出
//            SSJReportFormsPercentCircleItem *circleItem = [[SSJReportFormsPercentCircleItem alloc] init];
//            circleItem.scale = model.scale;
//            circleItem.image = [UIImage imageNamed:model.imageName];
//            circleItem.color = [UIColor ssj_colorWithHex:model.colorValue];
//            circleItem.identifier = model.incomeOrPayName;
//            return circleItem;
//            
//        } else if ([selectedTitle isEqualToString:kSegmentTitleSurplus]) {
//            //  盈余，盈余最多只有收入、支出两种类型
//            if (index <= 1) {
//                SSJReportFormsPercentCircleItem *circleItem = [[SSJReportFormsPercentCircleItem alloc] init];
//                circleItem.scale = model.scale;
//                circleItem.image = [UIImage imageNamed:model.imageName];
//                circleItem.color = [UIColor ssj_colorWithHex:model.colorValue];
//                circleItem.identifier = index == 0 ? @"支出" : @"收入";
//                return circleItem;
//            }
//        }
//    }
//    
//    return nil;
}

#pragma mark - Event
- (void)segmentControlValueDidChange {
    [self reloadDatas];
    [self updateSwithDateControlTitle];
    
    NSString *selectedTitle = [self.segmentControl titleForSegmentAtIndex:self.segmentControl.selectedSegmentIndex];
    if ([selectedTitle isEqualToString:kSegmentTitlePay]
        || [selectedTitle isEqualToString:kSegmentTitleIncome]) {
        self.tableView.tableFooterView = nil;
    } else if ([selectedTitle isEqualToString:kSegmentTitleSurplus]) {
        self.tableView.tableFooterView = self.surplusView;
    }
}

#pragma mark - Private
//  返回当前收支类型
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

//  更新切换年、月控件标题
- (void)updateSwithDateControlTitle {
    NSMutableString *title = [NSMutableString string];
    
    if (self.scrollView.currentIndex == 0) {
        [title appendFormat:@"%d月",(int)self.calendarUtil.month];
    } else if (self.scrollView.currentIndex == 1) {
        [title appendFormat:@"%d年",(int)self.calendarUtil.year];
    }
    
    NSString *selectedTitle = [self.segmentControl titleForSegmentAtIndex:self.segmentControl.selectedSegmentIndex];
    if ([selectedTitle isEqualToString:kSegmentTitlePay]) {
        [title appendString:@"支出明细图表"];
    } else if ([selectedTitle isEqualToString:kSegmentTitleIncome]) {
        [title appendString:@"收入明细图表"];
    } else if ([selectedTitle isEqualToString:kSegmentTitleSurplus]) {
        [title appendString:@"收支盈余明细图表"];
    }
    
    self.switchYearControl.title = title;
}

//  更新盈余标题
- (void)updateSurplusViewTitle {
    if (self.scrollView.currentIndex == 0) {
        [self.surplusView setTitle:[NSString stringWithFormat:@"%d月盈余",(int)self.calendarUtil.month]];
    } else if (self.scrollView.currentIndex == 1) {
        [self.surplusView setTitle:[NSString stringWithFormat:@"%d年盈余",(int)self.calendarUtil.year]];
    }
}

//  重新加载数据
- (void)reloadDatas {
    NSInteger month = 0;
    SSJReportFormsPercentCircle *currentCircleView = nil;
    
    if (self.scrollView.currentIndex == 0) {
        month = self.calendarUtil.month;
        currentCircleView = self.monthCircleView;
    } else if (self.scrollView.currentIndex == 1) {
        month = 0;
        currentCircleView = self.yearCircleView;
    } else {
        return;
    }
    
    [SSJReportFormsDatabaseUtil queryForIncomeOrPayType:[self currentType] inYear:self.calendarUtil.year month:month success:^(NSArray<SSJReportFormsItem *> *result) {
        
        self.datas = result;
        [self.tableView reloadData];
        
        //  将比例小于0.01的item过滤掉
        NSMutableArray *filterItems = [NSMutableArray array];
        double scaleAmount = 0;
        for (SSJReportFormsItem *item in result) {
            if (item.scale >= 0.01) {
                [filterItems addObject:item];
                scaleAmount += item.scale;
            }
        }
        
        //  将 SSJReportFormsItem 转换成 SSJReportFormsPercentCircleItem 存入数组
        [self.circleItems removeAllObjects];
        for (SSJReportFormsItem *item in filterItems) {
            NSString *selectedTitle = [self.segmentControl titleForSegmentAtIndex:self.segmentControl.selectedSegmentIndex];
            
            if ([selectedTitle isEqualToString:kSegmentTitlePay]
                || [selectedTitle isEqualToString:kSegmentTitleIncome]) {
                //  收入、支出
                SSJReportFormsPercentCircleItem *circleItem = [[SSJReportFormsPercentCircleItem alloc] init];
                circleItem.scale = item.scale / scaleAmount;
                circleItem.imageName = item.imageName;
                circleItem.colorValue = item.colorValue;
                circleItem.identifier = item.incomeOrPayName;
                [self.circleItems addObject:circleItem];
                
            } else if ([selectedTitle isEqualToString:kSegmentTitleSurplus]) {
                //  盈余，盈余最多只有收入、支出两种类型
                NSUInteger index = [result indexOfObject:item];
                if (index <= 1) {
                    SSJReportFormsPercentCircleItem *circleItem = [[SSJReportFormsPercentCircleItem alloc] init];
                    circleItem.scale = item.scale / scaleAmount;
                    circleItem.imageName = item.imageName;
                    circleItem.colorValue = item.colorValue;
                    circleItem.identifier = index == 0 ? @"支出" : @"收入";
                    [self.circleItems addObject:circleItem];
                }
            }
        }
        
        [currentCircleView reloadData];
        
        if (!self.datas.count) {
            self.tableView.hidden = YES;
//            [self.headerView ssj_setBorderStyle:SSJBorderStyleleNone];
            [self.view showWatermark:@"reportForm_empty" animated:YES Target:nil Action:nil];
        } else {
            self.tableView.hidden = NO;
//            [self.headerView ssj_setBorderStyle:SSJBorderStyleBottom];
            [self.view hideWatermark:YES];
        }
        
        NSString *selectedTitle = [self.segmentControl titleForSegmentAtIndex:self.segmentControl.selectedSegmentIndex];
        if ([selectedTitle isEqualToString:kSegmentTitleSurplus]) {
            double pay = ((SSJReportFormsItem *)[result ssj_safeObjectAtIndex:0]).money;
            double income = ((SSJReportFormsItem *)[result ssj_safeObjectAtIndex:1]).money;
            [self.surplusView setIncome:income pay:pay];
        }
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - Getter
- (SSJSegmentedControl *)segmentControl {
    if (!_segmentControl) {
        _segmentControl = [[SSJSegmentedControl alloc] initWithItems:@[kSegmentTitlePay,kSegmentTitleIncome,kSegmentTitleSurplus]];
        _segmentControl.font = [UIFont systemFontOfSize:18];
        _segmentControl.tintColor = [UIColor ssj_colorWithHex:@"#cccccc"];
        [_segmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"#47cfbe"]} forState:UIControlStateSelected];
        [_segmentControl addTarget:self action:@selector(segmentControlValueDidChange) forControlEvents:UIControlEventValueChanged];
        _segmentControl.center = CGPointMake(self.headerView.width * 0.5, kHeaderFirstPartHeight * 0.5);
    }
    return _segmentControl;
}

- (SSJReportFormsSwitchYearControl *)switchYearControl {
    if (!_switchYearControl) {
        __weak typeof(self) weakSelf = self;
        _switchYearControl = [[SSJReportFormsSwitchYearControl alloc] initWithFrame:CGRectMake(0, kHeaderFirstPartHeight, self.headerView.width, kHeaderSecondPartHeight)];
        _switchYearControl.backgroundColor = [UIColor ssj_colorWithHex:@"#f6f6f6"];
        _switchYearControl.preAction = ^(SSJReportFormsSwitchYearControl *switchYearControl) {
            if (weakSelf.scrollView.currentIndex == 0) {
                [weakSelf.calendarUtil preMonth];
            } else if (weakSelf.scrollView.currentIndex == 1) {
                [weakSelf.calendarUtil preYear];
            }
            [weakSelf updateSwithDateControlTitle];
            [weakSelf reloadDatas];
        };
        _switchYearControl.nextAction = ^(SSJReportFormsSwitchYearControl *switchYearControl) {
            if (weakSelf.scrollView.currentIndex == 0) {
                [weakSelf.calendarUtil nextMonth];
            } else if (weakSelf.scrollView.currentIndex == 1) {
                [weakSelf.calendarUtil nextYear];
            }
            [weakSelf updateSwithDateControlTitle];
            [weakSelf reloadDatas];
        };
    }
    return _switchYearControl;
}

- (SCYUnlimitedScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[SCYUnlimitedScrollView alloc] initWithFrame:CGRectMake(0, kHeaderFirstPartHeight + kHeaderSecondPartHeight, self.headerView.width, kHeaderThirdPartHeight)];
        _scrollView.dataSource = self;
        _scrollView.delegate = self;
        [_scrollView ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
        [_scrollView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_scrollView ssj_setBorderWidth:1];
    }
    return _scrollView;
}

- (SSJReportFormsPercentCircle *)monthCircleView {
    if (!_monthCircleView) {
        _monthCircleView = [[SSJReportFormsPercentCircle alloc] initWithFrame:CGRectZero];
        _monthCircleView.circleInsets = UIEdgeInsetsMake(30, 80, 60, 80);
        _monthCircleView.circleWidth = 39;
        _monthCircleView.dataSource = self;
    }
    return _monthCircleView;
}

- (SSJReportFormsPercentCircle *)yearCircleView {
    if (!_yearCircleView) {
        _yearCircleView = [[SSJReportFormsPercentCircle alloc] initWithFrame:CGRectZero];
        _yearCircleView.circleInsets = UIEdgeInsetsMake(30, 80, 60, 80);
        _yearCircleView.circleWidth = 39;
        _yearCircleView.dataSource = self;
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

- (SSJReportFormsSurplusView *)surplusView {
    if (!_surplusView) {
        _surplusView = [[SSJReportFormsSurplusView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 185)];
        _surplusView.backgroundColor = [UIColor ssj_colorWithHex:@"#f2f6f5"];
    }
    return _surplusView;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kHeaderFirstPartHeight + kHeaderSecondPartHeight/* + kHeaderThirdPartHeight*/)];
        _headerView.backgroundColor = [UIColor whiteColor];
        [_headerView ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
        [_headerView ssj_setBorderWidth:1];
        [_headerView addSubview:self.segmentControl];
        [_headerView addSubview:self.switchYearControl];
//        [_headerView addSubview:self.scrollView];
    }
    return _headerView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.headerView.height, self.view.width, self.view.height - self.headerView.height) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.rowHeight = 55;
        _tableView.sectionHeaderHeight = 0;
        _tableView.sectionFooterHeight = 0;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorColor = SSJ_DEFAULT_SEPARATOR_COLOR;
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.height, 0);
        _tableView.tableHeaderView = self.scrollView;
    }
    return _tableView;
}

@end
