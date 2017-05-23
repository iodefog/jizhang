//
//  SSJSelectCreateShareBookTypeCollectionViewCell.m
//  SuiShouJi
//
//  Created by yi cai on 2017/5/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJSelectCreateShareBookTypeCollectionViewCell.h"

@interface SSJSelectCreateShareBookTypeCollectionViewCell ()
@property(nonatomic, strong) UILabel *nameLab;

@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation SSJSelectCreateShareBookTypeCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.nameLab];
        [self.contentView addSubview:self.imageView];
        
        self.layer.cornerRadius = 20;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha].CGColor;
        self.layer.masksToBounds = YES;
//        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
//        shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:20].CGPath;
//        shapeLayer.borderWidth = 1;
//        shapeLayer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha].CGColor;
//        self.layer.mask = shapeLayer;
        
//        [self ssj_setCornerRadius:20];
//        [self ssj_setBorderWidth:1];
//        [self ssj_setBorderStyle:SSJBorderStyleAll];
//        [self ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];

        
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.nameLab.centerX = self.width * 0.5 + 15;
    self.nameLab.centerY = self.imageView.centerY = self.height * 0.5;
    self.imageView.left = CGRectGetMinX(self.nameLab.frame) - 30;
}

- (void)setImage:(NSString *)image title:(NSString *)title {
    self.nameLab.text = title;
    self.imageView.image = [UIImage imageNamed:image];
    [self.nameLab sizeToFit];
    [self.imageView sizeToFit];
}

#pragma mark - Lazy
- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _nameLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _nameLab;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}
@end
