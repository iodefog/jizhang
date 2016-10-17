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

@property (nonatomic, strong) UILabel *surplusLab;

@end

@implementation SSJBudgetProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.clipsToBounds = YES;
        
        _progressView = [[UIView alloc] init];
        [self addSubview:_progressView];
        
        _surplusLab = [[UILabel alloc] init];
        _surplusLab.font = [UIFont systemFontOfSize:13];
        _surplusLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [self addSubview:_surplusLab];
    }
    return self;
}

- (void)layoutSubviews {
    self.layer.cornerRadius = self.height * 0.5;
//    _progressView.size = self.size;
//    _progressView.left = - self.width;
    _surplusLab.center = CGPointMake(self.width * 0.5, self.height * 0.5);
    [self updateProgress];
}

- (void)setBudget:(CGFloat)budget {
    if (_budget != budget) {
        _budget = budget;
        [self updateMoney];
    }
}

- (void)setProgress:(CGFloat)progress {
    if (progress < 0) {
        SSJPRINT(@"progress不能为负数");
        return;
    }
    if (_progress != progress) {
        _progress = progress;
        _progressView.backgroundColor = _progress > 1 ? _overrunProgressColor : _progressColor;
        [self updateMoney];
        [self updateProgress];
    }
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    _progressView.backgroundColor = _progress > 1 ? _overrunProgressColor : _progressColor;
}

- (void)setOverrunProgressColor:(UIColor *)overrunProgressColor {
    _overrunProgressColor = overrunProgressColor;
    _progressView.backgroundColor = _progress > 1 ? _overrunProgressColor : _progressColor;
}

- (void)updateMoney {
    if (_progress >= 0 && _progress <= 1) {
        _surplusLab.text = [NSString stringWithFormat:@"剩余：%.2f", _budget * (1 - _progress)];
    } else if (_progress > 1) {
        _surplusLab.text = [NSString stringWithFormat:@"超支：%.2f", _budget * (_progress - 1)];
    }
    [_surplusLab sizeToFit];
}

- (void)updateProgress {
    if (!CGRectIsEmpty(self.bounds)) {
        _progressView.size = CGSizeMake(0, self.height);
//        _surplusLab.left = 10;
//        _surplusLab.centerY = self.height * 0.5;
        [UIView animateWithDuration:1 animations:^{
            _progressView.width = self.width * _progress;
//            _surplusLab.left = MIN(self.width - _surplusLab.width - 10, self.width * _progress + 10);
        }];
    }
}

@end
