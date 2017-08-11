//
//  SSJStartUpgradeAlertView.m
//  SuiShouJi
//
//  Created by old lang on 16/2/2.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJStartUpgradeAlertView.h"

//  最小标题高度
static const CGFloat kMinTitleHeight = 44;

//  最小内容高度
static const CGFloat kMinContentHeight = 38;

//  按钮固定高度
static const CGFloat kButtonHeight = 44;

//  动画持续时间
static const NSTimeInterval kDuration = 0.3;

@interface SSJStartUpgradeAlertView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) void(^cancelHandler)(SSJStartUpgradeAlertView *);
@property (nonatomic, strong) void(^sureHandler)(SSJStartUpgradeAlertView *);

@property (nonatomic) CGFloat titleHeight;

@property (nonatomic) CGFloat contentHeight;

@end

@implementation SSJStartUpgradeAlertView

- (instancetype)initWithTitle:(NSString *)title message:(NSAttributedString *)message cancelButtonTitle:(nullable NSString *)cancelButtonTitle sureButtonTitle:(nullable NSString *)sureButtonTitle cancelButtonClickHandler:(nullable void(^)(SSJStartUpgradeAlertView *alert))cancelHandler sureButtonClickHandler:(nullable void(^)(SSJStartUpgradeAlertView *alert))sureHandler {
    if (self = [super initWithFrame:CGRectZero]) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 3;
        self.clipsToBounds = YES;
        
        self.titleLabel.text = title;
        self.contentLabel.attributedText = message;
        [self.scrollView addSubview:self.contentLabel];
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.scrollView];
        
        if (cancelButtonTitle.length) {
            [self.cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
            [self addSubview:self.cancelButton];
            self.cancelHandler = cancelHandler;
        }
        
        if (sureButtonTitle.length) {
            [self.sureButton setTitle:sureButtonTitle forState:UIControlStateNormal];
            [self addSubview:self.sureButton];
            self.sureHandler = sureHandler;
        }
        
        if (cancelButtonTitle.length && sureButtonTitle.length) {
            [self.cancelButton ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
            [self.cancelButton ssj_setBorderStyle:(SSJBorderStyleRight | SSJBorderStyleTop)];
            [self.cancelButton ssj_setBorderWidth:1];
        }
        
        [self sizeToFit];
    }
    return self;
}

- (void)layoutSubviews {
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = CGRectMake(0, 0, self.width, _titleHeight);

    self.scrollView.contentSize = CGSizeMake(self.contentLabel.width, self.contentLabel.height);
    self.scrollView.frame = CGRectMake(15, self.titleLabel.bottom, self.contentLabel.width, _contentHeight);
    
    if ([self.cancelButton titleForState:UIControlStateNormal].length
        && [self.sureButton titleForState:UIControlStateNormal].length) {
        
        self.cancelButton.frame = CGRectMake(0, self.scrollView.bottom, self.width * 0.5, kButtonHeight);
        self.sureButton.frame = CGRectMake(self.width * 0.5, self.scrollView.bottom, self.width * 0.5, kButtonHeight);
        
    } else if ([self.cancelButton titleForState:UIControlStateNormal].length
               && ![self.sureButton titleForState:UIControlStateNormal].length) {
        
        self.cancelButton.frame = CGRectMake(0, self.scrollView.bottom, self.width, kButtonHeight);
        
    } else if (![self.cancelButton titleForState:UIControlStateNormal].length
               && [self.sureButton titleForState:UIControlStateNormal].length) {
        
        self.sureButton.frame = CGRectMake(0, self.scrollView.bottom, self.width, kButtonHeight);
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat width = 270;
    
    self.contentLabel.width = width - 30;
    [self.contentLabel sizeToFit];
    
    _titleHeight = MAX(kMinTitleHeight, self.titleLabel.height);
    CGFloat maxContentHeight = [UIScreen mainScreen].bounds.size.height * 0.7 - _titleHeight - kButtonHeight;
    _contentHeight = MIN(MAX(kMinContentHeight, self.contentLabel.height + 15), maxContentHeight);
    
    return CGSizeMake(width, _titleHeight + _contentHeight + kButtonHeight);
}

#pragma mark - Public
- (void)show {
    if (!self.superview) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow addSubview:self.backgroundView];
        [keyWindow addSubview:self];
        self.center = CGPointMake(keyWindow.width * 0.5, keyWindow.height * 0.5);
        self.transform = CGAffineTransformMakeScale(0, 0);
        
        [UIView animateKeyframesWithDuration:0.36 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.25 animations:^{
                self.transform = CGAffineTransformMakeScale(0.7, 0.7);
            }];
            [UIView addKeyframeWithRelativeStartTime:0.25 relativeDuration:0.25 animations:^{
                self.transform = CGAffineTransformMakeScale(0.9, 0.9);
            }];
            [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.25 animations:^{
                self.transform = CGAffineTransformMakeScale(1.2, 1.2);
            }];
            [UIView addKeyframeWithRelativeStartTime:0.75 relativeDuration:0.25 animations:^{
                self.transform = CGAffineTransformMakeScale(1, 1);
            }];
        } completion:NULL];
    }
}

- (void)dismiss {
    if (self.superview) {
        [UIView transitionWithView:self.superview duration:kDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self removeFromSuperview];
            [self.backgroundView removeFromSuperview];
        } completion:NULL];
    }
}

#pragma mark - Event
- (void)cancelButtonAction {
    if (self.cancelHandler) {
        self.cancelHandler(self);
    }
}

- (void)sureButtonAction {
    if (self.sureHandler) {
        self.sureHandler(self);
    }
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = self.backgroundColor;
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = self.backgroundColor;
        _contentLabel.font = [UIFont systemFontOfSize:12];
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = self.backgroundColor;
        _scrollView.bounces = NO;
    }
    return _scrollView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[[_cancelButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
        [_cancelButton ssj_setBorderStyle:SSJBorderStyleTop];
        [_cancelButton ssj_setBorderWidth:1];
    }
    return _cancelButton;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_sureButton setTitleColor:[UIColor ssj_colorWithHex:@"#EE4F4F"] forState:UIControlStateNormal];
        [_sureButton setTitleColor:[[_sureButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [_sureButton addTarget:self action:@selector(sureButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_sureButton ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
        [_sureButton ssj_setBorderStyle:SSJBorderStyleTop];
        [_sureButton ssj_setBorderWidth:1];
    }
    return _sureButton;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0.3;
    }
    return _backgroundView;
}

@end
