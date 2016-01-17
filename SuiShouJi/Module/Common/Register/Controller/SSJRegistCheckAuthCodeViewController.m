//
//  SSJRegistCheckAuthCodeViewController.m
//  YYDB
//
//  Created by old lang on 15/10/29.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJRegistCheckAuthCodeViewController.h"
#import "SSJRegistCompleteViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "SSJRegistNetworkService.h"

static const NSInteger kCountdownLimit = 60;    //  倒计时时限

@interface SSJRegistCheckAuthCodeViewController () <UITextFieldDelegate>

@property (nonatomic) SSJRegistAndForgetPasswordType type;
@property (nonatomic, copy) NSString *mobileNo;

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;
@property (nonatomic, strong) UILabel *topLabel;                //  顶部的提示
@property (nonatomic, strong) UITextField *authCodeTextField;   //  验证码输入框
@property (nonatomic, strong) UIButton *getAuthCodeBtn;         //  获取验证码的按钮
@property (nonatomic, strong) UIButton *nextBtn;                //  “下一步”按钮

@property (nonatomic, strong) SSJRegistNetworkService *networkService;

@property (nonatomic, strong) NSTimer *countdownTimer;  //  倒计时定时器
@property (nonatomic) NSInteger countdown;  //  倒计时

@end

@implementation SSJRegistCheckAuthCodeViewController

#pragma mark - Lifecycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithRegistAndForgetType:SSJRegistAndForgetPasswordTypeRegist mobileNo:nil];
}

- (instancetype)initWithRegistAndForgetType:(SSJRegistAndForgetPasswordType)type
                                   mobileNo:(NSString *)mobileNo {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.type = type;
        self.mobileNo = mobileNo;
        self.countdown = kCountdownLimit;
        switch (self.type) {
            case SSJRegistAndForgetPasswordTypeRegist:
                self.title = @"注册";
                break;
                
            case SSJRegistAndForgetPasswordTypeForgetPassword:
                self.title = @"忘记密码";
                break;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.topLabel];
    [self.scrollView addSubview:self.authCodeTextField];
    [self.scrollView addSubview:self.getAuthCodeBtn];
    [self.scrollView addSubview:self.nextBtn];
    
    self.getAuthCodeBtn.enabled = NO;
    self.nextBtn.enabled = NO;
    [self beginCountdownIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.authCodeTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.networkService cancel];
    if ([self isBeingPresented] || [self isMovingFromParentViewController]) {
        [self.countdownTimer invalidate];
    }
}

- (void)viewWillLayoutSubviews {
    self.scrollView.frame = self.view.bounds;
    self.topLabel.leftTop = CGPointMake(10, 20);
    
    CGFloat baseWidth = self.view.width - 30;
    self.authCodeTextField.frame = CGRectMake(10, self.topLabel.bottom + 12, baseWidth * 0.6, 48);
    self.getAuthCodeBtn.frame = CGRectMake(self.authCodeTextField.right + 10, self.topLabel.bottom + 12, baseWidth * 0.4, 48);
    
    self.nextBtn.frame = CGRectMake(10, self.authCodeTextField.bottom + 20, self.view.width - 20, 40);
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = textField.text ? : @"";
    text = [text stringByReplacingCharactersInRange:range withString:string];
    if (text.length > 6) {
        [CDAutoHideMessageHUD showMessage:@"最多只能输入6位" inView:self.view.window duration:1];
        return NO;
    }
    return YES;
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    [super serverDidFinished:service];
    
    if (self.networkService.interfaceType == SSJRegistNetworkServiceTypeGetAuthCode) {
        //  获取验证码
        if ([self.networkService.returnCode isEqualToString:@"1"]) {
            [self beginCountdownIfNeeded];
            [CDAutoHideMessageHUD showMessage:@"验证码发送成功" inView:self.view.window duration:1];
        } else {
            self.getAuthCodeBtn.enabled = YES;
        }
        
    } else if (self.networkService.interfaceType == SSJRegistNetworkServiceTypeCheckAuthCode) {
        //  校验验证码
        if ([self.networkService.returnCode isEqualToString:@"1"]) {
            SSJRegistCompleteViewController *registCompleteVC = [[SSJRegistCompleteViewController alloc] initWithRegistAndForgetType:self.type mobileNo:self.mobileNo authCode:self.networkService.authCode];
            registCompleteVC.finishHandle = self.finishHandle;
            [self.navigationController pushViewController:registCompleteVC animated:YES];
        }
    }
}

- (void)server:(SSJBaseNetworkService *)service didFailLoadWithError:(NSError *)error {
    [super server:service didFailLoadWithError:error];
    
    if (self.networkService.type == SSJRegistNetworkServiceTypeGetAuthCode) {
        self.getAuthCodeBtn.enabled = YES;
    }
}

#pragma mark - Notification
- (void)textDidChange {
    if ([self.authCodeTextField isFirstResponder]) {
        self.nextBtn.enabled = self.authCodeTextField.text.length >= 6;
    }
}

#pragma mark - Event
//  获取验证码
- (void)getAuthCodeAction {
    self.getAuthCodeBtn.enabled = NO;
    [self.getAuthCodeBtn setTitle:@"重新发送" forState:UIControlStateDisabled];
    [self.networkService getAuthCodeWithMobileNo:self.mobileNo];
}

//  更新倒计时
- (void)updateCountdown {
    if (self.countdown > 0) {
        [self.getAuthCodeBtn setTitle:[NSString stringWithFormat:@"重新发送(%d)",(int)self.countdown] forState:UIControlStateDisabled];
    } else {
        self.getAuthCodeBtn.enabled = YES;
        [self.countdownTimer invalidate];
    }
    self.countdown --;
}

//  以一步按钮点击
- (void)nextBtnAction {
    [self.networkService checkAuthCodeWithMobileNo:self.mobileNo authCode:self.authCodeTextField.text];
}

#pragma mark - Private
//  开始倒计时
- (void)beginCountdownIfNeeded {
    if (!self.countdownTimer.valid) {
        self.countdown = kCountdownLimit;
        self.countdownTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateCountdown) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.countdownTimer forMode:NSRunLoopCommonModes];
        [self.countdownTimer fire];
    }
}

#pragma mark - Getter
- (SSJRegistNetworkService *)networkService {
    if (!_networkService) {
        _networkService = [[SSJRegistNetworkService alloc] initWithDelegate:self type:self.type];
        _networkService.showLodingIndicator = YES;
    }
    return _networkService;
}

- (TPKeyboardAvoidingScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectZero];
    }
    return _scrollView;
}

- (UILabel *)topLabel {
    if (!_topLabel) {
        _topLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _topLabel.font = [UIFont systemFontOfSize:12];
        _topLabel.textColor = [UIColor darkGrayColor];
        _topLabel.text = [NSString stringWithFormat:@"请输入%@收到的手机验证码",self.mobileNo];
        [_topLabel sizeToFit];
    }
    return _topLabel;
}

- (UITextField *)authCodeTextField {
    if (!_authCodeTextField) {
        _authCodeTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _authCodeTextField.font = [UIFont systemFontOfSize:16];
        _authCodeTextField.borderStyle = UITextBorderStyleRoundedRect;
        _authCodeTextField.placeholder = @"请输入验证码";
        _authCodeTextField.delegate = self;
        _authCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _authCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _authCodeTextField;
}

- (UIButton *)getAuthCodeBtn {
    if (!_getAuthCodeBtn) {
        _getAuthCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _getAuthCodeBtn.clipsToBounds = YES;
        _getAuthCodeBtn.layer.cornerRadius = 3;
        _getAuthCodeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_getAuthCodeBtn setTitle:@"重新发送" forState:UIControlStateNormal];
        [_getAuthCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_getAuthCodeBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"#d43e42"] forState:UIControlStateNormal];
        [_getAuthCodeBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"#661517"] forState:UIControlStateHighlighted];
        [_getAuthCodeBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"#cfd2d4"] forState:UIControlStateDisabled];
        [_getAuthCodeBtn addTarget:self action:@selector(getAuthCodeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _getAuthCodeBtn;
}

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextBtn.clipsToBounds = YES;
        _nextBtn.layer.cornerRadius = 3;
        _nextBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"#d43e42"] forState:UIControlStateNormal];
        [_nextBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"#661517"] forState:UIControlStateHighlighted];
        [_nextBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"#cfd2d4"] forState:UIControlStateDisabled];
        [_nextBtn addTarget:self action:@selector(nextBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

@end
