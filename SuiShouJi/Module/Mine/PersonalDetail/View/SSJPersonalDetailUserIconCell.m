//
//  SSJPersonalDetailUserIconCell.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/4.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJPersonalDetailUserIconCell.h"

@implementation SSJPersonalDetailUserIconCellItem

+ (instancetype)itemWithIconUrl:(NSURL *)url {
    SSJPersonalDetailUserIconCellItem *item = [[SSJPersonalDetailUserIconCellItem alloc] init];
    item.userIconUrl = url;
    return item;
}

@end

@interface SSJPersonalDetailUserIconCell ()

@property (nonatomic, strong) UILabel *leftLab;

@property (nonatomic, strong) UIImageView *userIcon;

@end

@implementation SSJPersonalDetailUserIconCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.leftLab];
        [self.contentView addSubview:self.userIcon];
        [self setNeedsUpdateConstraints];
        [self updateAppearance];
        self.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
    }
    return self;
}

- (void)updateConstraints {
    [self.leftLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(self.contentView);
    }];
    [self.userIcon mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(66, 66));
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(self.contentView);
    }];
    [super updateConstraints];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.leftLab.textColor = SSJ_MAIN_COLOR;
}

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJPersonalDetailUserIconCellItem class]]) {
        return;
    }
    
    SSJPersonalDetailUserIconCellItem *item = cellItem;
    [[RACObserve(item, userIconUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSURL *url) {
        [self.userIcon sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"defualt_portrait"]];
    }];
}

- (UILabel *)leftLab {
    if (!_leftLab) {
        _leftLab = [[UILabel alloc] init];
        _leftLab.text = @"头像";
        _leftLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _leftLab;
}

- (UIImageView *)userIcon {
    if (!_userIcon) {
        _userIcon = [[UIImageView alloc] init];
        _userIcon.clipsToBounds = YES;
        _userIcon.layer.cornerRadius = 33;
        _userIcon.layer.borderWidth = 3;
        _userIcon.layer.borderColor = RGBCOLOR(245, 245, 245).CGColor;
    }
    return _userIcon;
}

@end
