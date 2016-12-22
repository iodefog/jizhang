//
//  SSJHeaderBannerCollectionViewCell.m
//  SuiShouJi
//
//  Created by yi cai on 2016/12/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJHeaderBannerCollectionViewCell.h"
@interface SSJHeaderBannerCollectionViewCell()
@property (nonatomic, strong) UIImageView *imageView;
@end
@implementation SSJHeaderBannerCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imageView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellAppearanceAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];
        [self updateCellAppearanceAfterThemeChanged];
    }
    return self;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor clearColor];
//        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}
- (void)setBannerImage:(NSString *)image
{
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:image]];
//    [self.imageView sd_setImageWithURL:[NSURL URLWithString:image] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        if (image) {
//            
//        }
//    }];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.frame = self.bounds;
}

-(void)updateCellAppearanceAfterThemeChanged{
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:SSJThemeDidChangeNotification];
}

@end
