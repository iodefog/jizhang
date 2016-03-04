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

+ (void)registerRegularTask {
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

+ (void)supplementBookkeepingIfNeededWithSuccess:(void(^)())success
                                         failure:(void (^)(NSError *error))failure {
    
}

+ (void)supplementBudgetIfNeededWithSuccess:(void(^)())success
                                    failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select itype, imoney, iremindmoney, cbilltype, iremind, max(cedate) from bk_user_budget where cuserid = ? and operatortype <> 2 and istate = 1 group by itype, cbilltype", SSJUSERID()];
        if (!resultSet) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        BOOL successfull = YES;
        
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
                
                NSArray *periodArr = [self periodArrayForType:itype sinceDate:recentEndDate];
                
                for (SSJDatePeriod *period in periodArr) {
                    NSString *beginDate = [period.startDate ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"];
                    NSString *endDate = [period.endDate ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"];
                    
                    successfull = [db executeUpdate:@"insert into bk_user_budget (ibid, cuserid, itype, imoney, iremindmoney, csdate, cedate, istate, ccadddate, cbilltype, iremind, cwritedate, iversion, operatortype) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)", SSJUUID(), SSJUSERID(), @(itype), imoney, iremindmoney, beginDate, endDate, @1, currentDate, cbilltype, @(iremind), currentDate, @(SSJSyncVersion())];
                }
            }
        }
        
        if (successfull) {
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

+ (NSArray *)periodArrayForType:(int)type sinceDate:(NSDate *)date {
    SSJDatePeriodType periodType = SSJDatePeriodTypeWeek;
    switch (type) {
        case 0:
            periodType = SSJDatePeriodTypeWeek;
            break;
        case 1:
            periodType = SSJDatePeriodTypeMonth;
            break;
        case 2:
            periodType = SSJDatePeriodTypeYear;
            break;
    }
    
    NSMutableArray *periodArr = [NSMutableArray array];
    
    NSDate *tDate = [NSDate dateWithTimeInterval:(24 * 60 * 60) sinceDate:date];
    SSJDatePeriod *period = [SSJDatePeriod datePeriodWithPeriodType:periodType date:tDate];
    
    if ([period.endDate compare:[NSDate date]] == NSOrderedAscending) {
        NSArray *anotherPeriod = [self periodArrayForType:type sinceDate:period.endDate];
        [periodArr addObjectsFromArray:anotherPeriod];
    }
    
    [periodArr addObject:period];
    
    return periodArr;
}

@end
