//
//  SSJChangeMobileNoFirstViewController.m
//  SuiShouJi
//
//  Created by old lang on 2017/6/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJChangeMobileNoFirstViewController.h"
#import "SSJChangeMobileNoSecondViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "SSJChangeMobileNoStepView.h"
#import "SSJVerifCodeField.h"
#import "SSJUserTableManager.h"
#import "SSJLoginVerifyPhoneNumViewModel.h"
#import "SSJEncourageService.h"

@interface SSJChangeMobileNoFirstViewController ()

@property (nonatomic, copy) NSString *mobileNo;

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

@property (nonatomic, strong) SSJChangeMobileNoStepView *stepView;

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *descLab;

@property (nonatomic, strong) SSJVerifCodeField *authCodeField;

@property (nonatomic, strong) UIButton *nextBtn;

@property (nonatomic, strong) UIButton *changeWayBtn;

@property (nonatomic, strong) SSJLoginVerifyPhoneNumViewModel *viewModel;

@property (nonatomic, strong) SSJBaseNetworkService *checkAuthCodeService;

@property (nonatomic, strong) SSJEncourageService *getQQGroupService;

@end

@implementation SSJChangeMobileNoFirstViewController

#pragma mark - Lifecycle
- (void)dealloc {
    
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"验证原手机号";
        self.appliesTheme = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadMobileNo:^{
        [self setUpViews];
        [self setupBindings];
        [self updateAppearance];
//        [self.authCodeField getVerifCode];
        [self.view setNeedsUpdateConstraints];
    }];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.checkAuthCodeService cancel];
    [self.getQQGroupService cancel];
}

- (void)updateViewConstraints {
    [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(SSJ_NAVIBAR_BOTTOM, 0, 0, 0));
    }];
    [self.stepView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView).offset(30);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    [self.icon mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.stepView.mas_bottom).offset(30);
        make.centerX.mas_equalTo(self.scrollView);
        make.size.mas_equalTo(self.icon.image.size);
    }];
    [self.descLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon.mas_bottom).offset(30);
        make.centerX.mas_equalTo(self.scrollView);
        make.height.mas_equalTo(22);
    }];
    [self.authCodeField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.descLab.mas_bottom).offset(28);
        make.left.mas_equalTo(self.scrollView).offset(15);
        make.right.mas_equalTo(self.scrollView).offset(-15);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    [self.nextBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.authCodeField.mas_bottom).offset(40);
        make.left.mas_equalTo(self.scrollView).offset(15);
        make.right.mas_equalTo(self.scrollView).offset(-15);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    [self.changeWayBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nextBtn.mas_bottom).offset(0);
        make.left.mas_equalTo(self.scrollView).offset(15);
        make.size.mas_equalTo(CGSizeMake(132, 38));
        make.bottom.mas_equalTo(self.scrollView).offset(-20);
    }];
    [super updateViewConstraints];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

#pragma mark - Private
- (void)loadMobileNo:(void(^)())completion {
    [self.view ssj_showLoadingIndicator];
    [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
        [self.view ssj_hideLoadingIndicator];
        self.mobileNo = userItem.mobileNo;
        if (completion) {
            completion();
        }
    } failure:^(NSError * _Nonnull error) {
        [self.view ssj_hideLoadingIndicator];
//        [SSJAlertViewAdapter showError:error];
        [CDAutoHideMessageHUD showMessage:error.localizedDescription.length?error.localizedDescription:SSJ_ERROR_MESSAGE];
    }];
}

- (void)updateAppearance {
    [self.authCodeField defaultAppearanceTheme];
    
    UIColor *normalColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].buttonColor];
    [self.nextBtn ssj_setBackgroundColor:normalColor forState:UIControlStateNormal];
    
    UIColor *disableColor = [normalColor colorWithAlphaComponent:SSJButtonDisableAlpha];
    [self.nextBtn ssj_setBackgroundColor:disableColor forState:UIControlStateDisabled];
    
    UIColor *mainColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].mainColor];
    self.descLab.textColor = mainColor;
    [self.changeWayBtn setTitleColor:mainColor forState:UIControlStateNormal];
}

- (void)setUpViews {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.stepView];
    [self.scrollView addSubview:self.icon];
    [self.scrollView addSubview:self.descLab];
    [self.scrollView addSubview:self.authCodeField];
    [self.scrollView addSubview:self.nextBtn];
    [self.scrollView addSubview:self.changeWayBtn];
}

- (void)setupBindings {
    self.viewModel.phoneNum = self.mobileNo;
    self.authCodeField.viewModel = self.viewModel;
    @weakify(self);
    RAC(self.nextBtn, enabled) = [RACSignal merge:@[[[self.authCodeField rac_textSignal] map:^id(NSString *authCode) {
        @strongify(self);
        return @(self.authCodeField.text.length >= 6 && self.checkAuthCodeService.state != SSJNetworkServiceStateLoading);
    }], [RACObserve(self.checkAuthCodeService, state) map:^id(id value) {
        return @(self.authCodeField.text.length >= 6 && self.checkAuthCodeService.state != SSJNetworkServiceStateLoading);
    }]]];
    
    RAC(self.descLab,text) = [RACObserve(self.authCodeField, getAuthCodeState) map:^id(NSNumber *value) {
        @strongify(self);
        SSJGetVerifCodeState state = [value integerValue];
        NSString *ciphertext = self.mobileNo;
        if (self.mobileNo.length >= 7) {
            ciphertext = [self.mobileNo stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        }
        if (state == SSJGetVerifCodeStateSent) {
            return [NSString stringWithFormat:@"验证码已发送至：%@", ciphertext];
        } else if (state == SSJGetVerifCodeStateReady) {
            return [NSString stringWithFormat:@"将验证码发送至：%@", ciphertext];
        } else {
            return nil;
        }
    }];
}

- (void)checkAuthCode {
    NSDictionary *params = @{@"cmobileNo":self.mobileNo,
                             @"yzm":self.authCodeField.text,
                             @"mobileType":@2};
    [self.checkAuthCodeService request:@"/chargebook/user/check_sms.go" params:params success:^(SSJBaseNetworkService * _Nonnull service) {
        if ([service.returnCode isEqualToString:@"1"]) {
            [self.authCodeField resignFirstResponder];
            SSJChangeMobileNoSecondViewController *secondVC = [[SSJChangeMobileNoSecondViewController alloc] init];
            [self.navigationController pushViewController:secondVC animated:YES];
        } else {
            [CDAutoHideMessageHUD showMessage:service.desc.length?service.desc:SSJ_ERROR_MESSAGE];
        }
        
    } failure:^(SSJBaseNetworkService * _Nonnull service) {
//        [SSJAlertViewAdapter showError:service.error];
        [CDAutoHideMessageHUD showMessage:service.desc.length?service.desc:SSJ_ERROR_MESSAGE];
    }];
}

- (void)openQQ {
    [self.getQQGroupService requestWithSuccess:^(SSJEncourageService * _Nonnull service) {
        SSJJoinQQGroup(service.qqgroup, service.qqgroupId);
    } failure:^(SSJEncourageService * _Nonnull service) {
//        [SSJAlertViewAdapter showError:service.error];
        [CDAutoHideMessageHUD showMessage:service.desc.length?service.desc:SSJ_ERROR_MESSAGE];
    }];
}

#pragma mark - Lazyloading
- (TPKeyboardAvoidingScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] init];
    }
    return _scrollView;
}

- (SSJChangeMobileNoStepView *)stepView {
    if (!_stepView) {
        _stepView = [[SSJChangeMobileNoStepView alloc] initWithStep:3];
        _stepView.currentStep = 1;
    }
    return _stepView;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bind_No_SMS"]];
    }
    return _icon;
}

- (UILabel *)descLab {
    if (!_descLab) {
        _descLab = [[UILabel alloc] init];
        _descLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _descLab;
}

- (SSJVerifCodeField *)authCodeField {
    if (!_authCodeField) {
        _authCodeField = [[SSJVerifCodeField alloc] initWithGetCodeType:SSJRegistAndForgetPasswordTypeForgetPassword];
    }
    return _authCodeField;
}

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextBtn.clipsToBounds = YES;
        _nextBtn.layer.cornerRadius = 6;
        _nextBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[_nextBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [self checkAuthCode];
        }];
    }
    return _nextBtn;
}

- (UIButton *)changeWayBtn {
    if (!_changeWayBtn) {
        _changeWayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeWayBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [_changeWayBtn setTitle:@"手机号停用，快速反馈" forState:UIControlStateNormal];
        [[_changeWayBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [self openQQ];
        }];
    }
    return _changeWayBtn;
}

- (SSJLoginVerifyPhoneNumViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[SSJLoginVerifyPhoneNumViewModel alloc] init];
    }
    return _viewModel;
}

- (SSJBaseNetworkService *)checkAuthCodeService {
    if (!_checkAuthCodeService) {
        _checkAuthCodeService = [[SSJBaseNetworkService alloc] init];
        _checkAuthCodeService.showLodingIndicator = YES;
    }
    return _checkAuthCodeService;
}

- (SSJEncourageService *)getQQGroupService {
    if (!_getQQGroupService) {
        _getQQGroupService = [[SSJEncourageService alloc] init];
        _getQQGroupService.showLodingIndicator = YES;
    }
    return _getQQGroupService;
}

@end
