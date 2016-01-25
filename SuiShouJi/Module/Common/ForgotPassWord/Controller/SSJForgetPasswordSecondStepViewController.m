//
//  SSJForgetPasswordSecondStepViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/1/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJForgetPasswordSecondStepViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "SSJBaselineTextField.h"
#import "SSJRegistNetworkService.h"

@interface SSJForgetPasswordSecondStepViewController () <UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

@property (nonatomic, strong) SSJBaselineTextField *passwordField;

@property (nonatomic, strong) UIButton *nextButton;

@property (nonatomic, strong) SSJRegistNetworkService *networkService;

@end

@implementation SSJForgetPasswordSecondStepViewController

#pragma mark - Lifecycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"输入新密码";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.passwordField];
    [self.scrollView addSubview:self.nextButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.passwordField becomeFirstResponder];
}

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
    [super serverDidFinished:service];
    
    if ([self.networkService.returnCode isEqualToString:@"1"]) {
        
        [self.passwordField resignFirstResponder];
        
        __weak typeof(self) weakSelf = self;
        SSJAlertViewAction *sureAction = [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction *action) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:SCYUpdateUserInfoNotification object:self];
            if (weakSelf.finishHandle) {
                weakSelf.finishHandle(weakSelf);
            }
        }];
        
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:@"设置密码成功" action:sureAction, nil];
        
    } else {
        [self.passwordField becomeFirstResponder];
    }
}

#pragma mark - Notification
- (void)textDidChange {
    if ([self.passwordField isFirstResponder]) {
        self.nextButton.enabled = self.passwordField.text.length >= 6;
    }
}

#pragma mark - Event
- (void)finishBtnAction {
    NSString * regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,15}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:self.passwordField.text];
    if (isMatch) {
        [self.networkService setPasswordWithMobileNo:self.mobileNo authCode:self.authCode password:self.passwordField.text];
    } else {
        [CDAutoHideMessageHUD showMessage:@"只能输入6-15位字母、数字组合"];
    }
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
    }
    return _scrollView;
}

- (SSJBaselineTextField *)passwordField {
    if (!_passwordField) {
        _passwordField = [[SSJBaselineTextField alloc] initWithFrame:CGRectMake(25, 30, self.view.width - 50, 50) contentHeight:40];
        _passwordField.secureTextEntry = YES;
        _passwordField.font = [UIFont systemFontOfSize:15];
        _passwordField.placeholder = @"请输入新密码";
        _passwordField.delegate = self;
        _passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _passwordField;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextButton.frame = CGRectMake(25, self.passwordField.bottom + 40, self.view.width - 50, 40);
        _nextButton.layer.cornerRadius = 3;
        _nextButton.clipsToBounds = YES;
        _nextButton.titleLabel.font = [UIFont systemFontOfSize:20];
        [_nextButton setTitle:@"确定" forState:UIControlStateNormal];
        [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"#47cfbe"] forState:UIControlStateNormal];
        [_nextButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"#cccccc"] forState:UIControlStateDisabled];
        [_nextButton addTarget:self action:@selector(finishBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

@end
