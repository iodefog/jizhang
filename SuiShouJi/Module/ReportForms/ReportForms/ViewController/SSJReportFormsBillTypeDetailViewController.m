//
//  SSJReportFormsBillTypeDetailViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/12/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsBillTypeDetailViewController.h"
#import "SSJReportFormsScaleAxisView.h"
#import "SSJReportFormCurveHeaderView.h"
#import "SSJBudgetNodataRemindView.h"
#import "SSJReportFormCanYinChartCell.h"
#import "SSJReportFormsCurveModel.h"
#import "SSJDatePeriod.h"
#import "SSJReportFormsUtil.h"

static NSString *const kSSJReportFormCanYinChartCellId = @"kSSJReportFormCanYinChartCellId";

@interface SSJReportFormsBillTypeDetailViewController () <UITableViewDataSource, UITableViewDelegate, SSJReportFormsScaleAxisViewDelegate>

//  自定义时间
@property (nonatomic, strong) UIButton *customPeriodBtn;

//  编辑、删除自定义时间按钮
@property (nonatomic, strong) UIButton *addOrDeleteCustomPeriodBtn;

//  切换年份、月份控件
@property (nonatomic, strong) SSJReportFormsScaleAxisView *dateAxisView;

//  流水列表视图
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) SSJReportFormCurveHeaderView *curveHeaderView;

//  没有流水的提示视图
@property (nonatomic, strong) SSJBudgetNodataRemindView *noDataRemindView;

@property (nonatomic, strong) SSJReportFormCurveHeaderViewItem *curveHeaderItem;

//  日期切换刻度控件的数据源
@property (nonatomic, strong) NSArray<SSJDatePeriod *> *periods;

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation SSJReportFormsBillTypeDetailViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _items = [[NSMutableArray alloc] init];
        _curveHeaderItem = [[SSJReportFormCurveHeaderViewItem alloc] init];
        _curveHeaderItem.timeDimension = SSJTimeDimensionMonth;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.customPeriodBtn];
    [self.view addSubview:self.addOrDeleteCustomPeriodBtn];
    [self.view addSubview:self.dateAxisView];
    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = self.curveHeaderView;
    [self updateAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view ssj_showLoadingIndicator];
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

#pragma mark - Private
- (void)updateAppearance {
    
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
        self.curveHeaderItem.timeDimension = timeDimension;
        
        [SSJReportFormsUtil queryForBillStatisticsWithTimeDimension:self.curveHeaderItem.timeDimension booksId:nil billTypeId:_billTypeID startDate:period.startDate endDate:period.endDate success:^(NSDictionary *result) {
            
            [self updateCurveHeaderItemWithCurveModels:result[SSJReportFormsCurveModelListKey] period:period];
            self.curveHeaderView.item = _curveHeaderItem;
            
        } failure:^(NSError *error) {
            [self.view ssj_hideLoadingIndicator];
            [self showError:error];
        }];
        
    } failure:^(NSError *error) {
        [self showError:error];
        [self.view ssj_hideLoadingIndicator];
    }];
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

- (void)showError:(NSError *)error {
    NSString *message = nil;
#ifdef DEBUG
    message = [error localizedDescription];
#else
    message = SSJ_ERROR_MESSAGE;
#endif
    [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:message action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
}

#pragma mark - LazyLoading
- (SSJReportFormsScaleAxisView *)dateAxisView {
    if (!_dateAxisView) {
        _dateAxisView = [[SSJReportFormsScaleAxisView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, 50)];
        _dateAxisView.delegate = self;
        [_dateAxisView ssj_setBorderWidth:1];
        [_dateAxisView ssj_setBorderStyle:(SSJBorderStyleBottom)];
    }
    return _dateAxisView;
}

- (SSJReportFormCurveHeaderView *)curveHeaderView {
    if (!_curveHeaderView) {
        _curveHeaderView = [[SSJReportFormCurveHeaderView alloc] init];
        __weak typeof(self) wself = self;
        _curveHeaderView.changeTimePeriodHandle = ^(SSJReportFormCurveHeaderView *view) {
            SSJDatePeriod *period = wself.customPeriod ?: wself.selectedPeriod;

            [SSJReportFormsUtil queryForBillStatisticsWithTimeDimension:view.item.timeDimension booksId:nil billTypeId:wself.billTypeID startDate:period.startDate endDate:period.endDate success:^(NSDictionary *result) {
                
                [wself.view ssj_hideLoadingIndicator];
                [wself updateCurveHeaderItemWithCurveModels:result[SSJReportFormsCurveModelListKey] period:period];
                wself.curveHeaderView.item = wself.curveHeaderItem;
                
            } failure:^(NSError *error) {
                [wself.view ssj_hideLoadingIndicator];
                [wself showError:error];
            }];
            
//            switch (view.item.timeDimension) {
//                case SSJTimeDimensionDay:
//                    [MobClick event:@"form_curve_day"];
//                    break;
//                    
//                case SSJTimeDimensionWeek:
//                    [MobClick event:@"form_curve_week"];
//                    break;
//                    
//                case SSJTimeDimensionMonth:
//                    [MobClick event:@"form_curve_month"];
//                    break;
//                    
//                case SSJTimeDimensionUnknown:
//                    break;
//            }
        };
    }
    return _curveHeaderView;
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

- (SSJBudgetNodataRemindView *)noDataRemindView {
    if (!_noDataRemindView) {
        _noDataRemindView = [[SSJBudgetNodataRemindView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 260)];
        _noDataRemindView.image = @"budget_no_data";
        _noDataRemindView.title = @"报表空空如也";
    }
    return _noDataRemindView;
}

@end
