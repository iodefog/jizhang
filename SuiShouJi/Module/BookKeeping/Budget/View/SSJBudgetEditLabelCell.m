//
//  SSJBudgetEditLabelCell.m
//  SuiShouJi
//
//  Created by old lang on 16/2/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetEditLabelCell.h"

//@interface SSJBudgetEditLabelCell ()
//
//@property (nonatomic, strong) UILabel *subtitleLab;
//
//@end

@implementation SSJBudgetEditLabelCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        
        self.textLabel.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
        self.detailTextLabel.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
        self.detailTextLabel.textAlignment = NSTextAlignmentRight;
        
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.imageView sizeToFit];
    self.imageView.left = 10;
    self.imageView.centerY = self.contentView.height * 0.5;
    
    self.textLabel.left = self.imageView.right + 10;
    self.textLabel.centerY = self.contentView.height * 0.5;
    
    if (self.customAccessoryType == UITableViewCellAccessoryNone) {
        self.detailTextLabel.frame = CGRectMake(self.textLabel.right + 20, 0, self.contentView.width - self.textLabel.right - 30, self.contentView.height);
    } else {
        self.detailTextLabel.frame = CGRectMake(self.textLabel.right + 20, 0, self.contentView.width - self.textLabel.right - 20, self.contentView.height);
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
}

@end
