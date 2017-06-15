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
#import "SSJMotionPasswordViewController.h"
#import "SSJBorderButton.h"

@interface SSJRegistCompleteViewController () <UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

//@property (nonatomic, strong) SSJRegistOrderView *stepView;

//  密码输入框
@property (nonatomic, strong) SSJBaselineTextField *passwordField;

//  完成注册按钮
@property (nonatomic, strong) SSJBorderButton *finishBtn;

@property (nonatomic, strong) SSJRegistNetworkService *registCompleteService;

@end

@implementation SSJRegistCompleteViewController

#pragma mark - Lifecycle
- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.title = @"注册";
        self.hidesBottomBarWhenPushed = YES;
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
    [self.scrollView addSubview:self.passwordField];
    [self.scrollView addSubview:self.finishBtn];
//    self.finishBtn.enabled = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor clearColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2],
                                                                        NSForegroundColorAttributeName:[UIColor whiteColor]};
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
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
        
        NSDictionary *resultInfo = [service.rootElement objectForKey:@"results"];
        
        if (resultInfo) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SSJHaveLoginOrRegistKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            SSJUserItem *userItem = [[SSJUserItem alloc] init];
            userItem.userId = SSJUSERID();
            userItem.mobileNo = self.registCompleteService.mobileNo;
            userItem.registerState = @"1";
            userItem.openId = @"";
            
            //  只有保存用户登录信息成功后才算登录成功
            [SSJUserTableManager saveUserItem:userItem success:^{
                if (SSJSaveAppId(resultInfo[@"appId"] ?: @"")
                    && SSJSaveAccessToken(resultInfo[@"accessToken"] ?: @"")
                    && SSJSaveUserLogined(YES)) {
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:SSJLoginOrRegisterNotification object:self];
                    
                    [self.passwordField resignFirstResponder];
                    [self showSuccessMessage];
                    
                    [CDAutoHideMessageHUD showMessage:@"注册成功"];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:userItem forKey:SSJLastLoggedUserItemKey];
                    
                    //  如果用户手势密码开启，进入手势密码页面
                    [SSJUserTableManager queryProperty:@[@"motionPWD", @"motionPWDState"] forUserId:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
                        if ([userItem.motionPWDState boolValue]) {
                            SSJMotionPasswordViewController *motionVC = [[SSJMotionPasswordViewController alloc] init];
                            motionVC.finishHandle = self.finishHandle;
                            motionVC.backController = self.backController;
                            if (userItem.motionPWD.length) {
                                motionVC.type = SSJMotionPasswordViewControllerTypeVerification;
                            } else {
                                motionVC.type = SSJMotionPasswordViewControllerTypeSetting;
                            }
                            [self.navigationController pushViewController:motionVC animated:YES];
                            
                            return;
                        }
                        
                        if (self.finishHandle) {
                            self.finishHandle(self);
                        }
                    } failure:^(NSError * _Nonnull error) {
                        [SSJAlertViewAdapter showError:error];
                    }];
                    
                    return;
                }
            } failure:^(NSError * _Nonnull error) {
                [SSJAlertViewAdapter showError:error];
            }];
        }
    }
    
    [self.passwordField becomeFirstResponder];
    [self showErrorMessage:(self.registCompleteService.desc.length ? self.registCompleteService.desc : SSJ_ERROR_MESSAGE)];
}

#pragma mark - Notification
//- (void)textDidChange {
//    if ([self.passwordField isFirstResponder]) {
//        self.finishBtn.enabled = self.passwordField.text.length >= 6;
//    }
//}

#pragma mark - Event
- (void)finishBtnAction {
    if (SSJVerifyPassword(self.passwordField.text)) {
        [self.registCompleteService setPasswordWithMobileNo:self.mobileNo authCode:self.authCode password:self.passwordField.text];
    } else {
        [CDAutoHideMessageHUD showMessage:@"只能输入6-15位字母、数字组合"];
    }
}

#pragma mark - Private
- (void)showSuccessMessage {
    
}

- (void)showErrorMessage:(NSString *)message {
    SSJAlertViewAction *sureAction = [SSJAlertViewAction actionWithTitle:@"确定" handler:NULL];
    [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:message action:sureAction, nil];
}

#pragma mark - Getter
- (SSJRegistNetworkService *)registCompleteService {
    if (!_registCompleteService) {
        _registCompleteService = [[SSJRegistNetworkService alloc] initWithDelegate:self type:SSJRegistAndForgetPasswordTypeRegist];
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


//- (SSJRegistOrderView *)stepView {
//    if (!_stepView) {
//        _stepView = [[SSJRegistOrderView alloc] initWithFrame:CGRectMake(10, 64, self.view.width - 20, 44) withOrderType:SSJRegistOrderTypeSetPassword];
//    }
//    return _stepView;
//}

- (SSJBaselineTextField *)passwordField {
    if (!_passwordField) {
        _passwordField = [[SSJBaselineTextField alloc] initWithFrame:CGRectMake(25, 83, self.view.width - 50, 50) contentHeight:34];
        _passwordField.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor];
        _passwordField.secureTextEntry = YES;
        _passwordField.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入6-15位字母、数字组合" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor]}];
        _passwordField.delegate = self;
        _passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _passwordField;
}

- (SSJBorderButton *)finishBtn {
    if (!_finishBtn) {
        _finishBtn = [[SSJBorderButton alloc] initWithFrame:CGRectMake(25, self.passwordField.bottom + 40, self.view.width - 50, 40)];
        [_finishBtn setFontSize:16];
        [_finishBtn setTitle:@"下一步" forState:SSJBorderButtonStateNormal];
        [_finishBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor] forState:SSJBorderButtonStateNormal];
        [_finishBtn setBackgroundColor:[UIColor clearColor] forState:SSJBorderButtonStateNormal];
        [_finishBtn setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor] forState:SSJBorderButtonStateNormal];
        [_finishBtn addTarget:self action:@selector(finishBtnAction)];
    }
    return _finishBtn;
}

@end
