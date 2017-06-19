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
#import "SSJUserTableManager.h"

static const NSInteger kCountdownLimit = 60;    //  倒计时时限

@interface SSJForgetPasswordFirstStepViewController () <UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

@property (nonatomic, strong) UITextField *phoneNoField;

@property (nonatomic, strong) UITextField *authCodeField;

@property (nonatomic, strong) UIButton *getAuthCodeBtn;

//@property (nonatomic, strong) UIButton *nextButton;

@property (nonatomic, strong) SSJRegistNetworkService *networkService;
/**
 顶部uiimgeview
 */
@property (nonatomic, strong) UIImageView *topView;

//  倒计时定时器
@property (nonatomic, strong) NSTimer *countdownTimer;

//  倒计时
@property (nonatomic) NSInteger countdown;

/**
 三角形尖块
 */
@property (nonatomic, strong) UIImageView *triangleView;

@property (nonatomic, strong) UIView *numRegSecretBgView;

/**
 <#注释#>
 */
@property (nonatomic, strong) UILabel *forgetPassWordLabel;
@property (nonatomic, strong) UIView *centerScrollViewOne;
//@property (nonatomic, strong) UIView *centerScrollViewTwo;

//设置密码
@property (nonatomic, strong) UITextField *passwordField;

@property (nonatomic, strong) UIButton *setPasswordButton;

/**
 <#注释#>
 */
@property (nonatomic, copy) NSString *mobileNum;
@property (nonatomic, copy) NSString *authCode;

@end

@implementation SSJForgetPasswordFirstStepViewController

#pragma mark - Lifecycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.showNavigationBarBaseLine = NO;
        self.appliesTheme = NO;
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.mobileNo.length) {
        self.phoneNoField.text = self.mobileNo;
    }
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.topView];
    [self.scrollView addSubview:self.forgetPassWordLabel];
    [self.scrollView addSubview:self.triangleView];
    
    [self.scrollView addSubview:self.centerScrollViewOne];
    
    [self.centerScrollViewOne addSubview:self.numRegSecretBgView];
    [self.numRegSecretBgView addSubview:self.phoneNoField];
    [self.numRegSecretBgView addSubview:self.authCodeField];
    
    [self.numRegSecretBgView addSubview:self.passwordField];
    [self.centerScrollViewOne addSubview:self.setPasswordButton];
    
//    [self upateNextButtonState];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//        self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:21],
//                                                                        NSForegroundColorAttributeName:[UIColor whiteColor]};
//        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    }

    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor clearColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self updateConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.mobileNo.length) {
        [self.authCodeField becomeFirstResponder];
    } else {
        [self.phoneNoField becomeFirstResponder];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.networkService cancel];
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

    if (self.networkService.interfaceType == SSJRegistNetworkServiceTypeSetPassword) {
        if ([self.networkService.returnCode isEqualToString:@"1"]) {
            
            [self.passwordField resignFirstResponder];
            
            __weak typeof(self) weakSelf = self;
            SSJAlertViewAction *sureAction = [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction *action) {
                //            [[NSNotificationCenter defaultCenter] postNotificationName:SCYUpdateUserInfoNotification object:self];
                [self.navigationController popViewControllerAnimated:NO];
                if (weakSelf.finishPassHandle) {
                    weakSelf.finishPassHandle(weakSelf.phoneNoField.text);
                }
            }];
            
            [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:@"设置密码成功" action:sureAction, nil];
            
            
        } else {
            [self.passwordField becomeFirstResponder];
        }

        return;
    }
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
//            SSJForgetPasswordSecondStepViewController *secondVC = [[SSJForgetPasswordSecondStepViewController alloc] init];
            self.mobileNo = self.networkService.mobileNo;
            self.authCode = self.networkService.authCode;
//            [self.navigationController pushViewController:secondVC animated:YES];
            self.forgetPassWordLabel.text = @"设置密码";
            [self.centerScrollViewOne endEditing:YES];
            //找回密码
            [self.networkService setPasswordWithMobileNo:self.mobileNo authCode:self.authCodeField.text password:self.passwordField.text];
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
- (void)textDidChange {
    if ([self.phoneNoField isFirstResponder] || [self.authCodeField isFirstResponder] || [self.passwordField isFirstResponder]) {
        if (self.phoneNoField.text.length == 11 && self.authCodeField.text.length == 6 && self.passwordField.text.length >= 6) {
            self.setPasswordButton.enabled = YES;
        }else {
            self.setPasswordButton.enabled = NO;
        }
        return;
    }
}

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
    
    if (![self vefifyPassword]) {//验证密码是否合格
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

/**
 *  画三角形
 */
- (UIImageView *)drawTriangle
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(10, 5), NO, [[UIScreen mainScreen] scale]);
    // 1.获得上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 2.画三角形
    CGContextMoveToPoint(ctx, 0, 5);
    CGContextAddLineToPoint(ctx, 5, 0);
    CGContextAddLineToPoint(ctx, 10, 5);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    // 关闭路径(连接起点和最后一个点)
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    return imageView;
}

- (BOOL)vefifyPassword {
    if (!self.passwordField.text.length) {
        [CDAutoHideMessageHUD showMessage:@"请输入6~15位数字和字母组合的密码"];
        return NO;
    }
    if (!SSJVerifyPassword(self.passwordField.text)) {
        [CDAutoHideMessageHUD showMessage:@"只能输入6-15位字母、数字组合"];
        return NO;
    }
    return YES;
}

- (void)showSecret:(UIButton *)button
{
    button.selected = !button.selected;
    self.passwordField.secureTextEntry = button.selected;
}

- (void)updateConstraints
{
    self.topView.frame = CGRectMake(0, 0, self.view.width, 206);
    self.forgetPassWordLabel.centerX = SSJSCREENWITH * 0.5;
    self.forgetPassWordLabel.bottom = self.topView.bottom - 10;
    
    self.triangleView.centerX = self.view.centerX;
    self.triangleView.bottom = self.topView.bottom;
    self.centerScrollViewOne.frame = CGRectMake(0, CGRectGetMaxY(self.topView.frame), self.view.width, SSJSCREENHEIGHT - self.topView.height);
    
    self.numRegSecretBgView.frame = CGRectMake(15, 35, self.view.width - 30, 150);
    self.phoneNoField.frame = CGRectMake(0, 0, self.numRegSecretBgView.width, 50);
    self.authCodeField.frame = CGRectMake(0, CGRectGetMaxY(self.phoneNoField.frame), self.numRegSecretBgView.width, 50);

    //输入密码
    self.passwordField.top = CGRectGetMaxY(self.authCodeField.frame);
    self.passwordField.height = 50;
    self.passwordField.left = 0;
    self.passwordField.width = SSJSCREENWITH - 30;
    
    self.setPasswordButton.top = CGRectGetMaxY(self.numRegSecretBgView.frame) + 25;
    self.setPasswordButton.left = self.numRegSecretBgView.left;
    self.setPasswordButton.width = self.passwordField.width;
    self.setPasswordButton.height = 45;
}

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
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(0, self.view.height);
    }
    return _scrollView;
}

- (UITextField *)phoneNoField {
    if (!_phoneNoField) {
        UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 50)];
        leftView.image = [UIImage imageNamed:@"zhuanghu"];
        leftView.contentMode = UIViewContentModeCenter;
        _phoneNoField = [[UITextField alloc] init];
        _phoneNoField.textColor = [UIColor ssj_colorWithHex:@"333333"];
        _phoneNoField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneNoField.placeholder = @"请输入手机号";
        _phoneNoField.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_phoneNoField setValue:[UIColor ssj_colorWithHex:@"999999"] forKeyPath:@"_placeholderLabel.textColor"];
        [_phoneNoField setValue:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4] forKeyPath:@"_placeholderLabel.font"];
        [_phoneNoField ssj_setBorderStyle:SSJBorderStyleBottom];
        [_phoneNoField ssj_setBorderWidth:1];
        [_phoneNoField ssj_setBorderColor:[UIColor ssj_colorWithHex:@"cccccc"]];
        _phoneNoField.delegate = self;
        _phoneNoField.keyboardType = UIKeyboardTypeNumberPad;
        _phoneNoField.leftView = leftView;
        _phoneNoField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _phoneNoField;
}

- (UITextField *)authCodeField {
    if (!_authCodeField) {
        UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 50)];
        leftView.image = [UIImage imageNamed:@"yanzheng"];
        leftView.contentMode = UIViewContentModeCenter;
        _authCodeField = [[UITextField alloc] init];
        _authCodeField.textColor = [UIColor ssj_colorWithHex:@"333333"];
        _authCodeField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _authCodeField.placeholder = @"请输入验证码";
        [_authCodeField setValue:[UIColor ssj_colorWithHex:@"999999"] forKeyPath:@"_placeholderLabel.textColor"];
        _authCodeField.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_authCodeField setValue:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4] forKeyPath:@"_placeholderLabel.font"];
        [_authCodeField ssj_setBorderColor:[UIColor ssj_colorWithHex:@"cccccc"]];
        [_authCodeField ssj_setBorderStyle:SSJBorderStyleBottom | SSJBorderStyleTop];
        [_authCodeField ssj_setBorderWidth:1];
        _authCodeField.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_3];
        _authCodeField.keyboardType = UIKeyboardTypeNumberPad;
        _authCodeField.delegate = self;
        _authCodeField.leftView = leftView;
        _authCodeField.rightView = self.getAuthCodeBtn;
        _authCodeField.leftViewMode = UITextFieldViewModeAlways;
        _authCodeField.rightViewMode = UITextFieldViewModeAlways;
    }
    return _authCodeField;
}

- (UITextField *)passwordField
{
    if (!_passwordField) {
        UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 50)];
        leftView.image = [UIImage imageNamed:@"mima"];
        leftView.contentMode = UIViewContentModeCenter;
        UIButton *rightView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 50)];
        [rightView setImage:[UIImage imageNamed:@"founds_xianshi"] forState:UIControlStateNormal];
        [rightView setImage:[UIImage imageNamed:@"founds_yincang"] forState:UIControlStateSelected];
        [rightView addTarget:self action:@selector(showSecret:) forControlEvents:UIControlEventTouchUpInside];
        rightView.tag = 300;
        _passwordField = [[UITextField alloc] init];
        _passwordField.textColor = [UIColor ssj_colorWithHex:@"333333"];
        _passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passwordField.placeholder = @"请输入账户密码";
        _passwordField.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_passwordField setValue:[UIColor ssj_colorWithHex:@"999999"] forKeyPath:@"_placeholderLabel.textColor"];
        [_passwordField setValue:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4] forKeyPath:@"_placeholderLabel.font"];
        
        _passwordField.keyboardType = UIKeyboardTypeASCIICapable;
        _passwordField.delegate = self;
        _passwordField.leftView = leftView;
        _passwordField.rightView = rightView;
        _passwordField.leftViewMode = UITextFieldViewModeAlways;
        _passwordField.rightViewMode = UITextFieldViewModeAlways;
        _passwordField.layer.cornerRadius = 4;
        _passwordField.clipsToBounds = YES;
    }
    return _passwordField;

}

- (UIButton *)getAuthCodeBtn {
    if (!_getAuthCodeBtn) {
        _getAuthCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _getAuthCodeBtn.size = CGSizeMake(80, 30);
        _getAuthCodeBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [_getAuthCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        
        [_getAuthCodeBtn setTitleColor:[UIColor ssj_colorWithHex:@"ea4a64"] forState:UIControlStateNormal];
        [_getAuthCodeBtn addTarget:self action:@selector(getAuthCodeAction) forControlEvents:UIControlEventTouchUpInside];
        [_getAuthCodeBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:@"ea4a64"]];
        [_getAuthCodeBtn ssj_setBorderStyle:SSJBorderStyleLeft];
        [_getAuthCodeBtn ssj_setBorderWidth:1];
        [_getAuthCodeBtn ssj_setBorderInsets:UIEdgeInsetsMake(6, 0, 6, 5)];
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

//- (UIButton *)nextButton {
//    if (!_nextButton) {
//        _nextButton = [[UIButton alloc] init];
//        _nextButton.titleLabel.font = systemFontSize(19);
//        [_nextButton setTitle:@"下一步" forState:UIControlStateNormal];
//        [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [_nextButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"f9cbd0"] forState:UIControlStateDisabled];
//        [_nextButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"ea4a64"] forState:UIControlStateNormal];
//        _nextButton.layer.cornerRadius = 4;
//        _nextButton.clipsToBounds = YES;
//        _nextButton.enabled = NO;
//        [_nextButton addTarget:self action:@selector(nextBtnAction) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _nextButton;
//}

- (UIImageView *)topView
{
    if (!_topView) {
        _topView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_login"]];
    }
    return _topView;
}

- (UIImageView *)triangleView
{
    if (!_triangleView) {
        _triangleView = [self drawTriangle];
    }
    return _triangleView;
}

- (UIView *)numRegSecretBgView
{
    if (!_numRegSecretBgView) {
        _numRegSecretBgView = [[UIView alloc] init];
        _numRegSecretBgView.backgroundColor = [UIColor ssj_colorWithHex:@"cccccc" alpha:0.2];
        _numRegSecretBgView.layer.cornerRadius = 4;
        _numRegSecretBgView.clipsToBounds = YES;
    }
    return _numRegSecretBgView;
}

- (UILabel *)forgetPassWordLabel{
    if (!_forgetPassWordLabel) {
        _forgetPassWordLabel = [[UILabel alloc]init];
        _forgetPassWordLabel.text = @"忘记密码";
        _forgetPassWordLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
        [_forgetPassWordLabel sizeToFit];
        _forgetPassWordLabel.textColor = [UIColor ssj_colorWithHex:@"eb4a64"];
    }
    return _forgetPassWordLabel;
}

- (UIView *)centerScrollViewOne
{
    if (!_centerScrollViewOne) {
        _centerScrollViewOne = [[UIView alloc] init];
    }
    return _centerScrollViewOne;
}


- (UIButton *)setPasswordButton {
    if (!_setPasswordButton) {
        _setPasswordButton = [[UIButton alloc] init];
        _setPasswordButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
        [_setPasswordButton setTitle:@"确定" forState:UIControlStateNormal];
        [_setPasswordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_setPasswordButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"f9cbd0"] forState:UIControlStateDisabled];
        [_setPasswordButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"ea4a64"] forState:UIControlStateNormal];
        _setPasswordButton.layer.cornerRadius = 4;
        _setPasswordButton.clipsToBounds = YES;
        _setPasswordButton.enabled = NO;
        [_setPasswordButton addTarget:self action:@selector(nextBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _setPasswordButton;
}
@end
