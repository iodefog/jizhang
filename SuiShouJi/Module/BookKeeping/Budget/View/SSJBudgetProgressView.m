//
//  SSJBudgetProgressView.m
//  SuiShouJi
//
//  Created by old lang on 16/9/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetProgressView.h"

@interface SSJBudgetProgressView ()

@property (nonatomic, strong) UIView *progressView;

@end

@implementation SSJBudgetProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.clipsToBounds = YES;
        
        _progressView = [[UIView alloc] init];
        [self addSubview:_progressView];
    }
    return self;
}

- (void)layoutSubviews {
    self.layer.cornerRadius = self.height * 0.5;
//    _progressView.size = self.size;
//    _progressView.left = - self.width;
    [self updateProgress];
}

- (void)setBudget:(CGFloat)budget {
    if (_budget != budget) {
        _budget = budget;
    }
}

- (void)setProgress:(CGFloat)progress {
    if (_progress != progress) {
        _progress = progress;
        [self updateProgress];
    }
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressView.backgroundColor = progressColor;
}

- (void)updateProgress {
    if (!CGRectIsEmpty(self.bounds)) {
        _progressView.height = self.height;
        [UIView animateWithDuration:1 animations:^{
            _progressView.width = self.width * _progress;
        }];
        
//        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
//        animation.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 0, self.height)];
//        animation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, self.width, self.height)];
//        animation.removedOnCompletion = NO;
//        animation.duration = 2;
//        [_progressView.layer addAnimation:animation forKey:nil];
    }
}

@end
