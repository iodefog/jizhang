//
//  SSJChargeCircleModifyCell.m
//  SuiShouJi
//
//  Created by ricky on 16/6/2.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJChargeCircleModifyCell.h"

@interface SSJChargeCircleModifyCell()

@property(nonatomic, strong) UIImageView *cellImage;

@property(nonatomic, strong) UIImageView *typeImageView;

@end

@implementation SSJChargeCircleModifyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.cellTitleLabel];
        [self.contentView addSubview:self.cellDetailLabel];
        [self.contentView addSubview:self.cellSubTitleLabel];
        [self.contentView addSubview:self.cellImageView];
        [self.contentView addSubview:self.cellInput];
        [self.contentView addSubview:self.cellImage];
        [self.contentView addSubview:self.typeImageView];

    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.cellImage.left = 16;
    self.cellImage.centerY = self.height / 2;
    self.cellTitleLabel.left = self.cellImage.right + 10;
    self.cellTitleLabel.centerY = self.height / 2;
    self.cellSubTitleLabel.left = 16;
    self.cellSubTitleLabel.centerY = self.height / 2;
    
    if (self.contentView.width == self.width) {
        CGFloat maxDetailLabelWith = self.contentView.width - 10 - self.cellTitleLabel.right - 10;
        if (self.typeImageView.image && !self.typeImageView.hidden) {
            maxDetailLabelWith = maxDetailLabelWith - self.typeImageView.width - 10;
        }
        self.cellDetailLabel.width = MIN(self.cellDetailLabel.width, maxDetailLabelWith);
        self.cellDetailLabel.right = self.contentView.width - 10;
    }else{
        CGFloat maxDetailLabelWith = self.contentView.width - self.cellTitleLabel.right - 10;
        if (self.typeImageView.image && !self.typeImageView.hidden) {
            maxDetailLabelWith = maxDetailLabelWith - self.typeImageView.width - 10;
        }
        self.cellDetailLabel.width = MIN(self.cellDetailLabel.width, maxDetailLabelWith);
        self.cellDetailLabel.right = self.contentView.width;
    }
    self.cellDetailLabel.centerY = self.height / 2;
    
    self.cellImageView.size = CGSizeMake(30, 30);
    if (self.contentView.width == self.width) {
        self.cellImageView.right = self.width - 10;
    }else{
        self.cellImageView.right = self.contentView.width;
    }
    self.cellImageView.centerY = self.height / 2;
    self.cellInput.size = CGSizeMake(self.width - 10 - self.cellTitleLabel.right - 10, self.height);
    self.cellInput.right = self.width - 10;
    self.cellInput.centerY = self.height / 2;
    self.typeImageView.right = self.cellDetailLabel.left - 10;
    self.typeImageView.centerY = self.height / 2;
}

-(UILabel *)cellTitleLabel{
    if (!_cellTitleLabel) {
        _cellTitleLabel = [[UILabel alloc]init];
        _cellTitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _cellTitleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _cellTitleLabel;
}

-(UILabel *)cellDetailLabel{
    if (!_cellDetailLabel) {
        _cellDetailLabel = [[UILabel alloc]init];
        _cellDetailLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _cellDetailLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _cellDetailLabel;
}

-(UILabel *)cellSubTitleLabel{
    if (!_cellSubTitleLabel) {
        _cellSubTitleLabel = [[UILabel alloc]init];
        _cellSubTitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _cellSubTitleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _cellSubTitleLabel;
}

-(UIImageView *)cellImageView{
    if (!_cellImageView) {
        _cellImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 21, 21)];
        _cellImageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _cellImageView;
}

-(UITextField *)cellInput{
    if (!_cellInput) {
        _cellInput = [[UITextField alloc]init];
        _cellInput.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _cellInput.textAlignment = NSTextAlignmentRight;
        _cellInput.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _cellInput.hidden = YES;
    }
    return _cellInput;
}

-(UIImageView *)typeImageView{
    if (!_typeImageView) {
        _typeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 22, 22)];
    }
    return _typeImageView;
}

-(UIImageView *)cellImage{
    if (!_cellImage) {
        _cellImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 21, 21)];
        _cellImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _cellImage;
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

-(void)setCellImageName:(NSString *)cellImageName{
    _cellImageName = cellImageName;
    self.cellImage.image = [[UIImage imageNamed:_cellImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setNeedsLayout];
}


-(void)setCellTypeImageName:(NSString *)cellTypeImageName{
    _cellTypeImageName = cellTypeImageName;
    self.typeImageView.image = [UIImage imageNamed:_cellTypeImageName];
    [self setNeedsLayout];
}

- (void)setCellTypeImageColor:(NSString *)cellTypeImageColor {
    _cellTypeImageColor = cellTypeImageColor;
    self.typeImageView.tintColor = [UIColor ssj_colorWithHex:_cellTypeImageColor];
}

- (void)updateCellAppearanceAfterThemeChanged{
    [super updateCellAppearanceAfterThemeChanged];
    self.cellTitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.cellDetailLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.cellSubTitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.cellInput.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.cellImageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
