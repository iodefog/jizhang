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
@property (nonatomic,strong)TencentOAuth *tencentOAuth;
@end

@implementation SSJQQLoginHelper
-(void)qqLoginWithSucessBlock:(qqLoginSuccessBlock)sucessBlock{
    self.tencentOAuth=[[TencentOAuth alloc]initWithAppId:SSJDetailSettingForSource(@"QQAppId") andDelegate:self];
    NSArray *permissions= [NSArray arrayWithObjects:@"get_user_info",@"get_simple_userinfo",@"add_t",nil];
    [self.tencentOAuth authorize:permissions inSafari:NO];
    self.sucessBlock = sucessBlock;
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
        NSLog(@"登录不成功 没有获取accesstoken");
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
}

// 网络错误导致登录失败：
-(void)tencentDidNotNetWork
{
    [CDAutoHideMessageHUD showMessage:@"无网络连接，请设置网络"];
}

//获取用户信息
-(void)getUserInfoResponse:(APIResponse *)response
{
    NSLog(@"respons:%@",response.jsonResponse);
    NSString *icon = [response.jsonResponse objectForKey:@"figureurl_qq_2"];
    NSString *realName = [response.jsonResponse objectForKey:@"nickname"];
    NSString *openId = [self.tencentOAuth openId];
    if (self.sucessBlock) {
        self.sucessBlock(realName,icon,openId);
    }
}

@end
