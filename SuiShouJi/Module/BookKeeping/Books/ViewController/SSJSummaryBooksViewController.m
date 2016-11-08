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
#import "SSJBooksTypeStore.h"
#import "SSJReportFormsCurveModel.h"
#import "SSJUserTableManager.h"
#import "SSJUserItem.h"
#import "SSJReportFormsIncomeAndPayCell.h"
#import "SSJMagicExportCalendarViewController.h"
#import "UIViewController+MMDrawerController.h"

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

//  自定义时间周期
@property (nonatomic, strong) SSJDatePeriod *currentPeriod;

@end

@implementation SSJSummaryBooksViewController
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.statisticsTitle = @"总账本";
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
    [self reloadDatasCurrentPeriod];
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
// 查询某个周期内的流水统计
- (void)reloadDatasCurrentPeriod {
    if (!self.currentPeriod) {
        return;
    }
    [self.view ssj_showLoadingIndicator];
    
    // 加载流水列表和饼状图的数据
    [SSJBooksTypeStore queryForIncomeOrPayType:!(int)_header.incomOrExpenseSelectSegment.selectedSegmentIndex startDate:self.currentPeriod.startDate endDate:self.currentPeriod.endDate success:^(NSArray<SSJReportFormsItem *> *result) {
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
    [SSJBooksTypeStore queryForBillStatisticsWithType:0 startDate:_currentPeriod.startDate endDate:_currentPeriod.endDate success:^(NSDictionary *result) {
        
        [self.view ssj_hideLoadingIndicator];
        _curveItems = result[SSJReportFormsCurveModelListForBooksKey];
        
        if (_curveItems.count > 0) {
            [_header.curveView reloadData];
            if (_curveItems.count >= 1) {
                [_header.curveView scrollToAxisXAtIndex:_curveItems.count - 1 animated:NO];
            }
            _currentPeriod = ((SSJReportFormsCurveModel *)[_curveItems ssj_safeObjectAtIndex:_curveItems.count - 1]).period;
            // 加载流水列表和饼状图的数据
            [SSJBooksTypeStore queryForIncomeOrPayType:!(int)_header.incomOrExpenseSelectSegment.selectedSegmentIndex startDate:self.currentPeriod.startDate endDate:self.currentPeriod.endDate success:^(NSArray<SSJReportFormsItem *> *result) {
                [self.view ssj_hideLoadingIndicator];
                [self organiseDatasWithResult:result];
            } failure:^(NSError *error) {
                [self.view ssj_hideLoadingIndicator];
                [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
            }];
            
//            [self.view ssj_hideWatermark:YES];
        } else {
//            [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
        }
        
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    }];

}


// 加载日期选择的数据
- (void)reloadAxisView{
    [SSJBooksTypeStore queryForPeriodListWithsuccess:^(NSArray<SSJDatePeriod *> *periods) {
        
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
        
        _header.dateAxisView.hidden = NO;
//        _header.customPeriodBtn.hidden = !_customPeriod;
        _header.addOrDeleteCustomPeriodBtn.hidden = NO;
        self.tableView.hidden = NO;
        [self.view ssj_hideWatermark:YES];
        
        _periods = periods;
        [_header.dateAxisView reloadData];
        
        if (_periods.count >= 3) {
            _header.dateAxisView.selectedIndex = _periods.count - 3;
        }
        
        _currentPeriod = [_periods ssj_safeObjectAtIndex:_header.dateAxisView.selectedIndex];
        
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
    
//    if (!self.datas.count) {
//        self.tableView.hidden = YES;
//        [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
//    } else {
//        self.tableView.hidden = NO;
//        [self.view ssj_hideWatermark:YES];
//    }
    
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

- (void)enterCalendarVC {
    __weak typeof(self) wself = self;
    SSJMagicExportCalendarViewController *calendarVC = [[SSJMagicExportCalendarViewController alloc] init];
    calendarVC.title = @"自定义时间";
    calendarVC.completion = ^(NSDate *selectedBeginDate, NSDate *selectedEndDate) {
        wself.currentPeriod = [SSJDatePeriod datePeriodWithStartDate:selectedBeginDate endDate:selectedEndDate];
        wself.header.dateAxisView.hidden = YES;
        wself.header.customPeriodBtn.hidden = NO;
        [wself updateCustomPeriodBtn];
        [wself.header.addOrDeleteCustomPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_delete"] forState:UIControlStateNormal];
        [wself reloadDatasCurrentPeriod];
    };
    [self.navigationController pushViewController:calendarVC animated:YES];
}

- (void)updateCustomPeriodBtn {
    NSString *startDateStr = [_currentPeriod.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *endDateStr = [_currentPeriod.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *title = [NSString stringWithFormat:@"%@－－%@", startDateStr, endDateStr];
    [_header.customPeriodBtn setTitle:title forState:UIControlStateNormal];
    CGSize textSize = [title sizeWithAttributes:@{NSFontAttributeName:_header.customPeriodBtn.titleLabel.font}];
    _header.customPeriodBtn.width = textSize.width + 28;
    _header.customPeriodBtn.centerX = self.header.width * 0.5;
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
