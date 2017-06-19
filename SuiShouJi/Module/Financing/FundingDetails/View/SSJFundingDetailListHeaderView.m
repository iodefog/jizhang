//
//  SSJFundingDetailListHeader.m
//  SuiShouJi
//
//  Created by ricky on 16/3/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingDetailListHeaderView.h"
#import "SSJFundingDetailListItem.h"
#import "SSJCreditCardListDetailItem.h"
#import "SSJStrikeLineLabel.h"

@interface SSJFundingDetailListHeaderView()

@property(nonatomic, strong) UILabel *dateLabel;

@property(nonatomic, strong) UIButton *btn;

@property(nonatomic, strong) UILabel *moneyLabel;

@property(nonatomic, strong) UIImageView *expandImage;

@property(nonatomic, strong) UILabel *subLab;

@property(nonatomic, strong) SSJStrikeLineLabel *subDetailLab;

@property(nonatomic, strong) UIImageView *payOffImage;

@end

@implementation SSJFundingDetailListHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self addSubview:self.btn];
        [self addSubview:self.dateLabel];
        [self addSubview:self.expandImage];
        [self addSubview:self.moneyLabel];
        [self addSubview:self.subLab];
        [self addSubview:self.subDetailLab];
        [self addSubview:self.payOffImage];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.payOffImage.leftTop = CGPointMake(0, 0);
    if ([self.item isKindOfClass:[SSJCreditCardListDetailItem class]] && self.subLab.text.length) {
        self.btn.frame = self.bounds;
        self.dateLabel.left = 15;
        self.dateLabel.bottom = self.height / 2 - 5;
        self.expandImage.size = CGSizeMake(16, 8);
        self.expandImage.right = self.width - 15;
        self.expandImage.centerY = self.dateLabel.centerY;
        self.moneyLabel.right = self.expandImage.left - 10;
        self.moneyLabel.centerY = self.dateLabel.centerY;
        self.subLab.left = self.dateLabel.left;
        self.subLab.height = self.height / 2 + 7;
        self.subLab.bottom = self.height;
        self.subDetailLab.right = self.expandImage.right;
        self.subDetailLab.centerY = self.subLab.centerY;
        self.subLab.width = self.subDetailLab.left - self.subLab.left - 10;
    } else {
        self.btn.frame = self.bounds;
        self.dateLabel.left = 15;
        self.dateLabel.centerY = self.height / 2;
        self.expandImage.size = CGSizeMake(16, 8);
        self.expandImage.right = self.width - 15;
        self.expandImage.centerY = self.height / 2;
        self.moneyLabel.right = self.expandImage.left - 10;
        self.moneyLabel.centerY = self.height / 2;
    }
}

- (UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _dateLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _dateLabel;
}

- (UIButton *)btn{
    if (!_btn) {
        _btn = [[UIButton alloc]init];
        [_btn addTarget:self action:@selector(sectionHeaderClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn;
}

- (UILabel *)moneyLabel{
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc]init];
        _moneyLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
    }
    return _moneyLabel;
}

-(UIImageView *)expandImage{
    if (!_expandImage) {
        _expandImage = [[UIImageView alloc]init];
    }
    return _expandImage;
}

- (UILabel *)subLab{
    if (!_subLab) {
        _subLab = [[UILabel alloc] init];
        _subLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _subLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _subLab;
}

- (SSJStrikeLineLabel *)subDetailLab{
    if (!_subDetailLab) {
        _subDetailLab = [[SSJStrikeLineLabel alloc] init];
        _subDetailLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _subDetailLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _subDetailLab;
}

- (UIImageView *)payOffImage {
    if (!_payOffImage) {
        _payOffImage = [[UIImageView alloc] init];
        _payOffImage.image = [UIImage ssj_themeImageWithName:@"card_payoff"];
        [_payOffImage sizeToFit];
    }
    return _payOffImage;
}

- (void)setItem:(SSJBaseCellItem *)item{
    _item = item;
    if ([_item isKindOfClass:[SSJFundingDetailListItem class]]) {
        _payOffImage.hidden = YES;
        SSJFundingDetailListItem *fundingItem = (SSJFundingDetailListItem *)_item;
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM"];
        NSDate *date = [formatter dateFromString:fundingItem.date];
        NSString *dateStr;
        if ([fundingItem.date hasPrefix:[NSString stringWithFormat:@"%ld",(long)[NSDate date].year]]) {
            dateStr = [NSString stringWithFormat:@"%ld月",(long)date.month];
        }else{
            dateStr = [NSString stringWithFormat:@"%ld年%ld月",(long)date.year,(long)date.month];
        }
        self.dateLabel.text = dateStr;
        [self.dateLabel sizeToFit];
        if (fundingItem.income - fundingItem.expenture > 0) {
            self.moneyLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurveIncomeColor];
            self.moneyLabel.text = [NSString stringWithFormat:@"+%.2f",fundingItem.income - fundingItem.expenture];
        }else if (fundingItem.income - fundingItem.expenture < 0){
            self.moneyLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentColor];
            self.moneyLabel.text = [NSString stringWithFormat:@"%.2f",fundingItem.income - fundingItem.expenture];
        }else{
            self.moneyLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
            self.moneyLabel.text = @"0.00";
        }
        if (fundingItem.isExpand) {
            self.expandImage.image = [UIImage imageNamed:@"ft_zhankai"];
        }else{
            self.expandImage.image = [UIImage imageNamed:@"ft_shouqi"];
        }
        [self.moneyLabel sizeToFit];
    }else if ([_item isKindOfClass:[SSJCreditCardListDetailItem class]]){
        SSJCreditCardListDetailItem *creditCardItem = (SSJCreditCardListDetailItem *)_item;
        NSDate *date = [NSDate dateWithString:creditCardItem.month formatString:@"yyyy-MM"];
        NSString *dateStr;
        if ([creditCardItem.month hasPrefix:[NSString stringWithFormat:@"%ld",(long)[NSDate date].year]]) {
            dateStr = [NSString stringWithFormat:@"%ld月",(long)date.month];
        }else{
            dateStr = [NSString stringWithFormat:@"%ld年%ld月",(long)date.year,(long)date.month];
        }
        self.dateLabel.text = dateStr;
        [self.dateLabel sizeToFit];
        double totalMoney = creditCardItem.income - creditCardItem.expenture + creditCardItem.instalmentMoney;
        double moneyNeedToRepay = creditCardItem.income - creditCardItem.expenture + creditCardItem.repaymentMoney - creditCardItem.repaymentForOtherMonthMoney + creditCardItem.instalmentMoney;
        if (moneyNeedToRepay < 0) {
            self.payOffImage.hidden = YES;
            // 本期应还大于0
            if (creditCardItem.instalmentMoney > 0) {
                // 本期分期大于0
                if (creditCardItem.repaymentMoney > 0) {
                    // 本期还过款
                    self.subLab.text = [NSString stringWithFormat:@"(本期已还%@元,分期%@元)",[[NSString stringWithFormat:@"%f",fabs(creditCardItem.repaymentMoney)]  ssj_moneyDecimalDisplayWithDigits:2],[[NSString stringWithFormat:@"%f",fabs(creditCardItem.instalmentMoney)]  ssj_moneyDecimalDisplayWithDigits:2]];
                    self.subLab.width = SSJSCREENWITH;
                    self.subDetailLab.text = [NSString stringWithFormat:@"-%.2f",creditCardItem.instalmentMoney];
                } else {
                    // 本期未还过款
                    self.subLab.text = [NSString stringWithFormat:@"(账单已分期,本期应还金额为%@元)",[[NSString stringWithFormat:@"%f",fabs(moneyNeedToRepay)]  ssj_moneyDecimalDisplayWithDigits:2]];
                    self.subLab.numberOfLines = 0;
                    self.subDetailLab.text = [NSString stringWithFormat:@"-%.2f",creditCardItem.instalmentMoney];
                    self.subLab.width = SSJSCREENWITH - 80;
                }
            } else {
                // 本期没有分期过
                if (creditCardItem.repaymentMoney > 0) {
                    // 本期还过款
                    self.subLab.text = [NSString stringWithFormat:@"(本期已还%@元,剩余应还%@元)",[[NSString stringWithFormat:@"%f",fabs(creditCardItem.repaymentMoney)]  ssj_moneyDecimalDisplayWithDigits:2],[[NSString stringWithFormat:@"%f",fabs(moneyNeedToRepay)]  ssj_moneyDecimalDisplayWithDigits:2]];
                    self.subDetailLab.text = @"";
                } else {
                    // 本期未还过款
                    self.subLab.text = @"";
                    self.subDetailLab.text = @"";
                }

            }
        } else {
            if (creditCardItem.repaymentMoney > 0) {
                if (creditCardItem.instalmentMoney > 0) {
                    // 本期分过期
                    self.subLab.text = [NSString stringWithFormat:@"(账单已分期,本期应还金额为0.00元)"];
                    self.subDetailLab.text = [NSString stringWithFormat:@"-%.2f",creditCardItem.instalmentMoney];
                    self.payOffImage.hidden = YES;
                } else {
                    // 本期未分期代表已经还清
                    self.subLab.text = @"账单已还清";
                    self.payOffImage.hidden = NO;
                    self.subDetailLab.text = @"";
                }
            } else {
                if (creditCardItem.instalmentMoney > 0) {
                    self.subLab.text = [NSString stringWithFormat:@"(账单已分期,本期应还金额为0.00元)"];
                    self.subDetailLab.text = [NSString stringWithFormat:@"-%.2f",creditCardItem.instalmentMoney];
                    self.payOffImage.hidden = YES;
                } else {
                    self.subLab.text = @"";
                    self.subDetailLab.text = @"";
                    self.payOffImage.hidden = YES;
                }
            }

        }
        [self.subLab sizeToFit];
        [self.subDetailLab sizeToFit];
        if (totalMoney > 0) {
            self.moneyLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurveIncomeColor];
            self.moneyLabel.text = [NSString stringWithFormat:@"+%.2f",totalMoney];
        }else if (totalMoney < 0){
            self.moneyLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentColor];
            self.moneyLabel.text = [NSString stringWithFormat:@"%.2f",totalMoney];
        }else{
            self.moneyLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
            self.moneyLabel.text = @"0.00";
        }
        if (creditCardItem.isExpand) {
            self.expandImage.image = [UIImage imageNamed:@"ft_zhankai"];
        }else{
            self.expandImage.image = [UIImage imageNamed:@"ft_shouqi"];
        }
        [self.moneyLabel sizeToFit];
    }
    [self setNeedsLayout];
}

- (void)sectionHeaderClicked:(id)sender{
    if (self.SectionHeaderClickedBlock) {
        self.SectionHeaderClickedBlock();
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
