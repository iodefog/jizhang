//
//  SSJAddOrEditLoanMultiLabelCell.m
//  SuiShouJi
//
//  Created by old lang on 16/8/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJAddOrEditLoanMultiLabelCell.h"

@implementation SSJAddOrEditLoanMultiLabelCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.textLabel.font = [UIFont systemFontOfSize:18];
        self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont systemFontOfSize:18];
        _subtitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        [self.contentView addSubview:_subtitleLabel];
        
        _textField = [[UITextField alloc] init];
        _textField.font = [UIFont systemFontOfSize:18];
        _textField.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_textField];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat top = (self.contentView.height - self.textLabel.height - self.subtitleLabel.height) * 0.33;
    
    [self.imageView sizeToFit];
    self.imageView.leftTop = CGPointMake(16, top);
    
    [self.textLabel sizeToFit];
    self.textLabel.leftTop = CGPointMake(48, top);
    
    [self.subtitleLabel sizeToFit];
    self.subtitleLabel.leftTop = CGPointMake(48, self.textLabel.bottom + top);
    
    _textField.frame = CGRectMake(self.textLabel.right + 10, (self.contentView.height - 48) * 0.5, self.contentView.width - self.textLabel.right - 38, 48);
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _subtitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _textField.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
}

@end
