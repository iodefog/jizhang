//
//  SSJBudgetDetailViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetDetailViewController.h"
#import "SSJBudgetDetailNavigationTitleView.h"
#import "SSJBudgetDetailHeaderView.h"
#import "SSJBudgetDetailBottomView.h"
#import "SSJBorderButton.h"
#import "SSJPercentCircleView.h"
#import "SSJBudgetHelper.h"

static const CGFloat kHeaderMargin = 8;

static const CGFloat kHeaderViewHeight = 266;

static const CGFloat kbudgetTitleLabelHeight = 40;

static const CGFloat kBottomViewHeight = 466;

@interface SSJBudgetDetailViewController () <SSJReportFormsPercentCircleDataSource>

@property (nonatomic, strong) SSJBudgetDetailNavigationTitleView *titleView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) SSJBudgetDetailHeaderView *headerView;

@property (nonatomic, strong) UILabel *budgetTitleLabel;

@property (nonatomic, strong) SSJBudgetDetailBottomView *bottomView;

@property (nonatomic, strong) SSJBudgetModel *budgetModel;

@property (nonatomic, strong) NSArray *circleItems;

@property (nonatomic, strong) NSArray *budgetIdList;

@property (nonatomic) NSUInteger selectedBudgetIdIndex;

@end

@implementation SSJBudgetDetailViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = self.titleView;
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.headerView];
    [self.scrollView addSubview:self.budgetTitleLabel];
    [self.scrollView addSubview:self.bottomView];
    
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
    
}

- (void)preMonthButtonAction {
    if (self.selectedBudgetIdIndex > 0) {
        self.selectedBudgetIdIndex --;
    }
    [self reloadBudgetData];
}

- (void)nextMonthButtonAction {
    if (self.selectedBudgetIdIndex < self.budgetIdList.count - 1) {
        self.selectedBudgetIdIndex ++;
    }
    [self reloadBudgetData];
}

#pragma mark - Private
- (void)loadAllData {
    [self.view ssj_showLoadingIndicator];
    
    [SSJBudgetHelper queryForBudgetDetailWithID:self.budgetId success:^(NSDictionary * _Nonnull result) {
        self.budgetModel = result[SSJBudgetModelKey];
        self.circleItems = result[SSJBudgetCircleItemsKey];
        
        NSString *tStr = nil;
        switch (self.budgetModel.type) {
            case 0:
                tStr = @"周";
                self.titleView.preButton.hidden = self.titleView.nextButton.hidden = YES;
                break;
                
            case 1:
                tStr = @"月";
                break;
                
            case 2:
                tStr = @"年";
                self.titleView.preButton.hidden = self.titleView.nextButton.hidden = YES;
                break;
        }
        self.titleView.titleLabel.text = [NSString stringWithFormat:@"%@预算", tStr];
        [self.titleView sizeToFit];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.headIndent = 15;
        style.firstLineHeadIndent = 15;
        self.budgetTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@预算消费明细", tStr] attributes:@{NSParagraphStyleAttributeName:style}];
        
        [SSJBudgetHelper queryForMonthBudgetIdListWithSuccess:^(NSArray<NSString *> * _Nonnull result) {
            [self.view ssj_hideLoadingIndicator];
            
            self.budgetIdList = result;
            self.selectedBudgetIdIndex = [result indexOfObject:self.budgetId];
            if (self.selectedBudgetIdIndex == NSNotFound) {
                SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
                [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:SSJ_ERROR_MESSAGE action:action, nil];
                return;
            }
            
            self.headerView.hidden = NO;
            self.budgetTitleLabel.hidden = NO;
            self.bottomView.hidden = NO;
            
            [self.headerView setBudgetModel:self.budgetModel];
            [self.bottomView.circleView reloadData];
            
            NSString *beginDate = [self.budgetModel.beginDate ssj_dateStringFromFormat:@"yyyy-MM-dd" toFormat:@"yyyy年M月d日"];
            NSString *endDate = [self.budgetModel.endDate ssj_dateStringFromFormat:@"yyyy-MM-dd" toFormat:@"yyyy年M月d日"];
            self.bottomView.timeRangeLabel.text = [NSString stringWithFormat:@"预算日期：%@——%@", beginDate, endDate];
            
        } failure:^(NSError * _Nullable error) {
            
            [self.view ssj_hideLoadingIndicator];
            SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
            [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:SSJ_ERROR_MESSAGE action:action, nil];
            
        }];
        
    } failure:^(NSError * _Nullable error) {
        
        [self.view ssj_hideLoadingIndicator];
        SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:SSJ_ERROR_MESSAGE action:action, nil];
        
    }];
}

- (void)reloadBudgetData {
    [self.view ssj_showLoadingIndicator];
    NSString *budgetId = [self.budgetIdList ssj_safeObjectAtIndex:self.selectedBudgetIdIndex];
    
    [SSJBudgetHelper queryForBudgetDetailWithID:budgetId success:^(NSDictionary * _Nonnull result) {
        [self.view ssj_hideLoadingIndicator];
        
        self.budgetModel = result[SSJBudgetModelKey];
        self.circleItems = result[SSJBudgetCircleItemsKey];
        
        [self.headerView setBudgetModel:self.budgetModel];
        [self.bottomView.circleView reloadData];
        
        NSString *beginDate = [self.budgetModel.beginDate ssj_dateStringFromFormat:@"yyyy-MM-dd" toFormat:@"yyyy年M月d日"];
        NSString *endDate = [self.budgetModel.endDate ssj_dateStringFromFormat:@"yyyy-MM-dd" toFormat:@"yyyy年M月d日"];
        self.bottomView.timeRangeLabel.text = [NSString stringWithFormat:@"预算日期：%@——%@", beginDate, endDate];
        
    } failure:^(NSError * _Nullable error) {
        [self.view ssj_hideLoadingIndicator];
        SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:SSJ_ERROR_MESSAGE action:action, nil];
    }];
}

#pragma mark - Getter
- (SSJBudgetDetailNavigationTitleView *)titleView {
    if (!_titleView) {
        _titleView = [[SSJBudgetDetailNavigationTitleView alloc] init];
        [_titleView.preButton addTarget:self action:@selector(preMonthButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_titleView.nextButton addTarget:self action:@selector(nextMonthButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _titleView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        _scrollView.contentSize = CGSizeMake(self.view.width, kHeaderMargin + kHeaderViewHeight + kbudgetTitleLabelHeight + kBottomViewHeight);
        _scrollView.backgroundColor = [UIColor ssj_colorWithHex:@"#f6f6f6"];
    }
    return _scrollView;
}

- (SSJBudgetDetailHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[SSJBudgetDetailHeaderView alloc] initWithFrame:CGRectMake(0, kHeaderMargin, self.view.width, kHeaderViewHeight)];
    }
    return _headerView;
}

- (UILabel *)budgetTitleLabel {
    if (!_budgetTitleLabel) {
        _budgetTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kHeaderMargin + kHeaderViewHeight, self.view.width, kbudgetTitleLabelHeight)];
        _budgetTitleLabel.backgroundColor = [UIColor ssj_colorWithHex:@"#f6f6f6"];
        _budgetTitleLabel.textColor = [UIColor blackColor];
        _budgetTitleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _budgetTitleLabel;
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
