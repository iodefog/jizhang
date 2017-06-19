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

@property(nonatomic, strong) UIView *topSeparator;

@property(nonatomic, strong) UIView *bottomSeparator;

@end

@implementation SSJCalendarTabelViewHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.dateLabel];
        [self addSubview:self.incomeLabel];
        [self addSubview:self.expenceLabel];
        [self addSubview:self.balanceLabel];
        [self addSubview:self.topSeparator];
        [self addSubview:self.bottomSeparator];
        self.backgroundView = [[UIView alloc] init];
        self.backgroundView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self.backgroundView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        [self.backgroundView ssj_setBorderStyle:SSJBorderStyleBottom];
        [self.backgroundView ssj_setBorderWidth:1 / [UIScreen mainScreen].scale];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellAppearanceAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    self.topSeparator.width = self.bottomSeparator.width = self.width;
    self.topSeparator.leftTop = CGPointMake(0, 0);
    self.bottomSeparator.leftBottom = CGPointMake(0, self.height);
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _dateLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    
    return _dateLabel;
}

- (UILabel *)incomeLabel {
    if (!_incomeLabel) {
        _incomeLabel = [[UILabel alloc] init];
        _incomeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _incomeLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    
    return _incomeLabel;
}

- (UILabel *)expenceLabel {
    if (!_expenceLabel) {
        _expenceLabel = [[UILabel alloc] init];
        _expenceLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _expenceLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    
    return _expenceLabel;
}

- (UILabel *)balanceLabel {
    if (!_balanceLabel) {
        _balanceLabel = [[UILabel alloc] init];
        _balanceLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        if (self.balance > 0) {
            _balanceLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurveIncomeColor];
        } else {
            _balanceLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentColor];
        }
    }
    
    return _balanceLabel;
}

- (UIView *)topSeparator {
    if (!_topSeparator) {
        _topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1 / [UIScreen mainScreen].scale)];
        _topSeparator.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    }
    return _topSeparator;
}

- (UIView *)bottomSeparator {
    if (!_bottomSeparator) {
        _bottomSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1 / [UIScreen mainScreen].scale)];
        _bottomSeparator.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    }
    return _bottomSeparator;
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
    self.backgroundView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
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
    if (balance > 0) {
        _balanceLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurveIncomeColor];
    } else {
        _balanceLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentColor];
    }
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
