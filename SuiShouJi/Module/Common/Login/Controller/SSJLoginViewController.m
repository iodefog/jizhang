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
#import "SSJBooksTypeSyncTable.h"
#import "SSJUserItem.h"
#import "SSJUserDefaultDataCreater.h"
#import "SSJUserTableManager.h"
#import "SSJBaselineTextField.h"
#import "SSJBorderButton.h"
#import "SSJFundAccountTable.h"
#import "SSJThirdPartyLoginManger.h"
#import <WXApi.h>
#import "SSJBookkeepingTreeStore.h"
#import "SSJBookkeepingTreeHelper.h"
#import "SSJLoginHelper.h"


@interface SSJLoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) SSJLoginService *loginService;

@property (nonatomic,strong)SSJBaselineTextField *tfPhoneNum;
@property (nonatomic,strong)SSJBaselineTextField *tfPassword;
@property (nonatomic,copy)NSString *strUserAccount;
@property (nonatomic,copy)NSString *strUserPassword;
@property (nonatomic,strong)UIButton *loginButton;
@property (nonatomic,strong)UIButton *registerButton;
@property (nonatomic,strong)UIButton *forgetButton;
@property (nonatomic,strong)UIButton *tencentLoginButton;
@property (nonatomic,strong)UIButton *weixinLoginButton;
@property (nonatomic,strong)UIImageView *backGroundImage;
@property (nonatomic,strong)UIView *leftSeperatorLine;
@property (nonatomic,strong)UIView *rightSeperatorLine;
@property (nonatomic,strong)UILabel *thirdPartyLoginLabel;
@end

@implementation SSJLoginViewController

#pragma mark - Lifecycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.statisticsTitle = @"登录";
//        self.hideKeyboradWhenTouch = YES;
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
    [scrollView addSubview:self.weixinLoginButton];
    [self.view addSubview:scrollView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.tfPhoneNum becomeFirstResponder];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor clearColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:21],
                                                                    NSForegroundColorAttributeName:[UIColor whiteColor]};
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (SSJSCREENWITH == 320 && SSJSCREENHEIGHT == 480) {
        self.tfPhoneNum.top = 45;
        self.tfPassword.top = self.tfPhoneNum.bottom + 10;
        self.loginButton.top = self.tfPassword.bottom + 35;
        self.loginButton.centerX = self.view.width / 2;
        self.registerButton.leftTop = CGPointMake(self.loginButton.left, self.loginButton.bottom + 20);
        self.forgetButton.rightTop = CGPointMake(self.loginButton.right, self.registerButton.bottom + 17);
        self.backGroundImage.frame = self.view.frame;
        self.thirdPartyLoginLabel.centerX = self.view.width / 2;
        self.thirdPartyLoginLabel.bottom = self.view.height - 110;
        if ([WXApi isWXAppInstalled]) {
            self.tencentLoginButton.centerX = self.view.width / 2 - 50;
            self.tencentLoginButton.centerY = self.view.height - 55;
            self.weixinLoginButton.centerX = self.view.width / 2 + 50;
            self.weixinLoginButton.centerY = self.view.height - 55;
            self.weixinLoginButton.hidden = NO;
        }else{
            self.tencentLoginButton.centerX = self.view.width / 2;
            self.tencentLoginButton.centerY = self.view.height - 55;
            self.weixinLoginButton.hidden = YES;
        }
        self.leftSeperatorLine.size = CGSizeMake((self.view.width - self.thirdPartyLoginLabel.width - 10) / 2, 1.0f / [UIScreen mainScreen].scale);
        self.leftSeperatorLine.centerY = self.thirdPartyLoginLabel.centerY;
        self.leftSeperatorLine.left = 0;
        self.rightSeperatorLine.size = CGSizeMake((self.view.width - self.thirdPartyLoginLabel.width - 10) / 2, 1.0f / [UIScreen mainScreen].scale);
        self.rightSeperatorLine.centerY = self.thirdPartyLoginLabel.centerY;
        self.rightSeperatorLine.right = self.view.width;

    }else{
        self.tfPhoneNum.top = 90;
        self.tfPassword.top = self.tfPhoneNum.bottom + 10;
        self.loginButton.top = self.tfPassword.bottom + 40;
        self.loginButton.centerX = self.view.width / 2;
        self.registerButton.leftTop = CGPointMake(self.loginButton.left, self.loginButton.bottom + 25);
        self.forgetButton.rightTop = CGPointMake(self.loginButton.right, self.registerButton.bottom + 20);
        self.backGroundImage.frame = self.view.frame;
        self.thirdPartyLoginLabel.centerX = self.view.width / 2;
        self.thirdPartyLoginLabel.bottom = self.view.height - 150;
        if ([WXApi isWXAppInstalled]) {
            self.weixinLoginButton.centerX = self.view.width / 2 - 50;
            self.tencentLoginButton.centerY = self.view.height - 75;
            self.tencentLoginButton.centerX = self.view.width / 2 + 50;
            self.weixinLoginButton.centerY = self.view.height - 75;
            self.weixinLoginButton.hidden = NO;
        }else{
            self.tencentLoginButton.centerX = self.view.width / 2;
            self.tencentLoginButton.centerY = self.view.height - 75;
            self.weixinLoginButton.hidden = YES;
        }
        self.leftSeperatorLine.size = CGSizeMake((self.view.width - self.thirdPartyLoginLabel.width - 10) / 2, 1.0f / [UIScreen mainScreen].scale);
        self.leftSeperatorLine.centerY = self.thirdPartyLoginLabel.centerY;
        self.leftSeperatorLine.left = 0;
        self.rightSeperatorLine.size = CGSizeMake((self.view.width - self.thirdPartyLoginLabel.width - 10) / 2, 1.0f / [UIScreen mainScreen].scale);
        self.rightSeperatorLine.centerY = self.thirdPartyLoginLabel.centerY;
        self.rightSeperatorLine.right = self.view.width;

    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.loginService cancel];
//    [self.navigationController setNavigationBarHidden:NO];
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
    
    if (![service.returnCode isEqualToString:@"1"]) {
        return;
    }
    
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
    
    [[SSJDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //  merge登陆接口返回的收支类型、资金帐户、账本
        [SSJUserBillSyncTable mergeRecords:self.loginService.userBillArray forUserId:SSJUSERID() inDatabase:db error:nil];
        [SSJFundInfoSyncTable mergeRecords:self.loginService.fundInfoArray forUserId:SSJUSERID() inDatabase:db error:nil];
        [SSJBooksTypeSyncTable mergeRecords:self.loginService.booksTypeArray forUserId:SSJUSERID() inDatabase:db error:nil];
        
        //  检测缺少哪个收支类型就创建
        [SSJUserDefaultDataCreater createDefaultBillTypesIfNeededForUserId:SSJUSERID() inDatabase:db];
        
        //  更新排序字段为空的收支类型
        [SSJLoginHelper updateBillTypeOrderIfNeededForUserId:SSJUSERID() inDatabase:db error:nil];
        
        //  如果登录没有返回任何资金帐户，说明服务器没有保存任何资金记录，就给用户创建默认的
        if (self.loginService.fundInfoArray.count == 0) {
            [SSJUserDefaultDataCreater createDefaultFundAccountsForUserId:SSJUSERID() inDatabase:db];
        }
        //  如果登录没有返回任何账本类型，说明服务器没有保存任何账本类型，就给用户创建默认的
        if (self.loginService.booksTypeArray.count == 0) {
            [SSJUserDefaultDataCreater createDefaultBooksTypeForUserId:SSJUSERID() inDatabase:db];
        }
        
        //  更新资金帐户余额
        [SSJFundAccountTable updateBalanceForUserId:SSJUSERID() inDatabase:db];
    }];
    
    // 如果本地保存的最近一次签到时间和服务端返回的不一致，说明本地没有保存最新的签到记录
    SSJBookkeepingTreeCheckInModel *checkInModel = [SSJBookkeepingTreeStore queryCheckInInfoWithUserId:SSJUSERID() error:nil];
    if (![checkInModel.lastCheckInDate isEqualToString:_loginService.checkInModel.lastCheckInDate]) {
        [SSJBookkeepingTreeStore saveCheckInModel:_loginService.checkInModel error:nil];
        [SSJBookkeepingTreeHelper loadTreeImageWithUrlPath:_loginService.checkInModel.treeImgUrl finish:NULL];
        [SSJBookkeepingTreeHelper loadTreeGifImageDataWithUrlPath:_loginService.checkInModel.treeGifUrl finish:NULL];
    }
    
    //  登陆成功后强制同步一次
    [[NSNotificationCenter defaultCenter] postNotificationName:SSJShowSyncLoadingNotification object:self];
    [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:^(SSJDataSynchronizeType type){
        [[NSNotificationCenter defaultCenter] postNotificationName:SSJHideSyncLoadingNotification object:self];
        [CDAutoHideMessageHUD showMessage:@"同步成功"];
    } failure:^(SSJDataSynchronizeType type, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SSJHideSyncLoadingNotification object:self];
        [CDAutoHideMessageHUD showMessage:@"同步失败"];
    }];
    
    //  如果有finishHandle，就通过finishHandle来控制页面流程，否则走默认流程
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:SSJHaveLoginOrRegistKey];
    [[NSUserDefaults standardUserDefaults]setInteger:self.loginService.loginType forKey:SSJUserLoginTypeKey];
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
    [MobClick event:@"login_forget_pwd"];

    SSJForgetPasswordFirstStepViewController *forgetVC = [[SSJForgetPasswordFirstStepViewController alloc] init];
    forgetVC.backController = self.backController;
    forgetVC.finishHandle = ^(UIViewController *controller){
        [weakSelf.navigationController popToViewController:weakSelf animated:YES];
    };
    [self.navigationController pushViewController:forgetVC animated:YES];
}

-(void)registerButtonClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    [MobClick event:@"login_register"];

    SSJRegistGetVerViewController *registerVc = [[SSJRegistGetVerViewController alloc] init];
    registerVc.finishHandle = ^(UIViewController *controller){
        //  如果是忘记密码，就返回到登录页面
        if ([controller isKindOfClass:[SSJForgetPasswordSecondStepViewController class]]) {
            [weakSelf.navigationController popToViewController:weakSelf animated:YES];
        } else {
            if (weakSelf.finishHandle) {
                weakSelf.finishHandle(weakSelf);
            } else {
                [weakSelf ssj_backOffAction];
            }
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
    [MobClick event:@"login_qq"];

    [[SSJThirdPartyLoginManger shareInstance].qqLogin qqLoginWithSucessBlock:^(NSString *nickName, NSString *iconUrl, NSString *openId) {
        [SSJThirdPartyLoginManger shareInstance].qqLogin = nil;
        [SSJThirdPartyLoginManger shareInstance].weixinLogin = nil;
        [self.loginService loadLoginModelWithLoginType:SSJLoginTypeQQ openID:openId realName:nickName icon:iconUrl];
    }];
}

-(void)weixinLoginButtonClicked:(id)sender{
    [MobClick event:@"login_weichat"];

    [[SSJThirdPartyLoginManger shareInstance].weixinLogin weixinLoginWithSucessBlock:^(NSString *nickName, NSString *iconUrl, NSString *openId) {
        [SSJThirdPartyLoginManger shareInstance].qqLogin = nil;
        [SSJThirdPartyLoginManger shareInstance].weixinLogin = nil;
        [self.loginService loadLoginModelWithLoginType:SSJLoginTypeWeiXin openID:openId realName:nickName icon:iconUrl];
    }];
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
        _backGroundImage.image = [UIImage imageNamed:@"login_bg"];
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
        _tfPhoneNum.tintColor = [UIColor whiteColor];
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
        _tfPassword.tintColor = [UIColor whiteColor];
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

-(UIButton*)loginButton{
    if (!_loginButton) {
        _loginButton = [[UIButton alloc]init];
        _loginButton.size = CGSizeMake(self.view.width - 22, 47);
        _loginButton.clipsToBounds = YES;
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:21];
        _loginButton.layer.cornerRadius = 3;
        _loginButton.enabled = NO;
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor ssj_colorWithHex:@"#eb4a64"] forState:UIControlStateNormal];
        _loginButton.backgroundColor = [UIColor whiteColor];
        [_loginButton addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
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
        _registerButton.titleLabel.font = [UIFont systemFontOfSize:21];
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
        _forgetButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_forgetButton addTarget:self action:@selector(forgetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_forgetButton sizeToFit];
        _forgetButton.rightTop = CGPointMake(self.view.width - 14, self.loginButton.bottom + 15);
    }
    return _forgetButton;
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

-(UIButton *)weixinLoginButton{
    if (!_weixinLoginButton) {
        _weixinLoginButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 70)];
        [_weixinLoginButton setImage:[UIImage imageNamed:@"more_weixin"] forState:UIControlStateNormal];
        [_weixinLoginButton setTitle:@"微信" forState:UIControlStateNormal];
        _weixinLoginButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _weixinLoginButton.spaceBetweenImageAndTitle = 12;
        _weixinLoginButton.contentLayoutType = SSJButtonLayoutTypeImageTopTitleBottom;
        _weixinLoginButton.contentMode = UIViewContentModeCenter;
        [_weixinLoginButton addTarget:self action:@selector(weixinLoginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _weixinLoginButton;
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
