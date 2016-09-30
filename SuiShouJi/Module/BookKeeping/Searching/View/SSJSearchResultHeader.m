//
//  SSJSearchResultHeader.m
//  SuiShouJi
//
//  Created by ricky on 16/9/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSearchResultHeader.h"

@interface SSJSearchResultHeader()

@property(nonatomic, strong) UILabel *dateLabel;

@property(nonatomic, strong) UILabel *moneyLabel;

@end

@implementation SSJSearchResultHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.moneyLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.dateLabel.left = 10;
    self.dateLabel.centerY = self.height / 2;
    self.moneyLabel.right = self.contentView.width - 10;
    self.moneyLabel.centerY = self.height / 2;
}

-(UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _dateLabel.font = [UIFont systemFontOfSize:12];
    }
    return _dateLabel;
}

-(UILabel *)moneyLabel{
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc]init];
        _moneyLabel.font = [UIFont systemFontOfSize:12];
    }
    return _moneyLabel;
}

-(void)setItem:(SSJSearchResultItem *)item{
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
    if (item.balance > 0) {
        self.moneyLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurveIncomeColor];
        self.moneyLabel.text = [NSString stringWithFormat:@"+%.2f",item.balance];
    }else{
        self.moneyLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentColor];
        self.moneyLabel.text = [NSString stringWithFormat:@"%.2f",item.balance];
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
