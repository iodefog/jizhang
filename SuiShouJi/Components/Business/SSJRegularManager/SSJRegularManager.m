//
//  SSJRegularManager.m
//  SuiShouJi
//
//  Created by old lang on 16/3/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRegularManager.h"
#import <UIKit/UIKit.h>
#import "SSJDatabaseQueue.h"
#import "SSJDatePeriod.h"
#import "SSJFundAccountTable.h"
#import "SSJDailySumChargeTable.h"
#import "DTTimePeriod.h"

static NSString *const SSJRegularManagerNotificationIdKey = @"SSJRegularManagerNotificationIdKey";
static NSString *const SSJRegularManagerNotificationIdValue = @"SSJRegularManagerNotificationIdValue";

@interface SSJRegularManager ()

@end

@implementation SSJRegularManager

//+ (void)load {
//    [self registerRegularTaskNotification];
//}

+ (void)registerRegularTaskNotification {
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeNone categories:nil]];
    }
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    NSDate *date = [NSDate date];
    notification.fireDate = [NSDate dateWithYear:[date year] month:[date month] day:[date day]];
    notification.repeatInterval = NSCalendarUnitDay;
    notification.repeatCalendar = [NSCalendar currentCalendar];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.userInfo = @{SSJRegularManagerNotificationIdKey:SSJRegularManagerNotificationIdValue};
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

+ (void)performRegularTaskWithLocalNotification:(UILocalNotification *)notification {
    NSString *notificationId = notification.userInfo[SSJRegularManagerNotificationIdKey];
    if ([notificationId isEqualToString:SSJRegularManagerNotificationIdValue]) {
        [self supplementBookkeepingIfNeededForUserId:SSJUSERID() withSuccess:NULL failure:NULL];
        [self supplementBudgetIfNeededForUserId:SSJUSERID() withSuccess:NULL failure:NULL];
    }
}

+ (BOOL)supplementBookkeepingIfNeededForUserId:(NSString *)userId {
    __block BOOL successfull = YES;
    [[SSJDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        successfull = [self supplementBookkeepingForUserId:userId inDatabase:db rollback:rollback];
    }];
    return successfull;
}

+ (BOOL)supplementBudgetIfNeededForUserId:(NSString *)userId {
    __block BOOL successfull = YES;
    [[SSJDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        successfull = [self supplementBudgetForUserId:userId inDatabase:db rollback:rollback];
    }];
    return successfull;
    
}

+ (void)supplementBookkeepingIfNeededForUserId:(NSString *)userId
                                   withSuccess:(void(^)())success
                                       failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([self supplementBookkeepingForUserId:userId inDatabase:db rollback:rollback]) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
        } else {
            if (success) {
                SSJDispatch_main_async_safe(^{
                    success();
                });
            }
        }
    }];
}

+ (void)supplementBudgetIfNeededForUserId:(NSString *)userId
                              withSuccess:(void(^)())success
                                  failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([self supplementBudgetForUserId:userId inDatabase:db rollback:rollback]) {
            if (success) {
                SSJDispatch_main_async_safe(^{
                    success();
                });
            }
        } else {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
        }
    }];
}

+ (BOOL)supplementBookkeepingForUserId:(NSString *)userId inDatabase:(FMDatabase *)db rollback:(BOOL *)rollback {
    
    if (!userId || !userId.length) {
        SSJPRINT(@">>> SSJ Warning:userid must not be nil or empty");
        return NO;
    }
    
    //  查询当前用户所有有效定期记账最近一次的流水记录
    FMResultSet *resultSet = [db executeQuery:@"select max(a.cbilldate), a.thumburl, a.cbooksid, b.iconfigid, b.ibillid, b.ifunsid, b.itype, b.imoney, b.cimgurl, b.cmemo, b.cmemberids from bk_user_charge as a, bk_charge_period_config as b where a.iconfigid = b.iconfigid and a.cuserid = ? and b.cuserid = ? and b.istate = 1 and b.operatortype <> 2 and a.cbilldate <= datetime('now', 'localtime') group by b.iconfigid", userId, userId];
    if (!resultSet) {
        return NO;
    }
    
    NSMutableArray *configIdArr = [NSMutableArray array];
    
    while ([resultSet next]) {
        
        NSString *configId = [resultSet stringForColumn:@"iconfigid"];
        NSString *billId = [resultSet stringForColumn:@"ibillid"];
        NSString *funsid = [resultSet stringForColumn:@"ifunsid"];
        NSString *money = [resultSet stringForColumn:@"imoney"];
        NSString *imgUrl = [resultSet stringForColumn:@"cimgurl"];
        NSString *memo = [resultSet stringForColumn:@"cmemo"];
        NSString *thumbUrl = [resultSet stringForColumn:@"thumburl"];
        NSString *booksId = [resultSet stringForColumn:@"cbooksid"];
        
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSArray *memberIds = [[resultSet stringForColumn:@"cmemberids"] componentsSeparatedByString:@","];
        if (!memberIds) {
            memberIds = @[[NSString stringWithFormat:@"%@-0", userId]];
        }
        CGFloat memberMoney = [money doubleValue] / memberIds.count;
        
        [configIdArr addObject:[NSString stringWithFormat:@"'%@'", configId]];
        
        int periodType = [resultSet intForColumn:@"itype"];
        NSString *billDateStr = [resultSet stringForColumn:@"max(a.cbilldate)"];
        NSDate *billDate = [NSDate dateWithString:billDateStr formatString:@"yyyy-MM-dd"];
        NSArray *billDates = [self billDatesFromDate:billDate periodType:periodType containFromDate:NO];
        
        for (NSDate *billDate in billDates) {
            NSString *billDateStr = [billDate formattedDateWithFormat:@"yyyy-MM-dd"];
            NSString *chargeId = SSJUUID();
            
            if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, iconfigid, cbilldate, cmemo, cimgurl, thumburl, cbooksid, iversion, cwritedate, operatortype) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)", chargeId, userId, money, billId, funsid, configId, billDateStr, memo, imgUrl, thumbUrl, booksId, @(SSJSyncVersion()), writeDate]) {
                *rollback = YES;
                return NO;
            }
            
            // 根据周期记账配置成员生成成员流水
            for (NSString *memberId in memberIds) {
                if (![db executeUpdate:@"insert into bk_member_charge (ichargeid, cmemberid, imoney, iversion, cwritedate, operatortype) values (?, ?, ?, ?, ?, ?)", chargeId, memberId, @(memberMoney), @(SSJSyncVersion()), writeDate, @0]) {
                    *rollback = YES;
                    return NO;
                }
            }
        }
    }
    
    //  查询没有生成过流水的定期记账
    NSString *tConfigIdStr = [configIdArr componentsJoinedByString:@","];
    NSMutableString *query = [NSMutableString stringWithFormat:@"select iconfigid, ibillid, ifunsid, itype, imoney, cimgurl, cmemo, cbilldate, cbooksid, cmemberids from bk_charge_period_config where cuserid = '%@' and istate = 1 and operatortype <> 2", userId];
    if (tConfigIdStr.length) {
        [query appendFormat:@" and iconfigid not in (%@)", tConfigIdStr];
    }
    resultSet = [db executeQuery:query];
    if (!resultSet) {
        return NO;
    }
    
    while ([resultSet next]) {
        NSString *configId = [resultSet stringForColumn:@"iconfigid"];
        NSString *billId = [resultSet stringForColumn:@"ibillid"];
        NSString *funsid = [resultSet stringForColumn:@"ifunsid"];
        NSString *money = [resultSet stringForColumn:@"imoney"];
        NSString *imgUrl = [resultSet stringForColumn:@"cimgurl"];
        NSString *memo = [resultSet stringForColumn:@"cmemo"];
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString *thumbUrl = nil;
        if (imgUrl && imgUrl.length > 0) {
            NSString *imgExtension = [imgUrl pathExtension];
            NSString *imgName = [NSString stringWithFormat:@"%@-thumb", [imgUrl stringByDeletingPathExtension]];
            thumbUrl = [imgName stringByAppendingPathExtension:imgExtension];
        }
        
        NSString *booksid = [resultSet stringForColumn:@"cbooksid"];
        
        int periodType = [resultSet intForColumn:@"itype"];
        NSString *billDateStr = [resultSet stringForColumn:@"cbilldate"];
        NSDate *billDate = [NSDate dateWithString:billDateStr formatString:@"yyyy-MM-dd"];
        NSArray *tmpBillDates = [self billDatesFromDate:billDate periodType:periodType containFromDate:YES];
        NSMutableArray *billDates = [tmpBillDates mutableCopy];
        if (!billDates) {
            billDates = [NSMutableArray array];
        }
        
        NSArray *memberIds = [[resultSet stringForColumn:@"cmemberids"] componentsSeparatedByString:@","];
        if (!memberIds) {
            memberIds = @[[NSString stringWithFormat:@"%@-0", userId]];
        }
        CGFloat memberMoney = [money doubleValue] / memberIds.count;
        
        for (NSDate *billDate in billDates) {
            NSString *chargeId = SSJUUID();
            
            NSString *billDateStr = [billDate formattedDateWithFormat:@"yyyy-MM-dd"];
            if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, iconfigid, cbilldate, cmemo, cimgurl, thumburl, cbooksid, iversion, cwritedate, operatortype) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", chargeId, userId, money, billId, funsid, configId, billDateStr, memo, imgUrl, thumbUrl, booksid, @(SSJSyncVersion()), writeDate, @0]) {
                *rollback = YES;
                return NO;
            }
            
            // 根据周期记账配置成员生成成员流水
            for (NSString *memberId in memberIds) {
                if (![db executeUpdate:@"insert into bk_member_charge (ichargeid, cmemberid, imoney, iversion, cwritedate, operatortype) values (?, ?, ?, ?, ?, ?)", chargeId, memberId, @(memberMoney), @(SSJSyncVersion()), writeDate, @0]) {
                    *rollback = YES;
                    return NO;
                }
            }
        }
    }
    
    //  根据流水表更新资金帐户余额表和每日流水统计表
    if (![SSJFundAccountTable updateBalanceForUserId:userId inDatabase:db]
        || ![SSJDailySumChargeTable updateDailySumChargeForUserId:userId inDatabase:db]) {
        *rollback = YES;
        return NO;
    }
    
    return YES;
}

+ (BOOL)supplementBudgetForUserId:(NSString *)userId inDatabase:(FMDatabase *)db rollback:(BOOL *)rollback {
    //  根据周期类型、支出类型分类，查询离今天最近的一次预算
    FMResultSet *resultSet = [db executeQuery:@"select itype, imoney, iremindmoney, cbilltype, iremind, max(cedate), operatortype, istate, cbooksid, islastday from bk_user_budget where cuserid = ? and csdate <= datetime('now', 'localtime') group by itype, cbilltype, cbooksid", userId];
    if (!resultSet) {
        [resultSet close];
        return NO;
    }
    
    while ([resultSet next]) {
        NSDate *tDate = [NSDate date];
        NSDate *currentDate = [NSDate dateWithYear:[tDate year] month:[tDate month] day:[tDate day]];
        NSDate *recentEndDate = [NSDate dateWithString:[resultSet stringForColumn:@"max(cedate)"] formatString:@"yyyy-MM-dd"];
        
        //  如果最近的一次预算周期结束日期晚于或等于当前日期，就忽略
        if ([recentEndDate compare:currentDate] != NSOrderedAscending) {
            continue;
        }
        
        int operatortype = [resultSet intForColumn:@"operatortype"];
        int istate = [resultSet intForColumn:@"istate"];
        
        // 如果最近一次预算已删除或关闭，就忽略
        if (operatortype == 2 || istate == 0) {
            continue;
        }
        
        int itype = [resultSet intForColumn:@"itype"];
        NSString *imoney = [resultSet stringForColumn:@"imoney"];
        NSString *iremindmoney = [resultSet stringForColumn:@"iremindmoney"];
        NSString *cbilltype = [resultSet stringForColumn:@"cbilltype"];
        int iremind = [resultSet intForColumn:@"iremind"];
        NSString *currentDateStr = [tDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString *booksId = [resultSet stringForColumn:@"cbooksid"];
        BOOL isLastDay = [resultSet boolForColumn:@"islastday"];
        
//        NSArray *periodArr = [SSJDatePeriod periodsBetweenDate:recentEndDate andAnotherDate:currentDate periodType:[self periodTypeForItype:itype]];
        
        NSArray *periodArr = [self periodsWithAccountday:recentEndDate untilDate:currentDate type:itype isLastDay:isLastDay];
        
        for (DTTimePeriod *period in periodArr) {
            NSString *beginDate = [period.StartDate formattedDateWithFormat:@"yyyy-MM-dd"];
            NSString *endDate = [period.EndDate formattedDateWithFormat:@"yyyy-MM-dd"];
            
            if (![db executeUpdate:@"insert into bk_user_budget (ibid, cuserid, itype, imoney, iremindmoney, csdate, cedate, istate, ccadddate, cbilltype, iremind, ihasremind, cbooksid, islastday, cwritedate, iversion, operatortype) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?, ?, 0)", SSJUUID(), userId, @(itype), imoney, iremindmoney, beginDate, endDate, @1, currentDateStr, cbilltype, @(iremind), booksId, @(isLastDay), currentDateStr, @(SSJSyncVersion())]) {
                *rollback = YES;
                [resultSet close];
                return NO;
            }
        }
    }
    
    [resultSet close];
    
    return YES;
}

+ (NSArray *)periodsWithAccountday:(NSDate *)accountday untilDate:(NSDate *)untilDate type:(int)type isLastDay:(BOOL)isLastDay {
    NSMutableArray *periods = [NSMutableArray array];
    NSDate *beginDate = [accountday dateByAddingDays:1];
    NSDate *endDate = nil;
    
    if (type == 0) {
        endDate = [accountday dateByAddingDays:7];
    } else if (type == 1) {
        if (isLastDay) {
            NSDate *tmpDate = [beginDate dateByAddingMonths:1];
            endDate = [tmpDate dateBySubtractingDays:1];
        } else {
            endDate = [accountday dateByAddingMonths:1];
        }
    } else if (type == 2) {
        if (accountday.month == 2 && isLastDay) {
            NSDate *tmpDate = [beginDate dateByAddingYears:1];
            endDate = [tmpDate dateBySubtractingDays:1];
        } else {
            endDate = [accountday dateByAddingYears:1];
        }
    }

    [periods addObject:[DTTimePeriod timePeriodWithStartDate:beginDate endDate:endDate]];
    
    if ([endDate compare:untilDate] == NSOrderedAscending) {
        [periods addObjectsFromArray:[self periodsWithAccountday:endDate untilDate:untilDate type:type isLastDay:isLastDay]];
    }
    
    return periods;
}

+ (NSArray *)billDatesFromDate:(NSDate *)date periodType:(int)periodType containFromDate:(BOOL)contained {
    //  如果date为空或晚于当前日期，就返回nil
    if (!date || [[NSDate date] compare:date] == NSOrderedAscending) {
        return nil;
    }
    
    NSDate *nowDate = [NSDate date];
    nowDate = [NSDate dateWithYear:nowDate.year month:nowDate.month day:nowDate.day];
    int dayInterval = contained ? 0 : 1;
    
    switch (periodType) {
            // 每天
        case 0: {
            NSInteger daycount = [nowDate daysFrom:date];
//            daycount ++;
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:daycount];
            for (int i = dayInterval; i <= daycount; i ++) {
                [billDates addObject:[date dateByAddingDays:i]];
            }
            return billDates;
            
        }   break;
            
            // 每个工作日
        case 1: {
            NSInteger daycount = [nowDate daysFrom:date];
//            daycount ++;
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:daycount];
            for (int i = dayInterval; i <= daycount; i ++) {
                NSDate *billDate = [date dateByAddingDays:i];
                if (![billDate isWeekend]) {
                    [billDates addObject:billDate];
                }
            }
            return billDates;
            
        }   break;
            
            // 每个周末
        case 2: {
            NSInteger daycount = [nowDate daysFrom:date];
//            daycount ++;
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:daycount];
            for (int i = dayInterval; i <= daycount; i ++) {
                NSDate *billDate = [date dateByAddingDays:i];
                if ([billDate isWeekend]) {
                    [billDates addObject:billDate];
                }
            }
            return billDates;
            
        }   break;
            
            // 每周
        case 3: {
            NSInteger weekCount = [SSJDatePeriod periodCountFromDate:date toDate:nowDate periodType:SSJDatePeriodTypeWeek];
//            weekCount ++;
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:weekCount];
            for (int i = dayInterval; i <= weekCount; i ++) {
                NSDate *newDate = [date dateByAddingWeeks:i];
                if ([newDate compare:nowDate] != NSOrderedDescending) {
                    [billDates addObject:newDate];
                }
            }
            return billDates;
            
        }   break;
            
            // 每月
        case 4: {
            NSInteger monthCount = [SSJDatePeriod periodCountFromDate:date toDate:nowDate periodType:SSJDatePeriodTypeMonth];
//            monthCount ++;
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:monthCount];
            for (int i = dayInterval; i <= monthCount; i ++) {
                NSDate *newDate = [date dateByAddingMonths:i];
                if ([newDate compare:nowDate] != NSOrderedDescending) {
                    [billDates addObject:newDate];
                }
            }
            return billDates;
            
        }   break;
            
            // 每月最后一天
        case 5: {
            NSInteger monthCount = [SSJDatePeriod periodCountFromDate:date toDate:nowDate periodType:SSJDatePeriodTypeMonth];
//            monthCount ++;
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:monthCount];
            for (int i = dayInterval; i <= monthCount; i ++) {
                NSDate *tDate = [date dateByAddingMonths:i];
                NSDate *newDate = [NSDate dateWithYear:[tDate year] month:[tDate month] day:[tDate daysInMonth]];
                if ([newDate compare:nowDate] != NSOrderedDescending) {
                    [billDates addObject:newDate];
                }
            }
            return billDates;
            
        }   break;
            
            // 每年
        case 6: {
            NSInteger yearCount = [SSJDatePeriod periodCountFromDate:date toDate:nowDate periodType:SSJDatePeriodTypeYear];
//            yearCount ++;
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:yearCount];
            for (int i = dayInterval; i <= yearCount; i ++) {
                NSDate *newDate = [date dateByAddingYears:i];
                if ([newDate compare:nowDate] != NSOrderedDescending) {
                    [billDates addObject:newDate];
                }
            }
            return billDates;
            
        }   break;
            
        default:
            return nil;
            break;
    }
}

@end
