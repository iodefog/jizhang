//
//  SSJRegistCompleteViewController.m
//  YYDB
//
//  Created by cdd on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJRegistCompleteViewController.h"
#import "SSJRegistNetworkService.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "SSJRegistOrderView.h"
#import "SSJBaselineTextField.h"
#import "SSJUserTableManager.h"

@interface SSJRegistCompleteViewController () <UITextFieldDelegate>

@property (nonatomic) SSJRegistAndForgetPasswordType type;
@property (nonatomic, copy) NSString *mobileNo;
@property (nonatomic, copy) NSString *authCode;

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

@property (nonatomic, strong) SSJRegistOrderView *stepView;

//  密码输入框
@property (nonatomic, strong) SSJBaselineTextField *passwordField;

//  完成注册按钮
@property (nonatomic, strong) UIButton *finishBtn;
@property (nonatomic, strong) SSJRegistNetworkService *registCompleteService;

@end

@implementation SSJRegistCompleteViewController

#pragma mark - Lifecycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithRegistAndForgetType:SSJRegistAndForgetPasswordTypeRegist mobileNo:nil authCode:nil];
}

- (instancetype)initWithRegistAndForgetType:(SSJRegistAndForgetPasswordType)type
                                   mobileNo:(NSString *)mobileNo
                                   authCode:(NSString *)authCode {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.type = type;
        self.mobileNo = mobileNo;
        self.authCode = authCode;
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
    [self.scrollView addSubview:self.stepView];
    [self.scrollView addSubview:self.passwordField];
    [self.scrollView addSubview:self.finishBtn];
    self.finishBtn.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.passwordField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.registCompleteService cancel];
}

//- (void)viewWillLayoutSubviews {
//    self.passwordField.frame = CGRectMake(10, 20, self.view.width - 20, 48);
//    self.finishBtn.frame = CGRectMake(10, self.passwordField.bottom + 25, self.view.width - 20, 40);
//}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = textField.text ? : @"";
    text = [text stringByReplacingCharactersInRange:range withString:string];
    if (text.length > 15) {
        [CDAutoHideMessageHUD showMessage:@"最多只能输入15位" inView:self.view.window duration:1];
        return NO;
    }
    return YES;
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
//    [super serverDidFinished:service];
    
    if ([self.registCompleteService.returnCode isEqualToString:@"1"]) {
        
        //  更新当前用户的注册状态，只有成功才按照注册成功处理，反之败则按照注册失败处理
        [SSJUserTableManager registerUserIdWithSuccess:^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSDictionary *resultInfo = [service.rootElement objectForKey:@"results"];
                if (resultInfo) {
                    SSJSaveAppId(resultInfo[@"appId"] ?: @"");
                    SSJSaveAccessToken(resultInfo[@"accessToken"] ?: @"");
                    SSJSaveUserLogined(YES);
                }
                
                [self.passwordField resignFirstResponder];
                [self showSuccessMessage];
            });
            
        } failure:^(NSError *error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.passwordField becomeFirstResponder];
                [self showErrorMessage:([error localizedDescription].length ? [error localizedDescription] : SSJ_ERROR_MESSAGE)];
            });
        }];
        
    } else {
        [self.passwordField becomeFirstResponder];
        [self showErrorMessage:(self.registCompleteService.desc.length ? self.registCompleteService.desc : SSJ_ERROR_MESSAGE)];
    }
}

#pragma mark - Notification
- (void)textDidChange {
    if ([self.passwordField isFirstResponder]) {
        self.finishBtn.enabled = self.passwordField.text.length >= 6;
    }
}

#pragma mark - Event
- (void)finishBtnAction {
    NSString * regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,15}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:self.passwordField.text];
    if (isMatch) {
        [self.registCompleteService setPasswordWithMobileNo:self.mobileNo authCode:self.authCode password:self.passwordField.text];
    } else {
        [CDAutoHideMessageHUD showMessage:@"只能输入6-15位字母、数字组合"];
    }
}

#pragma mark - Private
- (void)showSuccessMessage {
    __weak typeof(self) weakSelf = self;
    SSJAlertViewAction *sureAction = [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction *action) {
        if (weakSelf.finishHandle) {
            weakSelf.finishHandle(weakSelf);
        }
    }];
    NSString *message = self.type == SSJRegistAndForgetPasswordTypeRegist ? @"注册成功" : @"设置密码成功";
    [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:message action:sureAction, nil];
}

- (void)showErrorMessage:(NSString *)message {
    SSJAlertViewAction *sureAction = [SSJAlertViewAction actionWithTitle:@"确定" handler:NULL];
    [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:message action:sureAction, nil];
}

#pragma mark - Getter
- (SSJRegistNetworkService *)registCompleteService {
    if (!_registCompleteService) {
        _registCompleteService = [[SSJRegistNetworkService alloc] initWithDelegate:self type:self.type];
        _registCompleteService.showLodingIndicator = YES;
    }
    return _registCompleteService;
}

- (TPKeyboardAvoidingScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:self.view.bounds];
    }
    return _scrollView;
}

- (SSJRegistOrderView *)stepView {
    if (!_stepView) {
        _stepView = [[SSJRegistOrderView alloc] initWithFrame:CGRectMake(10, 0, self.view.width - 20, 44) withOrderType:SSJRegistOrderTypeInputAuthCode];
    }
    return _stepView;
}

- (UITextField *)passwordField {
    if (!_passwordField) {
        _passwordField = [[SSJBaselineTextField alloc] initWithFrame:CGRectMake(25, 60, self.view.width - 50, 50) contentHeight:40];
        _passwordField.secureTextEntry = YES;
        _passwordField.font = [UIFont systemFontOfSize:15];
        _passwordField.placeholder = @"请输入6-15位字母、数字组合";
        _passwordField.delegate = self;
        _passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _passwordField;
}

- (UIButton *)finishBtn {
    if (!_finishBtn) {
        _finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishBtn.frame = CGRectMake(25, self.passwordField.bottom + 40, self.view.width - 50, 40);
        _finishBtn.clipsToBounds = YES;
        _finishBtn.layer.cornerRadius = 2;
        _finishBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        [_finishBtn setTitle:@"完成注册" forState:UIControlStateNormal];
        [_finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_finishBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"#47cfbe"] forState:UIControlStateNormal];
        [_finishBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"#cccccc"] forState:UIControlStateDisabled];
        [_finishBtn addTarget:self action:@selector(finishBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishBtn;
}

@end
