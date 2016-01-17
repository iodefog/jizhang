//
//  SSJRegistGetVerViewController.m
//  YYDB
//
//  Created by cdd on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJRegistGetVerViewController.h"
#import "SSJRegistCheckAuthCodeViewController.h"
#import "SSJNormalWebViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "SSJRegistNetworkService.h"

@interface SSJRegistGetVerViewController () <UITextFieldDelegate>

@property (nonatomic) SSJRegistAndForgetPasswordType type;

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;
@property (nonatomic, strong) UITextField *tfPhoneNum;
@property (nonatomic, strong) UIButton *agreeButton;
@property (nonatomic, strong) UIButton *protocolButton;
@property (nonatomic, strong) UIButton *nextButton;

@property (nonatomic, strong) SSJRegistNetworkService *getVerCodeService;

@end

@implementation SSJRegistGetVerViewController

#pragma mark - Lifecycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithRegistAndForgetType:SSJRegistAndForgetPasswordTypeRegist];
}

- (instancetype)initWithRegistAndForgetType:(SSJRegistAndForgetPasswordType)type {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.type = type;
        switch (self.type) {
            case SSJRegistAndForgetPasswordTypeRegist:
                self.title = @"注册";
                break;
                
            case SSJRegistAndForgetPasswordTypeForgetPassword:
                self.title = @"忘记密码";
                break;
        }
        self.hidesBottomBarWhenPushed = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.tfPhoneNum];
    if (self.type == SSJRegistAndForgetPasswordTypeRegist) {
        [self.scrollView addSubview:self.agreeButton];
        [self.scrollView addSubview:self.protocolButton];
    }
    [self.scrollView addSubview:self.nextButton];
    
    self.nextButton.enabled = self.tfPhoneNum.text.length >= 11;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tfPhoneNum becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.getVerCodeService cancel];
}

- (void)viewWillLayoutSubviews {
    self.scrollView.frame = self.view.bounds;
    self.tfPhoneNum.frame = CGRectMake(10, 20, self.view.width - 20, 48);
    switch (self.type) {
        case SSJRegistAndForgetPasswordTypeRegist: {
            self.protocolButton.leftTop = CGPointMake(40, self.tfPhoneNum.bottom + 22);
            self.agreeButton.size = CGSizeMake(40, 40);
            self.agreeButton.center = CGPointMake(20, self.protocolButton.centerY);
            self.nextButton.frame = CGRectMake(10, self.agreeButton.bottom + 30, self.view.width - 20, 40);
        }   break;
            
        case SSJRegistAndForgetPasswordTypeForgetPassword: {
            self.nextButton.frame = CGRectMake(10, self.tfPhoneNum.bottom + 25, self.view.width - 20, 40);
        }   break;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = textField.text ? : @"";
    text = [text stringByReplacingCharactersInRange:range withString:string];
    if (text.length > 11) {
        [CDAutoHideMessageHUD showMessage:@"最多只能输入11位手机号" inView:self.view.window duration:1];
        return NO;
    }
    return YES;
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    [super serverDidFinished:service];
    
    if ([self.getVerCodeService.returnCode isEqualToString:@"1"]) {
        
        [CDAutoHideMessageHUD showMessage:@"验证码发送成功"];
        
        SSJRegistCheckAuthCodeViewController *checkAuthCodeVC = [[SSJRegistCheckAuthCodeViewController alloc] initWithRegistAndForgetType:self.type mobileNo:self.getVerCodeService.mobileNo];
        checkAuthCodeVC.finishHandle = self.finishHandle;
        [self.navigationController pushViewController:checkAuthCodeVC animated:YES];
        
    } else if ([self.getVerCodeService.returnCode isEqualToString:@"1001"]) {
        
        __weak typeof(self) weakSelf = self;
        SSJAlertViewAction *cancelAction = [SSJAlertViewAction actionWithTitle:@"取消" handler:NULL];
        SSJAlertViewAction *forgetAction = [SSJAlertViewAction actionWithTitle:@"忘记密码" handler:^(SSJAlertViewAction *action) {
            SSJRegistGetVerViewController *forgetVC = [[SSJRegistGetVerViewController alloc] initWithRegistAndForgetType:SSJRegistAndForgetPasswordTypeForgetPassword];
            forgetVC.forgetMobileNo = self.getVerCodeService.mobileNo;
            forgetVC.finishHandle = self.finishHandle;
            [weakSelf.navigationController pushViewController:forgetVC animated:YES];
        }];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:@"该手机号已经被注册，若忘记密码，请使用忘记密码功能找回密码" action:cancelAction, forgetAction, nil];
        
    } else {
        NSString *message = service.desc.length > 0 ? service.desc : SSJ_ERROR_MESSAGE;
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:message action:[SSJAlertViewAction actionWithTitle:@"确认" handler:NULL], nil];
    }
}

#pragma mark - Notification
- (void)textDidChange {
    if ([self.tfPhoneNum isFirstResponder]) {
        self.nextButton.enabled = self.tfPhoneNum.text.length >= 11;
    }
}

#pragma mark - Event
//  获取验证码
- (void)getAuthCodeAction {
    if (!self.agreeButton.selected) {
        [CDAutoHideMessageHUD showMessage:@"请先同意用户协定"];
        return;
    }
    [self.getVerCodeService getAuthCodeWithMobileNo:self.tfPhoneNum.text];
}

//  同意、不同意协议
- (void)agreeProtocaolAction {
    self.agreeButton.selected = !self.agreeButton.selected;
}

//  查看协议
- (void)checkProtocolAction {
    SSJNormalWebViewController *userAgreementVC = [SSJNormalWebViewController webViewVCWithURL:[NSURL URLWithString:SSJURLWithAPI(@"h5/static/adbyhxy.html")]];
    userAgreementVC.title = @"用户协定";
    [self.navigationController pushViewController:userAgreementVC animated:YES];
}

#pragma mark - Getter
- (SSJRegistNetworkService *)getVerCodeService{
    if (_getVerCodeService==nil) {
        _getVerCodeService = [[SSJRegistNetworkService alloc] initWithDelegate:self type:self.type];
        _getVerCodeService.showLodingIndicator = YES;
        _getVerCodeService.showMessageIfErrorOccured = NO;
    }
    return _getVerCodeService;
}

- (TPKeyboardAvoidingScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectZero];
    }
    return _scrollView;
}

- (UITextField *)tfPhoneNum {
    if (!_tfPhoneNum) {
        _tfPhoneNum = [[UITextField alloc] initWithFrame:CGRectZero];
        _tfPhoneNum.font = [UIFont systemFontOfSize:16];
        _tfPhoneNum.borderStyle = UITextBorderStyleRoundedRect;
        _tfPhoneNum.placeholder = @"请输入您本人手机号码";
        _tfPhoneNum.delegate = self;
        _tfPhoneNum.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfPhoneNum.keyboardType = UIKeyboardTypeNumberPad;
        if (self.type == SSJRegistAndForgetPasswordTypeForgetPassword) {
            _tfPhoneNum.text = self.forgetMobileNo;
        }
    }
    return _tfPhoneNum;
}

- (UIButton *)agreeButton {
    if (!_agreeButton) {
        _agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _agreeButton.selected = YES;
        [_agreeButton setImage:[UIImage imageNamed:@"regist_disagree"] forState:UIControlStateNormal];
        [_agreeButton setImage:[UIImage imageNamed:@"regist_agree"] forState:UIControlStateSelected];
        [_agreeButton setImage:[UIImage imageNamed:@"regist_agree"] forState:UIControlStateSelected | UIControlStateHighlighted];
        [_agreeButton addTarget:self action:@selector(agreeProtocaolAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _agreeButton;
}

- (UIButton *)protocolButton {
    if (!_protocolButton) {
        _protocolButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _protocolButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_protocolButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_protocolButton setTitle:@"我已阅读并同意用户协定" forState:UIControlStateNormal];
        [_protocolButton setTitleColor:[UIColor ssj_colorWithHex:@"#757575"] forState:UIControlStateNormal];
        [_protocolButton sizeToFit];
        [_protocolButton addTarget:self action:@selector(checkProtocolAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _protocolButton;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextButton.layer.cornerRadius = 3;
        _nextButton.clipsToBounds = YES;
        _nextButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_nextButton setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"#d43e42"] forState:UIControlStateNormal];
        [_nextButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"#661517"] forState:UIControlStateHighlighted];
        [_nextButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"#cfd2d4"] forState:UIControlStateDisabled];
        [_nextButton addTarget:self action:@selector(getAuthCodeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

@end
