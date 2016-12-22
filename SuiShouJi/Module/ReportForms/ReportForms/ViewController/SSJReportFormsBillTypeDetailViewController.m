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
#import "SSJDatePeriod.h"

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


@end

@implementation SSJReportFormsBillTypeDetailViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
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
}

#pragma mark - UITableViewDataSource

#pragma mark - UITableViewDelegate

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
//            SSJDatePeriod *period = wself.customPeriod ?: [wself.periods ssj_safeObjectAtIndex:wself.dateAxisView.selectedIndex];
//            
//            [SSJReportFormsUtil queryForBillStatisticsWithTimeDimension:view.item.timeDimension booksId:wself.currentBooksId billTypeId:nil startDate:period.startDate endDate:period.endDate success:^(NSDictionary *result) {
//                
//                [wself.view ssj_hideLoadingIndicator];
//                [wself updateCurveHeaderItemWithCurveModels:result[SSJReportFormsCurveModelListKey] period:period];
//                wself.curveHeaderView.item = wself.curveHeaderItem;
//                
//            } failure:^(NSError *error) {
//                [wself.view ssj_hideLoadingIndicator];
//                [wself showError:error];
//            }];
            
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
//        [_tableView registerClass:[SSJReportFormsChartCell class] forCellReuseIdentifier:kChartViewCellID];
//        [_tableView registerClass:[SSJReportFormsIncomeAndPayCell class] forCellReuseIdentifier:kIncomeAndPayCellID];
//        [_tableView registerClass:[SSJReportFormCurveListCell class] forCellReuseIdentifier:kSSJReportFormCurveListCellID];
//        [_tableView registerClass:[SSJReportFormsNoDataCell class] forCellReuseIdentifier:kNoDataRemindCellID];
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
