//
//  SSJJiXiMethodTableViewCell.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJJiXiMethodTableViewCell.h"

@interface SSJJiXiMethodTableViewCell ()
@property (nonatomic, strong) UIImageView *indicatorView;
/**<#注释#>*/


@end

@implementation SSJJiXiMethodTableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *cellId = @"SSJJiXiMethodTableViewCellId";
    SSJJiXiMethodTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SSJJiXiMethodTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
        cell.customAccessoryType = UITableViewCellAccessoryNone;
        
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.additionalIcon];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.subtitleLabel];
        [self.contentView addSubview:self.indicatorView];
        [self.contentView addSubview:self.detailL];
        
        [self setNeedsUpdateConstraints];
        [self updateCellAppearanceAfterThemeChanged];
    }
    return self;
}

- (void)updateConstraints {
    [self.additionalIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(16);
        make.size.mas_equalTo(CGSizeMake(21, 21));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.additionalIcon.mas_right).offset(10);
        make.centerY.mas_equalTo(self.additionalIcon);
        make.width.greaterThanOrEqualTo(0);
    }];
    
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.additionalIcon.mas_bottom).offset(5);
        make.left.mas_equalTo(self.nameLabel);
        make.width.greaterThanOrEqualTo(0);
    }];
    
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(self.additionalIcon);
    }];
    
    [self.detailL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.indicatorView.mas_left);
        make.left.mas_equalTo(self.nameLabel.mas_right);
        make.centerY.mas_equalTo(self.nameLabel);
    }];
    
    [super updateConstraints];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    self.indicatorView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor];
    self.nameLabel.textColor = SSJ_MAIN_COLOR;
    self.detailL.textColor = SSJ_SECONDARY_COLOR;
    self.subtitleLabel.textColor = SSJ_SECONDARY_COLOR;
    self.additionalIcon.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

- (UIImageView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cellIndicator"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [_indicatorView sizeToFit];
    }
    return _indicatorView;
}

- (UIImageView *)additionalIcon {
    if (!_additionalIcon) {
        _additionalIcon = [[UIImageView alloc] init];
    }
    return _additionalIcon;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _subtitleLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _nameLabel;
}


- (UILabel *)detailL {
    if (!_detailL) {
        _detailL = [[UILabel alloc] init];
        _detailL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _detailL;
}
@end
