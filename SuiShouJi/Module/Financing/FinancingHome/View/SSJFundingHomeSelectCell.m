


//
//  SSJFundingHomeSelectCell.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/29.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFundingHomeSelectCell.h"

@interface SSJFundingHomeSelectCell()

@property (nonatomic, strong) UILabel *titleLab;

@property(nonatomic, strong) UIButton *selectButton;


@end

@implementation SSJFundingHomeSelectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLab];
        [self.contentView addSubview:self.selectButton];
    }
    return self;
}

- (void)updateConstraints {
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(15);
    }];

    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self).offset(-15);
    }];

    [super updateConstraints];
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton setImage:[UIImage imageNamed:@"founds_checkmark"] forState:UIControlStateNormal];
    }
    return _selectButton;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _titleLab;
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    if (self.isSelected) {
        [self.selectButton setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]];
    } else {
        [self.selectButton setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]];
    }
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (_isSelected) {
        [self.selectButton setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]];
    } else {
        [self.selectButton setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]];
    }
}

- (void)setItem:(SSJFinancingHomeitem *)item {
    _item = item;
    self.titleLab.text = _item.fundingName;
    [self updateConstraintsIfNeeded];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
