
//
//  SSJCanlenderChargeDetailCell.m
//  SuiShouJi
//
//  Created by ricky on 16/8/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCanlenderChargeDetailCell.h"

@interface SSJCanlenderChargeDetailCell()

@property(nonatomic, strong) UILabel *dateLab;

@property(nonatomic, strong) UILabel *fundLab;

@property(nonatomic, strong) UILabel *booksLab;

@property(nonatomic, strong) UILabel *memoLab;

@property(nonatomic, strong) UILabel *dateDetailLab;

@property(nonatomic, strong) UILabel *fundDetailLab;

@property(nonatomic, strong) UILabel *booksDetailLab;

@property(nonatomic, strong) UILabel *memoDetailLab;
@end

@implementation SSJCanlenderChargeDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.dateLab];
        [self.contentView addSubview:self.dateDetailLab];
        [self.contentView addSubview:self.fundLab];
        [self.contentView addSubview:self.fundDetailLab];
        [self.contentView addSubview:self.booksLab];
        [self.contentView addSubview:self.booksDetailLab];
        [self.contentView addSubview:self.memoLab];
        [self.contentView addSubview:self.memoDetailLab];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.dateLab.leftTop = CGPointMake(10, 10);
    self.dateDetailLab.rightBottom = CGPointMake(self.width - 10, self.dateLab.bottom);
    self.fundLab.leftTop = CGPointMake(10, self.dateLab.bottom + 17);
    self.fundDetailLab.rightBottom = CGPointMake(self.width - 10, self.fundLab.bottom);
    self.booksLab.leftTop = CGPointMake(10, self.fundLab.bottom + 17);
    self.booksDetailLab.rightBottom = CGPointMake(self.width - 10, self.booksLab.bottom);
    if (self.item.chargeMemo.length) {
        self.memoLab.hidden = NO;
        self.memoLab.leftTop = CGPointMake(10, self.booksLab.bottom + 17);
        self.memoDetailLab.rightBottom = CGPointMake(self.width - 10, self.memoLab.bottom);
    }else{
        self.memoLab.hidden = YES;
    }
}

- (UILabel *)dateLab{
    if (!_dateLab) {
        _dateLab = [[UILabel alloc]init];
        _dateLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _dateLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _dateLab.text = @"时间";
        [_dateLab sizeToFit];
    }
    return _dateLab;
}

- (UILabel *)fundLab{
    if (!_fundLab) {
        _fundLab = [[UILabel alloc]init];
        _fundLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _fundLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _fundLab.text = @"资金类型";
        [_fundLab sizeToFit];
    }
    return _fundLab;
}

- (UILabel *)booksLab{
    if (!_booksLab) {
        _booksLab = [[UILabel alloc]init];
        _booksLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _booksLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _booksLab.text = @"账本类型";
        [_booksLab sizeToFit];
    }
    return _booksLab;
}

- (UILabel *)memoLab{
    if (!_memoLab) {
        _memoLab = [[UILabel alloc]init];
        _memoLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _memoLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _memoLab.text = @"备注";
        [_memoLab sizeToFit];
    }
    return _memoLab;
}

- (UILabel *)dateDetailLab{
    if (!_dateDetailLab) {
        _dateDetailLab = [[UILabel alloc]init];
        _dateDetailLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _dateDetailLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _dateDetailLab;
}

- (UILabel *)fundDetailLab{
    if (!_fundDetailLab) {
        _fundDetailLab = [[UILabel alloc]init];
        _fundDetailLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _fundDetailLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _fundDetailLab;
}

- (UILabel *)booksDetailLab{
    if (!_booksDetailLab) {
        _booksDetailLab = [[UILabel alloc]init];
        _booksDetailLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _booksDetailLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _booksDetailLab;
}

- (UILabel *)memoDetailLab{
    if (!_memoDetailLab) {
        _memoDetailLab = [[UILabel alloc]init];
        _memoDetailLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _memoDetailLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _memoDetailLab;
}

- (void)setItem:(SSJBillingChargeCellItem *)item{
    _item = item;
    self.dateDetailLab.text = [NSString stringWithFormat:@"%@  %@",_item.billDate,_item.billDetailDate];
    [self.dateDetailLab sizeToFit];
    self.fundDetailLab.text = _item.fundName;
    [self.fundDetailLab sizeToFit];
    self.booksDetailLab.text = _item.booksName;
    [self.booksDetailLab sizeToFit];
    CGSize memoSize = [_item.chargeMemo sizeWithAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3]}];

    if (memoSize.width > self.width - _memoLab.width - 30) {
        self.memoDetailLab.text = _item.chargeMemo;
        self.memoDetailLab.width = self.width - _memoLab.width - 30;
        self.memoDetailLab.height = memoSize.height;
        self.memoDetailLab.textAlignment = NSTextAlignmentLeft;
    } else {
        self.memoDetailLab.text = _item.chargeMemo;
        [self.memoDetailLab sizeToFit];
    }
    [self setNeedsLayout];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
