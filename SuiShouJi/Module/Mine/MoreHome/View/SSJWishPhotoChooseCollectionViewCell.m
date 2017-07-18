//
//  SSJWishPhotoChooseCollectionViewCell.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishPhotoChooseCollectionViewCell.h"

@interface SSJWishPhotoChooseCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIImageView *addImageView;

@property (nonatomic, strong) UIView *coverView;

/**圆角梦曾*/
@property (nonatomic, strong) CAShapeLayer *markLayer;
@end

@implementation SSJWishPhotoChooseCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.coverView];
        [self.contentView addSubview:self.addImageView];
        [self updateConstraintsIfNeeded];
    }
    return self;
}

- (void)updateConstraints {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];
    
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];
    
    [self.addImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.contentView);
    }];
    [super updateConstraints];
}

- (void)setImage:(NSString *)imageName indexPath:(NSIndexPath *)indexPath {
    self.addImageView.hidden = indexPath.row != 0;
    self.imageView.image = [UIImage imageNamed:imageName];
}

#pragma mark - Lazy
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.layer.mask = self.markLayer;
    }
    return _imageView;
}

- (UIImageView *)addImageView {
    if (!_addImageView) {
        _addImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wish_add_top_image"]];
    }
    return _addImageView;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = [UIColor ssj_colorWithHex:@"000000" alpha:0.5];
        _coverView.layer.cornerRadius = 6;
        _coverView.layer.masksToBounds = YES;
    }
    return _coverView;
}

- (CAShapeLayer *)markLayer {
    if (!_markLayer) {
        _markLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:8];
        _markLayer.path = path.CGPath;
    }
    return _markLayer;
}
@end
