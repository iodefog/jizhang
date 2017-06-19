//
//  SSJMotionPasswordViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/3/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMotionPasswordViewController.h"
#import "SSJNavigationController.h"
#import "SSJLoginViewController.h"
#import "SCYMotionEncryptionView.h"
#import "SSJUserTableManager.h"
#import "UIImageView+CornerRadius.h"
#import "SSJMotionPasswordLoginPasswordAlertView.h"
#import <LocalAuthentication/LocalAuthentication.h>

static NSString *const kErrorRemindTextColor = @"ff7139";

//  验证密码最多错误次数
static const int kVerifyFailureTimesLimit = 5;

@interface SSJMotionPasswordViewController () <SCYMotionEncryptionViewDelegate>

@property (nonatomic, strong) UIView *portraitContainer;

@property (nonatomic, strong) UIImageView *portraitView;

@property (nonatomic, strong) UILabel *remindLab;

@property (nonatomic, strong) UIButton *verifyLoginPwdBtn;

@property (nonatomic, strong) UIButton *forgetPwdBtn;

@property (nonatomic, strong) UIButton *changeAccountBtn;

@property (nonatomic, strong) SCYMotionEncryptionView *miniMotionView;

@property (nonatomic, strong) SCYMotionEncryptionView *motionView;

@property (nonatomic, strong) SSJMotionPasswordLoginPasswordAlertView *passwordAlertView;

@property (nonatomic, copy) NSString *password;

@property (nonatomic) int verifyFailureTimes;

// 设置手势密码时是否需要验证初始密码
@property (nonatomic) BOOL needToVerifyOriginalPwd;

@property (nonatomic, strong) SSJUserItem *userItem;

@property (nonatomic, strong) LAContext *context;

@end

@implementation SSJMotionPasswordViewController

#pragma mark - Lifecycle
+ (void)verifyMotionPasswordIfNeeded:(void (^)(BOOL isVerified))finish animated:(BOOL)animated {
    if (!SSJIsUserLogined()) {
        if (finish) {
            finish(NO);
        }
        return;
    }
    
    //  如果当前页面已经是手势密码，直接返回
    UIViewController *currentVC = SSJVisibalController();
    if ([currentVC isKindOfClass:[SSJMotionPasswordViewController class]]) {
        if (finish) {
            finish(NO);
        }
        return;
    }
    
    [SSJUserTableManager queryProperty:@[@"motionPWD", @"motionPWDState"] forUserId:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
        // 手势密码开启
        if ([userItem.motionPWDState boolValue] && userItem.motionPWD.length) {
            //  验证手势密码页面
            SSJMotionPasswordViewController *motionVC = [[SSJMotionPasswordViewController alloc] init];
            motionVC.type = SSJMotionPasswordViewControllerTypeVerification;
            motionVC.finishHandle = ^(UIViewController *controller) {
                if (finish) {
                    finish(YES);
                }
                [controller dismissViewControllerAnimated:YES completion:NULL];
            };
            SSJNavigationController *naviVC = [[SSJNavigationController alloc] initWithRootViewController:motionVC];
            [currentVC presentViewController:naviVC animated:animated completion:NULL];
            
            return;
        } else {
            if (finish) {
                finish(NO);
            }
        }
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
        if (finish) {
            finish(NO);
        }
    }];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
        self.hidesNavigationBarWhenPushed = YES;
        self.verifyFailureTimes = kVerifyFailureTimesLimit;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID]) {
        self.backgroundView.image = [UIImage ssj_compatibleImageNamed:@"motion_background"];
    }
    [self.view addSubview:self.remindLab];
    [self.view addSubview:self.motionView];
    [self loadUserModel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //  禁用手势返回
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_context invalidate];
    _context = nil;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.motionView.center = CGPointMake(self.view.width * 0.5, self.view.height * 0.556);
    
    switch (self.type) {
        case SSJMotionPasswordViewControllerTypeSetting: {
            CGFloat verticalGap = (self.motionView.top - self.miniMotionView.height - self.remindLab.height) * 0.333;
            self.miniMotionView.top = verticalGap;
            self.miniMotionView.centerX = self.view.width * 0.5;
            self.remindLab.top = self.miniMotionView.bottom + verticalGap;
        }   break;
            
        case SSJMotionPasswordViewControllerTypeVerification: {
            CGFloat verticalGap = (self.motionView.top - self.portraitContainer.height - self.remindLab.height) * 0.333;
            self.portraitContainer.top = verticalGap;
            self.portraitContainer.centerX = self.view.width * 0.5;
            self.remindLab.top = self.portraitContainer.bottom + verticalGap;
        }   break;
            
        case SSJMotionPasswordViewControllerTypeTurnoff: {
            self.remindLab.top = self.motionView.top * 0.62;
        }   break;
    }
    
    self.portraitView.frame = CGRectInset(self.portraitContainer.bounds, 3, 3);
}

#pragma mark - SCYMotionEncryptionViewDelegate
- (void)motionView:(SCYMotionEncryptionView *)motionView didSelectKeypads:(NSArray *)keypads {
    if (self.type == SSJMotionPasswordViewControllerTypeSetting && !_needToVerifyOriginalPwd) {
        [self.miniMotionView setKeypads:keypads toStatus:SCYMotionEncryptionCircleLayerStatusCorrect];
    }
}

- (SCYMotionEncryptionCircleLayerStatus)motionView:(SCYMotionEncryptionView *)motionView didFinishSelectKeypads:(NSArray *)keypads {
    switch (self.type) {
        //  设置手势密码
        case SSJMotionPasswordViewControllerTypeSetting: {
            // 验证初试密码
            if (_needToVerifyOriginalPwd) {
                if ([_userItem.motionPWD isEqualToString:[keypads componentsJoinedByString:@","]]) {
                    _needToVerifyOriginalPwd = NO;
                    self.remindLab.text = @"绘制解锁图案";
                    self.remindLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordNormalColor];
                    self.miniMotionView.hidden = NO;
                    self.verifyLoginPwdBtn.hidden = YES;
                    return SCYMotionEncryptionCircleLayerStatusCorrect;
                } else {
                    //  验证失败
                    self.verifyFailureTimes --;
                    self.remindLab.text = [NSString stringWithFormat:@"密码错误，您还可以输入%d次", self.verifyFailureTimes];
                    self.remindLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordErrorColor];
                    
                    //  验证失败次数达到最大限制
                    if (self.verifyFailureTimes == 0) {
                        [self forgetPasswordAction];
                    }
                    return SCYMotionEncryptionCircleLayerStatusError;
                }
            }
            
            [self.miniMotionView setKeypads:keypads toStatus:SCYMotionEncryptionCircleLayerStatusCorrect];
            
            if (!self.password) {
                //  第一次绘制
                if (keypads.count < 3) {
                    [CDAutoHideMessageHUD showMessage:@"至少选择3个"];
                    [self.miniMotionView setKeypads:keypads toStatus:SCYMotionEncryptionCircleLayerStatusError];
                    double delayInSeconds = 0.4;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self.miniMotionView setKeypads:[self.miniMotionView allKeypads] toStatus:SCYMotionEncryptionCircleLayerStatusDefault];
                    });
                    return SCYMotionEncryptionCircleLayerStatusError;
                } else {
                    self.remindLab.text = @"请再次绘制解锁图案";
                    self.remindLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordNormalColor];
                    self.password = [keypads componentsJoinedByString:@","];
                    return SCYMotionEncryptionCircleLayerStatusCorrect;
                }
            } else {
                //  第二次绘制
                if ([self.password isEqualToString:[keypads componentsJoinedByString:@","]]) {
                    //  设置成功，保存手势密码
                    _userItem.motionPWD = self.password;
                    _userItem.motionPWDState = @"1";
                    [SSJUserTableManager saveUserItem:_userItem success:^{
                        if (self.finishHandle) {
                            self.finishHandle(self);
                        } else {
                            [self ssj_backOffAction];
                        }
                    } failure:^(NSError * _Nonnull error) {
                        [SSJAlertViewAdapter showError:error];
                    }];
                    return SCYMotionEncryptionCircleLayerStatusCorrect;
                } else {
                    //  设置失败，重新绘制
                    self.remindLab.text = @"绘制不一致，请重新绘制";
                    self.remindLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordErrorColor];
                    [self.miniMotionView setKeypads:keypads toStatus:SCYMotionEncryptionCircleLayerStatusError];
                    double delayInSeconds = 0.4;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self.miniMotionView setKeypads:[self.miniMotionView allKeypads] toStatus:SCYMotionEncryptionCircleLayerStatusDefault];
                    });
                    self.password = nil;
                    return SCYMotionEncryptionCircleLayerStatusError;
                }
            }
        }
            break;
            
        //  验证手势密码
        case SSJMotionPasswordViewControllerTypeVerification: {
            if ([self.password isEqualToString:[keypads componentsJoinedByString:@","]]) {
                if (self.finishHandle) {
                    self.finishHandle(self);
                } else {
                    [self ssj_backOffAction];
                }
                return SCYMotionEncryptionCircleLayerStatusCorrect;
            } else {
                //  验证失败
                self.verifyFailureTimes --;
                self.remindLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordErrorColor];
                self.remindLab.text = [NSString stringWithFormat:@"密码错误，您还可以输入%d次", self.verifyFailureTimes];
                
                //  验证失败次数达到最大限制
                if (self.verifyFailureTimes == 0) {
                    [self forgetPasswordAction];
                }
                
                return SCYMotionEncryptionCircleLayerStatusError;
            }
        }
            break;
            
        //  关闭手势密码
        case SSJMotionPasswordViewControllerTypeTurnoff: {
            if ([_userItem.motionPWD isEqualToString:[keypads componentsJoinedByString:@","]]) {
                //  验证成功
                _userItem.motionPWDState = @"0";
                [SSJUserTableManager saveUserItem:_userItem success:^{
                    [self goBackAction];
                } failure:^(NSError * _Nonnull error) {
                    [SSJAlertViewAdapter showError:error];
                }];
                return SCYMotionEncryptionCircleLayerStatusCorrect;
            } else {
                //  验证失败
                self.verifyFailureTimes --;
                self.remindLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordErrorColor];
                self.remindLab.text = [NSString stringWithFormat:@"密码错误，您还可以输入%d次", self.verifyFailureTimes];
                
                //  验证失败次数达到最大限制
                if (self.verifyFailureTimes == 0) {
                    [self forgetPasswordAction];
                }
                return SCYMotionEncryptionCircleLayerStatusError;
            }
        }
            break;
    }
}

#pragma mark - Event
// 忘记密码
- (void)forgetPasswordAction {
    if (_userItem.loginPWD.length) {
        [self.passwordAlertView show];
    } else {
        // 注销登录状态、清空用户的手势密码，并跳转至登录页面
        _userItem.motionPWD = @"";
        @weakify(self);
        [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            [SSJUserTableManager saveUserItem:self.userItem success:^{
                [subscriber sendCompleted];
            } failure:^(NSError * _Nonnull error) {
                [subscriber sendError:error];
            }];
            return nil;
        }] then:^RACSignal *{
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                SSJClearLoginInfo();
                [SSJUserTableManager reloadUserIdWithSuccess:^{
                    [subscriber sendCompleted];
                } failure:^(NSError * _Nonnull error) {
                    [subscriber sendError:error];
                }];
                return nil;
            }];
        }] subscribeError:^(NSError *error) {
            [SSJAlertViewAdapter showError:error];
        } completed:^{
            @strongify(self);
            UIViewController *previousVC = [self ssj_previousViewController];
            if ([previousVC isKindOfClass:[SSJLoginViewController class]]) {
                SSJLoginViewController *loginVC = (SSJLoginViewController *)previousVC;
                loginVC.mobileNo = self.userItem.mobileNo;
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                SSJLoginViewController *loginVC = [[SSJLoginViewController alloc] init];
                loginVC.mobileNo = self.userItem.mobileNo;
                loginVC.finishHandle = self.finishHandle;
                loginVC.cancelHandle = self.finishHandle;
                loginVC.backController = self.backController;
                //[self.navigationController setViewControllers:@[loginVC] animated:YES];
                [self.navigationController pushViewController:loginVC animated:YES];
            }
        }];
    }
}

//  切换账号
- (void)changeAccountAction {
    SSJClearLoginInfo();
    [SSJUserTableManager reloadUserIdWithSuccess:^{
        if ([[self ssj_previousViewController] isKindOfClass:[SSJLoginViewController class]]) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            SSJLoginViewController *loginVC = [[SSJLoginViewController alloc] init];
            loginVC.finishHandle = self.finishHandle;
            loginVC.cancelHandle = self.finishHandle;
            loginVC.backController = self.backController;
            [self.navigationController setViewControllers:@[loginVC] animated:YES];
        }
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

//  验证touchID
- (void)verifyTouchIDIfNeeded {
    if (!_context) {
        _context = [[LAContext alloc] init];
        _context.localizedFallbackTitle = @"";
    }
    
    NSError *error = nil;
    if ([_context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [_context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"请按住Home键进行解锁" reply:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                SSJDispatchMainSync(^{
                    if (self.finishHandle) {
                        self.finishHandle(self);
                    } else {
                        [self ssj_backOffAction];
                    }
                });
            }
        }];
    }
}

// 验证登录密码
- (void)verifyLoginPassword {
    NSString *inputPwd = [_passwordAlertView.passwordInput.text ssj_md5HexDigest];
    if ([inputPwd isEqualToString:_userItem.loginPWD]) {
        // 验证登录密码正确
        if (_type == SSJMotionPasswordViewControllerTypeSetting) {
            self.remindLab.text = @"绘制解锁图案";
            self.remindLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordNormalColor];
            _needToVerifyOriginalPwd = NO;
            _miniMotionView.hidden = NO;
            _verifyLoginPwdBtn.hidden = YES;
            [_passwordAlertView dismiss:NULL];
        } else if (_type == SSJMotionPasswordViewControllerTypeTurnoff) {
            _userItem.motionPWDState = @"0";
            [SSJUserTableManager saveUserItem:_userItem success:^{
                [_passwordAlertView dismiss:^(BOOL finished) {
                    [self goBackAction];
                }];
            } failure:^(NSError * _Nonnull error) {
                [SSJAlertViewAdapter showError:error];
            }];
        }
    } else {
        [_passwordAlertView shake];
        _passwordAlertView.passwordInput.text = nil;
        [CDAutoHideMessageHUD showMessage:@"密码输入错误，请重新输入"];
    }
}

- (void)loadUserIcon {
    NSString *iconUrlStr = [_userItem.icon hasPrefix:@"http"] ? _userItem.icon : SSJImageURLWithAPI(_userItem.icon);
    [self.portraitView sd_setImageWithURL:[NSURL URLWithString:iconUrlStr] placeholderImage:[UIImage imageNamed:@"defualt_portrait"] options:(SDWebImageAvoidAutoSetImage | SDWebImageAllowInvalidSSLCertificates) completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image && cacheType == SDImageCacheTypeNone) {
            [UIView animateWithDuration:0.25 animations:^{
                self.portraitView.image = image;
            }];
        } else {
            self.portraitView.image = image;
        }
    }];
}
- (void)loadUserModel {
    switch (self.type) {
        case SSJMotionPasswordViewControllerTypeSetting: {
            [SSJUserTableManager queryProperty:@[@"userId", @"loginPWD", @"motionPWD", @"motionTrackState"] forUserId:SSJUSERID() success:^(SSJUserItem * _Nonnull userModel) {
                _userItem = userModel;
                [self loadUserIcon];
                self.motionView.showStroke = [_userItem.motionTrackState boolValue];
                if ([_userItem.motionTrackState boolValue]) {
                    [self.view addSubview:self.miniMotionView];
                }
                
                if (_userItem.motionPWD.length) {
                    self.needToVerifyOriginalPwd = YES;
                    self.miniMotionView.hidden = YES;
                    self.remindLab.text = @"请输入原手势密码";
                    [self.view addSubview:self.verifyLoginPwdBtn];
                } else {
                    self.remindLab.text = @"绘制解锁图案";
                }
            } failure:^(NSError * _Nonnull error) {
                [SSJAlertViewAdapter showError:error];
            }];
        }
            break;
            
        case SSJMotionPasswordViewControllerTypeVerification: {
            //  查询手势密码
            [SSJUserTableManager queryProperty:@[@"userId", @"motionPWD", @"icon", @"mobileNo", @"fingerPrintState", @"motionTrackState"] forUserId:SSJUSERID() success:^(SSJUserItem * _Nonnull userModel) {
                _userItem = userModel;
                [self loadUserIcon];
                self.password = _userItem.motionPWD;
                self.motionView.showStroke = [_userItem.motionTrackState boolValue];
                
                [self.view addSubview:self.portraitContainer];
                [self.view addSubview:self.forgetPwdBtn];
                [self.view addSubview:self.changeAccountBtn];
                self.remindLab.text = @"请输入手势密码";
                
                if ([_userItem.fingerPrintState boolValue]) {
                    [self verifyTouchIDIfNeeded];
                }
            } failure:^(NSError * _Nonnull error) {
                [SSJAlertViewAdapter showError:error];
            }];
        }
            break;
            
        case SSJMotionPasswordViewControllerTypeTurnoff: {
            [SSJUserTableManager queryProperty:@[@"userId", @"loginPWD", @"motionPWD", @"motionTrackState"] forUserId:SSJUSERID() success:^(SSJUserItem * _Nonnull userModel) {
                _userItem = userModel;
                [self loadUserIcon];
                self.remindLab.text = @"请输入原手势密码";
                self.motionView.showStroke = [_userItem.motionTrackState boolValue];
                [self.view addSubview:self.verifyLoginPwdBtn];
            } failure:^(NSError * _Nonnull error) {
                [SSJAlertViewAdapter showError:error];
            }];
        }
            break;
    }
}

#pragma mark - Getter
- (UIView *)portraitContainer {
    if (!_portraitContainer) {
        _portraitContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 68, 68)];
        _portraitContainer.clipsToBounds = YES;
        _portraitContainer.layer.cornerRadius = 34;
        _portraitContainer.layer.borderWidth = 1;
        _portraitContainer.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordNormalColor].CGColor;
        [_portraitContainer addSubview:self.portraitView];
    }
    return _portraitContainer;
}

- (UIImageView *)portraitView {
    if (!_portraitView) {
        _portraitView = [[UIImageView alloc] init];
    }
    return _portraitView;
}

- (UILabel *)remindLab {
    if (!_remindLab) {
        _remindLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.height * 0.338, self.view.width, 20)];
        _remindLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordNormalColor];
        _remindLab.textAlignment = NSTextAlignmentCenter;
        _remindLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
    }
    return _remindLab;
}

- (UIButton *)verifyLoginPwdBtn {
    if (!_verifyLoginPwdBtn) {
        _verifyLoginPwdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _verifyLoginPwdBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
        [_verifyLoginPwdBtn setTitle:@"忘记手势？可验证登录密码" forState:UIControlStateNormal];
        if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
            [_verifyLoginPwdBtn setTitleColor:[[UIColor ssj_colorWithHex:@"#eb4a64"] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
        } else {
            [_verifyLoginPwdBtn setTitleColor:[[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordNormalColor] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
        }
        [_verifyLoginPwdBtn addTarget:self action:@selector(forgetPasswordAction) forControlEvents:UIControlEventTouchUpInside];
        [_verifyLoginPwdBtn sizeToFit];
        _verifyLoginPwdBtn.centerX = self.view.width * 0.5;
        _verifyLoginPwdBtn.bottom = self.view.height - 30;
    }
    return _verifyLoginPwdBtn;
}

- (UIButton *)forgetPwdBtn {
    if (!_forgetPwdBtn) {
        _forgetPwdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _forgetPwdBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
        [_forgetPwdBtn setTitle:@"忘记手势密码" forState:UIControlStateNormal];
        if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
            [_forgetPwdBtn setTitleColor:[[UIColor ssj_colorWithHex:@"#eb4a64"] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
        } else {
            [_forgetPwdBtn setTitleColor:[[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordNormalColor] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
        }

        [_forgetPwdBtn addTarget:self action:@selector(forgetPasswordAction) forControlEvents:UIControlEventTouchUpInside];
        [_forgetPwdBtn sizeToFit];
        _forgetPwdBtn.leftBottom = CGPointMake(15, self.view.height - 30);
    }
    return _forgetPwdBtn;
}

- (UIButton *)changeAccountBtn {
    if (!_changeAccountBtn) {
        _changeAccountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeAccountBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
        [_changeAccountBtn setTitle:@"使用其它账号登录" forState:UIControlStateNormal];
        if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
            [_changeAccountBtn setTitleColor:[[UIColor ssj_colorWithHex:@"#eb4a64"] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
        } else {
            [_changeAccountBtn setTitleColor:[[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordNormalColor] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
        }
        [_changeAccountBtn addTarget:self action:@selector(changeAccountAction) forControlEvents:UIControlEventTouchUpInside];
        [_changeAccountBtn sizeToFit];
        _changeAccountBtn.rightBottom = CGPointMake(self.view.width - 15, self.view.height - 30);
    }
    return _changeAccountBtn;
}

- (SCYMotionEncryptionView *)miniMotionView {
    if (!_miniMotionView) {
        _miniMotionView = [[SCYMotionEncryptionView alloc] initWithFrame:CGRectMake(0, 0, 38, 38)];
        _miniMotionView.userInteractionEnabled = NO;
        _miniMotionView.circleRadius = 5;
        _miniMotionView.imageInfo = @{@(SCYMotionEncryptionCircleLayerStatusDefault):[UIImage ssj_themeImageWithName:@"motion_circle_default"],
                                      @(SCYMotionEncryptionCircleLayerStatusCorrect):[UIImage ssj_themeImageWithName:@"motion_circle_correct"],
                                      @(SCYMotionEncryptionCircleLayerStatusError):[UIImage ssj_themeImageWithName:@"motion_circle_error"]};
    }
    return _miniMotionView;
}

- (SCYMotionEncryptionView *)motionView {
    if (!_motionView) {
        _motionView = [[SCYMotionEncryptionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width * 0.8, self.view.width * 0.8)];
        _motionView.delegate = self;
        _motionView.showStroke = YES;
//        SSJThemeModel *model = SSJ_CURRENT_THEME;
        _motionView.strokeColorInfo = @{@(SCYMotionEncryptionCircleLayerStatusDefault):[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordHighlightedColor],
                                        @(SCYMotionEncryptionCircleLayerStatusCorrect):[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordHighlightedColor],
                                        @(SCYMotionEncryptionCircleLayerStatusError):[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordErrorColor]};
//        _motionView.strokeColorInfo = @{@(SCYMotionEncryptionCircleLayerStatusDefault):[UIColor ssj_colorWithHex:@"#ffdb01"],
//                                        @(SCYMotionEncryptionCircleLayerStatusCorrect):[UIColor ssj_colorWithHex:@"#ffdb01"],
//                                        @(SCYMotionEncryptionCircleLayerStatusError):[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.motionPasswordErrorColor]};

        _motionView.circleRadius = self.view.width * 0.1;
        _motionView.imageInfo = @{@(SCYMotionEncryptionCircleLayerStatusDefault):[UIImage ssj_themeImageWithName:@"motion_circle_default"],
                                  @(SCYMotionEncryptionCircleLayerStatusCorrect):[UIImage ssj_themeImageWithName:@"motion_circle_correct"],
                                  @(SCYMotionEncryptionCircleLayerStatusError):[UIImage ssj_themeImageWithName:@"motion_circle_error"]};
    }
    return _motionView;
}

- (SSJMotionPasswordLoginPasswordAlertView *)passwordAlertView {
    if (!_passwordAlertView) {
        _passwordAlertView = [SSJMotionPasswordLoginPasswordAlertView alertView];
        [_passwordAlertView.sureButton addTarget:self action:@selector(verifyLoginPassword) forControlEvents:UIControlEventTouchUpInside];
    }
    return _passwordAlertView;
}

@end
