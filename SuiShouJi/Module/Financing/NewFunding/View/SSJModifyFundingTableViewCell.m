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

@end

@implementation SSJModifyFundingTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.cellTitle];
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
    self.cellTitle.left = 10;
    self.cellTitle.centerY = self.height / 2;
    self.cellDetail.size = self.contentView.size;
    self.cellDetail.right = self.contentView.width - 10;
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

-(UILabel *)cellTitle{
    if (!_cellTitle) {
        _cellTitle = [[UILabel alloc]init];
        _cellTitle.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _cellTitle.font = [UIFont systemFontOfSize:18];
    }
    return _cellTitle;
}

-(UITextField *)cellDetail{
    if (!_cellDetail) {
        _cellDetail = [[UITextField alloc]init];
        _cellDetail.textAlignment = NSTextAlignmentRight;
        _cellDetail.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _cellDetail.font = [UIFont systemFontOfSize:15];
        _cellDetail.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _cellDetail;
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

-(UILabel *)typeTitle{
    if (!_typeTitle) {
        _typeTitle = [[UILabel alloc]init];
        _typeTitle.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _typeTitle.font = [UIFont systemFontOfSize:15];
    }
    return _typeTitle;
}

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.size = CGSizeMake(50, 30);
        _gradientLayer.cornerRadius = 8.f;
    }
    return _gradientLayer;
}

- (void)setItem:(SSJFinancingGradientColorItem *)item {
    _gradientLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:item.startColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:item.endColor].CGColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
