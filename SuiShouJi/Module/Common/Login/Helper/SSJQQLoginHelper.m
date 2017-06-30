//
//  SSJQQLoginHelper.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/4/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJQQLoginHelper.h"

@interface SSJQQLoginHelper()
@property (nonatomic, strong) qqLoginSuccessBlock sucessBlock;
@property (nonatomic, strong) qqLoginFailBlock failBlock;
@property (nonatomic,strong)TencentOAuth *tencentOAuth;
@end

@implementation SSJQQLoginHelper
-(void)qqLoginWithSucessBlock:(qqLoginSuccessBlock)sucessBlock failBlock:(qqLoginFailBlock)failBlock {
    self.tencentOAuth=[[TencentOAuth alloc]initWithAppId:SSJDetailSettingForSource(@"QQAppId") andDelegate:self];
    NSArray *permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_INFO, kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, nil];
//    NSArray *permissions= [NSArray arrayWithObjects:@"get_user_info",@"get_simple_userinfo",@"add_t",nil];
    [self.tencentOAuth authorize:permissions inSafari:NO];
    self.sucessBlock = sucessBlock;
    self.failBlock = failBlock;
}

//登陆完成调用
- (void)tencentDidLogin
{
    if (self.tencentOAuth.accessToken && 0 != [self.tencentOAuth.accessToken length])
    {
        //  记录登录用户的OpenID、Token以及过期时间
        [self.tencentOAuth getUserInfo];
    }
    else
    {
        SSJPRINT(@"登录不成功 没有获取accesstoken");
    }
}

//非网络错误导致登录失败：
-(void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled)
    {
        [CDAutoHideMessageHUD showMessage:@"登录取消"];
    }else{
        [CDAutoHideMessageHUD showMessage:@"登录失败"];
    }
    if (self.failBlock) {
        self.failBlock();
    }
}

// 网络错误导致登录失败：
-(void)tencentDidNotNetWork
{
    [CDAutoHideMessageHUD showMessage:@"无网络连接，请设置网络"];
    if (self.failBlock) {
        self.failBlock();
    }
}

//获取用户信息
-(void)getUserInfoResponse:(APIResponse *)response
{
    SSJPRINT(@"respons:%@",response.jsonResponse);
    SSJThirdPartLoginItem *item = [[SSJThirdPartLoginItem alloc]init];
    item.portraitURL = [response.jsonResponse objectForKey:@"figureurl_qq_2"] ? : @"";
    item.nickName = [response.jsonResponse objectForKey:@"nickname"] ? : @"";
    item.userGender = [response.jsonResponse objectForKey:@"gender"] ? : @"";
    item.unionId = @"";
    item.openID = [self.tencentOAuth openId];
    item.loginType = SSJLoginTypeQQ;
    if (self.sucessBlock) {
        self.sucessBlock(item);
    }
}

@end
