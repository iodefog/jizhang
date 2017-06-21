//
//  SSJRegistNetworkService.m
//  YYDB
//
//  Created by old lang on 15/10/29.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJRegistNetworkService.h"

@interface SSJRegistNetworkService ()

@property (readwrite, nonatomic) SSJRegistAndForgetPasswordType type;
@property (readwrite, nonatomic) SSJRegistNetworkServiceType interfaceType;
@property (readwrite, nonatomic, copy) NSString *mobileNo;
@property (readwrite, nonatomic, copy) NSString *authCode;
@property (readwrite, nonatomic, copy) NSString *password;

@end

@implementation SSJRegistNetworkService

- (instancetype)initWithDelegate:(id<SSJBaseNetworkServiceDelegate>)delegate type:(SSJRegistAndForgetPasswordType)type {
    if (self = [super initWithDelegate:delegate]) {
        self.type = type;
    }
    return self;
}

- (void)getAuthCodeWithMobileNo:(NSString *)mobileNo {
    self.mobileNo = mobileNo;
    self.interfaceType = SSJRegistNetworkServiceTypeGetAuthCode;
    
    //  加签名参数，防止短信炸弹
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionaryWithCapacity:4];
    if (mobileNo) {
        NSNumber *timestamp = @(SSJMilliTimestamp());
        NSString *key = @"iwannapie?!";
        NSString *signMsg = [NSString stringWithFormat:@"mobileNo=%@&timestamp=%@&key=%@",mobileNo,timestamp,key];
        signMsg = [[signMsg ssj_md5HexDigest] uppercaseString];
        
        [paramsDic setObject:mobileNo forKey:@"mobileNo"];
        [paramsDic setObject:timestamp forKey:@"timestamp"];
        [paramsDic setObject:key forKey:@"key"];
        [paramsDic setObject:signMsg forKey:@"signMsg"];
    }
    
    switch (self.type) {
        case SSJRegistAndForgetPasswordTypeRegist:
            [self request:@"/user/mobregisterchk.go" params:paramsDic];
            break;
            
        case SSJRegistAndForgetPasswordTypeForgetPassword:
            [self request:@"/user/forgetpwd.go" params:paramsDic];
            break;
    }
}

- (void)checkAuthCodeWithMobileNo:(NSString *)mobileNo authCode:(NSString *)authCode {
    self.mobileNo = mobileNo;
    self.authCode = authCode;
    self.interfaceType = SSJRegistNetworkServiceTypeCheckAuthCode;
    switch (self.type) {
        case SSJRegistAndForgetPasswordTypeRegist:
            [self request:@"/user/mobyzmchk.go" params:@{@"mobileNo":mobileNo ?: @"",
                                                                          @"yzm":authCode ?: @""}];
            break;
            
        case SSJRegistAndForgetPasswordTypeForgetPassword:
            [self request:@"/user/forgetpwdyz.go" params:@{@"mobileNo":mobileNo ?: @"",
                                                                          @"yzm":authCode ?: @""}];
            break;
    }
}

- (void)setPasswordWithMobileNo:(NSString *)mobileNo authCode:(NSString *)authCode password:(NSString *)password {
    self.mobileNo = mobileNo;
    self.authCode = authCode;
    self.password = password;
    self.interfaceType = SSJRegistNetworkServiceTypeSetPassword;
    switch (self.type) {
        case SSJRegistAndForgetPasswordTypeRegist:
            [self request:@"/user/mobregister.go" params:@{@"mobileNo":mobileNo ?: @"",
                                                           @"cuserid":SSJUSERID() ?: @"",
                                                               @"yzm":authCode ?: @"",
                                                               @"pwd":password ?: @"",
                                                           @"cimei":[UIDevice currentDevice].identifierForVendor.UUIDString,
                                                           @"cmodel":SSJPhoneModel(),
                                                           @"cphoneos":[[UIDevice currentDevice] systemVersion]}];
            break;
            
        case SSJRegistAndForgetPasswordTypeForgetPassword:
            [self request:@"/user/resetpwd.go" params:@{@"mobileNo":mobileNo ?: @"",
                                                             @"yzm":authCode ?: @"",
                                                             @"pwd":password ?: @""}];
            break;
    }
}

- (void)handleResult:(NSDictionary *)rootElement {
    if (self.interfaceType == SSJRegistNetworkServiceTypeSetPassword
        && self.type == SSJRegistAndForgetPasswordTypeRegist
        && [self.returnCode isEqualToString:@"1"]) {

    }
}


@end
