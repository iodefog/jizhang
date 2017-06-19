//
//  SSJBudgetSwitchCtrlCell.m
//  SuiShouJi
//
//  Created by old lang on 16/2/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetEditSwitchCtrlCell.h"

@interface SSJBudgetEditSwitchCtrlCell ()

@property (nonatomic, strong) UISwitch *switchCtrl;

@end

@implementation SSJBudgetEditSwitchCtrlCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        self.detailTextLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        
        self.switchCtrl = [[UISwitch alloc] init];
        [self.contentView addSubview:self.switchCtrl];
        
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
        
        self.switchCtrl.right = self.contentView.width - 15;
        self.switchCtrl.centerY = self.textLabel.centerY;
        
    } else {
        self.imageView.left = 15;
        self.imageView.centerY = self.contentView.height * 0.5;
        
        self.textLabel.left = self.detailTextLabel.left = self.imageView.right + 10;
        self.textLabel.centerY = self.contentView.height * 0.5;
        
        self.switchCtrl.right = self.contentView.width - 15;
        self.switchCtrl.centerY = self.contentView.height * 0.5;
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
