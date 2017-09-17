//
//  SSJSummaryBooksTableViewHeader.m
//  SuiShouJi
//
//  Created by ricky on 16/11/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSummaryBooksTableViewHeader.h"
#import "SSJSummaryBooksHeaderView.h"
#import "SSJBudgetNodataRemindView.h"

@interface SSJSummaryBooksTableViewHeader()

@property(nonatomic, strong) SSJSummaryBooksHeaderView *summaryHeader;

//  周期选择(日周月)
@property (nonatomic, strong) SSJSegmentedControl *periodSelectSegment;

@property(nonatomic, strong) UIView *backColorView;

@property(nonatomic, strong) UILabel *firstLineLab;

@property(nonatomic, strong) UILabel *secondLineLab;

@property(nonatomic, strong) SSJBudgetNodataRemindView *chartNoResultView;

@property(nonatomic, strong) SSJBudgetNodataRemindView *curveNoResultView;

@end


@implementation SSJSummaryBooksTableViewHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.summaryHeader];
        [self addSubview:self.periodControl];
        [self addSubview:self.backColorView];
        [self addSubview:self.firstLineLab];
        [self addSubview:self.periodSelectSegment];
        [self addSubview:self.curveView];
        [self addSubview:self.curveNoResultView];
        [self addSubview:self.secondLineLab];
        [self addSubview:self.incomOrExpenseSelectSegment];
        [self addSubview:self.chartView];
        [self addSubview:self.chartNoResultView];
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.summaryHeader.leftTop = CGPointMake(0, 0);
    self.periodControl.leftTop = CGPointMake(0, self.summaryHeader.bottom);
    self.backColorView.leftTop = CGPointMake(0, self.periodControl.bottom);
    self.backColorView.size = CGSizeMake(self.width, self.height - self.periodControl.bottom);
    self.firstLineLab.top = self.periodControl.bottom + 37;
    self.firstLineLab.centerX = self.width / 2;
    self.periodSelectSegment.top = self.firstLineLab.bottom + 20;
    self.periodSelectSegment.centerX = self.width / 2;
    self.curveView.leftTop = CGPointMake(0, self.periodSelectSegment.bottom + 29);
    self.curveNoResultView.frame = self.curveView.frame;
    self.secondLineLab.top = self.curveView.bottom + 50;
    self.secondLineLab.centerX = self.width / 2;
    self.incomOrExpenseSelectSegment.top = self.secondLineLab.bottom + 20;
    self.incomOrExpenseSelectSegment.centerX = self.width / 2;
    self.chartView.leftTop = CGPointMake(0, self.incomOrExpenseSelectSegment.bottom + 29);
    self.chartNoResultView.frame = self.chartView.frame;
    
    [self updateCurveUnitAxisXLength];
}

- (SSJReportFormsPeriodSelectionControl *)periodControl {
    if (!_periodControl) {
        _periodControl = [[SSJReportFormsPeriodSelectionControl alloc] initWithFrame:CGRectMake(0, 0, self.width, 40)];
        _periodControl.layer.zPosition = 100;
    }
    return _periodControl;
}

- (SSJPercentCircleView *)chartView {
    if (!_chartView) {
        _chartView = [[SSJPercentCircleView alloc] initWithFrame:CGRectMake(0, 70, self.width, 270) radius:80 thickness:20 lineLength1:15 lineLength2:10];
        _chartView.backgroundColor = [UIColor clearColor];
    }
    return _chartView;
}

- (SSJReportFormsCurveGraphView *)curveView {
    if (!_curveView) {
        _curveView = [[SSJReportFormsCurveGraphView alloc] initWithFrame:CGRectMake(0, 0, self.width, 384)];
        _curveView.showBalloon = YES;
        _curveView.showCurveShadow = YES;
        _curveView.backgroundColor = [UIColor clearColor];
    }
    return _curveView;
}

- (SSJSegmentedControl *)periodSelectSegment {
    if (!_periodSelectSegment) {
        _periodSelectSegment = [[SSJSegmentedControl alloc] initWithItems:@[@"日", @"周",@"月"]];
        _periodSelectSegment.size = CGSizeMake(150, 30);
        _periodSelectSegment.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _periodSelectSegment.tag = 100;
        [_periodSelectSegment addTarget:self action:@selector(segmentControlValueDidChange:) forControlEvents:UIControlEventValueChanged];

    }
    return _periodSelectSegment;
}

- (SSJSegmentedControl *)incomOrExpenseSelectSegment {
    if (!_incomOrExpenseSelectSegment) {
        _incomOrExpenseSelectSegment = [[SSJSegmentedControl alloc] initWithItems:@[@"支出",@"收入"]];
        _incomOrExpenseSelectSegment.size = CGSizeMake(225, 30);
        _incomOrExpenseSelectSegment.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _incomOrExpenseSelectSegment.tag = 101;
        [_incomOrExpenseSelectSegment addTarget:self action:@selector(segmentControlValueDidChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _incomOrExpenseSelectSegment;
}

-(UILabel *)firstLineLab{
    if (!_firstLineLab) {
        _firstLineLab = [[UILabel alloc]init];
        _firstLineLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        _firstLineLab.text = @"总账本折线图趋势";
        [_firstLineLab sizeToFit];
    }
    return _firstLineLab;
}

-(UILabel *)secondLineLab{
    if (!_secondLineLab) {
        _secondLineLab = [[UILabel alloc]init];
        _secondLineLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        _secondLineLab.text = @"总账本饼图明细";
        [_secondLineLab sizeToFit];
    }
    return _secondLineLab;
}

- (SSJSummaryBooksHeaderView *)summaryHeader{
    if (!_summaryHeader) {
        _summaryHeader = [[SSJSummaryBooksHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.width, 109)];
    }
    return _summaryHeader;
}

- (SSJBudgetNodataRemindView *)curveNoResultView{
    if (!_curveNoResultView) {
        _curveNoResultView = [[SSJBudgetNodataRemindView alloc]init];
        _curveNoResultView.image = @"budget_no_data";
        _curveNoResultView.title = @"报表空空如也";
        _curveNoResultView.hidden = YES;
    }
    return _curveNoResultView;
}

- (SSJBudgetNodataRemindView *)chartNoResultView{
    if (!_chartNoResultView) {
        _chartNoResultView = [[SSJBudgetNodataRemindView alloc]init];
        _chartNoResultView.image = @"budget_no_data";
        _chartNoResultView.title = @"报表空空如也";
        _chartNoResultView.hidden = YES;
    }
    return _chartNoResultView;
}

- (UIView *)backColorView{
    if (!_backColorView) {
        _backColorView = [[UIView alloc]init];

    }
    return _backColorView;
}

- (void)setTotalIncome:(double)totalIncome{
    _totalIncome = totalIncome;
    self.summaryHeader.income = _totalIncome;
}

- (void)setTotalExpenture:(double)totalExpenture{
    _totalExpenture = totalExpenture;
    self.summaryHeader.expenture = _totalExpenture;
}

- (void)setTitle:(NSString *)title {
    _chartView.bottomTitle = title;
}

- (void)setAmount:(NSString *)amount {
    _chartView.topTitle = amount;
}

- (void)setChartViewHasDataOrNot:(BOOL)chartViewHasDataOrNot{
    _chartViewHasDataOrNot = chartViewHasDataOrNot;
    if (!_chartViewHasDataOrNot) {
        self.chartView.hidden = YES;
        self.chartNoResultView.hidden = NO;
    }else{
        self.chartView.hidden = NO;
        self.chartNoResultView.hidden = YES;
    }
}

- (void)setCurveViewHasDataOrNot:(BOOL)curveViewHasDataOrNot{
    _curveViewHasDataOrNot = curveViewHasDataOrNot;
    if (!_curveViewHasDataOrNot) {
        self.curveView.hidden = YES;
        self.curveNoResultView.hidden = NO;
        self.chartView.hidden = YES;
        self.chartNoResultView.hidden = NO;
    }else{
        self.curveView.hidden = NO;
        self.curveNoResultView.hidden = YES;
        self.chartView.hidden = NO;
        self.chartNoResultView.hidden = YES;
    }
}

- (void)segmentControlValueDidChange:(SSJSegmentedControl *)sender{
    if (sender.tag == 100) {
        [self updateCurveUnitAxisXLength];
        if (self.periodSelectBlock) {
            self.periodSelectBlock();
        }
    }else{
        if (self.incomeOrExpentureSelectBlock) {
            self.incomeOrExpentureSelectBlock();
        }
    }
}

- (void)updateCurveUnitAxisXLength {
    switch ([self dimension]) {
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

- (SSJTimeDimension)dimension {
    if (_periodSelectSegment.selectedSegmentIndex == 0) {
        return SSJTimeDimensionDay;
    } else if (_periodSelectSegment.selectedSegmentIndex == 1) {
        return SSJTimeDimensionWeek;
    } else if (_periodSelectSegment.selectedSegmentIndex == 2) {
        return SSJTimeDimensionMonth;
    } else {
        return SSJTimeDimensionUnknown;
    }
}

- (void)setDimension:(SSJTimeDimension)dimension {
    switch (dimension) {
        case SSJTimeDimensionDay:
            _periodSelectSegment.selectedSegmentIndex = 0;
            break;
            
        case SSJTimeDimensionWeek:
            _periodSelectSegment.selectedSegmentIndex = 1;
            break;
            
        case SSJTimeDimensionMonth:
            _periodSelectSegment.selectedSegmentIndex = 2;
            break;
            
        case SSJTimeDimensionUnknown:
            break;
    }
    [self updateCurveUnitAxisXLength];
}

- (void)updateAppearance {
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    self.backColorView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    
    _chartView.addtionTextColor = SSJ_SECONDARY_COLOR;
    _chartView.topTitleAttribute = @{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1],
                                     NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]};
    _chartView.bottomTitleAttribute = @{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5],
                                        NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]};
    
    [self.periodControl updateAppearance];
    
    _periodSelectSegment.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _periodSelectSegment.selectedBorderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    [_periodSelectSegment setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]} forState:UIControlStateNormal];
    [_periodSelectSegment setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]} forState:UIControlStateSelected];
    
    _incomOrExpenseSelectSegment.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _incomOrExpenseSelectSegment.selectedBorderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    [_incomOrExpenseSelectSegment setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]} forState:UIControlStateNormal];
    [_incomOrExpenseSelectSegment setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]} forState:UIControlStateSelected];
    
    _firstLineLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _secondLineLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    
    [_curveView reloadData];
    _curveView.scaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor];
    _curveView.balloonTitleAttributes = @{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4],
                                          NSForegroundColorAttributeName:[UIColor whiteColor],
                                          NSBackgroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.bookKeepingHomeMutiButtonSelectColor]};
}

@end
