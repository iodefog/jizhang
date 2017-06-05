//
//  SSJBudgetEditTextFieldCell.m
//  SuiShouJi
//
//  Created by old lang on 16/2/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetEditTextFieldCell.h"

@interface SSJBudgetEditTextFieldCell ()

@property (nonatomic, strong) UITextField *textField;

@end

@implementation SSJBudgetEditTextFieldCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        self.detailTextLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        
        self.textField = [[UITextField alloc] init];
        self.textField.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.textField];
        
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.imageView sizeToFit];
    [self.textLabel sizeToFit];
    [self.detailTextLabel sizeToFit];
    
    if (self.detailTextLabel.text) {
        CGFloat verticalGap = (self.contentView.height - self.textLabel.height - self.detailTextLabel.height) * 0.33;
        
        self.imageView.left = 15;
        self.imageView.top = verticalGap;
        
        self.textLabel.left = self.imageView.right + 10;
        self.textLabel.top = verticalGap;
        
        self.detailTextLabel.left = self.imageView.right + 10;
        self.detailTextLabel.top = self.textLabel.bottom + verticalGap;
        self.detailTextLabel.width = MIN(self.detailTextLabel.width, self.contentView.width - self.detailTextLabel.left - 10);
        
        self.textField.frame = CGRectMake(self.contentView.width * 0.5 - 15, 0, self.contentView.width * 0.5, self.detailTextLabel.top);
        
    } else {
        self.imageView.left = 15;
        self.imageView.centerY = self.contentView.height * 0.5;
        
        self.textLabel.left = self.imageView.right + 10;
        self.textLabel.centerY = self.contentView.height * 0.5;
        
        self.textField.frame = CGRectMake(self.contentView.width * 0.5 - 15, 0, self.contentView.width * 0.5, self.contentView.height);
    }
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.imageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.detailTextLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.textField.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

@end
