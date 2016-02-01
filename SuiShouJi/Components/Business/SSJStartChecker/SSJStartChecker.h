//
//  SSJStartChecker.h
//  SuiShouJi
//
//  Created by old lang on 16/2/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SSJAppUpdateType){
    /**
     *  没有更新
     */
    SSJAppUpdateTypeNone,
    /**
     *  有更新
     */
    SSJAppUpdateTypeUpdate,
    /**
     *  强制更新
     */
    SSJAppUpdateTypeForceUpdate
};

@interface SSJStartChecker : NSObject

+ (instancetype)sharedInstance;

/**
 *  请求启动接口（版本更新、苹果审核监测）
 *
 *  @param completion 检测完成的回调
 */
- (void)checkWithSuccess:(void(^)(BOOL isInReview, SSJAppUpdateType type))success
                 failure:(void(^)(NSString *message))failure;

/**
 *  返回是否正在审核
 *
 *  @return BOOL 是否正在审核
 */
- (BOOL)isInReview;

@end
