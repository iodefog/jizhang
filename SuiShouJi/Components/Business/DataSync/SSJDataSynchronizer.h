//
//  SSJDataSynchronizer.h
//  SuiShouJi
//
//  Created by old lang on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SSJDataSynchronizeType) {
    SSJDataSynchronizeTypeData,
    SSJDataSynchronizeTypeImage
};

@interface SSJDataSynchronizer : NSObject

/**
 *  返回唯一实例对象
 */
+ (instancetype)shareInstance;

/**
 *  开启定时同步，只在wifi环境下每间隔1小时同步1次；
 */
- (void)startTimingSync;

/**
 *  关闭定时同步
 */
- (void)stopTimingSync;

/**
 *  开始数据同步，包括同步用户数据、图片
 *
 *  @param success  同步成功回调
 *  @param failure  同步失败回调
 */
- (void)startSyncWithSuccess:(void (^)(SSJDataSynchronizeType type))success failure:(void (^)(SSJDataSynchronizeType type, NSError *error))failure;

/**
 *  根据网络环境、同步设置、是否登录决定是否需要同步
 *
 *  @param success  同步成功回调
 *  @param failure  同步失败回调
 */
- (void)startSyncIfNeededWithSuccess:(void (^)(SSJDataSynchronizeType type))success failure:(void (^)(SSJDataSynchronizeType type, NSError *error))failure;

@end
