//
//  SSJForgetPassowrdNetworkService.m
//  YYDB
//
//  Created by old lang on 15/10/29.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJForgetPassowrdNetworkService.h"

@interface SSJForgetPassowrdNetworkService ()

@property (readwrite, nonatomic, copy) NSString *mobileNo;
@property (readwrite, nonatomic, copy) NSString *authCode;
@property (readwrite, nonatomic, copy) NSString *password;

@end

@implementation SSJForgetPassowrdNetworkService

- (void)getAuthCodeWithMobileNo:(NSString *)mobileNo {
    self.mobileNo = mobileNo;
    [self request:SSJURLWithAPI(@"/user/forgetpwd.go") params:@{@"mobileNo":mobileNo ?: @""}];
}

- (void)checkAuthCodeWithMobileNo:(NSString *)mobileNo authCode:(NSString *)authCode {
    self.mobileNo = mobileNo;
    self.authCode = authCode;
    [self request:SSJURLWithAPI(@"/user/forgetpwdyz.go") params:@{@"mobileNo":mobileNo ?: @"",
                                                                  @"yzm":authCode ?: @""}];
}

- (void)setPasswordWithMobileNo:(NSString *)mobileNo authCode:(NSString *)authCode password:(NSString *)password {
    self.mobileNo = mobileNo;
    self.authCode = authCode;
    self.password = password;
    [self request:SSJURLWithAPI(@"/user/mobregister.go") params:@{@"mobileNo":mobileNo ?: @"",
                                                                  @"yzm":authCode ?: @"",
                                                                  @"pwd":password ?: @""}];
}

- (void)handleResult:(NSDictionary *)rootElement {
    if ([self.returnCode isEqualToString:@"1"]) {
        NSDictionary *resultInfo = [rootElement objectForKey:@"results"];
        if (resultInfo) {
            SSJSaveAppId(resultInfo[@"appId"] ?: @"");
            SSJSaveAccessToken(resultInfo[@"accessToken"] ?: @"");
        }
    }
}

@end
