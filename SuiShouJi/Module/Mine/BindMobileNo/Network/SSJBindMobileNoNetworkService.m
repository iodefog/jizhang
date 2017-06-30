//
//  SSJBindMobileNoNetworkService.m
//  SuiShouJi
//
//  Created by old lang on 2017/6/29.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBindMobileNoNetworkService.h"

@interface SSJBindMobileNoNetworkService ()

@property (nonatomic, copy) NSString *mobileNo;

@property (nonatomic, copy) NSString *authCode;

@property (nonatomic, copy) NSString *password;

@end

@implementation SSJBindMobileNoNetworkService

- (void)bindMobileNoWithMobileNo:(NSString *)mobileNo
                        authCode:(NSString *)authCode
                        password:(NSString *)password
                         success:(SSJNetworkServiceHandler)success
                         failure:(SSJNetworkServiceHandler)failure {
    self.mobileNo = mobileNo;
    self.authCode = authCode;
    self.password = password;
    NSDictionary *params = @{@"cuserId":SSJUSERID(),
                             @"cmobileNo":mobileNo,
                             @"yzm":authCode,
                             @"cpwd":password,
                             @"mobileType":@2};
    [self requestWithParams:params success:success failure:failure];
}

- (void)changeMobileNoWithMobileNo:(NSString *)mobileNo
                          authCode:(NSString *)authCode
                           success:(SSJNetworkServiceHandler)success
                           failure:(SSJNetworkServiceHandler)failure {
    self.mobileNo = mobileNo;
    self.authCode = authCode;
    NSDictionary *params = @{@"cuserId":SSJUSERID(),
                             @"cmobileNo":mobileNo,
                             @"yzm":authCode,
                             @"mobileType":@2};
    [self requestWithParams:params success:success failure:failure];
}

- (void)requestWithParams:(nullable NSDictionary *)params
                  success:(nullable SSJNetworkServiceHandler)success
                  failure:(nullable SSJNetworkServiceHandler)failure {
    [self request:@"/chargebook/user/binding_cphone" params:params success:success failure:failure];
}

- (BOOL)isRequestSuccessfulWithCode:(NSInteger)code {
    return code == 1;
}

@end
