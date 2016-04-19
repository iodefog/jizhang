//
//  SSJLoginService.m
//  YYDB
//
//  Created by cdd on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJLoginService.h"
#import "SSJUserInfoItem.h"

@interface SSJLoginService ()

//  登录方式
@property (nonatomic) SSJLoginType loginType;

//用户账户类型数据
@property (nonatomic,strong) NSArray *fundInfoArray;

//用户记账类型数据
@property (nonatomic,strong) NSArray *userBillArray;

//登录用户的accesstoken
@property (nonatomic,strong) NSString *accesstoken;

//登录用户的appid
@property (nonatomic,strong) NSString *appid;

@property (nonatomic,strong) SSJUserItem *item;

@end

@implementation SSJLoginService

- (void)loadLoginModelWithPassWord:(NSString*)password AndUserAccount:(NSString*)useraccount{
    self.loginType = SSJLoginTypeNormal;
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
    [dict setObject:SSJUSERID() forKey:@"cuserid"];
    [self request:SSJURLWithAPI(@"/user/login.go") params:dict];
}

- (void)loadLoginModelWithLoginType:(SSJLoginType)loginType openID:(NSString*)openID realName:(NSString*)realName icon:(NSString*)icon{
    self.loginType = loginType;
    self.showLodingIndicator = YES;
    NSString *strAcctID=@"130313003";
    NSString *strSignType=@"1";
    NSString *strKey=@"iwannapie?!";
    NSString *type;
    if (self.loginType == SSJLoginTypeQQ) {
        type = @"qq";
    }else if (self.loginType == SSJLoginTypeWeiXin){
        type = @"wechat";
    }
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
    [dict setObject:[realName ssj_emojiFilter] forKey:@"crealname"];
    [self request:SSJURLWithAPI(@"/oauth/oauthlogin.go") params:dict];
}

- (void)requestDidFinish:(NSDictionary *)rootElement{
    [super requestDidFinish:rootElement];

    if ([self.returnCode isEqualToString:@"1"]) {
        self.item = [[SSJUserItem alloc]init];
        NSDictionary *dict=[rootElement objectForKey:@"results"];
        self.appid = [dict objectForKey:@"appId"];
        self.accesstoken = [dict  objectForKey:@"accessToken"];
        NSDictionary *result = [dict objectForKey:@"user"];
        
        [SSJUserItem mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
            return @{@"userId":@"cuserid",
                     @"nickName":@"crealname",  // 第三方登录时，服务器返回的crealname就是用户昵称
                     @"mobileNo":@"cmobileno",
                     @"icon":@"cicon"};
        }];
        self.item = [SSJUserItem mj_objectWithKeyValues:result];
        
        self.userBillArray = [NSArray arrayWithArray:[dict objectForKey:@"userBill"]];
        self.fundInfoArray = [NSArray arrayWithArray:[dict objectForKey:@"fundInfo"]];
    }
}

@end
