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
        self.textLabel.font = [UIFont systemFontOfSize:18];
        self.detailTextLabel.font = [UIFont systemFontOfSize:11];
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
    self.imageView.left = 10;
    self.imageView.centerY = self.contentView.height * 0.5;
    
    self.textLabel.left = self.detailTextLabel.left = self.imageView.right + 10;
    self.textLabel.centerY = self.contentView.height * 0.5;
    
    self.detailTextLabel.width = MIN(self.detailTextLabel.width, self.contentView.width - 20);
    self.detailTextLabel.centerY = self.contentView.height - (self.contentView.height - self.textLabel.bottom) * 0.5;
    
    self.textField.frame = CGRectMake(self.contentView.width * 0.5 - 10, 0, self.contentView.width * 0.5, self.contentView.height);
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
