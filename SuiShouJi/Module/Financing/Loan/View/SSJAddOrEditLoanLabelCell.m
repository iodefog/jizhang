//
//  SSJAddOrEditLoanCell.m
//  SuiShouJi
//
//  Created by old lang on 16/8/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJAddOrEditLoanLabelCell.h"

@interface SSJAddOrEditLoanLabelCell ()

//@property (nonatomic, strong) UISwitch *switchControl;

@end

@implementation SSJAddOrEditLoanLabelCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.textLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        
        _additionalIcon = [[UIImageView alloc] init];
        [self.contentView addSubview:_additionalIcon];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [self.contentView addSubview:_subtitleLabel];
        
        _switchControl = [[UISwitch alloc] init];
        [self.contentView addSubview:_switchControl];
        
        _descLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_descLabel];
        _descLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.imageView sizeToFit];
    self.imageView.left = 16;
    self.imageView.centerY = self.contentView.height * 0.5;
    
    [self.textLabel sizeToFit];
    self.textLabel.left = 48;
    self.textLabel.centerY = self.contentView.height * 0.5;
    
    CGFloat rightGap = self.customAccessoryType == UITableViewCellAccessoryDisclosureIndicator ? 0 : 10;
    
    if (_switchControl.hidden) {
        [_subtitleLabel sizeToFit];
        _subtitleLabel.rightTop = CGPointMake(self.contentView.width - rightGap, (self.contentView.height - _subtitleLabel.height) * 0.5);
    } else {
        _switchControl.rightTop = CGPointMake(self.contentView.width - rightGap, (self.contentView.height - _switchControl.height) * 0.5);
        
        [_subtitleLabel sizeToFit];
        _subtitleLabel.rightTop = CGPointMake(_switchControl.left - 16, (self.contentView.height - _subtitleLabel.height) * 0.5);
    }
    
    [_additionalIcon sizeToFit];
    _additionalIcon.rightTop = CGPointMake(_subtitleLabel.left - 8, (self.contentView.height - _additionalIcon.height) * 0.5);
    
    if (_additionalIcon.left < self.textLabel.right + 10) {
        _additionalIcon.left = self.textLabel.right + 10;
    }
    
    _subtitleLabel.width = _subtitleLabel.right - _additionalIcon.right - 5;
    
    _subtitleLabel.left = _additionalIcon.right + 5;
    
    _descLabel.frame = CGRectMake(15, self.contentView.height - 25, self.width - 30, 25);
    
    if (_isProduct) {
        self.imageView.top = 15;
        self.textLabel.centerY = self.imageView.centerY;
        self.descLabel.top = CGRectGetMaxY(self.imageView.frame) + 10;
//        self.subtitleLabel.centerY = self.textLabel.centerY;
    }
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)setShowSwitch:(BOOL)showSwitch {
    _switchControl.hidden = !showSwitch;
}

- (void)updateAppearance {
    self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _subtitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.imageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _descLabel.textColor = SSJ_SECONDARY_COLOR;
}

@end
