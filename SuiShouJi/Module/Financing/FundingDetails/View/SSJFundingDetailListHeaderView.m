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

@property(nonatomic, strong) UILabel *yearLab;

@property(nonatomic, strong) UILabel *monthLab;

@property(nonatomic, strong) UILabel *incomeLab;

@property(nonatomic, strong) UILabel *expenceLab;

@property(nonatomic, strong) UILabel *totalMoneyLab;

@property(nonatomic, strong) UILabel *totalMoneyTitleLab;

@property(nonatomic, strong) SSJStrikeLineLabel *instalmentMoneyLab;

@property(nonatomic, strong) UIImageView *payOffImage;

@property(nonatomic, strong) UIImageView *arrowImage;

@end

@implementation SSJFundingDetailListHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self addSubview:self.yearLab];
        [self addSubview:self.monthLab];
        [self addSubview:self.incomeLab];
        [self addSubview:self.expenceLab];
        [self addSubview:self.totalMoneyLab];
        [self addSubview:self.totalMoneyTitleLab];
        [self addSubview:self.instalmentMoneyLab];
        [self addSubview:self.arrowImage];
        [self addSubview:self.payOffImage];
    }
    return self;
}

- (void)updateConstraints {
    [self.monthLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(17);
    }];
    
    [self.yearLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(self.monthLab.mas_bottom).offset(3);
    }];
    
    [self.incomeLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.yearLab.mas_right).offset(14);
        make.centerY.mas_equalTo(self.yearLab);
    }];
    
    [self.expenceLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.yearLab.mas_right).offset(14);
        make.centerY.mas_equalTo(self.monthLab);
    }];
    
    [self.arrowImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-15);
        make.centerY.mas_equalTo(self);
    }];
    
    [self.totalMoneyLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.arrowImage.mas_left).offset(-12);
        make.centerY.mas_equalTo(self.monthLab);
    }];
    
    [self.totalMoneyTitleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.arrowImage.mas_left).offset(-12);
        make.centerY.mas_equalTo(self.yearLab);
    }];
    
    [self.instalmentMoneyLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.arrowImage.mas_left).offset(-12);
        make.centerY.mas_equalTo(self.monthLab);
    }];
    
    [self.payOffImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self);
    }];
    
    [super updateConstraints];
}

- (UILabel *)monthLab {
    if (!_monthLab) {
        _monthLab = [[UILabel alloc] init];
        _monthLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _monthLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _monthLab;
}

- (UILabel *)yearLab {
    if (!_yearLab) {
        _yearLab = [[UILabel alloc] init];
        _yearLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _yearLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_5];
    }
    return _yearLab;
}

- (UILabel *)incomeLab {
    if (!_incomeLab) {
        _incomeLab = [[UILabel alloc] init];
        _incomeLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _incomeLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _incomeLab;
}

- (UILabel *)expenceLab {
    if (!_expenceLab) {
        _expenceLab = [[UILabel alloc] init];
        _expenceLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _expenceLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _expenceLab;
}

- (UILabel *)totalMoneyLab {
    if (!_totalMoneyLab) {
        _totalMoneyLab = [[UILabel alloc] init];
        _totalMoneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _totalMoneyLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_1];
    }
    return _totalMoneyLab ;
}

- (UILabel *)totalMoneyTitleLab {
    if (!_totalMoneyTitleLab) {
        _totalMoneyTitleLab = [[UILabel alloc] init];
        _totalMoneyTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _totalMoneyTitleLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_4];
        _totalMoneyTitleLab.text = @"月结余";
    }
    return _totalMoneyTitleLab;
}

- (SSJStrikeLineLabel *)instalmentMoneyLab {
    if (!!_instalmentMoneyLab) {
        _instalmentMoneyLab = [[SSJStrikeLineLabel alloc] init];
        _instalmentMoneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _instalmentMoneyLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _instalmentMoneyLab;
}

- (UIImageView *)arrowImage {
    if (!_arrowImage) {
        _arrowImage = [[UIImageView alloc] init];
        _arrowImage.image = [[UIImage imageNamed:@"ft_arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _arrowImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _arrowImage;
}


- (UIImageView *)payOffImage {
    if (!_payOffImage) {
        _payOffImage = [[UIImageView alloc] init];
        _payOffImage.image = [UIImage ssj_themeImageWithName:@"card_payoff"];
    }
    return _payOffImage;
}


- (void)setItem:(SSJBaseCellItem *)item{
    _item = item;
    if ([_item isKindOfClass:[SSJFundingDetailListItem class]]) {
        _payOffImage.hidden = YES;
        SSJFundingDetailListItem *fundingItem = (SSJFundingDetailListItem *)_item;
        NSDate *currentDate = [NSDate dateWithString:fundingItem.date formatString:@"yyyy-MM"];
        self.monthLab.text = [NSString stringWithFormat:@"%02ld月",currentDate.month];
        self.yearLab.text = [NSString stringWithFormat:@"%04ld",currentDate.year];
        self.incomeLab.text = [NSString stringWithFormat:@"收入:%@",[[NSString stringWithFormat:@"%f",fundingItem.income] ssj_moneyDecimalDisplayWithDigits:2]];
        self.expenceLab.text = [NSString stringWithFormat:@"支出:%@",[[NSString stringWithFormat:@"%f",fundingItem.expenture] ssj_moneyDecimalDisplayWithDigits:2]];
        self.totalMoneyLab.text = [NSString stringWithFormat:@"%@",[[NSString stringWithFormat:@"%f",fundingItem.income - fundingItem.expenture] ssj_moneyDecimalDisplayWithDigits:2]];
        if (fundingItem.isExpand) {
            self.arrowImage.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        } else {
            self.arrowImage.layer.transform = CATransform3DIdentity;
        }
    }else if ([_item isKindOfClass:[SSJCreditCardListDetailItem class]]){
        SSJCreditCardListDetailItem *creditCardItem = (SSJCreditCardListDetailItem *)_item;
        NSDate *currentDate = [NSDate dateWithString:creditCardItem.month formatString:@"yyyy-MM"];
        self.monthLab.text = [NSString stringWithFormat:@"%02ld月",currentDate.month];
        self.yearLab.text = [NSString stringWithFormat:@"%04ld",currentDate.year];
        self.totalMoneyLab.text = [NSString stringWithFormat:@"%@",[[NSString stringWithFormat:@"%f",creditCardItem.income - creditCardItem.expenture] ssj_moneyDecimalDisplayWithDigits:2]];
        self.expenceLab.text = [NSString stringWithFormat:@"账单周期:%@",creditCardItem.datePeriod];
        NSDate *billingDate = [NSDate date];
        NSDate *repaymentDate = [NSDate date];
        NSDate *today = [NSDate date];
        if (creditCardItem.billingDay < creditCardItem.repaymentDay) {
            billingDate = [NSDate dateWithYear:currentDate.year month:currentDate.month day:creditCardItem.billingDay];
            repaymentDate = [NSDate dateWithYear:currentDate.year month:currentDate.month day:creditCardItem.repaymentDay];
        }else{
            billingDate = [NSDate dateWithYear:currentDate.year month:currentDate.month day:creditCardItem.billingDay];
            repaymentDate = [NSDate dateWithYear:currentDate.year month:currentDate.month + 1 day:creditCardItem.repaymentDay];
        }
        NSInteger daysToBillingDate = [billingDate daysFrom:today] + 1;
        NSInteger daysToRepaymentDate = [repaymentDate daysFrom:today] + 1;
        NSInteger minmumDays = MIN(daysToBillingDate, daysToRepaymentDate);
        if (daysToBillingDate > 0 || daysToRepaymentDate > 0) {
            if (!daysToBillingDate) {
                self.incomeLab.text = [NSString stringWithFormat:@"距还款日:%d天",(int)daysToRepaymentDate];
            }else if(!daysToRepaymentDate){
                self.incomeLab.text = [NSString stringWithFormat:@"距账单日:%d天",(int)daysToBillingDate];
            }else{
                if (minmumDays + 1 < 0) {
                    if (daysToBillingDate + 1 > 0) {
                        self.incomeLab.text = [NSString stringWithFormat:@"距账单日:%d天",(int)daysToBillingDate];
                    }else if(daysToRepaymentDate > 0){
                        self.incomeLab.text = [NSString stringWithFormat:@"距还款日:%d天",(int)daysToRepaymentDate];
                    }else{
                        self.incomeLab.text = @"";
                    }
                }else{
                    if (daysToBillingDate + 1 > 0) {
                        self.incomeLab.text = [NSString stringWithFormat:@"距账单日:%d天",(int)daysToBillingDate];
                    }else{
                        self.incomeLab.text = [NSString stringWithFormat:@"距还款日:%d天",(int)daysToRepaymentDate];
                    }
                }
            }
        }

        double moneyNeedToRepay = creditCardItem.income - creditCardItem.expenture + creditCardItem.repaymentMoney - creditCardItem.repaymentForOtherMonthMoney + creditCardItem.instalmentMoney;
        self.payOffImage.hidden = moneyNeedToRepay > 0 ? NO : YES;

        if (creditCardItem.isExpand) {
            self.arrowImage.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        } else {
            self.arrowImage.layer.transform = CATransform3DIdentity;
        }
    }
    [self setNeedsUpdateConstraints];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
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
