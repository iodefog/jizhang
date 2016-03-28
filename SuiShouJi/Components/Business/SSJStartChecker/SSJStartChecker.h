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

/**
 *  返回唯一实例
 *
 *  @return (instancetype) 返回唯一实例对象
 */
+ (instancetype)sharedInstance;

/**
 *  请求启动接口（版本更新、苹果审核控制）
 *
 *  @param success 请求成功的回调
 *  @param failure 请求失败的回调
 */
- (void)checkWithSuccess:(void(^)(BOOL isInReview, SSJAppUpdateType type))success
                 failure:(void(^)(NSString *message))failure;

/**
 *  返回是否正在审核，应该在checkWithSuccess:failure:方法之后嗲用，如果之前没有调用果，则直接返回NO；
 *
 *  @return BOOL 是否正在审核
 */
- (BOOL)isInReview;

/**
 *  推送提示文字
 *
 *  @return NSString 提示内容
 */
- (NSString *)remindMassage;

/**
 *  启动页图片地址
 *
 *  @return NSString 图片url(需要拼接)
 */
- (NSString *)startImageUrl;

@end
