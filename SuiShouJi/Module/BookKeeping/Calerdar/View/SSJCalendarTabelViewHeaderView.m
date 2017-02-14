//
//  SSJCalendarTabelViewHeaderView.m
//  SuiShouJi
//
//  Created by ricky on 2017/2/8.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCalendarTabelViewHeaderView.h"

@interface SSJCalendarTabelViewHeaderView()

@property(nonatomic, strong) UILabel *dateLabel;

@property(nonatomic, strong) UILabel *incomeLabel;

@property(nonatomic, strong) UILabel *expenceLabel;

@property(nonatomic, strong) UILabel *balanceLabel;

@end

@implementation SSJCalendarTabelViewHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.dateLabel];
        [self addSubview:self.incomeLabel];
        [self addSubview:self.expenceLabel];
        [self addSubview:self.balanceLabel];
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellAppearanceAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.dateLabel.left = 10;
    self.dateLabel.centerY = self.height / 2 - 5;
    self.balanceLabel.right = self.width - 10;
    self.balanceLabel.centerY = self.height / 2 - 5;
    self.incomeLabel.left = 10;
    self.incomeLabel.centerY = self.dateLabel.bottom + 10;
    self.expenceLabel.right = self.width - 10;
    self.expenceLabel.centerY = self.dateLabel.bottom + 10;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _dateLabel.font = [UIFont systemFontOfSize:16];
    }
    
    return _dateLabel;
}

- (UILabel *)incomeLabel {
    if (!_incomeLabel) {
        _incomeLabel = [[UILabel alloc] init];
        _incomeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _incomeLabel.font = [UIFont systemFontOfSize:13];
    }
    
    return _incomeLabel;
}

- (UILabel *)expenceLabel {
    if (!_expenceLabel) {
        _expenceLabel = [[UILabel alloc] init];
        _expenceLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _expenceLabel.font = [UIFont systemFontOfSize:13];
    }
    
    return _expenceLabel;
}

- (UILabel *)balanceLabel {
    
    if (!_balanceLabel) {
        _balanceLabel = [[UILabel alloc] init];
        _balanceLabel.font = [UIFont systemFontOfSize:16];
        if (self.balance > 0) {
            _balanceLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurveIncomeColor];
        } else {
            _balanceLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentColor];
        }
    }
    
    return _balanceLabel;
}

- (void)updateCellAppearanceAfterThemeChanged {
    self.dateLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.incomeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.expenceLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    if (self.balance > 0) {
        self.balanceLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurveIncomeColor];
    } else {
        self.balanceLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentColor];
    }
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
}

- (void)setIncome:(double)income {
    NSString *incomeStr = [[NSString stringWithFormat:@"%f",income] ssj_moneyDecimalDisplayWithDigits:2];
    self.incomeLabel.text = [NSString stringWithFormat:@"收入:%@",incomeStr];
    [self.incomeLabel sizeToFit];
}

- (void)setExpence:(double)expence {
    NSString *expenceStr = [[NSString stringWithFormat:@"%f",expence] ssj_moneyDecimalDisplayWithDigits:2];
    self.expenceLabel.text = [NSString stringWithFormat:@"支出:%@",expenceStr];
    [self.expenceLabel sizeToFit];
}

- (void)setBalance:(double)balance {
    NSString *balanceStr = [[NSString stringWithFormat:@"%f",balance] ssj_moneyDecimalDisplayWithDigits:2];
    self.balanceLabel.text = balanceStr;
    [self.balanceLabel sizeToFit];
}

- (void)setCurrentDateStr:(NSString *)currentDateStr {
    NSDate *currentDate = [NSDate dateWithString:currentDateStr formatString:@"yyyy.MM.dd"];
    if ([currentDate isSameDay:[NSDate date]]) {
        self.dateLabel.text = @"今日账单";
    } else {
        self.dateLabel.text = [NSString stringWithFormat:@"%@账单",currentDateStr];
    }
    [self.dateLabel sizeToFit];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
