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
#import "SCYSlidePagingHeaderView.h"
#import "SSJReportFormsSurplusView.h"
#import "SSJReportFormsIncomeAndPayCell.h"
#import "SSJReportFormsScaleAxisView.h"

#import "SSJBillingChargeViewController.h"
#import "SSJMagicExportCalendarViewController.h"
#import "SSJReportFormsCurveViewController.h"
#import "SSJReportFormsUtil.h"
#import "SSJUserTableManager.h"

static NSString *const kIncomeAndPayCellID = @"incomeAndPayCellID";

static NSString *const kSegmentTitlePay = @"支出";
static NSString *const kSegmentTitleIncome = @"收入";
static NSString *const kSegmentTitleSurplus = @"结余";

@interface SSJReportFormsViewController () <UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate, SSJReportFormsPercentCircleDataSource, SSJReportFormsScaleAxisViewDelegate, SCYSlidePagingHeaderViewDelegate>

//  收入、支出、结余切换控件
@property (nonatomic, strong) SCYSlidePagingHeaderView *segmentControl;

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

//  自定义时间
@property (nonatomic, strong) UILabel *customPeriodLab;

//  编辑、删除自定义时间按钮
@property (nonatomic, strong) UIButton *customPeriodBtn;

//  数据源
@property (nonatomic, strong) NSArray *datas;

//  日期切换刻度控件的数据源
@property (nonatomic, strong) NSArray *periods;

//  圆环图表数据源
@property (nonatomic, strong) NSMutableArray *circleItems;

//  选中的时间周期
@property (nonatomic, strong) SSJDatePeriod *selectedPeriod;

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
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarController.delegate = self;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reportForms_curve"] style:UIBarButtonItemStylePlain target:self action:@selector(enterCurveVewController)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.navigationItem.titleView = self.segmentControl;
    
    [self.view addSubview:self.dateAxisView];
    [self.view addSubview:self.customPeriodLab];
    [self.view addSubview:self.customPeriodBtn];
    [self.view addSubview:self.tableView];
    
    UIView *headerView = [[UIView alloc] initWithFrame:self.chartView.frame];
    [headerView addSubview:self.chartView];
    [headerView addSubview:self.incomeAndPaymentTitleLab];
    [headerView addSubview:self.incomeAndPaymentMoneyLab];
    
    self.tableView.tableHeaderView = headerView;
    [self.tableView registerClass:[SSJReportFormsIncomeAndPayCell class] forCellReuseIdentifier:kIncomeAndPayCellID];
    
    [self updateIncomeAndPaymentLabels];
    
    [self reloadDatas];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    
    [_tableView reloadData];
    
    _chartView.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    
    _segmentControl.titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _segmentControl.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    
    _dateAxisView.scaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _dateAxisView.selectedScaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    
    [_chartView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    [_surplusView updateThemeColor];
    
    if (_customPeriod) {
        [_customPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_edit"] forState:UIControlStateNormal];
    } else {
        [_customPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_delete"] forState:UIControlStateNormal];
    }
}

#pragma mark - UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *naviController = (UINavigationController *)viewController;
        if (naviController.topViewController == self) {
            [self reloadDatas];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *selectedTitle = [_segmentControl.titles ssj_safeObjectAtIndex:_segmentControl.selectedIndex];
    
    if ([selectedTitle isEqualToString:kSegmentTitlePay]
        || [selectedTitle isEqualToString:kSegmentTitleIncome]) {
        return self.datas.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJReportFormsIncomeAndPayCell *incomeAndPayCell = [tableView dequeueReusableCellWithIdentifier:kIncomeAndPayCellID forIndexPath:indexPath];
    incomeAndPayCell.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
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
        billingChargeVC.color = [UIColor ssj_colorWithHex:item.colorValue];
        billingChargeVC.period = _customPeriod ?: [_periods ssj_safeObjectAtIndex:_dateAxisView.selectedIndex];
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
        if (period.startDate.year != [NSDate date].year) {
            return [period.startDate formattedDateWithFormat:@"yyyy年M月"];
        }
        return [NSString stringWithFormat:@"%d月", (int)period.startDate.month];
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
    _selectedPeriod = [_periods ssj_safeObjectAtIndex:index];
    [self reloadDatasInPeriod:_selectedPeriod];
    [self updateSurplusViewTitle];
    
    [MobClick event:@"form_date_picked"];
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    [self reloadDatas];
    [self updateIncomeAndPaymentLabels];
    
    NSString *selectedTitle = [_segmentControl.titles ssj_safeObjectAtIndex:_segmentControl.selectedIndex];
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

#pragma mark - Event
//  切换周期（年、月）
- (void)enterCurveVewController {
    SSJReportFormsCurveViewController *curveVC = [[SSJReportFormsCurveViewController alloc] init];
    [self.navigationController pushViewController:curveVC animated:YES];
    
    [MobClick event:@"form_curve"];
}

- (void)customPeriodBtnAction {
    if (_customPeriod) {
        _customPeriod = nil;
        _dateAxisView.hidden = NO;
        _customPeriodLab.hidden = YES;
        [_customPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_edit"] forState:UIControlStateNormal];
        [self reloadDatas];
        
        [MobClick event:@"form_date_custom_delete"];
    } else {
        SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"currentBooksId"] forUserId:SSJUSERID()];
        
        if (!userItem.currentBooksId.length) {
            userItem.currentBooksId = SSJUSERID();
        }
        __weak typeof(self) wself = self;
        SSJMagicExportCalendarViewController *calendarVC = [[SSJMagicExportCalendarViewController alloc] init];
        calendarVC.title = @"自定义时间";
        calendarVC.billType = [self currentType];
        calendarVC.booksId = userItem.currentBooksId;
        calendarVC.completion = ^(NSDate *selectedBeginDate, NSDate *selectedEndDate) {
            wself.customPeriod = [SSJDatePeriod datePeriodWithStartDate:selectedBeginDate endDate:selectedEndDate];
            wself.dateAxisView.hidden = YES;
            wself.customPeriodLab.hidden = NO;
            [wself updateCustomPeriodLab];
            [wself.customPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_delete"] forState:UIControlStateNormal];
        };
        [self.navigationController pushViewController:calendarVC animated:YES];
        
        [MobClick event:@"form_date_custom"];
    }
}

- (void)reloadDataAfterSync {
    [self reloadDatas];
}

#pragma mark - Private
//  返回当前收支类型
- (SSJBillType)currentType {
    NSString *selectedTitle = [_segmentControl.titles ssj_safeObjectAtIndex:_segmentControl.selectedIndex];

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

- (void)updateCustomPeriodLab {
    NSString *startDateStr = [_customPeriod.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *endDateStr = [_customPeriod.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
    _customPeriodLab.text = [NSString stringWithFormat:@"%@－－%@", startDateStr, endDateStr];
    CGSize textSize = [_customPeriodLab.text sizeWithAttributes:@{NSFontAttributeName:_customPeriodLab.font}];
    _customPeriodLab.width = textSize.width + 28;
    _customPeriodLab.centerX = self.view.width * 0.5;
}

//  更新总收入\总支出
- (void)updateIncomeAndPaymentLabels {
    if (_segmentControl.selectedIndex == 0) {
        _incomeAndPaymentTitleLab.hidden = _incomeAndPaymentMoneyLab.hidden = NO;
        _incomeAndPaymentTitleLab.text = @"总支出";
    } else if (_segmentControl.selectedIndex == 1) {
        _incomeAndPaymentTitleLab.hidden = _incomeAndPaymentMoneyLab.hidden = NO;
        _incomeAndPaymentTitleLab.text = @"总收入";
    } else if (_segmentControl.selectedIndex == 2) {
        _incomeAndPaymentTitleLab.hidden = _incomeAndPaymentMoneyLab.hidden = YES;
    }
}

//  计算总收入\支出
- (void)caculateIncomeOrPayment {
    if (_segmentControl.selectedIndex == 0
        || _segmentControl.selectedIndex == 1) {
        
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
    
    [SSJReportFormsUtil queryForPeriodListWithIncomeOrPayType:[self currentType] success:^(NSArray<SSJDatePeriod *> *periods) {
        
        if (periods.count == 0) {
            _dateAxisView.hidden = YES;
            _customPeriodLab.hidden = YES;
            _customPeriodBtn.hidden = YES;
            self.tableView.hidden = YES;
            
            [self.view ssj_hideLoadingIndicator];
            [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
            
            return;
        }
        
        _dateAxisView.hidden = NO;
        _customPeriodLab.hidden = !_customPeriod;
        _customPeriodBtn.hidden = NO;
        self.tableView.hidden = NO;
        [self.view ssj_hideWatermark:YES];
        
        _periods = periods;
        [_dateAxisView reloadData];
        
        if (_periods.count >= 2) {
            _dateAxisView.selectedIndex = _periods.count - 2;
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
    
    [SSJReportFormsUtil queryForIncomeOrPayType:[self currentType] startDate:period.startDate endDate:period.endDate success:^(NSArray<SSJReportFormsItem *> *result) {
        
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
            NSString *selectedTitle = [_segmentControl.titles ssj_safeObjectAtIndex:_segmentControl.selectedIndex];
            
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
        
        NSString *selectedTitle = [_segmentControl.titles ssj_safeObjectAtIndex:_segmentControl.selectedIndex];
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
- (SCYSlidePagingHeaderView *)segmentControl {
    if (!_segmentControl) {
        _segmentControl = [[SCYSlidePagingHeaderView alloc] initWithFrame:CGRectMake(0, 0, 225, 44)];
        _segmentControl.backgroundColor = [UIColor clearColor];
        _segmentControl.customDelegate = self;
        _segmentControl.buttonClickAnimated = YES;
        _segmentControl.titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _segmentControl.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        [_segmentControl setTabSize:CGSizeMake(75, 2)];
        _segmentControl.titles = @[kSegmentTitlePay, kSegmentTitleIncome, kSegmentTitleSurplus];
    }
    return _segmentControl;
}

- (SSJReportFormsScaleAxisView *)dateAxisView {
    if (!_dateAxisView) {
        _dateAxisView = [[SSJReportFormsScaleAxisView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, 50)];
        _dateAxisView.backgroundColor = [UIColor clearColor];
        _dateAxisView.scaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _dateAxisView.selectedScaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        _dateAxisView.delegate = self;
    }
    return _dateAxisView;
}

- (SSJPercentCircleView *)chartView {
    if (!_chartView) {
        _chartView = [[SSJPercentCircleView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 320) insets:UIEdgeInsetsMake(80, 80, 80, 80) thickness:39];
        _chartView.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        _chartView.dataSource = self;
        [_chartView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        [_chartView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_chartView ssj_setBorderWidth:1];
    }
    return _chartView;
}

- (SSJReportFormsSurplusView *)surplusView {
    if (!_surplusView) {
        _surplusView = [[SSJReportFormsSurplusView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 185)];
        _surplusView.backgroundColor = [UIColor clearColor];
        [_surplusView updateThemeColor];
    }
    return _surplusView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.dateAxisView.bottom, self.view.width, self.view.height - self.dateAxisView.bottom - SSJ_TABBAR_HEIGHT) style:UITableViewStylePlain];
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

- (UIImageView *)noDataRemindView {
    if (!_noDataRemindView) {
        _noDataRemindView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reportForms_nodata"]];
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

- (UILabel *)customPeriodLab {
    if (!_customPeriodLab) {
        _customPeriodLab = [[UILabel alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM + 10, 0, 30)];
        _customPeriodLab.backgroundColor = [UIColor clearColor];
        _customPeriodLab.textAlignment = NSTextAlignmentCenter;
        _customPeriodLab.font = [UIFont systemFontOfSize:15];
        _customPeriodLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _customPeriodLab.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor].CGColor;
        _customPeriodLab.layer.borderWidth = 1;
        _customPeriodLab.layer.cornerRadius = 15;
        _customPeriodLab.hidden = YES;
    }
    return _customPeriodLab;
}

- (UIButton *)customPeriodBtn {
    if (!_customPeriodBtn) {
        _customPeriodBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _customPeriodBtn.frame = CGRectMake(self.view.width - 50, SSJ_NAVIBAR_BOTTOM, 50, 50);
        [_customPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_edit"] forState:UIControlStateNormal];
        [_customPeriodBtn addTarget:self action:@selector(customPeriodBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _customPeriodBtn;
}

@end
