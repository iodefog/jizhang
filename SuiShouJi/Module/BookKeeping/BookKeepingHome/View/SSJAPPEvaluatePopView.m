//
//  SSJAPPEvaluatePopView.m
//  SuiShouJi
//
//  Created by yi cai on 2017/6/28.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJAPPEvaluatePopView.h"
#import "CDPointActivityIndicator.h"
#import <StoreKit/StoreKit.h>

NSString *const SSJAppApplicationLunchTimeKey = @"SSJAppApplicationLunchTimeKey";
NSString *const SSJAppNewUserKey = @"SSJAppNewUserKey";
NSString *const SSJAppEvaluateSelecatedKey = @"SSJAppEvaluateSelecatedKey";

@interface SSJAPPEvaluatePopView() <SKStoreProductViewControllerDelegate>
/**topImageView*/
@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) UILabel *titleL;
@property (nonatomic, strong) UIButton *favorableButton;
@property (nonatomic, strong) UIButton *latterButton;
@property (nonatomic, strong) UIButton *tuCaoButton;
/**背景*/
@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, weak) UIViewController *controller;

@end

@implementation SSJAPPEvaluatePopView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 12;
        self.layer.masksToBounds = YES;
        [self addSubview:self.topImageView];
        [self addSubview:self.titleL];
        [self addSubview:self.favorableButton];
        [self addSubview:self.latterButton];
        [self addSubview:self.tuCaoButton];
        [self updateConstraintsIfNeeded];
    }
    return self;
}

- (void)updateConstraints {
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(20);
    }];
    
    [self.titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.width.greaterThanOrEqualTo(0);
        make.top.mas_equalTo(self.topImageView.mas_bottom).offset(10);
    }];
    
    [self.favorableButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleL.mas_bottom).offset(17);
        make.left.mas_equalTo(10);
        make.rightMargin.mas_equalTo(-10);
        make.height.mas_equalTo(44);
    }];
    
    [self.tuCaoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.mas_equalTo(self.favorableButton);
        make.top.mas_equalTo(self.favorableButton.mas_bottom).offset(10);
    }];
    
    [self.latterButton mas_makeConstraints:^(MASConstraintMaker *make) {
       make.left.right.height.mas_equalTo(self.favorableButton);
        make.top.mas_equalTo(self.tuCaoButton.mas_bottom).offset(10);
    }];
    [super updateConstraints];
}

#pragma mark - SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self.controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private
- (void)dismiss
{
    [self removeFromSuperview];
    [self.bgView removeFromSuperview];
}

- (void)show
{
    //更新时间
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:SSJAppApplicationLunchTimeKey];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    self.frame = CGRectMake(0, 0, 300, 340);
    self.center = keyWindow.center;
    [keyWindow addSubview:self.bgView];
    [self.bgView addSubview:self];
}

#pragma mark - Action
- (BOOL)showEvaluatePopViewWithController:(UIViewController *)controller
{
    self.controller = controller;
    
    //    //当前版本是否显示过弹框()
    int type = [[[NSUserDefaults standardUserDefaults] objectForKey:SSJAppEvaluateSelecatedKey] intValue];
    
#ifdef PRODUCTION
    int times = 10;
#else
    int times = 0;
#endif
    
    if (SSJLaunchTimesForCurrentVersion() > times) {//当前版本不是第一次启动
        switch (type) {
            case SSJAPPEvaluateSelecatedTypeUnKnow:
            {
                [self show];
//                //新用户
//                if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"SSJNewUserKey"] intValue] == 0) {
//                    //30天后弹出
//                    [self showAfterOneMonth];
//                    
//                }else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"SSJNewUserKey"] intValue] == 1){//老用户
//                    [self show];
//                    return YES;
//                }
            }
                break;
            case SSJAPPEvaluateSelecatedTypePraise://以后都不弹
                break;
            case SSJAPPEvaluateSelecatedTypeLatter:
            {
                [self showAfterOneMonth];//一个月后弹出
            }
                break;
            default:
                break;
        }
    }
    return NO;
}

- (BOOL)showAfterOneMonth {
    NSDate *currentDate = [NSDate date];
    NSDate *lastPopTime = [[NSUserDefaults standardUserDefaults]objectForKey:SSJAppApplicationLunchTimeKey];
    NSTimeInterval time = [currentDate timeIntervalSinceDate:lastPopTime];
    int days=((int)time) / (3600*24);
    //每隔30天弹出
    if (days > 30) {
        //弹出
        [self show];
        
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
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:SSJAppApplicationLunchTimeKey];
        
        //判断是否为新用户
        if ([self SSJIsNewUser]) {//是新用户
            [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:SSJAppNewUserKey];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:SSJAppNewUserKey];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Lazy

- (UIImageView *)topImageView
{
    if (!_topImageView) {
        _topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_evaluate_top_image"]];
    }
    return _topImageView;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:SSJ_KEYWINDOW.bounds];
        _bgView.backgroundColor = [UIColor ssj_colorWithHex:@"000000" alpha:0.5];
    }
    return _bgView;
}

- (UILabel *)titleL {
    if (!_titleL) {
        _titleL = [[UILabel alloc] init];
        _titleL.text = @"么么哒，你觉得有鱼记账好不好～？";
        _titleL.textColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].mainColor];
        _titleL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _titleL;
}

- (UIButton *)favorableButton
{
    if (!_favorableButton) {
        _favorableButton = [[UIButton alloc] init];
        _favorableButton.backgroundColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].marcatoColor];
        _favorableButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_favorableButton setTitle:@"当然，赏你五星 (╭￣3￣)╭♡" forState:UIControlStateNormal];
        [_favorableButton addTarget:self action:@selector(favorableButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _favorableButton.layer.cornerRadius = 8;
        _favorableButton.layer.masksToBounds = YES;
    }
    return _favorableButton;
}

- (UIButton *)latterButton
{
    if (!_latterButton) {
        _latterButton = [[UIButton alloc] init];
        _latterButton.backgroundColor = [UIColor clearColor];
        [_latterButton setTitleColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].mainColor] forState:UIControlStateNormal];
        _latterButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_latterButton setTitle:@"再用用看" forState:UIControlStateNormal];
        _latterButton.layer.cornerRadius = 8;
        _latterButton.layer.masksToBounds = YES;
        _latterButton.layer.borderColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].cellSeparatorColor].CGColor;
        _latterButton.layer.borderWidth = 1;
        [_latterButton addTarget:self action:@selector(latterButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _latterButton;
}

- (UIButton *)tuCaoButton
{
    if (!_tuCaoButton) {
        _tuCaoButton = [[UIButton alloc] init];
        _tuCaoButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_tuCaoButton setTitle:@"我要去吐槽" forState:UIControlStateNormal];
        [_tuCaoButton setTitleColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].mainColor] forState:UIControlStateNormal];
        _tuCaoButton.layer.cornerRadius = 8;
        _tuCaoButton.layer.masksToBounds = YES;
        _tuCaoButton.layer.borderColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].cellSeparatorColor].CGColor;
        _tuCaoButton.layer.borderWidth = 1;
        _tuCaoButton.backgroundColor = [UIColor clearColor];
        [_tuCaoButton addTarget:self action:@selector(tuCaoButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tuCaoButton;
}

- (void)favorableButtonClicked
{
//    if ([SKStoreReviewController respondsToSelector:@selector(requestReview)]) {
//        [SKStoreReviewController requestReview];
//        self.evaluateSelecatedType = SSJAPPEvaluateSelecatedTypePraise;
//        [[NSUserDefaults standardUserDefaults] setObject:@(self.evaluateSelecatedType) forKey:SSJAppEvaluateSelecatedKey];
//        [self dismiss];
//    } else {
//        [CDPointActivityIndicator startAnimating];
//        SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
//        storeProductVC.delegate = self;
//        [storeProductVC loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:SSJAppleID()} completionBlock:^(BOOL result, NSError * _Nullable error) {
//            [CDPointActivityIndicator stopAnimating];
//            if (!error) {
//                [self.controller presentViewController:storeProductVC animated:YES completion:nil];
//                self.evaluateSelecatedType = SSJAPPEvaluateSelecatedTypePraise;
//                [[NSUserDefaults standardUserDefaults] setObject:@(self.evaluateSelecatedType) forKey:SSJAppEvaluateSelecatedKey];
//                [self dismiss];
//            } else {
//                [CDAutoHideMessageHUD showError:error];
//            }
//        }];
//    }
//    
    [SSJAnaliyticsManager event:@"favorite_good"];
}

- (void)tuCaoButtonClicked {
    [SSJAnaliyticsManager event:@"favorite_complaint"];
    [self dismiss];
    self.evaluateSelecatedType = SSJAPPEvaluateSelecatedTypeTuCao;
    [[NSUserDefaults standardUserDefaults] setObject:@(self.evaluateSelecatedType) forKey:SSJAppEvaluateSelecatedKey];
    if (self.tuCaoBtnClickBlock) {
        self.tuCaoBtnClickBlock();
    }
}

- (void)latterButtonClicked
{
    [SSJAnaliyticsManager event:@"favorite_continue"];
    self.evaluateSelecatedType = SSJAPPEvaluateSelecatedTypeLatter;
    [[NSUserDefaults standardUserDefaults] setObject:@(self.evaluateSelecatedType) forKey:SSJAppEvaluateSelecatedKey];
    [self dismiss];
}


@end
