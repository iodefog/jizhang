//
//  SSJCalendarTableViewCell.m
//  SuiShouJi
//
//  Created by ricky on 2017/2/9.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCalendarTableViewCell.h"
#import <Masonry.h>

@interface SSJCalendarTableViewCell()

@property(nonatomic, strong) UIImageView *typeImage;

@property(nonatomic, strong) UIImageView *photo;

@property(nonatomic, strong) UIView *topSeparator;

@property(nonatomic, strong) UIView *bottomSeparator;

@property(nonatomic, strong) UIView *separator;

@property(nonatomic, strong) UILabel *memoLab;

@property(nonatomic, strong) UILabel *moneyLab;

@property(nonatomic, strong) UILabel *detailDateLab;

@property(nonatomic, strong) UILabel *typeLab;

@end

@implementation SSJCalendarTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.typeImage];
        [self.contentView addSubview:self.photo];
        [self.contentView addSubview:self.topSeparator];
        [self.contentView addSubview:self.bottomSeparator];
        [self.contentView addSubview:self.separator];
        [self.contentView addSubview:self.memoLab];
        [self.contentView addSubview:self.moneyLab];
        [self.contentView addSubview:self.detailDateLab];
        [self.contentView addSubview:self.typeLab];
        [self setUpConstraints];
    }
    return self;
}

- (UIImageView *)typeImage{
    if (!_typeImage) {
        _typeImage = [[UIImageView alloc] init];
        _typeImage.contentMode = UIViewContentModeCenter;
    }
    return _typeImage;
}

- (UIImageView *)photo{
    if (!_photo) {
        _photo = [[UIImageView alloc] init];
        _photo.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _photo.image = [UIImage imageNamed:@"mark_pic"];
    }
    return _photo;
}

- (UIView *)topSeparator {
    if (!_topSeparator) {
        _topSeparator = [[UIView alloc] init];
        _topSeparator.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _topSeparator;
}

- (UIView *)bottomSeparator {
    if (!_bottomSeparator) {
        _bottomSeparator = [[UIView alloc] init];
        _bottomSeparator.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];

    }
    return _bottomSeparator;
}

- (UIView *)separator {
    if (!_separator) {
        _separator = [[UIView alloc] init];
        _separator.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _separator;
}

- (UILabel *)typeLab {
    if (!_typeLab) {
        _typeLab = [[UILabel alloc] init];
        _typeLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _typeLab.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
    }
    return _typeLab;
}

- (UILabel *)memoLab {
    if (!_memoLab) {
        _memoLab = [[UILabel alloc] init];
        _memoLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _memoLab.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_4);
    }
    return _memoLab;
}

- (UILabel *)moneyLab {
    if (!_moneyLab) {
        _moneyLab = [[UILabel alloc] init];
        _moneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _moneyLab.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
    }
    return _moneyLab;
}

- (UILabel *)detailDateLab {
    if (!_detailDateLab) {
        _detailDateLab = [[UILabel alloc] init];
        _detailDateLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _detailDateLab;
}

- (void)setItem:(SSJBillingChargeCellItem *)item {
    _item = item;
    self.detailDateLab.text = item.billDetailDate;
    self.typeImage.image = [[UIImage imageNamed:item.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.typeImage.tintColor = [UIColor ssj_colorWithHex:item.colorValue];
    self.typeImage.layer.cornerRadius = 15;
    self.typeImage.layer.borderColor = [UIColor ssj_colorWithHex:item.colorValue].CGColor;
    self.typeImage.layer.borderWidth = 1;
    self.typeImage.contentScaleFactor = [UIScreen mainScreen].scale * self.typeImage.image.size.width / (30 * 0.75);
    self.typeLab.text = item.typeName;
    self.photo.hidden = !item.chargeImage.length;
    self.separator.hidden = !(item.chargeImage.length && item.chargeMemo.length);
    self.memoLab.text = item.chargeMemo;
    if (!item.incomeOrExpence) {
        self.moneyLab.text = [NSString stringWithFormat:@"+%@",[item.money ssj_moneyDecimalDisplayWithDigits:2]];
    } else {
        self.moneyLab.text = [NSString stringWithFormat:@"-%@",[item.money ssj_moneyDecimalDisplayWithDigits:2]];
    }
    [self customUpdateConstraints];
}

- (void)setIsLastRow:(BOOL)isLastRow {
    self.bottomSeparator.hidden = isLastRow;
}

- (void)setIsFirstRow:(BOOL)isFirstRow {
    self.topSeparator.hidden = isFirstRow;
}

- (void)setUpConstraints {
    [_detailDateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView).with.offset(10);
    }];
    
    [_typeImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.left.equalTo(self.contentView.mas_left).with.offset(70);
    }];
    
    [_topSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1 / [UIScreen mainScreen].scale);
        make.top.equalTo(self.contentView.mas_top);
        make.bottom.equalTo(self.typeImage.mas_top);
        make.centerX.equalTo(self.typeImage.mas_centerX);
    }];
    
    [_bottomSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1 / [UIScreen mainScreen].scale);
        make.top.equalTo(self.typeImage.mas_bottom);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.centerX.equalTo(self.typeImage.mas_centerX);
    }];
    
    [_typeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.typeImage.mas_centerY).with.offset(-5);
        make.left.equalTo(self.typeImage.mas_right).with.offset(10);
    }];
    
    [_photo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(19, 19));
        make.left.equalTo(self.typeImage.mas_right).with.offset(10);
        make.top.equalTo(self.typeImage.mas_centerY).with.offset(5);
    }];
    
    [_separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1 / [UIScreen mainScreen].scale);
        make.height.equalTo(self.photo.mas_height).with.offset(-4);
        make.centerY.equalTo(self.photo.mas_centerY);
        make.left.equalTo(self.photo.mas_right).with.offset(10);
    }];
    
    [_memoLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.photo.mas_centerY);
        make.left.equalTo(self.separator.mas_right).with.offset(10);
    }];
    
    [_moneyLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).with.offset(-10);
        make.left.greaterThanOrEqualTo(self.memoLab.mas_right).with.offset(10);
    }];
}

- (void)customUpdateConstraints {
    [_typeLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (!self.item.chargeMemo.length && !self.item.chargeImage.length) {
            make.centerY.equalTo(self.contentView.mas_centerY);
        } else {
            make.bottom.equalTo(self.contentView.mas_centerY).with.offset(-5);
        }
        make.left.equalTo(self.typeImage.mas_right).with.offset(10);
    }];
    
    [_memoLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (!self.item.chargeImage.length) {
            make.left.equalTo(self.typeImage.mas_right).with.offset(10);
        } else {
            make.left.equalTo(self.separator.mas_right).with.offset(10);
        }
        make.centerY.equalTo(self.photo.mas_centerY);
    }];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    _photo.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _topSeparator.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _bottomSeparator.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _separator.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _typeLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _memoLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _moneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _detailDateLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
