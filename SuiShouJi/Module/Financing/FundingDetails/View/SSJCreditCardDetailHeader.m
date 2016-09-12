//
//  SSJCreditCardDetailHeader.m
//  SuiShouJi
//
//  Created by ricky on 16/8/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCreditCardDetailHeader.h"

@interface SSJCreditCardDetailHeader()

@property(nonatomic, strong) UILabel *balanceTitleLab;

@property(nonatomic, strong) UILabel *balanceLab;

@property(nonatomic, strong) UILabel *limitTitleLab;

@property(nonatomic, strong) UILabel *limitLab;

@property(nonatomic, strong) UILabel *repaymentDayTitleLab;

@property(nonatomic, strong) UILabel *repaymentDayLab;

@property(nonatomic, strong) UILabel *billingDayTitleLab;

@property(nonatomic, strong) UILabel *billingDayLab;

@property(nonatomic, strong) UIView *horizontalSeperatorLine;

@property(nonatomic, strong) UIView *firstVerticalSeperatorLine;

@property(nonatomic, strong) UIView *secondVerticalSeperatorLine;

@property(nonatomic, strong) UIView *bottomView;

@property(nonatomic, strong) UILabel *incomeLab;

@property(nonatomic, strong) UILabel *expenceLab;

@end

@implementation SSJCreditCardDetailHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.backGroundView];
        [self addSubview:self.balanceTitleLab];
        [self addSubview:self.balanceLab];
        [self addSubview:self.horizontalSeperatorLine];
        [self addSubview:self.firstVerticalSeperatorLine];
        [self addSubview:self.secondVerticalSeperatorLine];
        [self addSubview:self.billingDayTitleLab];
        [self addSubview:self.billingDayLab];
        [self addSubview:self.limitTitleLab];
        [self addSubview:self.limitLab];
        [self addSubview:self.repaymentDayTitleLab];
        [self addSubview:self.repaymentDayLab];
        [self addSubview:self.bottomView];
        [self addSubview:self.incomeLab];
        [self addSubview:self.expenceLab];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.backGroundView.size = CGSizeMake(self.width, 193);
    self.backGroundView.leftTop = CGPointMake(0, 0);
    self.balanceTitleLab.top = 23;
    self.balanceTitleLab.centerX = self.width / 2;
    self.balanceLab.top = self.balanceTitleLab.top + 17;
    self.balanceLab.centerX = self.width / 2;
    self.horizontalSeperatorLine.top = 90;
    self.horizontalSeperatorLine.centerX = self.width / 2;
    self.firstVerticalSeperatorLine.centerX = self.width / 2 - 63;
    self.firstVerticalSeperatorLine.centerY = self.backGroundView.height / 2 + 45;
    self.secondVerticalSeperatorLine.centerX = self.width / 2 + 63;
    self.secondVerticalSeperatorLine.centerY = self.backGroundView.height / 2 + 45;
    self.billingDayTitleLab.top = self.horizontalSeperatorLine.top + 22;
    self.billingDayTitleLab.centerX = self.width / 2;
    self.billingDayLab.top = self.billingDayTitleLab.bottom + 10;
    self.billingDayLab.centerX = self.billingDayTitleLab.centerX;
    self.limitTitleLab.top = self.horizontalSeperatorLine.bottom + 22;
    self.limitTitleLab.centerX = self.firstVerticalSeperatorLine.left / 2;
    self.limitLab.top = self.limitTitleLab.bottom + 10;
    self.limitLab.centerX = self.limitTitleLab.centerX;
    self.repaymentDayTitleLab.top = self.horizontalSeperatorLine.bottom + 22;
    self.repaymentDayTitleLab.centerX = self.secondVerticalSeperatorLine.right + self.firstVerticalSeperatorLine.left / 2;
    self.repaymentDayLab.top = self.repaymentDayTitleLab.bottom + 10;
    self.repaymentDayLab.centerX = self.secondVerticalSeperatorLine.right + self.firstVerticalSeperatorLine.left / 2;
    self.bottomView.size = CGSizeMake(self.width, 40);
    self.bottomView.leftTop = CGPointMake(0, self.backGroundView.bottom);
    self.incomeLab.left = 10;
    self.incomeLab.centerY = self.bottomView.centerY;
    self.expenceLab.right = self.width - 10;
    self.expenceLab.centerY = self.bottomView.centerY;
}

-(UILabel *)balanceTitleLab{
    if (!_balanceTitleLab) {
        _balanceTitleLab = [[UILabel alloc]init];
        _balanceTitleLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:0.5];
        _balanceTitleLab.font = [UIFont systemFontOfSize:11];
        [_balanceTitleLab sizeToFit];
    }
    return _balanceTitleLab;
}

-(UILabel *)balanceLab{
    if (!_balanceLab) {
        _balanceLab = [[UILabel alloc]init];
        _balanceLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff"];
        _balanceLab.font = [UIFont systemFontOfSize:24];
    }
    return _balanceLab;
}

-(UILabel *)limitTitleLab{
    if (!_limitTitleLab) {
        _limitTitleLab = [[UILabel alloc]init];
        _limitTitleLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:0.5];
        _limitTitleLab.font = [UIFont systemFontOfSize:11];
        _limitTitleLab.text = @"信用额度";
        [_limitTitleLab sizeToFit];
    }
    return _limitTitleLab;
}

-(UILabel *)limitLab{
    if (!_limitLab) {
        _limitLab = [[UILabel alloc]init];
        _limitLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff"];
        _limitLab.font = [UIFont systemFontOfSize:15];
    }
    return _limitLab;
}

-(UILabel *)repaymentDayTitleLab{
    if (!_repaymentDayTitleLab) {
        _repaymentDayTitleLab = [[UILabel alloc]init];
        _repaymentDayTitleLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:0.5];
        _repaymentDayTitleLab.font = [UIFont systemFontOfSize:11];
        _repaymentDayTitleLab.text = @"还款日";
        [_repaymentDayTitleLab sizeToFit];
    }
    return _repaymentDayTitleLab;
}

-(UILabel *)repaymentDayLab{
    if (!_repaymentDayLab) {
        _repaymentDayLab = [[UILabel alloc]init];
        _repaymentDayLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff"];
        _repaymentDayLab.font = [UIFont systemFontOfSize:15];
    }
    return _repaymentDayLab;
}

-(UILabel *)billingDayTitleLab{
    if (!_billingDayTitleLab) {
        _billingDayTitleLab = [[UILabel alloc]init];
        _billingDayTitleLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:0.5];
        _billingDayTitleLab.font = [UIFont systemFontOfSize:11];
        _billingDayTitleLab.text = @"账单日";
        [_billingDayTitleLab sizeToFit];
    }
    return _billingDayTitleLab;
}

-(UILabel *)billingDayLab{
    if (!_billingDayLab) {
        _billingDayLab = [[UILabel alloc]init];
        _billingDayLab.textColor = [UIColor ssj_colorWithHex:@"#ffffff"];
        _billingDayLab.font = [UIFont systemFontOfSize:15];
    }
    return _billingDayLab;
}

-(UIView *)horizontalSeperatorLine{
    if (!_horizontalSeperatorLine) {
        _horizontalSeperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 290, 1 / [UIScreen mainScreen].scale)];
        _horizontalSeperatorLine.backgroundColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:0.5];
    }
    return _horizontalSeperatorLine;
}

-(UIView *)firstVerticalSeperatorLine{
    if (!_firstVerticalSeperatorLine) {
        _firstVerticalSeperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1 / [UIScreen mainScreen].scale, 40)];
        _firstVerticalSeperatorLine.backgroundColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:0.5];
    }
    return _firstVerticalSeperatorLine;
}

-(UIView *)secondVerticalSeperatorLine{
    if (!_secondVerticalSeperatorLine) {
        _secondVerticalSeperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1 / [UIScreen mainScreen].scale, 40)];
        _secondVerticalSeperatorLine.backgroundColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:0.5];
    }
    return _secondVerticalSeperatorLine;
}

-(UIView *)backGroundView{
    if (!_backGroundView) {
        _backGroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1 / [UIScreen mainScreen].scale, 40)];
    }
    return _backGroundView;
}

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
        _bottomView.backgroundColor = [UIColor clearColor];
    }
    return _bottomView;
}

-(UILabel *)incomeLab{
    if (!_incomeLab) {
        _incomeLab = [[UILabel alloc]init];
        _incomeLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _incomeLab.font = [UIFont systemFontOfSize:15];
    }
    return _incomeLab;
}

-(UILabel *)expenceLab{
    if (!_expenceLab) {
        _expenceLab = [[UILabel alloc]init];
        _expenceLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _expenceLab.font = [UIFont systemFontOfSize:15];
    }
    return _expenceLab;
}

- (void)setItem:(SSJCreditCardItem *)item{
    _item = item;
    self.backGroundView.backgroundColor = [UIColor ssj_colorWithHex:_item.cardColor];
    self.balanceLab.text = [NSString stringWithFormat:@"%.2f",_item.cardBalance];
    if (_item.cardBalance > 0) {
        self.balanceTitleLab.text = @"当前余额";
    }else{
        self.balanceTitleLab.text = @"当前欠款";
    }
    [self.balanceTitleLab sizeToFit];
    [self.balanceLab sizeToFit];
    self.limitLab.text = [NSString stringWithFormat:@"%.2f",_item.cardLimit];
    [self.limitLab sizeToFit];
    if (_item.cardRepaymentDay == 0) {
        self.repaymentDayLab.text = @"未设置";
    }else{
        self.repaymentDayLab.text = [NSString stringWithFormat:@"每月%ld日",_item.cardRepaymentDay];
    }
    [self.repaymentDayLab sizeToFit];
    if (_item.cardBillingDay == 0) {
        self.billingDayLab.text = @"未设置";
    }else{
        self.billingDayLab.text = [NSString stringWithFormat:@"每月%ld日",_item.cardBillingDay];
    }
    [self.billingDayLab sizeToFit];
}

-(void)setTotalIncome:(double)totalIncome{
    _totalIncome = totalIncome;
    self.incomeLab.text = [NSString stringWithFormat:@"累计收入:%.2f",_totalIncome];
    [self.incomeLab sizeToFit];
}

- (void)setTotalExpence:(double)totalExpence{
    _totalExpence = totalExpence;
    self.expenceLab.text = [NSString stringWithFormat:@"累计支出:%.2f",_totalExpence];
    [self.expenceLab sizeToFit];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
