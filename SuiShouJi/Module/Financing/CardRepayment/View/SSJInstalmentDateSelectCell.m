
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
        self.textLabel.font = [UIFont systemFontOfSize:18];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_subtitleLabel];
        
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:18];
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
    
    CGFloat top = (self.contentView.height - self.textLabel.height - self.subtitleLabel.height) * 0.33;
    
    self.imageView.leftTop = CGPointMake(16, top);
    self.textLabel.leftTop = CGPointMake(48, top);
    //    self.subtitleLabel.leftTop = CGPointMake(48, self.textLabel.bottom + top);
    self.subtitleLabel.frame = CGRectMake(48, self.textLabel.bottom + top, self.contentView.width - 60, 14);
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
