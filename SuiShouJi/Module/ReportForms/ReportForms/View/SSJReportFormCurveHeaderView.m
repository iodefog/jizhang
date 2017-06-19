//
//  SSJReportFormCurveHeaderView.m
//  SuiShouJi
//
//  Created by old lang on 16/12/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormCurveHeaderView.h"
#import "SCYSlidePagingHeaderView.h"
#import "SSJReportFormsCurveGraphView.h"
#import "SSJReportFormsCurveDescriptionView.h"
#import "SSJSeparatorFormView.h"
#import "SSJReportFormsCurveModel.h"
#import "SSJDatePeriod.h"

static const CGFloat kSpaceHeight = 10;

static const CGFloat kTimePeriodSegmentControlHeight = 40;

static const CGFloat kCurveViewHeight = 350;

static const CGFloat kSeparatorFormViewHeight = 88;

@interface SSJReportFormCurveHeaderView () <SCYSlidePagingHeaderViewDelegate, SSJReportFormsCurveGraphViewDataSource, SSJReportFormsCurveGraphViewDelegate, SSJSeparatorFormViewDataSource>

//  日、周、月切换控件
@property (nonatomic, strong) SCYSlidePagingHeaderView *timePeriodSegmentControl;

@property (nonatomic, strong) SSJReportFormsCurveGraphView *curveView;

@property (nonatomic, strong) SSJReportFormsCurveDescriptionView *descView;

@property (nonatomic, strong) SSJSeparatorFormView *separatorFormView;

@property (nonatomic, strong) UIButton *questionBtn;

@property (nonatomic, strong) SSJSeparatorFormViewCellItem *incomeItem;

@property (nonatomic, strong) SSJSeparatorFormViewCellItem *paymentItem;

@property (nonatomic, strong) SSJSeparatorFormViewCellItem *dailyCostItem;

@property (nonatomic) BOOL showCurveLoading;

@end

@implementation SSJReportFormCurveHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.separatorFormView];
        [self addSubview:self.timePeriodSegmentControl];
        [self addSubview:self.curveView];
        
        [self.curveView addSubview:self.questionBtn];
        
        [self updateAppearanceAccordingToTheme];
        [self updateQuestionBtnHidden];
        [self reloadSeparatorFormViewData];
        
        [self sizeToFit];
    }
    return self;
}

- (void)layoutSubviews {
    
    _separatorFormView.frame = CGRectMake(0, kSpaceHeight, self.width, kSeparatorFormViewHeight);
    
    _timePeriodSegmentControl.frame = CGRectMake(0, _separatorFormView.bottom + kSpaceHeight, self.width, kTimePeriodSegmentControlHeight);
    [_timePeriodSegmentControl setTabSize:CGSizeMake(_timePeriodSegmentControl.width * 0.33, 2)];
    
    _curveView.frame = CGRectMake(0, _timePeriodSegmentControl.bottom, self.width, kCurveViewHeight);
    _curveView.curveInsets = UIEdgeInsetsMake(50, 0, 50, 0);
    [self updateCurveUnitAxisXLength];
    [_curveView ssj_relayoutLoadingIndicator];
    
    _questionBtn.frame = CGRectMake(60, _curveView.height - 28, 28, 28);
}

- (CGSize)sizeThatFits:(CGSize)size {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    return CGSizeMake(window.width, kSpaceHeight * 3 + kTimePeriodSegmentControlHeight + kCurveViewHeight + kSeparatorFormViewHeight);
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    if (index == 0) {
        _item.timeDimension = SSJTimeDimensionDay;
    } else if (index == 1) {
        _item.timeDimension = SSJTimeDimensionWeek;
    } else if (index == 2) {
        _item.timeDimension = SSJTimeDimensionMonth;
    } else {
        SSJPRINT(@"未定义选中下标执行的逻辑");
        return;
    }
    
    [self updateCurveUnitAxisXLength];
    
    [self updateQuestionBtnHidden];
    
    [_descView dismiss];
    
    if (_changeTimePeriodHandle) {
        _changeTimePeriodHandle(self);
    }
}

#pragma mark - SSJReportFormsCurveGraphViewDataSource
- (NSUInteger)numberOfAxisXInCurveGraphView:(SSJReportFormsCurveGraphView *)graphView {
    if (_showCurveLoading) {
        return 0;
    }
    return self.item.curveModels.count;
}

- (NSUInteger)numberOfCurveInCurveGraphView:(SSJReportFormsCurveGraphView *)graphView {
    return 2;
}

- (double)curveGraphView:(SSJReportFormsCurveGraphView *)graphView valueForCurveAtIndex:(NSUInteger)curveIndex axisXIndex:(NSUInteger)axisXIndex {
    
    SSJReportFormsCurveModel *model = [self.item.curveModels ssj_safeObjectAtIndex:axisXIndex];
    if (curveIndex == 0) {  // 支出
        return model.payment;
    } else if (curveIndex == 1) { // 收入
        return model.income;
    } else {
        return 0;
    }
}

- (NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView titleAtAxisXIndex:(NSUInteger)index {
    SSJReportFormsCurveModel *model = [self.item.curveModels ssj_safeObjectAtIndex:index];
    switch (_item.timeDimension) {
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

- (UIColor *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView colorForCurveAtIndex:(NSUInteger)curveIndex {
    if (curveIndex == 0) { // 支出
        return [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentColor];
    } else if (curveIndex == 1) { // 收入
        return [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurveIncomeColor];
    } else {
        return nil;
    }
}

- (nullable NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView suspensionTitleAtAxisXIndex:(NSUInteger)index {
    
    SSJReportFormsCurveModel *model = [self.item.curveModels ssj_safeObjectAtIndex:index];
    if (index == 0) {
        switch (_item.timeDimension) {
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
    
    SSJReportFormsCurveModel *lastModel = [self.item.curveModels ssj_safeObjectAtIndex:index - 1];
    switch (_item.timeDimension) {
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

#pragma mark - SSJReportFormsCurveGraphViewDelegate
- (void)curveGraphView:(SSJReportFormsCurveGraphView *)graphView didScrollToAxisXIndex:(NSUInteger)index {
    [SSJAnaliyticsManager event:@"form_curve_move"];
}

- (NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView titleForBallonAtAxisXIndex:(NSUInteger)index {
    SSJReportFormsCurveModel *model = [self.item.curveModels ssj_safeObjectAtIndex:index];
    NSString *surplusStr = [NSString stringWithFormat:@"%f", (model.income - model.payment)];
    return [NSString stringWithFormat:@"结余%@", [surplusStr ssj_moneyDecimalDisplayWithDigits:2]];
}

- (NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView titleForBallonLabelAtCurveIndex:(NSUInteger)curveIndex axisXIndex:(NSUInteger)axisXIndex {
    SSJReportFormsCurveModel *model = [self.item.curveModels ssj_safeObjectAtIndex:axisXIndex];
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
        return _incomeItem;
    } else if (index.row == 1) {
        return _paymentItem;
    } else if (index.row == 2) {
        return _dailyCostItem;
    } else {
        return nil;
    }
}

#pragma mark - Public
- (void)setItem:(SSJReportFormCurveHeaderViewItem *)item {
//    if ([_item isEqualToItem:item]) {
//        return;
//    }
    
    _item = item;
    
    SSJReportFormsCurveModel *firstModel = [_item.curveModels firstObject];
    self.descView.period = [SSJDatePeriod datePeriodWithStartDate:firstModel.startDate endDate:firstModel.endDate];
    
    switch (_item.timeDimension) {
        case SSJTimeDimensionDay:
        {
            [SSJAnaliyticsManager event:@"forms_line_day"];
            [_timePeriodSegmentControl setSelectedIndex:0 animated:NO];
        }
            
            break;
            
        case SSJTimeDimensionWeek:
        {
            [SSJAnaliyticsManager event:@"forms_line_week"];
            [_timePeriodSegmentControl setSelectedIndex:1 animated:NO];
        }
            break;
            
        case SSJTimeDimensionMonth:
        {
            [SSJAnaliyticsManager event:@"forms_line_month"];
            [_timePeriodSegmentControl setSelectedIndex:2 animated:NO];
        }
            break;
            
        case SSJTimeDimensionUnknown:
            break;
    }
    
    [self updateQuestionBtnHidden];
    
    [_descView dismiss];
    
    [_curveView reloadData];
    [_curveView scrollToAxisXAtIndex:(_item.curveModels.count - 1) animated:NO];
    [self updateCurveUnitAxisXLength];
    
    [self reloadSeparatorFormViewData];
}

- (void)showLoadingOnSeparatorForm {
    [_separatorFormView showTopLoadingIndicatorAtRowIndex:0 cellIndex:0];
    [_separatorFormView showTopLoadingIndicatorAtRowIndex:0 cellIndex:1];
    [_separatorFormView showTopLoadingIndicatorAtRowIndex:0 cellIndex:2];
}

- (void)hideLoadingOnSeparatorForm {
    [_separatorFormView hideTopLoadingIndicatorAtRowIndex:0 cellIndex:0];
    [_separatorFormView hideTopLoadingIndicatorAtRowIndex:0 cellIndex:1];
    [_separatorFormView hideTopLoadingIndicatorAtRowIndex:0 cellIndex:2];
}

- (void)showLoadingOnCurve {
    _showCurveLoading = YES;
    [_curveView reloadData];
    [_curveView ssj_showLoadingIndicator];
}

- (void)hideLoadingOnCurve {
    _showCurveLoading = NO;
    [_curveView reloadData];
    [_curveView ssj_hideLoadingIndicator];
}

- (void)updateAppearanceAccordingToTheme {
    
    [_curveView reloadData];
    _curveView.scaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor];
    _curveView.balloonTitleAttributes = @{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4],
                                    NSForegroundColorAttributeName:[UIColor whiteColor],
                                    NSBackgroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.bookKeepingHomeMutiButtonSelectColor]};
    _curveView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    [_curveView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    _separatorFormView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    _separatorFormView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    
    _timePeriodSegmentControl.titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _timePeriodSegmentControl.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    _timePeriodSegmentControl.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    
    _questionBtn.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    
    _incomeItem.topTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurveIncomeColor];
    _incomeItem.bottomTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _paymentItem.topTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentColor];
    _paymentItem.bottomTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _dailyCostItem.topTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _dailyCostItem.bottomTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

#pragma mark - Private
- (void)updateCurveUnitAxisXLength {
    switch (_item.timeDimension) {
        case SSJTimeDimensionDay:
        case SSJTimeDimensionMonth:
            _curveView.unitAxisXLength = self.width / 7;
            break;
            
        case SSJTimeDimensionWeek:
            _curveView.unitAxisXLength = self.width / 5;
            break;
            
        case SSJTimeDimensionUnknown:
            break;
    }
}

- (void)updateQuestionBtnHidden {
    switch (_item.timeDimension) {
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

- (void)reloadSeparatorFormViewData {
    _incomeItem = [SSJSeparatorFormViewCellItem itemWithTopTitle:_item.generalIncome
                                                     bottomTitle:@"期间收入"
                                                   topTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurveIncomeColor]
                                                bottomTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]
                                                    topTitleFont:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2]
                                                 bottomTitleFont:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5]
                                                   contentInsets:UIEdgeInsetsZero];
    
    _paymentItem = [SSJSeparatorFormViewCellItem itemWithTopTitle:_item.generalPayment
                                                      bottomTitle:@"期间支出"
                                                    topTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentColor]
                                                 bottomTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]
                                                     topTitleFont:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2]
                                                  bottomTitleFont:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5]
                                                    contentInsets:UIEdgeInsetsZero];
    
    double surplus = [_item.generalIncome doubleValue] - [_item.generalPayment doubleValue];
    _dailyCostItem = [SSJSeparatorFormViewCellItem itemWithTopTitle:[NSString stringWithFormat:@"%.2f", surplus]
                                                        bottomTitle:@"期间结余"
                                                      topTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]
                                                   bottomTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]
                                                       topTitleFont:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2]
                                                    bottomTitleFont:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5]
                                                      contentInsets:UIEdgeInsetsZero];
    [_separatorFormView reloadData];
}

#pragma mark - Event
- (void)questionBtnAction {
    if (_descView.superview) {
        [_descView dismiss];
    } else {
        CGPoint showPoint = [_questionBtn convertPoint:CGPointMake(_questionBtn.width * 0.5, _questionBtn.height - 5) toView:self.superview];
        [_descView showInView:self.superview atPoint:showPoint];
    }
}

#pragma mark - LazyLoading
- (SCYSlidePagingHeaderView *)timePeriodSegmentControl {
    if (!_timePeriodSegmentControl) {
        _timePeriodSegmentControl = [[SCYSlidePagingHeaderView alloc] init];
        _timePeriodSegmentControl.customDelegate = self;
        _timePeriodSegmentControl.buttonClickAnimated = YES;
        _timePeriodSegmentControl.titles = @[@"日", @"周", @"月"];
    }
    return _timePeriodSegmentControl;
}

- (SSJReportFormsCurveGraphView *)curveView {
    if (!_curveView) {
        _curveView = [[SSJReportFormsCurveGraphView alloc] init];
        _curveView.dataSource = self;
        _curveView.delegate = self;
        _curveView.showBalloon = YES;
        _curveView.showCurveShadow = YES;
        
        [_curveView ssj_setBorderWidth:1];
        [_curveView ssj_setBorderStyle:SSJBorderStyleTop];
    }
    return _curveView;
}

- (UIButton *)questionBtn {
    if (!_questionBtn) {
        _questionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_questionBtn setImage:[[UIImage imageNamed:@"reportForms_question"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_questionBtn addTarget:self action:@selector(questionBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _questionBtn;
}

- (SSJSeparatorFormView *)separatorFormView {
    if (!_separatorFormView) {
        _separatorFormView = [[SSJSeparatorFormView alloc] init];
        _separatorFormView.separatorColor = [UIColor whiteColor];
        _separatorFormView.dataSource = self;
    }
    return _separatorFormView;
}

- (SSJReportFormsCurveDescriptionView *)descView {
    if (!_descView) {
        _descView = [[SSJReportFormsCurveDescriptionView alloc] init];
    }
    return _descView;
}

@end
