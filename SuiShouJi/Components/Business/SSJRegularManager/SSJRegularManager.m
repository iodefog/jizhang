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

static NSString *const SSJRegularManagerNotificationIdKey = @"SSJRegularManagerNotificationIdKey";
static NSString *const SSJRegularManagerNotificationIdValue = @"SSJRegularManagerNotificationIdValue";

@interface SSJRegularManager ()

@end

@implementation SSJRegularManager

+ (void)registerRegularTaskNotification {
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeNone categories:nil]];
    }
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    NSDate *date = [NSDate date];
    notification.fireDate = [NSDate dateWithYear:[date year] month:[date month] day:[date day]];
    notification.repeatInterval = NSCalendarUnitDay;
    notification.repeatCalendar = [NSCalendar currentCalendar];
    notification.userInfo = @{SSJRegularManagerNotificationIdKey:SSJRegularManagerNotificationIdValue};
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

+ (void)performRegularTaskWithLocalNotification:(UILocalNotification *)notification {
    NSString *notificationId = notification.userInfo[SSJRegularManagerNotificationIdKey];
    if ([notificationId isEqualToString:SSJRegularManagerNotificationIdValue]) {
        [self supplementBookkeepingIfNeededWithSuccess:NULL failure:NULL];
        [self supplementBudgetIfNeededWithSuccess:NULL failure:NULL];
    }
}

+ (BOOL)supplementBookkeepingIfNeeded {
    __block BOOL successfull = YES;
    [[SSJDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        successfull = [self supplementBookkeepingForUserId:SSJUSERID() inDatabase:db rollback:rollback];
    }];
    return successfull;
}

+ (BOOL)supplementBudgetIfNeeded {
    __block BOOL successfull = YES;
    [[SSJDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        successfull = [self supplementBudgetForUserId:SSJUSERID() inDatabase:db rollback:rollback];
    }];
    return successfull;
    
}

+ (void)supplementBookkeepingIfNeededWithSuccess:(void(^)())success
                                         failure:(void (^)(NSError *error))failure {
    NSString *userid = SSJUSERID();
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([self supplementBookkeepingForUserId:userid inDatabase:db rollback:rollback]) {
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

+ (void)supplementBudgetIfNeededWithSuccess:(void(^)())success
                                    failure:(void (^)(NSError *error))failure {
    NSString *userId = SSJUSERID();
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
    
    //  查询当前用户所有定期记账最近一次的billdate
    FMResultSet *resultSet = [db executeQuery:@"select max(a.cbilldate), b.iconfigid, b.ibillid, b.ifunsid, b.itype, b.imoney, b.cimgurl, b.cmemo from bk_user_charge as a, bk_charge_period_config as b where a.iconfigid = b.iconfigid and a.cuserid = ? and b.cuserid = ? and b.istate = 1 and b.operatortype <> 2 group by b.iconfigid", userId, userId];
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
        
        [configIdArr addObject:configId];
        
        int periodType = [resultSet intForColumn:@"itype"];
        NSDate *billDate = [resultSet dateForColumn:@"max(a.cbilldate)"];
        NSArray *billDates = [self billDatesFromDate:billDate periodType:periodType];
        
        for (NSString *billDate in billDates) {
            if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, iconfigid, cbilldate, cmemo, cimgurl, iversion, cwritedate, operatortype) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", SSJUUID(), userId, money, billId, funsid, configId, billDate, memo, imgUrl, @(SSJSyncVersion()), writeDate, @0]) {
                *rollback = YES;
                return NO;
            }
        }
    }
    
    //  查询没有生成过流水的定期记账
    resultSet = [db executeQuery:@"select iconfigid, ibillid, ifunsid, itype, imoney, cimgurl, cmemo, cbilldate from bk_charge_period_config where cuserid = ? and istate = 1 and operatortype <> 2 and iconfigid not in (?)", [configIdArr componentsJoinedByString:@","]];
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
        
        int periodType = [resultSet intForColumn:@"itype"];
        NSDate *billDate = [resultSet dateForColumn:@"cbilldate"];
        NSArray *billDates = [self billDatesFromDate:billDate periodType:periodType];
        
        for (NSString *billDate in billDates) {
            if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, iconfigid, cbilldate, cmemo, cimgurl, iversion, cwritedate, operatortype) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", SSJUUID(), userId, money, billId, funsid, configId, billDate, memo, imgUrl, @(SSJSyncVersion()), writeDate, @0]) {
                *rollback = YES;
                return NO;
            }
        }
    }
    
    return YES;
}

+ (BOOL)supplementBudgetForUserId:(NSString *)userId inDatabase:(FMDatabase *)db rollback:(BOOL *)rollback {
    FMResultSet *resultSet = [db executeQuery:@"select itype, imoney, iremindmoney, cbilltype, iremind, max(cedate) from bk_user_budget where cuserid = ? and operatortype <> 2 and istate = 1 group by itype, cbilltype", userId];
    if (!resultSet) {
        return NO;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    while ([resultSet next]) {
        NSDate *recentEndDate = [formatter dateFromString:[resultSet stringForColumn:@"max(cedate)"]];
        
        if ([recentEndDate compare:[NSDate date]] == NSOrderedAscending) {
            
            int itype = [resultSet intForColumn:@"itype"];
            NSString *imoney = [resultSet stringForColumn:@"imoney"];
            NSString *iremindmoney = [resultSet stringForColumn:@"iremindmoney"];
            NSString *cbilltype = [resultSet stringForColumn:@"cbilltype"];
            int iremind = [resultSet intForColumn:@"iremind"];
            NSString *currentDate = [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            
            NSArray *periodArr = [self periodArrayForType:[self periodTypeForItype:itype] sinceDate:recentEndDate];
            
            for (SSJDatePeriod *period in periodArr) {
                NSString *beginDate = [period.startDate ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"];
                NSString *endDate = [period.endDate ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"];
                
                if (![db executeUpdate:@"insert into bk_user_budget (ibid, cuserid, itype, imoney, iremindmoney, csdate, cedate, istate, ccadddate, cbilltype, iremind, cwritedate, iversion, operatortype) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)", SSJUUID(), userId, @(itype), imoney, iremindmoney, beginDate, endDate, @1, currentDate, cbilltype, @(iremind), currentDate, @(SSJSyncVersion())]) {
                    *rollback = YES;
                    return NO;
                }
            }
        }
    }
    
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
            return SSJDatePeriodTypeWeek;
    }
}

+ (NSArray *)periodArrayForType:(SSJDatePeriodType)type sinceDate:(NSDate *)date {
    NSMutableArray *periodArr = [NSMutableArray array];
    
    NSDate *tDate = [NSDate dateWithTimeInterval:(24 * 60 * 60) sinceDate:date];
    SSJDatePeriod *period = [SSJDatePeriod datePeriodWithPeriodType:type date:tDate];
    
    if ([period.endDate compare:[NSDate date]] == NSOrderedAscending) {
        NSArray *anotherPeriod = [self periodArrayForType:type sinceDate:period.endDate];
        [periodArr addObjectsFromArray:anotherPeriod];
    }
    
    [periodArr addObject:period];
    
    return periodArr;
}

+ (NSArray *)billDatesFromDate:(NSDate *)date periodType:(int)periodType {
    
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
            NSInteger weekCount = [[NSDate date] weeksFrom:date];
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:weekCount];
            for (int i = 1; i <= weekCount; i ++) {
                [billDates addObject:[date dateByAddingWeeks:i]];
            }
            return billDates;
            
        }   break;
            
            // 每月
        case 4: {
            NSInteger monthCount = [[NSDate date] monthsFrom:date];
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:monthCount];
            for (int i = 1; i <= monthCount; i ++) {
                [billDates addObject:[date dateByAddingMonths:i]];
            }
            return billDates;
            
        }   break;
            
            // 每年
        case 5: {
            NSInteger yearCount = [[NSDate date] yearsFrom:date];
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:yearCount];
            for (int i = 1; i <= yearCount; i ++) {
                [billDates addObject:[date dateByAddingYears:i]];
            }
            return billDates;
            
        }   break;
            
            // 每月最后一天
        case 6: {
            NSInteger monthCount = [[NSDate date] monthsFrom:date];
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
