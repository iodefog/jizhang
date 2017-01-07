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
NSString *const SSJEvaluateSelecatedKey = @"SSJEvaluateSelecatedKey";

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
    self.latterButton.bottom = CGRectGetMinY(self.notShowAgainButton.frame) - 11;
    self.favorableButton.bottom = CGRectGetMinY(self.latterButton.frame) - 5;
    self.favorableButton.centerX = self.latterButton.centerX = self.notShowAgainButton.centerX = self.bgImageView.width * 0.5;

}


#pragma mark - Lazy
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

#pragma mark - Setter
- (void)setEvaluateSelecatedType:(SSJEvaluateSelecatedType)evaluateSelecatedType
{
    _evaluateSelecatedType = evaluateSelecatedType;
    [[NSUserDefaults standardUserDefaults] setObject:@(evaluateSelecatedType) forKey:SSJEvaluateSelecatedKey];
}

#pragma mark - Private
- (void)dismiss
{
    [self removeFromSuperview];
}

- (void)show
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];//显示弹框
}


#pragma mark - Action
- (BOOL)showEvaluatePopView
{
//    //当前版本是否显示过弹框()
    int type = [[[NSUserDefaults standardUserDefaults] objectForKey:SSJEvaluateSelecatedKey] intValue];
//    if(type == SSJEvaluateSelecatedTypeNotShowAgain && SSJLaunchTimesForCurrentVersion() <= 1){//更新新版本继续弹出,当前版本是第一次启动并且上一个版本选择了高冷无视更新为还未选择
//        self.evaluateSelecatedType = SSJEvaluateSelecatedTypeUnKnow;
//        return NO;
//    }
    
    if (SSJLaunchTimesForCurrentVersion() > 1) {//当前版本不是第一次启动
        switch (type) {
            case SSJEvaluateSelecatedTypeUnKnow:
            {
                //新用户
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"SSJNewUserKey"] intValue] == 0) {
                    //5天后弹出
                    [self showAfterFiveDays];
                    
                }else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"SSJNewUserKey"] intValue] == 1){//老用户
                    [self show];
                    return YES;
                }
            }
                break;
            case SSJEvaluateSelecatedTypeHighPraise://以后都不弹
                break;
            case SSJEvaluateSelecatedTypeLatter:
            {
                [self showAfterFiveDays];//每隔5天后弹出
            }
                break;
            case SSJEvaluateSelecatedTypeNotShowAgain://当前版本不在弹出
                break;
            default:
                break;
        }
    }
    return NO;
}

- (BOOL)showAfterFiveDays{
    NSDate *currentDate = [NSDate date];
    NSDate *lastPopTime = [[NSUserDefaults standardUserDefaults]objectForKey:SSJApplicationLunchTimeKey];
    NSTimeInterval time = [currentDate timeIntervalSinceDate:lastPopTime];
    int days=((int)time) / (3600*24);
    //每隔5天弹出
    if (days > 5) {
        //弹出
        [self show];
        //更新时间
        [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:SSJApplicationLunchTimeKey];
        return YES;
    }
    return NO;
}

+ (BOOL)SSJIsNewUser
{
   NSDictionary *dic = SSJLaunchTimesInfo();
    __block long double lunchTimes = 0;
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        lunchTimes += [obj doubleValue];
    }];
    return lunchTimes <= 1;
}


+ (void)evaluatePopViewConfiguration
{
    BOOL isFirstLaunch = SSJLaunchTimesForCurrentVersion() == 1;
    //设置app启动时间
    if (isFirstLaunch) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:SSJApplicationLunchTimeKey];
        
        //判断是否为新用户
        if ([self SSJIsNewUser]) {//是新用户
            [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:SSJNewUserKey];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:SSJNewUserKey];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


- (void)favorableButtonClicked
{
    [MobClick event:@"evaluate_good"];
    NSString *appstoreUrlStr = [SSJSettingForSource() objectForKey:@"AppStoreUrl"];
    NSURL *url = [NSURL URLWithString:appstoreUrlStr];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    self.evaluateSelecatedType = SSJEvaluateSelecatedTypeHighPraise;
    [self dismiss];
    
}

- (void)latterButtonClicked
{
    [MobClick event:@"evaluate_later"];
    self.evaluateSelecatedType = SSJEvaluateSelecatedTypeLatter;
    [self dismiss];
}

- (void)notShowAgainButtonClicked
{
    [MobClick event:@"evaluate_not_show"];
    self.evaluateSelecatedType = SSJEvaluateSelecatedTypeNotShowAgain;
    [self dismiss];
}
@end
