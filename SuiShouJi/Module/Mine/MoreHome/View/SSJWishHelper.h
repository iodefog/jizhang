//
//  SSJWishHelper.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SSJWishChargeItem.h"
@class SSJWishModel;
@class SSJReminderItem;

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
 保存心愿

 @param wishModel 心愿model
 @param success 成功
 @param failure 失败
 */
+ (void)saveWishWithWishModel:(SSJWishModel *)wishModel
                      success:(void(^)())success
                      failure:(void(^)(NSError *error))failure;

/**
 终止心愿
 
 @param wishModel 心愿model
 @param success 成功
 @param failure 失败
 */
+ (void)termWishWithWishModel:(SSJWishModel *)wishModel
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
 根据心愿ID完成某个心愿
 
 @param wishId 心愿id
 @param success 成功
 @param failure 失败
 */
+ (void)finishWishWithWisId:(NSString *)wishId
                    Success:(void(^)())success
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

/**
 根据心愿ID终止某个心愿
 
 @param wishId 心愿id
 @param success 成功
 @param failure 失败
 */
+ (void)terminateWishWithWisId:(NSString *)wishId
                    Success:(void(^)())success
                       failure:(void(^)(NSError *error))failure;



/**
 根据心愿ID查询提醒信息

 @param wishId 心愿id
 @param success 成功
 @param failure 失败
 */
+ (void)queryWishRemindWithWishId:(NSString *)wishId Success:(void(^)(SSJReminderItem *remindItem))success
                          failure:(void(^)(NSError *error))failure;

#pragma mark - 流水操作

/**
 查询某个心愿的所有流水

 @param wishId 流水id
 @param success 成功
 @param failure 失败
 */
+ (void)queryWishChargeListWithWishid:(NSString *)wishId
                        success:(void(^)(NSMutableArray <SSJWishChargeItem *> *chargeArray))success
                        failure:(void(^)(NSError *error))failure;

/**
 保存心愿流水（存钱,取钱）
 
 @param wishModel 心愿model
 @param success 成功
 @param failure 失败
 */
+ (void)saveWishChargeWithWishChargeModel:(SSJWishChargeItem *)wishModel
                                     type:(SSJWishChargeBillType)type
                      success:(void(^)())success
                      failure:(void(^)(NSError *error))failure;


/**
 删除心愿流水
 
 @param wishId 心愿id
 @param success 成功
 @param failure 失败
 */
+ (void)deleteWishChargeWithWishChargeItem:(SSJWishChargeItem *)wishItem
                                  success:(void(^)())success
                                  failure:(void(^)(NSError *error))failure;



#pragma mark - 心愿图片
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





@end
