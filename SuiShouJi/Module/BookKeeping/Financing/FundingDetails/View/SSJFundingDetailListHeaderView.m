//
//  SSJFundingDetailListHeader.m
//  SuiShouJi
//
//  Created by ricky on 16/3/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingDetailListHeaderView.h"
@interface SSJFundingDetailListHeaderView()
@property(nonatomic, strong) UILabel *dateLabel;
@property(nonatomic, strong) UIButton *btn;
@property(nonatomic, strong) UILabel *moneyLabel;
@end

@implementation SSJFundingDetailListHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.moneyLabel];
        [self.contentView addSubview:self.btn];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.dateLabel.left = 20;
    self.dateLabel.centerY = self.contentView.height / 2;
    self.btn.frame = self.contentView.frame;
    self.moneyLabel.right = self.contentView.width - 20;
    self.moneyLabel.centerY = self.contentView.height / 2;
}

- (UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.textColor = [UIColor ssj_colorWithHex:@"a9a9a9"];
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
        _moneyLabel.textColor = [UIColor ssj_colorWithHex:@"a9a9a9"];
        _moneyLabel.font = [UIFont systemFontOfSize:15];
    }
    return _moneyLabel;
}

- (void)setItem:(SSJFundingDetailListItem *)item{
    _item = item;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM"];
    NSDate *date = [formatter dateFromString:_item.date];
    NSString *dateStr;
    if ([_item.date hasPrefix:[NSString stringWithFormat:@"%ld",[NSDate date].year]]) {
        dateStr = [NSString stringWithFormat:@"%ld月",date.month];
    }else{
        dateStr = [NSString stringWithFormat:@"%ld年%ld月",date.year,date.month];
    }
    self.dateLabel.text = dateStr;
    [self.dateLabel sizeToFit];
    self.moneyLabel.text = [NSString stringWithFormat:@"%.2f",_item.income - _item.expenture];
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
