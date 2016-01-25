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
#import "SSJRegistOrderView.h"
#import "SSJBaselineTextField.h"
#import "SSJRegistNetworkService.h"

@interface SSJRegistGetVerViewController () <UITextFieldDelegate>

@property (nonatomic) SSJRegistAndForgetPasswordType type;

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;
@property (nonatomic, strong) SSJRegistOrderView *stepView;
@property (nonatomic, strong) SSJBaselineTextField *tfPhoneNum;
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
        self.title = @"注册";
        self.hidesBottomBarWhenPushed = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.stepView];
    [self.scrollView addSubview:self.tfPhoneNum];
    [self.scrollView addSubview:self.agreeButton];
    [self.scrollView addSubview:self.protocolButton];
    [self.scrollView addSubview:self.nextButton];
    
    self.agreeButton.selected = YES;
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

//- (void)viewWillLayoutSubviews {
//    self.scrollView.frame = self.view.bounds;
//    self.tfPhoneNum.frame = CGRectMake(10, 20, self.view.width - 20, 48);
//    switch (self.type) {
//        case SSJRegistAndForgetPasswordTypeRegist: {
//            self.protocolButton.leftTop = CGPointMake(40, self.tfPhoneNum.bottom + 22);
//            self.agreeButton.size = CGSizeMake(40, 40);
//            self.agreeButton.center = CGPointMake(20, self.protocolButton.centerY);
//            self.nextButton.frame = CGRectMake(10, self.agreeButton.bottom + 30, self.view.width - 20, 40);
//        }   break;
//            
//        case SSJRegistAndForgetPasswordTypeForgetPassword: {
//            self.nextButton.frame = CGRectMake(10, self.tfPhoneNum.bottom + 25, self.view.width - 20, 40);
//        }   break;
//    }
//}

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
        _getVerCodeService = [[SSJRegistNetworkService alloc] initWithDelegate:self type:self.type];
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

- (SSJRegistOrderView *)stepView {
    if (!_stepView) {
        _stepView = [[SSJRegistOrderView alloc] initWithFrame:CGRectMake(10, 0, self.view.width - 20, 44) withOrderType:SSJRegistOrderTypeInputPhoneNo];
    }
    return _stepView;
}

- (SSJBaselineTextField *)tfPhoneNum {
    if (!_tfPhoneNum) {
        _tfPhoneNum = [[SSJBaselineTextField alloc] initWithFrame:CGRectMake(25, 60, self.view.width - 50, 50) contentHeight:40];
        _tfPhoneNum.font = [UIFont systemFontOfSize:16];
        _tfPhoneNum.placeholder = @"请输入您的手机号";
        _tfPhoneNum.delegate = self;
        _tfPhoneNum.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfPhoneNum.keyboardType = UIKeyboardTypeNumberPad;
        if (self.type == SSJRegistAndForgetPasswordTypeForgetPassword) {
            _tfPhoneNum.text = self.forgetMobileNo;
        }
    }
    return _tfPhoneNum;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextButton.frame = CGRectMake(25, self.tfPhoneNum.bottom + 40, self.view.width - 50, 40);
        _nextButton.layer.cornerRadius = 3;
        _nextButton.clipsToBounds = YES;
        _nextButton.titleLabel.font = [UIFont systemFontOfSize:20];
        [_nextButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"#47cfbe"] forState:UIControlStateNormal];
        [_nextButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"#cccccc"] forState:UIControlStateDisabled];
        [_nextButton addTarget:self action:@selector(getAuthCodeAction) forControlEvents:UIControlEventTouchUpInside];
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
