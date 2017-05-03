//
//  SJJBookKeepingHeader.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/14.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHeader.h"
#import "SSJRecordMakingViewController.h"

@interface SSJBookKeepingHeader()
@property (strong, nonatomic) UIImageView *backgroudview;
@property(nonatomic, strong) UIView *seperatorLine;
@end
@implementation SSJBookKeepingHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.seperatorLine];
        [self addSubview:self.incomeView];
        [self addSubview:self.incomeTitleLabel];
        [self addSubview:self.expenditureView];
        [self addSubview:self.expenditureTitleLabel];
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.seperatorLine.size = CGSizeMake(1, self.height - 60);
    self.seperatorLine.centerX = self.width / 2;
    self.seperatorLine.top = 0;
    self.incomeView.centerX = self.width / 2 / 2;
    self.incomeView.bottom = self.height - 46;
    self.incomeTitleLabel.bottom = self.incomeView.top - 10;
    self.incomeTitleLabel.centerX = self.width / 2 / 2;
    self.expenditureView.centerX = self.width / 2 + self.width / 2 / 2;
    self.expenditureView.bottom = self.height - 46;
    self.expenditureTitleLabel.bottom = self.expenditureView.top - 10;
    self.expenditureTitleLabel.centerX = self.width / 2 + self.width / 2 / 2;
}

-(SSJScrollTextView *)expenditureView{
    if (!_expenditureView) {
        _expenditureView = [[SSJScrollTextView alloc]init];
        _expenditureView.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _expenditureView.textFont = SSJ_FONT_SIZE_1;
        _expenditureView.totalAnimationDuration = 1.f;
    }
    return _expenditureView;
}

-(SSJScrollTextView *)incomeView{
    if (!_incomeView) {
        _incomeView = [[SSJScrollTextView alloc]init];
        _incomeView.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _incomeView.textFont = SSJ_FONT_SIZE_1;
        _incomeView.totalAnimationDuration = 1.f;
    }
    return _incomeView;
}

-(UILabel *)expenditureTitleLabel{
    if (!_expenditureTitleLabel) {
        _expenditureTitleLabel = [[UILabel alloc]init];
        _expenditureTitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _expenditureTitleLabel.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_5);
    }
    return _expenditureTitleLabel;
}

-(UILabel *)incomeTitleLabel{
    if (!_incomeTitleLabel) {
        _incomeTitleLabel = [[UILabel alloc]init];
        _incomeTitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _incomeTitleLabel.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_5);
    }
    return _incomeTitleLabel;
}

-(UIView *)seperatorLine{
    if (!_seperatorLine) {
        _seperatorLine = [[UIView alloc]init];
        _seperatorLine.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor];
    }
    return _seperatorLine;
}

-(void)setCurrentMonth:(long )currentMonth{
    _currentMonth = currentMonth;
    self.incomeTitleLabel.text = [NSString stringWithFormat:@"%ld月收入(元)",_currentMonth];
    [self.incomeTitleLabel sizeToFit];
    self.expenditureTitleLabel.text = [NSString stringWithFormat:@"%ld月支出(元)",_currentMonth];
    [self.expenditureTitleLabel sizeToFit];
}

-(void)setIncome:(NSString *)income{
    _income = income;
    CGSize incomeSize = [_income sizeWithAttributes:@{NSFontAttributeName:SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_1)}];
    if (incomeSize.width > self.width / 2 - self.buttonWidth / 3) {
        [self.incomeView ajustFontWithSize:CGSizeMake(self.width / 2 - self.buttonWidth / 3 - 10, incomeSize.height)];
        self.incomeView.string = _income;
    } else {
        self.incomeView.string = _income;
        [self.incomeView sizeToFit];
    }
    [self setNeedsLayout];
}

-(void)setExpenditure:(NSString *)expenditure{
    _expenditure = expenditure;
    CGSize expenditureSize = [_expenditure sizeWithAttributes:@{NSFontAttributeName:SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_1)}];
    if (expenditureSize.width > self.width / 2 - self.buttonWidth / 3) {
        [self.expenditureView ajustFontWithSize:CGSizeMake(self.width / 2 - self.buttonWidth / 3 - 10, expenditureSize.height)];
        self.expenditureView.string = _expenditure;
    } else {
        self.expenditureView.string = _expenditure;
        [self.expenditureView sizeToFit];
    }
    [self setNeedsLayout];
}

- (void)setButtonWidth:(double)buttonWidth {
    _buttonWidth = buttonWidth;
}

- (void)updateAfterThemeChange{
    self.expenditureView.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.incomeView.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.expenditureTitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.incomeTitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.seperatorLine.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor];
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
}

@end
