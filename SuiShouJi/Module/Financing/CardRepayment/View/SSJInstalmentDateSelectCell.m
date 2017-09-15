
//
//  SSJInstalmentDateSelectCell.m
//  SuiShouJi
//
//  Created by ricky on 2016/12/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJInstalmentDateSelectCell.h"

@implementation SSJInstalmentDateSelectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
        [self.contentView addSubview:_subtitleLabel];
        
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _detailLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_detailLabel];
        
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.imageView sizeToFit];
    [self.textLabel sizeToFit];
    [self.detailLabel sizeToFit];
    
    
    self.imageView.leftBottom = CGPointMake(16, self.height / 2 - 5);
    self.textLabel.leftBottom = CGPointMake(48, self.height / 2 - 5);
    self.imageView.centerY = self.textLabel.centerY;
    //    self.subtitleLabel.leftTop = CGPointMake(48, self.textLabel.bottom + top);
    self.subtitleLabel.frame = CGRectMake(48, 0, self.contentView.width - 60, 14);
    self.subtitleLabel.top = self.height / 2 + 5;
    _detailLabel.frame = CGRectMake(self.textLabel.right + 10, 0, self.contentView.width - self.textLabel.right - 10 - 10, self.subtitleLabel.top);
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _subtitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _detailLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.imageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
