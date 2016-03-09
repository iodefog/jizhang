//
//  SSJLoginService.m
//  YYDB
//
//  Created by cdd on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJLoginService.h"
#import "SSJUserInfoItem.h"

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
    NSString *encryptPassword = [@"88888888" stringByAppendingString:@"http://www.9188.com/"];
    encryptPassword = [[encryptPassword ssj_md5HexDigest] lowercaseString];
    NSString *strSign=[NSString stringWithFormat:@"signType=%@&merchantacctId=%@&mobileNo=%@&pwd=%@&key=%@",strSignType,strAcctID,useraccount,encryptPassword,strKey];
    NSString *strmd5Sign=[[strSign ssj_md5HexDigest]uppercaseString];
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:useraccount forKey:@"mobileNo"];
    [dict setObject:strAcctID forKey:@"merchantacctId"];
    [dict setObject:strSignType forKey:@"signType"];
    [dict setObject:encryptPassword forKey:@"pwd"];
    [dict setObject:strmd5Sign forKey:@"signMsg"];
    [dict setObject:SSJUSERID() forKey:@"cuserid"];
    [self request:SSJURLWithAPI(@"/user/login.go") params:dict];
}

- (void)requestDidFinish:(NSDictionary *)rootElement{
    [super requestDidFinish:rootElement];
    NSLog(@"%@",self.desc);
    if ([self.returnCode isEqualToString:@"1"]) {
        self.item = [[SSJUserItem alloc]init];
        NSDictionary *dict=[rootElement objectForKey:@"results"];
        self.appid = [dict objectForKey:@"appId"];
        self.accesstoken = [dict  objectForKey:@"accessToken"];
        NSDictionary *result = [dict objectForKey:@"user"];
        self.item = [SSJUserItem mj_objectWithKeyValues:result];
        self.userBillArray = [NSArray arrayWithArray:[dict objectForKey:@"userBill"]];
        self.fundInfoArray = [NSArray arrayWithArray:[dict objectForKey:@"fundInfo"]];
    }
}

@end
