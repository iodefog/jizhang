//
//  SSJLocalNotificationStore.h
//  SuiShouJi
//
//  Created by ricky on 16/8/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJReminderItem.h"
#import "SSJDatabaseQueue.h"

@interface SSJLocalNotificationStore : NSObject

/**
 *  保存提醒
 *
 *  @param item 提醒的item
 *  @param db
 *
 *  @return (NSError)
 */
+ (NSError *)saveReminderWithReminderItem:(SSJReminderItem *)item inDatabase:(FMDatabase *)db;

/**
 *  同步保存保存提醒
 *
 *  @param item  @param item 提醒的item
 *  @param error (NSError)
 */
+ (void)syncSaveReminderWithReminderItem:(SSJReminderItem *)item
                                   Error:(NSError **)error;

/**
 *  异步保存提醒
 *
 *  @param item    提醒的item
 *  @param success 保存成功的回调
 *  @param failure 保存失败的回调
 */
+ (void)asyncsaveReminderWithReminderItem:(SSJReminderItem *)item
                                  Success:(void (^)(SSJReminderItem *))success
                                  failure:(void (^)(NSError *error))failure;

/**
 *  异步保存提醒
 *
 *  @param userId    用户id
 *  @param success 保存成功的回调
 *  @param failure 保存失败的回调
 */
+ (void)queryForreminderListForUserId:(NSString *)userId
                          WithSuccess:(void(^)(NSArray<SSJReminderItem *> *result))success
                              failure:(void (^)(NSError *error))failure;

/**
 *  获取某个提醒的详情
 *
 *  @param remindId 提醒的id
 *
 *  @return 提醒的item
 */
+ (SSJReminderItem *)queryReminderItemForID:(NSString *)remindId;

/**
 *  删除某个提醒
 *
 *  @param remindId 提醒的id
 *  @param error
 *
 *  @return 是否删除成功
 */
+ (BOOL)deleteReminderWithItem:(SSJReminderItem *)remindItem error:(NSError **)error;


/**
 *  删除心愿某个提醒
 *
 *  @param remindId 提醒的id
 *  @param error
 *
 *  @return 是否删除成功
 */
+ (BOOL)deleteWishReminderWithItem:(SSJReminderItem *)remindItem error:(NSError **)error;

@end
