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
#import "SSJHomeLoadingView.h"
#import "SSJRegistNetworkService.h"
#import "SSJNormalWebViewController.h"
#import "NSString+MoneyDisplayFormat.h"
#import "MMDrawerController.h"
#import "UIViewController+MMDrawerController.h"

static const NSInteger kCountdownLimit = 60;    //  倒计时时限
@interface SSJLoginViewController () <UITextFieldDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) SSJLoginService *loginService;

@property (nonatomic, strong) SSJRegistNetworkService *registerService;

@property (nonatomic, strong) SSJRegistNetworkService *registerNextService;

@property (nonatomic, strong) SSJRegistNetworkService *registCompleteService;

@property (nonatomic,strong)UITextField *tfPhoneNum;

@property (nonatomic,strong)UITextField *tfPassword;

@property (nonatomic,strong)UITextField *tfRegPhoneNum;

@property (nonatomic,strong)UITextField *tfRegYanZhenNum;

@property (nonatomic,strong)UITextField *tfRegPasswordNum;

//@property (nonatomic,copy)NSString *strUserAccount;
//
//@property (nonatomic,copy)NSString *strUserPassword;

@property (nonatomic,strong)UIButton *loginButton;

@property (nonatomic,strong)UIButton *loginTitleButton;

@property (nonatomic,strong)UIButton *registerButton;

@property (nonatomic,strong)UIButton *registerTitleButton;

@property (nonatomic,strong)UIButton *forgetButton;

@property (nonatomic,strong)UIButton *tencentLoginButton;

@property (nonatomic,strong)UIButton *weixinLoginButton;

@property (nonatomic,strong)UIView *leftSeperatorLine;

@property (nonatomic,strong)UIView *rightSeperatorLine;

@property (nonatomic,strong)UILabel *thirdPartyLoginLabel;

@property(nonatomic, strong) SSJHomeLoadingView *loadingView;

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

@property (nonatomic, strong) UIView *centerScrollViewOne;
@property (nonatomic, strong) UIView *centerScrollViewTwo;
//@property (nonatomic, strong) UIView *centerScrollViewThree;

@property (nonatomic, strong) UIView *numSecretBgView;

@property (nonatomic, strong) UIView *numRegSecretBgView;

/**
 三角形尖块
 */
@property (nonatomic, strong) UIImageView *triangleView;
/**
 顶部uiimgeview
 */
@property (nonatomic, strong) UIImageView *topView;

//  倒计时定时器
@property (nonatomic, strong) NSTimer *countdownTimer;

//  倒计时
@property (nonatomic) NSInteger countdown;
//验证码
@property (nonatomic, strong) UIButton *getAuthCodeBtn;

//下一步
//@property (nonatomic, strong) UIButton *regNextBtn;

@property (nonatomic, strong) UIButton *agreeButton;

@property (nonatomic, strong) UIButton *protocolButton;

/**
 code
 */
@property (nonatomic, copy) NSString *codeNum;

/**
 <#注释#>
 */
@property (nonatomic, assign) BOOL isRegisterToForgetPassword;

@end

@implementation SSJLoginViewController

#pragma mark - Lifecycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = SSJAppName();
        self.appliesTheme = NO;
        self.backgroundView.hidden = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.hidesBottomBarWhenPushed = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatetextfield:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isRegisterToForgetPassword == YES) {
        if (self.tfRegPhoneNum.text.length) {
            [self.tfRegYanZhenNum becomeFirstResponder];
        } else {
            [self.tfRegPhoneNum becomeFirstResponder];
        }
    } else {
        if (self.tfPhoneNum.text.length) {
            [self.tfPassword becomeFirstResponder];
        } else {
            [self.tfPhoneNum becomeFirstResponder];
        }
    }
    self.isRegisterToForgetPassword = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.topView];
    [self.scrollView addSubview:self.registerTitleButton];
    [self.scrollView addSubview:self.loginTitleButton];
    
    //登录
    [self.scrollView addSubview:self.centerScrollViewOne];
    [self.centerScrollViewOne addSubview:self.numSecretBgView];
    [self.numSecretBgView addSubview:self.tfPhoneNum];
    [self.numSecretBgView addSubview:self.tfPassword];
    [self.centerScrollViewOne addSubview:self.loginButton];
    [self.centerScrollViewOne addSubview:self.forgetButton];
    self.centerScrollViewOne.hidden = NO;
    
    //注册1
    [self.scrollView addSubview:self.centerScrollViewTwo];
    [self.centerScrollViewTwo addSubview:self.numRegSecretBgView];
    [self.numRegSecretBgView addSubview:self.tfRegPhoneNum];
    [self.numRegSecretBgView addSubview:self.tfRegYanZhenNum];
//    [self.centerScrollViewTwo addSubview:self.regNextBtn];
    self.centerScrollViewTwo.hidden = YES;
    
    //注册2
//    [self.scrollView addSubview:self.centerScrollViewThree];
    [self.numRegSecretBgView addSubview:self.tfRegPasswordNum];
    [self.centerScrollViewTwo addSubview:self.registerButton];
    [self.centerScrollViewTwo addSubview:self.agreeButton];
    [self.centerScrollViewTwo addSubview:self.protocolButton];
//    self.centerScrollViewThree.hidden = YES;
    
    // 只有9188、有鱼并且没有审核的情况下，显示第三方登录
    if ([SSJDefaultSource() isEqualToString:@"11501"]
        || [SSJDefaultSource() isEqualToString:@"11502"]
        || [SSJDefaultSource() isEqualToString:@"11512"]
        || [SSJDefaultSource() isEqualToString:@"11513"]) {
//        [self.centerScrollView addSubview:self.seperatorLine];
        [self.centerScrollViewOne addSubview:self.thirdPartyLoginLabel];
        [self.centerScrollViewOne addSubview:self.leftSeperatorLine];
        [self.centerScrollViewOne addSubview:self.rightSeperatorLine];
        [self.centerScrollViewOne addSubview:self.tencentLoginButton];
        [self.centerScrollViewOne addSubview:self.weixinLoginButton];
    } else {
        [self.centerScrollViewOne addSubview:self.thirdPartyLoginLabel];
        [self.centerScrollViewOne addSubview:self.leftSeperatorLine];
        [self.centerScrollViewOne addSubview:self.rightSeperatorLine];
        [self.centerScrollViewOne addSubview:self.tencentLoginButton];
    }
    
    [self ssj_showBackButtonWithTarget:self selector:@selector(goBackAction)];
    self.showNavigationBarBaseLine = NO;
    [self.scrollView addSubview:self.triangleView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor clearColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    NSMutableDictionary *titleAttributes = [self.navigationController.navigationBar.titleTextAttributes mutableCopy];
    [titleAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
//    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//        self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:21],
//                                                                        NSForegroundColorAttributeName:[UIColor whiteColor]};
//    }
    
    [self.mm_drawerController setMaximumLeftDrawerWidth:SSJSCREENWITH];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self updateConstraints];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.loginService cancel];
    [self.registerService cancel];
    [self.registerNextService cancel];
    [self.registCompleteService cancel];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = textField.text ? : @"";
    text = [text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.tfRegPhoneNum || textField == self.tfPhoneNum) {
        if (text.length > 11) {
            [CDAutoHideMessageHUD showMessage:@"最多只能输入11位手机号" inView:self.view.window duration:1];
            return NO;
        }
    } else if (textField == self.tfRegYanZhenNum) {
        if (text.length > 6) {
            [CDAutoHideMessageHUD showMessage:@"最多只能输入6位" inView:self.view.window duration:1];
            return NO;
        }
    } else if (textField == self.tfRegPasswordNum){
        NSString *text = textField.text ? : @"";
        text = [text stringByReplacingCharactersInRange:range withString:string];
        if (text.length > 15) {
            [CDAutoHideMessageHUD showMessage:@"最多只能输入15位" inView:self.view.window duration:1];
            return NO;
        }
    }
    return YES;
}

#pragma mark - SSJBaseNetworkServiceDelegate
-(void)serverDidFinished:(SSJBaseNetworkService *)service{
    [super serverDidFinished:service];
    
    if (service == self.loginService && [service.returnCode isEqualToString:@"1"]) {//登陆
        if ([[NSUserDefaults standardUserDefaults] objectForKey:SSJLastLoggedUserItemKey]) {
            __weak typeof(self) weakSelf = self;
            NSData *lastUserData = [[NSUserDefaults standardUserDefaults] objectForKey:SSJLastLoggedUserItemKey];
            SSJUserItem *lastUserItem = [NSKeyedUnarchiver unarchiveObjectWithData:lastUserData];
            
//            [self.loginService.item.loginType isEqualToString:lastUserItem.loginType]
            BOOL isSameUser = ([self.loginService.item.mobileNo isEqualToString:lastUserItem.mobileNo] && lastUserItem.mobileNo.length) || ([self.loginService.item.openId isEqualToString:lastUserItem.openId] && lastUserItem.openId.length);
            if (!isSameUser) {
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
                return;
            }
        }
        
        [self comfirmTologin];
        return;
    }
    
    if (service == self.registerService) {//获取验证码
        if ([self.registerService.returnCode isEqualToString:@"1"]) {
            [CDAutoHideMessageHUD showMessage:@"验证码发送成功"];
            [self beginCountdownIfNeeded];//倒计时
            [self.tfRegYanZhenNum becomeFirstResponder];
        } else if ([self.registerService.returnCode isEqualToString:@"1001"]) {
            [self showAlertWhenPhoneNumalreadyExists];
        } else {
            NSString *message = service.desc.length > 0 ? service.desc : SSJ_ERROR_MESSAGE;
            [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:message action:[SSJAlertViewAction actionWithTitle:@"确认" handler:NULL], nil];
        }
        return;
    }
    
    if (service == self.registerNextService) { //下一步校验验证码
        if (self.registerNextService.interfaceType == SSJRegistNetworkServiceTypeGetAuthCode) {
            //  获取验证码
            if ([self.registerNextService.returnCode isEqualToString:@"1"]) {
            //进入输入密码页面
                [CDAutoHideMessageHUD showMessage:@"验证码发送成功" inView:self.view.window duration:1];
            } else {
                self.getAuthCodeBtn.enabled = YES;
            }
            
        } else if (self.registerNextService.interfaceType == SSJRegistNetworkServiceTypeCheckAuthCode) {
            //  校验验证码校验成功
            if ([self.registerNextService.returnCode isEqualToString:@"1"]) {
//                SSJRegistCompleteViewController *registCompleteVC = [[SSJRegistCompleteViewController alloc] init];
//                registCompleteVC.mobileNo = self.mobileNo;
//                registCompleteVC.authCode = self.registerNextService.authCode;
//                registCompleteVC.finishHandle = self.finishHandle;
//                self.phoneNum = self.mobileNo;
                self.codeNum = self.registerNextService.authCode;
                self.centerScrollViewTwo.hidden = NO;
                self.centerScrollViewOne.hidden = YES;
                [self.centerScrollViewOne endEditing:YES];
                [self.centerScrollViewTwo endEditing:YES];
                //去注册
                [self gotoRegister];
//                [self.navigationController pushViewController:registCompleteVC animated:YES];
            }
        }
        return;
    }
    
    if (service == self.registCompleteService) {//完成注册
        if ([self.registCompleteService.returnCode isEqualToString:@"1"]) {
            NSDictionary *resultInfo = [service.rootElement objectForKey:@"results"];
            if (resultInfo) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SSJHaveLoginOrRegistKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                SSJUserItem *userItem = [[SSJUserItem alloc] init];
                userItem.userId = SSJUSERID();
                userItem.mobileNo = self.registCompleteService.mobileNo;
                userItem.registerState = @"1";
                userItem.loginType = @"0";
                
                //  只有保存用户登录信息成功后才算登录成功
                RACSignal *sg_1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                    [SSJUserTableManager saveUserItem:userItem success:^{
                        [subscriber sendCompleted];
                    } failure:^(NSError * _Nonnull error) {
                        [subscriber sendError:error];
                    }];
                    return nil;
                }];
                
                RACSignal *sg_2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                    if (SSJSaveAppId(resultInfo[@"appId"] ?: @"")
                        && SSJSaveAccessToken(resultInfo[@"accessToken"] ?: @"")
                        && SSJSaveUserLogined(YES)) {
                        [subscriber sendCompleted];
                    } else {
                        [subscriber sendError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"保存appid／token／登录状态失败"}]];
                    }
                    return nil;
                }];
                
                @weakify(self);
                RACSignal *sg_3 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                    @strongify(self);
                    [self syncData];
                    [[NSNotificationCenter defaultCenter] postNotificationName:SSJLoginOrRegisterNotification object:self];
                    
                    [self.tfRegPasswordNum resignFirstResponder];
                    [CDAutoHideMessageHUD showMessage:@"注册成功"];
                    // 如果用户手势密码开启，进入手势密码页面
                    [SSJUserTableManager queryProperty:@[@"motionPWD", @"motionPWDState"] forUserId:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
                        [subscriber sendNext:userItem];
                        [subscriber sendCompleted];
                    } failure:^(NSError * _Nonnull error) {
                        [subscriber sendError:error];
                    }];
                    return nil;
                }];
                
                [[[sg_1 then:^RACSignal *{
                    return sg_2;
                }] then:^RACSignal *{
                    return sg_3;
                }] subscribeNext:^(SSJUserItem *userItem) {
                    @strongify(self);
                    if ([userItem.motionPWDState boolValue]) {
                        SSJMotionPasswordViewController *motionVC = [[SSJMotionPasswordViewController alloc] init];
                        motionVC.finishHandle = ^(UIViewController *controller) {
                            
                            UITabBarController *tabVC = (UITabBarController *)((MMDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController).centerViewController;
                            UINavigationController *navi = [tabVC.viewControllers firstObject];
                            UIViewController *homeController = [navi.viewControllers firstObject];
                            controller.backController = homeController;
                            [controller ssj_backOffAction];
                            
                        };
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
                } error:^(NSError *error) {
                    [SSJAlertViewAdapter showError:error];
                }];
            }
        } else {
            [self showErrorMessage:(self.registCompleteService.desc.length ? self.registCompleteService.desc : SSJ_ERROR_MESSAGE)];
        }
    }
}

#pragma mark - Notification
-(void)updatetextfield:(id)sender{
    if (self.tfPhoneNum.isFirstResponder || self.tfPassword.isFirstResponder) {
        if (self.tfPhoneNum.text.length == 11 && self.tfPassword.text.length >= 1) {
            self.loginButton.enabled = YES;
        }else{
        self.loginButton.enabled = NO;
        }
        return;
    }
    
    if (self.tfRegPhoneNum.isFirstResponder || self.tfRegYanZhenNum.isFirstResponder || self.tfRegPasswordNum.isFirstResponder) {
        if (self.tfRegPhoneNum.text.length == 11 && self.tfRegYanZhenNum.text.length == 6 && self.tfRegPasswordNum.text.length >= 1 && self.agreeButton.selected == YES) {
            self.registerButton.enabled = YES;
        } else {
            self.registerButton.enabled = NO;
        }
    }
}

#pragma mark - Event
-(void)loginButtonClicked:(UIButton *)sender{
    if (sender.tag == 100) {
        self.registerTitleButton.selected = NO;
        if (sender.selected == YES) return;
        //清空数据
        [self clearRegisterData];
        sender.selected = !sender.selected;
        [UIView animateWithDuration:0.2 animations:^{
            self.triangleView.centerX = self.loginTitleButton.centerX;
            self.centerScrollViewOne.hidden = NO;
            [self.tfPhoneNum becomeFirstResponder];
            self.centerScrollViewTwo.hidden = YES;
            [self.centerScrollViewTwo endEditing:YES];
        }];
    }else if (sender.tag == 101) {
        [self.loginService loadLoginModelWithPassWord:self.tfPassword.text AndUserAccount:self.tfPhoneNum.text];
        [self.tfPassword resignFirstResponder];
    }
   
}

-(void)forgetButtonClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    [SSJAnaliyticsManager event:@"login_forget_pwd"];

    SSJForgetPasswordFirstStepViewController *forgetVC = [[SSJForgetPasswordFirstStepViewController alloc] init];
    forgetVC.backController = self.backController;
    forgetVC.finishHandle = ^(UIViewController *controller){
        [weakSelf.navigationController popToViewController:weakSelf animated:NO];
    };
    [self.navigationController pushViewController:forgetVC animated:NO];
}

-(void)registerButtonClicked:(UIButton *)sender{//注册
    if (sender.tag == 200) {//注册标题
        self.loginTitleButton.selected = NO;
        //清空数据，停止请求数据
        [self clearLoginData];
        self.centerScrollViewOne.hidden = YES;
        self.centerScrollViewTwo.hidden = NO;
        [self.tfRegPhoneNum becomeFirstResponder];
        [self.centerScrollViewOne endEditing:YES];
        if (sender.selected == YES)return;
        sender.selected = !sender.selected;
        [UIView animateWithDuration:0.3 animations:^{
            self.triangleView.centerX = self.registerTitleButton.centerX;
            
        }];
        return;
    }
//    __weak typeof(self) weakSelf = self;
//    [SSJAnaliyticsManager event:@"login_register"];
//
//    SSJRegistGetVerViewController *registerVc = [[SSJRegistGetVerViewController alloc] init];
//    registerVc.finishHandle = ^(UIViewController *controller){
//        //  如果是忘记密码，就返回到登录页面
//        if ([controller isKindOfClass:[SSJForgetPasswordSecondStepViewController class]]) {
//            [weakSelf.navigationController popToViewController:weakSelf animated:YES];
//        } else {
//            if (weakSelf.finishHandle) {
//                weakSelf.finishHandle(weakSelf);
//            } else {
//                [weakSelf ssj_backOffAction];
//            }
//        }
//    };
//    [self.navigationController pushViewController:registerVc animated:YES];
    
    //先验证验证码后注册请求
    [self regNextButtonClicked];
}

/**
 去注册
 */
- (void)gotoRegister
{
    if (SSJVerifyPassword(self.tfRegPasswordNum.text)) {
        [self.registCompleteService setPasswordWithMobileNo:self.tfRegPhoneNum.text authCode:self.codeNum password:self.tfRegPasswordNum.text];
    } else {
        [CDAutoHideMessageHUD showMessage:@"只能输入6-15位字母、数字组合"];
    }
}

- (void)goBackAction {
    if (self.cancelHandle) {
        self.cancelHandle(self);
    } else {
       [super goBackAction];
    }
}

-(void)qqLoginButtonClicked:(id)sender{
    [SSJAnaliyticsManager event:@"login_qq"];
    __weak typeof(self) weakSelf = self;
    [[SSJThirdPartyLoginManger shareInstance].qqLogin qqLoginWithSucessBlock:^(SSJThirdPartLoginItem *item) {
        [SSJThirdPartyLoginManger shareInstance].qqLogin = nil;
        [SSJThirdPartyLoginManger shareInstance].weixinLogin = nil;
        [weakSelf.loginService loadLoginModelWithLoginItem:item];
    }];
}

-(void)weixinLoginButtonClicked:(id)sender{
    [SSJAnaliyticsManager event:@"login_weichat"];
    __weak typeof(self) weakSelf = self;
    [[SSJThirdPartyLoginManger shareInstance].weixinLogin weixinLoginWithSucessBlock:^(SSJThirdPartLoginItem *item) {
        [SSJThirdPartyLoginManger shareInstance].qqLogin = nil;
        [SSJThirdPartyLoginManger shareInstance].weixinLogin = nil;
        [weakSelf.loginService loadLoginModelWithLoginItem:item];
    }];
    
}

- (void)showSecret:(UIButton *)button
{
    if (button.tag == 300) {
        self.tfPassword.secureTextEntry = button.selected;
    } else if(button.tag == 301) {
        self.tfRegPasswordNum.secureTextEntry = button.selected;
    }
    button.selected = !button.selected;
}

//  获取验证码
- (void)getAuthCodeAction
{
    if (!self.tfRegPhoneNum.text.length) {
        [CDAutoHideMessageHUD showMessage:@"请先输入手机号"];
        return;
    }
    
    [self.registerService getAuthCodeWithMobileNo:self.tfRegPhoneNum.text];
    self.registerService.showMessageIfErrorOccured = NO;
}

- (void)regNextButtonClicked {//验证验证码
    NSString *phoneNum = self.tfRegPhoneNum.text;
    NSString *codeNum = self.tfRegYanZhenNum.text;
    if (!codeNum.length) {
        [CDAutoHideMessageHUD showMessage:@"请先输入验证码"];
        return;
    }
    
    if (!phoneNum.length) {
        [CDAutoHideMessageHUD showMessage:@"请先输入手机号码"];
        return;
    }
    [self.registerNextService checkAuthCodeWithMobileNo:phoneNum authCode:codeNum];
}

//  同意、不同意协议
- (void)agreeProtocaolAction {
        self.agreeButton.selected = !self.agreeButton.selected;
    if (self.tfRegPhoneNum.text.length > 0 && self.tfRegYanZhenNum.text.length == 6 && self.tfRegPasswordNum.text.length >= 1 && self.agreeButton.selected == YES) {
        self.registerButton.enabled = YES;
    }else{
        self.registerButton.enabled = NO;
    }
}

- (void)clearLoginData
{
    self.tfPhoneNum.text = nil;
    self.tfPassword.text = nil;
    self.loginButton.enabled = NO;
    [self.loginService cancel];
}

- (void)clearRegisterData
{
    self.tfRegYanZhenNum.text = nil;
    self.tfRegPhoneNum.text = nil;
    self.tfRegYanZhenNum.text = nil;
    self.tfRegPasswordNum.text = nil;
    self.registerButton.enabled = NO;
    [self.registerService cancel];
//    [self.countdownTimer invalidate];//停止倒计时
//    self.countdownTimer = nil;
}

//  查看协议
- (void)checkProtocolAction {
    SSJNormalWebViewController *userAgreementVC = [SSJNormalWebViewController webViewVCWithURL:[NSURL URLWithString:SSJUserProtocolUrl]];
    userAgreementVC.title = @"用户协定";
    [self.navigationController pushViewController:userAgreementVC animated:YES];
}

#pragma mark - Private
-(void)comfirmTologin{
    //  只要登录就设置用户为已注册，因为9188账户、第三方登录没有注册就可以登录
    self.loginService.item.registerState = @"1";
    
    if (!self.loginService.item.currentBooksId) {
        self.loginService.item.currentBooksId = self.loginService.item.userId;
    }
    
    // 保存用户信息
    [[[[[[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJUserTableManager saveUserItem:self.loginService.item success:^{
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }] then:^RACSignal *{
        // 保存用户登录信息
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            if (SSJSaveAppId(self.loginService.appid)
                && SSJSaveAccessToken(self.loginService.accesstoken)
                && SSJSetUserId(self.loginService.item.userId)
                && SSJSaveUserLogined(YES)) {
                //保存账本类型个人or共享
                [self queryCurrentCategoryForUserId:self.loginService.item.userId];
                [subscriber sendCompleted];
                
            } else {
                [subscriber sendError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"存储用户登录信息失败"}]];
            }
            return nil;
        }];
    }] then:^RACSignal *{
        // 合并用户数据，即使合并失败，之后还会进行同步，所以无论成功与否都正常走接下来的流程
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [SSJLoginHelper updateTableWhenLoginWithServices:self.loginService completion:^{
                [subscriber sendCompleted];
            }];
            return nil;
        }];
    }] then:^RACSignal *{
        // 检测用户的默认数据，哪些没有就创建哪些
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [SSJUserDefaultDataCreater asyncCreateAllDefaultDataWithUserId:SSJUSERID() success:^{
                [subscriber sendCompleted];
            } failure:^(NSError *error) {
                [subscriber sendError:error];
            }];
            return nil;
        }];
    }] then:^RACSignal *{
        // 更新用户签到数据
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [SSJBookkeepingTreeStore queryCheckInInfoWithUserId:SSJUSERID() success:^(SSJBookkeepingTreeCheckInModel * _Nonnull checkInModel) {
                if (![checkInModel.lastCheckInDate isEqualToString:_loginService.checkInModel.lastCheckInDate]) {
                    [SSJBookkeepingTreeStore saveCheckInModel:_loginService.checkInModel success:NULL failure:NULL];
                    [SSJBookkeepingTreeHelper loadTreeImageWithUrlPath:_loginService.checkInModel.treeImgUrl finish:NULL];
                    [SSJBookkeepingTreeHelper loadTreeGifImageDataWithUrlPath:_loginService.checkInModel.treeGifUrl finish:NULL];
                }
                [subscriber sendCompleted];
            } failure:^(NSError * _Nonnull error) {
                [subscriber sendError:error];
            }];
            return nil;
        }];
    }] then:^RACSignal *{
        // 登录成功，做些额外的处理
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [self syncData];
            [self.loadingView show];
            [CDAutoHideMessageHUD showMessage:@"登录成功"];
            [SSJAnaliyticsManager setUserId:SSJUSERID() userName:(self.loginService.item.nickName.length ? self.loginService.item.nickName : self.loginService.item.mobileNo)];
            [[NSNotificationCenter defaultCenter] postNotificationName:SSJLoginOrRegisterNotification object:nil];
            [SSJLocalNotificationHelper cancelLocalNotificationWithKey:SSJReminderNotificationKey];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SSJHaveLoginOrRegistKey];
            [[NSUserDefaults standardUserDefaults] setInteger:self.loginService.loginType forKey:SSJUserLoginTypeKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [subscriber sendCompleted];
            return nil;
        }];
    }] then:^RACSignal *{
        // 如果用户手势密码开启，进入手势密码页面，否则走既定的页面流程
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [SSJUserTableManager queryProperty:@[@"motionPWD", @"motionPWDState"] forUserId:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
                if ([userItem.motionPWDState boolValue]) {
                    __weak typeof(self) weakSelf = self;
                    SSJMotionPasswordViewController *motionVC = [[SSJMotionPasswordViewController alloc] init];
                    motionVC.finishHandle = ^(UIViewController *controller) {
                        UITabBarController *tabVC = (UITabBarController *)((MMDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController).centerViewController;
                        UINavigationController *navi = [tabVC.viewControllers firstObject];
                        UIViewController *homeController = [navi.viewControllers firstObject];

                        controller.backController = homeController;
                        [controller ssj_backOffAction];
                    };
                    motionVC.backController = self.backController;
                    if (userItem.motionPWD.length) {
                        motionVC.type = SSJMotionPasswordViewControllerTypeVerification;
                    } else {
                        motionVC.type = SSJMotionPasswordViewControllerTypeSetting;
                    }
                    [weakSelf.navigationController pushViewController:motionVC animated:YES];
                } else {
                    if (self.finishHandle) {
                        self.finishHandle(self);
                    } else {
                        [self ssj_backOffAction];
                    }
                }
                [subscriber sendCompleted];
            } failure:^(NSError * _Nonnull error) {
                [subscriber sendError:error];
            }];
            return nil;
        }];
    }] subscribeError:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

// 登录成功后保存当前账本类型：共享or个人
- (void )queryCurrentCategoryForUserId:(NSString *)userId {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSString *currentBookId = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userId];
        BOOL isShareBook = [db boolForQuery:@"select count(*) from bk_books_type where cbooksid = ? and operatortype <> 2 and cuserid = ?",currentBookId,SSJUSERID()];
        SSJSaveBooksCategory(!isShareBook);
    }];
}

- (void)syncData {
    [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:^(SSJDataSynchronizeType type){
        [CDAutoHideMessageHUD showMessage:@"同步成功"];
    } failure:^(SSJDataSynchronizeType type, NSError *error) {
        [CDAutoHideMessageHUD showMessage:@"同步失败"];
    }];
}
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
        self.getAuthCodeBtn.enabled = NO;
        [self.getAuthCodeBtn setTitle:[NSString stringWithFormat:@"%ds",(int)self.countdown] forState:UIControlStateDisabled];
    } else {
        self.getAuthCodeBtn.enabled = YES;
        [self.countdownTimer invalidate];
        _countdownTimer = nil;
    }
    self.countdown --;
}

- (void)showErrorMessage:(NSString *)message {
    SSJAlertViewAction *sureAction = [SSJAlertViewAction actionWithTitle:@"确定" handler:NULL];
    [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:message action:sureAction, nil];
}


/**
 当手机号已经存在的时候弹框
 */
- (void)showAlertWhenPhoneNumalreadyExists
{
    __weak typeof(self) weakSelf = self;
    NSString *oldStr = @"该手机号已经被注册，若忘记密码，请使用忘记密码功能找回密码。";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:oldStr preferredStyle:UIAlertControllerStyleAlert];
    
    //修改标题的内容，字号，颜色。使用的key值是“attributedTitle”
    NSMutableAttributedString *attMessate = [oldStr attributeStrWithTargetStr:@"忘记密码" range:NSMakeRange(0, 0) color:[UIColor ssj_colorWithHex:@"ea4a64"]];
    [attMessate addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7] range:NSMakeRange(0, attMessate.length - 1)];
    
    //修改按钮的颜色，同上可以使用同样的方法修改内容，样式
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"忘记密码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        SSJForgetPasswordFirstStepViewController *forgetVC = [[SSJForgetPasswordFirstStepViewController alloc] init];
        self.isRegisterToForgetPassword = YES;
        forgetVC.mobileNo = weakSelf.registerService.mobileNo;
        forgetVC.finishHandle = weakSelf.finishHandle;
        forgetVC.finishPassHandle = ^(NSString *num){
            weakSelf.tfPhoneNum.text = num;
            weakSelf.centerScrollViewOne.hidden = NO;
            weakSelf.centerScrollViewTwo.hidden = YES;
            self.triangleView.centerX = self.loginTitleButton.centerX;
            [weakSelf.centerScrollViewTwo endEditing:YES];
            weakSelf.loginTitleButton.selected = YES;
            weakSelf.registerTitleButton.selected = NO;
            if (num.length < 1) {
                [weakSelf.tfPhoneNum becomeFirstResponder];
            } else {
                [weakSelf.tfPassword becomeFirstResponder];
            }
            
        };
        [weakSelf.view endEditing:YES];
        [weakSelf.navigationController pushViewController:forgetVC animated:YES];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    if (SSJSystemVersion() >= 8.3) {
        [defaultAction setValue:[UIColor ssj_colorWithHex:@"ea4a64"] forKey:@"_titleTextColor"];
        [cancelAction setValue:[UIColor ssj_colorWithHex:@"444444"] forKey:@"_titleTextColor"];
        [alertController setValue:attMessate forKey:@"attributedMessage"];
    }
        
    
    
    [alertController addAction:defaultAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateConstraints
{
//    self.scrollView.frame = self.view.bounds;
    self.topView.frame = CGRectMake(0, 0, self.view.width, 206);
    
    self.loginTitleButton.frame = CGRectMake(0, self.topView.height - 45, self.view.width * 0.5, 45);
    self.registerTitleButton.left = self.view.width * 0.5;
    self.registerTitleButton.bottom = self.topView.bottom;
    self.registerTitleButton.height = 45;
    self.registerTitleButton.width = self.view.width * 0.5;
    self.triangleView.centerX = self.loginTitleButton.centerX;
    self.triangleView.bottom = self.topView.bottom;
    
    self.centerScrollViewOne.frame = CGRectMake(0, CGRectGetMaxY(self.topView.frame), self.view.width, self.view.height - self.topView.height);
    self.centerScrollViewTwo.frame = CGRectMake(0, CGRectGetMaxY(self.topView.frame), self.view.width, self.view.height - self.topView.height);
//    self.centerScrollViewThree.frame = CGRectMake(0, CGRectGetMaxY(self.topView.frame), self.view.width, self.view.height - self.topView.height);
    
    self.numSecretBgView.frame = CGRectMake(15, 35, self.view.width - 30, 100);
    
    self.tfPhoneNum.frame = CGRectMake(0, 0, self.numSecretBgView.width, 50);
    self.tfPassword.frame = CGRectMake(0, CGRectGetMaxY(self.tfPhoneNum.frame), self.numSecretBgView.width, 50);
    
    self.loginButton.frame = CGRectMake(15, CGRectGetMaxY(self.numSecretBgView.frame) + 25, self.view.width - 30, 44);

    self.forgetButton.right = self.view.width - 15;
    self.forgetButton.top= CGRectGetMaxY(self.loginButton.frame) + 15;
    
    // 只有9188、有鱼并且没有审核的情况下，显示第三方登录
    if ([SSJDefaultSource() isEqualToString:@"11501"]
        || [SSJDefaultSource() isEqualToString:@"11502"]
        || [SSJDefaultSource() isEqualToString:@"11512"]
        || [SSJDefaultSource() isEqualToString:@"11513"]) {
        self.thirdPartyLoginLabel.centerX = SSJSCREENWITH * 0.5;
        self.thirdPartyLoginLabel.bottom = self.centerScrollViewOne.height - 100;
        
        self.leftSeperatorLine.centerY = self.rightSeperatorLine.centerY = self.thirdPartyLoginLabel.centerY;
        self.leftSeperatorLine.width = self.rightSeperatorLine.width = 45;
        self.leftSeperatorLine.left =  (self.view.width - self.thirdPartyLoginLabel.width) * 0.5 - 55;
        self.rightSeperatorLine.left = CGRectGetMaxX(self.thirdPartyLoginLabel.frame) + 10;
        self.leftSeperatorLine.height = self.rightSeperatorLine.height = 1.0f / [UIScreen mainScreen].scale;
        if ([WXApi isWXAppInstalled]) {//安装微信
            self.weixinLoginButton.top = self.tencentLoginButton.top = CGRectGetMaxY(self.thirdPartyLoginLabel.frame) + 25;
            self.weixinLoginButton.centerX = self.thirdPartyLoginLabel.centerX - 90;
            self.tencentLoginButton.centerX = self.thirdPartyLoginLabel.centerX + 90;
            self.weixinLoginButton.hidden = NO;
            
        } else {
            self.tencentLoginButton.top = CGRectGetMaxY(self.thirdPartyLoginLabel.frame) + 25;
            self.tencentLoginButton.centerX = self.thirdPartyLoginLabel.centerX;
            self.weixinLoginButton.hidden = YES;
        }
    } else {
        self.thirdPartyLoginLabel.centerX = SSJSCREENWITH * 0.5;
        self.thirdPartyLoginLabel.bottom = self.centerScrollViewOne.height - 100;
        self.leftSeperatorLine.centerY = self.rightSeperatorLine.centerY = self.thirdPartyLoginLabel.centerY;
        self.leftSeperatorLine.width = self.rightSeperatorLine.width = 45;
        self.leftSeperatorLine.left =  (self.view.width - self.thirdPartyLoginLabel.width) * 0.5 - 55;
        self.rightSeperatorLine.left = CGRectGetMaxX(self.thirdPartyLoginLabel.frame) + 10;
        self.leftSeperatorLine.height = self.rightSeperatorLine.height = 1.0f / [UIScreen mainScreen].scale;
        self.tencentLoginButton.top = CGRectGetMaxY(self.thirdPartyLoginLabel.frame) + 25;
        self.tencentLoginButton.centerX = self.thirdPartyLoginLabel.centerX;
        self.weixinLoginButton.hidden = YES;
    }
    
    //注册
    self.numRegSecretBgView.size = CGSizeMake(self.view.width - 30, 150);
    self.numRegSecretBgView.top = self.numSecretBgView.top;
    self.numRegSecretBgView.left = 15;
    
    self.tfRegPhoneNum.frame = CGRectMake(0, 0, self.numSecretBgView.width, 50);
    self.tfRegYanZhenNum.frame = CGRectMake(0, CGRectGetMaxY(self.tfRegPhoneNum.frame), self.numSecretBgView.width, 50);
    
//    self.regNextBtn.size = self.loginButton.size;
//    self.regNextBtn.left = 15;
//    self.regNextBtn.top = self.loginButton.top;
    
    self.tfRegPasswordNum.top = CGRectGetMaxY(self.tfRegYanZhenNum.frame);//self.tfRegYanZhenNum.top;
    self.tfRegPasswordNum.height = self.tfRegPhoneNum.height;
    self.tfRegPasswordNum.left = 0;
    self.tfRegPasswordNum.width = self.numSecretBgView.width;
    
    self.registerButton.top = CGRectGetMaxY(self.numRegSecretBgView.frame) + 20;
    self.registerButton.left = self.numRegSecretBgView.left;
    self.registerButton.width = self.numRegSecretBgView.width;
    self.registerButton.height = 45;
    
    self.agreeButton.left = self.registerButton.left;
    self.agreeButton.top = CGRectGetMaxY(self.registerButton.frame) + 15;
    
    self.protocolButton.left = CGRectGetMaxX(self.agreeButton.frame) + 3;
    self.protocolButton.centerY = self.agreeButton.centerY;
}


#pragma mark - Getter
- (TPKeyboardAvoidingScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.contentSize = CGSizeMake(0, self.view.height);
    }
    return _scrollView;
}

- (UIView *)centerScrollViewOne
{
    if (!_centerScrollViewOne) {
        _centerScrollViewOne = [[UIView alloc] init];
    }
    return _centerScrollViewOne;
}

- (UIView *)centerScrollViewTwo
{
    if (!_centerScrollViewTwo) {
        _centerScrollViewTwo = [[UIView alloc] init];
    }
    return _centerScrollViewTwo;
}

//- (UIView *)centerScrollViewThree
//{
//    if (!_centerScrollViewThree) {
//        _centerScrollViewThree = [[UIView alloc] init];
//    }
//    return _centerScrollViewThree;
//}

- (SSJLoginService *)loginService{
    if (_loginService==nil) {
        _loginService=[[SSJLoginService alloc]initWithDelegate:self];
        _loginService.showLodingIndicator = YES;
    }
    return _loginService;
}

- (SSJRegistNetworkService *)registerService {
    if (!_registerService) {
        _registerService = [[SSJRegistNetworkService alloc] initWithDelegate:self type:SSJRegistAndForgetPasswordTypeRegist];
        _registerService.showLodingIndicator = YES;
    }
    return _registerService;
}

- (SSJRegistNetworkService *)registerNextService {
    if (!_registerNextService) {
        _registerNextService = [[SSJRegistNetworkService alloc] initWithDelegate:self type:SSJRegistAndForgetPasswordTypeRegist];
        _registerNextService.showLodingIndicator = YES;
    }
    return _registerNextService;
}

- (SSJRegistNetworkService *)registCompleteService {
    if (!_registCompleteService) {
        _registCompleteService = [[SSJRegistNetworkService alloc] initWithDelegate:self type:SSJRegistAndForgetPasswordTypeRegist];
        _registCompleteService.showLodingIndicator = YES;
    }
    return _registCompleteService;
}

- (SSJHomeLoadingView *)loadingView{
    if (!_loadingView) {
        _loadingView = [[SSJHomeLoadingView alloc] init];
    }
    return _loadingView;
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


- (UITextField*)tfPhoneNum{
    if (!_tfPhoneNum) {
        UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 50)];
        leftView.image = [UIImage imageNamed:@"zhuanghu"];
        leftView.contentMode = UIViewContentModeCenter;
        _tfPhoneNum = [[UITextField alloc] init];
        _tfPhoneNum.textColor = [UIColor ssj_colorWithHex:@"333333"];
        _tfPhoneNum.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfPhoneNum.placeholder = @"请输入手机号";
        _tfPhoneNum.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_tfPhoneNum setValue:[UIColor ssj_colorWithHex:@"999999"] forKeyPath:@"_placeholderLabel.textColor"];
        [_tfPhoneNum setValue:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4] forKeyPath:@"_placeholderLabel.font"];
        
        [_tfPhoneNum ssj_setBorderColor:[UIColor ssj_colorWithHex:@"cccccc"]];
        [_tfPhoneNum ssj_setBorderStyle:SSJBorderStyleBottom];
        [_tfPhoneNum ssj_setBorderWidth:1];
        
        _tfPhoneNum.delegate = self;
        _tfPhoneNum.keyboardType = UIKeyboardTypeNumberPad;
        _tfPhoneNum.leftView = leftView;
        _tfPhoneNum.leftViewMode = UITextFieldViewModeAlways;
    }
    return _tfPhoneNum;
}

- (UITextField*)tfRegPhoneNum{
    if (!_tfRegPhoneNum) {
        UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 50)];
        leftView.image = [UIImage imageNamed:@"zhuanghu"];
        leftView.contentMode = UIViewContentModeCenter;
        _tfRegPhoneNum = [[UITextField alloc] init];
        _tfRegPhoneNum.textColor = [UIColor ssj_colorWithHex:@"333333"];
        _tfRegPhoneNum.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfRegPhoneNum.placeholder = @"请输入手机号";
        _tfRegPhoneNum.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_tfRegPhoneNum setValue:[UIColor ssj_colorWithHex:@"999999"] forKeyPath:@"_placeholderLabel.textColor"];
        [_tfRegPhoneNum setValue:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4] forKeyPath:@"_placeholderLabel.font"];
        [_tfRegPhoneNum ssj_setBorderStyle:SSJBorderStyleBottom];
        [_tfRegPhoneNum ssj_setBorderWidth:1];
        [_tfRegPhoneNum ssj_setBorderColor:[UIColor ssj_colorWithHex:@"cccccc"]];
        
        _tfRegPhoneNum.delegate = self;
        _tfRegPhoneNum.keyboardType = UIKeyboardTypeNumberPad;
        _tfRegPhoneNum.leftView = leftView;
        _tfRegPhoneNum.leftViewMode = UITextFieldViewModeAlways;
    }
    return _tfRegPhoneNum;
}

-(UITextField*)tfPassword{
    if (!_tfPassword) {
        UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 50)];
        leftView.image = [UIImage imageNamed:@"mima"];
        leftView.contentMode = UIViewContentModeCenter;
        UIButton *rightView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 50)];
        [rightView setImage:[UIImage imageNamed:@"founds_xianshi"] forState:UIControlStateSelected];
        [rightView setImage:[UIImage imageNamed:@"founds_yincang"] forState:UIControlStateNormal];
        [rightView addTarget:self action:@selector(showSecret:) forControlEvents:UIControlEventTouchUpInside];
        rightView.tag = 300;
        _tfPassword = [[UITextField alloc] init];
        _tfPassword.textColor = [UIColor ssj_colorWithHex:@"333333"];
        _tfPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfPassword.placeholder = @"请输入账户密码";
        _tfPassword.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_tfPassword setValue:[UIColor ssj_colorWithHex:@"999999"] forKeyPath:@"_placeholderLabel.textColor"];
        [_tfPassword setValue:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4] forKeyPath:@"_placeholderLabel.font"];
        
        _tfPassword.keyboardType = UIKeyboardTypeASCIICapable;
        _tfPassword.delegate = self;
        _tfPassword.leftView = leftView;
        _tfPassword.rightView = rightView;
        _tfPassword.leftViewMode = UITextFieldViewModeAlways;
        _tfPassword.rightViewMode = UITextFieldViewModeAlways;
        self.tfPassword.secureTextEntry = YES;
    }
    return _tfPassword;
}

-(UITextField*)tfRegPasswordNum{
    if (!_tfRegPasswordNum) {
        UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 50)];
        leftView.image = [UIImage imageNamed:@"mima"];
        leftView.contentMode = UIViewContentModeCenter;
        UIButton *rightView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 50)];
        [rightView setImage:[UIImage imageNamed:@"founds_xianshi"] forState:UIControlStateSelected];
        [rightView setImage:[UIImage imageNamed:@"founds_yincang"] forState:UIControlStateNormal];
        [rightView addTarget:self action:@selector(showSecret:) forControlEvents:UIControlEventTouchUpInside];
        rightView.tag = 301;
        _tfRegPasswordNum = [[UITextField alloc] init];
        _tfRegPasswordNum.textColor = [UIColor ssj_colorWithHex:@"333333"];
        _tfRegPasswordNum.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfRegPasswordNum.placeholder = @"请输入6~15位数字和字母组合的密码";
        _tfRegPasswordNum.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_tfRegPasswordNum setValue:[UIColor ssj_colorWithHex:@"999999"] forKeyPath:@"_placeholderLabel.textColor"];
        [_tfRegPasswordNum setValue:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4] forKeyPath:@"_placeholderLabel.font"];
        
        _tfRegPasswordNum.keyboardType = UIKeyboardTypeASCIICapable;
        _tfRegPasswordNum.delegate = self;
        _tfRegPasswordNum.leftView = leftView;
        _tfRegPasswordNum.rightView = rightView;
        _tfRegPasswordNum.leftViewMode = UITextFieldViewModeAlways;
        _tfRegPasswordNum.rightViewMode = UITextFieldViewModeAlways;
//        _tfRegPasswordNum.backgroundColor = [UIColor ssj_colorWithHex:@"cccccc" alpha:0.1];
        self.tfRegPasswordNum.secureTextEntry = YES;
    }
    return _tfRegPasswordNum;
}

-(UITextField*)tfRegYanZhenNum{
    if (!_tfRegYanZhenNum) {
        UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 50)];
        leftView.image = [UIImage imageNamed:@"yanzheng"];
        leftView.contentMode = UIViewContentModeCenter;
        _tfRegYanZhenNum = [[UITextField alloc] init];
        _tfRegYanZhenNum.textColor = [UIColor ssj_colorWithHex:@"333333"];
        _tfRegYanZhenNum.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfRegYanZhenNum.placeholder = @"请输入验证码";
        _tfRegYanZhenNum.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_tfRegYanZhenNum setValue:[UIColor ssj_colorWithHex:@"999999"] forKeyPath:@"_placeholderLabel.textColor"];
        [_tfRegYanZhenNum setValue:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4] forKeyPath:@"_placeholderLabel.font"];
        [_tfRegYanZhenNum ssj_setBorderColor:[UIColor ssj_colorWithHex:@"cccccc"]];
        [_tfRegYanZhenNum ssj_setBorderStyle:SSJBorderStyleBottom | SSJBorderStyleTop];
        [_tfRegYanZhenNum ssj_setBorderWidth:1];
        _tfRegYanZhenNum.keyboardType = UIKeyboardTypeNumberPad;
        _tfRegYanZhenNum.delegate = self;
        _tfRegYanZhenNum.leftView = leftView;
        _tfRegYanZhenNum.rightView = self.getAuthCodeBtn;
        _tfRegYanZhenNum.leftViewMode = UITextFieldViewModeAlways;
        _tfRegYanZhenNum.rightViewMode = UITextFieldViewModeAlways;
        
    }
    return _tfRegYanZhenNum;
}

- (UIButton*)loginButton{
    if (!_loginButton) {
        _loginButton = [[UIButton alloc]init];
        _loginButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
        _loginButton.enabled = NO;
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"f9cbd0"] forState:UIControlStateDisabled];
        [_loginButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"ea4a64"] forState:UIControlStateNormal];
        _loginButton.layer.cornerRadius = 4;
        _loginButton.clipsToBounds = YES;
        _loginButton.tag = 101;
        [_loginButton addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

- (UIButton*)loginTitleButton{
    if (!_loginTitleButton) {
        _loginTitleButton = [[UIButton alloc]init];
        _loginTitleButton.selected = YES;
        _loginTitleButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
        [_loginTitleButton setTitle:@"登录" forState:UIControlStateNormal];
        [_loginTitleButton setTitleColor:[UIColor ssj_colorWithHex:@"eb4a64" alpha:0.6] forState:UIControlStateNormal];
        [_loginTitleButton setTitleColor:[UIColor ssj_colorWithHex:@"eb4a64"] forState:UIControlStateSelected];
        _loginTitleButton.tag = 100;
        
        [_loginTitleButton addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginTitleButton;
}

- (UIButton*)registerButton{
    if (!_registerButton) {
        _registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _registerButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
        [_registerButton setTitle:@"注册" forState:UIControlStateNormal];
        [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_registerButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"f9cbd0"] forState:UIControlStateDisabled];
        [_registerButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"ea4a64"] forState:UIControlStateNormal];
        _registerButton.layer.cornerRadius = 4;
        _registerButton.clipsToBounds = YES;
        _registerButton.tag = 201;
        _registerButton.enabled = NO;
        [_registerButton addTarget:self action:@selector(registerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerButton;
}

//- (UIButton*)regNextBtn{
//    if (!_regNextBtn) {
//        _regNextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _regNextBtn.titleLabel.font = [UIFont systemFontOfSize:19];
//        [_regNextBtn setTitle:@"下一步" forState:UIControlStateNormal];
//        [_regNextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [_regNextBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"f9cbd0"] forState:UIControlStateDisabled];
//        [_regNextBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"ea4a64"] forState:UIControlStateNormal];
//        _regNextBtn.enabled = NO;
//        _regNextBtn.layer.cornerRadius = 4;
//        _regNextBtn.clipsToBounds = YES;
//        [_regNextBtn addTarget:self action:@selector(regNextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _regNextBtn;
//}

- (UIButton*)registerTitleButton{
    if (!_registerTitleButton) {
        _registerTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _registerTitleButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
        [_registerTitleButton setTitle:@"注册" forState:UIControlStateNormal];
        [_registerTitleButton setTitleColor:[UIColor ssj_colorWithHex:@"eb4a64" alpha:0.6] forState:UIControlStateNormal];
        [_registerTitleButton setTitleColor:[UIColor ssj_colorWithHex:@"eb4a64"] forState:UIControlStateSelected];
        _registerTitleButton.tag = 200;
        [_registerTitleButton addTarget:self action:@selector(registerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerTitleButton;
}

-(UIButton*)forgetButton{
    if (!_forgetButton) {
        _forgetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _forgetButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [_forgetButton setTitle:@"忘记密码?" forState:UIControlStateNormal];
        [_forgetButton setTitleColor:[UIColor ssj_colorWithHex:@"666666"] forState:UIControlStateNormal];
        [_forgetButton addTarget:self action:@selector(forgetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_forgetButton sizeToFit];
    }
    return _forgetButton;
}

-(UIButton *)tencentLoginButton{
    if (!_tencentLoginButton) {
        _tencentLoginButton = [[UIButton alloc]init];
        [_tencentLoginButton setImage:[UIImage imageNamed:@"login_qq"] forState:UIControlStateNormal];
//        _tencentLoginButton.size = CGSizeMake(35, 35);
        [_tencentLoginButton sizeToFit];
        _tencentLoginButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor];
        _tencentLoginButton.contentMode = UIViewContentModeCenter;
        [_tencentLoginButton addTarget:self action:@selector(qqLoginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tencentLoginButton;
}

-(UIButton *)weixinLoginButton{
    if (!_weixinLoginButton) {
        _weixinLoginButton = [[UIButton alloc]init];
        [_weixinLoginButton setImage:[UIImage imageNamed:@"login_weixin"] forState:UIControlStateNormal];
//        _weixinLoginButton.size = CGSizeMake(35, 35);
        [_weixinLoginButton sizeToFit];
        _weixinLoginButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor];
        _weixinLoginButton.contentMode = UIViewContentModeCenter;
        [_weixinLoginButton addTarget:self action:@selector(weixinLoginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _weixinLoginButton;
}

-(UIView *)leftSeperatorLine{
    if (!_leftSeperatorLine) {
        _leftSeperatorLine = [[UIView alloc]init];
        _leftSeperatorLine.backgroundColor = [UIColor ssj_colorWithHex:@"666666" alpha:0.2];
    }
    return _leftSeperatorLine;
}

-(UIView *)rightSeperatorLine{
    if (!_rightSeperatorLine) {
        _rightSeperatorLine = [[UIView alloc]init];
        _rightSeperatorLine.backgroundColor = [UIColor ssj_colorWithHex:@"666666" alpha:0.2];
    }
    return _rightSeperatorLine;
}


-(UILabel *)thirdPartyLoginLabel{
    if (!_thirdPartyLoginLabel) {
        _thirdPartyLoginLabel = [[UILabel alloc]init];
        _thirdPartyLoginLabel.text = @"使用第三方登录";
        [_thirdPartyLoginLabel sizeToFit];
        _thirdPartyLoginLabel.textColor = [UIColor ssj_colorWithHex:@"666666"];
        _thirdPartyLoginLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _thirdPartyLoginLabel.textAlignment = NSTextAlignmentCenter;
        [_thirdPartyLoginLabel sizeToFit];
    }
    return _thirdPartyLoginLabel;
}

- (UIImageView *)triangleView
{
    if (!_triangleView) {
        _triangleView = [self drawTriangle];
    }
    return _triangleView;
}

- (UIImageView *)topView
{
    if (!_topView) {
        _topView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_login"]];
    }
    return _topView;
}

- (UIView *)numSecretBgView
{
    if (!_numSecretBgView) {
        _numSecretBgView = [[UIView alloc] init];
        _numSecretBgView.backgroundColor = [UIColor ssj_colorWithHex:@"cccccc" alpha:0.2];
        _numSecretBgView.layer.cornerRadius = 4;
        _numSecretBgView.clipsToBounds = YES;
    }
    return _numSecretBgView;
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

- (UIButton *)getAuthCodeBtn {
    if (!_getAuthCodeBtn) {
        _getAuthCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _getAuthCodeBtn.size = CGSizeMake(95, 30);
        _getAuthCodeBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [_getAuthCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_getAuthCodeBtn setTitleColor:[UIColor ssj_colorWithHex:@"#ea4a64"] forState:UIControlStateNormal];
        [_getAuthCodeBtn setTitleColor:[UIColor ssj_colorWithHex:@"#f9cbd0"] forState:UIControlStateDisabled];
        [_getAuthCodeBtn addTarget:self action:@selector(getAuthCodeAction) forControlEvents:UIControlEventTouchUpInside];
        [_getAuthCodeBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:@"f9cbd0"]];
        [_getAuthCodeBtn ssj_setBorderStyle:SSJBorderStyleLeft];
        [_getAuthCodeBtn ssj_setBorderWidth:1];
        [_getAuthCodeBtn ssj_setBorderInsets:UIEdgeInsetsMake(4, 5, 4, 5)];
    }
    return _getAuthCodeBtn;
}

- (UIButton *)agreeButton {
    if (!_agreeButton) {
        _agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _agreeButton.size = CGSizeMake(12, 12);
        _agreeButton.selected = YES;
        [_agreeButton setImage:nil forState:UIControlStateNormal];
        [_agreeButton setImage:[[UIImage imageNamed:@"register_agreement"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
        _agreeButton.tintColor = [UIColor ssj_colorWithHex:@"ea4a64"];
        [_agreeButton addTarget:self action:@selector(agreeProtocaolAction) forControlEvents:UIControlEventTouchUpInside];
        [_agreeButton ssj_setBorderWidth:1];
        [_agreeButton ssj_setBorderStyle:SSJBorderStyleAll];
        [_agreeButton ssj_setBorderColor:[UIColor ssj_colorWithHex:@"ea4a64"]];
    }
    return _agreeButton;
}

- (UIButton *)protocolButton {
    if (!_protocolButton) {
        _protocolButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _protocolButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        NSString *oldStr = @"我已阅读并同意用户协定";
        [_protocolButton setAttributedTitle:[oldStr attributeStrWithTargetStr:@"用户协定" range:NSMakeRange(0, 0) color:[UIColor ssj_colorWithHex:@"ea4a64"]] forState:UIControlStateNormal];
        [_protocolButton setTitleColor:[UIColor ssj_colorWithHex:@"666666"] forState:UIControlStateNormal];
        [_protocolButton sizeToFit];
        [_protocolButton addTarget:self action:@selector(checkProtocolAction) forControlEvents:UIControlEventTouchUpInside];
        _protocolButton.left = self.agreeButton.right + 10;
        _protocolButton.centerY = self.agreeButton.centerY;
    }
    return _protocolButton;
}
@end
