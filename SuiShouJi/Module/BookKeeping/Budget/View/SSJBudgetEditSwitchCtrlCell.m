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
        self.textLabel.font = [UIFont systemFontOfSize:18];
        self.detailTextLabel.font = [UIFont systemFontOfSize:11];
        self.switchCtrl = [[UISwitch alloc] init];
        self.accessoryView = self.switchCtrl;
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(10, (self.contentView.height - 22) * 0.5, 22, 22);
    
    self.textLabel.left = self.detailTextLabel.left = self.imageView.right + 10;
    self.textLabel.centerY = self.contentView.height * 0.5;
    self.detailTextLabel.centerY = self.contentView.height - (self.contentView.height - self.textLabel.bottom) * 0.5;
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
