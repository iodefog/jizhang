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

static NSString *const SSJRegularManagerNotificationIdKey = @"SSJRegularManagerNotificationIdKey";
static NSString *const SSJRegularManagerNotificationIdValue = @"SSJRegularManagerNotificationIdValue";

@interface SSJRegularManager ()

@end

@implementation SSJRegularManager

+ (void)load {
    [self registerRegularTaskNotification];
}

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
    
    //  查询当前用户所有定期记账最近一次的billdate
    FMResultSet *resultSet = [db executeQuery:@"select max(a.cbilldate), b.iconfigid, b.ibillid, b.ifunsid, b.itype, b.imoney, b.cimgurl, b.cmemo from bk_user_charge as a, bk_charge_period_config as b where a.iconfigid = b.iconfigid and a.cuserid = ? and b.cuserid = ? and b.istate = 1 and b.operatortype <> 2 and a.operatortype <> 2 group by b.iconfigid", userId, userId];
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
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString *thumbUrl = nil;
        if (imgUrl && imgUrl.length > 0) {
            NSString *imgExtension = [imgUrl pathExtension];
            NSString *imgName = [NSString stringWithFormat:@"%@-thumb", [imgUrl stringByDeletingPathExtension]];
            thumbUrl = [imgName stringByAppendingPathComponent:imgExtension];
        }
        
        [configIdArr addObject:[NSString stringWithFormat:@"'%@'", configId]];
        
        int periodType = [resultSet intForColumn:@"itype"];
        NSString *billDateStr = [resultSet stringForColumn:@"max(a.cbilldate)"];
        NSDate *billDate = [NSDate dateWithString:billDateStr formatString:@"yyyy-MM-dd"];
        NSArray *billDates = [self billDatesFromDate:billDate periodType:periodType];
        
        for (NSDate *billDate in billDates) {
            NSString *billDateStr = [billDate formattedDateWithFormat:@"yyyy-MM-dd"];
            if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, iconfigid, cbilldate, cmemo, cimgurl, thumburl, iversion, cwritedate, operatortype) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)", SSJUUID(), userId, money, billId, funsid, configId, billDateStr, memo, imgUrl, thumbUrl, @(SSJSyncVersion()), writeDate]) {
                *rollback = YES;
                return NO;
            }
        }
    }
    
    //  查询没有生成过流水的定期记账
    NSString *tConfigIdStr = [configIdArr componentsJoinedByString:@","];
    NSMutableString *query = [NSMutableString stringWithFormat:@"select iconfigid, ibillid, ifunsid, itype, imoney, cimgurl, cmemo, cbilldate from bk_charge_period_config where cuserid = '%@' and istate = 1 and operatortype <> 2", userId];
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
            thumbUrl = [imgName stringByAppendingPathComponent:imgExtension];
        }
        
        int periodType = [resultSet intForColumn:@"itype"];
        NSString *billDateStr = [resultSet stringForColumn:@"cbilldate"];
        NSDate *billDate = [NSDate dateWithString:billDateStr formatString:@"yyyy-MM-dd"];
        NSArray *billDates = [self billDatesFromDate:billDate periodType:periodType];
        
        for (NSDate *billDate in billDates) {
            NSString *billDateStr = [billDate formattedDateWithFormat:@"yyyy-MM-dd"];
            if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, iconfigid, cbilldate, cmemo, cimgurl, thumburl, iversion, cwritedate, operatortype) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", SSJUUID(), userId, money, billId, funsid, configId, billDateStr, memo, imgUrl, thumbUrl, @(SSJSyncVersion()), writeDate, @0]) {
                *rollback = YES;
                return NO;
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
    FMResultSet *resultSet = [db executeQuery:@"select itype, imoney, iremindmoney, cbilltype, iremind, max(cedate) from bk_user_budget where cuserid = ? and operatortype <> 2 and istate = 1 group by itype, cbilltype", userId];
    if (!resultSet) {
        [resultSet close];
        return NO;
    }
    
    while ([resultSet next]) {
        NSDate *tDate = [NSDate date];
        NSDate *currentDate = [NSDate dateWithYear:[tDate year] month:[tDate month] day:[tDate day]];
        NSDate *recentEndDate = [NSDate dateWithString:[resultSet stringForColumn:@"max(cedate)"] formatString:@"yyyy-MM-dd"];
        
        //  如果最近的一次预算时间晚于或等于当前时间，就忽略
        if ([recentEndDate compare:currentDate] != NSOrderedAscending) {
            continue;
        }
        
        int itype = [resultSet intForColumn:@"itype"];
        NSString *imoney = [resultSet stringForColumn:@"imoney"];
        NSString *iremindmoney = [resultSet stringForColumn:@"iremindmoney"];
        NSString *cbilltype = [resultSet stringForColumn:@"cbilltype"];
        int iremind = [resultSet intForColumn:@"iremind"];
        NSString *currentDateStr = [tDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        NSArray *periodArr = [SSJDatePeriod periodsBetweenDate:recentEndDate andAnotherDate:currentDate periodType:[self periodTypeForItype:itype]];
        for (SSJDatePeriod *period in periodArr) {
            NSString *beginDate = [period.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
            NSString *endDate = [period.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
            
            if (![db executeUpdate:@"insert into bk_user_budget (ibid, cuserid, itype, imoney, iremindmoney, csdate, cedate, istate, ccadddate, cbilltype, iremind, ihasremind, cwritedate, iversion, operatortype) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?, 0)", SSJUUID(), userId, @(itype), imoney, iremindmoney, beginDate, endDate, @1, currentDateStr, cbilltype, @(iremind), currentDateStr, @(SSJSyncVersion())]) {
                *rollback = YES;
                [resultSet close];
                return NO;
            }
        }
    }
    
    [resultSet close];
    
    return YES;
}

+ (SSJDatePeriodType)periodTypeForItype:(int)itype {
    switch (itype) {
        case 0:
            return SSJDatePeriodTypeWeek;
            break;
        case 1:
            return SSJDatePeriodTypeMonth;
            break;
        case 2:
            return SSJDatePeriodTypeYear;
            break;
            
        default:
            return SSJDatePeriodTypeUnknown;
    }
}

+ (NSArray *)billDatesFromDate:(NSDate *)date periodType:(int)periodType {
    //  如果date为空或晚于当前日期，就返回nil
    if (!date || [[NSDate date] compare:date] == NSOrderedAscending) {
        return nil;
    }
    
    switch (periodType) {
            // 每天
        case 0: {
            NSInteger daycount = [[NSDate date] daysFrom:date];
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:daycount];
            for (int i = 1; i <= daycount; i ++) {
                [billDates addObject:[date dateByAddingDays:i]];
            }
            return billDates;
            
        }   break;
            
            // 每个工作日
        case 1: {
            NSInteger daycount = [[NSDate date] daysFrom:date];
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:daycount];
            for (int i = 1; i <= daycount; i ++) {
                NSDate *billDate = [date dateByAddingDays:i];
                if (![billDate isWeekend]) {
                    [billDates addObject:billDate];
                }
            }
            return billDates;
            
        }   break;
            
            // 每个周末
        case 2: {
            NSInteger daycount = [[NSDate date] daysFrom:date];
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:daycount];
            for (int i = 1; i <= daycount; i ++) {
                NSDate *billDate = [date dateByAddingDays:i];
                if ([billDate isWeekend]) {
                    [billDates addObject:billDate];
                }
            }
            return billDates;
            
        }   break;
            
            // 每周
        case 3: {
            NSInteger weekCount = [SSJDatePeriod periodCountFromDate:date toDate:[NSDate date] periodType:SSJDatePeriodTypeWeek];
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:weekCount];
            for (int i = 1; i <= weekCount; i ++) {
                [billDates addObject:[date dateByAddingWeeks:i]];
            }
            return billDates;
            
        }   break;
            
            // 每月
        case 4: {
            NSInteger monthCount = [SSJDatePeriod periodCountFromDate:date toDate:[NSDate date] periodType:SSJDatePeriodTypeMonth];
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:monthCount];
            for (int i = 1; i <= monthCount; i ++) {
                [billDates addObject:[date dateByAddingMonths:i]];
            }
            return billDates;
            
        }   break;
            
            // 每年
        case 5: {
            NSInteger yearCount = [SSJDatePeriod periodCountFromDate:date toDate:[NSDate date] periodType:SSJDatePeriodTypeYear];
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:yearCount];
            for (int i = 1; i <= yearCount; i ++) {
                [billDates addObject:[date dateByAddingYears:i]];
            }
            return billDates;
            
        }   break;
            
            // 每月最后一天
        case 6: {
            NSInteger monthCount = [SSJDatePeriod periodCountFromDate:date toDate:[NSDate date] periodType:SSJDatePeriodTypeMonth];
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:monthCount];
            for (int i = 1; i <= monthCount; i ++) {
                NSDate *tDate = [date dateByAddingMonths:i];
                NSDate *billDate = [NSDate dateWithYear:[tDate year] month:[tDate month] day:[tDate daysInMonth]];
                [billDates addObject:billDate];
            }
            return billDates;
            
        }   break;
            
        default:
            return nil;
            break;
    }
}

@end
