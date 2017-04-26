//
//  SSJCustomThemeSelectCollectionViewCell.m
//  SuiShouJi
//
//  Created by ricky on 2017/4/24.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCustomThemeSelectCollectionViewCell.h"

@interface SSJCustomThemeSelectCollectionViewCell()

@property(nonatomic, strong) UIImageView *imageView;

@property(nonatomic, strong) UIImageView *selectImage;

@property(nonatomic, strong) UIImageView *addImage;

@property(nonatomic, strong) UIView *maskView;

@end

@implementation SSJCustomThemeSelectCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        [self addSubview:self.selectImage];
        [self addSubview:self.maskView];
        [self addSubview:self.addImage];    
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 13;
        self.layer.borderColor = [UIColor ssj_colorWithHex:@"#F5F5F5"].CGColor;
        self.layer.borderWidth = 2;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    self.maskView.frame = self.bounds;
    self.selectImage.rightTop = CGPointMake(self.width - 8, 8);
    self.addImage.center = CGPointMake(self.width / 2, self.height / 2);
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UIImageView *)selectImage {
    if (!_selectImage) {
        _selectImage = [[UIImageView alloc] init];
        _selectImage.image = [UIImage imageNamed:@"theme_inuse"];
        [_selectImage sizeToFit];
    }
    return _selectImage;
}

- (UIImageView *)addImage {
    if (!_addImage) {
        _addImage = [[UIImageView alloc] init];
        _addImage.image = [UIImage imageNamed:@"theme_add"];
        [_addImage sizeToFit];
    }
    return _addImage;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:0.3];
    }
    return _maskView;
}


- (void)setImageName:(NSString *)imageName {
    self.imageView.image = [UIImage imageNamed:imageName];
}

- (void)setIsSelected:(BOOL)isSelected {
    self.selectImage.hidden = !isSelected;
}

- (void)setIsFirstCell:(BOOL)isFirstCell {
    self.addImage.hidden = !isFirstCell;
}


@end
