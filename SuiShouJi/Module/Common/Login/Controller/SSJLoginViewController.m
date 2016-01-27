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
#import "SSJDataSynchronizer.h"
#import "SSJDatabaseQueue.h"
#import "SSJUserBillSyncTable.h"
#import "SSJFundInfoSyncTable.h"
#import "SSJUserItem.h"
#import "SSJUserDefaultDataCreater.h"
#import "SSJUserTableManager.h"
#import "SSJBaselineTextField.h"

@interface SSJLoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) SSJLoginService *loginService;

@property (nonatomic,strong)SSJBaselineTextField *tfPhoneNum;
@property (nonatomic,strong)SSJBaselineTextField *tfPassword;
@property (nonatomic,copy)NSString *strUserAccount;
@property (nonatomic,copy)NSString *strUserPassword;
@property (nonatomic,strong)UIView *loginView;
@property (nonatomic,strong)UIButton *loginButton;
@property (nonatomic,strong)UIButton *registerButton;
@property (nonatomic,strong)UIButton *forgetButton;

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
    [scrollView addSubview:self.tfPhoneNum];
    [scrollView addSubview:self.tfPassword];
    [scrollView addSubview:self.loginButton];
    [scrollView addSubview:self.forgetButton];
    [scrollView addSubview:self.registerButton];
    [self.view addSubview:scrollView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tfPhoneNum becomeFirstResponder];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.tfPhoneNum.top = 40;
    self.tfPassword.top = self.tfPhoneNum.bottom + 10;
    self.loginButton.top = self.tfPassword.bottom + 40;
    self.loginButton.centerX = self.view.width / 2;
    self.registerButton.leftTop = CGPointMake(self.loginButton.left, self.loginButton.bottom + 10);
    self.forgetButton.rightTop = CGPointMake(self.loginButton.right, self.loginButton.bottom + 10);
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.loginService cancel];
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

#pragma mark - SSJBaseNetworkServiceDelegate
-(void)serverDidFinished:(SSJBaseNetworkService *)service{
    [super serverDidFinished:service];
    if ([self.loginService.returnCode isEqualToString: @"1"]) {
        __block NSError *error = nil;
        __block BOOL fundInfoSuccess = true;
        __block BOOL userBillSuccess = true;
        [[SSJDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
            fundInfoSuccess = [SSJUserBillSyncTable mergeRecords:self.loginService.userBillArray inDatabase:db error:&error];
            userBillSuccess = [SSJFundInfoSyncTable mergeRecords:self.loginService.fundInfoArray inDatabase:db error:&error];
            if (!userBillSuccess || !fundInfoSuccess) {
                *rollback = YES;
                return;
            }
        }];
        if (userBillSuccess && fundInfoSuccess) {
            if (self.loginService.userBillArray.count == 0) {
                [SSJUserDefaultDataCreater createDefaultBillTypesIfNeededWithSuccess:^(){
                    
                }failure:^(NSError *error){
                    
                }];
            }
            if ([self.loginService.item.cuserid isEqualToString:SSJUSERID()])
            {
                [SSJUserTableManager registerUserIdWithSuccess:^(){
                    
                }failure:^(NSError *error){
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [CDAutoHideMessageHUD showMessage:([error localizedDescription].length ? [error localizedDescription] : SSJ_ERROR_MESSAGE)];
                    });
                }];
            }
            SSJSaveAppId(self.loginService.appid);
            SSJSaveAccessToken(self.loginService.accesstoken);
            SSJSaveUserLogined(YES);
            SSJSetUserId(self.loginService.item.cuserid);
            //  登陆成功后强制同步一次
            [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:NULL failure:NULL];
            //  如果有finishHandle，就通过finishHandle来控制页面流程，否则走默认流程
            dispatch_async(dispatch_get_main_queue(), ^{
                [CDAutoHideMessageHUD showMessage:@"登录成功"];
                if (self.finishHandle) {
                    self.finishHandle(self);
                } else {
                    [self ssj_backOffAction];
                }
            });
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

-(SSJBaselineTextField*)tfPhoneNum{
    if (!_tfPhoneNum) {
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_username"]];
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 47)];
        [leftView addSubview:image];
        image.center = CGPointMake(20, 23);
        
        _tfPhoneNum = [[SSJBaselineTextField alloc]initWithFrame:CGRectMake(11, 0, self.view.width - 22, 47) contentHeight:34];
        _tfPhoneNum.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfPhoneNum.placeholder = @"请输入手机号";
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
        _tfPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfPassword.placeholder = @"请输入密码";
        _tfPassword.font = [UIFont systemFontOfSize:16];
        _tfPassword.secureTextEntry = YES;
        _tfPassword.keyboardType = UIKeyboardTypeASCIICapable;
        _tfPassword.delegate = self;
        _tfPassword.leftView = leftView;
        _tfPassword.leftViewMode = UITextFieldViewModeAlways;
    }
    return _tfPassword;
}

-(UIButton*)loginButton{
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginButton.frame = CGRectMake(11, self.loginView.bottom + 26, self.view.width - 22 , 47);
        _loginButton.enabled = NO;
        _loginButton.clipsToBounds = YES;
        _loginButton.layer.cornerRadius = 3;
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"#47cfbe"] forState:UIControlStateNormal];
        [_loginButton addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

-(UIButton*)registerButton{
    if (!_registerButton) {
        _registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _registerButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_registerButton setLeft:self.loginButton.left];
        [_registerButton setTitle:@"立刻注册" forState:UIControlStateNormal];
        _registerButton.titleLabel.font = [UIFont systemFontOfSize:18];

        [_registerButton setTitleColor:[UIColor ssj_colorWithHex:@"#47cfbe"] forState:UIControlStateNormal];
        [_registerButton addTarget:self action:@selector(registerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_registerButton sizeToFit];
        _registerButton.leftTop = CGPointMake(14, self.loginButton.bottom + 15);
    }
    return _registerButton;
}

-(UIButton*)forgetButton{
    if (!_forgetButton) {
        _forgetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _forgetButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_forgetButton setRight:self.loginButton.right];
        [_forgetButton setTitle:@"忘记密码?" forState:UIControlStateNormal];
        [_forgetButton setTitleColor:[UIColor ssj_colorWithHex:@"#47cfbe"] forState:UIControlStateNormal];
        _forgetButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_forgetButton addTarget:self action:@selector(forgetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_forgetButton sizeToFit];
        _forgetButton.rightTop = CGPointMake(self.view.width - 14, self.loginButton.bottom + 15);
    }
    return _forgetButton;
}

@end
