//
//  SSJAboutusTableViewCell.m
//  SuiShouJi
//
//  Created by ricky on 16/5/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJAboutusTableViewCell.h"

@interface SSJAboutusTableViewCell()
@property(nonatomic, strong) UILabel *cellTitleLabel;
@property(nonatomic, strong) UILabel *cellDetailLabel;
@property(nonatomic, strong) UILabel *cellSubtitleLabel;
@end

@implementation SSJAboutusTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.cellTitleLabel];
        [self.contentView addSubview:self.cellDetailLabel];
        [self.contentView addSubview:self.cellSubtitleLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.cellTitleLabel.centerY = self.height / 2;
    self.cellTitleLabel.left = 10;
    self.cellDetailLabel.centerY = self.height / 2 - 5;
    self.cellDetailLabel.right = self.contentView.width - 10;
    self.cellSubtitleLabel.centerY = self.cellDetailLabel.bottom + 5;
    self.cellSubtitleLabel.right = self.contentView.width - 10;
}

-(UILabel *)cellTitleLabel{
    if (!_cellTitleLabel) {
        _cellTitleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _cellTitleLabel.font = [UIFont systemFontOfSize:15];
        _cellTitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _cellTitleLabel;
}

-(UILabel *)cellDetailLabel{
    if (!_cellDetailLabel) {
        _cellDetailLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _cellDetailLabel.font = [UIFont systemFontOfSize:15];
        _cellDetailLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _cellDetailLabel;
}

-(UILabel *)cellSubtitleLabel{
    if (!_cellSubtitleLabel) {
        _cellSubtitleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _cellSubtitleLabel.font = [UIFont systemFontOfSize:14];
        _cellSubtitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _cellSubtitleLabel;
}

-(void)setCellTitle:(NSString *)cellTitle{
    _cellTitle = cellTitle;
    self.cellTitleLabel.text = _cellTitle;
    [self.cellTitleLabel sizeToFit];
}

-(void)setCellDetail:(NSString *)cellDetail{
    _cellDetail = cellDetail;
    self.cellDetailLabel.text = _cellDetail;
    [self.cellDetailLabel sizeToFit];
}

-(void)setCellSubTitle:(NSString *)cellSubTitle{
    _cellSubTitle = cellSubTitle;
    self.cellSubtitleLabel.text = _cellSubTitle;
    [self.cellSubtitleLabel sizeToFit];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
