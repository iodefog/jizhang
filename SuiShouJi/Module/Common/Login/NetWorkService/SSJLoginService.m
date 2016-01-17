//
//  SSJLoginService.m
//  YYDB
//
//  Created by cdd on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJLoginService.h"

@implementation SSJLoginService

- (NSMutableDictionary *)packParameters:(NSMutableDictionary *)params {
    NSMutableDictionary *paramsDic = [super packParameters:params];
//    NSString *installationId = [AVInstallation currentInstallation].deviceToken;
//    if (installationId) {
//        [paramsDic setObject:installationId forKey:@"installationId"];
//    }
    return paramsDic;
}

- (void)loadLoginModelWithPassWord:(NSString*)password AndUserAccount:(NSString*)useraccount{
    self.showLodingIndicator = YES;
    NSString *strAcctID=@"130313003";
    NSString *strSignType=@"1";
    NSString *strKey=@"A9FK25RHT487ULMI";
    NSString *encryptPassword = [password stringByAppendingString:@"http://www.9188.com/"];
    encryptPassword = [[encryptPassword ssj_md5HexDigest] lowercaseString];
    NSString *strSign=[NSString stringWithFormat:@"signType=%@&merchantacctId=%@&mobileNo=%@&pwd=%@&key=%@",strSignType,strAcctID,useraccount,encryptPassword,strKey];
    NSString *strmd5Sign=[[strSign ssj_md5HexDigest]uppercaseString];
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:useraccount forKey:@"mobileNo"];
    [dict setObject:strAcctID forKey:@"merchantacctId"];
    [dict setObject:strSignType forKey:@"signType"];
    [dict setObject:encryptPassword forKey:@"pwd"];
    [dict setObject:strmd5Sign forKey:@"signMsg"];
    [self request:SSJURLWithAPI(@"/user/login.go") params:dict];
}

- (void)requestDidFinish:(NSDictionary *)rootElement{
    [super requestDidFinish:rootElement];
    NSLog(@"%@",self.desc);
    if ([self.returnCode isEqualToString:@"1"]) {
        NSDictionary *dict=[rootElement objectForKey:@"results"];
        NSString *appId = [dict objectForKey:@"appId"];
        SSJSaveAppId(appId);
        NSString *token = [dict  objectForKey:@"accessToken"];
        SSJSaveAccessToken(token);
        SSJSaveUserLogined(YES);
//        [[NSUserDefaults standardUserDefaults] setObject:<#(nullable id)#> forKey:<#(nonnull NSString *)#>];
//        NSString *isbind = [[rootElement attributeForName:@"isbind"] stringValue];
//        SSJSaveInvitedUser(isbind);
    }
}

@end
