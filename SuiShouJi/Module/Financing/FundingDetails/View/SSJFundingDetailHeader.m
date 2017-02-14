//
//  SSJFundingDetailHeader.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingDetailHeader.h"

@interface SSJFundingDetailHeader()

@property (nonatomic,strong) UIView *seperatorView;

@property (nonatomic,strong) UILabel *incomeLabel;

@property (nonatomic,strong) UILabel *expenceLabel;

@property(nonatomic, strong) UILabel *totalIncomeLabel;

@property(nonatomic, strong) UILabel *totalExpenceLabel;

@end

@implementation SSJFundingDetailHeader
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.incomeLabel];
        [self addSubview:self.totalIncomeLabel];
        [self addSubview:self.seperatorView];
        [self addSubview:self.expenceLabel];
        [self addSubview:self.totalExpenceLabel];
    }
    return self;
}

-(void)layoutSubviews{
    self.incomeLabel.centerX = self.width / 2 / 2;
    self.incomeLabel.top = 22;
    self.totalIncomeLabel.centerX = self.width / 2 / 2;
    self.totalIncomeLabel.top = self.incomeLabel.bottom + 15;
    self.seperatorView.size = CGSizeMake(1, 67);
    self.seperatorView.center = CGPointMake(self.width / 2, self.height / 2);
    self.expenceLabel.centerX = self.width / 2  + self.width / 2 / 2;
    self.expenceLabel.top = 22;
    self.totalExpenceLabel.centerX = self.width / 2  + self.width / 2 / 2;
    self.totalExpenceLabel.top = self.incomeLabel.bottom + 15;
}

-(UIView *)seperatorView{
    if (!_seperatorView) {
        _seperatorView = [[UIView alloc]init];
        _seperatorView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    }
    return _seperatorView;
}

-(UILabel *)expenceLabel{
    if (!_expenceLabel) {
        _expenceLabel = [[UILabel alloc]init];
        if (SSJ_CURRENT_THEME.financingDetailMainColor.length) {
            _expenceLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailMainColor alpha:SSJ_CURRENT_THEME.financingDetailMainAlpha];
        } else {
            _expenceLabel.textColor = [UIColor whiteColor];
        }
        _expenceLabel.font = [UIFont systemFontOfSize:15];
        _expenceLabel.textAlignment = NSTextAlignmentCenter;
        _expenceLabel.text = @"累计支出";
        [_expenceLabel sizeToFit];
    }
    return _expenceLabel;
}

-(UILabel *)incomeLabel{
    if (!_incomeLabel) {
        _incomeLabel = [[UILabel alloc]init];
        if (SSJ_CURRENT_THEME.financingDetailMainColor.length) {
            _incomeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailMainColor alpha:SSJ_CURRENT_THEME.financingDetailMainAlpha];
        } else {
            _incomeLabel.textColor = [UIColor whiteColor];
        }
        _incomeLabel.font = [UIFont systemFontOfSize:15];
        _incomeLabel.textAlignment = NSTextAlignmentCenter;
        _incomeLabel.text = @"累计收入";
        [_incomeLabel sizeToFit];
    }
    return _incomeLabel;
}

-(UILabel *)totalExpenceLabel{
    if (!_totalExpenceLabel) {
        _totalExpenceLabel = [[UILabel alloc]init];
        _totalExpenceLabel.font = [UIFont systemFontOfSize:24];
        if (SSJ_CURRENT_THEME.financingDetailMainColor.length) {
            _totalExpenceLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailMainColor alpha:SSJ_CURRENT_THEME.financingDetailMainAlpha];
        } else {
            _totalExpenceLabel.textColor = [UIColor whiteColor];
        }
        _totalExpenceLabel.textAlignment = NSTextAlignmentCenter;
        _totalExpenceLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _totalExpenceLabel;
}


-(UILabel *)totalIncomeLabel{
    if (!_totalIncomeLabel) {
        _totalIncomeLabel = [[UILabel alloc]init];
        _totalIncomeLabel.font = [UIFont systemFontOfSize:24];
        if (SSJ_CURRENT_THEME.financingDetailMainColor.length) {
            _totalIncomeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailMainColor alpha:SSJ_CURRENT_THEME.financingDetailMainAlpha];
        } else {
            _totalIncomeLabel.textColor = [UIColor whiteColor];
        }
        _totalIncomeLabel.textAlignment = NSTextAlignmentCenter;
        _totalIncomeLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _totalIncomeLabel;
}

- (void)setExpence:(double)expence {
    NSString *expenceStr = [[NSString stringWithFormat:@"%f",expence] ssj_moneyDecimalDisplayWithDigits:2];
    CGSize expenceSize = [expenceStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:24]}];
    if (expenceSize.width > self.width / 2 - 10) {
        self.totalExpenceLabel.width = self.width / 2 - 10;
        self.totalExpenceLabel.height = expenceSize.height;
        self.totalExpenceLabel.text = expenceStr;
    } else {
        self.totalExpenceLabel.text = expenceStr;
        [self.totalExpenceLabel sizeToFit];
    }
}

- (void)setIncome:(double)income {
    NSString *incomeStr = [[NSString stringWithFormat:@"%f",income] ssj_moneyDecimalDisplayWithDigits:2];
    CGSize incomeSize = [incomeStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:24]}];
    if (incomeSize.width > self.width / 2 - 10) {
        self.totalIncomeLabel.width = self.width / 2 - 10;
        self.totalIncomeLabel.height = incomeSize.height;
        self.totalIncomeLabel.text = incomeStr;
    } else {
        self.totalIncomeLabel.text = incomeStr;
        [self.totalIncomeLabel sizeToFit];
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
