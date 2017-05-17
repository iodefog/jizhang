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

@property (nonatomic, strong) UILabel *bottomLabel;

@end

@implementation SSJLoanDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _rightLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_rightLabel];
        
        _bottomLabel = [[UILabel alloc] init];
        _bottomLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [self.contentView addSubview:_bottomLabel];
        
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
    
    [_bottomLabel sizeToFit];
    _bottomLabel.left = self.imageView.right + 12;
    _bottomLabel.top = (self.contentView.height - self.textLabel.bottom - _bottomLabel.height) * 0.5 + self.textLabel.bottom;
    
    _rightLabel.frame = CGRectMake(self.textLabel.right + 15, 0, self.contentView.width - self.textLabel.right - 30, self.contentView.height);
}

- (void)setCellItem:(SSJBaseCellItem *)cellItem {
    [super setCellItem:cellItem];
    
    SSJLoanDetailCellItem *item = (SSJLoanDetailCellItem *)cellItem;
    
    self.imageView.image = [[UIImage imageNamed:item.image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.textLabel.text = item.title;
    _bottomLabel.attributedText = item.bottomTitle;
    _rightLabel.text = item.subtitle;
    
    [self setNeedsLayout];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _bottomLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _rightLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.imageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

@end
