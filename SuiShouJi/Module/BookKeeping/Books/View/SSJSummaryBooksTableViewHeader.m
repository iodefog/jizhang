//
//  SSJSummaryBooksTableViewHeader.m
//  SuiShouJi
//
//  Created by ricky on 16/11/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSummaryBooksTableViewHeader.h"
#import "SSJSummaryBooksHeaderView.h"

@interface SSJSummaryBooksTableViewHeader()

@property(nonatomic, strong) SSJSummaryBooksHeaderView *summaryHeader;

@property(nonatomic, strong) UILabel *firstLineLab;

@property(nonatomic, strong) UILabel *secondLineLab;

@end


@implementation SSJSummaryBooksTableViewHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self addSubview:self.summaryHeader];
        [self addSubview:self.dateAxisView];
        [self addSubview:self.firstLineLab];
        [self addSubview:self.periodSelectSegment];
        [self addSubview:self.curveView];
        [self addSubview:self.secondLineLab];
        [self addSubview:self.incomOrExpenseSelectSegment];
        [self addSubview:self.chartView];
        [self.chartView addSubview:self.incomeAndPaymentTitleLab];
        [self.chartView addSubview:self.incomeAndPaymentMoneyLab];
        [self addSubview:self.customPeriodBtn];
        [self addSubview:self.addOrDeleteCustomPeriodBtn];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.summaryHeader.leftTop = CGPointMake(0, 0);
    self.dateAxisView.leftTop = CGPointMake(0, self.summaryHeader.bottom);
    self.firstLineLab.top = self.dateAxisView.bottom + 37;
    self.firstLineLab.centerX = self.width / 2;
    self.periodSelectSegment.top = self.firstLineLab.bottom + 20;
    self.periodSelectSegment.centerX = self.width / 2;
    self.curveView.leftTop = CGPointMake(0, self.periodSelectSegment.bottom + 29);
    self.secondLineLab.top = self.curveView.bottom + 50;
    self.secondLineLab.centerX = self.width / 2;
    self.incomOrExpenseSelectSegment.top = self.secondLineLab.bottom + 20;
    self.incomOrExpenseSelectSegment.centerX = self.width / 2;
    self.chartView.leftTop = CGPointMake(0, self.incomOrExpenseSelectSegment.bottom + 29);
    CGRect hollowFrame = UIEdgeInsetsInsetRect(self.chartView.circleFrame, UIEdgeInsetsMake(self.chartView.circleThickness, self.chartView.circleThickness, self.chartView.circleThickness, self.chartView.circleThickness));
    self.incomeAndPaymentTitleLab.frame = CGRectMake(hollowFrame.origin.x, (hollowFrame.size.height - 38) * 0.5 + hollowFrame.origin.y, hollowFrame.size.width, 15);
    self.incomeAndPaymentMoneyLab.frame = CGRectMake(hollowFrame.origin.x, (hollowFrame.size.height - 38) * 0.5 + hollowFrame.origin.y + 20, hollowFrame.size.width, 18);
    self.addOrDeleteCustomPeriodBtn.frame = CGRectMake(self.width - 50, self.dateAxisView.top, 50, 50);
}

- (SSJPercentCircleView *)chartView{
    if (!_chartView) {
        _chartView = [[SSJPercentCircleView alloc] initWithFrame:CGRectMake(0, 0, self.width, 320) insets:UIEdgeInsetsMake(80, 80, 80, 80) thickness:39];
        _chartView.contentView.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [_chartView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        [_chartView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_chartView ssj_setBorderWidth:1];
    }
    return _chartView;
}

- (SSJReportFormsCurveGraphView *)curveView {
    if (!_curveView) {
        _curveView = [[SSJReportFormsCurveGraphView alloc] initWithFrame:CGRectMake(0, 0, self.width, 384)];
    }
    return _curveView;
}

- (SSJReportFormsScaleAxisView *)dateAxisView {
    if (!_dateAxisView) {
        _dateAxisView = [[SSJReportFormsScaleAxisView alloc] initWithFrame:CGRectMake(0, 0, self.width, 50)];
        _dateAxisView.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
        _dateAxisView.scaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _dateAxisView.selectedScaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    }
    return _dateAxisView;
}

- (SSJSegmentedControl *)periodSelectSegment {
    if (!_periodSelectSegment) {
        _periodSelectSegment = [[SSJSegmentedControl alloc] initWithItems:@[@"周",@"月"]];
        _periodSelectSegment.size = CGSizeMake(150, 30);
        _periodSelectSegment.font = [UIFont systemFontOfSize:15];
        _periodSelectSegment.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _periodSelectSegment.selectedBorderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        [_periodSelectSegment setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]} forState:UIControlStateNormal];
        [_periodSelectSegment setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]} forState:UIControlStateSelected];
        _periodSelectSegment.tag = 100;
        [_periodSelectSegment addTarget:self action:@selector(segmentControlValueDidChange:) forControlEvents:UIControlEventValueChanged];

    }
    return _periodSelectSegment;
}

- (SSJSegmentedControl *)incomOrExpenseSelectSegment {
    if (!_incomOrExpenseSelectSegment) {
        _incomOrExpenseSelectSegment = [[SSJSegmentedControl alloc] initWithItems:@[@"支出",@"收入"]];
        _incomOrExpenseSelectSegment.size = CGSizeMake(150, 30);
        _incomOrExpenseSelectSegment.font = [UIFont systemFontOfSize:15];
        _incomOrExpenseSelectSegment.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _incomOrExpenseSelectSegment.selectedBorderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        [_incomOrExpenseSelectSegment setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]} forState:UIControlStateNormal];
        [_incomOrExpenseSelectSegment setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]} forState:UIControlStateSelected];
        _incomOrExpenseSelectSegment.tag = 101;
        [_incomOrExpenseSelectSegment addTarget:self action:@selector(segmentControlValueDidChange:) forControlEvents:UIControlEventValueChanged];

    }
    return _incomOrExpenseSelectSegment;
}

-(UILabel *)firstLineLab{
    if (!_firstLineLab) {
        _firstLineLab = [[UILabel alloc]init];
        _firstLineLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _firstLineLab.font = [UIFont systemFontOfSize:12];
        _firstLineLab.text = @"总账本折线图趋势";
        [_firstLineLab sizeToFit];
    }
    return _firstLineLab;
}

-(UILabel *)secondLineLab{
    if (!_secondLineLab) {
        _secondLineLab = [[UILabel alloc]init];
        _secondLineLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _secondLineLab.font = [UIFont systemFontOfSize:12];
        _secondLineLab.text = @"总账本饼图明细";
        [_secondLineLab sizeToFit];
    }
    return _secondLineLab;
}

- (UILabel *)incomeAndPaymentTitleLab {
    if (!_incomeAndPaymentTitleLab) {
        _incomeAndPaymentTitleLab = [[UILabel alloc] init];
        _incomeAndPaymentTitleLab.backgroundColor = [UIColor clearColor];
        _incomeAndPaymentTitleLab.font = [UIFont systemFontOfSize:15];
        _incomeAndPaymentTitleLab.textAlignment = NSTextAlignmentCenter;
        _incomeAndPaymentTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _incomeAndPaymentTitleLab;
}

- (UILabel *)incomeAndPaymentMoneyLab {
    if (!_incomeAndPaymentMoneyLab) {
        _incomeAndPaymentMoneyLab = [[UILabel alloc] init];
        _incomeAndPaymentMoneyLab.backgroundColor = [UIColor clearColor];
        _incomeAndPaymentMoneyLab.font = [UIFont systemFontOfSize:18];
        _incomeAndPaymentMoneyLab.minimumScaleFactor = 0.66;
        _incomeAndPaymentMoneyLab.adjustsFontSizeToFitWidth = YES;
        _incomeAndPaymentMoneyLab.textAlignment = NSTextAlignmentCenter;
        _incomeAndPaymentMoneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _incomeAndPaymentMoneyLab;
}

- (SSJSummaryBooksHeaderView *)summaryHeader{
    if (!_summaryHeader) {
        _summaryHeader = [[SSJSummaryBooksHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.width, 109)];
    }
    return _summaryHeader;
}

- (UIButton *)customPeriodBtn {
    if (!_customPeriodBtn) {
        _customPeriodBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _customPeriodBtn.frame = CGRectMake(0, self.dateAxisView.top + 10, 0, 30);
        _customPeriodBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_customPeriodBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:UIControlStateNormal];
        _customPeriodBtn.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor].CGColor;
        _customPeriodBtn.layer.borderWidth = 1;
        _customPeriodBtn.layer.cornerRadius = 15;
        _customPeriodBtn.hidden = YES;
    }
    return _customPeriodBtn;
}

- (UIButton *)addOrDeleteCustomPeriodBtn {
    if (!_addOrDeleteCustomPeriodBtn) {
        _addOrDeleteCustomPeriodBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addOrDeleteCustomPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_edit"] forState:UIControlStateNormal];
//        [_addOrDeleteCustomPeriodBtn addTarget:self action:@selector(customPeriodBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addOrDeleteCustomPeriodBtn;
}

- (void)setTotalIncome:(double)totalIncome{
    _totalIncome = totalIncome;
    self.summaryHeader.income = _totalIncome;
}

- (void)setTotalExpenture:(double)totalExpenture{
    _totalExpenture = totalExpenture;
    self.summaryHeader.expenture = _totalExpenture;
}

- (void)setCustomPeriod:(SSJDatePeriod *)customPeriod{
    _customPeriod = customPeriod;
    if (_customPeriod) {
        self.dateAxisView.hidden = YES;
        self.customPeriodBtn.hidden = NO;
        [self updateCustomPeriodBtn];
        [self.addOrDeleteCustomPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_delete"] forState:UIControlStateNormal];
    }else{
        self.dateAxisView.hidden = NO;
        self.customPeriodBtn.hidden = YES;
        [self.addOrDeleteCustomPeriodBtn setImage:[UIImage ssj_themeImageWithName:@"reportForms_edit"] forState:UIControlStateNormal];
    }
}

- (void)updateCustomPeriodBtn {
    NSString *startDateStr = [_customPeriod.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *endDateStr = [_customPeriod.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *title = [NSString stringWithFormat:@"%@－－%@", startDateStr, endDateStr];
    [self.customPeriodBtn setTitle:title forState:UIControlStateNormal];
    CGSize textSize = [title sizeWithAttributes:@{NSFontAttributeName:self.customPeriodBtn.titleLabel.font}];
    self.customPeriodBtn.top = self.dateAxisView.top + 10;
    self.customPeriodBtn.width = textSize.width + 28;
    self.customPeriodBtn.centerX = self.width * 0.5;
}

- (void)segmentControlValueDidChange:(SSJSegmentedControl *)sender{
    if (sender.tag == 100) {
        if (self.periodSelectBlock) {
            self.periodSelectBlock();
        }
    }else{
        if (self.incomeOrExpentureSelectBlock) {
            self.incomeOrExpentureSelectBlock();
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
