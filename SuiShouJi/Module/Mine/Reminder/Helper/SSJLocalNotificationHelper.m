//
//  SSJLocalNotificationHelper.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLocalNotificationHelper.h"
#import "SSJStartChecker.h"
#import "SSJDatabaseQueue.h"

@interface SSJLocalNotificationHelper()

@end
@implementation SSJLocalNotificationHelper

//+ (void)load {
//    if (SSJIsFirstLaunchForCurrentVersion()) {
//        NSString *baseDateStr = [NSString stringWithFormat:@"%@ 20:00:00",[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]];
//        NSDate *baseDate = [NSDate dateWithString:baseDateStr formatString:@"yyyy-MM-dd HH:mm:ss"];
//        if ([baseDate isEarlierThan:[NSDate date]]) {
//            baseDate = [baseDate dateByAddingDays:1];
//        }
//        [SSJLocalNotificationHelper cancelLocalNotificationWithKey:SSJChargeReminderNotification];
//        [SSJLocalNotificationHelper registerLocalNotificationWithFireDate:baseDate repeatIterval:NSCalendarUnitDay notificationKey:SSJChargeReminderNotification];
//    }
//}

+ (void)registerLocalNotificationWithremindItem:(SSJReminderItem *)item
{
    if (!item.userId.length) {
        item.userId = SSJUSERID();
    }
    
    NSMutableArray *notificationsArr = [NSMutableArray array];
    
    NSDictionary *remindDic = [item mj_keyValues];
    
    NSDate * fireDate = item.remindDate;
    
    if (!item.userId.length) {
        item.userId = SSJUSERID();
    }
    
    if (!item.remindState) {
        return;
    }
    
    if ([fireDate isEarlierThan:[NSDate date]] && item.remindCycle == 7) {
        SSJPRINT(@"%@早于当前日期,不能添加提醒",[fireDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"]);
        return;
    }
    
    if (!item.remindContent.length) {
        switch (item.remindType) {
            case SSJReminderTypeNormal:{
                if (item.remindMemo.length) {
                    item.remindContent = [NSString stringWithFormat:@"%@(%@)",item.remindName,item.remindMemo];
                }else{
                    item.remindContent = [NSString stringWithFormat:@"%@",item.remindName];
                }
                break;
            }
                
            case SSJReminderTypeBorrowing:{
                if (!item.borrowtarget.length) {
                    item.borrowtarget = @"";
                }
                if (!item.borrowtOrLend) {
                    item.remindContent = [NSString stringWithFormat:@"还债啦，您有一笔欠%@的钱款，赶紧去结清吧！",item.borrowtarget];
                }else{
                    item.remindContent = [NSString stringWithFormat:@"追债啦，您有一笔被%@借走的钱款，赶紧去结清吧！",item.borrowtarget];
                }
                break;
            }
                
            case SSJReminderTypeCreditCard:
                item.remindContent = [NSString stringWithFormat:@"%@该还款啦，小主快去还账单吧！",item.remindName];
                break;
                
            case SSJReminderTypeWish:
            case SSJReminderTypeCharge:{
                if (item.remindMemo.length) {
                    item.remindContent = [NSString stringWithFormat:@"%@(%@)",item.remindName,item.remindMemo];
                }else{
                    item.remindContent = [NSString stringWithFormat:@"%@",item.remindName];
                }
                break;
            }

                
            default:
                break;
        }
    }
    
    switch (item.remindCycle) {
        // 如果是每天
        case 0:{
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            // 时区
            notification.timeZone = [NSTimeZone defaultTimeZone];
            // 通知内容
            notification.alertBody = item.remindContent;
            // 通知被触发时播放的声音
            notification.soundName = @"pushsound.wav";
            // 通知参数
            NSDictionary *userDict = @{@"remindItem":remindDic,
                                       @"key":SSJReminderNotificationKey};
            notification.userInfo = userDict;
            notification.repeatInterval = NSCalendarUnitDay;
            notification.fireDate = fireDate;
            [notificationsArr addObject:notification];
        }
        break;
        
        // 如果是每周
        case 3:{
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            // 时区
            notification.timeZone = [NSTimeZone defaultTimeZone];
            // 通知内容
            notification.alertBody = item.remindContent;
            // 通知被触发时播放的声音
            notification.soundName = @"pushsound.wav";
            // 通知参数
            NSDictionary *userDict = @{@"remindItem":remindDic,
                                       @"key":SSJReminderNotificationKey};
            notification.userInfo = userDict;
            notification.repeatInterval = NSCalendarUnitWeekOfYear;
            notification.fireDate = fireDate;
            [notificationsArr addObject:notification];
        }
        break;
        
        // 如果是仅一次
        case 7:{
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            // 时区
            notification.timeZone = [NSTimeZone defaultTimeZone];
            // 通知内容
            notification.alertBody = item.remindContent;
            // 通知被触发时播放的声音
            notification.soundName = @"pushsound.wav";
            // 通知参数
            NSDictionary *userDict = @{@"remindItem":remindDic,
                                       @"key":SSJReminderNotificationKey};
            notification.userInfo = userDict;
            if ([fireDate isEarlierThan:[NSDate date]]) {
                fireDate = [fireDate dateByAddingDays:1];
            }
            notification.fireDate = fireDate;
            [notificationsArr addObject:notification];
        }
        break;
        
        // 如果是没周末,添加两个推送
        case 2:{
            NSDate *firstDayOfTheWeek = [[fireDate dateBySubtractingDays:fireDate.weekday] dateByAddingDays:2];
            if (fireDate.weekday != 1) {
                for (int i = 5; i < 7; i ++) {
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    // 时区
                    notification.timeZone = [NSTimeZone defaultTimeZone];
                    // 通知内容
                    notification.alertBody = item.remindContent;
                    // 通知被触发时播放的声音
                    notification.soundName = @"pushsound.wav";
                    // 通知参数
                    NSDictionary *userDict = @{@"remindItem":remindDic,
                                               @"key":SSJReminderNotificationKey};
                    notification.userInfo = userDict;
                    notification.fireDate = [firstDayOfTheWeek dateByAddingDays:i];
                    notification.repeatInterval = NSCalendarUnitWeekOfYear;
                    [notificationsArr addObject:notification];
                }
            }else{
                for (int i = 0; i < 2 ; i ++) {
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    // 时区
                    notification.timeZone = [NSTimeZone defaultTimeZone];
                    // 通知内容
                    notification.alertBody = item.remindContent;
                    // 通知被触发时播放的声音
                    notification.soundName = @"pushsound.wav";
                    // 通知参数
                    NSDictionary *userDict = @{@"remindItem":remindDic,
                                               @"key":SSJReminderNotificationKey};
                    notification.userInfo = userDict;
                    notification.fireDate = [fireDate dateBySubtractingDays:i];
                    notification.repeatInterval = NSCalendarUnitWeekOfYear;
                    [notificationsArr addObject:notification];
                }
            }
        }
        break;
        
        // 如果是每年
        case 6:{
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            // 时区
            notification.timeZone = [NSTimeZone defaultTimeZone];
            // 通知内容
            notification.alertBody = item.remindContent;
            // 通知被触发时播放的声音
            notification.soundName = @"pushsound.wav";
            // 通知参数
            NSDictionary *userDict = @{@"remindItem":remindDic,
                                       @"key":SSJReminderNotificationKey};
            notification.userInfo = userDict;
            notification.fireDate = fireDate;
            notification.repeatInterval = NSCalendarUnitYear;
            [notificationsArr addObject:notification];
        }
        break;

        
        // 如果是每月最后一天
        case 5:{
            NSArray *localNotifications = [NSArray arrayWithArray:[UIApplication sharedApplication].scheduledLocalNotifications];
            for (UILocalNotification *notification in localNotifications) {
                NSDictionary *userinfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
                SSJReminderItem *remindItem = [SSJReminderItem mj_objectWithKeyValues:[userinfo objectForKey:@"remindItem"]];
                if ([userinfo[@"key"] isEqualToString:SSJReminderNotificationKey]) {
                    if ([remindItem.remindId isEqualToString:item.remindId] && item.remindDate.month == fireDate.month) {
                        return;
                    }
                }
            }
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            // 时区
            notification.timeZone = [NSTimeZone defaultTimeZone];
            // 通知内容
            notification.alertBody = item.remindContent;
            // 通知被触发时播放的声音
            notification.soundName = @"pushsound.wav";
            // 通知参数
            NSDictionary *userDict = @{@"remindItem":remindDic,
                                       @"key":SSJReminderNotificationKey};
            notification.userInfo = userDict;
            NSDate *lastDayOfTheMonth = [NSDate dateWithYear:fireDate.year month:fireDate.month day:fireDate.daysInMonth hour:fireDate.hour minute:fireDate.minute second:fireDate.second];
            notification.fireDate = lastDayOfTheMonth;
            [notificationsArr addObject:notification];
        }
        break;
        
        // 如果是每月
        case 4:{
            // 如果是大于28号,则只要添加一次推送
            if (!item.remindAtTheEndOfMonth) {
                if (fireDate.day > 28) {
                    
                    // 如果提醒日期大于本月最后一天则跳过
                    if (fireDate.day > [NSDate date].daysInMonth) {
                        return;
                    }
                    
                    NSArray *localNotifications = [NSArray arrayWithArray:[UIApplication sharedApplication].scheduledLocalNotifications];
                    // 查询本月有没有添加过提醒,如果添加过,则跳过
                    for (UILocalNotification *notification in localNotifications) {
                        NSDictionary *userinfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
                        SSJReminderItem *remindItem = [SSJReminderItem mj_objectWithKeyValues:[userinfo objectForKey:@"remindItem"]];
                        if ([userinfo[@"key"] isEqualToString:SSJReminderNotificationKey]) {
                            if ([remindItem.remindId isEqualToString:item.remindId] && item.remindDate.month == [NSDate date].month) {
                                return;
                            }
                        }
                    }
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    // 时区
                    notification.timeZone = [NSTimeZone defaultTimeZone];
                    // 通知内容
                    notification.alertBody = item.remindContent;
                    // 通知被触发时播放的声音
                    notification.soundName = @"pushsound.wav";
                    
                    NSDate *newRemindDate = [NSDate dateWithYear:fireDate.year month:[NSDate date].month day:fireDate.day hour:fireDate.hour minute:fireDate.minute second:fireDate.second];
                    
                    item.remindDate = newRemindDate;
                    
                    remindDic = [item mj_keyValues];
                    
                    // 通知参数
                    NSDictionary *userDict = @{@"remindItem":remindDic,
                                               @"key":SSJReminderNotificationKey};
                    notification.userInfo = userDict;
                    notification.fireDate = item.remindDate;
                    [notificationsArr addObject:notification];
                }else{
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    // 时区
                    notification.timeZone = [NSTimeZone defaultTimeZone];
                    // 通知内容
                    notification.alertBody = item.remindContent;
                    // 通知被触发时播放的声音
                    notification.soundName = @"pushsound.wav";
                    // 通知参数
                    NSDictionary *userDict = @{@"remindItem":remindDic,
                                               @"key":SSJReminderNotificationKey};
                    notification.userInfo = userDict;
                    notification.repeatInterval = NSCalendarUnitMonth;
                    notification.fireDate = fireDate;
                    [notificationsArr addObject:notification];
                }
            }else{
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                // 时区
                notification.timeZone = [NSTimeZone defaultTimeZone];
                // 通知内容
                notification.alertBody = item.remindContent;
                // 通知被触发时播放的声音
                notification.soundName = @"pushsound.wav";
                // 通知参数
                NSDictionary *userDict = @{@"remindItem":remindDic,
                                            @"key":SSJReminderNotificationKey};
                notification.userInfo = userDict;
                notification.repeatInterval = NSCalendarUnitMonth;
                notification.fireDate = fireDate;
                [notificationsArr addObject:notification];
            }
        }
        break;
        
        // 如果是每个工作日,添加五个推送
        case 1:{
            NSDate *firstDayOfTheWeek = [[fireDate dateBySubtractingDays:fireDate.weekday] dateByAddingDays:2];
            for (int i = 0; i < 5; i ++) {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                // 时区
                notification.timeZone = [NSTimeZone defaultTimeZone];
                // 通知内容
                notification.alertBody = item.remindContent;
                // 通知被触发时播放的声音
                notification.soundName = @"pushsound.wav";
                // 通知参数
                NSDictionary *userDict = @{@"remindItem":remindDic,
                                           @"key":SSJReminderNotificationKey};
                notification.userInfo = userDict;
                notification.fireDate = [firstDayOfTheWeek dateByAddingDays:i];
                notification.repeatInterval = NSCalendarUnitWeekday;
                [notificationsArr addObject:notification];
            }
        }
        break;
        
        default:{
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            // 时区
            notification.timeZone = [NSTimeZone defaultTimeZone];
            // 通知内容
            notification.alertBody = item.remindContent;
            // 通知被触发时播放的声音
            notification.soundName = @"pushsound.wav";
            // 通知参数
            NSDictionary *userDict = @{@"remindItem":remindDic,
                                       @"key":SSJReminderNotificationKey};
            notification.userInfo = userDict;
            if ([fireDate isEarlierThan:[NSDate date]]) {
                fireDate = [fireDate dateByAddingDays:1];
            }
            notification.fireDate = fireDate;
            [notificationsArr addObject:notification];
        }
        break;
    }
    
    //mzl modify
    // ios8后，需要添加这个注册，才能得到授权
//     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SSJNoticeAlertKey];
//    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
//        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
//        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
//                                                                                 categories:nil];
//        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//    }
    // 执行通知注册
    for (UILocalNotification *notification in notificationsArr) {
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    NSArray *localNotifications = [[NSArray alloc]init];
    localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
}

+ (void)cancelLocalNotificationWithKey:(nullable NSString *)key{
    if (!key.length) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        return;
    }
    // 获取所有本地通知数组
    NSArray *localNotifications = [[NSArray alloc]init];
    localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
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
}

+ (void)cancelLocalNotificationWithremindItem:(SSJReminderItem *)item{
    NSArray *localNotifications = [NSArray arrayWithArray:[UIApplication sharedApplication].scheduledLocalNotifications];
    for (UILocalNotification *notification in localNotifications) {
        NSDictionary *userinfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
        SSJReminderItem *remindItem = [SSJReminderItem mj_objectWithKeyValues:[userinfo objectForKey:@"remindItem"]];
        if ([userinfo[@"key"] isEqualToString:SSJReminderNotificationKey]) {
            if ([remindItem.remindId isEqualToString:item.remindId]) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
            }
        }
    }
}

+ (void)cancelLocalNotificationWithUserId:(NSString *)userId{
    if (!userId.length) {
        [CDAutoHideMessageHUD showMessage:@"用户id不能为空"];
        return;
    }
    NSArray *localNotifications = [NSArray arrayWithArray:[UIApplication sharedApplication].scheduledLocalNotifications];
    for (UILocalNotification *notification in localNotifications) {
        NSDictionary *userinfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
        SSJReminderItem *remindItem = [SSJReminderItem mj_objectWithKeyValues:[userinfo objectForKey:@"remindItem"]];
        if ([remindItem.userId isEqualToString:userId]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

+ (NSDate *)calculateNexRemindDateWithStartDate:(NSDate *)date remindCycle:(NSInteger)remindCycle remindAtEndOfMonth:(BOOL)remindAtEndOfMonth{
    // 算出下一次提示时间
    NSDate *today = [NSDate date];
    NSDate *endOfToday = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day hour:24 minute:0 second:0];
    NSDate *nextRemindDate;
    NSDate *baseStartDate;
    if ([date isLaterThan:endOfToday]) {
        baseStartDate = date;
    }else{
        baseStartDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day hour:date.hour minute:date.minute second:date.second];
    }
    NSDate *baseDate = [NSDate dateWithYear:today.year month:today.month day:today.day hour:date.hour minute:date.minute second:date.second];
    switch (remindCycle) {
        case 0:{
            // 如果是每天
            if ([baseStartDate isEarlierThan:[NSDate date]]) {
                // 如果已经早于现在,则加一天
                nextRemindDate = [baseStartDate dateByAddingDays:1];
            }else{
                nextRemindDate = baseStartDate;
            }
        }
            break;
            
        case 2:{
            //若是每周末
            if ([baseStartDate isWeekend]) {
                if (baseStartDate.weekday == 1) {
                    // 如果是礼拜天
                    if ([baseStartDate isEarlierThan:today]) {
                        // 如果设置的时间早于现在则加六天
                        nextRemindDate = [baseStartDate dateByAddingDays:6];
                    }else{
                        nextRemindDate = baseStartDate;
                    }
                }else{
                    // 如果是礼拜六
                    if ([baseStartDate isEarlierThan:today]) {
                        // 如果设置的时间早于现在则加一天
                        nextRemindDate = [baseStartDate dateByAddingDays:1];
                    }else{
                        nextRemindDate = baseStartDate;
                    }
                }
            }else{
                // 如果不是周末
                nextRemindDate = [[baseStartDate dateBySubtractingDays:baseStartDate.weekday] dateByAddingDays:7];
            }
        }
            break;
            
        case 1:{
            // 如果是每个工作日
            if (![baseStartDate isWeekend]) {
                // 如果是工作日
                if ([baseStartDate isEarlierThan:today]) {
                    // 如果时间早于现在
                    if (baseStartDate.weekday == 6) {
                        // 如果是礼拜五则要加到下个礼拜一
                        nextRemindDate = [baseStartDate dateByAddingDays:3];
                    }else{
                        nextRemindDate = [baseStartDate dateByAddingDays:1];
                    }
                }else{
                    nextRemindDate = baseStartDate;
                }
            }else{
                // 如果是周末
                if (baseStartDate.weekday == 1) {
                    nextRemindDate = [baseStartDate dateByAddingDays:1];
                }else{
                    nextRemindDate = [baseStartDate dateByAddingDays:2];
                }
            }
        }
            break;
            
        case 3:{
            // 如果是每周
            if (date.weekday == baseStartDate.weekday) {
                // 如果每周是今天记账
                if ([baseStartDate isEarlierThan:today]) {
                    // 如果是早于现在则要到下周提醒
                    nextRemindDate = [baseStartDate dateByAddingDays:7];
                }else{
                    nextRemindDate = baseStartDate;
                }
            }else{
                if (date.weekday < baseStartDate.weekday) {
                    // 如果提醒的星期几比今天早,则下个礼拜提醒
                    nextRemindDate = [[[baseStartDate dateBySubtractingDays:baseStartDate.weekday] dateByAddingDays:date.weekday] dateByAddingWeeks:1];
                }else{
                    nextRemindDate = [[baseStartDate dateBySubtractingDays:baseStartDate.weekday] dateByAddingDays:date.weekday];
                }
            }
        }
            break;
            
        case 4:{
            // 如果是每月
            baseStartDate = [NSDate dateWithYear:baseStartDate.year month:baseStartDate.month day:date.day hour:baseStartDate.hour minute:baseStartDate.minute second:baseStartDate.second];
            if (date.day > 28 && date.day < baseStartDate.daysInMonth) {
                // 如果提醒时间大于28号,并且日期大于本月的最大日期
                if (remindAtEndOfMonth) {
                    nextRemindDate = [NSDate dateWithYear:baseStartDate.year month:baseStartDate.month day:baseStartDate.daysInMonth hour:date.hour minute:date.minute second:date.second];
                }else{
                    nextRemindDate = [baseStartDate dateByAddingMonths:1];
                }
            }else{
                if (date.day > baseStartDate.day) {
                    // 如果提醒还没到时间
                    nextRemindDate = baseStartDate;
                }else if (date.day < baseStartDate.day){
                    nextRemindDate = [baseStartDate dateByAddingMonths:1];
                }else{
                    if ([baseStartDate isEarlierThan:baseDate]) {
                        //如果提醒过了
                        nextRemindDate = [baseStartDate dateByAddingMonths:1];
                    }else{
                        nextRemindDate = baseStartDate;
                    }
                }
            }
        }
            break;
            
        case 5:{
            // 如果是每月最后一天
            baseStartDate = [NSDate dateWithYear:baseStartDate.year month:baseStartDate.month day:date.day hour:baseStartDate.hour minute:baseStartDate.minute second:baseStartDate.second];
            if (baseStartDate.day != baseStartDate.daysInMonth) {
                nextRemindDate = [NSDate dateWithYear:baseStartDate.year month:baseStartDate.month day:baseStartDate.daysInMonth hour:date.hour minute:date.minute second:date.second];
            }else{
                //如果今天是每月最后一天
                if ([baseStartDate isEarlierThan:today]) {
                    //如果已经提醒过了就下个月提醒
                    nextRemindDate = [[NSDate dateWithYear:baseStartDate.year month:baseStartDate.month day:[baseStartDate dateByAddingMonths:1].daysInMonth hour:date.hour minute:date.minute second:date.second] dateByAddingMonths:1];
                }else{
                    //如果没有就今天提醒
                    nextRemindDate = baseStartDate;
                }
            }
        }
            break;
            
        case 6:{
            // 如果是每年
            baseDate = [NSDate dateWithYear:baseDate.year month:date.month day:date.day hour:baseDate.hour minute:baseDate.minute second:baseDate.second];
            if ([baseStartDate isEarlierThan:today]) {
                nextRemindDate = [baseStartDate dateByAddingYears:1];
            }else{
                nextRemindDate = baseStartDate;
            }
        }
            break;
            
        case 7:{
            //仅一次
            nextRemindDate = date;
        }
            break;
            
        default:
            nextRemindDate = date;
            break;
    }
    return nextRemindDate;
}

@end
