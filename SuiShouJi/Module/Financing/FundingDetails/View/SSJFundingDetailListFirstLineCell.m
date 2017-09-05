//
//  SSJFundingDetailListFirstLineCell.m
//  SuiShouJi
//
//  Created by ricky on 16/3/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingDetailListFirstLineCell.h"

@interface SSJFundingDetailListFirstLineCell()
@property(nonatomic, strong) UILabel *remaningDaysLab;
@property(nonatomic, strong) UILabel *pariodLab;
@end

@implementation SSJFundingDetailListFirstLineCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self.contentView addSubview:self.remaningDaysLab];
        [self.contentView addSubview:self.pariodLab];
    }
    return self;
}

- (void)updateConstraints {
    [self.pariodLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(self);
    }];

    [self.remaningDaysLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-15);
        make.centerY.mas_equalTo(self);
    }];

    [super updateConstraints];
}

-(UILabel *)remaningDaysLab{
    if (!_remaningDaysLab) {
        _remaningDaysLab = [[UILabel alloc]init];
        _remaningDaysLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _remaningDaysLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
    }
    return _remaningDaysLab;
}

-(UILabel *)pariodLab{
    if (!_pariodLab) {
        _pariodLab = [[UILabel alloc]init];
        _pariodLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _pariodLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
    }
    return _pariodLab;
}

-(void)setItem:(SSJCreditCardListFirstLineItem *)item{
    _item = item;
    self.remaningDaysLab.text = _item.remainingDaysStr;
    self.pariodLab.text = _item.period;
    [self setNeedsUpdateConstraints];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
