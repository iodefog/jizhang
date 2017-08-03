//
//  SSJWeiXinLoginHelper.m
//  SuiShouJi
//
//  Created by ricky on 16/4/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJWeiXinLoginHelper.h"

@interface SSJWeiXinLoginHelper()

@property (nonatomic, copy) weiXinLoginSuccessBlock sucessBlock;

@property (nonatomic, copy) weiXinLoginFailBlock failBlock;

@property (nonatomic) BOOL loading;

@end


@implementation SSJWeiXinLoginHelper

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)weixinLoginWithSucessBlock:(weiXinLoginSuccessBlock)sucessBlock failBlock:(weiXinLoginFailBlock)failBlock{
    self.loading = YES;
    SendAuthReq* req =[[SendAuthReq alloc ]init];
    req.scope = @"snsapi_userinfo";
    req.state = SSJWeiXinDescription;
    [WXApi sendReq:req];
    self.sucessBlock = sucessBlock;
    self.failBlock = failBlock;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

-(void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (self.loading) {
        self.loading = NO;
        if (self.failBlock) {
            self.failBlock([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeLoginCanceled userInfo:@{NSLocalizedDescriptionKey:@"用户取消登录"}]);
            self.failBlock = nil;
        }
    }
}


/**
 * onReq微信终端向第三方程序发起请求，要求第三方程序响应。第三方程序响应完后必须调用
 * sendRsp返回。在调用sendRsp返回时，会切回到微信终端程序界面。
 */
- (void)onReq:(BaseReq *)req {
    
}

//授权后回调 WXApiDelegate
-(void)onResp:(BaseResp *)resp
{
    self.loading = NO;
    if (resp.errCode == WXSuccess) {
        SSJPRINT(@"用户同意");
        if([resp isKindOfClass:[SendAuthResp class]]) {
            SendAuthResp *aresp=(SendAuthResp *)resp;
            [self getAccessTokenWithCode:aresp.code];
        }
    } else {
        if (self.failBlock) {
            self.failBlock([NSError errorWithDomain:SSJErrorDomain code:(resp.errCode == WXErrCodeUserCancel ? SSJErrorCodeLoginCanceled : SSJErrorCodeLoginFailed) userInfo:@{NSLocalizedDescriptionKey:resp.errStr ?: SSJ_ERROR_MESSAGE}]);
            self.failBlock = nil;
        }
    }
}

-(void)getAccessTokenWithCode:(NSString *)code{
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",SSJDetailSettingForSource(@"WeiXinKey"),SSJDetailSettingForSource(@"WeiXinSecret"),code];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                [self getUserInfoWithAccessToken:[dic objectForKey:@"access_token"] andOpenId:[dic objectForKey:@"openid"]];
            }
        });
    });
}

- (void)getUserInfoWithAccessToken:(NSString *)accessToken andOpenId:(NSString *)openId
{
    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",accessToken,openId];
    NSURL *url = [NSURL URLWithString:urlString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data)
            {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if ([dict objectForKey:@"errcode"])
                {
                    SSJPRINT(@"%@",[dict objectForKey:@"errmsg"]);
                }else{
                    SSJThirdPartLoginItem *item = [[SSJThirdPartLoginItem alloc]init];
                    item.portraitURL = [dict objectForKey:@"headimgurl"] ? : @"";
                    item.nickName = [dict objectForKey:@"nickname"] ? : @"";
                    item.unionId = [dict objectForKey:@"unionid"] ? : @"";
                    item.userGender = [NSString stringWithFormat:@"%@",[dict objectForKey:@"sex"] ? : @""];
                    item.loginType = SSJLoginTypeWeiXin;
                    item.openID = openId;
                    if (self.sucessBlock) {
                        self.sucessBlock(item);
                        self.sucessBlock = nil;
                    }
                }
            }
        });
    });
}

@end
