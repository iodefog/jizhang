//
//  SSJLoginPhoneViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/6/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJLoginPhoneViewController.h"
#import "SSRegisterAndLoginViewController.h"
#import "SSJMotionPasswordViewController.h"
#import "UIViewController+SSJPageFlow.h"

#import "SSJLoginVerifyPhoneNumViewModel.h"
#import "SSJUserTableManager.h"

@interface SSJLoginPhoneViewController ()<UITextFieldDelegate>
/**tips*/
@property (nonatomic, strong) UILabel *tipsL;

@property (nonatomic, strong) UITextField *tfPassword;

@property (nonatomic, strong) UIButton *loginButton;

/**忘记密码*/
@property (nonatomic, strong) UIButton *forgetPasswordBtn;

@property (nonatomic, strong) UIButton *rightBtn;

/**vm*/
@property (nonatomic, strong) SSJLoginVerifyPhoneNumViewModel *viewModel;
@end

@implementation SSJLoginPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self initBind];
    [self.tfPassword becomeFirstResponder];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.viewModel.netWorkService cancel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc {
    
}


- (void)setUpUI {
    [self.scrollView addSubview:self.tipsL];
    [self.scrollView addSubview:self.tfPassword];
    [self.scrollView addSubview:self.loginButton];
    [self.scrollView addSubview:self.forgetPasswordBtn];
    [self.scrollView addSubview:self.rightBtn];
    [self updateViewConstraints];
}

- (void)initBind {
    RAC(self.viewModel,passwardNum) = self.tfPassword.rac_textSignal;
    RAC(self.viewModel,phoneNum) = RACObserve(self, phoneNum);
//    RAC(_loginButton,enabled) = [self.viewModel.enableNormalLoginSignal skip:1];
}

- (void)updateViewConstraints {
    [self.tipsL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.scrollView.mas_centerX);
        make.width.greaterThanOrEqualTo(0);
        make.top.mas_equalTo(self.topView.mas_bottom).offset(15);
    }];
    
    [self.tfPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tipsL.mas_bottom).offset(24);
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(self.view.mas_left).offset(20);
        make.right.mas_equalTo(self.view.mas_right).offset(-60);
    }];
    
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view).offset(-20);
        make.bottom.mas_equalTo(self.tfPassword);
        make.left.mas_equalTo(self.tfPassword.mas_right);
        make.height.mas_equalTo(50);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.tfPassword);
        make.right.mas_equalTo(self.rightBtn);
        make.height.mas_equalTo(44);
        make.top.mas_equalTo(self.tfPassword.mas_bottom).offset(34);
    }];
    
    [self.forgetPasswordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.loginButton.mas_bottom).offset(10);
        make.left.mas_equalTo(self.loginButton);
        make.width.greaterThanOrEqualTo(0);
    }];
    [super updateViewConstraints];
}

#pragma mark - Lazy
- (SSJLoginVerifyPhoneNumViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[SSJLoginVerifyPhoneNumViewModel alloc] init];
    }
    return _viewModel;
}

- (UILabel *)tipsL {
    if (!_tipsL) {
        _tipsL = [[UILabel alloc] init];
        _tipsL.text = @"欢迎回来，一直在等你哦~";
        _tipsL.textColor = [UIColor ssj_colorWithHex:@"333333"];
        _tipsL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _tipsL;
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

- (UITextField*)tfPassword{
    if (!_tfPassword) {
        _tfPassword = [[UITextField alloc] init];
        _tfPassword.delegate = self;
        _tfPassword.textColor = [UIColor ssj_colorWithHex:@"333333"];
        _tfPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfPassword.placeholder = @"请输入账户密码";
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

- (UIButton*)loginButton{
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"f9cbd0"] forState:UIControlStateDisabled];
        [_loginButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"ea4a64"] forState:UIControlStateNormal];
        _loginButton.layer.cornerRadius = 6;
        _loginButton.clipsToBounds = YES;
        RAC(_loginButton,enabled) = self.viewModel.enableNormalLoginSignal;
        __weak __typeof(self)wSelf = self;
        [[_loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [wSelf.view endEditing:YES];
            
            [[[wSelf.viewModel.normalLoginCommand execute:nil] takeUntil:wSelf.rac_willDeallocSignal] subscribeError:^(NSError *error) {
                if (error.code != SSJErrorCodeLoginCanceled) {
                    [CDAutoHideMessageHUD showError:error];
                }
            } completed:^{
                [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
                    if ([userItem.motionPWDState boolValue] && !userItem.motionPWD.length) {
                        SSJMotionPasswordViewController *motionPwdVC = [[SSJMotionPasswordViewController alloc] init];
                        motionPwdVC.type = SSJMotionPasswordViewControllerTypeSetting;
                        motionPwdVC.isLoginFlow = YES;
                        motionPwdVC.finishHandle = wSelf.finishHandle;
                        [wSelf.navigationController pushViewController:motionPwdVC animated:YES];
                    } else {
                        [CDAutoHideMessageHUD showMessage:@"登录成功"];
                        if (wSelf.finishHandle) {
                            wSelf.finishHandle(wSelf);
                        }
                        [wSelf dismissViewControllerAnimated:NO completion:NULL];
                    }
                } failure:^(NSError * _Nonnull error) {
                    [CDAutoHideMessageHUD showError:error];
                }];
            }];
            
            [[[wSelf.viewModel.normalLoginCommand.executing skip:1] distinctUntilChanged] subscribeNext:^(id x) {
                if ([x boolValue]) {
                    wSelf.tfPassword.userInteractionEnabled = NO;
                } else {
                    wSelf.tfPassword.userInteractionEnabled = YES;
                }
            }];
        }];
    }
    return _loginButton;
}

- (UIButton *)forgetPasswordBtn {
    if (!_forgetPasswordBtn) {
        _forgetPasswordBtn = [[UIButton alloc] init];
        [_forgetPasswordBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
        [_forgetPasswordBtn setTitleColor:[UIColor ssj_colorWithHex:@"333333"] forState:UIControlStateNormal];
        _forgetPasswordBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        
        @weakify(self);
        [[_forgetPasswordBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn) {
            @strongify(self);
            [SSJAnaliyticsManager event:@"forget_pwd"];
            //忘记密码
            SSRegisterAndLoginViewController *vc = [[SSRegisterAndLoginViewController alloc] init];
            vc.titleL.text = @"忘记密码";
            vc.finishHandle = self.finishHandle;
            vc.phoneNum = self.viewModel.phoneNum;
            vc.regOrForgetType = SSJRegistAndForgetPasswordTypeForgetPassword;
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }
    return _forgetPasswordBtn;
}

@end
