//
//  SSJBudgetDetailViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetDetailViewController.h"
#import "SSJBudgetEditViewController.h"
#import "SSJBudgetDetailPeriodSwitchControl.h"
#import "SSJBudgetDetailHeaderView.h"
#import "SSJBudgetDetailBottomView.h"
#import "SSJBudgetDetailMiddleTitleView.h"
#import "SSJBorderButton.h"
#import "SSJPercentCircleView.h"
#import "SSJBudgetNodataRemindView.h"
#import "SSJBudgetDatabaseHelper.h"

static const CGFloat kHeaderMargin = 8;

static NSString *const kDateFomat = @"yyyy-MM-dd";

@interface SSJBudgetDetailViewController () <SSJReportFormsPercentCircleDataSource>

//  导航栏标题视图
@property (nonatomic, strong) SSJBudgetDetailPeriodSwitchControl *titleView;

//  底层滚动视图
@property (nonatomic, strong) UIScrollView *scrollView;

//  周期
@property (nonatomic, strong) UILabel *periodLabel;

//  包含本月预算、距结算日、已花、超支、波浪图表的视图
@property (nonatomic, strong) SSJBudgetDetailHeaderView *headerView;

//  预算消费明细的标题视图
@property (nonatomic, strong) SSJBudgetDetailMiddleTitleView *middleView;

//  包含预算消费明细图表、编辑按钮
@property (nonatomic, strong) SSJBudgetDetailBottomView *bottomView;

//  没有消费记录的提示视图
@property (nonatomic, strong) SSJBudgetNodataRemindView *noDataRemindView;

//  预算数据模型
@property (nonatomic, strong) SSJBudgetModel *budgetModel;

//  预算消费明细图表的数据源
@property (nonatomic, strong) NSArray *circleItems;

//  月预算历史id、日期映射表
@property (nonatomic, strong) NSDictionary *monthBudgetIdMap;

//  周期类型
@property (nonatomic) SSJBudgetPeriodType periodType;

@end

@implementation SSJBudgetDetailViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = self.titleView;
    
    [self.view addSubview:self.periodLabel];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.headerView];
    [self.scrollView addSubview:self.middleView];
    [self.scrollView addSubview:self.bottomView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadAllData];
}

#pragma mark - SSJReportFormsPercentCircleDataSource
- (NSUInteger)numberOfComponentsInPercentCircle:(SSJPercentCircleView *)circle {
    return self.circleItems.count;
}

- (SSJPercentCircleViewItem *)percentCircle:(SSJPercentCircleView *)circle itemForComponentAtIndex:(NSUInteger)index {
    return [self.circleItems ssj_safeObjectAtIndex:index];
}

#pragma mark - Event
- (void)editButtonAction {
    SSJBudgetEditViewController *budgetEditVC = [[SSJBudgetEditViewController alloc] init];
    budgetEditVC.model = self.budgetModel;
    [self.navigationController pushViewController:budgetEditVC animated:YES];
}

- (void)changeSelectedMonth {
    NSString *budgetId = [self.monthBudgetIdMap objectForKey:[self.titleView.currentDate formattedDateWithFormat:@"yyy-MM-dd"]];
    if (!budgetId.length) {
        self.budgetModel = nil;
        self.circleItems = nil;
        [self updateView];
        return;
    }
    
    [self.view ssj_showLoadingIndicator];
    [SSJBudgetDatabaseHelper queryForBudgetDetailWithID:budgetId success:^(NSDictionary * _Nonnull result) {
        [self.view ssj_hideLoadingIndicator];
        self.budgetModel = result[SSJBudgetModelKey];
        self.circleItems = result[SSJBudgetCircleItemsKey];
        [self updateView];
    } failure:^(NSError * _Nullable error) {
        [self.view ssj_hideLoadingIndicator];
        SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:SSJ_ERROR_MESSAGE action:action, nil];
    }];
}

#pragma mark - Private
- (void)loadAllData {
    [self.view ssj_showLoadingIndicator];
    [SSJBudgetDatabaseHelper queryForBudgetDetailWithID:self.budgetId success:^(NSDictionary * _Nonnull result) {
        self.budgetModel = result[SSJBudgetModelKey];
        self.circleItems = result[SSJBudgetCircleItemsKey];
        self.titleView.periodType = self.budgetModel.type;
        self.titleView.currentDate = [NSDate dateWithString:self.budgetModel.beginDate formatString:kDateFomat];
        
        if (self.budgetModel) {
            self.periodType = self.budgetModel.type;
        }
        
        //  如果是月预算，需要再查询历史月预算id；否则直接刷新页面
        if (self.budgetModel.type == SSJBudgetPeriodTypeMonth) {
            [SSJBudgetDatabaseHelper queryForMonthBudgetIdListWithSuccess:^(NSDictionary * _Nonnull result) {
                [self.view ssj_hideLoadingIndicator];
                
                self.monthBudgetIdMap = result;
                
                //  对日期进行生序排序
                NSArray *sortedDates = [[self.monthBudgetIdMap allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    NSDate *date1 = [NSDate dateWithString:obj1 formatString:kDateFomat];
                    NSDate *date2 = [NSDate dateWithString:obj2 formatString:kDateFomat];
                    return [date1 compare:date2];
                }];
                
                self.titleView.lastDate = [NSDate dateWithString:[sortedDates lastObject] formatString:kDateFomat];
                
                if (![[self.monthBudgetIdMap allValues] containsObject:self.budgetId]) {
                    SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
                    [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:SSJ_ERROR_MESSAGE action:action, nil];
                    return;
                }
                
                [self updateView];
                
            } failure:^(NSError * _Nullable error) {
                [self.view ssj_hideLoadingIndicator];
                SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
                [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:SSJ_ERROR_MESSAGE action:action, nil];
            }];
        } else {
            [self.view ssj_hideLoadingIndicator];
            [self updateView];
        }
        
    } failure:^(NSError * _Nullable error) {
        
        [self.view ssj_hideLoadingIndicator];
        SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:SSJ_ERROR_MESSAGE action:action, nil];
        
    }];
}

- (void)updateView {
    NSString *tStr = nil;
    switch (self.periodType) {
        case 0:
            tStr = @"周";
            break;
            
        case 1:
            tStr = @"月";
            break;
            
        case 2:
            tStr = @"年";
            break;
    }
    
    if (!self.budgetModel) {
        self.periodLabel.hidden = YES;
        self.scrollView.hidden = YES;
        self.noDataRemindView.title = [NSString stringWithFormat:@"您在这个%@没有设置预算哦", tStr];
        [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
        return;
    }
    
    self.periodLabel.hidden = NO;
    self.scrollView.hidden = NO;
    self.headerView.isHistory = ![self.budgetModel.ID isEqualToString:self.budgetId];
    [self.headerView setBudgetModel:self.budgetModel];
    
    self.scrollView.contentSize = CGSizeMake(self.view.width, kHeaderMargin + self.headerView.height + self.middleView.height + self.bottomView.height);
    self.headerView.top = kHeaderMargin;
    self.middleView.top = self.headerView.bottom;
    self.bottomView.top = self.middleView.bottom;
    
    [self.bottomView.circleView reloadData];
    self.bottomView.button.hidden = ![self.budgetModel.ID isEqualToString:self.budgetId];
    
    if (self.circleItems.count > 0) {
        [self.view ssj_hideWatermark:YES];
        [self.bottomView.circleView ssj_hideWatermark:YES];
    } else {
        self.noDataRemindView.title = @"NO，小主居然忘记记账了！";
        [self.bottomView.circleView ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:NULL];
    }
    
    NSString *beginDate = [self.budgetModel.beginDate ssj_dateStringFromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-M-d"];
    NSString *endDate = [self.budgetModel.endDate ssj_dateStringFromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-M-d"];
    [self.middleView setTitle:[NSString stringWithFormat:@"%@预算消费明细", tStr]];
//    [self.middleView setPeriod:[NSString stringWithFormat:@"%@——%@", beginDate, endDate]];
    self.periodLabel.text = [NSString stringWithFormat:@"%@——%@", beginDate, endDate];
}

#pragma mark - Getter
- (SSJBudgetDetailPeriodSwitchControl *)titleView {
    if (!_titleView) {
        _titleView = [[SSJBudgetDetailPeriodSwitchControl alloc] init];
        [_titleView addTarget:self action:@selector(changeSelectedMonth) forControlEvents:UIControlEventValueChanged];
    }
    return _titleView;
}

- (UILabel *)periodLabel {
    if (!_periodLabel) {
        _periodLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, 20)];
        _periodLabel.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarBackgroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        _periodLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _periodLabel.font = [UIFont systemFontOfSize:13];
        _periodLabel.textAlignment = NSTextAlignmentCenter;
        _periodLabel.hidden = YES;
    }
    return _periodLabel;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.periodLabel.bottom, self.view.width, self.view.height - self.periodLabel.bottom)];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.hidden = YES;
    }
    return _scrollView;
}

- (SSJBudgetDetailHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[SSJBudgetDetailHeaderView alloc] init];
    }
    return _headerView;
}

- (SSJBudgetDetailMiddleTitleView *)middleView {
    if (!_middleView) {
        _middleView = [[SSJBudgetDetailMiddleTitleView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
    }
    return _middleView;
}

- (SSJBudgetDetailBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[SSJBudgetDetailBottomView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 466)];
        _bottomView.circleView.dataSource = self;
        [_bottomView.button addTarget:self action:@selector(editButtonAction)];
    }
    return _bottomView;
}

- (SSJBudgetNodataRemindView *)noDataRemindView {
    if (!_noDataRemindView) {
        _noDataRemindView = [[SSJBudgetNodataRemindView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 260)];
    }
    return _noDataRemindView;
}

@end
