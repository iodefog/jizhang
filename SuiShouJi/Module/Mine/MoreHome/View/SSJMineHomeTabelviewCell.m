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
@end

@implementation SSJMineHomeTabelviewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detailLabel];
        [self.contentView addSubview:self.portraitImage];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.left = 10;
    self.titleLabel.centerY = self.height / 2;
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
    }
    return _titleLabel;
}

-(UILabel *)detailLabel{
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc]init];
        _detailLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.font = [UIFont systemFontOfSize:15];
    }
    return _detailLabel;
}

-(UIImageView *)portraitImage{
    if (!_portraitImage) {
        _portraitImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
        _portraitImage.layer.cornerRadius = 30.f;
        _portraitImage.layer.masksToBounds = YES;
    }
    return _portraitImage;
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
