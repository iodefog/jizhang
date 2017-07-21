//
//  SSJWishHelper.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJWishModel;

@interface SSJWishHelper : NSObject


typedef NS_ENUM(NSInteger, SSJSaveImgType) {
    SSJSaveImgTypeLocal,          // 保存本地图片
    SSJSaveImgTypeCustom         // 保存自定义图片
};

/**
 查询用户是否新建过愿望
 */
+ (BOOL)queryHasWishsWithError:(NSError **)error;



/**
 将图片保存到bk_wish表中

 @param imageName 图片名称
 @param type 保存图片类型
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)saveImageToWishTable:(NSString *)imageName
                    saveType:(SSJSaveImgType)type
                     success:(void(^)(NSString *imageName))success
                     failure:(void(^)(NSError *error))failure;


/**
 将图片保存到bk_img_sync表中
 
 @param imageName 图片名称
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)saveImageToImgSyncTable:(NSString *)imageName
                        success:(void(^)(NSString *imageName))success
                        failure:(void(^)(NSError *error))failure;



/**
 保存心愿

 @param wishModel 心愿model
 @param success 成功
 @param failure 失败
 */
+ (void)saveWishWithWishModel:(SSJWishModel *)wishModel
                      success:(void(^)())success
                      failure:(void(^)(NSError *error))failure;



/**
 查询心愿列表

 @param state 已完成或者未完成
 @param success 成功
 @param failure 失败
 */
+ (void)queryIngWishWithState:(SSJWishState)state
                      success:(void(^)(NSMutableArray <SSJWishModel *>*resultArr))success
                     failure:(void(^)(NSError *error))failure;


/**
 根据心愿ID查询心愿详情

 @param wishId 心愿id
 @param success 成功
 @param failure 失败
 */
+ (void)queryWishWithWisId:(NSString *)wishId
                   Success:(void(^)(SSJWishModel *resultItem))success
                   failure:(void(^)(NSError *error))failure;


/**
 根据心愿ID删除某个心愿

 @param wishId 心愿id
 @param success 成功
 @param failure 失败
 */
+ (void)deleteWishWithWisId:(NSString *)wishId
                   Success:(void(^)())success
                   failure:(void(^)(NSError *error))failure;

@end
