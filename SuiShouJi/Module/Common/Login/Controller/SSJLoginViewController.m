//
//  SSJLoginViewController.m
//  YYDB
//
//  Created by old lang on 15/10/27.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJLoginViewController.h"
#import "SSJLoginService.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "SSJRegistGetVerViewController.h"
#import "SSJForgetPasswordFirstStepViewController.h"
#import "SSJRegistCompleteViewController.h"
#import "SSJForgetPasswordSecondStepViewController.h"
#import "SSJMotionPasswordViewController.h"
#import "SSJDataSynchronizer.h"
#import "SSJDatabaseQueue.h"
#import "SSJUserBillSyncTable.h"
#import "SSJFundInfoSyncTable.h"
#import "SSJUserItem.h"
#import "SSJUserDefaultDataCreater.h"
#import "SSJUserTableManager.h"
#import "SSJBaselineTextField.h"
#import "SSJBorderButton.h"

static NSString *const KQQAppKey = @"1105133385";


@interface SSJLoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) SSJLoginService *loginService;

@property (nonatomic,strong)SSJBaselineTextField *tfPhoneNum;
@property (nonatomic,strong)SSJBaselineTextField *tfPassword;
@property (nonatomic,copy)NSString *strUserAccount;
@property (nonatomic,copy)NSString *strUserPassword;
@property (nonatomic,strong)SSJBorderButton *loginButton;
@property (nonatomic,strong)SSJBorderButton *registerButton;
@property (nonatomic,strong)UIButton *forgetButton;
@property (nonatomic,strong)TencentOAuth *tencentOAuth;
@property (nonatomic,strong)UIButton *tencentLoginButton;
@property (nonatomic,strong)UIImageView *backGroundImage;
@property (nonatomic,strong)UIView *leftSeperatorLine;
@property (nonatomic,strong)UIView *rightSeperatorLine;
@property (nonatomic,strong)UILabel *thirdPartyLoginLabel;
@property (nonatomic,strong)UIButton *backButton;
@end

@implementation SSJLoginViewController

#pragma mark - Lifecycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"登录";
        self.hideKeyboradWhenTouch = YES;
        self.hidesBottomBarWhenPushed = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatetextfield:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    TPKeyboardAvoidingScrollView *scrollView = [[TPKeyboardAvoidingScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    [self.view addSubview:self.backGroundImage];
    [scrollView addSubview:self.tfPhoneNum];
    [scrollView addSubview:self.tfPassword];
    [scrollView addSubview:self.loginButton];
    [scrollView addSubview:self.forgetButton];
    [scrollView addSubview:self.registerButton];
    [scrollView addSubview:self.tencentLoginButton];
    [scrollView addSubview:self.thirdPartyLoginLabel];
    [scrollView addSubview:self.leftSeperatorLine];
    [scrollView addSubview:self.rightSeperatorLine];
    [scrollView addSubview:self.tencentLoginButton];
    [scrollView addSubview:self.backButton];
    [self.view addSubview:scrollView];
    self.tencentOAuth=[[TencentOAuth alloc]initWithAppId:KQQAppKey andDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tfPhoneNum becomeFirstResponder];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor whiteColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.tfPhoneNum.top = 65;
    self.tfPassword.top = self.tfPhoneNum.bottom + 10;
    self.loginButton.top = self.tfPassword.bottom + 40;
    self.loginButton.centerX = self.view.width / 2;
    self.registerButton.leftTop = CGPointMake(self.loginButton.left, self.loginButton.bottom + 10);
    self.forgetButton.rightTop = CGPointMake(self.loginButton.right, self.registerButton.bottom + 10);
    self.backGroundImage.frame = self.view.frame;
    self.thirdPartyLoginLabel.centerX = self.view.width / 2;
    self.thirdPartyLoginLabel.bottom = self.view.height - 110;
    self.tencentLoginButton.centerX = self.view.width / 2;
    self.tencentLoginButton.centerY = self.view.height - 55;
    self.leftSeperatorLine.size = CGSizeMake((self.view.width - self.thirdPartyLoginLabel.width - 10) / 2, 1.0f / [UIScreen mainScreen].scale);
    self.leftSeperatorLine.centerY = self.thirdPartyLoginLabel.centerY;
    self.leftSeperatorLine.left = 0;
    self.rightSeperatorLine.size = CGSizeMake((self.view.width - self.thirdPartyLoginLabel.width - 10) / 2, 1.0f / [UIScreen mainScreen].scale);
    self.rightSeperatorLine.centerY = self.thirdPartyLoginLabel.centerY;
    self.rightSeperatorLine.right = self.view.width;
    self.backButton.size = CGSizeMake(20, 20);
    self.backButton.leftTop = CGPointMake(10, 10);
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.loginService cancel];
    [self.navigationController setNavigationBarHidden:NO];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.tfPassword){
        [self.tfPassword resignFirstResponder];
        [self.loginService loadLoginModelWithPassWord:self.tfPassword.text AndUserAccount:self.tfPhoneNum.text];
    }
    return true;
}

#pragma mark - TencentSessionDelegate
//登陆完成调用
- (void)tencentDidLogin
{
    if (self.tencentOAuth.accessToken && 0 != [self.tencentOAuth.accessToken length])
    {
        //  记录登录用户的OpenID、Token以及过期时间
        [self.tencentOAuth getUserInfo];
    }
    else
    {
        NSLog(@"登录不成功 没有获取accesstoken");
    }
}

//非网络错误导致登录失败：
-(void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled)
    {
        [CDAutoHideMessageHUD showMessage:@"登录取消"];
    }else{
        [CDAutoHideMessageHUD showMessage:@"登录失败"];
    }
}

// 网络错误导致登录失败：
-(void)tencentDidNotNetWork
{
    [CDAutoHideMessageHUD showMessage:@"无网络连接，请设置网络"];
}

//获取用户信息
-(void)getUserInfoResponse:(APIResponse *)response
{
    NSLog(@"respons:%@",response.jsonResponse);
    NSString *icon = [response.jsonResponse objectForKey:@"figureurl_qq_2"];
    NSString *realName = [response.jsonResponse objectForKey:@"nickname"];
    NSString *openId = [self.tencentOAuth openId];
    [self.loginService loadLoginModelWithopenID:openId realName:realName icon:icon];
}

#pragma mark - SSJBaseNetworkServiceDelegate
-(void)serverDidFinished:(SSJBaseNetworkService *)service{
    [super serverDidFinished:service];
    
    if (![service.returnCode isEqualToString:@"1"]) {
        return;
    }
    
    __block NSError *error = nil;
    __block BOOL fundInfoSuccess = YES;
    __block BOOL userBillSuccess = YES;
    
    //  merge登陆接口返回的收支类型和资金帐户
    [[SSJDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        fundInfoSuccess = [SSJUserBillSyncTable mergeRecords:self.loginService.userBillArray inDatabase:db error:&error];
        userBillSuccess = [SSJFundInfoSyncTable mergeRecords:self.loginService.fundInfoArray inDatabase:db error:&error];
        if (!userBillSuccess || !fundInfoSuccess) {
            *rollback = YES;
            return;
        }
    }];
    
    //  merge成功后保存用户登录信息，保存成功后才算登录成功
    if (userBillSuccess && fundInfoSuccess) {
        //  只要登录就设置用户为已注册，因为9188帐户、第三方登录没有注册就可以登录
        self.loginService.item.registerState = @"1";
        
        if (![SSJUserTableManager saveUserItem:self.loginService.item]
            || !SSJSaveAppId(self.loginService.appid)
            || !SSJSaveAccessToken(self.loginService.accesstoken)
            || !SSJSetUserId(self.loginService.item.userId)
            || !SSJSaveUserLogined(YES)) {
            
            [CDAutoHideMessageHUD showMessage:(SSJ_ERROR_MESSAGE)];
            return;
        }
        
        //  如果没有返回当前用户的收支类型，则创建默认的收支类型和资金帐户
        if (self.loginService.userBillArray.count == 0) {
            [SSJUserDefaultDataCreater createDefaultBillTypesIfNeededWithError:nil];
            [SSJUserDefaultDataCreater createDefaultFundAccountsWithError:nil];
        }
        
        //  登陆成功后强制同步一次
        //            [self.syncLoadingView show];
        [[NSNotificationCenter defaultCenter] postNotificationName:SSJShowSyncLoadingNotification object:self];
        [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:^{
            //                [self.syncLoadingView dismissWithSuccess:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:SSJHideSyncLoadingNotification object:self];
            [CDAutoHideMessageHUD showMessage:@"同步成功"];
        } failure:^(NSError *error) {
            //                [self.syncLoadingView dismissWithSuccess:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:SSJHideSyncLoadingNotification object:self];
            [CDAutoHideMessageHUD showMessage:@"同步失败"];
        }];
        
        //  如果有finishHandle，就通过finishHandle来控制页面流程，否则走默认流程
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:SSJHaveLoginOrRegistKey];
        [CDAutoHideMessageHUD showMessage:@"登录成功"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:SSJLastSelectFundItemKey];
        [[NSNotificationCenter defaultCenter]postNotificationName:SSJLoginOrRegisterNotification object:nil];
        
        //  如果用户手势密码开启，进入手势密码页面
        SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"motionPWD", @"motionPWDState"] forUserId:SSJUSERID()];
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
        
        //
        if (self.finishHandle) {
            self.finishHandle(self);
        } else {
            [self ssj_backOffAction];
        }
    }
}

#pragma mark - Notification
-(void)updatetextfield:(id)sender{
    if (self.tfPhoneNum.isFirstResponder || self.tfPassword.isFirstResponder) {
        if (self.tfPhoneNum.text.length != 0 && self.tfPassword.text.length >= 6) {
            self.loginButton.enabled = YES;
        }else{
        self.loginButton.enabled = NO;
        }
    }
}

#pragma mark - Event
-(void)loginButtonClicked:(id)sender{
    [self.loginService loadLoginModelWithPassWord:self.tfPassword.text AndUserAccount:self.tfPhoneNum.text];
    [self.tfPassword resignFirstResponder];
}

-(void)forgetButtonClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    SSJForgetPasswordFirstStepViewController *forgetVC = [[SSJForgetPasswordFirstStepViewController alloc] init];
    forgetVC.finishHandle = ^(UIViewController *controller){
        [weakSelf.navigationController popToViewController:weakSelf animated:YES];
    };
    [self.navigationController pushViewController:forgetVC animated:YES];
}

-(void)registerButtonClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    SSJRegistGetVerViewController *registerVc = [[SSJRegistGetVerViewController alloc] init];
    registerVc.finishHandle = ^(UIViewController *controller){
        if ([controller isKindOfClass:[SSJRegistCompleteViewController class]]) {
            [weakSelf ssj_backOffAction];
        } else if ([controller isKindOfClass:[SSJForgetPasswordSecondStepViewController class]]) {
            [weakSelf.navigationController popToViewController:weakSelf animated:YES];
        }
    };
    [self.navigationController pushViewController:registerVc animated:YES];
}

- (void)backOffAction {
    if (self.cancelHandle) {
        self.cancelHandle(self);
    } else {
       [super ssj_backOffAction];
    }
}

-(void)qqLoginButtonClicked:(id)sender{
    NSArray *permissions= [NSArray arrayWithObjects:@"get_user_info",@"get_simple_userinfo",@"add_t",nil];
    [self.tencentOAuth authorize:permissions inSafari:NO];
    [self.tencentOAuth getUserInfo];
}

#pragma mark - Getter
- (SSJLoginService *)loginService{
    if (_loginService==nil) {
        _loginService=[[SSJLoginService alloc]initWithDelegate:self];
        _loginService.showLodingIndicator = YES;
    }
    return _loginService;
}

//-(UIView*)loginView{
//    if (!_loginView) {
//        _loginView = [[UIView alloc]initWithFrame:CGRectMake(11, 24, self.view.width - 22, 94)];
//        _loginView.backgroundColor = [UIColor whiteColor];
//        _loginView.layer.borderWidth = 1;
//        _loginView.layer.borderColor = [UIColor ssj_colorWithHex:@"#d4d4d4"].CGColor;
//        _loginView.layer.cornerRadius = 5;
//        _loginView.layer.masksToBounds = YES;
//    }
//    return _loginView;
//}

-(UIImageView *)backGroundImage{
    if (!_backGroundImage) {
        _backGroundImage = [[UIImageView alloc]init];
        _backGroundImage.image = [UIImage imageNamed:@"login_bg.jpg"];
    }
    return _backGroundImage;
}

-(SSJBaselineTextField*)tfPhoneNum{
    if (!_tfPhoneNum) {
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_username"]];
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 47)];
        [leftView addSubview:image];
        image.center = CGPointMake(20, 23);
        
        _tfPhoneNum = [[SSJBaselineTextField alloc]initWithFrame:CGRectMake(11, 0, self.view.width - 22, 47) contentHeight:34];
        _tfPhoneNum.textColor = [UIColor whiteColor];
        _tfPhoneNum.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfPhoneNum.placeholder = @"请输入手机号";
        [_tfPhoneNum setValue:[UIColor colorWithWhite:1 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        _tfPhoneNum.font = [UIFont systemFontOfSize:16];
        _tfPhoneNum.delegate = self;
        _tfPhoneNum.keyboardType = UIKeyboardTypeNumberPad;
        _tfPhoneNum.leftView = leftView;
        _tfPhoneNum.leftViewMode = UITextFieldViewModeAlways;
    }
    return _tfPhoneNum;
}

-(SSJBaselineTextField*)tfPassword{
    if (!_tfPassword) {
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_password"]];
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 47)];
        [leftView addSubview:image];
        image.center = CGPointMake(20, 23);
        _tfPassword = [[SSJBaselineTextField alloc]initWithFrame:CGRectMake(11, 47, self.view.width - 22, 47) contentHeight:34];
        _tfPassword.textColor = [UIColor whiteColor];
        _tfPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfPassword.placeholder = @"请输入密码";
        [_tfPassword setValue:[UIColor colorWithWhite:1 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];

        _tfPassword.font = [UIFont systemFontOfSize:16];
        _tfPassword.secureTextEntry = YES;
        _tfPassword.keyboardType = UIKeyboardTypeASCIICapable;
        _tfPassword.delegate = self;
        _tfPassword.leftView = leftView;
        _tfPassword.leftViewMode = UITextFieldViewModeAlways;
    }
    return _tfPassword;
}

-(SSJBorderButton*)loginButton{
    if (!_loginButton) {
        _loginButton = [[SSJBorderButton alloc]init];
        _loginButton.size = CGSizeMake(self.view.width - 22, 47);
        _loginButton.clipsToBounds = YES;
        _loginButton.layer.cornerRadius = 3;
        [_loginButton setTitle:@"登录"];
        [_loginButton setColor:[UIColor ssj_colorWithHex:@"#47cfbe"]];
        [_loginButton addTarget:self action:@selector(loginButtonClicked:)];
    }
    return _loginButton;
}

-(UIButton*)registerButton{
    if (!_registerButton) {
        _registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _registerButton.size = CGSizeMake(self.view.width - 22, 47);
        _registerButton.clipsToBounds = YES;
        _registerButton.layer.cornerRadius = 3;
        _registerButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _registerButton.layer.borderWidth = 1.0f;
        _registerButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_registerButton setTitle:@"注册" forState:UIControlStateNormal];
        [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_registerButton ssj_setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [_registerButton addTarget:self action:@selector(registerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerButton;
}

-(UIButton*)forgetButton{
    if (!_forgetButton) {
        _forgetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _forgetButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_forgetButton setRight:self.loginButton.right];
        [_forgetButton setTitle:@"忘记密码?" forState:UIControlStateNormal];
        [_forgetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _forgetButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_forgetButton addTarget:self action:@selector(forgetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_forgetButton sizeToFit];
        _forgetButton.rightTop = CGPointMake(self.view.width - 14, self.loginButton.bottom + 15);
    }
    return _forgetButton;
}

-(UIButton *)backButton{
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        [_backButton setBackgroundImage:[[UIImage imageNamed:@"reportForms_left"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _backButton.tintColor = [UIColor whiteColor];
        [_backButton addTarget:self action:@selector(backOffAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

-(UIButton *)tencentLoginButton{
    if (!_tencentLoginButton) {
        _tencentLoginButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 70)];
        [_tencentLoginButton setImage:[UIImage imageNamed:@"more_qq"] forState:UIControlStateNormal];
        [_tencentLoginButton setTitle:@"腾讯QQ" forState:UIControlStateNormal];
        _tencentLoginButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _tencentLoginButton.spaceBetweenImageAndTitle = 12;
        _tencentLoginButton.contentLayoutType = SSJButtonLayoutTypeImageTopTitleBottom;
        _tencentLoginButton.contentMode = UIViewContentModeCenter;
        [_tencentLoginButton addTarget:self action:@selector(qqLoginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tencentLoginButton;
}

-(UIView *)leftSeperatorLine{
    if (!_leftSeperatorLine) {
        _leftSeperatorLine = [[UIView alloc]init];
        _leftSeperatorLine.backgroundColor = [UIColor whiteColor];
    }
    return _leftSeperatorLine;
}

-(UIView *)rightSeperatorLine{
    if (!_rightSeperatorLine) {
        _rightSeperatorLine = [[UIView alloc]init];
        _rightSeperatorLine.backgroundColor = [UIColor whiteColor];
    }
    return _rightSeperatorLine;
}

-(UILabel *)thirdPartyLoginLabel{
    if (!_thirdPartyLoginLabel) {
        _thirdPartyLoginLabel = [[UILabel alloc]init];
        _thirdPartyLoginLabel.text = @"使用第三方登录";
        [_thirdPartyLoginLabel sizeToFit];
        _thirdPartyLoginLabel.textColor = [UIColor whiteColor];
        _thirdPartyLoginLabel.font = [UIFont systemFontOfSize:15];
        _thirdPartyLoginLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _thirdPartyLoginLabel;
}

@end
