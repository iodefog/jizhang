
//
//  SSJNewFundingTypeCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNewFundingTypeCell.h"

@interface SSJNewFundingTypeCell()

@property(nonatomic, strong) CAGradientLayer *gradientLayer;

@property(nonatomic, strong) UIImageView *cellImageView;

@property (nonatomic,strong) UITextField *cellTextLab;

@end

@implementation SSJNewFundingTypeCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.cellImageView];
        [self.contentView addSubview:self.cellTextLab];
        [self.contentView addSubview:self.typeLabel];
        [self.contentView addSubview:self.colorView];
        [self.contentView addSubview:self.typeImage];
        [self.contentView.layer addSublayer:self.gradientLayer];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.cellTextLab.frame = CGRectMake(self.cellImageView.right + 12, 0, self.contentView.width - self.cellImageView.right - 30, self.contentView.height);
    self.typeLabel.right = self.contentView.width - 10;
    self.typeLabel.centerY = self.contentView.height / 2;
    self.typeImage.size = CGSizeMake(18, 18);
    self.typeImage.right = self.typeLabel.left - 10;
    self.typeImage.centerY = self.height / 2;
    self.gradientLayer.position = CGPointMake(0, self.height / 2);
    self.gradientLayer.right = self.contentView.width - 10;
}

-(UITextField *)cellTextLab{
    if (!_cellTextLab) {
        _cellTextLab = [[UITextField alloc]init];
        _cellTextLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _cellTextLab.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
        _cellTextLab.textAlignment = NSTextAlignmentLeft;
    }
    return _cellTextLab;
}

-(UILabel *)typeLabel{
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc]init];
        _typeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _typeLabel.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
    }
    return _typeLabel;
}

-(UIView *)colorView{
    if (!_colorView) {
        _colorView = [[UIView alloc]init];
    }
    return _colorView;
}

-(UIImageView *)typeImage{
    if (!_typeImage) {
        _typeImage = [[UIImageView alloc]init];
    }
    return _typeImage;
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

- (UIImageView *)cellImageView {
    if (!_cellImageView) {
        _cellImageView = [[UIImageView alloc] init];
        _cellImageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _cellImageView;
}

- (void)setCellImage:(NSString *)cellImage {
    self.cellImageView.image = [[UIImage imageNamed:cellImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)setColorItem:(SSJFinancingGradientColorItem *)colorItem {
    _gradientLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:colorItem.startColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:colorItem.endColor].CGColor];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    _cellTextLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _typeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _cellImageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
