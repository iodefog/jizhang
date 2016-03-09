//
//  SSJQQLoginService.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJQQLoginService.h"

@implementation SSJQQLoginService

- (void)loadLoginModelWithopenID:(NSString*)openID realName:(NSString*)realName icon:(NSString*)icon{
    self.showLodingIndicator = YES;
    NSString *strAcctID=@"130313003";
    NSString *strSignType=@"1";
    NSString *strKey=@"accountbook";
    NSString *type = @"qq";
    NSString *strSign=[NSString stringWithFormat:@"signType=%@&merchantacctId=%@&auth_token=%@&key=%@",strSignType,strAcctID,openID,strKey];
    NSString *strmd5Sign=[[strSign ssj_md5HexDigest]uppercaseString];
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:strAcctID forKey:@"merchantacctId"];
    [dict setObject:strSignType forKey:@"signType"];
    [dict setObject:strmd5Sign forKey:@"signMsg"];
    [dict setObject:SSJUSERID() forKey:@"cuserid"];
    [dict setObject:openID forKey:@"auth_token"];
    [dict setObject:icon forKey:@"cicon"];
    [dict setObject:type forKey:@"type"];
    [dict setObject:realName forKey:@"crealname"];
    
    [self request:SSJURLWithAPI(@"/oauth/oauthlogin.go") params:dict];
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
