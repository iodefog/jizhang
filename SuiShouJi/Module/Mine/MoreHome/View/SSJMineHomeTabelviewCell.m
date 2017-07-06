//
//  SSJMineHomeTabelviewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJMineHomeTabelviewCell.h"

@interface SSJMineHomeTabelviewCell()

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) UILabel *detailLabel;

@end

@implementation SSJMineHomeTabelviewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detailLabel];
        [self updateAppearance];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.titleLabel sizeToFit];
    self.titleLabel.left = 10;
    self.titleLabel.centerY = self.height / 2;
    
    [self.detailLabel sizeToFit];
    if (self.detailTitlefilled) {
        self.detailLabel.width += 16;
        self.detailLabel.height += 4;
    }
    self.detailLabel.centerY = self.height / 2;
    if (self.contentView.width == self.width) {
        self.detailLabel.right = self.width - 20;
    } else {
        self.detailLabel.right = self.contentView.width;
    }
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.clipsToBounds = YES;
        _detailLabel.layer.cornerRadius = 2;
    }
    return _detailLabel;
}

- (void)setCellTitle:(NSString *)cellTitle {
    _cellTitle = cellTitle;
    _titleLabel.text = _cellTitle;
}

- (void)setCellDetail:(NSString *)cellDetail {
    _cellDetail = cellDetail;
    self.detailLabel.text = _cellDetail;
}

- (void)setDetailTitlefilled:(BOOL)detailTitlefilled {
    if (_detailTitlefilled != detailTitlefilled) {
        _detailTitlefilled = detailTitlefilled;
        [self updateAppearance];
    }
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    if (_detailTitlefilled) {
        self.detailLabel.textColor = [UIColor whiteColor];
        self.detailLabel.backgroundColor = SSJ_MARCATO_COLOR;
        self.detailLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    } else {
        self.detailLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        self.detailLabel.backgroundColor = [UIColor clearColor];
        _detailLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
}

@end
