//
//  SSJReportFormsBillTypeDetailViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/12/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsBillTypeDetailViewController.h"
#import "SSJMagicExportCalendarViewController.h"
#import "SSJBillingChargeViewController.h"

#import "SSJReportFormsPeriodSelectionControl.h"
#import "SCYSlidePagingHeaderView.h"
#import "SSJReportFormsCurveGraphView.h"
#import "SSJSeparatorFormView.h"
#import "SSJReportFormsCurveDescriptionView.h"
#import "SSJBudgetNodataRemindView.h"
#import "SSJReportFormCanYinChartCell.h"

#import "SSJReportFormCanYinChartCellItem.h"
#import "SSJReportFormsCurveModel.h"
#import "SSJDatePeriod.h"
#import "SSJReportFormsUtil.h"
#import "SSJUserTableManager.h"

static const CGFloat kSpaceHeight = 10;

static const CGFloat kTimePeriodSegmentControlHeight = 40;

static const CGFloat kCurveViewHeight = 350;

static const CGFloat kSeparatorFormViewHeight = 88;

static NSString *const kSSJReportFormCanYinChartCellId = @"kSSJReportFormCanYinChartCellId";

@interface SSJReportFormsBillTypeDetailViewController () <UITableViewDataSource, UITableViewDelegate, SCYSlidePagingHeaderViewDelegate, SSJReportFormsCurveGraphViewDataSource, SSJReportFormsCurveGraphViewDelegate, SSJSeparatorFormViewDataSource>

@property (nonatomic, strong) SSJReportFormsPeriodSelectionControl *periodControl;

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

@property (nonatomic, strong) NSArray<SSJReportFormsCurveModel *> *curveModels;

@property (nonatomic, strong) NSMutableArray<SSJReportFormsCurveModel *> *filterCurveModels;

@property (nonatomic, strong) NSMutableArray<SSJReportFormCanYinChartCellItem *> *cellItems;

@property (nonatomic) SSJTimeDimension dimesion;

@property (nonatomic) double maxValue;

@property (nonatomic) double amount;

@property (nonatomic) double average;

@end

@implementation SSJReportFormsBillTypeDetailViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        _dimesion = SSJTimeDimensionMonth;
        _filterCurveModels = [[NSMutableArray alloc] init];
        _cellItems = [[NSMutableArray alloc] init];
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.billType != SSJBillTypePay && self.billType != SSJBillTypeIncome) {
        [SSJAlertViewAdapter showError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"未定义的收支类型，billType:%d", (int)self.billType]}]];
        return;
    }
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.periodControl];
    self.tableView.tableHeaderView = self.headerView;
    [self.curveView addSubview:self.questionBtn];
    [self updateAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateSubveiwsHidden];
    [self.view ssj_showLoadingIndicator];
    
    [SSJReportFormsUtil queryForPeriodListWithIncomeOrPayType:SSJBillTypeSurplus booksId:nil success:^(NSArray<SSJDatePeriod *> *periods) {
        
        [self.view ssj_hideLoadingIndicator];
        
        self.periodControl.periods = periods;
        
        [self updateSubveiwsHidden];
        
        if (periods.count == 0) {
            [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
        } else {
            [self.view ssj_hideWatermark:YES];
        }
        
        if (periods.count > 0) {
            [self reloadAllData];
        }
        
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showError:error];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJReportFormCanYinChartCell *cell = [tableView dequeueReusableCellWithIdentifier:kSSJReportFormCanYinChartCellId forIndexPath:indexPath];
    SSJReportFormCanYinChartCellItem *item = [_cellItems ssj_safeObjectAtIndex:indexPath.row];
    cell.cellItem = item;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [SSJAnaliyticsManager event:@"forms_item_detail"];
    SSJReportFormsCurveModel *curveModel = [_filterCurveModels ssj_safeObjectAtIndex:indexPath.row];
    
    SSJBillingChargeViewController *chargeListController = [[SSJBillingChargeViewController alloc] init];
    chargeListController.billId = self.billTypeID;
    chargeListController.billName = self.billName;
    chargeListController.billType = self.billType;
    chargeListController.memberId = SSJAllMembersId;
    chargeListController.period = [SSJDatePeriod datePeriodWithStartDate:curveModel.startDate endDate:curveModel.endDate];
    [self.navigationController pushViewController:chargeListController animated:YES];
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    [self reloadDataWithDimension:[self currentDemension]];
}

#pragma mark - SSJReportFormsCurveGraphViewDataSource
- (NSUInteger)numberOfAxisXInCurveGraphView:(SSJReportFormsCurveGraphView *)graphView {
    return _curveModels.count;
}

- (NSUInteger)numberOfCurveInCurveGraphView:(SSJReportFormsCurveGraphView *)graphView {
    return 1;
}

- (double)curveGraphView:(SSJReportFormsCurveGraphView *)graphView valueForCurveAtIndex:(NSUInteger)curveIndex axisXIndex:(NSUInteger)axisXIndex {
    
    SSJReportFormsCurveModel *model = [_curveModels ssj_safeObjectAtIndex:axisXIndex];
    if (self.billType == SSJBillTypePay) {
        return model.payment;
    } else if (self.billType == SSJBillTypeIncome) {
        return model.income;
    } else {
        return 0;
    }
}

- (NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView titleAtAxisXIndex:(NSUInteger)index {
    SSJReportFormsCurveModel *model = [_curveModels ssj_safeObjectAtIndex:index];
    return [self timeWithModel:model];
}

- (UIColor *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView colorForCurveAtIndex:(NSUInteger)curveIndex {
    return [UIColor ssj_colorWithHex:_colorValue];
}

- (nullable NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView suspensionTitleAtAxisXIndex:(NSUInteger)index {
    
    SSJReportFormsCurveModel *model = [_curveModels ssj_safeObjectAtIndex:index];
    if (index == 0) {
        switch ([self currentDemension]) {
            case SSJTimeDimensionDay:
                [SSJAnaliyticsManager event:@"forms_classify_cycle_day"];
                return [model.startDate formattedDateWithFormat:@"M月"];
                
                break;
                
            case SSJTimeDimensionWeek:
                [SSJAnaliyticsManager event:@"forms_classify_cycle_week"];
                return [model.startDate formattedDateWithFormat:@"yyyy年"];
                break;
                
            case SSJTimeDimensionMonth:
                [SSJAnaliyticsManager event:@"forms_classify_cycle_month"];
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
    if (self.billType == SSJBillTypePay) {
        return model.payment > 0;
    } else if (self.billType == SSJBillTypeIncome) {
        return model.income > 0;
    } else {
        return NO;
    }
}

#pragma mark - SSJReportFormsCurveGraphViewDelegate
- (void)curveGraphView:(SSJReportFormsCurveGraphView *)graphView didScrollToAxisXIndex:(NSUInteger)index {
    [self reorganiseCellItems];
    [_tableView reloadData];
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
                bottomTitle = self.billType == SSJBillTypePay ? @"日均支出" : @"日均收入";
                break;
                
            case SSJTimeDimensionWeek:
                bottomTitle = self.billType == SSJBillTypePay ? @"周均支出" : @"周均收入";
                break;
                
            case SSJTimeDimensionMonth:
                bottomTitle = self.billType == SSJBillTypePay ? @"月均支出" : @"月均收入";
                break;
                
            case SSJTimeDimensionUnknown:
                return nil;
                break;
        }
        
        return [SSJSeparatorFormViewCellItem itemWithTopTitle:topTitle
                                                  bottomTitle:bottomTitle
                                                topTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]
                                             bottomTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]
                                                 topTitleFont:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2]
                                              bottomTitleFont:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5]
                                                contentInsets:UIEdgeInsetsZero];
        
    } else if (index.row == 1) {
        
        NSString *topTitle = [[NSString stringWithFormat:@"%f", _maxValue] ssj_moneyDecimalDisplayWithDigits:2];
        return [SSJSeparatorFormViewCellItem itemWithTopTitle:topTitle
                                                  bottomTitle:@"最大值"
                                                topTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]
                                             bottomTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]
                                                 topTitleFont:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2]
                                              bottomTitleFont:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5]
                                                contentInsets:UIEdgeInsetsZero];
        
    } else if (index.row == 2) {
        
        NSString *topTitle = [[NSString stringWithFormat:@"%f", _amount] ssj_moneyDecimalDisplayWithDigits:2];
        return [SSJSeparatorFormViewCellItem itemWithTopTitle:topTitle
                                                  bottomTitle:@"合值"
                                                topTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]
                                             bottomTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]
                                                 topTitleFont:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2]
                                              bottomTitleFont:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5]
                                                contentInsets:UIEdgeInsetsZero];
        
    } else {
        return nil;
    }
}

#pragma mark - Event
- (void)enterCalendarVC {
    [SSJAnaliyticsManager event:@"form_date_custom"];
    [SSJAnaliyticsManager event:@"form_item_date_custom"];
    
    __weak typeof(self) wself = self;
    [SSJUserTableManager currentBooksId:^(NSString * _Nonnull booksId) {
        SSJMagicExportCalendarViewController *calendarVC = [[SSJMagicExportCalendarViewController alloc] init];
        calendarVC.title = @"自定义时间";
        calendarVC.booksId = booksId;
        calendarVC.billType = self.billType;
        calendarVC.billName = self.billName;
        calendarVC.billTypeId = wself.billTypeID;
        calendarVC.userId = SSJAllMembersId;
        calendarVC.completion = ^(NSDate *selectedBeginDate, NSDate *selectedEndDate) {
            wself.periodControl.customPeriod = [SSJDatePeriod datePeriodWithStartDate:selectedBeginDate endDate:selectedEndDate];
        };
        [wself.navigationController pushViewController:calendarVC animated:YES];
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

- (void)questionBtnAction {
    if (self.descView.superview) {
        [self.descView dismiss];
    } else {
        CGPoint showPoint = [_questionBtn convertPoint:CGPointMake(_questionBtn.width * 0.5, _questionBtn.height - 5) toView:self.tableView];
        [self.descView showInView:self.tableView atPoint:showPoint];
    }
}

#pragma mark - Private
- (void)reloadAllData {
    [self.view ssj_showLoadingIndicator];
    SSJDatePeriod *period = self.periodControl.currentPeriod;
    if (self.billTypeID) {
        [SSJReportFormsUtil queryForDefaultTimeDimensionWithStartDate:period.startDate endDate:period.endDate booksId:nil billId:_billTypeID success:^(SSJTimeDimension timeDimension) {
            if (timeDimension == SSJTimeDimensionUnknown) {
                _tableView.hidden = YES;
                [self.view ssj_hideLoadingIndicator];
                [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
                return;
            }
            
            _tableView.hidden = NO;
            [self.view ssj_hideWatermark:YES];
            [self updateDimension:timeDimension];
            [self reloadDataWithDimension:timeDimension];
        } failure:^(NSError *error) {
            [SSJAlertViewAdapter showError:error];
            [self.view ssj_hideLoadingIndicator];
        }];
    } else {
        [SSJReportFormsUtil queryForDefaultTimeDimensionWithStartDate:period.startDate endDate:period.endDate booksId:nil billName:self.billName billType:self.billType success:^(SSJTimeDimension timeDimension) {
            if (timeDimension == SSJTimeDimensionUnknown) {
                _tableView.hidden = YES;
                [self.view ssj_hideLoadingIndicator];
                [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
                return;
            }
            
            _tableView.hidden = NO;
            [self.view ssj_hideWatermark:YES];
            [self updateDimension:timeDimension];
            [self reloadDataWithDimension:timeDimension];
        } failure:^(NSError *error) {
            [SSJAlertViewAdapter showError:error];
            [self.view ssj_hideLoadingIndicator];
        }];
    }
}

- (void)reloadDataWithDimension:(SSJTimeDimension)dimension {
    
    SSJDatePeriod *period = self.periodControl.currentPeriod;
    
    if (self.billTypeID) {
        [SSJReportFormsUtil queryForBillStatisticsWithTimeDimension:[self currentDemension] booksId:nil billId:self.billTypeID startDate:period.startDate endDate:period.endDate success:^(NSDictionary *result) {
            
            [self.view ssj_hideLoadingIndicator];
            
            _curveModels = result[SSJReportFormsCurveModelListKey];
            
            [self caculateValue];
            [_separatorFormView reloadData];
            
            [_curveView reloadData];
            [_curveView scrollToAxisXAtIndex:(_curveModels.count - 1) animated:NO];
            [self updateCurveUnitAxisXLength];
            
            [self reorganiseCellItems];
            [_tableView reloadData];
            
            [self updateQuestionBtnHidden];
            
            [_descView dismiss];
            
            if (_curveModels.count) {
                SSJReportFormsCurveModel *firstModel = [_curveModels firstObject];
                self.descView.period = [SSJDatePeriod datePeriodWithStartDate:firstModel.startDate endDate:firstModel.endDate];
            }
            
        } failure:^(NSError *error) {
            [self.view ssj_hideLoadingIndicator];
            [SSJAlertViewAdapter showError:error];
        }];
    } else {
        [SSJReportFormsUtil queryForBillStatisticsWithTimeDimension:[self currentDemension] booksId:nil billName:self.billName billType:self.billType startDate:period.startDate endDate:period.endDate success:^(NSDictionary *result) {
            [self.view ssj_hideLoadingIndicator];
            
            _curveModels = result[SSJReportFormsCurveModelListKey];
            
            [self caculateValue];
            [_separatorFormView reloadData];
            
            [_curveView reloadData];
            [_curveView scrollToAxisXAtIndex:(_curveModels.count - 1) animated:NO];
            [self updateCurveUnitAxisXLength];
            
            [self reorganiseCellItems];
            [_tableView reloadData];
            
            [self updateQuestionBtnHidden];
            
            [_descView dismiss];
            
            if (_curveModels.count) {
                SSJReportFormsCurveModel *firstModel = [_curveModels firstObject];
                self.descView.period = [SSJDatePeriod datePeriodWithStartDate:firstModel.startDate endDate:firstModel.endDate];
            }
        } failure:^(NSError *error) {
            [self.view ssj_hideLoadingIndicator];
            [SSJAlertViewAdapter showError:error];
        }];
    }
}

- (void)reorganiseCellItems {
    
    [_filterCurveModels removeAllObjects];
    
    [_curveView.visibleIndexs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        int index = [obj doubleValue];
        SSJReportFormsCurveModel *model = [_curveModels ssj_safeObjectAtIndex:index];
        double money = self.billType == SSJBillTypePay ? model.payment : model.income;
        
        if (money) {
            [_filterCurveModels addObject:model];
        }
    }];
    
    [_cellItems removeAllObjects];
    
    for (int i = 0; i < _filterCurveModels.count; i ++) {
        SSJReportFormsCurveModel *model = [_filterCurveModels ssj_safeObjectAtIndex:i];
        double money = self.billType == SSJBillTypePay ? model.payment : model.income;
        
        SSJReportFormCanYinChartCellItem *item = [[SSJReportFormCanYinChartCellItem alloc] init];
        if (_filterCurveModels.count == 1) {
            item.segmentStyle = SSJReportFormCanYinChartCellSegmentStyleNone;
        } else if (i == 0) {
            item.segmentStyle = SSJReportFormCanYinChartCellSegmentStyleBottom;
        } else if (i == _filterCurveModels.count - 1) {
            item.segmentStyle = SSJReportFormCanYinChartCellSegmentStyleTop;
        } else {
            item.segmentStyle = SSJReportFormCanYinChartCellSegmentStyleTop | SSJReportFormCanYinChartCellSegmentStyleBottom;
        }
        item.leftText = [self timeWithModel:model];
        item.centerText = [[NSString stringWithFormat:@"%f", (money / _amount) * 100] ssj_moneyDecimalDisplayWithDigits:1];
        item.rightText = [[NSString stringWithFormat:@"%f", money] ssj_moneyDecimalDisplayWithDigits:2];
        item.circleColor = _colorValue;
        item.separatorInsets = UIEdgeInsetsMake(0, 30, 0, 0);
        
        [_cellItems addObject:item];
    }
}

- (void)updateAppearance {
    [self.periodControl updateAppearance];
    self.tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    
    [self.noDataRemindView updateAppearance];
    
    [_curveView reloadData];
    _curveView.valueColor = SSJ_MAIN_COLOR;
    _curveView.scaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor];
    _curveView.balloonTitleAttributes = @{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4],
                                          NSForegroundColorAttributeName:[UIColor whiteColor],
                                          NSBackgroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.bookKeepingHomeMutiButtonSelectColor]};
    
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
    if (self.periodControl.periods.count == 0) {
        self.periodControl.hidden = YES;
        self.tableView.hidden = YES;
    } else {
        self.periodControl.hidden = NO;
        self.tableView.hidden = NO;
    }
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

- (void)updateCurveUnitAxisXLength {
    switch ([self currentDemension]) {
        case SSJTimeDimensionDay:
        case SSJTimeDimensionMonth:
            _curveView.unitAxisXLength = self.view.width / 7;
            break;
            
        case SSJTimeDimensionWeek:
            _curveView.unitAxisXLength = self.view.width / 5;
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

- (void)caculateValue {
    _amount = 0;
    _maxValue = 0;
    _average = 0;
    
    int count = 0;
    
    for (SSJReportFormsCurveModel *model in _curveModels) {
        double money = self.billType == SSJBillTypePay ? model.payment : model.income;
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

- (NSString *)timeWithModel:(SSJReportFormsCurveModel *)model {
    switch ([self currentDemension]) {
        case SSJTimeDimensionDay: {
            return [model.startDate formattedDateWithFormat:@"dd"];
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

#pragma mark - LazyLoading
- (SSJReportFormsPeriodSelectionControl *)periodControl {
    if (!_periodControl) {
        __weak typeof(self) wself = self;
        _periodControl = [[SSJReportFormsPeriodSelectionControl alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, 40)];
        _periodControl.customPeriod = self.customPeriod;
        _periodControl.selectedPeriod = self.selectedPeriod;
        _periodControl.periodChangeHandler = ^(SSJReportFormsPeriodSelectionControl *control) {
            [wself reloadAllData];
            [SSJAnaliyticsManager event:@"form_date_picked"];
        };
        _periodControl.addCustomPeriodHandler = ^(SSJReportFormsPeriodSelectionControl *control) {
            [wself enterCalendarVC];
        };
        _periodControl.clearCustomPeriodHandler = ^(SSJReportFormsPeriodSelectionControl *control) {
            [wself reloadAllData];
            [SSJAnaliyticsManager event:@"form_date_custom_delete"];
        };
    }
    return _periodControl;
}

- (SSJSeparatorFormView *)separatorFormView {
    if (!_separatorFormView) {
        _separatorFormView = [[SSJSeparatorFormView alloc] initWithFrame:CGRectMake(0, kSpaceHeight, self.view.width, kSeparatorFormViewHeight)];
        _separatorFormView.separatorColor = [UIColor whiteColor];
        _separatorFormView.dataSource = self;
    }
    return _separatorFormView;
}

- (SCYSlidePagingHeaderView *)timeDemisionControl {
    if (!_timeDemisionControl) {
        _timeDemisionControl = [[SCYSlidePagingHeaderView alloc] initWithFrame:CGRectMake(0, kSeparatorFormViewHeight + kSpaceHeight * 2, self.view.width, kTimePeriodSegmentControlHeight)];
        _timeDemisionControl.customDelegate = self;
        _timeDemisionControl.buttonClickAnimated = YES;
        _timeDemisionControl.titles = @[@"日", @"周", @"月"];
    }
    return _timeDemisionControl;
}

- (SSJReportFormsCurveGraphView *)curveView {
    if (!_curveView) {
        _curveView = [[SSJReportFormsCurveGraphView alloc] initWithFrame:CGRectMake(0, kSeparatorFormViewHeight + kTimePeriodSegmentControlHeight + kSpaceHeight * 2, self.view.width, kCurveViewHeight)];
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
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, kSpaceHeight * 3 + kTimePeriodSegmentControlHeight + kCurveViewHeight + kSeparatorFormViewHeight)];
        _headerView.backgroundColor = [UIColor clearColor];
        [_headerView addSubview:self.timeDemisionControl];
        [_headerView addSubview:self.curveView];
        [_headerView addSubview:self.separatorFormView];
    }
    return _headerView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.periodControl.bottom, self.view.width, self.view.height - self.periodControl.bottom) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 55;
        _tableView.sectionHeaderHeight = 0;
        _tableView.sectionFooterHeight = 0;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.width, 36)];
        _tableView.tableFooterView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[SSJReportFormCanYinChartCell class] forCellReuseIdentifier:kSSJReportFormCanYinChartCellId];
    }
    return _tableView;
}

- (UIButton *)questionBtn {
    if (!_questionBtn) {
        _questionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _questionBtn.frame = CGRectMake(60, _curveView.height - 30, 30, 30);
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
