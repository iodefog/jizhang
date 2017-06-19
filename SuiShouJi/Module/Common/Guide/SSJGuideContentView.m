//
//  SSJGuideContentView.m
//  MoneyMore
//
//  Created by old lang on 15-5-7.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJGuideContentView.h"
#import <Lottie/Lottie.h>

@interface SSJGuideContentView ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) LOTAnimationView *lottieView;

// 图片名称
@property (nonatomic, copy) NSString *imageName;

@end

@implementation SSJGuideContentView

- (instancetype)initWithFrame:(CGRect)frame withType:(SSJGuideContentViewType)type imageName:(NSString *)imageName{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        _imageName = [imageName copy];
        if (type == SSJGuideContentViewTypeNormal) {
            [self addSubview:self.imageView];
        } else {
            [self addSubview:self.lottieView];
            [self.lottieView play];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.lottieView.frame = [UIApplication sharedApplication].keyWindow.bounds;
    self.imageView.center = CGPointMake(self.width * 0.5, self.height * 0.43);
}

//- (void)setImageName:(NSString *)imageName {
//    if (![_imageName isEqualToString:imageName]) {
//        _imageName = [imageName copy];
//        self.imageView.image = [UIImage imageNamed:imageName];
//        [self.imageView sizeToFit];
//        [self setNeedsLayout];
//    }
//}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = [UIImage imageNamed:self.imageName];
        [_imageView sizeToFit];
    }
    return _imageView;
}

- (LOTAnimationView *)lottieView {
    if (!_lottieView) {
        _lottieView = [LOTAnimationView animationNamed:self.imageName];
        _lottieView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _lottieView;
}

- (void)play {
    if (self.lottieView) {
        self.lottieView.animationProgress = 0;
        [self.lottieView play];
    }
}

@end
