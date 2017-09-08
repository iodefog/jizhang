//
//  SSJReportFormsViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/11.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJReportFormsViewController.h"
#import "SSJNavigationController.h"
#import "SSJBillingChargeViewController.h"
#import "SSJMagicExportCalendarViewController.h"
#import "SSJReportFormsBillTypeDetailViewController.h"
#import "UIViewController+MMDrawerController.h"

#import "SSJPercentCircleView.h"
#import "SSJPageControl.h"
#import "SSJReportFormsIncomeAndPayCell.h"
#import "SSJReportFormsChartCell.h"
#import "SSJReportFormCurveListCell.h"
#import "SSJReportFormsNoDataCell.h"
#import "SSJBudgetNodataRemindView.h"
#import "SCYSlidePagingHeaderView.h"
#import "SSJSegmentedControl.h"
#import "SSJReportFormCurveHeaderView.h"
#import "SSJReportFormsPeriodSelectionControl.h"
#import "SSJReportFormsNavigationBar.h"

#import "SSJReportFormsUtil.h"
#import "SSJUserTableManager.h"
#import "SSJBooksTypeStore.h"
#import "SSJReportFormsCurveModel.h"
#import "SSJReportFormsSurplusCell.h"

static NSString *const kChartViewCellID = @"kChartViewCellID";
static NSString *const kSSJReportFormCurveCellID = @"kSSJReportFormCurveCellID";
static NSString *const kIncomeAndPayCellID = @"incomeAndPayCellID";
static NSString *const kSurplusCellID = @"SurplusCellID";
static NSString *const kNoDataRemindCellID = @"kNoDataRemindCellID";
static NSString *const kSSJReportFormStatisticsCellID = @"kSSJReportFormStatisticsCellID";
static NSString *const kSSJReportFormCurveListCellID = @"kSSJReportFormCurveListCellID";

static NSString *const kSegmentTitlePay = @"支出";
static NSString *const kSegmentTitleIncome = @"收入";
static NSString *const kSegmentTitleSurplus = @"结余";

@interface SSJReportFormsViewController () <UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate, SCYSlidePagingHeaderViewDelegate>

@property (nonatomic, strong) SSJReportFormsNavigationBar *navigationBar;

@property (nonatomic, strong) SSJReportFormsPeriodSelectionControl *periodControl;

//  收入、支出、结余切换控件
@property (nonatomic, strong) SCYSlidePagingHeaderView *payIncomeSurplusControl;

//  没有流水的提示视图
@property (nonatomic, strong) SSJBudgetNodataRemindView *noDataRemindView;

@property (nonatomic, strong) SSJReportFormCurveHeaderView *curveHeaderView;

//  流水列表视图
@property (nonatomic, strong) UITableView *tableView;

//  当前账本id
@property (nonatomic, strong) NSObject<SSJBooksItemProtocol> *currentBooksItem;

//  tableview数据源
@property (nonatomic, strong) NSMutableArray *datas;

@property (nonatomic, strong) SSJReportFormCurveHeaderViewItem *curveHeaderItem;

//  选择的成员／类别
@property (nonatomic) SSJReportFormsMemberAndCategoryOption selectedOption;

@end

@implementation SSJReportFormsViewController

#pragma mark - Lifecycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.statisticsTitle = @"报表首页";
        _datas = [[NSMutableArray alloc] init];
        _curveHeaderItem = [[SSJReportFormCurveHeaderViewItem alloc] init];
        _curveHeaderItem.timeDimension = SSJTimeDimensionMonth;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.showNavigationBarBaseLine = NO;
        self.hidesNavigationBarWhenPushed = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAllDatas) name:SSJBooksTypeDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.navigationBar];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.periodControl];
    [self updateAppearance];
    [self updateSubveiwsHidden];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadAllDatas];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.navigationBar.frame = CGRectMake(0, 0, self.view.width, 64);
    self.periodControl.frame = CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, 40);
//    self.payIncomeSurplusControl.frame = CGRectMake(0, 0, self.view.width, 40);
    self.tableView.frame = CGRectMake(0, self.periodControl.bottom, self.view.width, self.view.height - self.periodControl.bottom - SSJ_TABBAR_HEIGHT);
    self.noDataRemindView.frame = CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM - SSJ_STATUSBAR_HEIGHT);
}

#pragma mark - Overwrite
- (void)reloadDataAfterSync {
    [self reloadAllDatas];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [_tableView reloadData];
    [self updateAppearance];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseCellItem *item = [self.datas ssj_safeObjectAtIndex:indexPath.row];
    
    if ([item isKindOfClass:[SSJReportFormsChartCellItem class]]) {
        SSJReportFormsChartCell *chartCell = [tableView dequeueReusableCellWithIdentifier:kChartViewCellID forIndexPath:indexPath];
        chartCell.cellItem = item;
        chartCell.option = _selectedOption;
        __weak typeof(self) wself = self;
        chartCell.selectOptionHandle = ^(SSJReportFormsChartCell *cell) {
            wself.selectedOption = cell.option;
            [wself reloadDatasInPeriod:wself.periodControl.selectedPeriod];
            
            switch (wself.selectedOption) {
                case SSJReportFormsMemberAndCategoryOptionCategory:
                    [SSJAnaliyticsManager event:@"form_category"];
                    break;
                    
                case SSJReportFormsMemberAndCategoryOptionMember:
                    [SSJAnaliyticsManager event:@"form_member"];
                    break;
            }
        };
        return chartCell;
    }
    
    if ([item isKindOfClass:[SSJReportFormsItem class]]) {
        SSJReportFormsIncomeAndPayCell *incomeAndPayCell = [tableView dequeueReusableCellWithIdentifier:kIncomeAndPayCellID forIndexPath:indexPath];
        incomeAndPayCell.cellItem = item;
        return incomeAndPayCell;
    }
    
    if ([item isKindOfClass:[SSJReportFormCurveListCellItem class]]) {
        SSJReportFormCurveListCell *curveListCell = [tableView dequeueReusableCellWithIdentifier:kSSJReportFormCurveListCellID forIndexPath:indexPath];
        curveListCell.cellItem = item;
        return curveListCell;
    }
    
    if ([item isKindOfClass:[SSJReportFormsSurplusCellItem class]]) {
        SSJReportFormsSurplusCell *surplusCell = [tableView dequeueReusableCellWithIdentifier:kSurplusCellID forIndexPath:indexPath];
        surplusCell.cellItem = item;
        return surplusCell;
    }
    
    if ([item isKindOfClass:[SSJReportFormsNoDataCellItem class]]) {
        SSJReportFormsNoDataCell *noDataRemindCell = [tableView dequeueReusableCellWithIdentifier:kNoDataRemindCellID forIndexPath:indexPath];
        noDataRemindCell.cellItem = item;
        return noDataRemindCell;
    }
    
    return [UITableViewCell new];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [SSJAnaliyticsManager event:@"forms_bar_chart"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![self.currentBooksItem isKindOfClass:[SSJBooksTypeItem class]]
        && ![self.currentBooksItem isKindOfClass:[SSJShareBookItem class]]) {
        [SSJAlertViewAdapter showError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"未定义当前账本模型类对应的行为"}]];
        return;
    }
    
    BOOL isShareBook = [self.currentBooksItem isKindOfClass:[SSJShareBookItem class]];
    
    SSJBaseCellItem *item = [self.datas ssj_safeObjectAtIndex:indexPath.row];
    
    if ([item isKindOfClass:[SSJReportFormsItem class]]) {
        SSJReportFormsItem *tmpItem = (SSJReportFormsItem *)item;
        SSJBillingChargeViewController *billingChargeVC = [[SSJBillingChargeViewController alloc] init];
        billingChargeVC.period = _periodControl.currentPeriod;
        billingChargeVC.billType = [self currentType];
        if (tmpItem.isMember) {
            billingChargeVC.title = tmpItem.name;
            billingChargeVC.memberId = tmpItem.ID;
        } else {
            if (isShareBook) {
                billingChargeVC.billName = tmpItem.name;
                billingChargeVC.memberId = SSJAllMembersId;
            } else {
                billingChargeVC.billId = tmpItem.ID;
            }
        }
        [self.navigationController pushViewController:billingChargeVC animated:YES];
        
        if (tmpItem.isMember) {
            [SSJAnaliyticsManager event:@"form_member_detail"];
        }
    } else if ([item isKindOfClass:[SSJReportFormCurveListCellItem class]]) {
        SSJReportFormCurveListCellItem *curveListItem = (SSJReportFormCurveListCellItem *)item;
        SSJReportFormsBillTypeDetailViewController *billTypeDetailController = [[SSJReportFormsBillTypeDetailViewController alloc] init];
        if (isShareBook) {
            billTypeDetailController.billName = curveListItem.leftTitle1;
        } else {
            billTypeDetailController.billTypeID = curveListItem.billTypeId;
        }
        billTypeDetailController.billType = [self currentType];
        billTypeDetailController.title = curveListItem.leftTitle1;
        billTypeDetailController.colorValue = curveListItem.progressColorValue;
        billTypeDetailController.customPeriod = _periodControl.customPeriod;
        billTypeDetailController.selectedPeriod = _periodControl.selectedPeriod;
        [self.navigationController pushViewController:billTypeDetailController animated:YES];
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.payIncomeSurplusControl;
    }
    return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseCellItem *item = [self.datas ssj_safeObjectAtIndex:indexPath.row];
    return item.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 40;
        return self.payIncomeSurplusControl.height;
    }
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    SSJDatePeriod *period = _periodControl.currentPeriod;
    switch (self.navigationBar.option) {
        case SSJReportFormsNavigationBarChart:
            [self reloadDatasInPeriod:period];
            break;
            
        case SSJReportFormsNavigationBarCurve:
            [SSJReportFormsUtil queryForIncomeOrPayType:[self currentType] booksId:self.currentBooksItem.booksId startDate:period.startDate endDate:period.endDate success:^(NSArray<SSJReportFormsItem *> *list) {
                [self reorganiseCurveTableDataWithOriginalData:list];
            } failure:^(NSError *error) {
                [SSJAlertViewAdapter showError:error];
                [self.view ssj_hideLoadingIndicator];
            }];
            break;
    }
    
    switch ([self currentType]) {
        case SSJBillTypeIncome:
            [SSJAnaliyticsManager event:@"form_in"];
            break;
            
        case SSJBillTypePay:
            [SSJAnaliyticsManager event:@"form_out"];
            break;
            
        case SSJBillTypeSurplus:
            
            break;
            
        case SSJBillTypeUnknown:
            [SSJAlertViewAdapter showError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"无效参数：SSJBillTypeUnknown"}]];
            break;
    }
}

#pragma mark - Private
//  重新加载数据
- (void)reloadAllDatas {
    [self.view ssj_showLoadingIndicator];
    [SSJBooksTypeStore queryCurrentBooksItemWithSuccess:^(NSObject<SSJBooksItemProtocol> *booksItem) {
        self.currentBooksItem = booksItem;
        [self.navigationBar setBooksImage:[UIImage imageNamed:booksItem.parentIcon]];
        [self.navigationBar setBooksColor:[UIColor ssj_colorWithHex:booksItem.getSingleColor]];
        
        [SSJReportFormsUtil queryForPeriodListWithIncomeOrPayType:SSJBillTypeSurplus booksId:self.currentBooksItem.booksId success:^(NSArray<SSJDatePeriod *> *periods) {
            
            _periodControl.periods = periods;
            // 当前没有选中的周期 或者 选中的周期不在周期列表中
            if (periods.count >= 3
                && (!_periodControl.selectedPeriod
                 || (_periodControl.selectedPeriod
                     && ![periods containsObject:_periodControl.selectedPeriod]))) {
                _periodControl.selectedPeriod = periods[periods.count - 3];
            }
            
            [self updateSubveiwsHidden];
            
            if (periods.count == 0) {
                [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
            } else {
                [self.view ssj_hideWatermark:YES];
            }
            
            [self reloadDatasInPeriod:_periodControl.currentPeriod];
            [self.view ssj_hideLoadingIndicator];
            
        } failure:^(NSError *error) {
            [self.view ssj_hideLoadingIndicator];
            [SSJAlertViewAdapter showError:error];
        }];
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showError:error];
    }];
}

// 查询某个周期内的流水统计
- (void)reloadDatasInPeriod:(SSJDatePeriod *)period {
    if (!period) {
        return;
    }
    switch (self.navigationBar.option) {
        case SSJReportFormsNavigationBarChart: {
            [self.datas removeAllObjects];
            [self.tableView reloadData];
            self.tableView.tableHeaderView = nil;
            [self.tableView ssj_showLoadingIndicator];
            
            switch (_selectedOption) {
                case SSJReportFormsMemberAndCategoryOptionCategory: {
                    [SSJReportFormsUtil queryForIncomeOrPayType:[self currentType] booksId:self.currentBooksItem.booksId startDate:period.startDate endDate:period.endDate success:^(NSArray<SSJReportFormsItem *> *result) {
                        [self.tableView ssj_hideLoadingIndicator];
                        [self reorganiseChartTableVieDatasWithOriginalData:result];
                        [self.tableView reloadData];
                    } failure:^(NSError *error) {
                        [SSJAlertViewAdapter showError:error];
                        [self.tableView ssj_hideLoadingIndicator];
                    }];
                }
                    break;
                    
                case SSJReportFormsMemberAndCategoryOptionMember: {
                    [self.tableView ssj_showLoadingIndicator];
                    [SSJReportFormsUtil queryForMemberChargeWithType:[self currentType] booksId:nil startDate:period.startDate endDate:period.endDate success:^(NSArray<SSJReportFormsItem *> *result) {
                        [self.tableView ssj_hideLoadingIndicator];
                        [self reorganiseChartTableVieDatasWithOriginalData:result];
                        [self.tableView reloadData];
                    } failure:^(NSError *error) {
                        [SSJAlertViewAdapter showError:error];
                        [self.tableView ssj_hideLoadingIndicator];
                    }];
                }
                    break;
            }
        }
            break;
            
        case SSJReportFormsNavigationBarCurve: {
            [self.datas removeAllObjects];
            [self.tableView reloadData];
            self.tableView.tableHeaderView = self.curveHeaderView;
            
            [self.curveHeaderView showLoadingOnSeparatorForm];
            [self.curveHeaderView showLoadingOnCurve];
            
            [SSJReportFormsUtil queryForDefaultTimeDimensionWithStartDate:period.startDate endDate:period.endDate booksId:self.currentBooksItem.booksId billId:nil success:^(SSJTimeDimension timeDimension) {
                
                if (timeDimension != SSJTimeDimensionUnknown) {
                    self.curveHeaderItem.timeDimension = timeDimension;
                }
                
                [SSJReportFormsUtil queryForBillStatisticsWithTimeDimension:self.curveHeaderItem.timeDimension booksId:self.currentBooksItem.booksId billId:nil startDate:period.startDate endDate:period.endDate success:^(NSDictionary *result) {
                    
                    [self updateCurveHeaderItemWithCurveModels:result[SSJReportFormsCurveModelListKey] period:period];
                    
                    [SSJReportFormsUtil queryForIncomeOrPayType:[self currentType] booksId:self.currentBooksItem.booksId startDate:period.startDate endDate:period.endDate success:^(NSArray<SSJReportFormsItem *> *list) {
                        
                        [self.curveHeaderView hideLoadingOnSeparatorForm];
                        [self.curveHeaderView hideLoadingOnCurve];
                        
                        self.curveHeaderView.item = _curveHeaderItem;
                        
                        if (_curveHeaderItem.curveModels.count == 0) {
                            self.tableView.tableHeaderView = nil;
                        }
                        
                        [self reorganiseCurveTableDataWithOriginalData:list];
                        
                    } failure:^(NSError *error) {
                        [SSJAlertViewAdapter showError:error];
                        [self.curveHeaderView hideLoadingOnSeparatorForm];
                        [self.curveHeaderView hideLoadingOnCurve];
                    }];
                    
                } failure:^(NSError *error) {
                    [SSJAlertViewAdapter showError:error];
                    [self.curveHeaderView hideLoadingOnSeparatorForm];
                    [self.curveHeaderView hideLoadingOnCurve];
                }];
                
            } failure:^(NSError *error) {
                [SSJAlertViewAdapter showError:error];
                [self.curveHeaderView hideLoadingOnSeparatorForm];
                [self.curveHeaderView hideLoadingOnCurve];
            }];
        }
            break;
    }
}

- (void)updateSubveiwsHidden {
    if (self.periodControl.periods.count) {
        self.periodControl.hidden = NO;
        self.tableView.hidden = NO;
    } else {
        self.periodControl.hidden = YES;
        self.tableView.hidden = YES;
    }
}

- (void)updatePayIncomeSurplusControlTitles {
    switch (self.navigationBar.option) {
        case SSJReportFormsNavigationBarChart:
            _payIncomeSurplusControl.titles = @[kSegmentTitlePay, kSegmentTitleIncome, kSegmentTitleSurplus];
            [_payIncomeSurplusControl setTabSize:CGSizeMake(_payIncomeSurplusControl.width * 0.33, 3)];
            break;
            
        case SSJReportFormsNavigationBarCurve:
            _payIncomeSurplusControl.titles = @[kSegmentTitlePay, kSegmentTitleIncome];
            [_payIncomeSurplusControl setTabSize:CGSizeMake(_payIncomeSurplusControl.width * 0.5, 3)];
            break;
    }
}

- (void)updateCurveHeaderItemWithCurveModels:(NSArray<SSJReportFormsCurveModel *> *)curveModels period:(SSJDatePeriod *)period {
    double income = 0;
    double payment = 0;
    for (SSJReportFormsCurveModel *model in curveModels) {
        income += model.income;
        payment += model.payment;
    }
    
    int dayCount = dayCount = [period.endDate timeIntervalSinceDate:period.startDate] / (24 * 60 * 60);
    dayCount ++;
    double dailyCost = payment / dayCount;
    
    _curveHeaderItem.curveModels = curveModels;
    _curveHeaderItem.generalIncome = [[NSString stringWithFormat:@"%f", income] ssj_moneyDecimalDisplayWithDigits:2];
    _curveHeaderItem.generalPayment = [[NSString stringWithFormat:@"%f", payment] ssj_moneyDecimalDisplayWithDigits:2];
    _curveHeaderItem.dailyCost = [[NSString stringWithFormat:@"%f", dailyCost] ssj_moneyDecimalDisplayWithDigits:2];
}

- (void)reorganiseChartTableVieDatasWithOriginalData:(NSArray<SSJReportFormsItem *> *)result {
    [self.datas removeAllObjects];
    
    if (result.count == 0) {
        SSJReportFormsNoDataCellItem *remindItem = [[SSJReportFormsNoDataCellItem alloc] init];
        remindItem.remindDesc = @"暂无数据";
        [self.datas addObject:remindItem];
        [self.tableView reloadData];
        return;
    }
    
    // 将比例小于0.01的item过滤掉
    NSMutableArray *filterItems = [NSMutableArray array];
    double scaleAmount = 0;
    for (SSJReportFormsItem *item in result) {
        if (item.scale >= 0.01) {
            [filterItems addObject:item];
            scaleAmount += item.scale;
        }
    }
    
    //----------------------------------- 组织饼图数据 -----------------------------------//
    NSMutableArray *chartItems = [[NSMutableArray alloc] init];
    for (SSJReportFormsItem *item in filterItems) {
        //  收入、支出
        SSJPercentCircleViewItem *circleItem = [[SSJPercentCircleViewItem alloc] init];
        circleItem.scale = item.scale / scaleAmount;
        circleItem.color = [UIColor ssj_colorWithHex:item.colorValue];
        circleItem.text = [NSString stringWithFormat:@"%@ %.0f％", item.name, item.scale * 100];
        circleItem.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        [chartItems addObject:circleItem];
    }
    
    if (chartItems.count) {
        SSJReportFormsChartCellItem *chartCellItem = [[SSJReportFormsChartCellItem alloc] init];
        chartCellItem.chartItems = chartItems;
        switch ([self currentType]) {
            case SSJBillTypePay: {
                chartCellItem.title = @"总支出";
                double amount = [[result valueForKeyPath:@"@sum.money"] doubleValue];
                chartCellItem.amount = [[NSString stringWithFormat:@"%f", amount] ssj_moneyDecimalDisplayWithDigits:2];
            }
                break;
                
            case SSJBillTypeIncome: {
                chartCellItem.title = @"总收入";
                double amount = [[result valueForKeyPath:@"@sum.money"] doubleValue];
                chartCellItem.amount = [[NSString stringWithFormat:@"%f", amount] ssj_moneyDecimalDisplayWithDigits:2];
            }
                break;
                
            case SSJBillTypeSurplus: {
                chartCellItem.title = @"结余";
                double payment = 0;
                double income = 0;
                for (SSJReportFormsItem *item in result) {
                    if (item.type == SSJReportFormsTypePayment) {
                        payment += item.money;
                    } else {
                        income += item.money;
                    }
                }
                chartCellItem.amount = [[NSString stringWithFormat:@"%f", (income - payment)] ssj_moneyDecimalDisplayWithDigits:2];
            }
                break;
                
            case SSJBillTypeUnknown:
                [SSJAlertViewAdapter showError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"组织数据发生错误，无效参数：SSJBillTypeUnknown"}]];
                break;
        }
        
        [self.datas addObject:chartCellItem];
    }
    //----------------------------------------------------------------------------------------//
    
    
    //--------------------------------------- 组织列表数据 --------------------------------------//
    switch ([self currentType]) {
        case SSJBillTypePay:
        case SSJBillTypeIncome: {
            //  将datas按照收支类型所占比例从大到小进行排序
            NSArray *listItems = [result sortedArrayUsingComparator:^NSComparisonResult(SSJReportFormsItem *item1, SSJReportFormsItem *item2) {
                if (item1.scale > item2.scale) {
                    return NSOrderedAscending;
                } else if (item1.scale < item2.scale) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }];
            [self.datas addObjectsFromArray:listItems];
        }
            break;
            
        case SSJBillTypeSurplus: {
            double payment = 0;
            double income = 0;
            for (SSJReportFormsItem *item in result) {
                if (item.type == SSJReportFormsTypePayment) {
                    payment += item.money;
                } else {
                    income += item.money;
                }
            }
            SSJReportFormsSurplusCellItem *surplusItem = [[SSJReportFormsSurplusCellItem alloc] init];
            if (self.periodControl.customPeriod) {
                surplusItem.title = @"期间结余";
            } else {
                if (self.periodControl.selectedPeriod.periodType == SSJDatePeriodTypeMonth) {
                    surplusItem.title = [self.periodControl.selectedPeriod.startDate formattedDateWithFormat:@"yyyy年MM月结余"];
                } else if (self.periodControl.selectedPeriod.periodType == SSJDatePeriodTypeYear) {
                    surplusItem.title = [self.periodControl.selectedPeriod.startDate formattedDateWithFormat:@"yyyy年结余"];
                } else if (self.periodControl.selectedPeriod.periodType == SSJDatePeriodTypeCustom) {
                    surplusItem.title = @"总结余";
                } else {
                    [SSJAlertViewAdapter showError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"组织数据发生错误，无效的时间周期类型：%d", (int)self.periodControl.selectedPeriod.periodType]}]];
                }
            }
            surplusItem.payment = payment;
            surplusItem.income = income;
            [self.datas addObject:surplusItem];
        }
            break;
            
        case SSJBillTypeUnknown: {
            [SSJAlertViewAdapter showError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"组织数据发生错误，无效参数：SSJBillTypeUnknown"}]];
        }
            break;
    }
    //----------------------------------------------------------------------------------------//
}

// 组织折线图下方的列表数据
- (void)reorganiseCurveTableDataWithOriginalData:(NSArray<SSJReportFormsItem *> *)result {
    [self.datas removeAllObjects];
    
    if (result.count == 0) {
        SSJReportFormsNoDataCellItem *remindItem = [[SSJReportFormsNoDataCellItem alloc] init];
        remindItem.remindDesc = @"暂无数据";
        [self.datas addObject:remindItem];
        [self.tableView reloadData];
        return;
    }
    
    //  将datas按照收支类型所占比例从大到小进行排序
    NSArray *sortedItems = [result sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        SSJReportFormsItem *item1 = obj1;
        SSJReportFormsItem *item2 = obj2;
        if (item1.money > item2.money) {
            return NSOrderedAscending;
        } else if (item1.money < item2.money) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    SSJReportFormsItem *firstItem = [sortedItems firstObject];
    double maxMoney = firstItem.money;
    
    for (SSJReportFormsItem *item in sortedItems) {
        SSJReportFormCurveListCellItem *curveListItem = [[SSJReportFormCurveListCellItem alloc] init];
        curveListItem.leftTitle1 = item.name;
        curveListItem.leftTitle2 = [NSString stringWithFormat:@"%.1f％", item.scale * 100];
        curveListItem.rightTitle = [[NSString stringWithFormat:@"%f", item.money] ssj_moneyDecimalDisplayWithDigits:2];
        curveListItem.progressColorValue = item.colorValue;
        curveListItem.scale = item.money / maxMoney;
        curveListItem.billTypeId = item.ID;
        [self.datas addObject:curveListItem];
    }
    
    [self.tableView reloadData];
}

- (void)updateAppearance {
    [self.navigationBar updateAppearance];
    self.payIncomeSurplusControl.titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.payIncomeSurplusControl.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    self.payIncomeSurplusControl.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    [self.payIncomeSurplusControl ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    [self.periodControl updateAppearance];
    self.tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    
    [self.curveHeaderView updateAppearanceAccordingToTheme];
    [self.noDataRemindView updateAppearance];
}

//  返回当前收支类型
- (SSJBillType)currentType {
    NSString *selectedTitle = [self.payIncomeSurplusControl.titles ssj_safeObjectAtIndex:self.payIncomeSurplusControl.selectedIndex];
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

- (void)enterCalendarVC {
    __weak typeof(self) wself = self;
    SSJMagicExportCalendarViewController *calendarVC = [[SSJMagicExportCalendarViewController alloc] init];
    calendarVC.title = @"自定义时间";
    switch (self.navigationBar.option) {
        case SSJReportFormsNavigationBarChart:
            calendarVC.billType = [self currentType];
            break;
            
        case SSJReportFormsNavigationBarCurve:
            calendarVC.billType = SSJBillTypeSurplus;
            break;
    }
    calendarVC.userId = SSJAllMembersId;
    calendarVC.booksId = self.currentBooksItem.booksId;
    calendarVC.completion = ^(NSDate *selectedBeginDate, NSDate *selectedEndDate) {
        wself.periodControl.customPeriod = [SSJDatePeriod datePeriodWithStartDate:selectedBeginDate endDate:selectedEndDate];
    };
    [self.navigationController pushViewController:calendarVC animated:YES];
    
    [SSJAnaliyticsManager event:@"form_date_custom"];
}

#pragma mark - LazyLoading
- (SSJReportFormsNavigationBar *)navigationBar {
    if (!_navigationBar) {
        __weak typeof(self) wself = self;
        _navigationBar = [[SSJReportFormsNavigationBar alloc] init];
        _navigationBar.switchChartAndCurveHandler = ^(SSJReportFormsNavigationBar *bar) {
            [wself updatePayIncomeSurplusControlTitles];
            [wself reloadDatasInPeriod:wself.periodControl.currentPeriod];
        };
        _navigationBar.clickBooksHandler = ^(SSJReportFormsNavigationBar *bar) {
            [SSJAnaliyticsManager event:@"forms_open_account_books"];
            [wself.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:NULL];
        };
    }
    return _navigationBar;
}

- (SSJReportFormsPeriodSelectionControl *)periodControl {
    if (!_periodControl) {
        __weak typeof(self) wself = self;
        _periodControl = [[SSJReportFormsPeriodSelectionControl alloc] init];
        _periodControl.periodChangeHandler = ^(SSJReportFormsPeriodSelectionControl *control) {
            [wself reloadDatasInPeriod:control.selectedPeriod];
            [SSJAnaliyticsManager event:@"form_date_picked"];
        };
        _periodControl.addCustomPeriodHandler = ^(SSJReportFormsPeriodSelectionControl *control) {
            [wself enterCalendarVC];
        };
        _periodControl.clearCustomPeriodHandler = ^(SSJReportFormsPeriodSelectionControl *control) {
            [wself reloadDatasInPeriod:control.selectedPeriod];
            [SSJAnaliyticsManager event:@"form_date_custom_delete"];
        };
    }
    return _periodControl;
}

- (SCYSlidePagingHeaderView *)payIncomeSurplusControl {
    if (!_payIncomeSurplusControl) {
        _payIncomeSurplusControl = [[SCYSlidePagingHeaderView alloc] init];
        _payIncomeSurplusControl.customDelegate = self;
        _payIncomeSurplusControl.buttonClickAnimated = YES;
        [_payIncomeSurplusControl ssj_setBorderWidth:1];
        [_payIncomeSurplusControl ssj_setBorderStyle:SSJBorderStyleBottom];
        [self updatePayIncomeSurplusControlTitles];
    }
    return _payIncomeSurplusControl;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 55;
        _tableView.sectionHeaderHeight = 0;
        _tableView.sectionFooterHeight = 0;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView registerClass:[SSJReportFormsChartCell class] forCellReuseIdentifier:kChartViewCellID];
        [_tableView registerClass:[SSJReportFormsIncomeAndPayCell class] forCellReuseIdentifier:kIncomeAndPayCellID];
        [_tableView registerClass:[SSJReportFormsSurplusCell class] forCellReuseIdentifier:kSurplusCellID];
        [_tableView registerClass:[SSJReportFormCurveListCell class] forCellReuseIdentifier:kSSJReportFormCurveListCellID];
        [_tableView registerClass:[SSJReportFormsNoDataCell class] forCellReuseIdentifier:kNoDataRemindCellID];
    }
    return _tableView;
}

- (SSJBudgetNodataRemindView *)noDataRemindView {
    if (!_noDataRemindView) {
        _noDataRemindView = [[SSJBudgetNodataRemindView alloc] init];
        _noDataRemindView.image = @"budget_no_data";
        _noDataRemindView.title = @"报表空空如也";
    }
    return _noDataRemindView;
}

- (SSJReportFormCurveHeaderView *)curveHeaderView {
    if (!_curveHeaderView) {
        __weak typeof(self) wself = self;
        _curveHeaderView = [[SSJReportFormCurveHeaderView alloc] init];
        _curveHeaderView.changeTimePeriodHandle = ^(SSJReportFormCurveHeaderView *view) {
            SSJDatePeriod *period = wself.periodControl.currentPeriod;
            
            [wself.curveHeaderView showLoadingOnCurve];
            [SSJReportFormsUtil queryForBillStatisticsWithTimeDimension:view.item.timeDimension booksId:wself.currentBooksItem.booksId billId:nil startDate:period.startDate endDate:period.endDate success:^(NSDictionary *result) {
                
                [wself.curveHeaderView hideLoadingOnCurve];
                
                [wself updateCurveHeaderItemWithCurveModels:result[SSJReportFormsCurveModelListKey] period:period];
                wself.curveHeaderView.item = wself.curveHeaderItem;
                
            } failure:^(NSError *error) {
                [SSJAlertViewAdapter showError:error];
                [wself.curveHeaderView hideLoadingOnCurve];
            }];
            
            switch (view.item.timeDimension) {
                case SSJTimeDimensionDay:
                    [SSJAnaliyticsManager event:@"form_curve_day"];
                    break;
                    
                case SSJTimeDimensionWeek:
                    [SSJAnaliyticsManager event:@"form_curve_week"];
                    break;
                    
                case SSJTimeDimensionMonth:
                    [SSJAnaliyticsManager event:@"form_curve_month"];
                    break;
                    
                case SSJTimeDimensionUnknown:
                    break;
            }
        };
    }
    return _curveHeaderView;
}

@end
