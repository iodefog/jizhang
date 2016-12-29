//
//  SSJForgetPasswordFirstStepViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/1/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJForgetPasswordFirstStepViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "SSJBaselineTextField.h"
#import "SSJRegistNetworkService.h"
#import "SSJForgetPasswordSecondStepViewController.h"
#import "SSJBorderButton.h"

static const NSInteger kCountdownLimit = 60;    //  倒计时时限

@interface SSJForgetPasswordFirstStepViewController () <UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

@property (nonatomic, strong) SSJBaselineTextField *phoneNoField;

@property (nonatomic, strong) SSJBaselineTextField *authCodeField;

@property (nonatomic, strong) UIButton *getAuthCodeBtn;

@property (nonatomic, strong) SSJBorderButton *nextButton;

@property (nonatomic, strong) SSJRegistNetworkService *networkService;

//  倒计时定时器
@property (nonatomic, strong) NSTimer *countdownTimer;

//  倒计时
@property (nonatomic) NSInteger countdown;

@end

@implementation SSJForgetPasswordFirstStepViewController

#pragma mark - Lifecycle
- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"忘记密码";
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
    [self.scrollView addSubview:self.phoneNoField];
    [self.scrollView addSubview:self.authCodeField];
    [self.scrollView addSubview:self.nextButton];
    
//    [self upateNextButtonState];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:21],
                                                                        NSForegroundColorAttributeName:[UIColor whiteColor]};
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor clearColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.mobileNo.length) {
        [self.authCodeField becomeFirstResponder];
    } else {
        [self.phoneNoField becomeFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = textField.text ? : @"";
    text = [text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.phoneNoField) {
        if (text.length > 11) {
            [CDAutoHideMessageHUD showMessage:@"最多只能输入11位手机号" inView:self.view.window duration:1];
            return NO;
        }
    } else if (textField == self.authCodeField) {
        if (text.length > 6) {
            [CDAutoHideMessageHUD showMessage:@"最多只能输入6位" inView:self.view.window duration:1];
            return NO;
        }
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
            SSJForgetPasswordSecondStepViewController *secondVC = [[SSJForgetPasswordSecondStepViewController alloc] init];
            secondVC.mobileNo = self.networkService.mobileNo;
            secondVC.authCode = self.networkService.authCode;
            secondVC.finishHandle = self.finishHandle;
            [self.navigationController pushViewController:secondVC animated:YES];
        }
    }
}

- (void)server:(SSJBaseNetworkService *)service didFailLoadWithError:(NSError *)error {
    [super server:service didFailLoadWithError:error];
    
    if (self.networkService.interfaceType == SSJRegistNetworkServiceTypeGetAuthCode) {
        self.getAuthCodeBtn.enabled = YES;
    }
}

#pragma mark - Notification
//- (void)textDidChange {
//    if ([self.phoneNoField isFirstResponder] || [self.authCodeField isFirstResponder]) {
//        [self upateNextButtonState];
//    }
//}

#pragma mark - Event
- (void)getAuthCodeAction {
    if (self.phoneNoField.text.length < 11) {
        [CDAutoHideMessageHUD showMessage:@"手机号码不能小于11位"];
        return;
    }
    
    self.getAuthCodeBtn.enabled = NO;
    [self.getAuthCodeBtn setTitle:@"发送中" forState:UIControlStateDisabled];
    [self.networkService getAuthCodeWithMobileNo:self.phoneNoField.text];
}

//  以一步按钮点击
- (void)nextBtnAction {
    if (!self.phoneNoField.text.length) {
        [CDAutoHideMessageHUD showMessage:@"请先输入您的手机号"];
        return;
    }
    
    if (!self.authCodeField.text.length) {
        [CDAutoHideMessageHUD showMessage:@"请先输入验证码"];
        return;
    }
    
    [self.networkService checkAuthCodeWithMobileNo:self.phoneNoField.text authCode:self.authCodeField.text];
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

//- (void)upateNextButtonState {
//    self.nextButton.enabled = self.phoneNoField.text.length >= 11 && self.authCodeField.text.length >= 6;
//}

#pragma mark - Getter
- (SSJRegistNetworkService *)networkService {
    if (!_networkService) {
        _networkService = [[SSJRegistNetworkService alloc] initWithDelegate:self type:SSJRegistAndForgetPasswordTypeForgetPassword];
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

- (SSJBaselineTextField *)phoneNoField {
    if (!_phoneNoField) {
        _phoneNoField = [[SSJBaselineTextField alloc] initWithFrame:CGRectMake(25, 74, self.view.width - 50, 50) contentHeight:34];
        _phoneNoField.font = [UIFont systemFontOfSize:15];
        _phoneNoField.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor];
        _phoneNoField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入您的手机号" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor]}];
        _phoneNoField.text = self.mobileNo.length ? self.mobileNo : @"";
        _phoneNoField.delegate = self;
        _phoneNoField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneNoField.keyboardType = UIKeyboardTypeNumberPad;
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 36)];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"login_username"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        imageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor];
        imageView.center = CGPointMake(leftView.width * 0.5, leftView.height * 0.5);
        [leftView addSubview:imageView];
        _phoneNoField.leftViewMode = UITextFieldViewModeAlways;
        _phoneNoField.leftView = leftView;
    }
    return _phoneNoField;
}

- (SSJBaselineTextField *)authCodeField {
    if (!_authCodeField) {
        _authCodeField = [[SSJBaselineTextField alloc] initWithFrame:CGRectMake(25, self.phoneNoField.bottom, self.view.width - 50, 50) contentHeight:34];
        _authCodeField.font = [UIFont systemFontOfSize:15];
        _authCodeField.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor];
        _authCodeField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入验证码" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor]}];
        _authCodeField.delegate = self;
        _authCodeField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _authCodeField.keyboardType = UIKeyboardTypeNumberPad;
        _authCodeField.rightView = self.getAuthCodeBtn;
        _authCodeField.rightViewMode = UITextFieldViewModeAlways;
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 36)];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"login_password"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        imageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor];
        imageView.center = CGPointMake(leftView.width * 0.5, leftView.height * 0.5);
        [leftView addSubview:imageView];
        _authCodeField.leftViewMode = UITextFieldViewModeAlways;
        _authCodeField.leftView = leftView;
    }
    return _authCodeField;
}

- (UIButton *)getAuthCodeBtn {
    if (!_getAuthCodeBtn) {
        _getAuthCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _getAuthCodeBtn.size = CGSizeMake(85, 30);
        _getAuthCodeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_getAuthCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
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

//- (UIButton *)nextButton {
//    if (!_nextButton) {
//        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _nextButton.frame = CGRectMake(25, self.authCodeField.bottom + 40, self.view.width - 50, 40);
//        _nextButton.layer.cornerRadius = 3;
//        _nextButton.clipsToBounds = YES;
//        _nextButton.titleLabel.font = [UIFont systemFontOfSize:20];
//        [_nextButton setTitle:@"下一步" forState:UIControlStateNormal];
//        [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [_nextButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"#eb4a64"] forState:UIControlStateNormal];
//        [_nextButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"#cccccc"] forState:UIControlStateDisabled];
//        [_nextButton addTarget:self action:@selector(nextBtnAction) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _nextButton;
//}

- (SSJBorderButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [[SSJBorderButton alloc] initWithFrame:CGRectMake(25, self.authCodeField.bottom + 40, self.view.width - 50, 40)];
        [_nextButton setFontSize:16];
        [_nextButton setTitle:@"下一步" forState:SSJBorderButtonStateNormal];
        [_nextButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor] forState:SSJBorderButtonStateNormal];
        [_nextButton setBackgroundColor:[UIColor clearColor] forState:SSJBorderButtonStateNormal];
        [_nextButton setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor] forState:SSJBorderButtonStateNormal];
        [_nextButton addTarget:self action:@selector(nextBtnAction)];
    }
    return _nextButton;
}

@end
