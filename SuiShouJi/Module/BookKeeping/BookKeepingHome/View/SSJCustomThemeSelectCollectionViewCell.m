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

@end

@implementation SSJCustomThemeSelectCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        [self addSubview:self.selectImage];
        
    }
    return self;
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
        
    }
    return _selectImage;
}

- (void)setImageName:(NSString *)imageName {
    self.imageView.image = [UIImage imageNamed:imageName];
}

- (void)setIsSelected:(BOOL)isSelected {
    self.selectImage.hidden = !isSelected;
}

- (void)updateConstraints {
    
}

@end
