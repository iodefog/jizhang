//
//  SSJRegistGetVerViewController.m
//  YYDB
//
//  Created by cdd on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJRegistGetVerViewController.h"
#import "SSJRegistCheckAuthCodeViewController.h"
#import "SSJForgetPasswordFirstStepViewController.h"
#import "SSJNormalWebViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "SSJRegistOrderView.h"
#import "SSJBaselineTextField.h"
#import "SSJRegistNetworkService.h"
#import "SSJBorderButton.h"

@interface SSJRegistGetVerViewController () <UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;
//@property (nonatomic, strong) SSJRegistOrderView *stepView;
@property (nonatomic, strong) SSJBaselineTextField *tfPhoneNum;
@property (nonatomic, strong) UIButton *agreeButton;
@property (nonatomic, strong) UIButton *protocolButton;
@property (nonatomic, strong) SSJBorderButton *nextButton;
@property (nonatomic,strong)UIImageView *backGroundImage;

@property (nonatomic, strong) SSJRegistNetworkService *getVerCodeService;

@end

@implementation SSJRegistGetVerViewController

#pragma mark - Lifecycle
- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.title = @"注册";
        self.hidesBottomBarWhenPushed = YES;
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.backGroundImage];
    [self.view addSubview:self.scrollView];
//    [self.scrollView addSubview:self.stepView];
    [self.scrollView addSubview:self.tfPhoneNum];
    [self.scrollView addSubview:self.agreeButton];
    [self.scrollView addSubview:self.protocolButton];
    [self.scrollView addSubview:self.nextButton];
    
    self.agreeButton.selected = YES;
//    self.nextButton.enabled = self.tfPhoneNum.text.length >= 11;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tfPhoneNum becomeFirstResponder];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.getVerCodeService cancel];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor clearColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:21],
                                                                    NSForegroundColorAttributeName:[UIColor whiteColor]};
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
        
        SSJRegistCheckAuthCodeViewController *checkAuthCodeVC = [[SSJRegistCheckAuthCodeViewController alloc] init];
        checkAuthCodeVC.mobileNo = self.getVerCodeService.mobileNo;
        checkAuthCodeVC.finishHandle = self.finishHandle;
        [self.navigationController pushViewController:checkAuthCodeVC animated:YES];
        
    } else if ([self.getVerCodeService.returnCode isEqualToString:@"1001"]) {
        
        __weak typeof(self) weakSelf = self;
        SSJAlertViewAction *cancelAction = [SSJAlertViewAction actionWithTitle:@"取消" handler:NULL];
        SSJAlertViewAction *forgetAction = [SSJAlertViewAction actionWithTitle:@"忘记密码" handler:^(SSJAlertViewAction *action) {
            SSJForgetPasswordFirstStepViewController *forgetVC = [[SSJForgetPasswordFirstStepViewController alloc] init];
            forgetVC.mobileNo = self.getVerCodeService.mobileNo;
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
//- (void)textDidChange {
//    if ([self.tfPhoneNum isFirstResponder]) {
//        self.nextButton.enabled = self.tfPhoneNum.text.length >= 11;
//    }
//}

#pragma mark - Event
//  获取验证码
- (void)getAuthCodeAction {
    if (!self.tfPhoneNum.text.length) {
        [CDAutoHideMessageHUD showMessage:@"请先输入手机号"];
        return;
    }
    
    if (!self.agreeButton.selected) {
        [CDAutoHideMessageHUD showMessage:@"请先同意用户协定"];
        return;
    }
    [self.getVerCodeService getAuthCodeWithMobileNo:self.tfPhoneNum.text];
}

//  同意、不同意协议
- (void)agreeProtocaolAction {
//    self.agreeButton.selected = !self.agreeButton.selected;
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
        _getVerCodeService = [[SSJRegistNetworkService alloc] initWithDelegate:self type:SSJRegistAndForgetPasswordTypeRegist];
        _getVerCodeService.showLodingIndicator = YES;
        _getVerCodeService.showMessageIfErrorOccured = NO;
    }
    return _getVerCodeService;
}

- (TPKeyboardAvoidingScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:self.view.bounds];
    }
    return _scrollView;
}

-(UIImageView *)backGroundImage{
    if (!_backGroundImage) {
        _backGroundImage = [[UIImageView alloc]initWithFrame:self.view.bounds];
        _backGroundImage.image = [UIImage imageNamed:@"login_bg.jpg"];
    }
    return _backGroundImage;
}


//- (SSJRegistOrderView *)stepView {
//    if (!_stepView) {
//        _stepView = [[SSJRegistOrderView alloc] initWithFrame:CGRectMake(10, 64, self.view.width - 20, 44) withOrderType:SSJRegistOrderTypeInputPhoneNo];
//    }
//    return _stepView;
//}

- (SSJBaselineTextField *)tfPhoneNum {
    if (!_tfPhoneNum) {
        _tfPhoneNum = [[SSJBaselineTextField alloc] initWithFrame:CGRectMake(25, 83, self.view.width - 50, 50) contentHeight:34];
        _tfPhoneNum.font = [UIFont systemFontOfSize:16];
        _tfPhoneNum.placeholder = @"请输入您的手机号";
        _tfPhoneNum.delegate = self;
        _tfPhoneNum.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfPhoneNum.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _tfPhoneNum;
}

- (SSJBorderButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [[SSJBorderButton alloc] initWithFrame:CGRectMake(25, self.tfPhoneNum.bottom + 40, self.view.width - 50, 40)];
        [_nextButton setFontSize:16];
        [_nextButton setTitle:@"获取验证码" forState:SSJBorderButtonStateNormal];
        [_nextButton setTitleColor:[UIColor whiteColor] forState:SSJBorderButtonStateNormal];
        [_nextButton setBackgroundColor:[UIColor clearColor] forState:SSJBorderButtonStateNormal];
        [_nextButton setBorderColor:[UIColor whiteColor] forState:SSJBorderButtonStateNormal];
        [_nextButton addTarget:self action:@selector(getAuthCodeAction)];
    }
    return _nextButton;
}

- (UIButton *)agreeButton {
    if (!_agreeButton) {
        _agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _agreeButton.frame = CGRectMake(25, self.nextButton.bottom + 20, 12, 12);
        _agreeButton.selected = YES;
        [_agreeButton setImage:nil forState:UIControlStateNormal];
        [_agreeButton setImage:[UIImage imageNamed:@"register_agreement"] forState:UIControlStateSelected];
        [_agreeButton addTarget:self action:@selector(agreeProtocaolAction) forControlEvents:UIControlEventTouchUpInside];
        [_agreeButton ssj_setBorderWidth:1];
        [_agreeButton ssj_setBorderStyle:SSJBorderStyleAll];
        [_agreeButton ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
//        [_agreeButton ssj_setBorderInsets:UIEdgeInsetsMake(13, 13, 13, 13)];
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
        _protocolButton.left = self.agreeButton.right + 10;
        _protocolButton.centerY = self.agreeButton.centerY;
    }
    return _protocolButton;
}

@end
