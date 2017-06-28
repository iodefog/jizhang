//
//  SSJLoginPhoneViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/6/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJLoginPhoneViewController.h"
#import "SSRegisterAndLoginViewController.h"

#import "SSJLoginVerifyPhoneNumViewModel.h"

@interface SSJLoginPhoneViewController ()<UITextFieldDelegate>
/**tips*/
@property (nonatomic, strong) UILabel *tipsL;

@property (nonatomic, strong) UITextField *tfPassword;

@property (nonatomic, strong) UIButton *loginButton;

/**忘记密码*/
@property (nonatomic, strong) UIButton *forgetPasswordBtn;
@end

@implementation SSJLoginPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self initBind];
}

- (void)setUpUI {
    [self.scrollView addSubview:self.tipsL];
    [self.scrollView addSubview:self.tfPassword];
    [self.scrollView addSubview:self.loginButton];
    [self.scrollView addSubview:self.forgetPasswordBtn];
    [self updateViewConstraints];
}

- (void)initBind {
    RAC(self.viewModel,passwardNum) = self.tfPassword.rac_textSignal;
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
        make.right.mas_equalTo(self.view.mas_right).offset(-20);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.tfPassword);
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
- (UILabel *)tipsL {
    if (!_tipsL) {
        _tipsL = [[UILabel alloc] init];
        _tipsL.text = @"欢迎回来，一直在等你哦~";
        _tipsL.textColor = [UIColor ssj_colorWithHex:@"333333"];
        _tipsL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _tipsL;
}

- (UITextField*)tfPassword{
    if (!_tfPassword) {
        UIButton *rightView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 50)];
        [rightView setImage:[UIImage imageNamed:@"founds_xianshi"] forState:UIControlStateSelected];
        [rightView setImage:[UIImage imageNamed:@"founds_yincang"] forState:UIControlStateNormal];
        [[rightView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *button) {
            self.tfPassword.secureTextEntry = button.selected;
            button.selected = !button.selected;
        }];
        _tfPassword = [[UITextField alloc] init];
        _tfPassword.delegate = self;
        _tfPassword.textColor = [UIColor ssj_colorWithHex:@"333333"];
        _tfPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfPassword.placeholder = @"至少6位";
        _tfPassword.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_3];
        _tfPassword.keyboardType = UIKeyboardTypeASCIICapable;
        _tfPassword.delegate = self;
        _tfPassword.rightView = rightView;
        _tfPassword.rightViewMode = UITextFieldViewModeAlways;
        _tfPassword.secureTextEntry = YES;
        [_tfPassword ssj_setBorderColor:[UIColor ssj_colorWithHex:@"cccccc"]];
        [_tfPassword ssj_setBorderStyle:SSJBorderStyleBottom];
        [_tfPassword ssj_setBorderWidth:1];
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
        [[_loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            self.viewModel.vc = self;
            [self.viewModel.normalLoginCommand execute:nil];
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
            //忘记密码
            SSRegisterAndLoginViewController *vc = [[SSRegisterAndLoginViewController alloc] init];
            vc.viewModel = self.viewModel;
            vc.regOrForgetType = SSJRegistAndForgetPasswordTypeForgetPassword;
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }
    return _forgetPasswordBtn;
}

@end
