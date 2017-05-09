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
@property(nonatomic, strong) UILabel *subTitleLabel;
@end

@implementation SSJMineHomeTabelviewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.subTitleLabel];
        [self.contentView addSubview:self.detailLabel];
        [self.contentView addSubview:self.portraitImage];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.left = 10;
    self.titleLabel.centerY = self.height / 2;
    self.subTitleLabel.left = 10;
    self.subTitleLabel.centerY = self.height / 2;
    self.detailLabel.width = 200;
    self.detailLabel.centerY = self.height / 2;
    if (self.contentView.width == self.width) {
        self.detailLabel.right = self.width - 20;
    }else{
        self.detailLabel.right = self.contentView.width;
    }
    self.portraitImage.right = self.detailLabel.right;
    self.portraitImage.centerY = self.height / 2;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _titleLabel;
}

-(UILabel *)detailLabel{
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc]init];
        _detailLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _detailLabel;
}

-(UIImageView *)portraitImage{
    if (!_portraitImage) {
        CGRect rect = CGRectMake(0, 0, 60, 60);
        _portraitImage = [[UIImageView alloc]initWithFrame:rect];
        CAShapeLayer *portLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:rect.size.width * 0.5];
        portLayer.path = path.CGPath;
        _portraitImage.layer.mask = portLayer;
    }
    return _portraitImage;
}

-(UILabel *)subTitleLabel{
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc]init];
        _subTitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _subTitleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _subTitleLabel;
}

-(void)setCellTitle:(NSString *)cellTitle{
    _cellTitle = cellTitle;
    _titleLabel.text = _cellTitle;
    [_titleLabel sizeToFit];
}

-(void)setCellDetail:(NSString *)cellDetail{
    _cellDetail = cellDetail;
    self.detailLabel.text = _cellDetail;
    [self.detailLabel sizeToFit];
}

-(void)setCellSubTitle:(NSString *)cellSubTitle{
    _cellSubTitle = cellSubTitle;
    self.subTitleLabel.text = _cellSubTitle;
    [self.subTitleLabel sizeToFit];
}

- (void)updateCellAppearanceAfterThemeChanged{
    [super updateCellAppearanceAfterThemeChanged];
    self.titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.detailLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.subTitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}


@end
