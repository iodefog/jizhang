//
//  SSJSummaryBooksViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/11/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSummaryBooksViewController.h"
#import "SSJSummaryBooksTableViewHeader.h"
#import "SSJDatePeriod.h"
#import "SSJReportFormsCurveModel.h"
#import "SSJUserTableManager.h"
#import "SSJDatabaseQueue.h"
#import "SSJReportFormsUtil.h"
#import "SSJBooksTypeStore.h"
#import "SSJUserItem.h"
#import "SSJReportFormsIncomeAndPayCell.h"
#import "SSJMagicExportCalendarViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "SSJBillingChargeViewController.h"

static NSString *const kIncomeAndPayCellID = @"incomeAndPayCellID";

@interface SSJSummaryBooksViewController ()<UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate, SSJReportFormsPercentCircleDataSource, SSJReportFormsScaleAxisViewDelegate, SSJReportFormsCurveGraphViewDataSource, SSJReportFormsCurveGraphViewDelegate>


@property(nonatomic, strong) SSJSummaryBooksTableViewHeader *header;

//  流水列表视图
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, strong) NSMutableArray *circleItems;

@property (nonatomic, strong) NSArray *curveItems;

//  日期切换刻度控件的数据源
@property (nonatomic, strong) NSArray *periods;

@property(nonatomic, strong) NSArray *chargeDatas;

//  当前时间周期
@property (nonatomic, strong) SSJDatePeriod *currentPeriod;

//  自定义周期
@property (nonatomic, strong) SSJDatePeriod *customPeriod;

@end

@implementation SSJSummaryBooksViewController
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"总账本";
        self.circleItems = [NSMutableArray array];
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = self.header;
    [self.tableView registerClass:[SSJReportFormsIncomeAndPayCell class] forCellReuseIdentifier:kIncomeAndPayCellID];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadAxisView];
    [self updateIncomeAndPaymentLabels];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.summaryBooksHeaderColor alpha:SSJ_CURRENT_THEME.summaryBooksHeaderAlpha] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    [self.mm_drawerController setMaximumLeftDrawerWidth:SSJSCREENWITH];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
}


#pragma mark - Getter
- (SSJSummaryBooksTableViewHeader *)header{
    if (!_header) {
        _header = [[SSJSummaryBooksTableViewHeader alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 1138)];
        _header.curveView.dataSource = self;
        _header.curveView.delegate = self;
        _header.chartView.dataSource = self;
        _header.dateAxisView.delegate = self;
        __weak typeof(self) weakSelf = self;
        _header.periodSelectBlock = ^(){
            [weakSelf reloadCurveViewData];
        };
        _header.incomeOrExpentureSelectBlock = ^(){
            [weakSelf reloadChartViewData];
            [weakSelf updateIncomeAndPaymentLabels];
        };
        [_header.addOrDeleteCustomPeriodBtn addTarget:self action:@selector(customPeriodBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_header.customPeriodBtn addTarget:self action:@selector(enterCalendarVC) forControlEvents:UIControlEventTouchUpInside];

    }
    return _header;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_TABBAR_HEIGHT - SSJ_NAVIBAR_BOTTOM) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 55;
        _tableView.sectionHeaderHeight = 0;
        _tableView.sectionFooterHeight = 0;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chargeDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJReportFormsIncomeAndPayCell *incomeAndPayCell = [tableView dequeueReusableCellWithIdentifier:kIncomeAndPayCellID forIndexPath:indexPath];
    incomeAndPayCell.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    [incomeAndPayCell setCellItem:[self.chargeDatas ssj_safeObjectAtIndex:indexPath.row]];
    return incomeAndPayCell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.chargeDatas.count > indexPath.row) {
        SSJReportFormsItem *item = self.chargeDatas[indexPath.row];
        SSJBillingChargeViewController *billingChargeVC = [[SSJBillingChargeViewController alloc] init];
        billingChargeVC.ID = item.ID;
        billingChargeVC.booksId = @"all";
        billingChargeVC.color = [UIColor ssj_colorWithHex:item.colorValue];
        billingChargeVC.period = _customPeriod ?: [_periods ssj_safeObjectAtIndex:_header.dateAxisView.selectedIndex];
        billingChargeVC.isPayment = _header.incomOrExpenseSelectSegment.selectedSegmentIndex == 0;
        [self.navigationController pushViewController:billingChargeVC animated:YES];
    }
}

#pragma mark - SSJReportFormsScaleAxisViewDelegate
- (NSUInteger)numberOfAxisInScaleAxisView:(SSJReportFormsScaleAxisView *)scaleAxisView {
    return _periods.count;
}

- (NSString *)scaleAxisView:(SSJReportFormsScaleAxisView *)scaleAxisView titleForAxisAtIndex:(NSUInteger)index {
    SSJDatePeriod *period = [_periods ssj_safeObjectAtIndex:index];
    if (period.periodType == SSJDatePeriodTypeMonth) {
        return [NSString stringWithFormat:@"%d月", (int)period.startDate.month];
    } else if (period.periodType == SSJDatePeriodTypeYear) {
        return [NSString stringWithFormat:@"%d年", (int)period.startDate.year];
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
    } else if (period.periodType == SSJDatePeriodTypeYear
               || period.periodType == SSJDatePeriodTypeCustom) {
        return 20;
    } else {
        return 0;
    }
}

- (void)scaleAxisView:(SSJReportFormsScaleAxisView *)scaleAxisView didSelectedScaleAxisAtIndex:(NSUInteger)index {
    SSJDatePeriod *period = [_periods ssj_safeObjectAtIndex:index];
    self.currentPeriod = period;
    [self reloadAllDatas];
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

#pragma mark - SSJReportFormsCurveGraphViewDataSource
- (NSUInteger)numberOfAxisXInCurveGraphView:(SSJReportFormsCurveGraphView *)graphView {
    return _curveItems.count;
}

- (NSUInteger)numberOfCurveInCurveGraphView:(SSJReportFormsCurveGraphView *)graphView {
    return 2;
}

- (CGFloat)curveGraphView:(SSJReportFormsCurveGraphView *)graphView valueForCurveAtIndex:(NSUInteger)curveIndex axisXIndex:(NSUInteger)axisXIndex {
    
    SSJReportFormsCurveModel *model = [_curveItems ssj_safeObjectAtIndex:axisXIndex];
    if (curveIndex == 0) {  // 支出
        return model.payment;
    } else if (curveIndex == 1) { // 收入
        return model.income;
    } else {
        return 0;
    }
}

- (NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView titleAtAxisXIndex:(NSUInteger)index {
    SSJReportFormsCurveModel *model = [_curveItems ssj_safeObjectAtIndex:index];
    switch ([_header dimension]) {
        case SSJTimeDimensionDay: {
            return [model.startDate formattedDateWithFormat:@"dd日"];
        }
            break;
            
        case SSJTimeDimensionWeek: {
            NSString *startDateStr = [model.startDate formattedDateWithFormat:@"MM/dd"];
            NSString *endDateStr = [model.endDate formattedDateWithFormat:@"MM/dd"];
            return [NSString stringWithFormat:@"%@~%@", startDateStr, endDateStr];
        }
            break;
            
        case SSJTimeDimensionMonth: {
            return [model.startDate formattedDateWithFormat:@"MM月"];
        }
            break;
            
        case SSJTimeDimensionUnknown: {
            return nil;
        }
            break;
    }
}

- (UIColor *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView colorForCurveAtIndex:(NSUInteger)curveIndex {
    if (curveIndex == 0) { // 支出
        return [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentColor];
    } else if (curveIndex == 1) { // 收入
        return [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurveIncomeColor];
    } else {
        return nil;
    }
}

- (nullable NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView suspensionTitleAtAxisXIndex:(NSUInteger)index {
    
    SSJReportFormsCurveModel *model = [_curveItems ssj_safeObjectAtIndex:index];
    if (index == 0) {
        switch ([_header dimension]) {
            case SSJTimeDimensionDay:
                return [model.startDate formattedDateWithFormat:@"M月"];
                break;
                
            case SSJTimeDimensionWeek:
                return [model.startDate formattedDateWithFormat:@"yyyy年"];
                break;
                
            case SSJTimeDimensionMonth:
                return [model.startDate formattedDateWithFormat:@"yyyy年"];
                break;
                
            case SSJTimeDimensionUnknown:
                break;
        }
    }
    
    SSJReportFormsCurveModel *lastModel = [_curveItems ssj_safeObjectAtIndex:index - 1];
    switch ([_header dimension]) {
        case SSJTimeDimensionDay:
            if (model.startDate.year != lastModel.startDate.year
                || model.startDate.month != lastModel.startDate.month) {
                return [model.startDate formattedDateWithFormat:@"M月"];
            }
            
            break;
            
        case SSJTimeDimensionWeek:
            if (model.startDate.year != lastModel.startDate.year) {
                return [model.startDate formattedDateWithFormat:@"yyyy年"];
            }
            
            break;
            
        case SSJTimeDimensionMonth:
            if (model.startDate.year != lastModel.startDate.year) {
                return [model.startDate formattedDateWithFormat:@"yyyy年"];
            }
            
            break;
            
        case SSJTimeDimensionUnknown:
            break;
    }
    
    return nil;
}

#pragma mark - SSJReportFormsCurveGraphViewDelegate
- (NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView titleForBallonAtAxisXIndex:(NSUInteger)index {
    SSJReportFormsCurveModel *model = [_curveItems ssj_safeObjectAtIndex:index];
    NSString *surplusStr = [NSString stringWithFormat:@"%f", (model.income - model.payment)];
    return [NSString stringWithFormat:@"结余%@", [surplusStr ssj_moneyDecimalDisplayWithDigits:2]];
}

- (NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView titleForBallonLabelAtCurveIndex:(NSUInteger)curveIndex axisXIndex:(NSUInteger)axisXIndex {
    SSJReportFormsCurveModel *model = [_curveItems ssj_safeObjectAtIndex:axisXIndex];
    if (curveIndex == 0) { // 支出
        return [NSString stringWithFormat:@"支出%@", [[NSString stringWithFormat:@"%f", model.payment] ssj_moneyDecimalDisplayWithDigits:2]];
    } else if (curveIndex == 1) { // 收入
        return [NSString stringWithFormat:@"收入%@", [[NSString stringWithFormat:@"%f", model.income] ssj_moneyDecimalDisplayWithDigits:2]];
    } else {
        return nil;
    }
}

#pragma mark - Private
//  更新总收入\总支出
- (void)updateIncomeAndPaymentLabels {
    if (_header.incomOrExpenseSelectSegment.selectedSegmentIndex == 0) {
        _header.title = @"总支出";
    } else if (_header.incomOrExpenseSelectSegment.selectedSegmentIndex == 1) {
        _header.title = @"总收入";
    }
}

//  重新加载数据
- (void)reloadAllDatas {
    
    SSJDatePeriod *period = _customPeriod ?: _currentPeriod;
    [SSJReportFormsUtil queryForDefaultTimeDimensionWithStartDate:period.startDate endDate:period.endDate booksId:@"all" billTypeId:nil success:^(SSJTimeDimension timeDimension) {
        
        if (timeDimension != SSJTimeDimensionUnknown) {
            _header.dimension = timeDimension;
        }
        
        [self reloadCurveViewData];
        [self reloadChartViewData];
        
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [self showError:error];
    }];
}

// 加载折线图的数据
- (void)reloadCurveViewData {
    SSJDatePeriod *period = _customPeriod ?: _currentPeriod;
    [SSJReportFormsUtil queryForBillStatisticsWithTimeDimension:[_header dimension] booksId:@"all" billTypeId:nil startDate:period.startDate endDate:period.endDate success:^(NSDictionary *result) {
        
        [self.view ssj_hideLoadingIndicator];
        _curveItems = result[SSJReportFormsCurveModelListKey];
        
        if (_curveItems.count == 0) {
            self.header.curveViewHasDataOrNot = NO;
            self.chargeDatas = nil;
            [self.tableView reloadData];
            return;
        }
        
        [_header.curveView reloadData];
        if (_curveItems.count >= 1) {
            [_header.curveView scrollToAxisXAtIndex:_curveItems.count - 1 animated:NO];
        }
        self.header.curveViewHasDataOrNot = YES;
        
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [self showError:error];
    }];
}

- (void)reloadChartViewData {
    // 加载流水列表和饼状图的数据
    SSJDatePeriod *period = _customPeriod ?: _currentPeriod;
    if (period) {
        [SSJReportFormsUtil queryForIncomeOrPayType:!(int)_header.incomOrExpenseSelectSegment.selectedSegmentIndex booksId:@"all" startDate:period.startDate endDate:period.endDate success:^(NSArray<SSJReportFormsItem *> *result) {
            [self.view ssj_hideLoadingIndicator];
            [self organiseDatasWithResult:result];
        } failure:^(NSError *error) {
            [self.view ssj_hideLoadingIndicator];
            [self showError:error];
        }];
    }
}

// 加载日期选择的数据
- (void)reloadAxisView{
    __weak typeof(self) weakSelf = self;
    [SSJBooksTypeStore getTotalIncomeAndExpenceWithSuccess:^(double income, double expenture) {
        weakSelf.header.totalIncome = income;
        weakSelf.header.totalExpenture = expenture;
    } failure:^(NSError *error) {
        [self showError:error];
    }];

    
    [SSJReportFormsUtil queryForPeriodListWithIncomeOrPayType:SSJBillTypeSurplus booksId:@"all" success:^(NSArray<SSJDatePeriod *> *periods) {
        
//        if (periods.count == 0) {
//            _dateAxisView.hidden = YES;
//            _customPeriodBtn.hidden = YES;
//            _addOrDeleteCustomPeriodBtn.hidden = YES;
//            self.tableView.hidden = YES;
//            
//            [self.view ssj_hideLoadingIndicator];
//            [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
//            
//            return;
//        }
        
        _header.dateAxisView.hidden = _customPeriod;
        _header.customPeriodBtn.hidden = !_customPeriod;
        _header.addOrDeleteCustomPeriodBtn.hidden = NO;
        self.tableView.hidden = NO;
        [self.view ssj_hideWatermark:YES];
        
        _periods = periods;
        [_header.dateAxisView reloadData];
        
        NSInteger selectedIndex = (_currentPeriod ? [_periods indexOfObject:_currentPeriod] : _periods.count - 1);
        _header.dateAxisView.selectedIndex = selectedIndex;
        _currentPeriod = [_periods ssj_safeObjectAtIndex:selectedIndex];
        
        _header.addOrDeleteCustomPeriodBtn.hidden = !_periods.count;
        
        [self reloadAllDatas];
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [self showError:error];
    }];

}

- (void)organiseDatasWithResult:(NSArray *)result {
    //  将datas按照收支类型所占比例从大到小进行排序
    self.chargeDatas = [result sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
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
    
    NSNumber *payment = [self.chargeDatas valueForKeyPath:@"@sum.money"];
    _header.amount = [NSString stringWithFormat:@"%.2f", [payment doubleValue]];
    
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
        //  收入、支出
        SSJPercentCircleViewItem *circleItem = [[SSJPercentCircleViewItem alloc] init];
        circleItem.scale = item.scale / scaleAmount;
        circleItem.imageName = item.imageName;
        circleItem.colorValue = item.colorValue;
        circleItem.additionalText = [NSString stringWithFormat:@"%.0f％", item.scale * 100];
        circleItem.additionalFont = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_5);
        circleItem.imageBorderShowed = YES;
        [self.circleItems addObject:circleItem];
    }
    
    [self.header.chartView reloadData];
    
    if (!self.chargeDatas.count) {
        self.header.chartViewHasDataOrNot = NO;
    } else {
        self.header.chartViewHasDataOrNot = YES;

    }
    
    //        NSString *selectedTitle = [_segmentControl.titles ssj_safeObjectAtIndex:_segmentControl.selectedIndex];
    //        if ([selectedTitle isEqualToString:kSegmentTitleSurplus]) {
    //            double pay = 0;
    //            double income = 0;
    //            for (SSJReportFormsItem *item in result) {
    //                switch (item.type) {
    //                    case SSJReportFormsTypeIncome:
    //                        income = item.money;
    //                        break;
    //
    //                    case SSJReportFormsTypePayment:
    //                        pay = item.money;
    //                        break;
    //                }
    //            }
    //            [self.surplusView setIncome:income pay:pay];
    //        }
}

- (void)customPeriodBtnAction {
    if (_customPeriod) {
        _customPeriod = nil;
        _header.customPeriod = nil;
        [self reloadAllDatas];
    } else {
        [self enterCalendarVC];
    }
}

- (void)enterCalendarVC {
    SSJMagicExportCalendarViewController *calendarVC = [[SSJMagicExportCalendarViewController alloc] init];
    calendarVC.title = @"自定义时间";
    calendarVC.billType = SSJBillTypeSurplus;
    calendarVC.completion = ^(NSDate *selectedBeginDate, NSDate *selectedEndDate) {
        _customPeriod = [SSJDatePeriod datePeriodWithStartDate:selectedBeginDate endDate:selectedEndDate];
        _header.customPeriod = _customPeriod;
    };
    [self.navigationController pushViewController:calendarVC animated:YES];
}

- (void)showError:(NSError *)error {
    NSString *message = nil;
#ifdef DEBUG
    message = [error localizedDescription];
#else
    message = SSJ_ERROR_MESSAGE;
#endif
    [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:message action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
}

- (void)updateAppearanceAfterThemeChanged{
    [super updateAppearanceAfterThemeChanged];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.summaryBooksHeaderColor alpha:SSJ_CURRENT_THEME.summaryBooksHeaderAlpha] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
