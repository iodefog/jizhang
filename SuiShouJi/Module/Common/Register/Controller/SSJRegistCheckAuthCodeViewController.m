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
#import "SSJRegistOrderView.h"
#import "SSJBaselineTextField.h"
#import "SSJRegistNetworkService.h"
#import "SSJBorderButton.h"

static const NSInteger kCountdownLimit = 60;    //  倒计时时限

@interface SSJRegistCheckAuthCodeViewController () <UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

//@property (nonatomic, strong) SSJRegistOrderView *stepView;

//  验证码输入框
@property (nonatomic, strong) SSJBaselineTextField *authCodeTextField;

//  获取验证码的按钮
@property (nonatomic, strong) UIButton *getAuthCodeBtn;

//  “下一步”按钮
@property (nonatomic, strong) SSJBorderButton *nextBtn;

@property (nonatomic, strong) SSJRegistNetworkService *networkService;

//  倒计时定时器
@property (nonatomic, strong) NSTimer *countdownTimer;

//  倒计时
@property (nonatomic) NSInteger countdown;

@end

@implementation SSJRegistCheckAuthCodeViewController

#pragma mark - Lifecycle
- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [self.countdownTimer invalidate];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.title = @"注册";
        self.countdown = kCountdownLimit;
        self.showNavigationBarBaseLine = NO;
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        self.backgroundView.image = [UIImage ssj_compatibleImageNamed:@"login_bg"];
    }
    [self.view addSubview:self.scrollView];
//    [self.scrollView addSubview:self.stepView];
    [self.scrollView addSubview:self.authCodeTextField];
    [self.scrollView addSubview:self.nextBtn];
    
    self.getAuthCodeBtn.enabled = NO;
//    self.nextBtn.enabled = NO;
    [self beginCountdownIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor clearColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1],
                                                                        NSForegroundColorAttributeName:[UIColor whiteColor]};
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
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
            SSJRegistCompleteViewController *registCompleteVC = [[SSJRegistCompleteViewController alloc] init];
            registCompleteVC.mobileNo = self.mobileNo;
            registCompleteVC.authCode = self.networkService.authCode;
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
//- (void)textDidChange {
//    if ([self.authCodeTextField isFirstResponder]) {
//        self.nextBtn.enabled = self.authCodeTextField.text.length >= 6;
//    }
//}

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
        [self.getAuthCodeBtn setTitle:[NSString stringWithFormat:@"%ds",(int)self.countdown] forState:UIControlStateDisabled];
    } else {
        self.getAuthCodeBtn.enabled = YES;
        [self.countdownTimer invalidate];
    }
    self.countdown --;
}

//  以一步按钮点击
- (void)nextBtnAction {
    if (!self.authCodeTextField.text.length) {
        [CDAutoHideMessageHUD showMessage:@"请先输入验证码"];
        return;
    }
    
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
        _networkService = [[SSJRegistNetworkService alloc] initWithDelegate:self type:SSJRegistAndForgetPasswordTypeRegist];
        _networkService.showLodingIndicator = YES;
    }
    return _networkService;
}

- (TPKeyboardAvoidingScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:self.view.bounds];
    }
    return _scrollView;
}

//- (SSJRegistOrderView *)stepView {
//    if (!_stepView) {
//        _stepView = [[SSJRegistOrderView alloc] initWithFrame:CGRectMake(10, 64, self.view.width - 20, 44) withOrderType:SSJRegistOrderTypeInputAuthCode];
//    }
//    return _stepView;
//}

- (SSJBaselineTextField *)authCodeTextField {
    if (!_authCodeTextField) {
        _authCodeTextField = [[SSJBaselineTextField alloc] initWithFrame:CGRectMake(25, 83, self.view.width - 50, 50) contentHeight:34];
        _authCodeTextField.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _authCodeTextField.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor];
        _authCodeTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入验证码" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor]}];
        _authCodeTextField.delegate = self;
        _authCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _authCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
        _authCodeTextField.rightView = self.getAuthCodeBtn;
        _authCodeTextField.rightViewMode = UITextFieldViewModeAlways;
    }
    return _authCodeTextField;
}

- (UIButton *)getAuthCodeBtn {
    if (!_getAuthCodeBtn) {
        _getAuthCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _getAuthCodeBtn.size = CGSizeMake(90, 30);
        _getAuthCodeBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
        [_getAuthCodeBtn setTitle:@"重新发送" forState:UIControlStateNormal];
        if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
            [_getAuthCodeBtn setTitleColor:[UIColor ssj_colorWithHex:@"#f6ff00"] forState:UIControlStateNormal];
        }else{
            [_getAuthCodeBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor] forState:UIControlStateNormal];
        }
        [_getAuthCodeBtn addTarget:self action:@selector(getAuthCodeAction) forControlEvents:UIControlEventTouchUpInside];
        [_getAuthCodeBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor]];
        [_getAuthCodeBtn ssj_setBorderStyle:SSJBorderStyleLeft];
        [_getAuthCodeBtn ssj_setBorderWidth:2];
        [_getAuthCodeBtn ssj_setBorderInsets:UIEdgeInsetsMake(4, 0, 4, 0)];
    }
    return _getAuthCodeBtn;
}

- (SSJBorderButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [[SSJBorderButton alloc] initWithFrame:CGRectMake(25, self.authCodeTextField.bottom + 40, self.view.width - 50, 40)];
        [_nextBtn setFontSize:16];
        [_nextBtn setTitle:@"下一步" forState:SSJBorderButtonStateNormal];
        [_nextBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor] forState:SSJBorderButtonStateNormal];
        [_nextBtn setBackgroundColor:[UIColor clearColor] forState:SSJBorderButtonStateNormal];
        [_nextBtn setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor] forState:SSJBorderButtonStateNormal];
        [_nextBtn addTarget:self action:@selector(nextBtnAction)];
    }
    return _nextBtn;
}

@end
