//
//  SSJBookkeepingRiminderCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookkeepingRiminderCell.h"

@interface SSJBookkeepingRiminderCell()
@property (nonatomic,strong) UIImageView *checkMark;
@property (nonatomic,strong) UILabel *cellTitleLabel;

@end
@implementation SSJBookkeepingRiminderCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.checkMark];
        [self.contentView addSubview:self.cellTitleLabel];
        [self addSubview:self.checkMark];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.cellTitleLabel.left = 10;
    self.cellTitleLabel.centerY = self.centerY;
    self.checkMark.centerY = self.centerY;
    self.checkMark.right = self.width - 10;
}

-(UILabel *)cellTitleLabel{
    if (!_cellTitleLabel) {
        _cellTitleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _cellTitleLabel.font = [UIFont systemFontOfSize:15];
        _cellTitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _cellTitleLabel;
}

-(UIImageView *)checkMark{
    if (!_checkMark) {
        _checkMark = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 17, 17)];
        _checkMark.image = [[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _checkMark.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        _checkMark.hidden = YES;
    }
    return _checkMark;
}

-(void)setSelectedOrNot:(BOOL)selectedOrNot{
    _selectedOrNot = selectedOrNot;
    if (_selectedOrNot) {
        self.checkMark.hidden = NO;
    }else{
        self.checkMark.hidden = YES;
    }
}

-(void)setCellTitle:(NSString *)cellTitle{
    _cellTitle = cellTitle;
    self.cellTitleLabel.text = _cellTitle;
    [self.cellTitleLabel sizeToFit];
}

-(void)updateCellAppearanceAfterThemeChanged{
    [super updateCellAppearanceAfterThemeChanged];
    self.backgroundColor = [UIColor clearColor];
    self.cellTitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.checkMark.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
