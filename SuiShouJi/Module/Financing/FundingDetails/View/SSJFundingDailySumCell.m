
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
        self.backgroundColor = [UIColor ssj_colorWithHex:@"F6F6F6"];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
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
        _dateLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        _dateLabel.font = [UIFont systemFontOfSize:12];
    }
    return _dateLabel;
}

-(UILabel *)moneyLabel{
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc]init];
        _moneyLabel.font = [UIFont systemFontOfSize:12];
        _moneyLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
    }
    return _moneyLabel;
}

-(void)setItem:(SSJFundingListDayItem *)item{
    _item = item;
    self.dateLabel.text = _item.date;
    [self.dateLabel sizeToFit];
    double sumMoney = _item.income - _item.expenture;
    if (sumMoney > 0) {
        self.moneyLabel.textColor = [UIColor ssj_colorWithHex:@"00d0b6"];
        self.moneyLabel.text = [NSString stringWithFormat:@"+%.2f",sumMoney];
    }else{
        self.moneyLabel.textColor = [UIColor ssj_colorWithHex:@"ea3a3a"];
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
