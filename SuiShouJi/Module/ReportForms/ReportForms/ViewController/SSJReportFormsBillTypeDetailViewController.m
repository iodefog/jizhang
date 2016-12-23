//
//  SSJReportFormsBillTypeDetailViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/12/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsBillTypeDetailViewController.h"
#import "SSJReportFormsScaleAxisView.h"
#import "SCYSlidePagingHeaderView.h"
#import "SSJReportFormsCurveGraphView.h"
#import "SSJSeparatorFormView.h"
#import "SSJReportFormsCurveDescriptionView.h"
#import "SSJBudgetNodataRemindView.h"
#import "SSJReportFormCanYinChartCell.h"
#import "SSJReportFormsCurveModel.h"
#import "SSJDatePeriod.h"
#import "SSJReportFormsUtil.h"

static const CGFloat kSpaceHeight = 10;

static const CGFloat kTimePeriodSegmentControlHeight = 40;

static const CGFloat kCurveViewHeight = 350;

static const CGFloat kSeparatorFormViewHeight = 88;

static NSString *const kSSJReportFormCanYinChartCellId = @"kSSJReportFormCanYinChartCellId";

@interface SSJReportFormsBillTypeDetailViewController () <UITableViewDataSource, UITableViewDelegate, SSJReportFormsScaleAxisViewDelegate, SCYSlidePagingHeaderViewDelegate, SSJReportFormsCurveGraphViewDataSource, SSJReportFormsCurveGraphViewDelegate, SSJSeparatorFormViewDataSource>

//  自定义时间
@property (nonatomic, strong) UIButton *customPeriodBtn;

//  编辑、删除自定义时间按钮
@property (nonatomic, strong) UIButton *addOrDeleteCustomPeriodBtn;

//  切换年份、月份控件
@property (nonatomic, strong) SSJReportFormsScaleAxisView *dateAxisView;

@property (nonatomic, strong) SCYSlidePagingHeaderView *timeDemisionControl;

@property (nonatomic, strong) SSJReportFormsCurveGraphView *curveView;

@property (nonatomic, strong) SSJSeparatorFormView *separatorFormView;

@property (nonatomic, strong) UIView *headerView;

//  流水列表视图
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *questionBtn;

@property (nonatomic, strong) SSJReportFormsCurveDescriptionView *descView;

//  没有流水的提示视图
@property (nonatomic, strong) SSJBudgetNodataRemindView *noDataRemindView;

//  日期切换刻度控件的数据源
@property (nonatomic, strong) NSArray<SSJDatePeriod *> *periods;

@property (nonatomic, strong) NSArray<SSJReportFormsCurveModel *> *curveModels;

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic) SSJTimeDimension dimesion;

@property (nonatomic) BOOL isPayment;

@property (nonatomic, strong) NSString *colorValue;

@property (nonatomic) double maxValue;

@property (nonatomic) double amount;

@property (nonatomic) double average;

@end

@implementation SSJReportFormsBillTypeDetailViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        _dimesion = SSJTimeDimensionMonth;
        _items = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.customPeriodBtn];
    [self.view addSubview:self.addOrDeleteCustomPeriodBtn];
    [self.view addSubview:self.dateAxisView];
    [self.view addSubview:self.tableView];
    
    self.tableView.tableHeaderView = self.headerView;
    [self.headerView addSubview:self.timeDemisionControl];
    [self.headerView addSubview:self.curveView];
    [self.headerView addSubview:self.separatorFormView];
    
    [self updateAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view ssj_showLoadingIndicator];
    
    _isPayment = [SSJReportFormsUtil isPaymentWithBillTypeId:_billTypeID];
    _colorValue = [SSJReportFormsUtil billTypeColorWithBillTypeId:_billTypeID];
    
    [SSJReportFormsUtil queryForPeriodListWithIncomeOrPayType:SSJBillTypeSurplus booksId:nil success:^(NSArray<SSJDatePeriod *> *periods) {
        
        [self.view ssj_hideLoadingIndicator];
        
        _periods = periods;
        
        [self updateSubveiwsHidden];
        
        if (_periods.count > 0) {
            
            [_dateAxisView reloadData];
            
            NSUInteger selectedIndex = _selectedPeriod ? [_periods indexOfObject:_selectedPeriod] : NSNotFound;
            _dateAxisView.selectedIndex = (selectedIndex != NSNotFound) ? selectedIndex : _periods.count - 1;
            _selectedPeriod = [_periods ssj_safeObjectAtIndex:_dateAxisView.selectedIndex];
            
            [self reloadDataInCurrentPeriod];
        }
        
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [self showError:error];
    }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    _dateAxisView.frame = CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, 50);
    _separatorFormView.frame = CGRectMake(0, kSpaceHeight, self.view.width, kSeparatorFormViewHeight);
    _timeDemisionControl.frame = CGRectMake(0, _separatorFormView.bottom + kSpaceHeight, self.view.width, kTimePeriodSegmentControlHeight);
    _curveView.frame = CGRectMake(0, _timeDemisionControl.bottom, self.view.width, kCurveViewHeight);
    [_curveView ssj_relayoutBorder];
    _headerView.frame = CGRectMake(0, 0, self.view.width, kSpaceHeight * 3 + kTimePeriodSegmentControlHeight + kCurveViewHeight + kSeparatorFormViewHeight);
    _tableView.frame = CGRectMake(0, self.dateAxisView.bottom, self.view.width, self.view.height - self.dateAxisView.bottom - SSJ_TABBAR_HEIGHT);
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJReportFormCanYinChartCell *cell = [tableView dequeueReusableCellWithIdentifier:kSSJReportFormCanYinChartCellId forIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    [self reloadDataInCurrentPeriod];
//    [MobClick event:@"form_date_picked"];
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    
    SSJDatePeriod *period = _customPeriod ?: _selectedPeriod;
    
    [SSJReportFormsUtil queryForBillStatisticsWithTimeDimension:[self currentDemension] booksId:nil billTypeId:_billTypeID startDate:period.startDate endDate:period.endDate success:^(NSDictionary *result) {
        
        [self.view ssj_hideLoadingIndicator];
        
//        [self updateCurveHeaderItemWithCurveModels:result[SSJReportFormsCurveModelListKey] period:period];
        
        _curveModels = result[SSJReportFormsCurveModelListKey];
        [_separatorFormView reloadData];
        [_curveView reloadData];
        [_curveView scrollToAxisXAtIndex:(_curveModels.count - 1) animated:NO];
        [self updateCurveUnitAxisXLength];
        [self updateQuestionBtnHidden];
        
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [self showError:error];
    }];
}

#pragma mark - SSJReportFormsCurveGraphViewDataSource
- (NSUInteger)numberOfAxisXInCurveGraphView:(SSJReportFormsCurveGraphView *)graphView {
    return _curveModels.count;
}

- (NSUInteger)numberOfCurveInCurveGraphView:(SSJReportFormsCurveGraphView *)graphView {
    return 1;
}

- (CGFloat)curveGraphView:(SSJReportFormsCurveGraphView *)graphView valueForCurveAtIndex:(NSUInteger)curveIndex axisXIndex:(NSUInteger)axisXIndex {
    
    SSJReportFormsCurveModel *model = [_curveModels ssj_safeObjectAtIndex:axisXIndex];
    if (_isPayment) {
        return model.payment;
    } else {
        return model.income;
    }
}

- (NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView titleAtAxisXIndex:(NSUInteger)index {
    SSJReportFormsCurveModel *model = [_curveModels ssj_safeObjectAtIndex:index];
    switch ([self currentDemension]) {
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
    return [UIColor ssj_colorWithHex:_colorValue];
}

- (nullable NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView suspensionTitleAtAxisXIndex:(NSUInteger)index {
    
    SSJReportFormsCurveModel *model = [_curveModels ssj_safeObjectAtIndex:index];
    if (index == 0) {
        switch ([self currentDemension]) {
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
    
    SSJReportFormsCurveModel *lastModel = [_curveModels ssj_safeObjectAtIndex:index - 1];
    switch ([self currentDemension]) {
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

- (BOOL)curveGraphView:(SSJReportFormsCurveGraphView *)graphView shouldShowValuePointForCurveAtIndex:(NSUInteger)curveIndex axisXIndex:(NSUInteger)axisXIndex {
    SSJReportFormsCurveModel *model = [_curveModels ssj_safeObjectAtIndex:axisXIndex];
    if (_isPayment) {
        return model.payment > 0;
    } else {
        return model.income > 0;
    }
}

#pragma mark - SSJReportFormsCurveGraphViewDelegate
- (void)curveGraphView:(SSJReportFormsCurveGraphView *)graphView didScrollToAxisXIndex:(NSUInteger)index {
    [MobClick event:@"form_curve_move"];
}

- (NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView titleForBallonAtAxisXIndex:(NSUInteger)index {
    SSJReportFormsCurveModel *model = [_curveModels ssj_safeObjectAtIndex:index];
    NSString *surplusStr = [NSString stringWithFormat:@"%f", (model.income - model.payment)];
    return [NSString stringWithFormat:@"结余%@", [surplusStr ssj_moneyDecimalDisplayWithDigits:2]];
}

- (NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView titleForBallonLabelAtCurveIndex:(NSUInteger)curveIndex axisXIndex:(NSUInteger)axisXIndex {
    SSJReportFormsCurveModel *model = [_curveModels ssj_safeObjectAtIndex:axisXIndex];
    if (curveIndex == 0) { // 支出
        return [NSString stringWithFormat:@"支出%@", [[NSString stringWithFormat:@"%f", model.payment] ssj_moneyDecimalDisplayWithDigits:2]];
    } else if (curveIndex == 1) { // 收入
        return [NSString stringWithFormat:@"收入%@", [[NSString stringWithFormat:@"%f", model.income] ssj_moneyDecimalDisplayWithDigits:2]];
    } else {
        return nil;
    }
}

#pragma mark - SSJSeparatorFormViewDataSource
- (NSUInteger)numberOfRowsInSeparatorFormView:(SSJSeparatorFormView *)view {
    return 1;
}

- (NSUInteger)separatorFormView:(SSJSeparatorFormView *)view numberOfCellsInRow:(NSUInteger)row {
    return 3;
}

- (SSJSeparatorFormViewCellItem *)separatorFormView:(SSJSeparatorFormView *)view itemForCellAtIndex:(NSIndexPath *)index {
    if (index.row == 0) {
        
        NSString *topTitle = [[NSString stringWithFormat:@"%f", _average] ssj_moneyDecimalDisplayWithDigits:2];
        
        NSString *bottomTitle = nil;
        switch ([self currentDemension]) {
            case SSJTimeDimensionDay:
                bottomTitle = _isPayment ? @"日均支出" : @"日均收入";
                break;
                
            case SSJTimeDimensionWeek:
                bottomTitle = _isPayment ? @"周均支出" : @"周均收入";
                break;
                
            case SSJTimeDimensionMonth:
                bottomTitle = _isPayment ? @"月均支出" : @"月均收入";
                break;
                
            case SSJTimeDimensionUnknown:
                return nil;
                break;
        }
        
        return [SSJSeparatorFormViewCellItem itemWithTopTitle:topTitle
                                                  bottomTitle:bottomTitle
                                                topTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]
                                             bottomTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]
                                                 topTitleFont:[UIFont systemFontOfSize:18]
                                              bottomTitleFont:[UIFont systemFontOfSize:12]
                                                contentInsets:UIEdgeInsetsZero];
        
    } else if (index.row == 1) {
        
        NSString *topTitle = [[NSString stringWithFormat:@"%f", _maxValue] ssj_moneyDecimalDisplayWithDigits:2];
        return [SSJSeparatorFormViewCellItem itemWithTopTitle:topTitle
                                                  bottomTitle:@"最大值"
                                                topTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]
                                             bottomTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]
                                                 topTitleFont:[UIFont systemFontOfSize:18]
                                              bottomTitleFont:[UIFont systemFontOfSize:12]
                                                contentInsets:UIEdgeInsetsZero];
        
    } else if (index.row == 2) {
        
        NSString *topTitle = [[NSString stringWithFormat:@"%f", _amount] ssj_moneyDecimalDisplayWithDigits:2];
        return [SSJSeparatorFormViewCellItem itemWithTopTitle:topTitle
                                                  bottomTitle:@"合值"
                                                topTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]
                                             bottomTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]
                                                 topTitleFont:[UIFont systemFontOfSize:18]
                                              bottomTitleFont:[UIFont systemFontOfSize:12]
                                                contentInsets:UIEdgeInsetsZero];
        
    } else {
        return nil;
    }
}

#pragma mark - Event
- (void)questionBtnAction {
    if (_descView.superview) {
        [_descView dismiss];
    } else {
        CGPoint showPoint = [_questionBtn convertPoint:CGPointMake(_questionBtn.width * 0.5, _questionBtn.height - 5) toView:self.view];
        [_descView showInView:self.view atPoint:showPoint];
    }
}

#pragma mark - Private
- (void)updateAppearance {
    self.dateAxisView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    self.dateAxisView.scaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.dateAxisView.selectedScaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    
    [self.customPeriodBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:UIControlStateNormal];
    self.customPeriodBtn.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor].CGColor;
    
    self.tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    
    if (_customPeriod) {
        [self.addOrDeleteCustomPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_delete"] forState:UIControlStateNormal];
    } else {
        [self.addOrDeleteCustomPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_edit"] forState:UIControlStateNormal];
    }
    
    [self.noDataRemindView updateAppearance];
    
    [_curveView reloadData];
    _curveView.scaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor];
    _curveView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    [_curveView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    [_separatorFormView reloadData];
    _separatorFormView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    _separatorFormView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    
    _timeDemisionControl.titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _timeDemisionControl.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    _timeDemisionControl.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    
    _questionBtn.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
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

- (void)reloadDataInCurrentPeriod {
    [self.view ssj_showLoadingIndicator];
    SSJDatePeriod *period = _customPeriod ?: _selectedPeriod;
    [SSJReportFormsUtil queryForDefaultTimeDimensionWithStartDate:period.startDate endDate:period.endDate booksId:nil billTypeId:_billTypeID success:^(SSJTimeDimension timeDimension) {
        
        if (timeDimension == SSJTimeDimensionUnknown) {
            _tableView.hidden = YES;
            [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
            return ;
        }
        
        _tableView.hidden = NO;
        [self.view ssj_hideWatermark:YES];
        [self updateDimension:timeDimension];
        
        [SSJReportFormsUtil queryForBillStatisticsWithTimeDimension:timeDimension booksId:nil billTypeId:_billTypeID startDate:period.startDate endDate:period.endDate success:^(NSDictionary *result) {
            
            _curveModels = result[SSJReportFormsCurveModelListKey];
            [self caculateValue];
            
            [_separatorFormView reloadData];
            [_curveView reloadData];
            [_curveView scrollToAxisXAtIndex:(_curveModels.count - 1) animated:NO];
            [self updateCurveUnitAxisXLength];
            [self updateQuestionBtnHidden];
            
        } failure:^(NSError *error) {
            [self.view ssj_hideLoadingIndicator];
            [self showError:error];
        }];
        
    } failure:^(NSError *error) {
        [self showError:error];
        [self.view ssj_hideLoadingIndicator];
    }];
}

- (void)updateDimension:(SSJTimeDimension)dimension {
    switch (dimension) {
        case SSJTimeDimensionDay:
            [_timeDemisionControl setSelectedIndex:0 animated:YES];
            break;
            
        case SSJTimeDimensionWeek:
            [_timeDemisionControl setSelectedIndex:1 animated:YES];
            break;
            
        case SSJTimeDimensionMonth:
            [_timeDemisionControl setSelectedIndex:2 animated:YES];
            break;
            
        case SSJTimeDimensionUnknown:
            break;
    }
}

- (SSJTimeDimension)currentDemension {
    if (_timeDemisionControl.selectedIndex == 0) {
        return SSJTimeDimensionDay;
    } else if (_timeDemisionControl.selectedIndex == 1) {
        return SSJTimeDimensionWeek;
    } else if (_timeDemisionControl.selectedIndex == 2) {
        return SSJTimeDimensionMonth;
    } else {
        return SSJTimeDimensionUnknown;
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
    
//    _curveHeaderItem.curveModels = curveModels;
//    _curveHeaderItem.generalIncome = [[NSString stringWithFormat:@"%f", income] ssj_moneyDecimalDisplayWithDigits:2];
//    _curveHeaderItem.generalPayment = [[NSString stringWithFormat:@"%f", payment] ssj_moneyDecimalDisplayWithDigits:2];
//    _curveHeaderItem.dailyCost = [[NSString stringWithFormat:@"%f", dailyCost] ssj_moneyDecimalDisplayWithDigits:2];
}

- (void)updateCurveUnitAxisXLength {
    switch ([self currentDemension]) {
        case SSJTimeDimensionDay:
        case SSJTimeDimensionMonth:
            _curveView.unitAxisXLength = self.view.width / 7;
            break;
            
        case SSJTimeDimensionWeek:
            _curveView.unitAxisXLength = self.view.width / 4;
            break;
            
        case SSJTimeDimensionUnknown:
            break;
    }
}

- (void)updateQuestionBtnHidden {
    switch ([self currentDemension]) {
        case SSJTimeDimensionDay:
        case SSJTimeDimensionMonth:
            _questionBtn.hidden = YES;
            break;
            
        case SSJTimeDimensionWeek:
            _questionBtn.hidden = NO;
            break;
            
        case SSJTimeDimensionUnknown:
            break;
    }
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

- (void)caculateValue {
    
    _amount = 0;
    _maxValue = 0;
    _average = 0;
    
    int count = 0;
    
    for (SSJReportFormsCurveModel *model in _curveModels) {
        double money = _isPayment ? model.payment : model.income;
        if (money > 0) {
            count ++;
            _amount += money;
            _maxValue = MAX(_maxValue, money);
        }
    }
    
    if (count == 0) {
        SSJPRINT(@"没有有数据的周期");
        return;
    }
    
    if (count > 0) {
        _average = _amount / count;
    }
}

#pragma mark - LazyLoading
- (SSJReportFormsScaleAxisView *)dateAxisView {
    if (!_dateAxisView) {
        _dateAxisView = [[SSJReportFormsScaleAxisView alloc] init];
        _dateAxisView.delegate = self;
    }
    return _dateAxisView;
}

- (SSJSeparatorFormView *)separatorFormView {
    if (!_separatorFormView) {
        _separatorFormView = [[SSJSeparatorFormView alloc] init];
        _separatorFormView.separatorColor = [UIColor whiteColor];
        _separatorFormView.dataSource = self;
    }
    return _separatorFormView;
}

- (SCYSlidePagingHeaderView *)timeDemisionControl {
    if (!_timeDemisionControl) {
        _timeDemisionControl = [[SCYSlidePagingHeaderView alloc] init];
        _timeDemisionControl.customDelegate = self;
        _timeDemisionControl.buttonClickAnimated = YES;
        _timeDemisionControl.titles = @[@"日", @"周", @"月"];
    }
    return _timeDemisionControl;
}

- (SSJReportFormsCurveGraphView *)curveView {
    if (!_curveView) {
        _curveView = [[SSJReportFormsCurveGraphView alloc] init];
        _curveView.dataSource = self;
        _curveView.delegate = self;
        _curveView.showValuePoint = YES;
        _curveView.showCurveShadow = YES;
        [_curveView ssj_setBorderWidth:1];
        [_curveView ssj_setBorderStyle:(SSJBorderStyleTop)];
    }
    return _curveView;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kSpaceHeight * 3 + kTimePeriodSegmentControlHeight + kCurveViewHeight + kSeparatorFormViewHeight)];
        _headerView.backgroundColor = [UIColor clearColor];
    }
    return _headerView;
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
    }
    return _tableView;
}

- (UIButton *)questionBtn {
    if (!_questionBtn) {
        _questionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_questionBtn setImage:[[UIImage imageNamed:@"reportForms_question"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_questionBtn addTarget:self action:@selector(questionBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _questionBtn;
}

- (SSJReportFormsCurveDescriptionView *)descView {
    if (!_descView) {
        _descView = [[SSJReportFormsCurveDescriptionView alloc] init];
    }
    return _descView;
}

- (SSJBudgetNodataRemindView *)noDataRemindView {
    if (!_noDataRemindView) {
        _noDataRemindView = [[SSJBudgetNodataRemindView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 260)];
        _noDataRemindView.image = @"budget_no_data";
        _noDataRemindView.title = @"报表空空如也";
    }
    return _noDataRemindView;
}

@end
