//
//  SSJAddOrEditLoanMultiLabelCell.m
//  SuiShouJi
//
//  Created by old lang on 16/8/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJAddOrEditLoanMultiLabelCell.h"

@interface SSJAddOrEditLoanMultiLabelCell ()

@property (nonatomic, strong) UILabel *percentLab;

@end

@implementation SSJAddOrEditLoanMultiLabelCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
        [self.contentView addSubview:_subtitleLabel];
        
        _textField = [[UITextField alloc] init];
        _textField.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _textField.textAlignment = NSTextAlignmentRight;
        _textField.clearsOnBeginEditing = YES;
        [self.contentView addSubview:_textField];
        
        _percentLab = [[UILabel alloc] init];
        _percentLab.text = @"%";
        [_percentLab sizeToFit];
        
        _textField.rightView = _percentLab;
        _textField.rightViewMode = UITextFieldViewModeAlways;
        
        [self updateAppearance];
    }
    return self;
}


- (void)setHaspercentLab:(BOOL)haspercentLab
{
    _haspercentLab = haspercentLab;
    if (haspercentLab == NO) {
        _percentLab.text = @"";
        [_percentLab sizeToFit];
    }
    self.subtitleLabel.right = self.width - 10;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.imageView sizeToFit];
    [self.textLabel sizeToFit];
    
    if (self.subtitleLabel.height == 0) {
        self.subtitleLabel.height = 14;
    }
    
    CGFloat gap = (self.contentView.height - self.textLabel.height - self.subtitleLabel.height) * 0.33;
    
    self.imageView.leftTop = CGPointMake(16, gap);
    self.textLabel.leftTop = CGPointMake(48, gap);
//    self.subtitleLabel.leftTop = CGPointMake(48, self.textLabel.bottom + top);
    self.subtitleLabel.frame = CGRectMake(48, self.textLabel.bottom + gap, self.contentView.width - 60, self.subtitleLabel.height);
    _textField.frame = CGRectMake(self.textLabel.right + 10, 0, self.contentView.width - self.textLabel.right - 10 - 10, self.subtitleLabel.top);
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _subtitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _textField.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _percentLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.imageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

@end
