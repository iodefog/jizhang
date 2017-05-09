//
//  SSJNewFundingTableViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJModifyFundingTableViewCell.h"

@interface SSJModifyFundingTableViewCell()

@property(nonatomic, strong) CAGradientLayer *gradientLayer;

@property(nonatomic, strong) UIImageView *cellImageView;

@property (nonatomic,strong) UILabel *cellTextLab;

@end

@implementation SSJModifyFundingTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.cellImageView];
        [self.contentView addSubview:self.cellTextLab];
        [self.contentView addSubview:self.colorView];
        [self.contentView addSubview:self.cellDetail];
        [self.contentView addSubview:self.typeTitle];
        [self.contentView addSubview:self.typeImage];
        [self.contentView.layer addSublayer:self.gradientLayer];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.cellImageView.size = CGSizeMake(20, 20);
    self.cellImageView.centerY = self.height / 2;
    self.cellImageView.left = 20;
    self.cellTextLab.left = self.cellImageView.right + 10;
    self.cellTextLab.centerY = self.height / 2;
    self.cellDetail.width = self.contentView.width - self.cellTextLab.right - 19;
    self.cellDetail.height = self.contentView.height;
    self.cellDetail.left = self.cellTextLab.right + 10;
    self.cellDetail.centerY = self.height / 2;
    self.colorView.size = CGSizeMake(30, 30);
    self.colorView.right = self.contentView.width - 10;
    self.colorView.layer.cornerRadius = 15;
    self.colorView.centerY = self.height / 2;
    self.typeTitle.right = self.cellDetail.right;
    self.typeTitle.centerY = self.height / 2;
    self.typeImage.size = CGSizeMake(22, 22);
    self.typeImage.right = self.typeTitle.left - 10;
    self.typeImage.centerY = self.height / 2;
    self.gradientLayer.position = CGPointMake(0, self.height / 2);
    self.gradientLayer.right = self.contentView.width - 10;
}

-(UILabel *)cellTextLab{
    if (!_cellTextLab) {
        _cellTextLab = [[UILabel alloc] init];
        _cellTextLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _cellTextLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _cellTextLab;
}


-(UITextField *)cellDetail{
    if (!_cellDetail) {
        _cellDetail = [[UITextField alloc] init];
        _cellDetail.textAlignment = NSTextAlignmentRight;
        _cellDetail.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _cellDetail.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _cellDetail.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _cellDetail;
}

-(UIImageView *)typeImage{
    if (!_typeImage) {
        _typeImage = [[UIImageView alloc]init];
    }
    return _typeImage;
}

-(UILabel *)typeTitle{
    if (!_typeTitle) {
        _typeTitle = [[UILabel alloc]init];
        _typeTitle.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _typeTitle.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _typeTitle;
}

- (UIImageView *)cellImageView {
    if (!_cellImageView) {
        _cellImageView = [[UIImageView alloc] init];
        _cellImageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _cellImageView;
}


- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.startPoint = CGPointMake(0, 0.5);
        _gradientLayer.endPoint = CGPointMake(1, 0.5);
        _gradientLayer.size = CGSizeMake(50, 30);
        _gradientLayer.cornerRadius = 8.f;
    }
    return _gradientLayer;
}

- (void)setItem:(SSJFinancingGradientColorItem *)item {
    _gradientLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:item.startColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:item.endColor].CGColor];
}

- (void)setCellImage:(NSString *)cellImage {
    self.cellImageView.image = [[UIImage imageNamed:cellImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)setCellTitle:(NSString *)cellTitle {
    self.cellTextLab.text = cellTitle;
    [self.cellTextLab sizeToFit];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
