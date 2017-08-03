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
 *  是否请求过启动接口，不区分成功或失败
 */
@property (nonatomic, readonly) BOOL isChecked;

/**
 *  启动接口是否请求成功，需要结合isChecked一起判断才能准确
 */
@property (nonatomic, readonly) BOOL isCheckedSuccess;

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
 *  请求启动接口（版本更新、苹果审核控制）
 *
 *  @param timeout 请求超时时限
 *  @param success 请求成功的回调
 *  @param failure 请求失败的回调
 */
- (void)checkWithTimeoutInterval:(NSTimeInterval)timeout
                         success:(void(^)(BOOL isInReview, SSJAppUpdateType type))success
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
//- (NSString *)startImageUrl;


/**
 *  lottie的下载地址
 *
 *  @return NSString lottie的url(需要拼接)
 */
//- (NSString *)lottieUrl;

/**
 *  启动页动态图片
 *
 *  @return NSString 动态图片url(需要拼接)
 */
//- (NSString *)animUrl;

/**
 *  下发的客服电话
 *
 *  @return NSString 图片url(需要拼接)
 */
- (NSString *)serviceNum;


@end
