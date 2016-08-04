//
//  SSJWeiXinLoginHelper.m
//  SuiShouJi
//
//  Created by ricky on 16/4/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJWeiXinLoginHelper.h"

@interface SSJWeiXinLoginHelper()
@property (nonatomic, strong) weiXinLoginSuccessBlock sucessBlock;
@end

@implementation SSJWeiXinLoginHelper

-(void)weixinLoginWithSucessBlock:(weiXinLoginSuccessBlock)sucessBlock{
    SendAuthReq* req =[[SendAuthReq alloc ]init];
    req.scope = @"snsapi_userinfo";
    req.state = SSJWeiXinDescription;
    [WXApi sendReq:req];
    self.sucessBlock = sucessBlock;
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
    
    if (resp.errCode == 0)
    {
        NSLog(@"用户同意");
        if([resp isKindOfClass:[SendAuthResp class]]) {
            SendAuthResp *aresp=(SendAuthResp *)resp;
            [self getAccessTokenWithCode:aresp.code];
        }
        
    }else if (resp.errCode == -4){
        NSLog(@"用户拒绝");
    }else if (resp.errCode == -2){
        NSLog(@"用户取消");;
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
                    NSLog(@"%@",[dict objectForKey:@"errmsg"]);
                }else{
                    NSString *iconUrl = [dict objectForKey:@"headimgurl"] ? : @"";
                    NSString *nickName = [dict objectForKey:@"nickname"] ? : @"";
                    if (self.sucessBlock) {
                        self.sucessBlock(nickName,iconUrl,openId);
                    }
                }
            }
        });
    });
}

@end
