//
//  SSJWishProgressView.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishProgressView.h"

static NSTimeInterval animationTime = 1;
@interface SSJWishProgressView ()

@property(nonatomic, strong, nullable) UIColor *progressTintColor;

@property(nonatomic, strong, nullable) UIColor *trackTintColor;

@property (nonatomic, strong) UIView *progressView;

@property (nonatomic, strong) UIView *trackView;

@property (nonatomic, strong) UIButton *progressBtn;
@end

@implementation SSJWishProgressView

- (instancetype)initWithFrame:(CGRect)frame proColor:(UIColor *)proColor trackColor:(UIColor *)trackColor {
    if (self = [super initWithFrame:frame]) {
        self.trackTintColor = trackColor;
        self.progressTintColor = proColor;
        [self addSubview:self.trackView];
        [self.trackView addSubview:self.progressView];
        [self addSubview:self.progressBtn];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.progressBtn.size = CGSizeMake(36, 22);
    self.trackView.frame = CGRectMake(0, self.progressBtn.height, self.width, self.height - self.progressBtn.height);
    self.progressView.frame = CGRectMake(0, 0, self.progress * self.width, self.trackView.height);
    self.progressBtn.centerX = self.progressView.width;
}
- (void)setProgress:(float)progress {
    if (progress > 1) {
        progress = 1;
    }
    _progress = progress;
    [self.progressBtn setTitle:[NSString stringWithFormat:@"%.f%@",progress * 100,@"%"] forState:UIControlStateNormal];
    
    @weakify(self);
    [UIView animateWithDuration:progress * animationTime animations:^{
        @strongify(self);
        self.progressView.width = progress * self.width;
        self.progressBtn.centerX = self.progressView.width;
    }];

}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    self.progressView.backgroundColor = progressColor;
    self.progressBtn.tintColor = self.progressColor;
    
}

- (UIView *)progressView {
    if (!_progressView) {
        _progressView = [[UIView alloc] init];
        _progressView.backgroundColor = self.progressTintColor;
    }
    return _progressView;
}

- (UIView *)trackView {
    if (!_trackView) {
        _trackView = [[UIView alloc] init];
        _trackView.backgroundColor = self.trackTintColor;
        _trackView.layer.cornerRadius = 8;
        _trackView.layer.masksToBounds = YES;
    }
    return _trackView;;
}

- (UIButton *)progressBtn {
    if (!_progressBtn) {
        _progressBtn = [[UIButton alloc] init];
        [_progressBtn setBackgroundImage:[[UIImage imageNamed:@"wish_progress_bg"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _progressBtn.tintColor = self.progressColor?: self.progressTintColor;
        [_progressBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_progressBtn setTitle:@"0" forState:UIControlStateNormal];
        _progressBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_6];
        [_progressBtn setTitleEdgeInsets:UIEdgeInsetsMake(-2, 0, 2, 0)];
        [_progressBtn sizeToFit];
    }
    return _progressBtn;
}

@end
