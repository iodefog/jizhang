//
//  SSJLocalNotificationHelper.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJReminderItem.h"

@interface SSJLocalNotificationHelper : NSObject

/**
*  注册一个本地通知
*
*  @param item 通知的item
*/
+ (void)registerLocalNotificationWithremindItem:(SSJReminderItem * __nonnull)item;


/**
 *  取消本地通知
 *
 *  @param key 要取消的本地通知的key
 */
+ (void)cancelLocalNotificationWithKey:(NSString * __nullable)key;

/**
 *  取消一个本地通知
 *
 *  @param item 通知的item
 */
+ (void)cancelLocalNotificationWithremindItem:(SSJReminderItem * __nonnull)item;

/**
 *  取消某个用户所有的通知
 *
 *  @param userId 用户id
 */
+ (void)cancelLocalNotificationWithUserId:(NSString * __nonnull)userId;
@end
