//
//  SSJMineHomeImageCell.m
//  SuiShouJi
//
//  Created by ricky on 16/5/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMineHomeImageCell.h"
@interface SSJMineHomeImageCell()
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *detailLabel;
@property (nonatomic,strong) UILabel *subTitleLabel;
@property(nonatomic, strong) UIImageView *cellImageView;
@end

@implementation SSJMineHomeImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.cellImageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detailLabel];
        [self.contentView addSubview:self.subTitleLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.cellImageView.size = CGSizeMake(40, 40);
    self.cellImageView.left = 10;
    self.cellImageView.centerY = self.height / 2;
    self.titleLabel.left = self.cellImageView.right + 10;
    self.subTitleLabel.left = self.titleLabel.left;
    if (self.cellSubTitle.length) {
        self.subTitleLabel.top = self.height / 2 + 2;
        self.titleLabel.bottom = self.height / 2 - 2;
    }else{
        self.titleLabel.centerY = self.height / 2;
    }
    self.detailLabel.width = 200;
    self.detailLabel.centerY = self.height / 2;
    if (self.contentView.width == self.width) {
        self.detailLabel.right = self.width - 20;
    }else{
        self.detailLabel.right = self.contentView.width;
    }
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
    }
    return _titleLabel;
}

-(UILabel *)detailLabel{
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc]init];
        _detailLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.font = [UIFont systemFontOfSize:15];
    }
    return _detailLabel;
}

-(UILabel *)subTitleLabel{
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc]init];
        _subTitleLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        _subTitleLabel.textAlignment = NSTextAlignmentRight;
        _subTitleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _subTitleLabel;
}

-(UIImageView *)cellImageView{
    if (!_cellImageView) {
        _cellImageView = [[UIImageView alloc]init];
    }
    return _cellImageView;
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
    self.subTitleLabel.text = cellSubTitle;
    [self.subTitleLabel sizeToFit];
}

-(void)setCellImage:(UIImage *)cellImage{
    _cellImage = cellImage;
    self.cellImageView.image = _cellImage;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
