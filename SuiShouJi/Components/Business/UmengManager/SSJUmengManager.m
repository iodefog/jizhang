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
#import "UMSocialSinaSSOHandler.h"
#import <UMMobClick/MobClick.h>
#import "UMSocial.h"


@implementation SSJUmengManager

+ (void)load {
//    NSDate *beginDate = [NSDate date];
    //  添加友盟统计
    [self umengTrack];
    
    //  添加友盟分享
    [self umengShare];
    
    
//    NSLog(@">>> 友盟加载时间：%f",  ,[[NSDate date] timeIntervalSinceDate:beginDate]);
}

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
    [UMSocialData setAppKey:SSJDetailSettingForSource(@"UMAppKey")];
    [UMSocialWechatHandler setWXAppId:SSJDetailSettingForSource(@"WeiXinKey") appSecret:SSJDetailSettingForSource(@"WeiXinSecret") url:SSJDetailSettingForSource(@"ShareUrl")];
    [UMSocialData defaultData].extConfig.wechatSessionData.title = SSJDetailSettingForSource(@"ShareTitle");
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = SSJDetailSettingForSource(@"ShareTitle");
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = SSJDetailSettingForSource(@"ShareUrl");
    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:SSJDetailSettingForSource(@"WeiBoAppKey") secret:SSJDetailSettingForSource(@"WeiBoSecret") RedirectURL:SSJDetailSettingForSource(@"AppStoreUrl")];
    [UMSocialQQHandler setQQWithAppId:SSJDetailSettingForSource(@"QQAppId") appKey:SSJDetailSettingForSource(@"QQAppKey") url:SSJDetailSettingForSource(@"ShareUrl")];
    [UMSocialData defaultData].extConfig.qqData.title = SSJDetailSettingForSource(@"ShareTitle");
}


@end
