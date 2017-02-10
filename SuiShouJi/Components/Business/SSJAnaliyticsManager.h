//
//  YYAnaliyticsManager.h
//  SuiShouJi
//
//  Created by ricky on 2017/2/9.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJAnaliyticsManager : NSObject

+ (void)SSJAnaliytics;

//用户登录成功后，调用此方法设置userid和username
+ (void)setUserId:(nullable NSString *)userId userName:(nullable NSString *)userName;

//用户退出登录调用
+ (void)loginOut;

//设置用户网络状态，使用kYYAnalyticsNetWorkStatus值
+ (void)setNetWorkStatus:(NSString *)netWorkStaus;

//设置用户经纬度信息
+ (void)setLongtitude:(CGFloat)longtitude Latitude:(CGFloat)latitude;

// 自动页面时长统计, 开始记录某个页面展示时长.
// 使用方法：必须配对调用beginLogPageView:和endLogPageView:两个函数来完成自动统计，若只调用某一个函数不会生成有效数据。
// 在该页面展示时调用beginLogPageView:，当退出该页面时调用endLogPageView:
+ (void)beginLogPageView:(NSString *)pageName;
+ (void)endLogPageView:(NSString *)pageName;

//自定义事件统计
+ (void)event:(NSString *)eventId;
+ (void)event:(NSString *)eventId extra:(  NSString *)extra;

@end
