//
//  SSJHoleBooksHeaderView.m
//  SuiShouJi
//
//  Created by ricky on 16/11/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSummaryBooksHeaderView.h"

@interface SSJSummaryBooksHeaderView()

@property(nonatomic, strong) UILabel *incomeTitleLab;

@property(nonatomic, strong) UILabel *incomeLab;

@property(nonatomic, strong) UILabel *expentureTitleLab;

@property(nonatomic, strong) UILabel *expentureLab;

@property(nonatomic, strong) UIView *seperatorLine;

@end

@implementation SSJSummaryBooksHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self ssj_setBorderColor:[UIColor whiteColor]];
        [self ssj_setBorderStyle:SSJBorderStyleTop];
        [self ssj_setBorderWidth:1.f / [UIScreen mainScreen].scale];
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.summaryBooksHeaderColor alpha:SSJ_CURRENT_THEME.summaryBooksHeaderAlpha];
        [self addSubview:self.seperatorLine];
        [self addSubview:self.incomeTitleLab];
        [self addSubview:self.incomeLab];
        [self addSubview:self.expentureTitleLab];
        [self addSubview:self.expentureLab];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.seperatorLine.center = CGPointMake(self.width / 2, self.height / 2);
    self.incomeTitleLab.centerY = self.expentureTitleLab.centerY = self.height / 2 - 12;
    self.incomeLab.centerY = self.expentureLab.centerY = self.height / 2 + 12;
    self.incomeTitleLab.centerX = self.incomeLab.centerX = self.width / 4;
    self.expentureTitleLab.centerX = self.expentureLab.centerX = self.width / 2 + self.width / 4;
}

- (UIView *)seperatorLine{
    if (!_seperatorLine) {
        _seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1.f / [UIScreen mainScreen].scale, 57)];
        _seperatorLine.backgroundColor = [UIColor whiteColor];
    }
    return _seperatorLine;
}

- (UILabel *)incomeTitleLab{
    if (!_incomeTitleLab) {
        _incomeTitleLab = [[UILabel alloc]init];
        _incomeTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _incomeTitleLab.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_5);
        _incomeTitleLab.text = @"累计收入";
        [_incomeTitleLab sizeToFit];
    }
    return _incomeTitleLab;
}

- (UILabel *)incomeLab{
    if (!_incomeLab) {
        _incomeLab = [[UILabel alloc]init];
        _incomeLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _incomeLab.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_1);
    }
    return _incomeLab;
}

- (UILabel *)expentureTitleLab{
    if (!_expentureTitleLab) {
        _expentureTitleLab = [[UILabel alloc]init];
        _expentureTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _expentureTitleLab.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_5);
        _expentureTitleLab.text = @"累计支出";
        [_expentureTitleLab sizeToFit];
    }
    return _expentureTitleLab;
}

- (UILabel *)expentureLab{
    if (!_expentureLab) {
        _expentureLab = [[UILabel alloc]init];
        _expentureLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _expentureLab.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_1);
    }
    return _expentureLab;
}

- (void)setIncome:(double)income{
    _income = income;
    self.incomeLab.text = [NSString stringWithFormat:@"%.2f",_income];
    [self.incomeLab sizeToFit];
}

- (void)setExpenture:(double)expenture{
    _expenture = expenture;
    self.expentureLab.text = [NSString stringWithFormat:@"%.2f",_expenture];
    [self.expentureLab sizeToFit];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
