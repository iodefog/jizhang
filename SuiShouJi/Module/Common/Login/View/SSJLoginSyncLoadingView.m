//
//  SSJLoginSyncLoadingView.m
//  SuiShouJi
//
//  Created by old lang on 16/2/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoginSyncLoadingView.h"

static const NSTimeInterval kDuration = 0.25;

@interface SSJLoginSyncLoadingView ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *label;

@end

@implementation SSJLoginSyncLoadingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
//        self.alpha = 0.5;
        
        [self addSubview:self.indicatorView];
        [self addSubview:self.label];
        
        [self sizeToFit];
    }
    return self;
}

- (void)layoutSubviews {
    if (self.indicatorView.hidden) {
        self.label.center = CGPointMake(self.width * 0.5, self.height * 0.5);
    } else {
        CGFloat gap = 10;
        CGFloat left = (self.width - self.label.width - self.indicatorView.width - gap) * 0.5;
        self.indicatorView.left = left;
        self.label.left = self.indicatorView.right + gap;
        self.indicatorView.centerY = self.label.centerY = self.height * 0.5;
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat width = [UIApplication sharedApplication].keyWindow.width;
    CGFloat height = MAX(self.indicatorView.height, self.label.height);
    return CGSizeMake(width, height + 10);
}

- (void)show {
    if (!self.superview) {
        [self.indicatorView startAnimating];
        self.label.text = @"同步中...";
        [self.label sizeToFit];
        [self setNeedsLayout];
        
        if (!self.superview) {
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
            [keyWindow addSubview:self];
        }
        
        self.bottom = 0;
        [UIView animateWithDuration:kDuration animations:^{
            self.bottom = self.height;
        }];
    }
}

- (void)dismissWithSuccess:(BOOL)success {
    if (self.superview) {
        [self.indicatorView stopAnimating];
        self.label.text = success ? @"同步成功" : @"同步失败";
        [self.label sizeToFit];
        [self setNeedsLayout];
        
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.3];
    }
}

- (void)dismiss {
    [UIView animateWithDuration:kDuration animations:^{
        self.bottom = 0;
    }];
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _indicatorView;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:14];
        _label.textColor = [UIColor whiteColor];
        _label.backgroundColor = [UIColor clearColor];
    }
    return _label;
}

@end
