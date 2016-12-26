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

@interface SSJFundingDetailListHeaderView()

@property(nonatomic, strong) UILabel *dateLabel;

@property(nonatomic, strong) UIButton *btn;

@property(nonatomic, strong) UILabel *moneyLabel;

@property(nonatomic, strong) UIImageView *expandImage;

@property(nonatomic, strong) UILabel *subLab;

@property(nonatomic, strong) UILabel *subDetailLab;

@property(nonatomic, strong) UIImageView *payOffImage;

@end

@implementation SSJFundingDetailListHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self ssj_setBorderWidth:1.f];
        [self ssj_setBorderStyle:SSJBorderStyleBottom];
        [self ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        self.backgroundColor = [UIColor ssj_colorWithHex:@"ffffff" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self addSubview:self.btn];
        [self addSubview:self.dateLabel];
        [self addSubview:self.expandImage];
        [self addSubview:self.moneyLabel];
        [self addSubview:self.subLab];
        [self addSubview:self.subDetailLab];
//        [self addSubview:self.payOffImage];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.payOffImage.leftTop = CGPointMake(0, 0);
    if ([self.item isKindOfClass:[SSJCreditCardListDetailItem class]] && ((SSJCreditCardListDetailItem *)self.item).instalmentMoney > 0) {
        self.btn.frame = self.bounds;
        self.dateLabel.left = 10;
        self.dateLabel.bottom = self.height / 2 - 5;
        self.expandImage.size = CGSizeMake(16, 8);
        self.expandImage.right = self.width - 10;
        self.expandImage.centerY = self.dateLabel.centerY;
        self.moneyLabel.right = self.expandImage.left - 10;
        self.moneyLabel.centerY = self.dateLabel.centerY;
        self.subLab.left = self.dateLabel.left;
        self.subLab.top = self.height / 2 + 5;
        self.subDetailLab.right = self.expandImage.right;
        self.subDetailLab.centerY = self.subLab.centerY;
        [self ssj_relayoutBorder];
    } else {
        self.btn.frame = self.bounds;
        self.dateLabel.left = 10;
        self.dateLabel.centerY = self.height / 2;
        self.expandImage.size = CGSizeMake(16, 8);
        self.expandImage.right = self.width - 10;
        self.expandImage.centerY = self.height / 2;
        self.moneyLabel.right = self.expandImage.left - 10;
        self.moneyLabel.centerY = self.height / 2;
        [self ssj_relayoutBorder];
    }
}

- (UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _dateLabel.font = [UIFont systemFontOfSize:15];
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
        _moneyLabel.font = [UIFont systemFontOfSize:18];
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
        _subLab.font = [UIFont systemFontOfSize:15];
        _subLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _subLab;
}

- (UILabel *)subDetailLab{
    if (!_subDetailLab) {
        _subDetailLab = [[UILabel alloc] init];
        _subDetailLab.font = [UIFont systemFontOfSize:15];
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

- (void)setItem:(SSJBaseItem *)item{
    _item = item;
    if ([_item isKindOfClass:[SSJFundingDetailListItem class]]) {
        _payOffImage.hidden = YES;
        SSJFundingDetailListItem *fundingItem = (SSJFundingDetailListItem *)_item;
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM"];
        NSDate *date = [formatter dateFromString:fundingItem.date];
        NSString *dateStr;
        if ([fundingItem.date hasPrefix:[NSString stringWithFormat:@"%ld",[NSDate date].year]]) {
            dateStr = [NSString stringWithFormat:@"%ld月",date.month];
        }else{
            dateStr = [NSString stringWithFormat:@"%ld年%ld月",date.year,date.month];
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
        if ([creditCardItem.month hasPrefix:[NSString stringWithFormat:@"%ld",[NSDate date].year]]) {
            dateStr = [NSString stringWithFormat:@"%ld月",date.month];
        }else{
            dateStr = [NSString stringWithFormat:@"%ld年%ld月",date.year,date.month];
        }
        self.dateLabel.text = dateStr;
        [self.dateLabel sizeToFit];
        double totalMoney = creditCardItem.income - creditCardItem.expenture + creditCardItem.instalmentMoney;
        double moneyNeedToRepay = creditCardItem.income - creditCardItem.expenture + creditCardItem.repaymentMoney - creditCardItem.repaymentForOtherMonthMoney;
        if (creditCardItem.instalmentMoney > 0) {
            if (totalMoney < 0) {
                self.subLab.text = [NSString stringWithFormat:@"(账单已分期,本期应还金额为%@元)",[[NSString stringWithFormat:@"%f",fabs(totalMoney)]  ssj_moneyDecimalDisplayWithDigits:2]];
            } else {
                self.subLab.text = [NSString stringWithFormat:@"(账单已分期,本期应还金额为0.00元)"];
            }
            NSString *instalmentMoneyStr = [[NSString stringWithFormat:@"-%f",creditCardItem.instalmentMoney] ssj_moneyDecimalDisplayWithDigits:2];
            NSMutableAttributedString *attributeInstalmenStr = [[NSMutableAttributedString alloc] initWithString:instalmentMoneyStr];
            [attributeInstalmenStr addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, instalmentMoneyStr.length)];
            self.subDetailLab.attributedText = attributeInstalmenStr;
        } else {
            self.subLab.text = @"";
            self.subDetailLab.text = @"";
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
