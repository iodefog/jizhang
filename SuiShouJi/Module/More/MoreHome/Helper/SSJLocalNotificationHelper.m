//
//  SSJLocalNotificationHelper.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLocalNotificationHelper.h"
#import "SSJStartChecker.h"

@interface SSJLocalNotificationHelper()

@end
@implementation SSJLocalNotificationHelper

+ (void)load {
    if (SSJIsFirstLaunchForCurrentVersion()) {
        NSString *baseDateStr = [NSString stringWithFormat:@"%@ 20:00:00",[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]];
        NSDate *baseDate = [NSDate dateWithString:baseDateStr formatString:@"yyyy-MM-dd HH:mm:ss"];
        if ([baseDate isEarlierThan:[NSDate date]]) {
            baseDate = [baseDate dateByAddingDays:1];
        }
        [SSJLocalNotificationHelper cancelLocalNotificationWithKey:SSJChargeReminderNotification];
        [SSJLocalNotificationHelper registerLocalNotificationWithFireDate:baseDate repeatIterval:NSCalendarUnitDay notificationKey:SSJChargeReminderNotification];
    }
}

+(void)registerLocalNotificationWithFireDate:(NSDate*)fireDate
                               repeatIterval:(NSCalendarUnit)repeatIterval
                             notificationKey:(NSString *)notificationKey
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // 设置触发通知的时间
    notification.fireDate = fireDate;
    // 时区
    notification.timeZone = [NSTimeZone defaultTimeZone];
    // 设置重复的间隔
    notification.repeatInterval = repeatIterval;
    // 通知内容
    if ([SSJStartChecker sharedInstance].remindMassage) {
        notification.alertBody =  [SSJStartChecker sharedInstance].remindMassage;
    }else{
        notification.alertBody =  @"精打细算，有吃有穿，小主快来记账啦～";
    }

    notification.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    // 通知被触发时播放的声音
    notification.soundName = @"pushsound.wav";
    // 通知参数
    NSDictionary *userDict = [NSDictionary dictionaryWithObject:notificationKey forKey:@"key"];
    notification.userInfo = userDict;
    // ios8后，需要添加这个注册，才能得到授权
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        notification.repeatInterval = repeatIterval;
    }
    // 执行通知注册
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    NSLog(@"-----------%lu",(unsigned long)localNotifications.count);
}

+(void)cancelLocalNotificationWithKey:(NSString *)key{
    // 获取所有本地通知数组
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    
    for (UILocalNotification *notification in localNotifications) {
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            // 根据设置通知参数时指定的key来获取通知参数
            NSString *info = userInfo[@"key"];
            
            // 如果找到需要取消的通知，则取消
            if (([info isEqualToString: key])) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
            }  
        }  
    }
    NSArray *NewlocalNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;

    NSLog(@"-----------%lu",(unsigned long)NewlocalNotifications.count);
}


@end
