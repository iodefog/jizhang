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

//  友盟key
static NSString *const kUMAppKey = @"566e6f12e0f55ac052003f62";

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
    UMConfigInstance.appKey = kUMAppKey;
    UMConfigInstance.ePolicy = (ReportPolicy)BATCH;
    UMConfigInstance.channelId = SSJDefaultSource();
    [MobClick startWithConfigure:UMConfigInstance]; 
//    [MobClick startWithAppkey:kUMAppKey reportPolicy:(ReportPolicy)BATCH channelId:SSJDefaultSource()];
}

/* 友盟分享 */
+ (void)umengShare{
    [UMSocialData setAppKey:kUMAppKey];
    [UMSocialWechatHandler setWXAppId:SSJWeiXinAppKey appSecret:SSJWeiXinSecret url:@"http://5.9188.com/note/d/"];
    [UMSocialData defaultData].extConfig.wechatSessionData.title = @"9188记账，一种快速实现财务自由的方式。";
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = @"9188记账，一种快速实现财务自由的方式。";
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = @"http://5.9188.com/note/d/";
    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:SSJWeiBoAppKey secret:SSJWeiBoSecret RedirectURL:SSJAppStoreAddress];
    [UMSocialQQHandler setQQWithAppId:SSJQQAppId appKey:SSJQQAppKey url:@"http://5.9188.com/note/d/"];
    [UMSocialData defaultData].extConfig.qqData.title = @"9188记账，一种快速实现财务自由的方式。";
}


@end
