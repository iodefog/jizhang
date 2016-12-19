//
//  SSJReportFormsCurveViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/6/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveViewController.h"
#import "SSJMagicExportCalendarViewController.h"
#import "SSJSegmentedControl.h"
#import "SSJReportFormsCurveGraphView.h"
#import "SSJReportFormsCurveGridView.h"
#import "SSJReportFormsCurveDescriptionView.h"
#import "SSJBudgetNodataRemindView.h"
#import "SSJReportFormsCurveModel.h"
#import "SSJReportFormsUtil.h"
#import "SSJUserTableManager.h"

@interface SSJReportFormsCurveViewController () <SSJReportFormsCurveGraphViewDelegate>

@property (nonatomic, strong) SSJSegmentedControl *segmentControl;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UILabel *periodLabel;

@property (nonatomic, strong) UIButton *editPeriodBtn;

@property (nonatomic, strong) SSJReportFormsCurveGraphView *curveView;

@property (nonatomic, strong) UIView *questionBackView;

@property (nonatomic, strong) UIButton *questionBtn;

@property (nonatomic, strong) SSJReportFormsCurveDescriptionView *descView;

@property (nonatomic, strong) SSJReportFormsCurveGridView *gridView;

@property (nonatomic, strong) SSJBudgetNodataRemindView *noDataRemindView;

@property (nonatomic, strong) NSArray *datas;

@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, strong) NSDate *endDate;

@end

@implementation SSJReportFormsCurveViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = self.segmentControl;
    
    [self.view addSubview:self.periodLabel];
    [self.view addSubview:self.editPeriodBtn];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.curveView];
    [self.scrollView addSubview:self.questionBackView];
    [self.scrollView addSubview:self.gridView];
    
    self.scrollView.contentSize = CGSizeMake(self.view.width, self.gridView.bottom);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

#pragma mark - SSJReportFormsCurveGraphViewDelegate
- (NSUInteger)numberOfAxisXInCurveGraphView:(SSJReportFormsCurveGraphView *)graphView {
    return _datas.count;
}

- (NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView titleAtAxisXIndex:(NSUInteger)index {
    SSJReportFormsCurveModel *model = [_datas ssj_safeObjectAtIndex:index];
    return model.time;
}

- (CGFloat)curveGraphView:(SSJReportFormsCurveGraphView *)graphView paymentValueAtAxisXIndex:(NSUInteger)index {
    SSJReportFormsCurveModel *model = [_datas ssj_safeObjectAtIndex:index];
    return [model.payment floatValue];
}

- (CGFloat)curveGraphView:(SSJReportFormsCurveGraphView *)graphView incomeValueAtAxisXIndex:(NSUInteger)index {
    SSJReportFormsCurveModel *model = [_datas ssj_safeObjectAtIndex:index];
    return [model.income floatValue];
}

- (void)curveGraphView:(SSJReportFormsCurveGraphView *)graphView didScrollToAxisXIndex:(NSUInteger)index {
    [MobClick event:@"form_curve_move"];
}

#pragma mark - Event
- (void)segmentControlValueDidChange {
    [self reloadData];
    _questionBtn.hidden = _segmentControl.selectedSegmentIndex == 0;
    if (_descView.superview) {
        [_descView dismiss];
    }
    
    if (_segmentControl.selectedSegmentIndex == 0) {
        [MobClick event:@"form_curve_month"];
    } else if (_segmentControl.selectedSegmentIndex == 1) {
        [MobClick event:@"form_curve_week"];
    }
}

- (void)editPeriodBtnAction {
    if (_startDate && _endDate) {
        _startDate = nil;
        _endDate = nil;
        [self reloadData];
        [_editPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_edit"] forState:UIControlStateNormal];
        
        [MobClick event:@"form_curve_date_custom_delete"];
    } else {
        SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"currentBooksId"] forUserId:SSJUSERID()];
        if (!userItem.currentBooksId.length) {
            userItem.currentBooksId = SSJUSERID();
        }
        __weak typeof(self) wself = self;
        SSJMagicExportCalendarViewController *calendarVC = [[SSJMagicExportCalendarViewController alloc] init];
        calendarVC.title = @"自定义时间";
        calendarVC.billType = SSJBillTypeSurplus;
        calendarVC.booksId = userItem.currentBooksId;
        calendarVC.completion = ^(NSDate *selectedBeginDate, NSDate *selectedEndDate) {
            wself.startDate = selectedBeginDate;
            wself.endDate = selectedEndDate;
            [wself.editPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_delete"] forState:UIControlStateNormal];
        };
        [self.navigationController pushViewController:calendarVC animated:YES];
        
        [MobClick event:@"form_curve_date_custom"];
    }
}

- (void)questionBtnAction {
    if (_descView.superview) {
        [_descView dismiss];
    } else {
        CGPoint showPoint = [_questionBtn convertPoint:CGPointMake(_questionBtn.width * 0.5, 22) toView:_scrollView];
        [_descView showInView:_scrollView atPoint:showPoint];
    }
}

#pragma mark - Private
- (void)updatePeriodLabelWithResult:(NSDictionary *)result {
    NSString *beginDateStr = result[SSJReportFormsCurveModelBeginDateKey];
    NSString *endDateStr = result[SSJReportFormsCurveModelEndDateKey];
    _periodLabel.text = [NSString stringWithFormat:@"%@--%@", beginDateStr, endDateStr];
    CGSize textSize = [_periodLabel.text sizeWithAttributes:@{NSFontAttributeName:_periodLabel.font}];
    _periodLabel.width = textSize.width + 28;
    _periodLabel.center = CGPointMake(self.view.width * 0.5, 25 + SSJ_NAVIBAR_BOTTOM);
}

- (void)updateGirdViewWithResult:(NSDictionary *)result {
    double income = 0;
    double payment = 0;
    for (SSJReportFormsCurveModel *model in _datas) {
        income += [model.income doubleValue];
        payment += [model.payment doubleValue];
    }
    _gridView.income = income;
    _gridView.payment = payment;
    _gridView.surplus = income - payment;
    
    int dayCount = 0;
    if (_startDate && _endDate) {
        dayCount = [_endDate timeIntervalSinceDate:_startDate] / (24 * 60 * 60);
    } else {
        NSString *startDateStr = result[SSJReportFormsCurveModelBeginDateKey];
        NSString *endDateStr = result[SSJReportFormsCurveModelEndDateKey];
        NSDate *startDate = [NSDate dateWithString:startDateStr formatString:@"yyyy-MM-dd"];
        NSDate *endDate = [NSDate dateWithString:endDateStr formatString:@"yyyy-MM-dd"];
        dayCount = [endDate timeIntervalSinceDate:startDate] / (24 * 60 * 60);
    }
    dayCount ++;
    _gridView.dailyPayment = payment / dayCount;
}

- (void)updateDescViewWithResult:(NSDictionary *)result {
    SSJReportFormsCurveModel *model = [_datas firstObject];
    if (model.period.periodType != SSJDatePeriodTypeWeek) {
        return;
    }
    
    NSDate *beginDate = nil;
    if (_startDate) {
        beginDate = _startDate;
    } else {
        NSString *beginDateStr = result[SSJReportFormsCurveModelBeginDateKey];
        beginDate = [NSDate dateWithString:beginDateStr formatString:@"yyyy-MM-dd"];
    }
    
    if (!_descView) {
        _descView = [[SSJReportFormsCurveDescriptionView alloc] init];
    }
    _descView.period = [SSJDatePeriod datePeriodWithStartDate:beginDate endDate:model.period.endDate];
}

- (void)reloadData {
    [self.view ssj_showLoadingIndicator];
    [SSJReportFormsUtil queryForBillStatisticsWithTimeDimension:(int)_segmentControl.selectedSegmentIndex startDate:_startDate endDate:_endDate booksId:nil success:^(NSDictionary *result) {
        
        [self.view ssj_hideLoadingIndicator];
        _datas = result[SSJReportFormsCurveModelListKey];
        
        if (_datas.count > 0) {
            [_curveView reloadData];
            if (_datas.count >= 1) {
                [_curveView scrollToAxisXAtIndex:_datas.count - 1 animated:NO];
            }
            [self updatePeriodLabelWithResult:result];
            [self updateGirdViewWithResult:result];
            [self updateDescViewWithResult:result];
            
            _scrollView.hidden = NO;
            [self.view ssj_hideWatermark:YES];
        } else {
            _scrollView.hidden = YES;
            [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
        }
        
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    }];
}

#pragma mark - Getter
- (SSJSegmentedControl *)segmentControl {
    if (!_segmentControl) {
        _segmentControl = [[SSJSegmentedControl alloc] initWithItems:@[@"月", @"周"]];
        _segmentControl.size = CGSizeMake(150, 30);
        _segmentControl.font = [UIFont systemFontOfSize:15];
        _segmentControl.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _segmentControl.selectedBorderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        [_segmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]} forState:UIControlStateNormal];
        [_segmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]} forState:UIControlStateSelected];
        [_segmentControl addTarget:self action:@selector(segmentControlValueDidChange) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentControl;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM + 50, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM - 50)];
        _scrollView.backgroundColor = [UIColor clearColor];
    }
    return _scrollView;
}

- (UILabel *)periodLabel {
    if (!_periodLabel) {
        _periodLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, 0, 30)];
        _periodLabel.textAlignment = NSTextAlignmentCenter;
        _periodLabel.font = [UIFont systemFontOfSize:15];
        _periodLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _periodLabel.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor].CGColor;
        _periodLabel.layer.borderWidth = 1;
        _periodLabel.layer.cornerRadius = 15;
    }
    return _periodLabel;
}

- (UIButton *)editPeriodBtn {
    if (!_editPeriodBtn) {
        _editPeriodBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editPeriodBtn.frame = CGRectMake(self.view.width - 50, SSJ_NAVIBAR_BOTTOM, 50, 50);
        [_editPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_edit"] forState:UIControlStateNormal];
        [_editPeriodBtn addTarget:self action:@selector(editPeriodBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editPeriodBtn;
}

- (SSJReportFormsCurveGraphView *)curveView {
    if (!_curveView) {
        _curveView = [[SSJReportFormsCurveGraphView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 384)];
        _curveView.delegate = self;
    }
    return _curveView;
}

- (UIView *)questionBackView {
    if (!_questionBackView) {
        _questionBackView = [[UIView alloc] initWithFrame:CGRectMake(0, self.curveView.bottom, self.view.width, 30)];
        _questionBackView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [_questionBackView addSubview:self.questionBtn];
    }
    return _questionBackView;
}

- (UIButton *)questionBtn {
    if (!_questionBtn) {
        _questionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _questionBtn.hidden = YES;
        _questionBtn.frame = CGRectMake(8, 0, 30, 30);
        [_questionBtn setImage:[UIImage imageNamed:@"reportForms_question"] forState:UIControlStateNormal];
        [_questionBtn addTarget:self action:@selector(questionBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _questionBtn;
}

- (SSJReportFormsCurveGridView *)gridView {
    if (!_gridView) {
        _gridView = [[SSJReportFormsCurveGridView alloc] initWithFrame:CGRectMake(0, self.questionBackView.bottom + 10, self.view.width, 254)];
    }
    return _gridView;
}

- (SSJBudgetNodataRemindView *)noDataRemindView {
    if (!_noDataRemindView) {
        _noDataRemindView = [[SSJBudgetNodataRemindView alloc] initWithFrame:CGRectMake(0, 50, self.view.width, 210)];
        _noDataRemindView.title = @"报表空空如也";
        _noDataRemindView.image = @"budget_no_data";
    }
    return _noDataRemindView;
}

@end
