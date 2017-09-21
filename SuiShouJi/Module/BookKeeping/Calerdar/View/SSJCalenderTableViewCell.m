//
//  SSJCalenderTableViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCalenderTableViewCell.h"
#import "SSJBillingChargeCellItem.h"

const CGFloat kImageDiam = 26;

@implementation SSJCalenderTableViewCellItem

@end

@interface SSJCalenderTableViewCell ()

@property (nonatomic, strong) UIView *borderView;

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *leftLab;

@property (nonatomic, strong) UILabel *moneyLab;

@end

@implementation SSJCalenderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.borderView];
        [self.contentView addSubview:self.icon];
        [self.contentView addSubview:self.leftLab];
        [self.contentView addSubview:self.moneyLab];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self updateAppearance];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints {
    [self.borderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.centerY.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(kImageDiam, kImageDiam));
    }];
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.borderView);
        make.size.mas_equalTo(CGSizeMake(kImageDiam * 0.75, kImageDiam * 0.75));
    }];
    [self.leftLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(16);
        make.bottom.mas_equalTo(-16);
        make.left.mas_equalTo(self.borderView.mas_right).offset(10);
        make.width.mas_equalTo([self.leftLab ssj_textSize].width);
    }];
    [self.moneyLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftLab.mas_right).offset(10);
        make.right.mas_equalTo(-10);
        make.centerY.mas_equalTo(self.contentView);
    }];
    [super updateConstraints];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    _leftLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _moneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
}

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJCalenderTableViewCellItem class]]) {
        return;
    }
    
    SSJCalenderTableViewCellItem *item = cellItem;
    
    self.icon.image = item.billImage;
    self.icon.tintColor = item.billColor;
    
    self.borderView.layer.borderColor = item.billColor.CGColor;
    
    self.leftLab.text = item.billName;
    
    self.moneyLab.text = [NSString stringWithFormat:@"%.2f", [item.money doubleValue]];
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
    }
    return _icon;
}

- (UIView *)borderView {
    if (!_borderView) {
        _borderView = [[UIView alloc] init];
        _borderView.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
        _borderView.layer.cornerRadius = kImageDiam * 0.5;
    }
    return _borderView;
}

- (UILabel *)leftLab {
    if (!_leftLab) {
        _leftLab = [[UILabel alloc] init];
        _leftLab.backgroundColor = [UIColor clearColor];
        _leftLab.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _leftLab;
}

- (UILabel *)moneyLab {
    if (!_moneyLab) {
        _moneyLab = [[UILabel alloc] init];
        _moneyLab.backgroundColor = [UIColor clearColor];
        _moneyLab.textAlignment = NSTextAlignmentRight;
        _moneyLab.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_1];
    }
    return _moneyLab;
}

@end
