//
//  SSJCalendarTableViewCell.m
//  SuiShouJi
//
//  Created by ricky on 2017/2/9.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCalendarTableViewCell.h"
#import "Masonry.h"

static CGFloat kGap = 10;

@interface SSJCalendarTableViewCell()

@property(nonatomic, strong) UIImageView *typeImage;

@property(nonatomic, strong) UIImageView *photo;

@property(nonatomic, strong) UIView *topSeparator;

@property(nonatomic, strong) UIView *bottomSeparator;

@property(nonatomic, strong) UIView *separator1;

@property(nonatomic, strong) UIView *separator2;

@property(nonatomic, strong) UILabel *memberLab;

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
        [self.contentView addSubview:self.separator1];
        [self.contentView addSubview:self.separator2];
        [self.contentView addSubview:self.memberLab];
        [self.contentView addSubview:self.memoLab];
        [self.contentView addSubview:self.moneyLab];
        [self.contentView addSubview:self.detailDateLab];
        [self.contentView addSubview:self.typeLab];
        [self setNeedsUpdateConstraints];
    }
    return self;
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
    
    self.memberLab.text = item.memberNickname;
    self.photo.hidden = !item.chargeImage.length;
    self.memoLab.text = item.chargeMemo;
    
    [self updateSeparatorsHidden];
    
    if (!item.incomeOrExpence) {
        self.moneyLab.text = [NSString stringWithFormat:@"+%@",[item.money ssj_moneyDecimalDisplayWithDigits:2]];
    } else {
        self.moneyLab.text = [NSString stringWithFormat:@"-%@",[item.money ssj_moneyDecimalDisplayWithDigits:2]];
    }
    [self setNeedsUpdateConstraints];
}

- (void)setIsLastRow:(BOOL)isLastRow {
    self.bottomSeparator.hidden = isLastRow;
}

- (void)setIsFirstRow:(BOOL)isFirstRow {
    self.topSeparator.hidden = isFirstRow;
}

- (void)updateConstraints {
    [_detailDateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView).with.offset(10);
    }];
    
    [_typeImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.left.mas_equalTo(70);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [_typeLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.item.chargeMemo.length
            || self.item.chargeImage.length
            || self.item.memberNickname.length) {
            make.bottom.equalTo(self.contentView.mas_centerY).with.offset(-5);
        } else {
            make.centerY.equalTo(self.contentView.mas_centerY);
        }
        make.left.equalTo(self.typeImage.mas_right).with.offset(10);
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
    
    if (!_separator1.hidden && !_separator2.hidden) {
        [_separator1 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(1 / [UIScreen mainScreen].scale);
            make.height.mas_equalTo(15);
            make.left.equalTo(_memberLab.mas_right).with.offset(kGap);
            make.centerY.mas_equalTo(self.contentView.mas_bottom).multipliedBy(0.73);
        }];
        
        [_separator2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(1 / [UIScreen mainScreen].scale);
            make.height.mas_equalTo(15);
            make.left.equalTo(_photo.mas_right).with.offset(kGap);
            make.centerY.mas_equalTo(self.contentView.mas_bottom).multipliedBy(0.73);
        }];
    } else if (!_separator1.hidden) {
        [_separator1 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(1 / [UIScreen mainScreen].scale);
            make.height.mas_equalTo(15);
            make.left.equalTo(_item.memberNickname.length ? _memberLab.mas_right : _photo.mas_right).offset(kGap);
            make.centerY.mas_equalTo(self.contentView.mas_bottom).multipliedBy(0.73);
        }];
    }
    
    CGFloat gap = kGap;
    MASViewAttribute *left = _typeImage.mas_right;
    
    if (self.item.memberNickname.length) {
        [_memberLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo([_memberLab.text sizeWithAttributes:@{NSFontAttributeName:_memberLab.font}]);
            make.left.mas_equalTo(left).offset(gap * 0.5);
            make.right.mas_lessThanOrEqualTo(_moneyLab.mas_left).offset(-10);
            make.centerY.mas_equalTo(self.contentView.mas_bottom).multipliedBy(0.73);
        }];
        gap = 2 *kGap;
        left = _memberLab.mas_right;
    }
    
    if (self.item.chargeImage.length) {
        [_photo mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(19, 19));
            make.left.mas_equalTo(left).offset(gap);
            make.right.mas_lessThanOrEqualTo(_moneyLab.mas_left).offset(-10);
            make.centerY.mas_equalTo(self.contentView.mas_bottom).multipliedBy(0.73);
        }];
        gap = 2 *kGap;
        left = _photo.mas_right;
    }
    
    if (self.item.chargeMemo.length) {
        [_memoLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(left).offset(gap);
            make.right.mas_lessThanOrEqualTo(_moneyLab.mas_left).offset(-10);
            make.centerY.mas_equalTo(self.contentView.mas_bottom).multipliedBy(0.73);
        }];
    }
    
    [_moneyLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).with.offset(-10);
    }];
    [super updateConstraints];
}

- (void)updateSeparatorsHidden {
    int count = 0;
    if (_item.memberNickname.length) {
        count ++;
    }
    if (_item.chargeImage.length) {
        count ++;
    }
    if (_item.chargeMemo.length) {
        count ++;
    }
    
    if (count == 3) {
        self.separator1.hidden = NO;
        self.separator2.hidden = NO;
    } else if (count == 2) {
        self.separator1.hidden = NO;
        self.separator2.hidden = YES;
    } else {
        self.separator1.hidden = YES;
        self.separator2.hidden = YES;
    }
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    _photo.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _topSeparator.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _bottomSeparator.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _separator1.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _separator2.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _typeLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _memoLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _moneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _detailDateLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

#pragma mark - Lazyloading
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

- (UIView *)separator1 {
    if (!_separator1) {
        _separator1 = [[UIView alloc] init];
        _separator1.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _separator1;
}

- (UIView *)separator2 {
    if (!_separator2) {
        _separator2 = [[UIView alloc] init];
        _separator2.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _separator2;
}

- (UILabel *)typeLab {
    if (!_typeLab) {
        _typeLab = [[UILabel alloc] init];
        _typeLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _typeLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _typeLab;
}

- (UILabel *)memberLab {
    if (!_memberLab) {
        _memberLab = [[UILabel alloc] init];
        _memberLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _memberLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _memberLab;
}

- (UILabel *)memoLab {
    if (!_memoLab) {
        _memoLab = [[UILabel alloc] init];
        _memoLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _memoLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _memoLab;
}

- (UILabel *)moneyLab {
    if (!_moneyLab) {
        _moneyLab = [[UILabel alloc] init];
        _moneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _moneyLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
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

@end
