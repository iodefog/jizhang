//
//  SSJLoanDetailCell.m
//  SuiShouJi
//
//  Created by old lang on 16/8/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanDetailCell.h"

@interface SSJLoanDetailCell ()

@property (nonatomic, strong) UILabel *rightLabel;

@end

@implementation SSJLoanDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.textLabel.font = [UIFont systemFontOfSize:18];
        
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.font = [UIFont systemFontOfSize:18];
        _rightLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_rightLabel];
        
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.imageView sizeToFit];
    self.imageView.left = 12;
    self.imageView.centerY = self.contentView.height * 0.5;
    
    [self.textLabel sizeToFit];
    self.textLabel.left = self.imageView.right + 12;
    self.textLabel.centerY = self.contentView.height * 0.5;
    
    _rightLabel.frame = CGRectMake(self.textLabel.right + 15, 0, self.contentView.width - self.textLabel.right - 30, self.contentView.height);
}

- (void)setCellItem:(SSJBaseItem *)cellItem {
    [super setCellItem:cellItem];
    
    SSJLoanDetailCellItem *item = (SSJLoanDetailCellItem *)cellItem;
    
    self.imageView.image = [[UIImage imageNamed:item.image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.textLabel.text = item.title;
    self.rightLabel.text = item.subtitle;
    [self updateAppearance];
    
    [self setNeedsLayout];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _rightLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.imageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

@end
