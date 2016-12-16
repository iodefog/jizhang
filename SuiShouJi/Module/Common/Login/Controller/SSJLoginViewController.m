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
//#import "SSJFundAccountTable.h"
#import "SSJThirdPartyLoginManger.h"
#import "WXApi.h"
#import "SSJBookkeepingTreeStore.h"
#import "SSJBookkeepingTreeHelper.h"
#import "SSJStartUpgradeAlertView.h"
#import "SSJThirdPartLoginItem.h"
#import "SSJLoginHelper.h"
#import "SSJStartChecker.h"
#import "SSJLocalNotificationHelper.h"

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
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        self.backgroundView.image = [UIImage ssj_compatibleImageNamed:@"login_bg"];
    }
    [scrollView addSubview:self.tfPhoneNum];
    [scrollView addSubview:self.tfPassword];
    [scrollView addSubview:self.loginButton];
    [scrollView addSubview:self.forgetButton];
    [scrollView addSubview:self.registerButton];
    // 只有9188、有鱼并且没有审核的情况下，显示第三方登录
    if ([SSJDefaultSource() isEqualToString:@"11501"]
         || [SSJDefaultSource() isEqualToString:@"11502"]) {
        [scrollView addSubview:self.thirdPartyLoginLabel];
        [scrollView addSubview:self.leftSeperatorLine];
        [scrollView addSubview:self.rightSeperatorLine];
        [scrollView addSubview:self.tencentLoginButton];
        [scrollView addSubview:self.weixinLoginButton];
    }
    [self.view addSubview:scrollView];
    
    [self ssj_showBackButtonWithTarget:self selector:@selector(goBackAction)];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    NSLog(@"%d", self.navigationController.navigationBarHidden);
    
    [self.tfPhoneNum becomeFirstResponder];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor clearColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:21],
                                                                        NSForegroundColorAttributeName:[UIColor whiteColor]};
    }
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
        self.thirdPartyLoginLabel.centerX = self.view.width / 2;
        self.thirdPartyLoginLabel.bottom = self.view.height - 110;
            self.tencentLoginButton.centerX = self.view.width / 2 - 50;
            self.tencentLoginButton.centerY = self.view.height - 55;
            self.weixinLoginButton.centerX = self.view.width / 2 + 50;
            self.weixinLoginButton.centerY = self.view.height - 55;
            self.weixinLoginButton.hidden = NO;

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
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:SSJLastLoggedUserItemKey]) {
        __weak typeof(self) weakSelf = self;
        NSData *lastUserData = [[NSUserDefaults standardUserDefaults] objectForKey:SSJLastLoggedUserItemKey];
        SSJUserItem *lastUserItem = [NSKeyedUnarchiver unarchiveObjectWithData:lastUserData];
        if (![self.loginService.item.mobileNo isEqualToString:lastUserItem.mobileNo] || ![self.loginService.item.openId isEqualToString:lastUserItem.openId] || ![self.loginService.item.loginType isEqualToString:lastUserItem.loginType]) {
            NSString *userName;
            int loginType = [lastUserItem.loginType intValue];
            if (loginType == 0) {
                userName = [lastUserItem.mobileNo stringByReplacingCharactersInRange:NSMakeRange(4, 4) withString:@"****"];
            }else{
                userName = lastUserItem.nickName;
            }
            NSString *message;
            if (loginType == 0) {
                message = [NSString stringWithFormat:@"您已使用过手机号%@登陆过,确定使用新账户登录",userName];
            }else if (loginType == 1) {
                message = [NSString stringWithFormat:@"您已使用过QQ:%@登陆过,确定使用新账户登录",userName];
            }else if (loginType == 2) {
                message = [NSString stringWithFormat:@"您已使用过微信:%@登陆过,确定使用新账户登录",userName];
            }
            
            [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:message action:[SSJAlertViewAction actionWithTitle:@"取消" handler:NULL], [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction * _Nonnull action) {
                [weakSelf comfirmTologin];
            }], nil];
        }else{
            [self comfirmTologin];
        }
    }else{
        [self comfirmTologin];
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

- (void)goBackAction {
    if (self.cancelHandle) {
        self.cancelHandle(self);
    } else {
       [super goBackAction];
    }
}

-(void)qqLoginButtonClicked:(id)sender{
    [MobClick event:@"login_qq"];
    __weak typeof(self) weakSelf = self;
    [[SSJThirdPartyLoginManger shareInstance].qqLogin qqLoginWithSucessBlock:^(SSJThirdPartLoginItem *item) {
        [SSJThirdPartyLoginManger shareInstance].qqLogin = nil;
        [SSJThirdPartyLoginManger shareInstance].weixinLogin = nil;
        [weakSelf.loginService loadLoginModelWithLoginItem:item];
    }];
}

-(void)weixinLoginButtonClicked:(id)sender{
    [MobClick event:@"login_weichat"];
    __weak typeof(self) weakSelf = self;
    [[SSJThirdPartyLoginManger shareInstance].weixinLogin weixinLoginWithSucessBlock:^(SSJThirdPartLoginItem *item) {
        [SSJThirdPartyLoginManger shareInstance].qqLogin = nil;
        [SSJThirdPartyLoginManger shareInstance].weixinLogin = nil;
        [weakSelf.loginService loadLoginModelWithLoginItem:item];
    }];
}

#pragma mark - Private
-(void)comfirmTologin{
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
    
    // 合并登陆借口返回的数据，即使合并失败也不影响登陆，因为之后还会同步一次
    [SSJLoginHelper updateTableWhenLoginWithServices:self.loginService];
        
    // 如果本地保存的最近一次签到时间和服务端返回的不一致，说明本地没有保存最新的签到记录
    SSJBookkeepingTreeCheckInModel *checkInModel = [SSJBookkeepingTreeStore queryCheckInInfoWithUserId:SSJUSERID() error:nil];
    if (![checkInModel.lastCheckInDate isEqualToString:_loginService.checkInModel.lastCheckInDate]) {
        [SSJBookkeepingTreeStore saveCheckInModel:_loginService.checkInModel error:nil];
        [SSJBookkeepingTreeHelper loadTreeImageWithUrlPath:_loginService.checkInModel.treeImgUrl finish:NULL];
        [SSJBookkeepingTreeHelper loadTreeGifImageDataWithUrlPath:_loginService.checkInModel.treeGifUrl finish:NULL];
    }
    
    [CDAutoHideMessageHUD showMessage:@"登录成功"];
    [[NSNotificationCenter defaultCenter]postNotificationName:SSJLoginOrRegisterNotification object:nil];
    [SSJLocalNotificationHelper cancelLocalNotificationWithKey:SSJReminderNotificationKey];
    
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
    
    //  如果用户手势密码开启，进入手势密码页面
    SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"motionPWD", @"motionPWDState"] forUserId:SSJUSERID()];
    if ([userItem.motionPWDState boolValue]) {
        __weak typeof(self) weakSelf = self;
        SSJMotionPasswordViewController *motionVC = [[SSJMotionPasswordViewController alloc] init];
        motionVC.finishHandle = self.finishHandle;
        motionVC.backController = self.backController;
        if (userItem.motionPWD.length) {
            motionVC.type = SSJMotionPasswordViewControllerTypeVerification;
        } else {
            motionVC.type = SSJMotionPasswordViewControllerTypeSetting;
        }
        [weakSelf.navigationController pushViewController:motionVC animated:YES];
        
        return;
    }
    
    //
    if (self.finishHandle) {
        self.finishHandle(self);
    } else {
        [self ssj_backOffAction];
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
        UIImageView *image = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"login_username"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        image.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor];
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 47)];
        [leftView addSubview:image];
        image.center = CGPointMake(20, 23);
        
        _tfPhoneNum = [[SSJBaselineTextField alloc]initWithFrame:CGRectMake(11, 0, self.view.width - 22, 47) contentHeight:34];
        _tfPhoneNum.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor];
        _tfPhoneNum.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor];
        _tfPhoneNum.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfPhoneNum.placeholder = @"请输入手机号";
        [_tfPhoneNum setValue:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor] forKeyPath:@"_placeholderLabel.textColor"];
        _tfPhoneNum.normalLineColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor];
        _tfPhoneNum.highlightLineColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor];
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
        UIImageView *image = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"login_password"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        image.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor];
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 47)];
        [leftView addSubview:image];
        image.center = CGPointMake(20, 23);
        _tfPassword = [[SSJBaselineTextField alloc]initWithFrame:CGRectMake(11, 47, self.view.width - 22, 47) contentHeight:34];
        _tfPassword.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor];
        _tfPassword.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor];
        _tfPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfPassword.placeholder = @"请输入密码";
        [_tfPassword setValue:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor] forKeyPath:@"_placeholderLabel.textColor"];
        _tfPassword.normalLineColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor];
        _tfPassword.highlightLineColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor];
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
        [_loginButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginButtonTitleColor] forState:UIControlStateNormal];
        _loginButton.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor];
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
        _registerButton.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor].CGColor;
        _registerButton.layer.borderWidth = 1.0f;
        _registerButton.titleLabel.font = [UIFont systemFontOfSize:21];
        [_registerButton setTitle:@"注册" forState:UIControlStateNormal];
        [_registerButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor] forState:UIControlStateNormal];
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
        [_forgetButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor] forState:UIControlStateNormal];
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
        [_tencentLoginButton setImage:[[UIImage imageNamed:@"more_qq"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_tencentLoginButton setTitle:@"腾讯QQ" forState:UIControlStateNormal];
        [_tencentLoginButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor] forState:UIControlStateNormal];
        _tencentLoginButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _tencentLoginButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor];
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
        [_weixinLoginButton setImage:[[UIImage imageNamed:@"more_weixin"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_weixinLoginButton setTitle:@"微信" forState:UIControlStateNormal];
        [_weixinLoginButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor] forState:UIControlStateNormal];
        _weixinLoginButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor];
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
        _leftSeperatorLine.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor];
    }
    return _leftSeperatorLine;
}

-(UIView *)rightSeperatorLine{
    if (!_rightSeperatorLine) {
        _rightSeperatorLine = [[UIView alloc]init];
        _rightSeperatorLine.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor];
    }
    return _rightSeperatorLine;
}

-(UILabel *)thirdPartyLoginLabel{
    if (!_thirdPartyLoginLabel) {
        _thirdPartyLoginLabel = [[UILabel alloc]init];
        _thirdPartyLoginLabel.text = @"使用第三方登录";
        [_thirdPartyLoginLabel sizeToFit];
        _thirdPartyLoginLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor];
        _thirdPartyLoginLabel.font = [UIFont systemFontOfSize:15];
        _thirdPartyLoginLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _thirdPartyLoginLabel;
}

@end
