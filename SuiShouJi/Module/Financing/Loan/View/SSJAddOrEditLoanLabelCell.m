//
//  SSJAddOrEditLoanCell.m
//  SuiShouJi
//
//  Created by old lang on 16/8/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJAddOrEditLoanLabelCell.h"

@implementation SSJAddOrEditLoanLabelCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.textLabel.font = [UIFont systemFontOfSize:18];
        self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        
        _additionalIcon = [[UIImageView alloc] init];
        [self.contentView addSubview:_additionalIcon];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont systemFontOfSize:18];
        _subtitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        [self.contentView addSubview:_subtitleLabel];
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
    
    [_subtitleLabel sizeToFit];
    _subtitleLabel.rightTop = CGPointMake(self.contentView.width - 28, (self.contentView.height - _subtitleLabel.height) * 0.5);
    
    [_additionalIcon sizeToFit];
    _additionalIcon.rightTop = CGPointMake(_subtitleLabel.left - 8, (self.contentView.height - _additionalIcon.height) * 0.5);
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _subtitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

@end
