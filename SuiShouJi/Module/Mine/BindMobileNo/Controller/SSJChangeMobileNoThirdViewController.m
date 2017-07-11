//
//  SSJChangeMobileNoThirdViewController.m
//  SuiShouJi
//
//  Created by old lang on 2017/6/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJChangeMobileNoThirdViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "SSJChangeMobileNoStepView.h"
#import "SSJVerifCodeField.h"
#import "SSJInviteCodeJoinSuccessView.h"
#import "SSJBindMobileNoNetworkService.h"
#import "SSJEncourageService.h"
#import "SSJUserTableManager.h"

@interface SSJChangeMobileNoThirdViewController ()

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

@property (nonatomic, strong) SSJChangeMobileNoStepView *stepView;

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *descLab;

@property (nonatomic, strong) SSJVerifCodeField *authCodeField;

@property (nonatomic, strong) UIButton *nextBtn;

@property (nonatomic, strong) UIButton *changeWayBtn;

@property (nonatomic, strong) SSJInviteCodeJoinSuccessView *successAlertView;

@property (nonatomic, strong) SSJLoginVerifyPhoneNumViewModel *viewModel;

@property (nonatomic, strong) SSJBindMobileNoNetworkService *service;

@property (nonatomic, strong) SSJEncourageService *getQQGroupService;

@end

@implementation SSJChangeMobileNoThirdViewController

- (void)dealloc {
    
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"绑定新手机号";
        self.appliesTheme = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self setupBindings];
    [self updateAppearance];
//    [self.authCodeField getVerifCode];
    [self.view setNeedsUpdateConstraints];
    self.view.backgroundColor = [UIColor whiteColor];
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
        make.bottom.mas_equalTo(self.scrollView).offset(-20);
    }];
    [self.changeWayBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nextBtn);
        make.top.mas_equalTo(self.nextBtn.mas_bottom).offset(10);
        make.width.greaterThanOrEqualTo(0);

    }];
    [super updateViewConstraints];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

#pragma mark - Private
- (void)updateAppearance {
    [self.authCodeField defaultAppearanceTheme];
    
    UIColor *mainColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].mainColor];
    self.descLab.textColor = mainColor;
    
    UIColor *normalColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].buttonColor];
    [self.nextBtn ssj_setBackgroundColor:normalColor forState:UIControlStateNormal];
    
    UIColor *disableColor = [normalColor colorWithAlphaComponent:SSJButtonDisableAlpha];
    [self.nextBtn ssj_setBackgroundColor:disableColor forState:UIControlStateDisabled];
}

- (void)openQQ {
    //    __weak __typeof(self)wSelf = self;
    [self.getQQGroupService requestWithSuccess:^(SSJEncourageService * _Nonnull service) {
        SSJJoinQQGroup(service.qqgroup, service.qqgroupId);
    } failure:^(SSJEncourageService * _Nonnull service) {
        //        [SSJAlertViewAdapter showError:service.error];
        [CDAutoHideMessageHUD showMessage:service.desc.length?service.desc:SSJ_ERROR_MESSAGE];
    }];
}

- (void)setupViews {
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
    RAC(self.nextBtn, enabled) = [self.authCodeField.rac_textSignal map:^id(NSString *text) {
        return @(text.length >= SSJAuthCodeLength);
    }];
    @weakify(self);
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
    
    [[self.nextBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self bindNewMobileNo];
    }];
}

- (void)bindNewMobileNo {
    [[[[self requestBindMobileNo] then:^RACSignal *{
        return [self queryUserItem];
    }] flattenMap:^RACStream *(SSJUserItem *userItem) {
        return [self saveMobildNo:userItem];
    }] subscribeError:^(NSError *error) {
//        [SSJAlertViewAdapter showError:error];//mzl modify
        [CDAutoHideMessageHUD showMessage:error.localizedDescription.length?error.localizedDescription:SSJ_ERROR_MESSAGE];
    } completed:^{
        UIViewController *setttingVC = [self ssj_previousViewControllerBySubtractingIndex:4];
        if (setttingVC) {
            [self.navigationController popToViewController:setttingVC animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.successAlertView showWithDesc:@"更换手机号成功"];
            });
        }
    }];
}

- (RACSignal *)requestBindMobileNo {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.service changeMobileNoWithMobileNo:self.mobileNo authCode:self.authCodeField.text success:^(SSJBaseNetworkService * _Nonnull service) {
            [subscriber sendCompleted];
        } failure:^(SSJBaseNetworkService * _Nonnull service) {
            [subscriber sendError:service.error];
        }];
        return nil;
    }];
}

- (RACSignal *)queryUserItem {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
            [subscriber sendNext:userItem];
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (RACSignal *)saveMobildNo:(SSJUserItem *)userItem {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        userItem.mobileNo = self.service.mobileNo;
        [SSJUserTableManager saveUserItem:userItem success:^{
            //解决第三方登录后绑定手机号后再次登录手机号输入框默
            NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:userItem];
            [[NSUserDefaults standardUserDefaults] setObject:userData forKey:SSJLastLoggedUserItemKey];
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
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
        _stepView.currentStep = 3;
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
        _descLab.text = @"新手机号，新的开始";
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
        [_nextBtn setTitle:@"绑定" forState:UIControlStateNormal];
        [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _nextBtn;
}

- (SSJInviteCodeJoinSuccessView *)successAlertView {
    if (!_successAlertView) {
        _successAlertView = [[SSJInviteCodeJoinSuccessView alloc] init];
    }
    return _successAlertView;
}

- (SSJLoginVerifyPhoneNumViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[SSJLoginVerifyPhoneNumViewModel alloc] init];
    }
    return _viewModel;
}

- (SSJBindMobileNoNetworkService *)service {
    if (!_service) {
        _service = [[SSJBindMobileNoNetworkService alloc] init];
        _service.showLodingIndicator = YES;
    }
    return _service;
}


- (SSJEncourageService *)getQQGroupService {
    if (!_getQQGroupService) {
        _getQQGroupService = [[SSJEncourageService alloc] init];
        _getQQGroupService.showLodingIndicator = YES;
    }
    return _getQQGroupService;
}

- (UIButton *)changeWayBtn {
    if (!_changeWayBtn) {
        _changeWayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeWayBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [_changeWayBtn setTitle:@"无法收到验证码，快速反馈" forState:UIControlStateNormal];
        [_changeWayBtn setTitleColor:[UIColor ssj_colorWithHex:@"333333"] forState:UIControlStateNormal];
        @weakify(self);
        [[_changeWayBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self openQQ];
        }];
    }
    return _changeWayBtn;
}


@end
