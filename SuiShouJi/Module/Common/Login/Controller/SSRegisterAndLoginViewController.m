//
//  SSRegisterAndLoginViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/6/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//
//static const NSInteger kCountdownLimit = 60;    //  倒计时时限
#import "SSRegisterAndLoginViewController.h"

#import "SSJLoginVerifyPhoneNumViewModel.h"

#import "SSJLoginGraphVerView.h"
#import "SSJVerifCodeField.h"

@interface SSRegisterAndLoginViewController ()<UITextFieldDelegate>
//@property (nonatomic,strong)UITextField *tfRegYanZhenNum;

@property (nonatomic,strong)UITextField *tfPassword;

/**验证码*/
@property (nonatomic, strong) SSJVerifCodeField *tfRegYanZhenF;

//  倒计时定时器
//@property (nonatomic, strong) NSTimer *countdownTimer;

//  倒计时
//@property (nonatomic) NSInteger countdown;

//验证码
//@property (nonatomic, strong) UIButton *getAuthCodeBtn;

@property (nonatomic, strong) SSJLoginVerifyPhoneNumViewModel *viewModel;

@property (nonatomic,strong)UIButton *registerAndLoginButton;

/**图形验证码*/
//@property (nonatomic, strong) SSJLoginGraphVerView *graphVerView;

/**<#注释#>*/
@property (nonatomic, strong) UIButton *rightBtn;

@end

@implementation SSRegisterAndLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialUI];
    [self setUpConst];
    [self initialBind];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.viewModel.netWorkService cancel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc{

}

- (void)setUpConst {
    [self.tfRegYanZhenF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom).offset(50);
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(self.view.mas_left).offset(20);
        make.right.mas_equalTo(self.view.mas_right).offset(-20);
    }];
    
    [self.tfPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tfRegYanZhenF.mas_bottom).offset(20);
        make.left.height.mas_equalTo(self.tfRegYanZhenF);
        make.right.mas_equalTo(self.tfRegYanZhenF).offset(-40);
    }];
    
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.tfRegYanZhenF);
        make.bottom.mas_equalTo(self.tfPassword);
        make.left.mas_equalTo(self.tfPassword.mas_right);
        make.height.mas_equalTo(50);
    }];
    
    [self.registerAndLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.tfRegYanZhenF);
        make.height.mas_equalTo(44);
        make.top.mas_equalTo(self.tfPassword.mas_bottom).offset(30);
    }];
}

#pragma mark - Private
- (void)initialUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.titleL];
    [self.scrollView addSubview:self.tfRegYanZhenF];
    [self.scrollView addSubview:self.tfPassword];
    [self.scrollView addSubview:self.registerAndLoginButton];
    [self.scrollView addSubview:self.rightBtn];
}

- (void)initialBind {
    self.viewModel.vc = self;
    RAC(self.viewModel,verificationCode) = self.tfRegYanZhenF.rac_textSignal;
    RAC(self.viewModel,passwardNum) = self.tfPassword.rac_textSignal;
    RAC(self.viewModel,phoneNum) = RACObserve(self, phoneNum);
}

////  开始倒计时
//- (void)beginCountdownIfNeeded {
//    if (!self.countdownTimer.valid) {
//        self.countdown = kCountdownLimit;
////        self.countdownTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateCountdown) userInfo:nil repeats:YES];
////        
//        [[[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] takeUntil:self.rac_willDeallocSignal ] subscribeNext:^(id x) {
//            [self updateCountdown];
//        }];
//        [[NSRunLoop currentRunLoop] addTimer:self.countdownTimer forMode:NSRunLoopCommonModes];
//        [self.countdownTimer fire];
//    }
//}
////取消定时器
//- (void)invalidateTimer {
//    [self.countdownTimer invalidate];
//    _countdownTimer = nil;
//}
//
////  更新倒计时
//- (void)updateCountdown {
//    if (self.countdown > 0) {
//        self.getAuthCodeBtn.enabled = NO;
//        [self.getAuthCodeBtn setTitle:[NSString stringWithFormat:@"%ds",(int)self.countdown] forState:UIControlStateDisabled];
//    } else {
//        self.getAuthCodeBtn.enabled = YES;
//        [self invalidateTimer];
//    }
//    self.countdown --;
//}

#pragma mark - Setter
- (void)setRegOrForgetType:(SSJRegistAndForgetPasswordType)regOrForgetType {
    //执行请求验证码
    _regOrForgetType = regOrForgetType;
    self.viewModel.regOrForType = regOrForgetType;
    self.tfRegYanZhenF.viewModel = self.viewModel;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = textField.text ?:@"";
    text = [text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.tfRegYanZhenF) {
        if (text.length > 6) {
            [CDAutoHideMessageHUD showMessage:@"最多只能输入6位" inView:self.view.window duration:1];
            return NO;
        }
    } else if (textField == self.tfPassword) {
        if (text.length > 15) {
            [CDAutoHideMessageHUD showMessage:@"最多只能输入15位" inView:self.view.window duration:1];
            return NO;
        }
    }
    return YES;
}

#pragma mark - Lazy
//-(UITextField *)tfRegYanZhenNum{
//    if (!_tfRegYanZhenNum) {
//        _tfRegYanZhenNum = [[UITextField alloc] init];
//        _tfRegYanZhenNum.delegate = self;
//        _tfRegYanZhenNum.textColor = [UIColor ssj_colorWithHex:@"333333"];
//        _tfRegYanZhenNum.clearButtonMode = UITextFieldViewModeWhileEditing;
//        _tfRegYanZhenNum.placeholder = @"验证码";
//        _tfRegYanZhenNum.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_3];
//        [_tfRegYanZhenNum ssj_setBorderColor:[UIColor ssj_colorWithHex:@"cccccc"]];
//        [_tfRegYanZhenNum ssj_setBorderStyle:SSJBorderStyleBottom];
//        [_tfRegYanZhenNum ssj_setBorderWidth:1];
//        _tfRegYanZhenNum.keyboardType = UIKeyboardTypeNumberPad;
//        _tfRegYanZhenNum.delegate = self;
//        _tfRegYanZhenNum.rightView = self.getAuthCodeBtn;
//        _tfRegYanZhenNum.rightViewMode = UITextFieldViewModeAlways;
//        
//    }
//    return _tfRegYanZhenNum;
//}

- (SSJLoginVerifyPhoneNumViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[SSJLoginVerifyPhoneNumViewModel alloc] init];
    }
    return _viewModel;
}

- (SSJVerifCodeField *)tfRegYanZhenF {
    if (!_tfRegYanZhenF) {
        _tfRegYanZhenF = [[SSJVerifCodeField alloc] initWithGetCodeType:self.regOrForgetType];
        _tfRegYanZhenF.rightViewMode = UITextFieldViewModeAlways;
        _tfRegYanZhenF.delegate = self;
        _tfRegYanZhenF.viewModel = self.viewModel;
        [_tfRegYanZhenF defaultAppearanceTheme];
        [_tfRegYanZhenF getVerifCode];//请求验证码
    }
    return _tfRegYanZhenF;
}

- (UITextField*)tfPassword{
    if (!_tfPassword) {
        _tfPassword = [[UITextField alloc] init];
        _tfPassword.delegate = self;
        _tfPassword.textColor = [UIColor ssj_colorWithHex:@"333333"];
        _tfPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfPassword.placeholder = @"请输入6~15位数字、字母组合密码";
        _tfPassword.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_3];
        _tfPassword.keyboardType = UIKeyboardTypeASCIICapable;
        _tfPassword.delegate = self;
        _tfPassword.rightViewMode = UITextFieldViewModeAlways;
        _tfPassword.secureTextEntry = YES;
        [_tfPassword ssj_setBorderColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].cellSeparatorColor alpha:[SSJThemeSetting defaultThemeModel].cellSeparatorAlpha]];
        [_tfPassword ssj_setBorderStyle:SSJBorderStyleBottom];
        [_tfPassword ssj_setBorderWidth:2];
    }
    return _tfPassword;
}

- (UIButton *)rightBtn {
    if (!_rightBtn) {
        _rightBtn = [[UIButton alloc] init];
        [_rightBtn setImage:[UIImage imageNamed:@"founds_xianshi"] forState:UIControlStateSelected];
        [_rightBtn setImage:[UIImage imageNamed:@"founds_yincang"] forState:UIControlStateNormal];
        [_rightBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].cellSeparatorColor alpha:[SSJThemeSetting defaultThemeModel].cellSeparatorAlpha]];
        [_rightBtn ssj_setBorderStyle:SSJBorderStyleBottom];
        [_rightBtn ssj_setBorderWidth:2];
        @weakify(self);
        [[_rightBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *button) {
            @strongify(self);
            self.tfPassword.secureTextEntry = button.selected;
            button.selected = !button.selected;
        }];
    }
    return _rightBtn;
}

//- (UIButton *)getAuthCodeBtn {
//    if (!_getAuthCodeBtn) {
//        _getAuthCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _getAuthCodeBtn.size = CGSizeMake(95, 30);
//        _getAuthCodeBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
//        [_getAuthCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
//        [_getAuthCodeBtn setTitleColor:[UIColor ssj_colorWithHex:@"#ea4a64"] forState:UIControlStateNormal];
//        [_getAuthCodeBtn setTitleColor:[UIColor ssj_colorWithHex:@"#f9cbd0"] forState:UIControlStateDisabled];
//
//        [[_getAuthCodeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn) {
//            [self.viewModel.getVerificationCodeCommand execute:nil];
//            [self.viewModel.getVerificationCodeCommand.executionSignals.switchToLatest subscribeNext:^(RACTuple *tuple) {
//                //请求成功并且不需要图形验证码的时候开启倒计时
//                    if ([tuple.first isEqualToString:@"1"]) {//发送验证码成功
//                        //倒计时
//                        [self beginCountdownIfNeeded];
//                    } else if ([tuple.first isEqualToString:@"1"]) {//需要图片验证码
//                        //显示图形验证码
////                        self.graphVerView.verSt
//                        [self.graphVerView show];
//                    } else if ([tuple.first isEqualToString:@"1"]) {//图片验证码错误
//                        [CDAutoHideMessageHUD showMessage:@"图片验证码错误"];
//                    } else {
//                        [CDAutoHideMessageHUD showMessage:tuple.last];
//                    }
//                }];
//
//            }];
//        [_getAuthCodeBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:@"cccccc"]];
//        [_getAuthCodeBtn ssj_setBorderStyle:SSJBorderStyleLeft];
//        [_getAuthCodeBtn ssj_setBorderWidth:1/SSJSCREENSCALE];
//        [_getAuthCodeBtn ssj_setBorderInsets:UIEdgeInsetsMake(4, 5, 4, 5)];
//    }
//    return _getAuthCodeBtn;
//}
//


- (UIButton*)registerAndLoginButton{
    if (!_registerAndLoginButton) {
        _registerAndLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _registerAndLoginButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        NSString *btnTitle = @"";
        if (self.regOrForgetType == SSJRegistAndForgetPasswordTypeRegist) {
            btnTitle = @"注册并登录";
        } else if (self.regOrForgetType == SSJRegistAndForgetPasswordTypeForgetPassword) {
            btnTitle = @"确定";
        }
        [_registerAndLoginButton setTitle:btnTitle forState:UIControlStateNormal];
        [_registerAndLoginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_registerAndLoginButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"f9cbd0"] forState:UIControlStateDisabled];
        [_registerAndLoginButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"ea4a64"] forState:UIControlStateNormal];
        _registerAndLoginButton.layer.cornerRadius = 6;
        _registerAndLoginButton.clipsToBounds = YES;
        RAC(_registerAndLoginButton,enabled) = self.viewModel.enableRegAndLoginSignal;
        __weak __typeof(self)weakSelf = self;
        [[_registerAndLoginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [[weakSelf.viewModel.registerAndLoginCommand execute:nil] takeUntil:weakSelf.rac_willDeallocSignal];
            [[[weakSelf.viewModel.registerAndLoginCommand.executing skip:1] distinctUntilChanged] subscribeNext:^(id x) {
                 if ([x boolValue]) {
                     weakSelf.tfPassword.userInteractionEnabled = NO;
                     weakSelf.tfRegYanZhenF.userInteractionEnabled = NO;
                 } else {
                     weakSelf.tfPassword.userInteractionEnabled = YES;
                     weakSelf.tfRegYanZhenF.userInteractionEnabled = YES;
                 }
             }];
        }];
    }
    return _registerAndLoginButton;
}


//- (SSJLoginGraphVerView *)graphVerView {
//    if (!_graphVerView) {
//        _graphVerView = [[SSJLoginGraphVerView alloc] init];
//        _graphVerView.size = CGSizeMake(315, 252);
//        _graphVerView.centerY = self.view.centerY - 80;
//        _graphVerView.centerX = self.view.centerX;
//         [[_graphVerView.reChooseBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn) {
//             [self.viewModel.reGetVerificationCodeCommand execute:nil];
//             [self.viewModel.reGetVerificationCodeCommand.executionSignals.switchToLatest subscribeNext:^(UIImage *image) {
//                     //成功刷新验证码
//                 self.graphVerView.verImage = image;
//
//             }];
//        }];
//    }
//    return _graphVerView;
//}

@end
