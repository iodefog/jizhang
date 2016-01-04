//
//  SSJReportFormsSurplusView.m
//  SuiShouJi
//
//  Created by old lang on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJReportFormsSurplusView.h"

@interface SSJReportFormsSurplusView ()

//  总和标题
@property (nonatomic, strong) UILabel *sumTitleLab;

//  总和值
@property (nonatomic, strong) UILabel *sumValueLab;

//  收入标题
@property (nonatomic, strong) UILabel *incomeTitleLab;

//  收入值
@property (nonatomic, strong) UILabel *incomeValueLab;

//  支出标题
@property (nonatomic, strong) UILabel *payTitleLab;

//  支出值
@property (nonatomic, strong) UILabel *payValueLab;

//  水平线
@property (nonatomic, strong) UIView *horizontalLine;

//  垂直线
@property (nonatomic, strong) UIView *verticalLine;

//  收入
@property (nonatomic) double income;

//  支出
@property (nonatomic) double pay;

@end

@implementation SSJReportFormsSurplusView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.sumTitleLab];
        [self addSubview:self.sumValueLab];
        [self addSubview:self.incomeTitleLab];
        [self addSubview:self.incomeValueLab];
        [self addSubview:self.payTitleLab];
        [self addSubview:self.payValueLab];
        [self addSubview:self.horizontalLine];
        [self addSubview:self.verticalLine];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat verticalGap = 7;
    
    CGFloat top1 = (100 - self.sumTitleLab.height - self.sumValueLab.height - verticalGap) * 0.5;
    self.sumTitleLab.top = top1;
    self.sumValueLab.top = self.sumTitleLab.bottom + verticalGap;
    self.sumTitleLab.centerX = self.sumValueLab.centerX = self.width * 0.5;
    
    CGFloat top2 = (85 - self.incomeTitleLab.height - self.incomeValueLab.height - verticalGap) * 0.5 + 100;
    self.incomeTitleLab.top = self.payTitleLab.top = top2;
    self.incomeValueLab.top = self.payValueLab.top = self.incomeTitleLab.bottom + verticalGap;
    self.incomeTitleLab.centerX = self.incomeValueLab.centerX = self.width * 0.25;
    self.payTitleLab.centerX = self.payValueLab.centerX = self.width * 0.75;
    
    self.horizontalLine.frame = CGRectMake(0, 100, self.width, 0.5);
    self.verticalLine.frame = CGRectMake(self.width * 0.5, 100, 0.5, 85);
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    
    self.sumTitleLab.backgroundColor = backgroundColor;
    self.sumValueLab.backgroundColor = backgroundColor;
    self.incomeTitleLab.backgroundColor = backgroundColor;
    self.incomeValueLab.backgroundColor = backgroundColor;
    self.payTitleLab.backgroundColor = backgroundColor;
    self.payValueLab.backgroundColor = backgroundColor;
}

- (void)setTitle:(NSString *)title {
    if (![self.sumTitleLab.text isEqualToString:title]) {
        self.sumTitleLab.text = title;
        [self.sumTitleLab sizeToFit];
        [self setNeedsLayout];
    }
}

- (void)setIncome:(double)income pay:(double)pay {
    if (self.income == income && self.pay == pay) {
        return;
    }
    
    if (self.income != income) {
        self.income = income;
        self.incomeValueLab.text = [[NSString stringWithFormat:@"%.2f",income] ssj_moneyDisplayFormat];
        [self.incomeValueLab sizeToFit];
    }
    
    if (self.pay != pay) {
        self.pay = pay;
        self.payValueLab.text = [[NSString stringWithFormat:@"%.2f",pay] ssj_moneyDisplayFormat];
        [self.payValueLab sizeToFit];
    }
    
    self.sumValueLab.text = [[NSString stringWithFormat:@"%.2f",(self.income - self.pay)] ssj_moneyDisplayFormat];
    [self.sumValueLab sizeToFit];
    
    [self setNeedsLayout];
}

- (UILabel *)sumTitleLab {
    if (!_sumTitleLab) {
        _sumTitleLab = [self createLabelWithText:@"支出" fontSize:15 textColor:[UIColor ssj_colorWithHex:@"#a7a7a7"]];
    }
    return _sumTitleLab;
}

- (UILabel *)sumValueLab {
    if (!_sumValueLab) {
        _sumValueLab = [self createLabelWithText:@"--" fontSize:30 textColor:[UIColor ssj_colorWithHex:@"#99c9fb"]];
    }
    return _sumValueLab;
}

- (UILabel *)incomeTitleLab {
    if (!_incomeTitleLab) {
        _incomeTitleLab = [self createLabelWithText:@"收入" fontSize:15 textColor:[UIColor ssj_colorWithHex:@"#a7a7a7"]];
    }
    return _incomeTitleLab;
}

- (UILabel *)incomeValueLab {
    if (!_incomeValueLab) {
        _incomeValueLab = [self createLabelWithText:@"--" fontSize:20 textColor:[UIColor ssj_colorWithHex:@"#393939"]];
    }
    return _incomeValueLab;
}

- (UILabel *)payTitleLab {
    if (!_payTitleLab) {
        _payTitleLab = [self createLabelWithText:@"支出" fontSize:15 textColor:[UIColor ssj_colorWithHex:@"#a7a7a7"]];
    }
    return _payTitleLab;
}

- (UILabel *)payValueLab {
    if (!_payValueLab) {
        _payValueLab = [self createLabelWithText:@"--" fontSize:20 textColor:[UIColor ssj_colorWithHex:@"#393939"]];
    }
    return _payValueLab;
}

- (UIView *)horizontalLine {
    if (!_horizontalLine) {
        _horizontalLine = [[UIView alloc] init];
        _horizontalLine.backgroundColor = SSJ_DEFAULT_SEPARATOR_COLOR;
    }
    return _horizontalLine;
}

- (UIView *)verticalLine {
    if (!_verticalLine) {
        _verticalLine = [[UIView alloc] init];
        _verticalLine.backgroundColor = SSJ_DEFAULT_SEPARATOR_COLOR;
    }
    return _verticalLine;
}

- (UILabel *)createLabelWithText:(NSString *)text fontSize:(CGFloat)size textColor:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:size];
    label.textColor = color;
    label.adjustsFontSizeToFitWidth = YES;
    [label sizeToFit];
    return label;
}

@end
