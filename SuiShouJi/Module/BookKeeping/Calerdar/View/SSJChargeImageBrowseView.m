//
//  SSJChargeImageBrowseView.m
//  SuiShouJi
//
//  Created by old lang on 17/5/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJChargeImageBrowseView.h"

static const NSTimeInterval kAnimationDuration = 0.25;

@interface SSJChargeImageBrowseView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation SSJChargeImageBrowseView

+ (void)showWithImage:(UIImage *)image {
    SSJChargeImageBrowseView *view = [[SSJChargeImageBrowseView alloc] init];
    view.image = image;
    [view show];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.scrollView];
        [self setNeedsUpdateConstraints];
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)layoutSubviews {
    self.scrollView.frame = self.bounds;
    
    CGSize imgSize = self.imageView.image.size;
    if (imgSize.width < self.width * SSJ_SCREEN_SCALE
        && imgSize.height < self.height * SSJ_SCREEN_SCALE) {
        self.imageView.size = CGSizeMake(imgSize.width / SSJ_SCREEN_SCALE, imgSize.height / SSJ_SCREEN_SCALE);
    } else {
        CGFloat height = self.width / imgSize.width * imgSize.height;
        self.imageView.size = CGSizeMake(self.width, height);
    }
    self.imageView.center = CGPointMake(self.scrollView.width * 0.5, self.scrollView.height * 0.5);
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
    
}

- (void)show {
    self.frame = SSJ_KEYWINDOW.bounds;
    [SSJ_KEYWINDOW addSubview:self];
    self.alpha = 0;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.alpha = 1;
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UIScrollViewDelegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.maximumZoomScale = 2;
        _scrollView.bouncesZoom = NO;
        _scrollView.delegate = self;
        [_scrollView addSubview:self.imageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [_scrollView addGestureRecognizer:tap];
    }
    return _scrollView;
}

- (void)tapAction {
    [self dismiss];
}

@end
