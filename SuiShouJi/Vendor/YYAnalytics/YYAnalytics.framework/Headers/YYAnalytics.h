//
//  YYAnalytics.h
//  YYAnalytics
//
//  Created by Carl on 2016/12/29.
//  Copyright © 2016年 Carl. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YYAnalyticsConfig : NSObject
@property (nonatomic, copy) NSString *appKey; //由后台制定，唯一标识APP
@property (nonatomic, copy) NSString *appSource; //app渠道值，由后台制定
@property (nonatomic, copy) NSString *appChannel; //市场渠道名
@property (nonatomic, copy, nullable) NSString *userId; //若用户未登录可空
@property (nonatomic, copy, nullable) NSString *userName; //若用户未登录可空

@property (nonatomic, assign) BOOL logEnable;
@property (nonatomic, assign) BOOL isDebug;
@end

@interface YYAnalytics : NSObject

//初始化统计模块
+ (void)startWithConfig:(YYAnalyticsConfig *)config;

//用户登录成功后，调用此方法设置userid和username
+ (void)setUserId:(nullable NSString *)userId userName:(nullable NSString *)userName;

//用户退出登录调用
+ (void)loginOut;

//是否自动检查网络状态，默认为NO；若不使用自动检查网络状态，则可使用setNetWorkStatus: 手动设置网络状态
+ (void)setAutoDetectNetWorkStatusEnable:(BOOL)yesOrNO;
//设置用户网络状态，使用kYYAnalyticsNetWorkStatus值
+ (void)setNetWorkStatus:(NSString *)netWorkStaus;

////是否自动定位，默认为NO; 若不使用自动定位，则可使用setLongtitude:Latitude: 手动设置位置信息
+ (void)setAutoLocationEnable:(BOOL)yesOrNO;
//设置用户经纬度信息
+ (void)setLongtitude:(CGFloat)longtitude Latitude:(CGFloat)latitude;

// 自动页面时长统计, 开始记录某个页面展示时长.
// 使用方法：必须配对调用beginLogPageView:和endLogPageView:两个函数来完成自动统计，若只调用某一个函数不会生成有效数据。
// 在该页面展示时调用beginLogPageView:，当退出该页面时调用endLogPageView:
+ (void)beginLogPageView:(NSString *)pageName;
+ (void)endLogPageView:(NSString *)pageName;

//自定义事件统计
+ (void)event:(NSString *)eventId;
+ (void)event:(NSString *)eventId extra:(nullable NSString *)extra;

@end


extern NSString * const kYYAnalyticsNetWorkStatusUnknown;
extern NSString * const kYYAnalyticsNetWorkStatusNotReachable;
extern NSString * const kYYAnalyticsNetWorkStatus2G;
extern NSString * const kYYAnalyticsNetWorkStatus3G;
extern NSString * const kYYAnalyticsNetWorkStatus4G;
extern NSString * const kYYAnalyticsNetWorkStatusWWAN; //若为蜂窝连接且无法判断2g/3g/4g，使用此值
extern NSString * const kYYAnalyticsNetWorkStatusWiFi;

NS_ASSUME_NONNULL_END
