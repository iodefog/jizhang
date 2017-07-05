//
//  SSJForgetAndResetPasswordNetworkService.m
//  SuiShouJi
//
//  Created by old lang on 2017/6/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJForgetAndResetPasswordNetworkService.h"

@interface SSJForgetAndResetPasswordNetworkService ()

@property (nonatomic) SSJForgetAndResetPasswordType type;

@property (nonatomic, copy) NSString *mobileNo;

@property (nonatomic, copy) NSString *authCode;

@property (nonatomic, copy) NSString *password;

@end

@implementation SSJForgetAndResetPasswordNetworkService

- (void)requestWithType:(SSJForgetAndResetPasswordType)type
               mobileNo:(NSString *)mobileNo
               authCode:(NSString *)authCode
               password:(NSString *)password
                success:(SSJNetworkServiceHandler)success
                failure:(SSJNetworkServiceHandler)failure {
    
    self.type = type;
    self.mobileNo = mobileNo;
    self.authCode = authCode;
    self.password = password;
    
    NSString *encryptPassword = [password stringByAppendingString:SSJLoginPWDEncryptionKey];
    encryptPassword = [[encryptPassword ssj_md5HexDigest] lowercaseString];
    
    NSString *authCodeType = nil;
    switch (type) {
        case SSJForgetPasswordType:
            authCodeType = @"14";
            break;
            
        case SSJResetPasswordType:
            authCodeType = @"13";
            break;
    }
    
    NSDictionary *params = @{@"cmobileNo":mobileNo,
                             @"yzm":authCode,
                             @"newPwd":encryptPassword,
                             @"yzmType":authCodeType};
    [self request:@"/chargebook/user/forget_pwd.go" params:params success:success failure:failure];
}

- (BOOL)isRequestSuccessfulWithCode:(NSInteger)code {
    return code == 1;
}

@end
