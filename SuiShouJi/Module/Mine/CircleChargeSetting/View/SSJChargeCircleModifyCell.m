//
//  SSJChargeCircleModifyCell.m
//  SuiShouJi
//
//  Created by ricky on 16/6/2.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJChargeCircleModifyCell.h"

@interface SSJChargeCircleModifyCell()
@property(nonatomic, strong) UILabel *cellDetailLabel;
@property(nonatomic, strong) UIImageView *cellImageView;
@end

@implementation SSJChargeCircleModifyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.cellTitleLabel];
        [self.contentView addSubview:self.cellDetailLabel];
        [self.contentView addSubview:self.cellSubTitleLabel];
        [self.contentView addSubview:self.cellImageView];
        [self.contentView addSubview:self.cellInput];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.cellTitleLabel.left = 10;
    self.cellTitleLabel.centerY = self.height / 2;
    self.cellSubTitleLabel.left = 10;
    self.cellSubTitleLabel.centerY = self.height / 2;
    if (self.contentView.width == self.width) {
        self.cellDetailLabel.right = self.contentView.width - 10;
    }else{
        self.cellDetailLabel.right = self.contentView.width;
    }
    self.cellDetailLabel.centerY = self.height / 2;
    self.cellImageView.right = self.width - 10;
    self.cellImageView.centerY = self.height / 2;
    self.cellInput.size = CGSizeMake(self.width / 2, self.height);
    self.cellInput.right = self.width - 10;
    self.cellInput.centerY = self.height / 2;
}

-(UILabel *)cellTitleLabel{
    if (!_cellTitleLabel) {
        _cellTitleLabel = [[UILabel alloc]init];
        _cellTitleLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _cellTitleLabel.font = [UIFont systemFontOfSize:18];
    }
    return _cellTitleLabel;
}

-(UILabel *)cellDetailLabel{
    if (!_cellDetailLabel) {
        _cellDetailLabel = [[UILabel alloc]init];
        _cellDetailLabel.textColor = [UIColor ssj_colorWithHex:@"929292"];
        _cellDetailLabel.font = [UIFont systemFontOfSize:18];
    }
    return _cellDetailLabel;
}

-(UILabel *)cellSubTitleLabel{
    if (!_cellSubTitleLabel) {
        _cellSubTitleLabel = [[UILabel alloc]init];
        _cellSubTitleLabel.textColor = [UIColor ssj_colorWithHex:@"929292"];
        _cellSubTitleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _cellSubTitleLabel;
}

-(UIImageView *)cellImageView{
    if (!_cellImageView) {
        _cellImageView = [[UIImageView alloc]init];
    }
    return _cellImageView;
}

-(UITextField *)cellInput{
    if (!_cellInput) {
        _cellInput = [[UITextField alloc]init];
        _cellInput.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _cellInput.textAlignment = NSTextAlignmentRight;
        _cellInput.font = [UIFont systemFontOfSize:18];
        _cellInput.hidden = YES;
    }
    return _cellInput;
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
    self.cellSubTitleLabel.text = _cellSubTitle;
    [self.cellSubTitleLabel sizeToFit];
}

-(void)setCellImage:(NSString *)cellImage{
    _cellImage = cellImage;
    self.cellImageView.image = [UIImage imageNamed:_cellImage];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
