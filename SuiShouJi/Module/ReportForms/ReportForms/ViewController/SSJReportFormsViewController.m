//
//  SSJReportFormsViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/11.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJReportFormsViewController.h"
#import "SSJReportFormsPeriodSelectionView.h"
#import "SSJReportFormsPercentCircle.h"
#import "SSJReportFormsSwitchYearControl.h"
#import "SSJPageControl.h"
#import "SSJSegmentedControl.h"
#import "SSJReportFormsSurplusView.h"
#import "SSJReportFormsIncomeAndPayCell.h"

#import "SSJBillingChargeViewController.h"
#import "SSJReportFormsUtil.h"

#warning test
#import "SSJDataSynchronizer.h"

static NSString *const kIncomeAndPayCellID = @"incomeAndPayCellID";

static NSString *const kSegmentTitlePay = @"支出";
static NSString *const kSegmentTitleIncome = @"收入";
static NSString *const kSegmentTitleSurplus = @"结余";

@interface SSJReportFormsViewController () <UITableViewDataSource, UITableViewDelegate, SSJReportFormsPercentCircleDataSource>

//  周期选择控件（月、年）
@property (nonatomic, strong) SSJReportFormsPeriodSelectionView *periodSelectionView;

//  收入、支出、结余切换控件
@property (nonatomic, strong) SSJSegmentedControl *segmentControl;

//  切换年份、月份控件
@property (nonatomic, strong) SSJReportFormsSwitchYearControl *switchDateControl;

//  月份收支图表
@property (nonatomic, strong) SSJReportFormsPercentCircle *chartView;

//  结余金额视图
@property (nonatomic, strong) SSJReportFormsSurplusView *surplusView;

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
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = self.segmentControl;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reportForms_filter"] style:UIBarButtonItemStylePlain target:self action:@selector(filterAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationController.navigationBar.tintColor = [UIColor ssj_colorWithHex:@"#47cfbe"];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.switchDateControl];
    
    [self.tableView registerClass:[SSJReportFormsIncomeAndPayCell class] forCellReuseIdentifier:kIncomeAndPayCellID];
    
    [self updateSurplusViewTitle];
    [self updateSwithDateControlTitle];
    
    [self setTestItem];
}

#warning test
- (void)setTestItem {
    UIBarButtonItem *testItem = [[UIBarButtonItem alloc] initWithTitle:@"test" style:UIBarButtonItemStylePlain target:self action:@selector(testAction)];
    self.navigationItem.leftBarButtonItem = testItem;
}

- (void)testAction {
    [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:^{
        NSLog(@"success");
    } failure:^(NSError *error) {
        UIAlertView *aler = [[UIAlertView alloc] initWithTitle:@"error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [aler show];
        NSLog(@"%@", error);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadDatas];
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
        billingChargeVC.color = [UIColor ssj_colorWithHex:item.colorValue];
        if (self.periodSelectionView.periodType == SSJReportFormsPeriodTypeMonth) {
            billingChargeVC.month = self.calendarUtil.month;
        }
        [self.navigationController pushViewController:billingChargeVC animated:YES];
    }
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
}

#pragma mark - Event
- (void)filterAction {
    if ([self.periodSelectionView isShowed]) {
        [self.periodSelectionView dismiss:YES];
    } else {
       [self.periodSelectionView showInView:self.view fromTop:self.navigationController.navigationBar.bottom animated:YES];
    }
}

- (void)segmentControlValueDidChange {
    [self.periodSelectionView dismiss:YES];
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

- (void)switchDateControlPreAction {
    switch (self.periodSelectionView.periodType) {
        case SSJReportFormsPeriodTypeMonth:
            [self.calendarUtil preMonth];
            break;
            
        case SSJReportFormsPeriodTypeYear:
            [self.calendarUtil preYear];
            break;
    }
    [self updateSwithDateControlTitle];
    [self reloadDatas];
    [self updateSwitchDateControlNextBtnState];
}

- (void)switchDateControlNextAction {
    switch (self.periodSelectionView.periodType) {
        case SSJReportFormsPeriodTypeMonth:
            [self.calendarUtil nextMonth];
            break;
            
        case SSJReportFormsPeriodTypeYear:
            [self.calendarUtil nextYear];
            break;
    }
    [self updateSwithDateControlTitle];
    [self reloadDatas];
    [self updateSwitchDateControlNextBtnState];
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
    
    switch (self.periodSelectionView.periodType) {
        case SSJReportFormsPeriodTypeMonth:
//            [title appendFormat:@"%d月",(int)self.calendarUtil.month];
            [title appendFormat:@"%d年%d月", (int)self.calendarUtil.year, (int)self.calendarUtil.month];
            break;
            
        case SSJReportFormsPeriodTypeYear:
            [title appendFormat:@"%d年",(int)self.calendarUtil.year];
            break;
    }
    
    NSString *selectedTitle = [self.segmentControl titleForSegmentAtIndex:self.segmentControl.selectedSegmentIndex];
    if ([selectedTitle isEqualToString:kSegmentTitlePay]) {
        [title appendString:@"支出明细图表"];
    } else if ([selectedTitle isEqualToString:kSegmentTitleIncome]) {
        [title appendString:@"收入明细图表"];
    } else if ([selectedTitle isEqualToString:kSegmentTitleSurplus]) {
        [title appendString:@"收支结余明细图表"];
    }
    
    self.switchDateControl.title = title;
}

//  更新结余标题
- (void)updateSurplusViewTitle {
    switch (self.periodSelectionView.periodType) {
        case SSJReportFormsPeriodTypeMonth:
            [self.surplusView setTitle:[NSString stringWithFormat:@"%d月结余",(int)self.calendarUtil.month]];
            break;
            
        case SSJReportFormsPeriodTypeYear:
            [self.surplusView setTitle:[NSString stringWithFormat:@"%d年结余",(int)self.calendarUtil.year]];
            break;
    }
}

//  更新切换日期空间按钮状态
- (void)updateSwitchDateControlNextBtnState {
    if (self.calendarUtil.year == self.calendarUtil.currentYear
        && self.calendarUtil.month == self.calendarUtil.currentMonth) {
        self.switchDateControl.nextBtn.enabled = NO;
    } else {
        self.switchDateControl.nextBtn.enabled = YES;
    }
}

//  重新加载数据
- (void)reloadDatas {
    [self.view ssj_showLoadingIndicator];
    
    NSInteger month = 0;
    if (self.periodSelectionView.periodType == SSJReportFormsPeriodTypeMonth) {
        month = self.calendarUtil.month;
    }
    
    [SSJReportFormsDatabaseUtil queryForIncomeOrPayType:[self currentType] inYear:self.calendarUtil.year month:month success:^(NSArray<SSJReportFormsItem *> *result) {
        
        [self.view ssj_hideLoadingIndicator];
        
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
                circleItem.additionalText = [NSString stringWithFormat:@"%.0f％", item.scale * 100];
                [self.circleItems addObject:circleItem];
                
            } else if ([selectedTitle isEqualToString:kSegmentTitleSurplus]) {
                //  结余，结余最多只有收入、支出两种类型
                NSUInteger index = [result indexOfObject:item];
                if (index <= 1) {
                    SSJReportFormsPercentCircleItem *circleItem = [[SSJReportFormsPercentCircleItem alloc] init];
                    circleItem.scale = item.scale / scaleAmount;
                    circleItem.imageName = item.imageName;
                    circleItem.colorValue = item.colorValue;
                    circleItem.additionalText = [NSString stringWithFormat:@"%.0f％", item.scale * 100];
                    [self.circleItems addObject:circleItem];
                }
            }
        }
        
        [self.chartView reloadData];
        
        if (!self.datas.count) {
            self.tableView.hidden = YES;
            [self.view ssj_showWatermarkWithImageName:@"reportForm_empty" animated:YES target:nil action:nil];
        } else {
            self.tableView.hidden = NO;
            [self.view ssj_hideWatermark:YES];
        }
        
        NSString *selectedTitle = [self.segmentControl titleForSegmentAtIndex:self.segmentControl.selectedSegmentIndex];
        if ([selectedTitle isEqualToString:kSegmentTitleSurplus]) {
            double pay = ((SSJReportFormsItem *)[result ssj_safeObjectAtIndex:0]).money;
            double income = ((SSJReportFormsItem *)[result ssj_safeObjectAtIndex:1]).money;
            [self.surplusView setIncome:income pay:pay];
        }
        
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        
        NSString *message = [error localizedDescription].length ? [error localizedDescription] : SSJ_ERROR_MESSAGE;
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:message action:[SSJAlertViewAction actionWithTitle:@"确认" handler:NULL], nil];
    }];
}

#pragma mark - Getter
- (SSJReportFormsPeriodSelectionView *)periodSelectionView {
    if (!_periodSelectionView) {
        __weak typeof(self) weakSelf = self;
        _periodSelectionView = [[SSJReportFormsPeriodSelectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 110)];
        _periodSelectionView.selectionHandler = ^(SSJReportFormsPeriodSelectionView *view, SSJReportFormsPeriodType periodType) {
            [view dismiss:YES];
            [weakSelf reloadDatas];
            [weakSelf updateSwithDateControlTitle];
        };
    }
    return _periodSelectionView;
}

- (SSJSegmentedControl *)segmentControl {
    if (!_segmentControl) {
        _segmentControl = [[SSJSegmentedControl alloc] initWithItems:@[kSegmentTitlePay,kSegmentTitleIncome,kSegmentTitleSurplus]];
        _segmentControl.font = [UIFont systemFontOfSize:18];
        _segmentControl.tintColor = [UIColor ssj_colorWithHex:@"#cccccc"];
        [_segmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"#47cfbe"]} forState:UIControlStateSelected];
        [_segmentControl addTarget:self action:@selector(segmentControlValueDidChange) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentControl;
}

- (SSJReportFormsSwitchYearControl *)switchDateControl {
    if (!_switchDateControl) {
        _switchDateControl = [[SSJReportFormsSwitchYearControl alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.bottom, self.view.width, 40)];
        _switchDateControl.backgroundColor = [UIColor ssj_colorWithHex:@"#f6f6f6"];
        [_switchDateControl.preBtn addTarget:self action:@selector(switchDateControlPreAction) forControlEvents:UIControlEventTouchUpInside];
        [_switchDateControl.nextBtn addTarget:self action:@selector(switchDateControlNextAction) forControlEvents:UIControlEventTouchUpInside];
        [self updateSwitchDateControlNextBtnState];
    }
    return _switchDateControl;
}

- (SSJReportFormsPercentCircle *)chartView {
    if (!_chartView) {
        _chartView = [[SSJReportFormsPercentCircle alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 247) insets:UIEdgeInsetsMake(30, 80, 60, 80) thickness:39];
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
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.rowHeight = 55;
        _tableView.sectionHeaderHeight = 0;
        _tableView.sectionFooterHeight = 0;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorColor = SSJ_DEFAULT_SEPARATOR_COLOR;
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.contentInset = UIEdgeInsetsMake(self.switchDateControl.bottom, 0, self.tabBarController.tabBar.height, 0);
        _tableView.tableHeaderView = self.chartView;
    }
    return _tableView;
}

@end
