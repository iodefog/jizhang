//
//  SSJFundingDetailListFirstLineCell.m
//  SuiShouJi
//
//  Created by ricky on 16/3/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingDetailListFirstLineCell.h"

@interface SSJFundingDetailListFirstLineCell()
@property(nonatomic, strong) UILabel *incomeLabel;
@property(nonatomic, strong) UILabel *expentureLabel;
@end

@implementation SSJFundingDetailListFirstLineCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor ssj_colorWithHex:@"ffffff" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self.contentView addSubview:self.incomeLabel];
        [self.contentView addSubview:self.expentureLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.incomeLabel.left = 10;
    self.incomeLabel.centerY = self.contentView.height / 2;
    self.expentureLabel.right = self.contentView.width - 10;
    self.expentureLabel.centerY = self.contentView.height / 2;
}

-(UILabel *)incomeLabel{
    if (!_incomeLabel) {
        _incomeLabel = [[UILabel alloc]init];
        _incomeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _incomeLabel.font = [UIFont systemFontOfSize:12];
    }
    return _incomeLabel;
}

-(UILabel *)expentureLabel{
    if (!_expentureLabel) {
        _expentureLabel = [[UILabel alloc]init];
        _expentureLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _expentureLabel.font = [UIFont systemFontOfSize:12];
    }
    return _expentureLabel;
}

-(void)setItem:(SSJFundingDetailListItem *)item{
    _item = item;
    self.incomeLabel.text = [NSString stringWithFormat:@"收入:%.2f",_item.income];
    [self.incomeLabel sizeToFit];
    self.expentureLabel.text = [NSString stringWithFormat:@"支出:%.2f",_item.expenture];
    [self.expentureLabel sizeToFit];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
