//
//  SSJReportFormsViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/11.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJReportFormsViewController.h"
#import "SSJPercentCircleView.h"
#import "SSJPageControl.h"
#import "SSJSegmentedControl.h"
#import "SSJReportFormsSurplusView.h"
#import "SSJReportFormsIncomeAndPayCell.h"
#import "SSJReportFormsScaleAxisView.h"

#import "SSJBillingChargeViewController.h"
#import "SSJMagicExportCalendarViewController.h"
#import "SSJReportFormsUtil.h"

static NSString *const kIncomeAndPayCellID = @"incomeAndPayCellID";

static NSString *const kSegmentTitlePay = @"支出";
static NSString *const kSegmentTitleIncome = @"收入";
static NSString *const kSegmentTitleSurplus = @"结余";

@interface SSJReportFormsViewController () <UITableViewDataSource, UITableViewDelegate, SSJReportFormsPercentCircleDataSource, SSJReportFormsScaleAxisViewDelegate>

//  收入、支出、结余切换控件
@property (nonatomic, strong) SSJSegmentedControl *segmentControl;

//  切换年份、月份控件
@property (nonatomic, strong) SSJReportFormsScaleAxisView *dateAxisView;

//  月份收支图表
@property (nonatomic, strong) SSJPercentCircleView *chartView;

//  结余金额视图
@property (nonatomic, strong) SSJReportFormsSurplusView *surplusView;

//  没有流水的提示视图
@property (nonatomic, strong) UIImageView *noDataRemindView;

//  流水列表视图
@property (nonatomic, strong) UITableView *tableView;

//  圆环中间顶部的总收入、总支出
@property (nonatomic, strong) UILabel *incomeAndPaymentTitleLab;

//  圆环中间顶部的总收入、总支出金额
@property (nonatomic, strong) UILabel *incomeAndPaymentMoneyLab;

//  数据源
@property (nonatomic, strong) NSArray *datas;

//  日期切换刻度控件的数据源
@property (nonatomic, strong) NSArray *periods;

//  圆环图表数据源
@property (nonatomic, strong) NSMutableArray *circleItems;

//  自定义时间周期
@property (nonatomic, strong) SSJDatePeriod *customPeriod;

@end

@implementation SSJReportFormsViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.statisticsTitle = @"报表首页";
        self.circleItems = [NSMutableArray array];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reportForms_filter"] style:UIBarButtonItemStylePlain target:self action:@selector(enterCalendarAction)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reportForms_filter"] style:UIBarButtonItemStylePlain target:self action:@selector(filterAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.navigationItem.titleView = self.segmentControl;
    
    [self.view addSubview:self.dateAxisView];
    [self.view addSubview:self.tableView];
    
    UIView *headerView = [[UIView alloc] initWithFrame:self.chartView.frame];
    [headerView addSubview:self.chartView];
    [headerView addSubview:self.incomeAndPaymentTitleLab];
    [headerView addSubview:self.incomeAndPaymentMoneyLab];
    
    self.tableView.tableHeaderView = headerView;
    [self.tableView registerClass:[SSJReportFormsIncomeAndPayCell class] forCellReuseIdentifier:kIncomeAndPayCellID];
    
    [self updateIncomeAndPaymentLabels];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadDatas];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.height = self.view.height - self.dateAxisView.height;
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
//        billingChargeVC.year = self.calendarUtil.year;
        billingChargeVC.color = [UIColor ssj_colorWithHex:item.colorValue];
//        if (self.periodSelectionView.periodType == SSJReportFormsPeriodTypeMonth) {
//            billingChargeVC.month = self.calendarUtil.month;
//        }
        [self.navigationController pushViewController:billingChargeVC animated:YES];
    }
}

#pragma mark - SSJReportFormsPercentCircleDataSource
- (NSUInteger)numberOfComponentsInPercentCircle:(SSJPercentCircleView *)circle {
    return self.circleItems.count;
}

- (SSJPercentCircleViewItem *)percentCircle:(SSJPercentCircleView *)circle itemForComponentAtIndex:(NSUInteger)index {
    if (index < self.circleItems.count) {
        return self.circleItems[index];
    }
    return nil;
}

#pragma mark - SSJReportFormsScaleAxisViewDelegate
- (NSUInteger)numberOfAxisInScaleAxisView:(SSJReportFormsScaleAxisView *)scaleAxisView {
    return _periods.count;
}

- (NSString *)scaleAxisView:(SSJReportFormsScaleAxisView *)scaleAxisView titleForAxisAtIndex:(NSUInteger)index {
    SSJDatePeriod *period = [_periods ssj_safeObjectAtIndex:index];
    if (period.periodType == SSJDatePeriodTypeMonth) {
        return [NSString stringWithFormat:@"%d月", (int)period.startDate.month];
    } else if (period.periodType == SSJDatePeriodTypeMonth) {
        return [NSString stringWithFormat:@"%d", (int)period.startDate.year];
    } else if (period.periodType == SSJDatePeriodTypeCustom) {
        return @"合计";
    } else {
        return nil;
    }
}

- (CGFloat)scaleAxisView:(SSJReportFormsScaleAxisView *)scaleAxisView heightForAxisAtIndex:(NSUInteger)index {
    SSJDatePeriod *period = [_periods ssj_safeObjectAtIndex:index];
    if (period.periodType == SSJDatePeriodTypeMonth) {
        return 12;
    } else if (period.periodType == SSJDatePeriodTypeMonth
               || period.periodType == SSJDatePeriodTypeCustom) {
        return 20;
    } else {
        return 0;
    }
}

- (void)scaleAxisView:(SSJReportFormsScaleAxisView *)scaleAxisView didSelectedScaleAxisAtIndex:(NSUInteger)index {
    SSJDatePeriod *period = [_periods ssj_safeObjectAtIndex:index];
    [self reloadDatasInPeriod:period];
    [self updateSurplusViewTitle];
}

#pragma mark - Event
- (void)enterCalendarAction {
    __weak typeof(self) wself = self;
    SSJMagicExportCalendarViewController *calendarVC = [[SSJMagicExportCalendarViewController alloc] init];
    calendarVC.title = @"自定义时间";
    calendarVC.billType = [self currentType];
    calendarVC.completion = ^(NSDate *selectedBeginDate, NSDate *selectedEndDate) {
        wself.customPeriod = [SSJDatePeriod datePeriodWithStartDate:selectedBeginDate endDate:selectedEndDate];
        wself.dateAxisView.hidden = YES;
    };
    [self.navigationController pushViewController:calendarVC animated:YES];
}

//  切换周期（年、月）
- (void)filterAction {
    [MobClick event:@"form_filter"];
}

//  切换支出、收入、结余
- (void)segmentControlValueDidChange {
    [self reloadDatas];
    [self updateIncomeAndPaymentLabels];
    
    NSString *selectedTitle = [self.segmentControl titleForSegmentAtIndex:self.segmentControl.selectedSegmentIndex];
    if ([selectedTitle isEqualToString:kSegmentTitlePay]
        || [selectedTitle isEqualToString:kSegmentTitleIncome]) {
        
        self.tableView.tableFooterView = [[UIView alloc] init];
        
    } else if ([selectedTitle isEqualToString:kSegmentTitleSurplus]) {
        self.tableView.tableFooterView = self.surplusView;
    }
    if ([selectedTitle isEqualToString:kSegmentTitlePay]) {
        [MobClick event:@"form_out"];
    }else if ([selectedTitle isEqualToString:kSegmentTitleIncome]){
        [MobClick event:@"form_in"];
    }else{
        [MobClick event:@"form_total"];
    }
}

- (void)reloadDataAfterSync {
    [self reloadDatas];
}

#pragma mark - Private
//  返回当前收支类型
- (SSJBillType)currentType {
    NSString *selectedTitle = [self.segmentControl titleForSegmentAtIndex:self.segmentControl.selectedSegmentIndex];

    if ([selectedTitle isEqualToString:kSegmentTitlePay]) {
        return SSJBillTypePay;
    } else if ([selectedTitle isEqualToString:kSegmentTitleIncome]) {
        return SSJBillTypeIncome;
    } else if ([selectedTitle isEqualToString:kSegmentTitleSurplus]) {
        return SSJBillTypeSurplus;
    } else {
        return SSJBillTypeUnknown;
    }
}

//  更新结余标题
- (void)updateSurplusViewTitle {
    SSJDatePeriod *selectedPeriod = [_periods ssj_safeObjectAtIndex:_dateAxisView.selectedIndex];
    if (selectedPeriod.periodType == SSJDatePeriodTypeMonth) {
        [self.surplusView setTitle:[NSString stringWithFormat:@"%d月结余", (int)selectedPeriod.startDate.month]];
    } else if (selectedPeriod.periodType == SSJDatePeriodTypeYear) {
        [self.surplusView setTitle:[NSString stringWithFormat:@"%d年结余", (int)selectedPeriod.startDate.year]];
    } else if (selectedPeriod.periodType == SSJDatePeriodTypeCustom) {
        [self.surplusView setTitle:@"合计结余"];
    }
}

//  更新总收入\总支出
- (void)updateIncomeAndPaymentLabels {
    if (_segmentControl.selectedSegmentIndex == 0) {
        _incomeAndPaymentTitleLab.hidden = _incomeAndPaymentMoneyLab.hidden = NO;
        _incomeAndPaymentTitleLab.text = @"总支出";
    } else if (_segmentControl.selectedSegmentIndex == 1) {
        _incomeAndPaymentTitleLab.hidden = _incomeAndPaymentMoneyLab.hidden = NO;
        _incomeAndPaymentTitleLab.text = @"总收入";
    } else if (_segmentControl.selectedSegmentIndex == 2) {
        _incomeAndPaymentTitleLab.hidden = _incomeAndPaymentMoneyLab.hidden = YES;
    }
}

//  计算总收入\支出
- (void)caculateIncomeOrPayment {
    if (_segmentControl.selectedSegmentIndex == 0
        || _segmentControl.selectedSegmentIndex == 1) {
        
        [_incomeAndPaymentMoneyLab ssj_showLoadingIndicator];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSNumber *payment = [self.datas valueForKeyPath:@"@sum.money"];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [_incomeAndPaymentMoneyLab ssj_hideLoadingIndicator];
                _incomeAndPaymentMoneyLab.text = [NSString stringWithFormat:@"%.2f", [payment doubleValue]];
            });
        });
    }
}

// 如果当前是自定义时间，就查询自定义时间范围内的流水统计；反之就查询当前刻度时间的流水统计
- (void)reloadDatas {
    if (_customPeriod) {
        [self reloadDatasInPeriod:_customPeriod];
    } else {
        [self reloadAllDatas];
    }
}

//  重新加载数据
- (void)reloadAllDatas {
    
    [self.view ssj_showLoadingIndicator];
    
    [SSJReportFormsDatabaseUtil queryForPeriodListWithIncomeOrPayType:[self currentType] success:^(NSArray<SSJDatePeriod *> *periods) {
        
        if (periods.count == 0) {
            _dateAxisView.hidden = YES;
            self.tableView.hidden = YES;
            [self.view ssj_hideLoadingIndicator];
            [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
            return;
        }
        
        _dateAxisView.hidden = NO;
        self.tableView.hidden = NO;
        [self.view ssj_hideWatermark:YES];
        _periods = periods;
        [_dateAxisView reloadData];
        
        // 计算当前月份在日起刻度控件上的下标
        SSJDatePeriod *currentPeriod = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeMonth date:[NSDate date]];
        for (int i = 0; i < _periods.count; i ++) {
            if ([_periods[i] compareWithPeriod:currentPeriod] == SSJDatePeriodComparisonResultSame) {
                _dateAxisView.selectedIndex = i;
            }
        }
        
        [self updateSurplusViewTitle];
        
        // 查询当前月份的流水统计
        [self reloadDatasInPeriod:[_periods ssj_safeObjectAtIndex:_dateAxisView.selectedIndex]];
        
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    }];
}

// 查询某个周期内的流水统计
- (void)reloadDatasInPeriod:(SSJDatePeriod *)period {
    
    [self.view ssj_showLoadingIndicator];
    
    [SSJReportFormsDatabaseUtil queryForIncomeOrPayType:[self currentType] startDate:period.startDate endDate:period.endDate success:^(NSArray<SSJReportFormsItem *> *result) {
        
        [self.view ssj_hideLoadingIndicator];
        
        //  将datas按照收支类型所占比例从大到小进行排序
        self.datas = [result sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            SSJReportFormsItem *item1 = obj1;
            SSJReportFormsItem *item2 = obj2;
            if (item1.scale > item2.scale) {
                return NSOrderedAscending;
            } else if (item1.scale < item2.scale) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }];
        [self.tableView reloadData];
        [self caculateIncomeOrPayment];
        
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
                SSJPercentCircleViewItem *circleItem = [[SSJPercentCircleViewItem alloc] init];
                circleItem.scale = item.scale / scaleAmount;
                circleItem.imageName = item.imageName;
                circleItem.colorValue = item.colorValue;
                circleItem.additionalText = [NSString stringWithFormat:@"%.0f％", item.scale * 100];
                circleItem.imageBorderShowed = YES;
                [self.circleItems addObject:circleItem];
                
            } else if ([selectedTitle isEqualToString:kSegmentTitleSurplus]) {
                //  结余，结余最多只有收入、支出两种类型
                NSUInteger index = [result indexOfObject:item];
                if (index <= 1) {
                    SSJPercentCircleViewItem *circleItem = [[SSJPercentCircleViewItem alloc] init];
                    circleItem.scale = item.scale / scaleAmount;
                    circleItem.imageName = item.imageName;
                    circleItem.colorValue = item.colorValue;
                    circleItem.additionalText = [NSString stringWithFormat:@"%.0f％", item.scale * 100];
                    circleItem.imageBorderShowed = NO;
                    [self.circleItems addObject:circleItem];
                }
            }
        }
        
        [self.chartView reloadData];
        
        if (!self.datas.count) {
            self.tableView.hidden = YES;
            [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
        } else {
            self.tableView.hidden = NO;
            [self.view ssj_hideWatermark:YES];
        }
        
        NSString *selectedTitle = [self.segmentControl titleForSegmentAtIndex:self.segmentControl.selectedSegmentIndex];
        if ([selectedTitle isEqualToString:kSegmentTitleSurplus]) {
            double pay = 0;
            double income = 0;
            for (SSJReportFormsItem *item in result) {
                switch (item.type) {
                    case SSJReportFormsTypeIncome:
                        income = item.money;
                        break;
                        
                    case SSJReportFormsTypePayment:
                        pay = item.money;
                        break;
                }
            }
            [self.surplusView setIncome:income pay:pay];
        }
        
        
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    }];
}

#pragma mark - Getter
- (SSJSegmentedControl *)segmentControl {
    if (!_segmentControl) {
        _segmentControl = [[SSJSegmentedControl alloc] initWithItems:@[kSegmentTitlePay,kSegmentTitleIncome,kSegmentTitleSurplus]];
        _segmentControl.size = CGSizeMake(225, 30);
        _segmentControl.font = [UIFont systemFontOfSize:15];
        _segmentControl.borderColor = [UIColor ssj_colorWithHex:@"#cccccc"];
        _segmentControl.selectedBorderColor = [UIColor ssj_colorWithHex:@"#eb4a64"];
        [_segmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"#eb4a64"]} forState:UIControlStateSelected];
        [_segmentControl addTarget:self action:@selector(segmentControlValueDidChange) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentControl;
}

- (SSJReportFormsScaleAxisView *)dateAxisView {
    if (!_dateAxisView) {
        _dateAxisView = [[SSJReportFormsScaleAxisView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 60)];
        _dateAxisView.delegate = self;
    }
    return _dateAxisView;
}

- (SSJPercentCircleView *)chartView {
    if (!_chartView) {
        _chartView = [[SSJPercentCircleView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 320) insets:UIEdgeInsetsMake(80, 80, 80, 80) thickness:39];
        _chartView.dataSource = self;
        [_chartView ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
        [_chartView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_chartView ssj_setBorderWidth:1];
    }
    return _chartView;
}

- (SSJReportFormsSurplusView *)surplusView {
    if (!_surplusView) {
        _surplusView = [[SSJReportFormsSurplusView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 185)];
        _surplusView.backgroundColor = [UIColor ssj_colorWithHex:@"#f2f6f5"];
    }
    return _surplusView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.dateAxisView.bottom, self.view.width, self.view.height - self.dateAxisView.bottom) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.rowHeight = 55;
        _tableView.sectionHeaderHeight = 0;
        _tableView.sectionFooterHeight = 0;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorColor = SSJ_DEFAULT_SEPARATOR_COLOR;
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.height, 0);
    }
    return _tableView;
}

- (UIImageView *)noDataRemindView {
    if (!_noDataRemindView) {
        _noDataRemindView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"budget_no_data"]];
        UILabel *noDataLab = [[UILabel alloc] init];
        noDataLab.textColor = [UIColor whiteColor];
        noDataLab.font = [UIFont systemFontOfSize:18];
        noDataLab.text = @"报表空空如也";
        [noDataLab sizeToFit];
        noDataLab.center = CGPointMake(_noDataRemindView.width * 0.5, _noDataRemindView.height * 0.737);
        [_noDataRemindView addSubview:noDataLab];
    }
    return _noDataRemindView;
}

- (UILabel *)incomeAndPaymentTitleLab {
    if (!_incomeAndPaymentTitleLab) {
        CGRect hollowFrame = UIEdgeInsetsInsetRect(self.chartView.circleFrame, UIEdgeInsetsMake(self.chartView.circleThickness, self.chartView.circleThickness, self.chartView.circleThickness, self.chartView.circleThickness));
        _incomeAndPaymentTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(hollowFrame.origin.x, (hollowFrame.size.height - 38) * 0.5 + hollowFrame.origin.y, hollowFrame.size.width, 15)];
        _incomeAndPaymentTitleLab.backgroundColor = [UIColor clearColor];
        _incomeAndPaymentTitleLab.font = [UIFont systemFontOfSize:15];
        _incomeAndPaymentTitleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _incomeAndPaymentTitleLab;
}

- (UILabel *)incomeAndPaymentMoneyLab {
    if (!_incomeAndPaymentMoneyLab) {
        CGRect hollowFrame = UIEdgeInsetsInsetRect(self.chartView.circleFrame, UIEdgeInsetsMake(self.chartView.circleThickness, self.chartView.circleThickness, self.chartView.circleThickness, self.chartView.circleThickness));
        _incomeAndPaymentMoneyLab = [[UILabel alloc] initWithFrame:CGRectMake(hollowFrame.origin.x, (hollowFrame.size.height - 38) * 0.5 + hollowFrame.origin.y + 20, hollowFrame.size.width, 18)];
        _incomeAndPaymentMoneyLab.backgroundColor = [UIColor clearColor];
        _incomeAndPaymentMoneyLab.font = [UIFont systemFontOfSize:18];
        _incomeAndPaymentMoneyLab.minimumScaleFactor = 0.66;
        _incomeAndPaymentMoneyLab.adjustsFontSizeToFitWidth = YES;
        _incomeAndPaymentMoneyLab.textAlignment = NSTextAlignmentCenter;
    }
    return _incomeAndPaymentMoneyLab;
}

@end
