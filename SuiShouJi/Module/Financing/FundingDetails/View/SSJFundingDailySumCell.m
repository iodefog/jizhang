
//
//  SSJFundingDailySumCell.m
//  SuiShouJi
//
//  Created by ricky on 16/3/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingDailySumCell.h"

@interface SSJFundingDailySumCell()

@property(nonatomic, strong) UILabel *dateLabel;

@property(nonatomic, strong) UILabel *moneyLabel;

@end

@implementation SSJFundingDailySumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.moneyLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.dateLabel.left = 15;
    self.dateLabel.centerY = self.height / 2;
    self.moneyLabel.right = self.contentView.width - 15;
    self.moneyLabel.centerY = self.height / 2;
}

-(UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _dateLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _dateLabel;
}

-(UILabel *)moneyLabel{
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc]init];
        _moneyLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _moneyLabel;
}

-(void)setItem:(SSJFundingListDayItem *)item{
    _item = item;
    NSDate *billDate = [NSDate dateWithString:_item.date formatString:@"yyyy-MM-dd"];
    NSString *dateStr = [billDate formattedDateWithFormat:@"yyyy年MM月dd日"];
    NSString *weekStr;

    switch (billDate.weekday) {
        case 1 : {
            weekStr = @"星期日";
            break;
        }
        case 2 : {
            weekStr = @"星期一";
            break;
        }
        case 3 : {
            weekStr = @"星期二";
            break;
        }
        case 4 : {
            weekStr = @"星期三";
            break;
        }
        case 5 : {
            weekStr = @"星期四";
            break;
        }
        case 6 : {
            weekStr = @"星期五";
            break;
        }
        case 7 : {
            weekStr = @"星期六";
            break;
        }
                
        default : {
            weekStr = @"";
            break;
        }
    }
    self.dateLabel.text = [NSString stringWithFormat:@"%@ %@",dateStr,weekStr];
    [self.dateLabel sizeToFit];
    double sumMoney = _item.income - _item.expenture;
    if (sumMoney > 0) {
        self.moneyLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurveIncomeColor];
        self.moneyLabel.text = [NSString stringWithFormat:@"+%.2f",sumMoney];
    }else{
        self.moneyLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentColor];
        self.moneyLabel.text = [NSString stringWithFormat:@"%.2f",sumMoney];
    }
    [self.moneyLabel sizeToFit];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
