//
//  SSJLoginVerifyPhoneNumViewModel.m
//  SuiShouJi
//
//  Created by yi cai on 2017/6/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJLoginVerifyPhoneNumViewModel.h"
#import "SSJBaseNetworkService.h"

#import "SSJThirdPartLoginItem.h"
#import "SSJUserItem.h"
#import "SSJBookkeepingTreeCheckInModel.h"
#import "SSJCustomCategoryItem.h"


#import "SSJStringAddition.h"
#import "SSJWeiXinLoginHelper.h"
#import "SSJLoginHelper.h"
#import "SSJBookkeepingTreeHelper.h"
#import "SSJLocalNotificationHelper.h"

#import "SSJUserTableManager.h"
#import "SSJUserDefaultDataCreater.h"
#import "GeTuiSdk.h"
#import "SSJDatabaseQueue.h"
#import "SSJBookkeepingTreeStore.h"

#import "SSJThirdPartyLoginManger.h"

#import "SSJMotionPasswordViewController.h"
#import "MMDrawerController.h"

@interface SSJLoginVerifyPhoneNumViewModel ()
/**<#注释#>*/
@property (nonatomic, strong) SSJBaseNetworkService *netWorkService;

/**wx*/
//@property (nonatomic, strong) SSJWeiXinLoginHelper *wxLoginHelper;

//  登录方式
@property (assign, nonatomic) SSJLoginType loginType;

//登录用户的appid
@property (nonatomic,strong) NSString *appid;

@property (nonatomic,strong) SSJUserItem *userItem;

@property (nonatomic, strong) SSJBookkeepingTreeCheckInModel *checkInModel;

/**openId*/
@property (nonatomic, copy) NSString *openId;


@end

@implementation SSJLoginVerifyPhoneNumViewModel
- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

#pragma mark - Private

/**
 验证手机号请求

 @param phoneNum 手机号
 @param subscriber 订阅者
 */
- (void)verityPhoneNumWithPhone:(NSString *)phoneNum subscriber:(id<RACSubscriber>) subscriber {
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:SSJUSERID() forKey:@"cuserId"];
    [paramDic setObject:phoneNum forKey:@"cmobileNo"];
    [self.netWorkService request:@"/chargebook/user/check_cphoneExist.go" params:paramDic success:^(SSJBaseNetworkService * _Nonnull service) {
        [subscriber sendNext:service.rootElement];
        [subscriber sendCompleted];
    } failure:^(SSJBaseNetworkService * _Nonnull service) {
        [CDAutoHideMessageHUD showMessage:service.desc];
        [subscriber sendError:nil];
    }];
}


/**
 第三方登录
 */
- (void)thirdLoginWithLoginItem:(SSJThirdPartLoginItem *)item subscriber:(id<RACSubscriber>) subscriber {
    self.netWorkService.showLodingIndicator = YES;
    NSString *strAcctID = @"130313003";
    NSString *strSignType = @"1";
    NSString *strKey = @"iwannapie?!";
    NSString *type = @"";
    self.openId = item.openID;
    if (item.loginType == SSJLoginTypeQQ) {
        type = @"qq";
    }else if (item.loginType == SSJLoginTypeWeiXin){
        type = @"wechat";
    }
    NSString *strSign=[NSString stringWithFormat:@"signType=%@&merchantacctId=%@&auth_token=%@&key=%@",strSignType,strAcctID,item.openID,strKey];
    NSString *strmd5Sign=[[strSign ssj_md5HexDigest]uppercaseString];
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    //imei
    NSString *imei = [UIDevice currentDevice].identifierForVendor.UUIDString;
    
    //手机型号
    NSString* phoneModel = SSJPhoneModel();
    
    //手机系统版本
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    
    //个推id
    NSString *getuiId = [GeTuiSdk clientId];
    
    [dict setObject:strAcctID forKey:@"merchantacctId"];
    [dict setObject:strSignType forKey:@"signType"];
    [dict setObject:strmd5Sign forKey:@"signMsg"];
    [dict setObject:SSJUSERID() forKey:@"cuserid"];
    [dict setObject:item.openID forKey:@"auth_token"];
    [dict setObject:item.portraitURL forKey:@"cicon"];
    [dict setObject:type forKey:@"type"];
    [dict setObject:[item.nickName ssj_emojiFilter] forKey:@"crealname"];
    [dict setObject:imei forKey:@"cimei"];
    [dict setObject:phoneModel forKey:@"cmodel"];
    [dict setObject:phoneVersion forKey:@"cphoneos"];
    [dict setObject:item.userGender forKey:@"cgender"];
    [dict setObject:item.unionId forKey:@"cunionid"];
    [dict setObject:getuiId ?: @"" forKey:@"cgetuiid"];

    [self.netWorkService request:SSJURLWithAPI(@"/oauth/oauthlogin.go") params:dict success:^(SSJBaseNetworkService * _Nonnull service) {
        [subscriber sendNext:service.rootElement];
        [subscriber sendCompleted];
    } failure:^(SSJBaseNetworkService * _Nonnull service) {
        [subscriber sendError:nil];
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


/**
 获取验证码

 @param type 注册or忘记密码
 @param channelType 短信or语音
 @param subscriber <#subscriber description#>
 */
- (void)verCode:(SSJRegistAndForgetPasswordType)type channelType:(SSJLoginAndRegisterPasswordChannelType)channelType subscriber:(id<RACSubscriber>) subscriber {
    //                (mobileNo+timeStamp+key) MD5加密
    //发送验证码请求
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    u_long time = [[NSDate date] timeIntervalSince1970];
    NSString *strKey = @"iwannapie?!";
    NSString *strSign = [NSString stringWithFormat:@"%@%@%@",self.phoneNum,@(time),strKey];
    strSign = [[strSign ssj_md5HexDigest] uppercaseString];
    
    [param setObject:self.phoneNum  forKey:@"cmobileNo"];
    [param setObject:(type==SSJRegistAndForgetPasswordTypeRegist)?@"13":@"14" forKey:@"yzmType"];//验证码业务类型，13注册 14找回密码
    [param setObject:(channelType == SSJLoginAndRegisterPasswordChannelTypeSMS) ? @"0" : @"1" forKey:@"channelType"];//验证码类型： 0短信 1语音 , 默认为0；
    
    [param setObject:@(time) forKey:@"timeStamp"];
    [param setObject:strSign forKey:@"signMsg"];
    [param setObject:@"" forKey:@"imgYzm"];
    
    [self.netWorkService request:@"/chargebook/user/send_sms.go" params:param success:^(SSJBaseNetworkService * _Nonnull service) {
        [subscriber sendNext:service.rootElement];
        [subscriber sendCompleted];
    } failure:^(SSJBaseNetworkService * _Nonnull service) {
        [subscriber sendError:nil];
    }];
}


/**
 重新获取验证码
 */
- (void)reVerCodeWithSubscriber:(id<RACSubscriber>) subscriber {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:self.phoneNum forKey:@"cmobileno"];
    [self.netWorkService request:@"/chargebook/user/get_imgYzm.go" params:param success:^(SSJBaseNetworkService * _Nonnull service) {
        [subscriber sendNext:service.rootElement];
        [subscriber sendCompleted];
    } failure:^(SSJBaseNetworkService * _Nonnull service) {
        [subscriber sendError:nil];
    }];
}

- (void)loginNormalWithPassWord:(NSString*)password AndUserAccount:(NSString*)useraccount subscriber:(id<RACSubscriber>) subscriber {
    self.netWorkService.showLodingIndicator = YES;
    self.openId = @"";
//    NSString *strAcctID = @"130313003";
//    NSString *strSignType = @"1";
//    NSString *strKey = @"A9FK25RHT487ULMI";
    
    //imei
    NSString *imei = [UIDevice currentDevice].identifierForVendor.UUIDString;
    
    //手机型号
    NSString *phoneModel = SSJPhoneModel();
    
    //个推id
    NSString *getuiId = [GeTuiSdk clientId];
    
    //手机系统版本
    NSString *phoneVersion = [[UIDevice currentDevice] systemVersion];
    
    NSString *encryptPassword = [password stringByAppendingString:@"http://www.9188.com/"];
    encryptPassword = [[encryptPassword ssj_md5HexDigest] lowercaseString];
    
//    NSString *strSign=[NSString stringWithFormat:@"signType=%@&merchantacctId=%@&mobileNo=%@&pwd=%@&key=%@",strSignType,strAcctID,useraccount,encryptPassword,strKey];
    
//    NSString *strmd5Sign=[[strSign ssj_md5HexDigest]uppercaseString];
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:useraccount forKey:@"cmobileno"];
    [dict setObject:self.verificationCode forKey:@"yzm"];
    [dict setObject:encryptPassword forKey:@"pwd"];
    [dict setObject:phoneModel forKey:@"cmodel"];
    [dict setObject:phoneVersion forKey:@"cphoneos"];
    [dict setObject:phoneModel forKey:@"cphonebrand"];
    [dict setObject:imei forKey:@"cimei"];
    [dict setObject:getuiId ?: @"" forKey:@"cgetuiid"];
    
//    [dict setObject:strAcctID forKey:@"merchantacctId"];
//    [dict setObject:strSignType forKey:@"signType"];
//    [dict setObject:strmd5Sign forKey:@"signMsg"];
    
    [self.netWorkService request:SSJURLWithAPI(@"/user/login.go") params:dict success:^(SSJBaseNetworkService * _Nonnull service) {
        [subscriber sendNext:service.rootElement];
        [subscriber sendCompleted];
    } failure:^(SSJBaseNetworkService * _Nonnull service) {
        [CDAutoHideMessageHUD showMessage:service.desc];
        [subscriber sendError:nil];
    }];
}


- (void)datawithDic:(NSDictionary *)dict {
    NSDictionary *result = [[dict objectForKey:@"results"] objectForKey:@"user"];
    self.accesstoken = [dict objectForKey:@"accessToken"];
    [SSJUserItem mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"userId":@"cuserid",
                 @"nickName":@"crealname",  // 第三方登录时，服务器返回的crealname就是用户昵称
                 @"mobileNo":@"cmobileno",
                 @"icon":@"cicon",
                 @"openid":@"oauthid"};
    }];
    _userItem = [SSJUserItem mj_objectWithKeyValues:result];
    self.userItem.loginType = [NSString stringWithFormat:@"%ld",self.loginType];
    if (self.loginType != SSJLoginTypeNormal) {
        self.userItem.mobileNo = @"";
    }
    self.userItem.loginPWD = @"";
    self.userItem.openId = self.openId;
    
    self.userBillArray = [NSArray arrayWithArray:[dict objectForKey:@"userBill"]];
    self.fundInfoArray = [NSArray arrayWithArray:[dict objectForKey:@"fundInfo"]];
    self.booksTypeArray = [NSArray arrayWithArray:[dict objectForKey:@"bookType"]];
    self.membersArray = [NSArray arrayWithArray:[dict objectForKey:@"bk_member"]];
    self.checkInModel = [SSJBookkeepingTreeCheckInModel mj_objectWithKeyValues:[dict objectForKey:@"userTree"]];
    self.customCategoryArray = [SSJCustomCategoryItem mj_objectArrayWithKeyValuesArray:[dict objectForKey:@"bookBillArray"]];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:SSJLastLoggedUserItemKey]) {
        //                    __weak typeof(self) weakSelf = self;
        NSData *lastUserData = [[NSUserDefaults standardUserDefaults] objectForKey:SSJLastLoggedUserItemKey];
        SSJUserItem *lastUserItem = [NSKeyedUnarchiver unarchiveObjectWithData:lastUserData];
        BOOL isSameUser = ([self.userItem.mobileNo isEqualToString:lastUserItem.mobileNo] && lastUserItem.mobileNo.length) || ([self.userItem.openId isEqualToString:lastUserItem.openId] && lastUserItem.openId.length);
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
                [self comfirmTologin];
            }], nil];
            return;
        }
    }
    
    [self comfirmTologin];
}

-(void)comfirmTologin {
    //  只要登录就设置用户为已注册，因为9188账户、第三方登录没有注册就可以登录
    self.userItem.registerState = @"1";
    
    if (!self.userItem.currentBooksId) {
        self.userItem.currentBooksId = self.userItem.userId;
    }
    
    // 保存用户信息
    [[[[[[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJUserTableManager saveUserItem:self.userItem success:^{
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }] then:^RACSignal *{
        // 保存用户登录信息
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            if (SSJSaveAppId(self.appid)
                && SSJSaveAccessToken(self.accesstoken)
                && SSJSetUserId(self.userItem.userId)
                && SSJSaveUserLogined(YES)) {
                //保存账本类型个人or共享
                [self queryCurrentCategoryForUserId:self.userItem.userId];
                [subscriber sendCompleted];
                
            } else {
                [subscriber sendError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"存储用户登录信息失败"}]];
            }
            return nil;
        }];
    }] then:^RACSignal *{
        // 合并用户数据，即使合并失败，之后还会进行同步，所以无论成功与否都正常走接下来的流程
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [SSJLoginHelper updateTableWhenLoginWithViewModel:self completion:^{
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
                if (![checkInModel.lastCheckInDate isEqualToString:self.checkInModel.lastCheckInDate]) {
                    [SSJBookkeepingTreeStore saveCheckInModel:self.checkInModel success:NULL failure:NULL];
                    [SSJBookkeepingTreeHelper loadTreeImageWithUrlPath:self.checkInModel.treeImgUrl finish:NULL];
                    [SSJBookkeepingTreeHelper loadTreeGifImageDataWithUrlPath:self.checkInModel.treeGifUrl finish:NULL];
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
//            [self syncData];
//            [self.loadingView show];
            [CDAutoHideMessageHUD showMessage:@"登录成功"];
            [SSJAnaliyticsManager setUserId:SSJUSERID() userName:(self.userItem.nickName.length ? self.userItem.nickName : self.userItem.mobileNo)];
            [[NSNotificationCenter defaultCenter] postNotificationName:SSJLoginOrRegisterNotification object:nil];
            [SSJLocalNotificationHelper cancelLocalNotificationWithKey:SSJReminderNotificationKey];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SSJHaveLoginOrRegistKey];
            [[NSUserDefaults standardUserDefaults] setInteger:self.loginType forKey:SSJUserLoginTypeKey];
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
                    motionVC.backController = self.vc.backController;
                    if (userItem.motionPWD.length) {
                        motionVC.type = SSJMotionPasswordViewControllerTypeVerification;
                    } else {
                        motionVC.type = SSJMotionPasswordViewControllerTypeSetting;
                    }
                    [weakSelf.vc.navigationController pushViewController:motionVC animated:YES];
                } else {
                    if (self.vc.finishHandle) {
                        self.vc.finishHandle(self.vc);
                    } else {
                        [self.vc ssj_backOffAction];
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


#pragma mark - Lazy
- (SSJBaseNetworkService *)netWorkService {
    if (!_netWorkService) {
        _netWorkService = [[SSJBaseNetworkService alloc] init];
        _netWorkService.httpMethod = SSJBaseNetworkServiceHttpMethodPOST;
    }
    return _netWorkService;
}

- (RACCommand *)verifyPhoneNumRequestCommand {
    //判断手机号格式
    if (![self.phoneNum ssj_validPhoneNum]) {
        [CDAutoHideMessageHUD showMessage:@"请输入正确的手机号"];
        return nil;
    }
    if (!_verifyPhoneNumRequestCommand) {
        _verifyPhoneNumRequestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @weakify(self);
            RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self verityPhoneNumWithPhone:self.phoneNum subscriber:subscriber];
                return nil;
            }];
            //返回的数据处理json->model
//            return [signal map:^id(id value) {
//                return @"成功啦";
//            }];
            return signal;
        }];
        
        //获得数据
        [_verifyPhoneNumRequestCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        }];
    }
    return _verifyPhoneNumRequestCommand;
}

- (RACSignal *)enableVerifySignal {
    if (!_enableVerifySignal) {
        //手机号位数，是否同意用户协议
        _enableVerifySignal = [[RACSignal combineLatest:@[RACObserve(self, phoneNum),RACObserve(self, agreeProtocol)] reduce:^id(NSString *phoneNum,NSNumber *isAgree){
            return @(phoneNum.length == 11 && isAgree.boolValue);
        }] skip:1];
    }
    return _enableVerifySignal;
}

- (RACSignal *)enableRegAndLoginSignal {
    if (!_enableRegAndLoginSignal) {
        _enableRegAndLoginSignal = [[RACSignal combineLatest:@[RACObserve(self, verificationCode),RACObserve(self, passwardNum)] reduce:^id(NSString *code,NSString *passward){
            return @(code.length == 6 && passward.length >=6 && passward.length <=15);
        }] skip:1];
    }
    return _enableRegAndLoginSignal;
}

- (RACCommand *)getVerificationCodeCommand {
    if (!_getVerificationCodeCommand) {
        _getVerificationCodeCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                [self verCode:SSJRegistAndForgetPasswordTypeRegist channelType:SSJLoginAndRegisterPasswordChannelTypeSMS subscriber:subscriber];
                return nil;
            }];
            return [signal map:^id(NSDictionary *value) {
               return [RACTuple tupleWithObjects:[value objectForKey:@"code"],[value objectForKey:@"desc"], nil];
//                return [value objectForKey:@"code"];
            }];
        }];
    }
    return _getVerificationCodeCommand;
}

- (RACCommand *)reGetVerificationCodeCommand {
    if (!_reGetVerificationCodeCommand) {
        _reGetVerificationCodeCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                [self reVerCodeWithSubscriber:subscriber];
                return nil;
            }];
            return [signal map:^id(NSDictionary *value) {
                if ([[value objectForKey:@"code"] isEqualToString:@"1"]) {
                    return [value objectForKey:@"image"];
                } else {
                    [CDAutoHideMessageHUD showMessage:[value objectForKey:@"desc"]];
                    return [value objectForKey:@"desc"];
                }
            }];
        }];
    }
    return _reGetVerificationCodeCommand;
}

- (RACCommand *)registerAndLoginCommand {
    if (!_registerAndLoginCommand) {
        _registerAndLoginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                //登录
                self.loginType = SSJLoginTypeNormal;
                return nil;
            }];
            return signal;
        }];
        [_registerAndLoginCommand.executionSignals.switchToLatest subscribeNext:^(NSDictionary *dict) {
            [self datawithDic:dict];
        }];
    }
    return _registerAndLoginCommand;
}

- (RACCommand *)wxLoginCommand {
    if (!_wxLoginCommand) {
        _wxLoginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                
                //发送微信登录请求
                [[SSJThirdPartyLoginManger shareInstance].weixinLogin weixinLoginWithSucessBlock:^(SSJThirdPartLoginItem *item) {
                    [SSJThirdPartyLoginManger shareInstance].qqLogin = nil;
                    [SSJThirdPartyLoginManger shareInstance].weixinLogin = nil;
                    self.loginType = SSJLoginTypeWeiXin;
                    [self thirdLoginWithLoginItem:item subscriber:subscriber];
                }];
                
                return nil;
            }];
            return signal;
        }];
        
        [_wxLoginCommand.executionSignals.switchToLatest subscribeNext:^(NSDictionary *dict) {
            [self datawithDic:dict];
        }] ;
    }
    return _wxLoginCommand;
}

- (RACCommand *)qqLoginCommand {
    if (!_qqLoginCommand) {
        _qqLoginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                //发送qq登录请求
                [[SSJThirdPartyLoginManger shareInstance].qqLogin qqLoginWithSucessBlock:^(SSJThirdPartLoginItem *item) {
                    [SSJThirdPartyLoginManger shareInstance].qqLogin = nil;
                    [SSJThirdPartyLoginManger shareInstance].weixinLogin = nil;
                    self.loginType = SSJLoginTypeQQ;
                    [self thirdLoginWithLoginItem:item subscriber:subscriber];
                }];
                
                return nil;
            }];
        }];
        
        [_qqLoginCommand.executionSignals.switchToLatest subscribeNext:^(NSDictionary *dict) {
            [self datawithDic:dict];
        }] ;
    }
    return _qqLoginCommand;
}

@end
