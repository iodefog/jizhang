//
//  SSJUmengManager.m
//  SuiShouJi
//
//  Created by old lang on 16/3/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUmengManager.h"

#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import <UMSocialCore/UMSocialCore.h>
#import <UMMobClick/MobClick.h>


@implementation SSJUmengManager

/* 友盟统计 */
+ (void)umengTrack {
    [MobClick setCrashReportEnabled:YES]; // 如果不需要捕捉异常，注释掉此行
#ifdef DEBUG
    //    [MobClick setLogEnabled:YES];
#endif
    [MobClick setAppVersion:SSJAppVersion()]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    //  reportPolicy为枚举类型,可以为 REALTIME, BATCH,SENDDAILY,SENDWIFIONLY几种
    //  channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App Store"渠道
    UMConfigInstance.appKey = SSJDetailSettingForSource(@"UMAppKey");
    UMConfigInstance.ePolicy = (ReportPolicy)BATCH;
    UMConfigInstance.channelId = SSJDefaultSource();
    [MobClick startWithConfigure:UMConfigInstance]; 
//    [MobClick startWithAppkey:kUMAppKey reportPolicy:(ReportPolicy)BATCH channelId:SSJDefaultSource()];
}

/* 友盟分享 */
+ (void)umengShare{
    [[UMSocialManager defaultManager] setUmSocialAppkey:SSJDetailSettingForSource(@"UMAppKey")];
    
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession | UMSocialPlatformType_WechatTimeLine appKey:SSJDetailSettingForSource(@"WeiXinKey") appSecret:SSJDetailSettingForSource(@"WeiXinSecret") redirectURL:SSJDetailSettingForSource(@"ShareUrl")];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:SSJDetailSettingForSource(@"QQAppId") appSecret:nil redirectURL:SSJDetailSettingForSource(@"ShareUrl")];
    
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:SSJDetailSettingForSource(@"WeiBoAppKey") appSecret:SSJDetailSettingForSource(@"WeiBoSecret") redirectURL:SSJDetailSettingForSource(@"ShareUrl")];

}


@end
