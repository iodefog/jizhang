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

@interface SSJSummaryBooksViewController ()<UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate, SSJReportFormsPercentCircleDataSource, SSJReportFormsScaleAxisViewDelegate,SSJReportFormsCurveGraphViewDelegate>


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
    [self updateIncomeAndPaymentLabels];
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
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.summaryBooksHeaderColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];

    [self.mm_drawerController setMaximumLeftDrawerWidth:SSJSCREENWITH];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mm_drawerController setMaximumLeftDrawerWidth:SSJSCREENWITH * 0.8];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
}

#pragma mark - Getter
- (SSJSummaryBooksTableViewHeader *)header{
    if (!_header) {
        _header = [[SSJSummaryBooksTableViewHeader alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 1138)];
        _header.curveView.delegate = self;
        _header.chartView.dataSource = self;
        _header.dateAxisView.delegate = self;
        __weak typeof(self) weakSelf = self;
        _header.periodSelectBlock = ^(){
            weakSelf.currentPeriod = [weakSelf.periods ssj_safeObjectAtIndex:weakSelf.header.dateAxisView.selectedIndex];
            [weakSelf reloadAllDatas];
        };
        _header.incomeOrExpentureSelectBlock = ^(){
            [weakSelf reloadDatasCurrentPeriod];
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
    incomeAndPayCell.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
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

#pragma mark - SSJReportFormsCurveGraphViewDelegate
- (NSUInteger)numberOfAxisXInCurveGraphView:(SSJReportFormsCurveGraphView *)graphView {
    return _curveItems.count;
}

- (NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView titleAtAxisXIndex:(NSUInteger)index {
    SSJReportFormsCurveModel *model = [_curveItems ssj_safeObjectAtIndex:index];
    return model.time;
}

- (CGFloat)curveGraphView:(SSJReportFormsCurveGraphView *)graphView paymentValueAtAxisXIndex:(NSUInteger)index {
    SSJReportFormsCurveModel *model = [_curveItems ssj_safeObjectAtIndex:index];
    return [model.payment floatValue];
}

- (CGFloat)curveGraphView:(SSJReportFormsCurveGraphView *)graphView incomeValueAtAxisXIndex:(NSUInteger)index {
    SSJReportFormsCurveModel *model = [_curveItems ssj_safeObjectAtIndex:index];
    return [model.income floatValue];
}

- (void)curveGraphView:(SSJReportFormsCurveGraphView *)graphView didScrollToAxisXIndex:(NSUInteger)index {
    SSJReportFormsCurveModel *model = [_curveItems ssj_safeObjectAtIndex:index];
    self.currentPeriod = model.period;
    [self reloadDatasCurrentPeriod];
}

#pragma mark - Private
//  更新总收入\总支出
- (void)updateIncomeAndPaymentLabels {
    if (_header.incomOrExpenseSelectSegment.selectedSegmentIndex == 0) {
        _header.incomeAndPaymentTitleLab.hidden = _header.incomeAndPaymentMoneyLab.hidden = NO;
        _header.incomeAndPaymentTitleLab.text = @"总支出";
    } else if (_header.incomOrExpenseSelectSegment.selectedSegmentIndex == 1) {
        _header.incomeAndPaymentTitleLab.hidden = _header.incomeAndPaymentMoneyLab.hidden = NO;
        _header.incomeAndPaymentTitleLab.text = @"总收入";
    }
}

//  计算总收入\支出
- (void)caculateIncomeOrPayment {
    [_header.incomeAndPaymentMoneyLab ssj_showLoadingIndicator];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSNumber *payment = [self.chargeDatas valueForKeyPath:@"@sum.money"];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [_header.incomeAndPaymentMoneyLab ssj_hideLoadingIndicator];
            _header.incomeAndPaymentMoneyLab.text = [NSString stringWithFormat:@"%.2f", [payment doubleValue]];
        });
    });
}


// 查询某个周期内的流水统计
- (void)reloadDatasCurrentPeriod {
    if (!self.currentPeriod) {
        return;
    }
    [self.view ssj_showLoadingIndicator];
    
    // 加载流水列表和饼状图的数据
    [SSJReportFormsUtil queryForIncomeOrPayType:!(int)_header.incomOrExpenseSelectSegment.selectedSegmentIndex booksId:@"all" startDate:self.currentPeriod.startDate endDate:self.currentPeriod.endDate success:^(NSArray<SSJReportFormsItem *> *result) {
        [self.view ssj_hideLoadingIndicator];
        [self organiseDatasWithResult:result];
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    }];
}

//  重新加载数据
- (void)reloadAllDatas {
    // 加载折线图的数据
    SSJDatePeriod *period;
    if (_customPeriod) {
        period = _customPeriod;
    }else{
        period = [_periods ssj_safeObjectAtIndex:self.header.dateAxisView.selectedIndex];
    }
    [SSJReportFormsUtil queryForBillStatisticsWithType:!(int)_header.periodSelectSegment.selectedSegmentIndex startDate:period.startDate endDate:period.endDate booksId:@"all" success:^(NSDictionary *result) {
        
        [self.view ssj_hideLoadingIndicator];
        _curveItems = result[SSJReportFormsCurveModelListKey];
        
        if (_curveItems.count > 0) {
            [_header.curveView reloadData];
            if (_curveItems.count >= 1) {
                [_header.curveView scrollToAxisXAtIndex:_curveItems.count - 1 animated:NO];
            }
            SSJDatePeriod *currentPeriod = ((SSJReportFormsCurveModel *)[_curveItems ssj_safeObjectAtIndex:_curveItems.count - 1]).period;
            _currentPeriod = currentPeriod;
            // 加载流水列表和饼状图的数据
            [SSJReportFormsUtil queryForIncomeOrPayType:!(int)_header.incomOrExpenseSelectSegment.selectedSegmentIndex booksId:@"all" startDate:currentPeriod.startDate endDate:currentPeriod.endDate success:^(NSArray<SSJReportFormsItem *> *result) {
                [self.view ssj_hideLoadingIndicator];
                [self organiseDatasWithResult:result];
            } failure:^(NSError *error) {
                [self.view ssj_hideLoadingIndicator];
                [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
            }];
            self.header.curveViewHasDataOrNot = YES;
        } else {
            self.header.curveViewHasDataOrNot = NO;
        }
        
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    }];
}


// 加载日期选择的数据
- (void)reloadAxisView{
    __weak typeof(self) weakSelf = self;
    [SSJBooksTypeStore getTotalIncomeAndExpenceWithSuccess:^(double income, double expenture) {
        weakSelf.header.totalIncome = income;
        weakSelf.header.totalExpenture = expenture;
    } failure:^(NSError *error) {
        
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
        
        if (_periods.count >= 1) {
            _header.dateAxisView.selectedIndex = _periods.count - 1;
        }
        
        if (!_periods.count) {
            _header.addOrDeleteCustomPeriodBtn.hidden = YES;
        }else{
            _currentPeriod = [_periods ssj_safeObjectAtIndex:_header.dateAxisView.selectedIndex];
            _header.addOrDeleteCustomPeriodBtn.hidden = NO;
        }
        
        [self reloadAllDatas];
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
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
        //  收入、支出
        SSJPercentCircleViewItem *circleItem = [[SSJPercentCircleViewItem alloc] init];
        circleItem.scale = item.scale / scaleAmount;
        circleItem.imageName = item.imageName;
        circleItem.colorValue = item.colorValue;
        circleItem.additionalText = [NSString stringWithFormat:@"%.0f％", item.scale * 100];
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
    __weak typeof(self) wself = self;
    SSJMagicExportCalendarViewController *calendarVC = [[SSJMagicExportCalendarViewController alloc] init];
    calendarVC.title = @"自定义时间";
    calendarVC.billType = SSJBillTypeSurplus;

    calendarVC.completion = ^(NSDate *selectedBeginDate, NSDate *selectedEndDate) {
        _customPeriod = [SSJDatePeriod datePeriodWithStartDate:selectedBeginDate endDate:selectedEndDate];
        
        _header.customPeriod = _customPeriod;

        [wself reloadDatasCurrentPeriod];
    };
    [self.navigationController pushViewController:calendarVC animated:YES];
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
