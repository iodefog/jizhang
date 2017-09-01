//
//  SSJFundingDetailHeader.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingDetailHeader.h"

@interface SSJFundingDetailHeader()

@property (nonatomic,strong) CAGradientLayer *backLayer;

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
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self.layer addSublayer:self.backLayer];
        [self addSubview:self.totalIncomeLabel];
        [self addSubview:self.incomeLabel];
        [self addSubview:self.seperatorView];
        [self addSubview:self.totalExpenceLabel];
        [self addSubview:self.expenceLabel];
    }
    return self;
}

-(void)layoutSubviews{
    self.totalIncomeLabel.width = self.backLayer.width / 2 - 10;
    self.totalIncomeLabel.centerX = self.width / 2 - self.backLayer.width / 4;
    self.totalIncomeLabel.bottom = self.height / 2;
    self.incomeLabel.centerX = self.totalIncomeLabel.centerX;
    self.incomeLabel.top = self.totalIncomeLabel.bottom + 15;
    self.seperatorView.size = CGSizeMake(1, 67);
    self.seperatorView.center = CGPointMake(self.width / 2, self.height / 2);
    self.totalExpenceLabel.width = self.backLayer.width / 2 - 10;
    self.totalExpenceLabel.right = self.backLayer.right;
    self.totalExpenceLabel.bottom = self.height / 2;
    self.expenceLabel.centerX = self.totalExpenceLabel.centerX;
    self.expenceLabel.top = self.totalExpenceLabel.bottom + 15;
}

-(UIView *)seperatorView{
    if (!_seperatorView) {
        _seperatorView = [[UIView alloc]init];
        _seperatorView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
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
        _expenceLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_6];
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
        _incomeLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_6];
        _incomeLabel.textAlignment = NSTextAlignmentCenter;
        _incomeLabel.text = @"累计收入";
        [_incomeLabel sizeToFit];
    }
    return _incomeLabel;
}

-(UILabel *)totalExpenceLabel{
    if (!_totalExpenceLabel) {
        _totalExpenceLabel = [[UILabel alloc]init];
        _totalExpenceLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
        _totalExpenceLabel.textAlignment = NSTextAlignmentCenter;
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
        _totalIncomeLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
        _totalIncomeLabel.textAlignment = NSTextAlignmentCenter;
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

- (CAGradientLayer *)backLayer {
    if (!_backLayer) {
        _backLayer = [CAGradientLayer layer];
        _backLayer.cornerRadius = 8;
        _backLayer.startPoint = CGPointMake(0, 0.5);
        _backLayer.endPoint = CGPointMake(1, 0.5);
        _backLayer.size = CGSizeMake(self.width - 30, self.height - 20);
        _backLayer.position = CGPointMake(self.width / 2, self.height / 2);
        if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
            _backLayer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, _backLayer.width + 4, _backLayer.height + 4) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(8, 8)].CGPath;
        }
        _backLayer.shadowRadius = 10;
        _backLayer.shadowOpacity = 0.3;
    }
    return _backLayer;
}

- (void)setItem:(SSJFinancingHomeitem *)item {
    _item = item;
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        self.backLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:_item.startColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:_item.endColor].CGColor];
        self.backLayer.shadowColor = [UIColor ssj_colorWithHex:_item.startColor].CGColor;
    } else {
        self.backLayer.colors = nil;
        if (SSJ_CURRENT_THEME.financingDetailHeaderColor.length) {
            self.backLayer.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailHeaderColor alpha:SSJ_CURRENT_THEME.financingDetailHeaderAlpha].CGColor;
        } else {
            self.backLayer.backgroundColor = [UIColor ssj_colorWithHex:_item.startColor].CGColor;
        }
    }
    NSString *incomeStr = [[NSString stringWithFormat:@"%f",_item.fundingIncome] ssj_moneyDecimalDisplayWithDigits:2];
    CGSize incomeSize = [incomeStr sizeWithAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1]}];
    if (incomeSize.width > self.width / 2 - 10) {
        self.totalIncomeLabel.width = self.width / 2 - 10;
        self.totalIncomeLabel.height = incomeSize.height;
        self.totalIncomeLabel.text = incomeStr;
    } else {
        self.totalIncomeLabel.text = incomeStr;
        [self.totalIncomeLabel sizeToFit];
    }

    NSString *expenceStr = [[NSString stringWithFormat:@"%f",_item.fundingExpence] ssj_moneyDecimalDisplayWithDigits:2];
    CGSize expenceSize = [expenceStr sizeWithAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1]}];
    if (expenceSize.width > self.width / 2 - 10) {
        self.totalExpenceLabel.width = self.width / 2 - 10;
        self.totalExpenceLabel.height = expenceSize.height;
        self.totalExpenceLabel.text = expenceStr;
    } else {
        self.totalExpenceLabel.text = expenceStr;
        [self.totalExpenceLabel sizeToFit];
    }
}

- (void)updateAfterThemeChange {
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        _backLayer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, _backLayer.width + 4, _backLayer.height + 4) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(8, 8)].CGPath;
    }
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        self.backLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:self.item.startColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:self.item.endColor].CGColor];
        self.backLayer.shadowColor = [UIColor ssj_colorWithHex:self.item.startColor].CGColor;
    } else {
        self.backLayer.colors = nil;
        if (SSJ_CURRENT_THEME.financingDetailHeaderColor.length) {
            self.backLayer.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailHeaderColor alpha:SSJ_CURRENT_THEME.financingDetailHeaderAlpha].CGColor;
        } else {
            self.backLayer.backgroundColor = [UIColor ssj_colorWithHex:self.item.startColor].CGColor;
        }
    }
    self.seperatorView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
