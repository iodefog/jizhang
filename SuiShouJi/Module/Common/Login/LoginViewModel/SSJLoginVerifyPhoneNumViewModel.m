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

#import "SSJStringAddition.h"
#import "SSJWeiXinLoginHelper.h"

#import "GeTuiSdk.h"

@interface SSJLoginVerifyPhoneNumViewModel ()
/**<#注释#>*/
@property (nonatomic, strong) SSJBaseNetworkService *netWorkService;

/**wx*/
@property (nonatomic, strong) SSJWeiXinLoginHelper *wxLoginHelper;

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
        [CDAutoHideMessageHUD showMessage:service.description];
        [subscriber sendError:nil];
    }];
}

- (void)wexLoginWithLoginItem:(SSJThirdPartLoginItem *)item subscriber:(id<RACSubscriber>) subscriber {
    self.netWorkService.showLodingIndicator = YES;
    NSString *strAcctID = @"130313003";
    NSString *strSignType = @"1";
    NSString *strKey = @"iwannapie?!";
    NSString *type = @"";
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

#pragma mark - Lazy
- (SSJBaseNetworkService *)netWorkService {
    if (!_netWorkService) {
        _netWorkService = [[SSJBaseNetworkService alloc] init];
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
            return [signal map:^id(id value) {
                return @"成功啦";
            }];
        }];
        
        //获得数据
        [_verifyPhoneNumRequestCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
            NSLog(@"新数据:::::%@",x);
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

- (RACCommand *)wxLoginCommand {
    if (!_wxLoginCommand) {
        _wxLoginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                
                //发送微信登录请求
                [self.wxLoginHelper weixinLoginWithSucessBlock:^(SSJThirdPartLoginItem *item) {
                    [self wexLoginWithLoginItem:item subscriber:subscriber];
                }];
                
                return nil;
            }];
            return [signal map:^id(NSDictionary *rootElement) {
                
                return rootElement;
            }];
        }];
    }
    return _wxLoginCommand;
}

- (SSJWeiXinLoginHelper *)wxLoginHelper {
    if (!_wxLoginHelper) {
        _wxLoginHelper = [[SSJWeiXinLoginHelper alloc] init];
    }
    return _wxLoginHelper;
}

@end
