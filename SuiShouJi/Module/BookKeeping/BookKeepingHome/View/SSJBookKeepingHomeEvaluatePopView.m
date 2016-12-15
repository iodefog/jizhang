//
//  SSJBookKeepingHomeEvaluatePopView.m
//  SuiShouJi
//
//  Created by yi cai on 2016/12/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomeEvaluatePopView.h"

NSString *const SSJApplicationLunchTimeKey = @"SSJApplicationLunchTimeKey";
NSString *const SSJNewUserKey = @"SSJNewUserKey";

@interface SSJBookKeepingHomeEvaluatePopView()

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *buttonBgView;
@property (nonatomic, strong) UIButton *favorableButton;
@property (nonatomic, strong) UIButton *latterButton;
@property (nonatomic, strong) UIButton *notShowAgainButton;
@end
@implementation SSJBookKeepingHomeEvaluatePopView


- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        [self addSubview:self.bgView];
        [self addSubview:self.bgImageView];
        [self.bgImageView addSubview:self.notShowAgainButton];
        [self.bgImageView addSubview:self.latterButton];
        [self.bgImageView addSubview:self.favorableButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bgView.frame = self.bounds;
    self.bgImageView.top = (SSJSCREENHEIGHT - 485) * 0.5 - 30;
    if (self.width > 375) {
        self.bgImageView.left = (self.width - 375) * 0.5;
    }else{
        self.bgImageView.centerX = self.width * 0.5;
    }
    self.notShowAgainButton.bottom = self.bgImageView.height - 25;
    self.latterButton.bottom = CGRectGetMinY(self.notShowAgainButton.frame) - 14;
    self.favorableButton.bottom = CGRectGetMinY(self.latterButton.frame) - 7;
    self.favorableButton.centerX = self.latterButton.centerX = self.notShowAgainButton.centerX = self.bgImageView.width * 0.5;

}

- (UIImageView *)bgImageView
{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_evaluate_bg"]];
        _bgImageView.backgroundColor = [UIColor clearColor];
        _bgImageView.size = CGSizeMake(375, 485);
        _bgImageView.userInteractionEnabled = YES;
    }
    return _bgImageView;
}

- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha = 0.5;
    }
    return _bgView;
}

- (UIView *)buttonBgView
{
    if (!_buttonBgView) {
        _buttonBgView = [[UIView alloc] init];
        _buttonBgView.backgroundColor = [UIColor brownColor];
    }
    return _bgView;
}


- (UIButton *)favorableButton
{
    if (!_favorableButton) {
        _favorableButton = [[UIButton alloc] init];
        _favorableButton.size = CGSizeMake(165, 45);
        _favorableButton.backgroundColor = [UIColor clearColor];
        [_favorableButton addTarget:self action:@selector(favorableButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _favorableButton;
}

- (UIButton *)latterButton
{
    if (!_latterButton) {
        _latterButton = [[UIButton alloc] init];
        _latterButton.size = CGSizeMake(165, 30);
        _latterButton.backgroundColor = [UIColor clearColor];
        [_latterButton addTarget:self action:@selector(latterButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _latterButton;
}

- (UIButton *)notShowAgainButton
{
    if (!_notShowAgainButton) {
        _notShowAgainButton = [[UIButton alloc] init];
        _notShowAgainButton.size = CGSizeMake(165, 30);
        _notShowAgainButton.backgroundColor = [UIColor clearColor];
        [_notShowAgainButton addTarget:self action:@selector(notShowAgainButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _notShowAgainButton;
}


#pragma mark -Private
- (void)dismiss
{
    [self removeFromSuperview];
}


#pragma mark -Action
- (void)showEvaluatePopView
{
   UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
}


+ (BOOL)SSJIsNewUser
{
    return YES;
}


+ (void)evaluatePopViewConfiguration
{
    //设置app启动时间
    if (SSJIsFirstLaunchForCurrentVersion()) {//当前版本是第一次启动
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:SSJApplicationLunchTimeKey];
        
        //判断是否为新用户
        if ([self SSJIsNewUser]) {//是新用户
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:SSJNewUserKey];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:SSJNewUserKey];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)favorableButtonClicked
{
    NSString *appstoreUrlStr = [SSJSettingForSource() objectForKey:@"AppStoreUrl"];
    NSURL *url = [NSURL URLWithString:appstoreUrlStr];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    [self dismiss];
    
}

- (void)latterButtonClicked
{
    [self dismiss];
}

- (void)notShowAgainButtonClicked
{
    [self dismiss];
}
@end
