//
//  SSJDataClearManager.h
//  SuiShouJi
//
//  Created by ricky on 16/7/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJDataClearHelper : NSObject

+ (void)clearLocalDataWithSuccess:(void(^)())success
                      failure:(void (^)(NSError *error))failure;


+ (void)clearAllDataWithSuccess:(void(^)())success
                        failure:(void (^)(NSError *error))failure;

/**
 上传当前用户所有数据

 @param success 成功回调；syncTime代表同步成功的时间
 @param failure 失败回调
 */
+ (void)uploadAllUserDataWithSuccess:(void(^)(NSString *syncTime))success
                             failure:(void (^)(NSError *error))failure;

/**
 计算磁盘和内存缓存数据大小，结果以字节为单位

 @param success 成功回调，size是计算结果
 @param failure 失败回调
 */
+ (void)caculateCacheDataSizeWithSuccess:(void(^)(int64_t size))success
                                 failure:(void (^)(NSError *error))failure;

/**
 清楚磁盘和内存缓存数据

 @param success 成功回调
 @param failure 失败回调
 */
+ (void)clearLocalDataCacheWithSuccess:(void(^)())success
                               failure:(void (^)(NSError *error))failure;

@end
