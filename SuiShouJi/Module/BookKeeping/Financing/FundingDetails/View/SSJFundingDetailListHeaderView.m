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
@property(nonatomic, strong) UIImageView *expandImage;
@end

@implementation SSJFundingDetailListHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self ssj_setBorderWidth:1.f];
        [self ssj_setBorderStyle:SSJBorderStyleBottom];
        [self ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.btn];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.expandImage];
        [self.contentView addSubview:self.moneyLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.btn.frame = self.contentView.frame;
    self.dateLabel.left = 10;
    self.dateLabel.centerY = self.contentView.height / 2;
    self.expandImage.size = CGSizeMake(16, 8);
    self.expandImage.right = self.contentView.width - 10;
    self.expandImage.centerY = self.contentView.height / 2;
    self.moneyLabel.right = self.expandImage.left - 10;
    self.moneyLabel.centerY = self.contentView.height / 2;
    [self ssj_relayoutBorder];
}

- (UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
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
        _moneyLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
    }
    return _moneyLabel;
}

-(UIImageView *)expandImage{
    if (!_expandImage) {
        _expandImage = [[UIImageView alloc]init];
    }
    return _expandImage;
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
    if (_item.income - _item.expenture > 0) {
        self.moneyLabel.textColor = [UIColor ssj_colorWithHex:@"00d0b6"];
        self.moneyLabel.text = [NSString stringWithFormat:@"+%.2f",_item.income - _item.expenture];
    }else if (_item.income - _item.expenture < 0){
        self.moneyLabel.textColor = [UIColor ssj_colorWithHex:@"ea3a3a"];
        self.moneyLabel.text = [NSString stringWithFormat:@"%.2f",_item.income - _item.expenture];
    }
    if (_item.isExpand) {
        self.expandImage.image = [UIImage imageNamed:@"ft_zhankai"];
    }else{
        self.expandImage.image = [UIImage imageNamed:@"ft_shouqi"];
    }
    [self.moneyLabel sizeToFit];
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
