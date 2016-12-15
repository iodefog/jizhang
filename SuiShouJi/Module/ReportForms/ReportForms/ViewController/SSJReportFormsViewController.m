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
#import "SSJReportFormsIncomeAndPayCell.h"
#import "SSJReportFormsChartCell.h"
#import "SSJReportFormCurveListCell.h"
#import "SSJReportFormsNoDataCell.h"

#import "SSJReportFormsScaleAxisView.h"
#import "SSJBudgetNodataRemindView.h"
#import "SCYSlidePagingHeaderView.h"
#import "SSJSegmentedControl.h"
#import "SSJListMenu.h"
#import "SSJReportFormCurveHeaderView.h"

#import "SSJBillingChargeViewController.h"
#import "SSJMagicExportCalendarViewController.h"
#import "SSJReportFormsCurveViewController.h"
#import "SSJReportFormsUtil.h"
#import "SSJUserTableManager.h"
#import "SSJBooksTypeStore.h"
#import "SSJReportFormsCurveModel.h"

static NSString *const kChartViewCellID = @"kChartViewCellID";
static NSString *const kSSJReportFormCurveCellID = @"kSSJReportFormCurveCellID";
static NSString *const kIncomeAndPayCellID = @"incomeAndPayCellID";
static NSString *const kNoDataRemindCellID = @"kNoDataRemindCellID";
static NSString *const kSSJReportFormStatisticsCellID = @"kSSJReportFormStatisticsCellID";
static NSString *const kSSJReportFormCurveListCellID = @"kSSJReportFormCurveListCellID";

static NSString *const kSegmentTitlePay = @"支出";
static NSString *const kSegmentTitleIncome = @"收入";
//static NSString *const kSegmentTitleSurplus = @"结余";

@interface SSJReportFormsViewController () <UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate, SSJReportFormsPercentCircleDataSource, SSJReportFormsScaleAxisViewDelegate, SCYSlidePagingHeaderViewDelegate>

//  饼图、折线图切换控件
@property (nonatomic, strong) SSJSegmentedControl *titleSegmentCtrl;

//  切换年份、月份控件
@property (nonatomic, strong) SSJReportFormsScaleAxisView *dateAxisView;

//  收入、支出切换控件
@property (nonatomic, strong) SCYSlidePagingHeaderView *payAndIncomeSegmentControl;

//  没有流水的提示视图
@property (nonatomic, strong) SSJBudgetNodataRemindView *noDataRemindView;

@property (nonatomic, strong) SSJReportFormCurveHeaderView *curveView;

//  流水列表视图
@property (nonatomic, strong) UITableView *tableView;

//  自定义时间
@property (nonatomic, strong) UIButton *customPeriodBtn;

//  编辑、删除自定义时间按钮
@property (nonatomic, strong) UIButton *addOrDeleteCustomPeriodBtn;

//  选择账本的下拉菜单
@property (nonatomic, strong) SSJListMenu *booksMenu;

//  当前账本id
@property (nonatomic, strong) NSString *currentBooksId;

//  账本id列表
@property (nonatomic, strong) NSArray *booksIds;

//  tableview数据源
@property (nonatomic, strong) NSMutableArray *datas;

//  日期切换刻度控件的数据源
@property (nonatomic, strong) NSArray *periods;

@property (nonatomic, strong) SSJReportFormCurveHeaderViewItem *curveHeaderItem;

//  自定义时间周期
@property (nonatomic, strong) SSJDatePeriod *customPeriod;

//  选择的成员／类别
@property (nonatomic) SSJReportFormsMemberAndCategoryOption selectedOption;

//  折线图的时间维度
@property (nonatomic) SSJTimeDimension timeDimension;

@end

@implementation SSJReportFormsViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.statisticsTitle = @"报表首页";
        self.datas = [[NSMutableArray alloc] init];
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
    
    self.navigationItem.titleView = self.titleSegmentCtrl;
    [self.view addSubview:self.dateAxisView];
    [self.view addSubview:self.customPeriodBtn];
    [self.view addSubview:self.addOrDeleteCustomPeriodBtn];
    [self.view addSubview:self.tableView];
    
    [self updateAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadDatas];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_booksMenu dismiss];
}

#pragma mark - Overwrite
- (void)reloadDataAfterSync {
    [self reloadDatas];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    
    [_tableView reloadData];
    [self updateAppearance];
}

#pragma mark - UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *naviController = (UINavigationController *)viewController;
        if (naviController.topViewController == self) {
            [self reloadAllDatas];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionArr = [self.datas ssj_safeObjectAtIndex:section];
    if ([sectionArr isKindOfClass:[NSArray class]]) {
        return sectionArr.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseItem *item = [self.datas ssj_objectAtIndexPath:indexPath];
    
    if ([item isKindOfClass:[SSJReportFormsChartCellItem class]]) {
        SSJReportFormsChartCell *chartCell = [tableView dequeueReusableCellWithIdentifier:kChartViewCellID forIndexPath:indexPath];
        chartCell.cellItem = item;
        chartCell.option = _selectedOption;
        __weak typeof(self) wself = self;
        chartCell.selectOptionHandle = ^(SSJReportFormsChartCell *cell) {
            wself.selectedOption = cell.option;
            [wself reloadDatas];
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
    
    if ([item isKindOfClass:[SSJReportFormsNoDataCellItem class]]) {
        SSJReportFormsNoDataCell *noDataRemindCell = [tableView dequeueReusableCellWithIdentifier:kNoDataRemindCellID forIndexPath:indexPath];
        noDataRemindCell.cellItem = item;
        return noDataRemindCell;
    }
    
    return [UITableViewCell new];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SSJBaseItem *item = [self.datas ssj_objectAtIndexPath:indexPath];
    
    if ([item isKindOfClass:[SSJReportFormsItem class]]) {
        SSJReportFormsItem *tmpItem = (SSJReportFormsItem *)item;
        SSJBillingChargeViewController *billingChargeVC = [[SSJBillingChargeViewController alloc] init];
        billingChargeVC.ID = tmpItem.ID;
        billingChargeVC.color = [UIColor ssj_colorWithHex:tmpItem.colorValue];
        billingChargeVC.period = _customPeriod ?: [_periods ssj_safeObjectAtIndex:_dateAxisView.selectedIndex];
        billingChargeVC.isMemberCharge = tmpItem.isMember;
        billingChargeVC.isPayment = _payAndIncomeSegmentControl.selectedIndex == 0;
        if (tmpItem.isMember) {
            billingChargeVC.title = tmpItem.name;
        }
        [self.navigationController pushViewController:billingChargeVC animated:YES];
        
        if (tmpItem.isMember) {
            [MobClick event:@"form_member_detail"];
        }
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (_titleSegmentCtrl.selectedSegmentIndex == 0 && section == 0) {
        return self.payAndIncomeSegmentControl;
    }
    
    if (_titleSegmentCtrl.selectedSegmentIndex == 1) {
        return nil;
    }
    
    return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseItem *item = [self.datas ssj_objectAtIndexPath:indexPath];
    return [item rowHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_titleSegmentCtrl.selectedSegmentIndex == 0 && section == 0) {
        return self.payAndIncomeSegmentControl.height;
    }
    
    if (_titleSegmentCtrl.selectedSegmentIndex == 1 && section == 2) {
        return self.payAndIncomeSegmentControl.height;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    [self reloadDatas];
    
    if (_payAndIncomeSegmentControl.selectedIndex == 0) {
        [MobClick event:@"form_out"];
    } else if (_payAndIncomeSegmentControl.selectedIndex == 1) {
        [MobClick event:@"form_in"];
    } else {
        
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
    [self reloadDatasInPeriod:[_periods ssj_safeObjectAtIndex:index]];
    [MobClick event:@"form_date_picked"];
}

#pragma mark - Event
- (void)titleSegmentCtrlAction {
    [self reloadDatas];
}

// 切换分类和成员
- (void)typeAndMemberControlAction {
    [self reloadDatas];
    
    switch (_selectedOption) {
        case SSJReportFormsMemberAndCategoryOptionCategory:
            [MobClick event:@"form_category"];
            break;
            
        case SSJReportFormsMemberAndCategoryOptionMember:
            [MobClick event:@"form_member"];
            break;
    }
}

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
        _customPeriodBtn.hidden = YES;
        [_addOrDeleteCustomPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_edit"] forState:UIControlStateNormal];
        [self reloadDatas];
        
        [MobClick event:@"form_date_custom_delete"];
    } else {
        [self enterCalendarVC];
    }
}

- (void)selectBookAction {
    _currentBooksId = [_booksIds ssj_safeObjectAtIndex:_booksMenu.selectedIndex];
    SSJSelectBooksType(_currentBooksId);
    [self reloadAllDatas];
    [self updateLfetItem];
}

- (void)showBooksMenuAction {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [_booksMenu showInView:window atPoint:CGPointMake(22, 60)];
}

#pragma mark - Private
// 如果当前是自定义时间，就查询自定义时间范围内的流水统计；反之就查询当前刻度时间的流水统计
- (void)reloadDatas {
    if (_customPeriod) {
        [self reloadDatasInPeriod:_customPeriod];
    } else if (_periods.count) {
        [self reloadDatasInPeriod:[_periods ssj_safeObjectAtIndex:_dateAxisView.selectedIndex]];
    } else {
        [self reloadAllDatas];
    }
}

//  重新加载数据
- (void)reloadAllDatas {
    
    [self.view ssj_showLoadingIndicator];
    
    [SSJBooksTypeStore queryForBooksListWithSuccess:^(NSMutableArray<SSJBooksTypeItem *> *bookItems) {
        
        _currentBooksId = SSJGetCurrentBooksType();
        [self reorganiseBooksDataWithOriginalData:bookItems];
        
        [SSJReportFormsUtil queryForPeriodListWithIncomeOrPayType:SSJBillTypeSurplus booksId:_currentBooksId success:^(NSArray<SSJDatePeriod *> *periods) {
            
            [self.view ssj_hideLoadingIndicator];
            
            [self reorganiseDateAxisViewDataWithOriginalData:periods];
            
            // 查询当前月份的流水统计
            [self reloadDatasInPeriod:[_periods ssj_safeObjectAtIndex:_dateAxisView.selectedIndex]];
            
        } failure:^(NSError *error) {
            [self.view ssj_hideLoadingIndicator];
            [self showError:error];
        }];
        
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [self showError:error];
    }];
}

// 查询某个周期内的流水统计
- (void)reloadDatasInPeriod:(SSJDatePeriod *)period {
    if (!period) {
        return;
    }
    
    if (_titleSegmentCtrl.selectedSegmentIndex == 0) {
        switch (_selectedOption) {
            case SSJReportFormsMemberAndCategoryOptionCategory: {
                [self.view ssj_showLoadingIndicator];
                [SSJReportFormsUtil queryForIncomeOrPayType:[self currentType] booksId:_currentBooksId startDate:period.startDate endDate:period.endDate success:^(NSArray<SSJReportFormsItem *> *result) {
                    [self.view ssj_hideLoadingIndicator];
                    [self reorganiseTableVieDatasWithOriginalData:result];
                } failure:^(NSError *error) {
                    [self showError:error];
                    [self.view ssj_hideLoadingIndicator];
                }];
            }
                break;
                
            case SSJReportFormsMemberAndCategoryOptionMember: {
                [self.view ssj_showLoadingIndicator];
                [SSJReportFormsUtil queryForMemberChargeWithType:[self currentType] startDate:period.startDate endDate:period.endDate success:^(NSArray<SSJReportFormsItem *> *result) {
                    [self.view ssj_hideLoadingIndicator];
                    [self reorganiseTableVieDatasWithOriginalData:result];
                } failure:^(NSError *error) {
                    [self showError:error];
                    [self.view ssj_hideLoadingIndicator];
                }];
            }
                break;
        }
    } else if (_titleSegmentCtrl.selectedSegmentIndex == 1) {
        [self.view ssj_showLoadingIndicator];
        [SSJReportFormsUtil queryForBillStatisticsWithType:_timeDimension startDate:period.startDate endDate:period.endDate booksId:nil success:^(NSDictionary *result) {
            
            [self.view ssj_hideLoadingIndicator];
            [self updateCurveHeaderItemWithCurveModels:result[SSJReportFormsCurveModelListKey] period:period];
            
            [SSJReportFormsUtil queryForIncomeOrPayType:[self currentType] booksId:_currentBooksId startDate:period.startDate endDate:period.endDate success:^(NSArray<SSJReportFormsItem *> *list) {
                [self.view ssj_hideLoadingIndicator];
                [self reorganiseTableVieDatasWithOriginalData:list];
            } failure:^(NSError *error) {
                [self showError:error];
                [self.view ssj_hideLoadingIndicator];
            }];
            
        } failure:^(NSError *error) {
            [self.view ssj_hideLoadingIndicator];
            [self showError:error];
        }];
    } else {
        
    }
}

- (void)updateCurveHeaderItemWithCurveModels:(NSArray<SSJReportFormsCurveModel *> *)curveModels period:(SSJDatePeriod *)period {
    double income = 0;
    double payment = 0;
    for (SSJReportFormsCurveModel *model in curveModels) {
        income += [model.income doubleValue];
        payment += [model.payment doubleValue];
    }
    
    int dayCount = dayCount = [period.endDate timeIntervalSinceDate:period.startDate] / (24 * 60 * 60);
    dayCount ++;
    double dailyCost = payment / dayCount;
    
    _curveHeaderItem.curveModels = curveModels;
    _curveHeaderItem.generalIncome = [[NSString stringWithFormat:@"%f", income] ssj_moneyDecimalDisplayWithDigits:2];
    _curveHeaderItem.generalPayment = [[NSString stringWithFormat:@"%f", payment] ssj_moneyDecimalDisplayWithDigits:2];
    _curveHeaderItem.dailyCost = [[NSString stringWithFormat:@"%f", dailyCost] ssj_moneyDecimalDisplayWithDigits:2];
}

// 组织账本数据
- (void)reorganiseBooksDataWithOriginalData:(NSMutableArray<SSJBooksTypeItem *> *)bookItems {
    NSInteger selectedIndex = 0;
    NSMutableArray *bookIds = [[NSMutableArray alloc] init];
    NSMutableArray *listItem = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < bookItems.count; i ++) {
        SSJBooksTypeItem *item = bookItems[i];
        if (item.booksId.length) {
            [bookIds addObject:item.booksId];
            [listItem addObject:[SSJListMenuItem itemWithImageName:item.booksIcoin title:item.booksName]];
            if ([item.booksId isEqualToString:_currentBooksId]) {
                selectedIndex = i;
            }
        }
    }
    
    _booksIds = [bookIds copy];
    self.booksMenu.items = listItem;
    self.booksMenu.selectedIndex = selectedIndex;
    
    [self updateLfetItem];
}

// 重新组织时间刻度控件的数据
- (void)reorganiseDateAxisViewDataWithOriginalData:(NSArray <SSJDatePeriod *>*)periods {
    _periods = periods;
    
    if (_periods.count == 0) {
        _dateAxisView.hidden = YES;
        _customPeriodBtn.hidden = YES;
        _addOrDeleteCustomPeriodBtn.hidden = YES;
        self.tableView.hidden = YES;
        
        [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
        
        return;
    }
    
    _dateAxisView.hidden = NO;
    _customPeriodBtn.hidden = !_customPeriod;
    _addOrDeleteCustomPeriodBtn.hidden = NO;
    self.tableView.hidden = NO;
    [self.view ssj_hideWatermark:YES];
    
    [_dateAxisView reloadData];
    
    if (_periods.count >= 3) {
        _dateAxisView.selectedIndex = _periods.count - 3;
    }
}

- (void)reorganiseTableVieDatasWithOriginalData:(NSArray<SSJReportFormsItem *> *)result {
    
    [self.datas removeAllObjects];
    
    NSMutableArray *sectionArr = [[NSMutableArray alloc] initWithCapacity:1];
    
    if (result.count == 0) {
        SSJReportFormsNoDataCellItem *remindItem = [[SSJReportFormsNoDataCellItem alloc] init];
        remindItem.remindDesc = @"暂无数据";
        [sectionArr addObject:remindItem];
        [self.datas addObject:sectionArr];
        
        [self.tableView reloadData];
        
        return;
    }
    
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
    NSMutableArray *chartItems = [[NSMutableArray alloc] init];
    for (SSJReportFormsItem *item in filterItems) {
        //  收入、支出
        SSJPercentCircleViewItem *circleItem = [[SSJPercentCircleViewItem alloc] init];
        circleItem.scale = item.scale / scaleAmount;
        circleItem.imageName = item.imageName;
        circleItem.colorValue = item.colorValue;
        circleItem.additionalText = [NSString stringWithFormat:@"%.0f％", item.scale * 100];
        circleItem.imageBorderShowed = YES;
        if (item.isMember) {
            circleItem.customView = [self chartAdditionalViewWithMemberName:item.name colorValue:item.colorValue];
        }
        [chartItems addObject:circleItem];
    }
    
    if (chartItems.count) {
        SSJReportFormsChartCellItem *chartCellItem = [[SSJReportFormsChartCellItem alloc] init];
        chartCellItem.chartItems = chartItems;
        if (_payAndIncomeSegmentControl.selectedIndex == 0) {
            chartCellItem.title = @"支出";
        } else if (_payAndIncomeSegmentControl.selectedIndex == 1) {
            chartCellItem.title = @"收入";
        }
        double amount = [[result valueForKeyPath:@"@sum.money"] doubleValue];
        chartCellItem.amount = [[NSString stringWithFormat:@"%f", amount] ssj_moneyDecimalDisplayWithDigits:2];
        [sectionArr addObject:chartCellItem];
    }
    
    //  将datas按照收支类型所占比例从大到小进行排序
    NSArray *cellItems = [result sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
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
    
    [sectionArr addObjectsFromArray:cellItems];
    [self.datas addObject:sectionArr];
    
    [self.tableView reloadData];
    
}

- (void)reorganiseCurveDataWith {
    
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

- (void)updateAppearance {
    
    self.titleSegmentCtrl.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.titleSegmentCtrl.selectedBorderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    [self.titleSegmentCtrl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]} forState:UIControlStateNormal];
    [self.titleSegmentCtrl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]} forState:UIControlStateSelected];
    
    self.payAndIncomeSegmentControl.titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.payAndIncomeSegmentControl.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    self.payAndIncomeSegmentControl.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    [self.payAndIncomeSegmentControl ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    self.dateAxisView.scaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.dateAxisView.selectedScaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    [self.dateAxisView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    self.tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    
    if (_customPeriod) {
        [self.addOrDeleteCustomPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_delete"] forState:UIControlStateNormal];
    } else {
        [self.addOrDeleteCustomPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_edit"] forState:UIControlStateNormal];
    }
    
    [self.noDataRemindView updateAppearance];
    
    self.booksMenu.normalTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.booksMenu.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    self.booksMenu.fillColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
    self.booksMenu.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    self.booksMenu.normalImageColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.booksMenu.selectedImageColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
}

//  返回当前收支类型
- (SSJBillType)currentType {
    if (self.payAndIncomeSegmentControl.selectedIndex == 0) {
        return SSJBillTypePay;
    } else if (self.payAndIncomeSegmentControl.selectedIndex == 1) {
        return SSJBillTypeIncome;
    } else {
        return SSJBillTypeUnknown;
    }
}

- (void)updateCustomPeriodBtn {
    NSString *startDateStr = [_customPeriod.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *endDateStr = [_customPeriod.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *title = [NSString stringWithFormat:@"%@－－%@", startDateStr, endDateStr];
    [_customPeriodBtn setTitle:title forState:UIControlStateNormal];
    CGSize textSize = [title sizeWithAttributes:@{NSFontAttributeName:_customPeriodBtn.titleLabel.font}];
    _customPeriodBtn.width = textSize.width + 28;
    _customPeriodBtn.centerX = self.view.width * 0.5;
}

- (UILabel *)chartAdditionalViewWithMemberName:(NSString *)name colorValue:(NSString *)colorValue {
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    lab.layer.borderColor = [UIColor ssj_colorWithHex:colorValue].CGColor;
    lab.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    lab.layer.cornerRadius = lab.width * 0.5;
    lab.text = name.length >= 1 ? [name substringToIndex:1] : @"";
    lab.textColor = [UIColor ssj_colorWithHex:colorValue];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.font = [UIFont systemFontOfSize:16];
    
    return lab;
}

- (void)enterCalendarVC {
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
        wself.customPeriodBtn.hidden = NO;
        [wself updateCustomPeriodBtn];
        [wself.addOrDeleteCustomPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_delete"] forState:UIControlStateNormal];
        [wself reloadDatas];
    };
    [self.navigationController pushViewController:calendarVC animated:YES];
    
    [MobClick event:@"form_date_custom"];
}

- (void)updateLfetItem {
    SSJListMenuItem *selectedItem = [_booksMenu.items ssj_safeObjectAtIndex:_booksMenu.selectedIndex];
    UIImage *image = [[UIImage imageNamed:selectedItem.imageName] ssj_compressWithinSize:CGSizeMake(22, 22)];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(showBooksMenuAction)];
    [self.navigationItem setLeftBarButtonItem:leftItem animated:YES];
}

#pragma mark - LazyLoading
- (SSJSegmentedControl *)titleSegmentCtrl {
    if (!_titleSegmentCtrl) {
        _titleSegmentCtrl = [[SSJSegmentedControl alloc] initWithItems:@[@"饼图",@"折线图"]];
        _titleSegmentCtrl.size = CGSizeMake(170, 24);
        [_titleSegmentCtrl addTarget:self action:@selector(titleSegmentCtrlAction) forControlEvents: UIControlEventValueChanged];
    }
    return _titleSegmentCtrl;
}

- (SSJReportFormsScaleAxisView *)dateAxisView {
    if (!_dateAxisView) {
        _dateAxisView = [[SSJReportFormsScaleAxisView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, 50)];
        _dateAxisView.backgroundColor = [UIColor clearColor];
        _dateAxisView.scaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _dateAxisView.selectedScaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        _dateAxisView.delegate = self;
        [_dateAxisView ssj_setBorderWidth:1];
        [_dateAxisView ssj_setBorderStyle:(SSJBorderStyleBottom)];
        [_dateAxisView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    }
    return _dateAxisView;
}

- (SCYSlidePagingHeaderView *)payAndIncomeSegmentControl {
    if (!_payAndIncomeSegmentControl) {
        _payAndIncomeSegmentControl = [[SCYSlidePagingHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
        _payAndIncomeSegmentControl.customDelegate = self;
        _payAndIncomeSegmentControl.buttonClickAnimated = YES;
        [_payAndIncomeSegmentControl setTabSize:CGSizeMake(_payAndIncomeSegmentControl.width * 0.5, 3)];
        _payAndIncomeSegmentControl.titles = @[kSegmentTitlePay, kSegmentTitleIncome];
        [_payAndIncomeSegmentControl ssj_setBorderWidth:1];
        [_payAndIncomeSegmentControl ssj_setBorderStyle:SSJBorderStyleBottom];
        
    }
    return _payAndIncomeSegmentControl;
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
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView registerClass:[SSJReportFormsChartCell class] forCellReuseIdentifier:kChartViewCellID];
        [_tableView registerClass:[SSJReportFormsIncomeAndPayCell class] forCellReuseIdentifier:kIncomeAndPayCellID];
        [_tableView registerClass:[SSJReportFormCurveListCell class] forCellReuseIdentifier:kSSJReportFormCurveListCellID];
        [_tableView registerClass:[SSJReportFormsNoDataCell class] forCellReuseIdentifier:kNoDataRemindCellID];
    }
    return _tableView;
}

- (SSJBudgetNodataRemindView *)noDataRemindView {
    if (!_noDataRemindView) {
        _noDataRemindView = [[SSJBudgetNodataRemindView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 260)];
        _noDataRemindView.image = @"budget_no_data";
        _noDataRemindView.title = @"报表空空如也";
    }
    return _noDataRemindView;
}

- (SSJReportFormCurveHeaderView *)curveView {
    if (!_curveView) {
        _curveView = [[SSJReportFormCurveHeaderView alloc] init];
    }
    return _curveView;
}

- (UIButton *)customPeriodBtn {
    if (!_customPeriodBtn) {
        _customPeriodBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _customPeriodBtn.frame = CGRectMake(0, self.dateAxisView.top + 10, 0, 30);
        _customPeriodBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _customPeriodBtn.layer.borderWidth = 1;
        _customPeriodBtn.layer.cornerRadius = 15;
        _customPeriodBtn.hidden = YES;
        [_customPeriodBtn addTarget:self action:@selector(enterCalendarVC) forControlEvents:UIControlEventTouchUpInside];
    }
    return _customPeriodBtn;
}

- (UIButton *)addOrDeleteCustomPeriodBtn {
    if (!_addOrDeleteCustomPeriodBtn) {
        _addOrDeleteCustomPeriodBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addOrDeleteCustomPeriodBtn.frame = CGRectMake(self.view.width - 50, self.dateAxisView.top, 50, 50);
        [_addOrDeleteCustomPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_edit"] forState:UIControlStateNormal];
        [_addOrDeleteCustomPeriodBtn addTarget:self action:@selector(customPeriodBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addOrDeleteCustomPeriodBtn;
}

- (SSJListMenu *)booksMenu {
    if (!_booksMenu) {
        _booksMenu = [[SSJListMenu alloc] initWithFrame:CGRectMake(0, 0, 156, 0)];
        _booksMenu.maxDisplayRowCount = 5.5;
        _booksMenu.imageSize = CGSizeMake(18, 18);
        [_booksMenu addTarget:self action:@selector(selectBookAction) forControlEvents:UIControlEventValueChanged];
    }
    return _booksMenu;
}

- (SSJReportFormCurveHeaderViewItem *)curveHeaderItem {
    if (!_curveHeaderItem) {
        _curveHeaderItem = [[SSJReportFormCurveHeaderViewItem alloc] init];
    }
    return _curveHeaderItem;
}

@end
