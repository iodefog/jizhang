//
//  SSJFundingTransferEdite.m
//  SuiShouJi
//
//  Created by ricky on 16/6/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingTransferEdite.h"

@interface SSJFundingTransferEdite()
@property(nonatomic, strong) UILabel *cellTitleLabel;
@property(nonatomic, strong) UILabel *cellDetailLabel;
@property(nonatomic, strong) UIImageView *cellDetailImage;
@end

@implementation SSJFundingTransferEdite
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.cellTitleLabel];
        [self.contentView addSubview:self.cellDetailLabel];
        [self.contentView addSubview:self.cellDetailImage];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.cellTitleLabel.centerY = self.cellDetailLabel.centerY = self.contentView.height / 2;
    self.cellTitleLabel.left = 10;
    self.cellDetailLabel.right = self.contentView.width - 10;
    self.cellDetailImage.centerY = self.height / 2;
    self.cellDetailImage.right = self.cellDetailLabel.left - 10;
}

-(UILabel *)cellTitleLabel{
    if (!_cellTitleLabel) {
        _cellTitleLabel = [[UILabel alloc]init];
        _cellTitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _cellTitleLabel.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
    }
    return _cellTitleLabel;
}

-(UILabel *)cellDetailLabel{
    if (!_cellDetailLabel) {
        _cellDetailLabel = [[UILabel alloc]init];
        _cellDetailLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _cellDetailLabel.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
    }
    return _cellDetailLabel;
}

-(UIImageView *)cellDetailImage{
    if (!_cellDetailImage) {
        _cellDetailImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    }
    return _cellDetailImage;
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

- (void)setCellImage:(NSString *)cellImage{
    _cellImage = cellImage;
    self.cellDetailImage.image = [UIImage imageNamed:_cellImage];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
