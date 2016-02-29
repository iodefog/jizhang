//
//  SSJBudgetDetailViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetDetailViewController.h"
#import "SSJBudgetEditViewController.h"
#import "SSJBudgetDetailNavigationTitleView.h"
#import "SSJBudgetDetailHeaderView.h"
#import "SSJBudgetDetailBottomView.h"
#import "SSJBudgetDetailMiddleTitleView.h"
#import "SSJBorderButton.h"
#import "SSJPercentCircleView.h"
#import "SSJBudgetDatabaseHelper.h"

static const CGFloat kHeaderMargin = 8;

static const CGFloat kHeaderViewHeight = 295;

static const CGFloat kbudgetTitleLabelHeight = 40;

static const CGFloat kBottomViewHeight = 466;

@interface SSJBudgetDetailViewController () <SSJReportFormsPercentCircleDataSource>

//  导航栏标题视图
@property (nonatomic, strong) SSJBudgetDetailNavigationTitleView *titleView;

//  底层滚动视图
@property (nonatomic, strong) UIScrollView *scrollView;

//  包含本月预算、距结算日、已花、超支、波浪图表的视图
@property (nonatomic, strong) SSJBudgetDetailHeaderView *headerView;

//  预算消费明细的标题视图
@property (nonatomic, strong) SSJBudgetDetailMiddleTitleView *middleView;

//  包含预算消费明细图表、编辑按钮
@property (nonatomic, strong) SSJBudgetDetailBottomView *bottomView;

//  预算数据模型
@property (nonatomic, strong) SSJBudgetModel *budgetModel;

//  预算消费明细图表的数据源
@property (nonatomic, strong) NSArray *circleItems;

//  月预算历史id列表
@property (nonatomic, strong) NSArray *monthBudgetIdList;

//  月预算标题
@property (nonatomic, strong) NSArray *monthTitles;

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
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.headerView];
    [self.scrollView addSubview:self.middleView];
    [self.scrollView addSubview:self.bottomView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor ssj_colorWithHex:@"#47cfbe"];
    [self loadAllData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.scrollView.height = self.view.height;
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
    [self.view ssj_showLoadingIndicator];
    NSString *budgetId = [self.monthBudgetIdList ssj_safeObjectAtIndex:self.titleView.currentIndex];
    
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
        
        //  如果是月预算，需要再查询历史月预算id；否则直接刷新页面
        if (self.budgetModel.type == 1) {
            [SSJBudgetDatabaseHelper queryForMonthBudgetIdListWithSuccess:^(NSArray<NSString *> * _Nonnull result) {
                [self.view ssj_hideLoadingIndicator];
                
                self.monthTitles = [result valueForKeyPath:SSJBudgetMonthTitleKey];
                self.monthBudgetIdList = [result valueForKeyPath:SSJBudgetMonthIDKey];
                if ([self.monthBudgetIdList indexOfObject:self.budgetId] == NSNotFound) {
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
    self.scrollView.hidden = NO;
    
    NSString *tStr = nil;
    switch (self.budgetModel.type) {
        case 0:
            tStr = @"周";
            [self.titleView setTitles:@[@"周预算"]];
            [self.titleView setButtonShowed:NO];
            break;
            
        case 1:
            tStr = @"月";
            [self.titleView setTitles:self.monthTitles];
            [self.titleView setButtonShowed:YES];
            break;
            
        case 2:
            tStr = @"年";
            [self.titleView setTitles:@[@"年预算"]];
            [self.titleView setButtonShowed:NO];
            break;
    }
    self.titleView.currentIndex = [self.monthBudgetIdList indexOfObject:self.budgetId];
    
    [self.headerView setBudgetModel:self.budgetModel];
    [self.bottomView.circleView reloadData];
    
    NSString *beginDate = [self.budgetModel.beginDate ssj_dateStringFromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-M-dd"];
    NSString *endDate = [self.budgetModel.endDate ssj_dateStringFromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-M-dd"];
    [self.middleView setTitle:[NSString stringWithFormat:@"%@预算消费明细", tStr]];
    [self.middleView setPeriod:[NSString stringWithFormat:@"%@——%@", beginDate, endDate]];
}

#pragma mark - Getter
- (SSJBudgetDetailNavigationTitleView *)titleView {
    if (!_titleView) {
        _titleView = [[SSJBudgetDetailNavigationTitleView alloc] init];
        [_titleView addTarget:self action:@selector(changeSelectedMonth) forControlEvents:UIControlEventValueChanged];
    }
    return _titleView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        _scrollView.contentSize = CGSizeMake(self.view.width, kHeaderMargin + kHeaderViewHeight + kbudgetTitleLabelHeight + kBottomViewHeight);
        _scrollView.backgroundColor = [UIColor ssj_colorWithHex:@"#f6f6f6"];
        _scrollView.hidden = YES;
    }
    return _scrollView;
}

- (SSJBudgetDetailHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[SSJBudgetDetailHeaderView alloc] initWithFrame:CGRectMake(0, kHeaderMargin, self.view.width, kHeaderViewHeight)];
    }
    return _headerView;
}

- (SSJBudgetDetailMiddleTitleView *)middleView {
    if (!_middleView) {
        _middleView = [[SSJBudgetDetailMiddleTitleView alloc] initWithFrame:CGRectMake(0, kHeaderMargin + kHeaderViewHeight, self.view.width, kbudgetTitleLabelHeight)];
    }
    return _middleView;
}

- (SSJBudgetDetailBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[SSJBudgetDetailBottomView alloc] initWithFrame:CGRectMake(0, kHeaderMargin + kHeaderViewHeight + kbudgetTitleLabelHeight, self.view.width, kBottomViewHeight)];
        _bottomView.circleView.dataSource = self;
        [_bottomView.button addTarget:self action:@selector(editButtonAction)];
    }
    return _bottomView;
}

@end
