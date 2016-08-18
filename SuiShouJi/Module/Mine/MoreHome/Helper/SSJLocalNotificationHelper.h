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
+ (void)registerLocalNotificationWithremindItem:(SSJReminderItem *)item;


/**
 *  取消本地通知
 *
 *  @param key 要取消的本地通知的key
 */
+ (void)cancelLocalNotificationWithKey:(nullable NSString *)key;

/**
 *  取消一个本地通知
 *
 *  @param item 通知的item
 */
+ (void)cancelLocalNotificationWithremindItem:(SSJReminderItem *)item;
@end
