
//
//  SSJCreditCardListCell.m
//  SuiShouJi
//
//  Created by ricky on 16/8/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCreditCardListCell.h"

@interface SSJCreditCardListCell()

@property(nonatomic, strong) UILabel *incomeLab;

@property(nonatomic, strong) UILabel *expenseLab;

@property(nonatomic, strong) UILabel *periodLab;

@property(nonatomic, strong) UILabel *daysLab;

@end

@implementation SSJCreditCardListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}

-(UILabel *)incomeLab{
    if (!_incomeLab) {
        _incomeLab = [[UILabel alloc]init];
        _incomeLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _incomeLab.font = [UIFont systemFontOfSize:13];
    }
    return _incomeLab;
}

-(UILabel *)expenseLab{
    if (!_expenseLab) {
        _expenseLab = [[UILabel alloc]init];
        _expenseLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _expenseLab.font = [UIFont systemFontOfSize:13];
    }
    return _expenseLab;
}

-(UILabel *)periodLab{
    if (!_periodLab) {
        _periodLab = [[UILabel alloc]init];
        _periodLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _periodLab.font = [UIFont systemFontOfSize:13];
    }
    return _periodLab;
}

-(UILabel *)daysLab{
    if (!_daysLab) {
        _daysLab = [[UILabel alloc]init];
        _daysLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _daysLab.font = [UIFont systemFontOfSize:13];
    }
    return _daysLab;
}

- (void)setItem:(SSJCreditCardListDetailItem *)item{
    _item = item;
    self.incomeLab.text = [NSString stringWithFormat:@"%.2f",_item.income];
    [self.incomeLab sizeToFit];
    self.expenseLab.text = [NSString stringWithFormat:@"%.2f",_item.expenture];
    [self.expenseLab sizeToFit];
    self.periodLab.text = _item.datePeriod;
    [self.periodLab sizeToFit];
    NSDate *date = [NSDate dateWithString:_item.month formatString:@"yyyy-MM-dd"];
    if (date.year == [NSDate date].year) {
        if (date.month == [NSDate date].month) {
            if (date.day < _item.billingDay) {
                self.daysLab.text = [NSString stringWithFormat:@"距账单日:%ld",_item.billingDay - date.day];
                [self.daysLab sizeToFit];
            }else{
                self.daysLab.text = [NSString stringWithFormat:@"距还款日:%ld",date.daysInMonth - date.day + _item.repaymentDay];
                [self.daysLab sizeToFit];
            }
        }else if(date.month == [NSDate date].month - 1){
            if (date.day < _item.repaymentDay) {
                self.daysLab.text = [NSString stringWithFormat:@"距还款日:%ld",_item.repaymentDay - date.day];
                [self.daysLab sizeToFit];
            }
        }
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
