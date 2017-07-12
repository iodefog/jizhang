//
//  SSJFingerprintPWDViewController.m
//  SuiShouJi
//
//  Created by old lang on 2017/6/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFingerprintPWDViewController.h"
#import "SSJNavigationController.h"
#import "SSJLoginVerifyPhoneViewController.h"
#import "SSJUserTableManager.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface SSJFingerprintPWDViewController ()

@property (nonatomic, strong) UIImageView *userIcon;

@property (nonatomic, strong) UILabel *lab;

@property (nonatomic, strong) UIButton *fingerBtn;

@property (nonatomic, strong) UIButton *changeAccountBtn;

@end

@implementation SSJFingerprintPWDViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.appliesTheme = NO;
        self.hidesNavigationBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.userIcon];
    [self.view addSubview:self.lab];
    [self.view addSubview:self.fingerBtn];
    [self.view addSubview:self.changeAccountBtn];
    [self.view setNeedsUpdateConstraints];
    [self loadUserIcon];
    [self verifyTouchIDIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_context invalidate];
    _context = nil;
}

- (void)updateViewConstraints {
    [self.userIcon mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(66, 66));
        make.top.mas_equalTo(66);
        make.centerX.mas_equalTo(self.view);
    }];
    [self.lab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userIcon.mas_bottom).offset(15);
        make.centerX.mas_equalTo(self.view);
        make.height.mas_equalTo(22);
    }];
    [self.fingerBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 60));
        make.center.mas_equalTo(self.view);
    }];
    [self.changeAccountBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(96, 22));
        make.bottom.mas_equalTo(self.view).offset(-30);
        make.centerX.mas_equalTo(self.view);
    }];
    [super updateViewConstraints];
}

#pragma mark - Private
- (void)loadUserIcon {
    [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
        NSString *iconUrlStr = [userItem.icon hasPrefix:@"http"] ? userItem.icon : SSJImageURLWithAPI(userItem.icon);
        UIImage *placeholder = [UIImage imageNamed:@"defualt_portrait"];
        [self.userIcon sd_setImageWithURL:[NSURL URLWithString:iconUrlStr] placeholderImage:placeholder options:(SDWebImageAvoidAutoSetImage | SDWebImageAllowInvalidSSLCertificates) completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                [UIView animateWithDuration:0.25 animations:^{
                    self.userIcon.image = image;
                }];
            }
        }];
    } failure:NULL];
}

// 验证touchID
- (void)verifyTouchIDIfNeeded {
    [_context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"请按住Home键进行解锁" reply:^(BOOL success, NSError * _Nullable error) {
        BOOL touchIDChanged = NO;
        if (SSJEvaluatedPolicyDomainState() && _context.evaluatedPolicyDomainState) {
            touchIDChanged = ![_context.evaluatedPolicyDomainState isEqualToData:SSJEvaluatedPolicyDomainState()];
        }
        if (success && !touchIDChanged) {
            SSJDispatchMainSync(^{
                if (self.finishHandle) {
                    self.finishHandle(self);
                }
                [self dismissViewControllerAnimated:YES completion:NULL];
            });
        } else {
            if (touchIDChanged || error.code == LAErrorTouchIDNotEnrolled) {
                [self relogin:^{
                    [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"您的指纹信息发生变更，请重新登录" action:[SSJAlertViewAction actionWithTitle:@"知道了" handler:NULL], nil];
                } finishLoginProcess:^{
                    // 登录成功后保存新的指纹数据
                    LAContext *context = [[LAContext alloc] init];
                    context.localizedFallbackTitle = @"";
                    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
                        SSJUpdateEvaluatedPolicyDomainState(context.evaluatedPolicyDomainState);
                    }
                }];
            }
        }
    }];
}

// 重新登录
- (void)relogin:(void(^)())completion finishLoginProcess:(void(^)())finishHandle {
    [SSJUserTableManager reloadUserIdWithSuccess:^{
        SSJLoginVerifyPhoneViewController *loginVC = [[SSJLoginVerifyPhoneViewController alloc] init];
        loginVC.finishHandle = ^(UIViewController *controller) {
            if (finishHandle) {
                finishHandle();
            }
            if (self.finishHandle) {
                self.finishHandle(controller);
            }
        };
        [self.navigationController setViewControllers:@[loginVC] animated:YES];
        if (completion) {
            completion();
        }
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

#pragma mark - Lazyloading
- (UIImageView *)userIcon {
    if (!_userIcon) {
        _userIcon = [[UIImageView alloc] init];
        _userIcon.clipsToBounds = YES;
        _userIcon.layer.borderWidth = 2;
        _userIcon.layer.cornerRadius = 33;
        _userIcon.layer.borderColor = RGBCOLOR(217, 217, 217).CGColor;
    }
    return _userIcon;
}

- (UILabel *)lab {
    if (!_lab) {
        _lab = [[UILabel alloc] init];
        _lab.text = @"欢迎回来";
        _lab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _lab;
}

- (UIButton *)fingerBtn {
    if (!_fingerBtn) {
        _fingerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fingerBtn setImage:[UIImage imageNamed:@"fingerprint"] forState:UIControlStateNormal];
        [_fingerBtn addTarget:self action:@selector(verifyTouchIDIfNeeded) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fingerBtn;
}

- (UIButton *)changeAccountBtn {
    if (!_changeAccountBtn) {
        _changeAccountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeAccountBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_changeAccountBtn setTitle:@"登陆其它账号" forState:UIControlStateNormal];
        [_changeAccountBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        @weakify(self);
        [[_changeAccountBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self relogin:NULL finishLoginProcess:NULL];
        }];
    }
    return _changeAccountBtn;
}

@end
