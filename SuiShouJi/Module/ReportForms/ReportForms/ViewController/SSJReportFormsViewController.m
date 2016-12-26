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
#import "SSJReportFormsBillTypeDetailViewController.h"
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

@interface SSJReportFormsViewController () <UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate, SSJReportFormsScaleAxisViewDelegate, SCYSlidePagingHeaderViewDelegate>

//  饼图、折线图切换控件
@property (nonatomic, strong) SSJSegmentedControl *titleSegmentCtrl;

//  切换年份、月份控件
@property (nonatomic, strong) SSJReportFormsScaleAxisView *dateAxisView;

//  收入、支出切换控件
@property (nonatomic, strong) SCYSlidePagingHeaderView *payAndIncomeSegmentControl;

//  没有流水的提示视图
@property (nonatomic, strong) SSJBudgetNodataRemindView *noDataRemindView;

@property (nonatomic, strong) SSJReportFormCurveHeaderView *curveHeaderView;

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
@property (nonatomic, strong) NSArray<SSJDatePeriod *> *periods;

@property (nonatomic, strong) SSJReportFormCurveHeaderViewItem *curveHeaderItem;

//  选中的时间周期
@property (nonatomic, strong) SSJDatePeriod *selectedPeriod;

//  自定义时间周期
@property (nonatomic, strong) SSJDatePeriod *customPeriod;

//  选择的成员／类别
@property (nonatomic) SSJReportFormsMemberAndCategoryOption selectedOption;

@end

@implementation SSJReportFormsViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.statisticsTitle = @"报表首页";
        _datas = [[NSMutableArray alloc] init];
        _curveHeaderItem = [[SSJReportFormCurveHeaderViewItem alloc] init];
        _curveHeaderItem.timeDimension = SSJTimeDimensionMonth;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = self.titleSegmentCtrl;
    [self.view addSubview:self.dateAxisView];
    [self.view addSubview:self.customPeriodBtn];
    [self.view addSubview:self.addOrDeleteCustomPeriodBtn];
    [self.view addSubview:self.tableView];
    
    [self updateAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadAllDatas];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_booksMenu dismiss];
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
    SSJBaseItem *item = [self.datas ssj_safeObjectAtIndex:indexPath.row];
    
    if ([item isKindOfClass:[SSJReportFormsChartCellItem class]]) {
        SSJReportFormsChartCell *chartCell = [tableView dequeueReusableCellWithIdentifier:kChartViewCellID forIndexPath:indexPath];
        chartCell.cellItem = item;
        chartCell.option = _selectedOption;
        __weak typeof(self) wself = self;
        chartCell.selectOptionHandle = ^(SSJReportFormsChartCell *cell) {
            wself.selectedOption = cell.option;
            [wself reloadDatasInPeriod:wself.customPeriod ?: wself.selectedPeriod];
            
            switch (wself.selectedOption) {
                case SSJReportFormsMemberAndCategoryOptionCategory:
                    [MobClick event:@"form_category"];
                    break;
                    
                case SSJReportFormsMemberAndCategoryOptionMember:
                    [MobClick event:@"form_member"];
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
    
    SSJBaseItem *item = [self.datas ssj_safeObjectAtIndex:indexPath.row];
    
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
    } else if ([item isKindOfClass:[SSJReportFormCurveListCellItem class]]) {
        
        SSJReportFormCurveListCellItem *curveListItem = (SSJReportFormCurveListCellItem *)item;
        SSJReportFormsBillTypeDetailViewController *billTypeDetailController = [[SSJReportFormsBillTypeDetailViewController alloc] init];
        billTypeDetailController.billTypeID = curveListItem.billTypeId;
        billTypeDetailController.title = curveListItem.leftTitle1;
        billTypeDetailController.customPeriod = _customPeriod;
        billTypeDetailController.selectedPeriod = _selectedPeriod;
        [self.navigationController pushViewController:billTypeDetailController animated:YES];
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.payAndIncomeSegmentControl;
    }
    return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseItem *item = [self.datas ssj_safeObjectAtIndex:indexPath.row];
    return item.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.payAndIncomeSegmentControl.height;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    
    SSJDatePeriod *period = _customPeriod ?: _selectedPeriod;
    
    if (_titleSegmentCtrl.selectedSegmentIndex == 0) {
        
        [self reloadDatasInPeriod:period];
        
    } else if (_titleSegmentCtrl.selectedSegmentIndex == 1) {
        
        [SSJReportFormsUtil queryForIncomeOrPayType:[self currentType] booksId:_currentBooksId startDate:period.startDate endDate:period.endDate success:^(NSArray<SSJReportFormsItem *> *list) {
            [self reorganiseCurveTableDataWithOriginalData:list];
        } failure:^(NSError *error) {
            [self showError:error];
            [self.view ssj_hideLoadingIndicator];
        }];
    }
    
    if (_payAndIncomeSegmentControl.selectedIndex == 0) {
        [MobClick event:@"form_out"];
    } else if (_payAndIncomeSegmentControl.selectedIndex == 1) {
        [MobClick event:@"form_in"];
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
    _selectedPeriod = [_periods ssj_safeObjectAtIndex:index];
    [self reloadDatasInPeriod:_selectedPeriod];
    [MobClick event:@"form_date_picked"];
}

#pragma mark - Event
- (void)titleSegmentCtrlAction {
    [self reloadDatasInPeriod:_customPeriod ?: _selectedPeriod];
}

- (void)customPeriodBtnAction {
    if (_customPeriod) {
        
        _customPeriod = nil;
        _dateAxisView.hidden = NO;
        _customPeriodBtn.hidden = YES;
        
        [_addOrDeleteCustomPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_edit"] forState:UIControlStateNormal];
        
        [self reloadDatasInPeriod:_selectedPeriod];
        
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
//  重新加载数据
- (void)reloadAllDatas {
    
    [self.view ssj_showLoadingIndicator];
    
    [SSJBooksTypeStore queryForBooksListWithSuccess:^(NSMutableArray<SSJBooksTypeItem *> *bookItems) {
        
        _currentBooksId = SSJGetCurrentBooksType();
        [self reorganiseBooksDataWithOriginalData:bookItems];
        
        [SSJReportFormsUtil queryForPeriodListWithIncomeOrPayType:SSJBillTypeSurplus booksId:_currentBooksId success:^(NSArray<SSJDatePeriod *> *periods) {
            
            [self.view ssj_hideLoadingIndicator];
            
            _periods = periods;
            
            [self updateSubveiwsHidden];
            
            if (_periods.count > 0) {
                
                [_dateAxisView reloadData];
                
                NSUInteger selectedIndex = _selectedPeriod ? [_periods indexOfObject:_selectedPeriod] : NSNotFound;
                _dateAxisView.selectedIndex = (selectedIndex != NSNotFound) ? selectedIndex : _periods.count - 1;
                _selectedPeriod = [_periods ssj_safeObjectAtIndex:_dateAxisView.selectedIndex];
                
                [self reloadDatasInPeriod:(_customPeriod ?: _selectedPeriod)];
            }
            
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
        SSJPRINT(@"参数period不能为nil");
        return;
    }
    
    if (_titleSegmentCtrl.selectedSegmentIndex == 0) {
        switch (_selectedOption) {
            case SSJReportFormsMemberAndCategoryOptionCategory: {
                [self.view ssj_showLoadingIndicator];
                [SSJReportFormsUtil queryForIncomeOrPayType:[self currentType]
                                                    booksId:_currentBooksId
                                                  startDate:period.startDate
                                                    endDate:period.endDate
                                                    success:^(NSArray<SSJReportFormsItem *> *result) {
                    [self.view ssj_hideLoadingIndicator];
                    self.tableView.tableHeaderView = nil;
                    [self reorganiseChartTableVieDatasWithOriginalData:result];
                } failure:^(NSError *error) {
                    [self showError:error];
                    [self.view ssj_hideLoadingIndicator];
                }];
            }
                break;
                
            case SSJReportFormsMemberAndCategoryOptionMember: {
                [self.view ssj_showLoadingIndicator];
                [SSJReportFormsUtil queryForMemberChargeWithType:[self currentType]
                                                       startDate:period.startDate
                                                         endDate:period.endDate
                                                         success:^(NSArray<SSJReportFormsItem *> *result) {
                    [self.view ssj_hideLoadingIndicator];
                    self.tableView.tableHeaderView = nil;
                    [self reorganiseChartTableVieDatasWithOriginalData:result];
                } failure:^(NSError *error) {
                    [self showError:error];
                    [self.view ssj_hideLoadingIndicator];
                }];
            }
                break;
        }
    } else if (_titleSegmentCtrl.selectedSegmentIndex == 1) {
        [self.view ssj_showLoadingIndicator];
        
        [SSJReportFormsUtil queryForDefaultTimeDimensionWithStartDate:period.startDate endDate:period.endDate booksId:_currentBooksId billTypeId:nil success:^(SSJTimeDimension timeDimension) {
            
            if (timeDimension != SSJTimeDimensionUnknown) {
                self.curveHeaderItem.timeDimension = timeDimension;
            }
            
            [SSJReportFormsUtil queryForBillStatisticsWithTimeDimension:self.curveHeaderItem.timeDimension booksId:_currentBooksId billTypeId:nil startDate:period.startDate endDate:period.endDate success:^(NSDictionary *result) {
                
                [self updateCurveHeaderItemWithCurveModels:result[SSJReportFormsCurveModelListKey] period:period];
                
                [SSJReportFormsUtil queryForIncomeOrPayType:[self currentType] booksId:_currentBooksId startDate:period.startDate endDate:period.endDate success:^(NSArray<SSJReportFormsItem *> *list) {
                    
                    [self.view ssj_hideLoadingIndicator];
                    
                    self.curveHeaderView.item = _curveHeaderItem;
                    if (_curveHeaderItem.curveModels.count == 0) {
                        self.tableView.tableHeaderView = nil;
                    } else {
                        self.tableView.tableHeaderView = self.curveHeaderView;
                    }
                    
                    [self reorganiseCurveTableDataWithOriginalData:list];
                    
                } failure:^(NSError *error) {
                    [self showError:error];
                    [self.view ssj_hideLoadingIndicator];
                }];
                
            } failure:^(NSError *error) {
                [self.view ssj_hideLoadingIndicator];
                [self showError:error];
            }];
            
        } failure:^(NSError *error) {
            [self showError:error];
            [self.view ssj_hideLoadingIndicator];
        }];
    }
}

- (void)updateSubveiwsHidden {
    if (_periods.count == 0) {
        _dateAxisView.hidden = YES;
        _customPeriodBtn.hidden = YES;
        _addOrDeleteCustomPeriodBtn.hidden = YES;
        self.tableView.hidden = YES;
        
        [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
        
        return;
    }
    
    if (_customPeriod) {
        _dateAxisView.hidden = YES;
        _customPeriodBtn.hidden = NO;
    } else {
        _dateAxisView.hidden = NO;
        _customPeriodBtn.hidden = YES;
    }
    
    _addOrDeleteCustomPeriodBtn.hidden = NO;
    self.tableView.hidden = NO;
    [self.view ssj_hideWatermark:YES];
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

- (void)reorganiseChartTableVieDatasWithOriginalData:(NSArray<SSJReportFormsItem *> *)result {
    
    [self.datas removeAllObjects];
    
    if (result.count == 0) {
        SSJReportFormsNoDataCellItem *remindItem = [[SSJReportFormsNoDataCellItem alloc] init];
        remindItem.remindDesc = @"暂无数据";
        [self.datas addObject:remindItem];
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
        [self.datas addObject:chartCellItem];
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
    
    [self.datas addObjectsFromArray:cellItems];
    [self.tableView reloadData];
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
    
    double maxMoney = [[result valueForKeyPath:@"@max.money"] doubleValue];
    
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
    
    self.dateAxisView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    self.dateAxisView.scaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.dateAxisView.selectedScaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    [self.dateAxisView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    [self.customPeriodBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:UIControlStateNormal];
    self.customPeriodBtn.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor].CGColor;
    
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
        _dateAxisView.delegate = self;
        [_dateAxisView ssj_setBorderWidth:1];
        [_dateAxisView ssj_setBorderStyle:(SSJBorderStyleBottom)];
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

- (SSJReportFormCurveHeaderView *)curveHeaderView {
    if (!_curveHeaderView) {
        _curveHeaderView = [[SSJReportFormCurveHeaderView alloc] init];
        __weak typeof(self) wself = self;
        _curveHeaderView.changeTimePeriodHandle = ^(SSJReportFormCurveHeaderView *view) {
            SSJDatePeriod *period = wself.customPeriod ?: [wself.periods ssj_safeObjectAtIndex:wself.dateAxisView.selectedIndex];
            
            [SSJReportFormsUtil queryForBillStatisticsWithTimeDimension:view.item.timeDimension booksId:wself.currentBooksId billTypeId:nil startDate:period.startDate endDate:period.endDate success:^(NSDictionary *result) {
                
                [wself.view ssj_hideLoadingIndicator];
                [wself updateCurveHeaderItemWithCurveModels:result[SSJReportFormsCurveModelListKey] period:period];
                wself.curveHeaderView.item = wself.curveHeaderItem;
                
            } failure:^(NSError *error) {
                [wself.view ssj_hideLoadingIndicator];
                [wself showError:error];
            }];
            
            switch (view.item.timeDimension) {
                case SSJTimeDimensionDay:
                    [MobClick event:@"form_curve_day"];
                    break;
                    
                case SSJTimeDimensionWeek:
                    [MobClick event:@"form_curve_week"];
                    break;
                    
                case SSJTimeDimensionMonth:
                    [MobClick event:@"form_curve_month"];
                    break;
                    
                case SSJTimeDimensionUnknown:
                    break;
            }
        };
    }
    return _curveHeaderView;
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

@end
