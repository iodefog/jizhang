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
#import "SSJReportFormsSurplusView.h"
#import "SSJReportFormsIncomeAndPayCell.h"
#import "SSJReportFormsChartCell.h"
#import "SSJReportFormsScaleAxisView.h"
#import "SSJBudgetNodataRemindView.h"
#import "SCYSlidePagingHeaderView.h"
#import "SSJSegmentedControl.h"
#import "SSJListMenu.h"

#import "SSJBillingChargeViewController.h"
#import "SSJMagicExportCalendarViewController.h"
#import "SSJReportFormsCurveViewController.h"
#import "SSJReportFormsUtil.h"
#import "SSJUserTableManager.h"
#import "SSJBooksTypeStore.h"

static NSString *const kChartViewCellID = @"kChartViewCellID";
static NSString *const kIncomeAndPayCellID = @"incomeAndPayCellID";

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

//  日、周、月切换控件
@property (nonatomic, strong) SCYSlidePagingHeaderView *timePeriodSegmentControl;

//  没有流水的提示视图
@property (nonatomic, strong) SSJBudgetNodataRemindView *noDataRemindView;

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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *selectedTitle = [_payAndIncomeSegmentControl.titles ssj_safeObjectAtIndex:_payAndIncomeSegmentControl.selectedIndex];
    
    if ([selectedTitle isEqualToString:kSegmentTitlePay]
        || [selectedTitle isEqualToString:kSegmentTitleIncome]) {
        return self.datas.count;
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
    
    return [UITableViewCell new];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.datas.count > indexPath.row) {
        SSJReportFormsItem *item = self.datas[indexPath.row];
        SSJBillingChargeViewController *billingChargeVC = [[SSJBillingChargeViewController alloc] init];
        billingChargeVC.ID = item.ID;
        billingChargeVC.color = [UIColor ssj_colorWithHex:item.colorValue];
        billingChargeVC.period = _customPeriod ?: [_periods ssj_safeObjectAtIndex:_dateAxisView.selectedIndex];
        billingChargeVC.isMemberCharge = item.isMember;
        billingChargeVC.isPayment = _payAndIncomeSegmentControl.selectedIndex == 0;
        if (item.isMember) {
            billingChargeVC.title = item.name;
        }
        [self.navigationController pushViewController:billingChargeVC animated:YES];
        
        if (item.isMember) {
            [MobClick event:@"form_member_detail"];
        }
    }
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    [self reloadDatas];
    
    NSString *selectedTitle = [_payAndIncomeSegmentControl.titles ssj_safeObjectAtIndex:_payAndIncomeSegmentControl.selectedIndex];
    
    if ([selectedTitle isEqualToString:kSegmentTitlePay]) {
        [MobClick event:@"form_out"];
    }else if ([selectedTitle isEqualToString:kSegmentTitleIncome]){
        [MobClick event:@"form_in"];
    }else{
        [MobClick event:@"form_total"];
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
//    [self reloadDatas];
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

#pragma mark - Overwrite
- (void)reloadDataAfterSync {
    [self reloadDatas];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    
    [_tableView reloadData];
    [self updateAppearance];
}

#pragma mark - Private
- (void)updateAppearance {
    
    _payAndIncomeSegmentControl.titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _payAndIncomeSegmentControl.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    _payAndIncomeSegmentControl.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    [_payAndIncomeSegmentControl ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    _dateAxisView.scaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _dateAxisView.selectedScaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    [_dateAxisView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    
    if (_customPeriod) {
        [_addOrDeleteCustomPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_delete"] forState:UIControlStateNormal];
    } else {
        [_addOrDeleteCustomPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_edit"] forState:UIControlStateNormal];
    }
    
    [_noDataRemindView updateAppearance];
    
    self.booksMenu.normalTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.booksMenu.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    self.booksMenu.fillColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
    self.booksMenu.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    self.booksMenu.normalImageColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.booksMenu.selectedImageColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
}

//  返回当前收支类型
- (SSJBillType)currentType {
    NSString *selectedTitle = [_payAndIncomeSegmentControl.titles ssj_safeObjectAtIndex:_payAndIncomeSegmentControl.selectedIndex];

    if ([selectedTitle isEqualToString:kSegmentTitlePay]) {
        return SSJBillTypePay;
    } else if ([selectedTitle isEqualToString:kSegmentTitleIncome]) {
        return SSJBillTypeIncome;
    }/* else if ([selectedTitle isEqualToString:kSegmentTitleSurplus]) {
        return SSJBillTypeSurplus;
    }*/ else {
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
        
        [SSJReportFormsUtil queryForPeriodListWithIncomeOrPayType:SSJBillTypeSurplus booksId:_currentBooksId success:^(NSArray<SSJDatePeriod *> *periods) {
            
            [self.view ssj_hideLoadingIndicator];
            
            // 组织账本数据
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
            
            if (periods.count == 0) {
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
            
            _periods = periods;
            [_dateAxisView reloadData];
            
            if (_periods.count >= 3) {
                _dateAxisView.selectedIndex = _periods.count - 3;
            }
            
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

- (void)showError:(NSError *)error {
    NSString *message = nil;
#ifdef DEBUG
    message = [error localizedDescription];
#else
    message = SSJ_ERROR_MESSAGE;
#endif
    [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:message action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
}

- (void)organiseDatasWithResult:(NSArray *)result {
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
    
    if (!self.datas.count) {
        self.tableView.hidden = YES;
        [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
    } else {
        self.tableView.hidden = NO;
        [self.view ssj_hideWatermark:YES];
    }
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

// 查询某个周期内的流水统计
- (void)reloadDatasInPeriod:(SSJDatePeriod *)period {
    if (!period) {
        return;
    }
    
    switch (_selectedOption) {
        case SSJReportFormsMemberAndCategoryOptionCategory: {
            [self.view ssj_showLoadingIndicator];
            [SSJReportFormsUtil queryForIncomeOrPayType:[self currentType] booksId:nil startDate:period.startDate endDate:period.endDate success:^(NSArray<SSJReportFormsItem *> *result) {
                [self.view ssj_hideLoadingIndicator];
                [self organiseDatasWithResult:result];
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
                [self organiseDatasWithResult:result];
            } failure:^(NSError *error) {
                [self showError:error];
                [self.view ssj_hideLoadingIndicator];
            }];
        }
            break;
    }
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

#pragma mark - Getter
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

- (SCYSlidePagingHeaderView *)timePeriodSegmentControl {
    if (!_timePeriodSegmentControl) {
        _timePeriodSegmentControl = [[SCYSlidePagingHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
        _timePeriodSegmentControl.customDelegate = self;
        _timePeriodSegmentControl.buttonClickAnimated = YES;
        [_timePeriodSegmentControl setTabSize:CGSizeMake(_payAndIncomeSegmentControl.width * 0.5, 3)];
        _timePeriodSegmentControl.titles = @[kSegmentTitlePay, kSegmentTitleIncome];
        [_timePeriodSegmentControl ssj_setBorderWidth:1];
        [_timePeriodSegmentControl ssj_setBorderStyle:SSJBorderStyleBottom];
    }
    return _timePeriodSegmentControl;
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
