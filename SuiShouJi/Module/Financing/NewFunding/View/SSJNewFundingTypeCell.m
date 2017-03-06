
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

@end

@implementation SSJNewFundingTypeCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.cellText];
        [self.contentView addSubview:self.typeLabel];
        [self.contentView addSubview:self.colorView];
        [self.contentView addSubview:self.typeImage];
        [self.contentView.layer addSublayer:self.gradientLayer];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.cellText.frame = CGRectMake(20, 0, self.contentView.width - 20, self.contentView.height);
    self.typeLabel.right = self.contentView.width - 10;
    self.typeLabel.centerY = self.contentView.height / 2;
    self.colorView.size = CGSizeMake(30, 30);
    self.colorView.layer.cornerRadius = 15;
    self.colorView.right = self.contentView.width - 10;
    self.colorView.centerY = self.contentView.height / 2;
    self.typeImage.size = CGSizeMake(18, 18);
    self.typeImage.right = self.typeLabel.left - 10;
    self.typeImage.centerY = self.height / 2;
    self.gradientLayer.position = CGPointMake(0, self.height / 2);
    self.gradientLayer.right = self.contentView.width - 10;
}

-(UITextField *)cellText{
    if (!_cellText) {
        _cellText = [[UITextField alloc]init];
        _cellText.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _cellText.font = [UIFont systemFontOfSize:18];
        _cellText.textAlignment = NSTextAlignmentLeft;
    }
    return _cellText;
}

-(UILabel *)typeLabel{
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc]init];
        _typeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _typeLabel.font = [UIFont systemFontOfSize:18];
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
        _gradientLayer.size = CGSizeMake(50, 30);
        _gradientLayer.cornerRadius = 8.f;
    }
    return _gradientLayer;
}

- (void)setColorItem:(SSJFinancingGradientColorItem *)colorItem {
    _gradientLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:colorItem.startColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:colorItem.endColor].CGColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
