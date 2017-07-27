//
//  YYAnaliyticsManager.m
//  SuiShouJi
//
//  Created by ricky on 2017/2/9.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJAnaliyticsManager.h"
#import <YYAnalytics/YYAnalytics.h>

@implementation SSJAnaliyticsManager

+ (void)SSJAnaliytics {
    YYAnalyticsConfig *config = [[YYAnalyticsConfig alloc] init];
    config.appSource = SSJDefaultSource();
    config.appKey = @"yy_jz";
    config.logEnable = NO;
    [YYAnalytics startWithConfig:config];
    [MobClick setCrashReportEnabled:YES]; // 如果不需要捕捉异常，注释掉此行
#ifdef DEBUG
    //    [SSJAnaliyticsManager setLogEnabled:YES];
#endif
    [MobClick setAppVersion:SSJAppVersion()]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    //  reportPolicy为枚举类型,可以为 REALTIME, BATCH,SENDDAILY,SENDWIFIONLY几种
    //  channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App Store"渠道
    UMConfigInstance.appKey = SSJDetailSettingForSource(@"UMAppKey");
    UMConfigInstance.ePolicy = (ReportPolicy)BATCH;
    UMConfigInstance.channelId = SSJDefaultSource();
    [MobClick startWithConfigure:UMConfigInstance];
}

//用户登录成功后，调用此方法设置userid和username
+ (void)setUserId:(nullable NSString *)userId userName:(nullable NSString *)userName {
    [YYAnalytics setUserId:userId userName:userName];
}

//用户退出登录调用
+ (void)loginOut {
    [YYAnalytics loginOut];
}

//设置用户网络状态，使用kYYAnalyticsNetWorkStatus值
+ (void)setNetWorkStatus:(NSString *)netWorkStaus {
    [YYAnalytics setNetWorkStatus:netWorkStaus];
}

//设置用户经纬度信息
+ (void)setLongtitude:(CGFloat)longtitude Latitude:(CGFloat)latitude {
    [YYAnalytics setLongtitude:longtitude Latitude:latitude];
    [MobClick setLatitude:latitude longitude:longtitude];
}

+ (void)beginLogPageView:(NSString *)pageName {
    [YYAnalytics beginLogPageView:pageName];
    [MobClick beginLogPageView:pageName];
}

+ (void)endLogPageView:(NSString *)pageName {
    [YYAnalytics endLogPageView:pageName];
    [MobClick endLogPageView:pageName];
}

//自定义事件统计
+ (void)event:(NSString *)eventId {
    [YYAnalytics event:eventId];
    [MobClick event:eventId];
}

+ (void)event:(NSString *)eventId extra:(nullable NSString *)extra {
    [YYAnalytics event:eventId extra:extra];
    [MobClick event:eventId label:extra];
}

@end
