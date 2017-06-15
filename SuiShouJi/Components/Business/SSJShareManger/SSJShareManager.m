//
//  SSJShareManager.m
//  SuiShouJi
//
//  Created by ricky on 2017/3/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareManager.h"

@implementation SSJShareManager

+ (void)shareWithType:(SSJShareType)type
                image:(UIImage *)image
               UrlStr:(NSString *)str
                title:(NSString *)title
              content:(NSString *)content
         PlatformType:(NSArray *)platforms
         inController:(UIViewController *)controller
           ShareSuccess:(void(^)(UMSocialShareResponse *response))success
{
    __weak typeof(self) weakSelf = self;
    [UMSocialUIManager setPreDefinePlatforms:platforms];
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        switch (type) {
            case SSJShareTypeUrl: {
                [weakSelf shareWebPageWithUrlStr:str title:title content:content PlatformType:platformType inController:controller ShareSuccess:success];
            }
                break;
                
            case SSJShareTypeTextOnly: {
                [weakSelf shareText:content PlatformType:platformType inController:controller ShareSuccess:success];
            }
                break;
                
            case SSJShareTypeImageOnly: {
                [weakSelf shareImage:image PlatformType:platformType inController:controller ShareSuccess:success];
            }
                break;
                
            default:
                break;
        }
    }];
}

+ (void)shareWebPageWithUrlStr:(NSString *)str
                         title:(NSString *)title
                       content:(NSString *)content
                  PlatformType:(UMSocialPlatformType)platformType
                  inController:(UIViewController *)controller
                  ShareSuccess:(void(^)(UMSocialShareResponse *response))success
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    messageObject.title = title;
    
    messageObject.text = content;
    
    NSString *icon = @"";
    
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    
    if ([UIScreen mainScreen].scale >= 2) {
        icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    } else {
        icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] firstObject];
    }
    
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:content thumImage:[UIImage imageNamed:icon]];
    
    
    //设置网页地址
    shareObject.webpageUrl = [NSString stringWithFormat:@"%@",[str mj_url]];
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:controller completion:^(id data, NSError *error) {
        if (error) {
            [CDAutoHideMessageHUD showMessage:@"分享失败"];
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
        }else{
            [CDAutoHideMessageHUD showMessage:@"分享成功"];
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }else{
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
    }];
}

+ (void)shareText:(NSString *)text
      PlatformType:(UMSocialPlatformType)platformType
     inController:(UIViewController *)controller
     ShareSuccess:(void(^)(UMSocialShareResponse *response))success
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //设置文本
    messageObject.text = text;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:controller completion:^(id data, NSError *error) {
        if (error) {
            [CDAutoHideMessageHUD showMessage:@"分享失败"];
            SSJPRINT(@"************Share fail with error %@*********",error);
        }else{
            [CDAutoHideMessageHUD showMessage:@"分享成功"];
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                success(resp);
            } else {
                success(nil);
            }
            SSJPRINT(@"response data is %@",data);
        }
    }];
}

+ (void)shareImage:(UIImage *)image
      PlatformType:(UMSocialPlatformType)platformType
      inController:(UIViewController *)controller
      ShareSuccess:(void(^)(UMSocialShareResponse *response))success
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建图片内容对象
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    
    [shareObject setShareImage:image];
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:controller completion:^(id data, NSError *error) {
        if (error) {
            [CDAutoHideMessageHUD showMessage:@"分享失败"];
            SSJPRINT(@"************Share fail with error %@*********",error);
        }else{
            
            [CDAutoHideMessageHUD showMessage:@"分享成功"];
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                success(resp);
            } else {
                success(nil);
            }
            SSJPRINT(@"response data is %@",data);
        }
    }];
}



@end
