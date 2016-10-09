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
        
        self.textLabel.font = [UIFont systemFontOfSize:18];
        self.detailTextLabel.font = [UIFont systemFontOfSize:18];
        
//        self.subtitleLab = [[UILabel alloc] init];
//        self.subtitleLab.backgroundColor = [UIColor clearColor];
//        self.detailTextLabel.font = [UIFont systemFontOfSize:18];
//        self.subtitleLab.textAlignment = NSTextAlignmentRight;
//        [self.contentView addSubview:self.subtitleLab];
        
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(10, (self.contentView.height - 22) * 0.5, 22, 22);
    
    self.textLabel.left = self.imageView.right + 10;
    self.textLabel.centerY = self.contentView.height * 0.5;
//    self.detailTextLabel.centerY = self.contentView.height - (self.contentView.height - self.textLabel.bottom) * 0.5;
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
    self.detailTextLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
//    self.subtitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
}

@end
