//
//  SSJMotionPasswordViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/3/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMotionPasswordViewController.h"
#import "SSJLoginViewController.h"
#import "SCYMotionEncryptionView.h"
#import "SSJUserTableManager.h"
#import "UIImageView+CornerRadius.h"
#import <LocalAuthentication/LocalAuthentication.h>

//  验证密码最多错误次数
static const int kVerifyFailureTimesLimit = 5;

@interface SSJMotionPasswordViewController () <SCYMotionEncryptionViewDelegate>

@property (nonatomic, strong) UIImageView *backgroundView;

@property (nonatomic, strong) UIView *portraitView;

@property (nonatomic, strong) UILabel *remindLab;

@property (nonatomic, strong) UIButton *forgetPwdBtn;

@property (nonatomic, strong) UIButton *changeAccountBtn;

@property (nonatomic, strong) SCYMotionEncryptionView *miniMotionView;

@property (nonatomic, strong) SCYMotionEncryptionView *motionView;

@property (nonatomic, copy) NSString *password;

@property (nonatomic, copy) NSString *iconUrl;

@property (nonatomic) int verifyFailureTimes;

@end

@implementation SSJMotionPasswordViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
        self.verifyFailureTimes = kVerifyFailureTimesLimit;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.remindLab];
    [self.view addSubview:self.motionView];
    
    switch (self.type) {
        case SSJMotionPasswordViewControllerTypeSetting: {
            [self.view addSubview:self.miniMotionView];
            self.remindLab.text = @"绘制解锁图案";
        }   break;
            
        case SSJMotionPasswordViewControllerTypeVerification: {
            //  查询手势密码
            SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"motionPWD", @"icon"] forUserId:SSJUSERID()];
            self.password = userItem.motionPWD;
            self.iconUrl = [userItem.icon hasPrefix:@"http"] ? userItem.icon : SSJImageURLWithAPI(userItem.icon);
            
            [self.view addSubview:self.portraitView];
            [self.view addSubview:self.forgetPwdBtn];
            [self.view addSubview:self.changeAccountBtn];
            self.remindLab.text = @"请输入手势密码";
            
            [self verifyTouchIDIfNeeded];
            
        }   break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //  禁用手势返回
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
            CGFloat verticalGap = (self.motionView.top - self.portraitView.height - self.remindLab.height) * 0.333;
            self.portraitView.top = verticalGap;
            self.portraitView.centerX = self.view.width * 0.5;
            self.remindLab.top = self.portraitView.bottom + verticalGap;
        }   break;
    }
}

#pragma mark - SCYMotionEncryptionViewDelegate
- (void)motionView:(SCYMotionEncryptionView *)motionView didSelectKeypads:(NSArray *)keypads {
    if (self.type == SSJMotionPasswordViewControllerTypeSetting) {
        [self.miniMotionView setKeypads:keypads toStatus:SCYMotionEncryptionCircleLayerStatusCorrect];
    }
}

- (SCYMotionEncryptionCircleLayerStatus)motionView:(SCYMotionEncryptionView *)motionView didFinishSelectKeypads:(NSArray *)keypads {
    switch (self.type) {
        //  设置手势密码
        case SSJMotionPasswordViewControllerTypeSetting: {
            [self.miniMotionView setKeypads:keypads toStatus:SCYMotionEncryptionCircleLayerStatusCorrect];
            if (self.password) {
                //  设置成功
                if ([self.password isEqualToString:[keypads componentsJoinedByString:@","]]) {
                    //  保存手势密码
                    SSJUserItem *userItem = [[SSJUserItem alloc] init];
                    userItem.userId = SSJUSERID();
                    userItem.motionPWD = self.password;
                    userItem.motionPWDState = @"1";
                    [SSJUserTableManager saveUserItem:userItem];
                    
                    if (self.finishHandle) {
                        self.finishHandle(self);
                    } else {
                        [self ssj_backOffAction];
                    }
                    return SCYMotionEncryptionCircleLayerStatusCorrect;
                }
                
                //  设置失败，重新绘制
                self.remindLab.text = @"绘制解锁图案";
                [self.miniMotionView setKeypads:keypads toStatus:SCYMotionEncryptionCircleLayerStatusError];
                double delayInSeconds = 0.4;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self.miniMotionView setKeypads:[self.miniMotionView allKeypads] toStatus:SCYMotionEncryptionCircleLayerStatusDefault];
                });
                self.password = nil;
                return SCYMotionEncryptionCircleLayerStatusError;
            }
            
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
            }
            
            self.remindLab.text = @"请再次绘制解锁图案";
            self.password = [keypads componentsJoinedByString:@","];
            return SCYMotionEncryptionCircleLayerStatusCorrect;
        }
            break;
            
        //  验证手势密码
        case SSJMotionPasswordViewControllerTypeVerification: {
            if ([self.password isEqualToString:[keypads componentsJoinedByString:@","]]) {
                //  验证成功
                if (self.finishHandle) {
                    self.finishHandle(self);
                } else {
                    [self ssj_backOffAction];
                }
                return SCYMotionEncryptionCircleLayerStatusCorrect;
            } else {
                //  验证失败
                self.verifyFailureTimes --;
                self.remindLab.textColor = [UIColor ssj_colorWithHex:@"#ff7139"];
                self.remindLab.text = [NSString stringWithFormat:@"密码错误，您还可以输入%d次", self.verifyFailureTimes];
                
                //  验证失败次数达到最大限制
                if (self.verifyFailureTimes <= 0) {
                    [self forgetPasswordAction];
                }
                
                return SCYMotionEncryptionCircleLayerStatusError;
            }
        }
            break;
    }
}

#pragma mark - Event
//  忘记手势密码
- (void)forgetPasswordAction {
    // 注销登录状态、清空用户的手势密码，并跳转至登录页面
    SSJUserItem *userItem = [[SSJUserItem alloc] init];
    userItem.userId = SSJUSERID();
    userItem.motionPWD = @"";
    [SSJUserTableManager saveUserItem:userItem];
    
    userItem = [SSJUserTableManager queryProperty:@[@"mobileNo"] forUserId:SSJUSERID()];
    
    UIViewController *previousVC = [self ssj_previousViewController];
    if ([previousVC isKindOfClass:[SSJLoginViewController class]]) {
        SSJLoginViewController *loginVC = (SSJLoginViewController *)previousVC;
        loginVC.mobileNo = userItem.mobileNo;
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        SSJLoginViewController *loginVC = [[SSJLoginViewController alloc] init];
        loginVC.mobileNo = userItem.mobileNo;
        [self.navigationController setViewControllers:@[loginVC] animated:YES];
    }
    
    SSJClearLoginInfo();
    [SSJUserTableManager reloadUserIdWithError:nil];
}

//  切换账号
- (void)changeAccountAction {
    if ([[self ssj_previousViewController] isKindOfClass:[SSJLoginViewController class]]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        SSJLoginViewController *loginVC = [[SSJLoginViewController alloc] init];
        [self.navigationController setViewControllers:@[loginVC] animated:YES];
    }
}

//  验证touchID
- (void)verifyTouchIDIfNeeded {
    LAContext *context = [[LAContext alloc] init];
    context.localizedFallbackTitle = @"";
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"请按住Home键进行解锁" reply:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                if (self.finishHandle) {
                    self.finishHandle(self);
                } else {
                    [self ssj_backOffAction];
                }
            }
        }];
    }
}

#pragma mark - Getter
- (UIImageView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"motion_background.jpg"]];
        _backgroundView.frame = self.view.bounds;
    }
    return _backgroundView;
}

- (UIView *)portraitView {
    if (!_portraitView) {
        _portraitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 68, 68)];
        _portraitView.clipsToBounds = YES;
        _portraitView.layer.cornerRadius = 34;
        _portraitView.layer.borderWidth = 1;
        _portraitView.layer.borderColor = [UIColor whiteColor].CGColor;
        
        CGRect imageFrame = CGRectInset(_portraitView.bounds, 1, 1);
        UIImageView *imageView = [[UIImageView alloc] initWithCornerRadiusAdvance:CGRectGetWidth(imageFrame) * 0.5 rectCornerType:UIRectCornerAllCorners];
        imageView.frame = imageFrame;
        [imageView sd_setImageWithURL:[NSURL URLWithString:self.iconUrl] placeholderImage:[UIImage imageNamed:@"defualt_portrait"] options:SDWebImageAvoidAutoSetImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image && cacheType == SDImageCacheTypeNone) {
                [UIView animateWithDuration:0.25 animations:^{
                    imageView.image = image;
                }];
            } else {
                imageView.image = image;
            }
        }];
        [_portraitView addSubview:imageView];
    }
    return _portraitView;
}

- (UILabel *)remindLab {
    if (!_remindLab) {
        _remindLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.height * 0.338, self.view.width, 20)];
        _remindLab.textColor = [UIColor whiteColor];
        _remindLab.textAlignment = NSTextAlignmentCenter;
        _remindLab.font = [UIFont systemFontOfSize:18];
    }
    return _remindLab;
}

- (UIButton *)forgetPwdBtn {
    if (!_forgetPwdBtn) {
        _forgetPwdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _forgetPwdBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_forgetPwdBtn setTitle:@"忘记手势密码" forState:UIControlStateNormal];
        [_forgetPwdBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_forgetPwdBtn addTarget:self action:@selector(forgetPasswordAction) forControlEvents:UIControlEventTouchUpInside];
        [_forgetPwdBtn sizeToFit];
        _forgetPwdBtn.leftBottom = CGPointMake(15, self.view.height - 30);
    }
    return _forgetPwdBtn;
}

- (UIButton *)changeAccountBtn {
    if (!_changeAccountBtn) {
        _changeAccountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeAccountBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_changeAccountBtn setTitle:@"使用其它账号登录" forState:UIControlStateNormal];
        [_changeAccountBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_changeAccountBtn addTarget:self action:@selector(changeAccountBtn) forControlEvents:UIControlEventTouchUpInside];
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
        _miniMotionView.imageInfo = @{@(SCYMotionEncryptionCircleLayerStatusDefault):[UIImage ssj_compatibleImageNamed:@"motion_circle_default"],
                                      @(SCYMotionEncryptionCircleLayerStatusCorrect):[UIImage ssj_compatibleImageNamed:@"motion_circle_correct"],
                                      @(SCYMotionEncryptionCircleLayerStatusError):[UIImage ssj_compatibleImageNamed:@"motion_circle_error"]};
    }
    return _miniMotionView;
}

- (SCYMotionEncryptionView *)motionView {
    if (!_motionView) {
        _motionView = [[SCYMotionEncryptionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width * 0.8, self.view.width * 0.8)];
        _motionView.delegate = self;
        _motionView.showStroke = YES;
        _motionView.strokeColorInfo = @{@(SCYMotionEncryptionCircleLayerStatusDefault):[UIColor ssj_colorWithHex:@"#ffdb01"],
                                        @(SCYMotionEncryptionCircleLayerStatusCorrect):[UIColor ssj_colorWithHex:@"#ffdb01"],
                                        @(SCYMotionEncryptionCircleLayerStatusError):[UIColor ssj_colorWithHex:@"#ff7139"]};
        _motionView.circleRadius = self.view.width * 0.1;
        _motionView.imageInfo = @{@(SCYMotionEncryptionCircleLayerStatusDefault):[UIImage ssj_compatibleImageNamed:@"motion_circle_default"],
                                  @(SCYMotionEncryptionCircleLayerStatusCorrect):[UIImage ssj_compatibleImageNamed:@"motion_circle_correct"],
                                  @(SCYMotionEncryptionCircleLayerStatusError):[UIImage ssj_compatibleImageNamed:@"motion_circle_error"]};
    }
    return _motionView;
}

@end
