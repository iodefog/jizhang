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
#import "SSJDailySumChargeTable.h"
#import "DTTimePeriod.h"

static NSString *const SSJRegularManagerNotificationIdKey = @"SSJRegularManagerNotificationIdKey";
static NSString *const SSJRegularManagerNotificationIdValue = @"SSJRegularManagerNotificationIdValue";

@interface SSJRegularManager ()

@end

@implementation SSJRegularManager

+ (void)registerRegularTaskNotification {
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeNone categories:nil]];
    }
    
    // 获取所有本地通知数组
    for (UILocalNotification *notification in [UIApplication sharedApplication].scheduledLocalNotifications) {
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            // 根据设置通知参数时指定的key来获取通知参数
            NSString *info = userInfo[SSJRegularManagerNotificationIdKey];
            
            // 如果找到需要取消的通知，则取消
            if (([info isEqualToString: SSJRegularManagerNotificationIdValue])) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
            }
        }
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
        [self supplementCycleRecordsForUserId:SSJUSERID() success:NULL failure:NULL];
    }
}

+ (BOOL)supplementCycleRecordsForUserId:(NSString *)userId {
    __block BOOL successfull = NO;
    [[SSJDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        if (![self supplementBookkeepingForUserId:userId inDatabase:db]) {
            *rollback = YES;
            return;
        }
        
        if (![self supplementBudgetForUserId:userId inDatabase:db]) {
            *rollback = YES;
            return;
        }
        
        if (![self supplementCyclicTransferForUserId:userId inDatabase:db]) {
            *rollback = YES;
            return;
        }
        
        successfull = YES;
        
    }];
    return successfull;
}

+ (void)supplementCycleRecordsForUserId:(NSString *)userId success:(nullable void(^)())success failure:(nullable void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        if (![self supplementBookkeepingForUserId:userId inDatabase:db]
            || ![self supplementBudgetForUserId:userId inDatabase:db]
            || ![self supplementCyclicTransferForUserId:userId inDatabase:db]) {
            
            *rollback = YES;
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
    }];
}

+ (BOOL)supplementBookkeepingForUserId:(NSString *)userId inDatabase:(FMDatabase *)db {
    
    if (!userId || !userId.length) {
        SSJPRINT(@">>> SSJ Warning:userid must not be nil or empty");
        return NO;
    }
    
    //  查询当前用户所有有效定期记账最近一次的流水记录
    FMResultSet *resultSet = [db executeQuery:@"select max(a.cbilldate), a.thumburl, a.cbooksid,  b.iconfigid, b.ibillid, b.ifunsid, b.itype, b.imoney, b.cimgurl, b.cmemo, b.cmemberids, b.cbilldateend from bk_user_charge as a, bk_charge_period_config as b where a.cid = b.iconfigid and a.cuserid = ? and b.cuserid = ? and b.istate = 1 and b.operatortype <> 2 and a.cbilldate <= datetime('now', 'localtime') group by b.iconfigid", userId, userId];
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
        
        NSString *endDateStr = [resultSet stringForColumn:@"cbilldateend"];
        NSDate *endDate = [NSDate dateWithString:endDateStr formatString:@"yyyy-MM-dd"];
        
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString *memeberIdStr = [resultSet stringForColumn:@"cmemberids"];
        
        NSArray *memberIds = [memeberIdStr componentsSeparatedByString:@","];
        if (!memeberIdStr.length) {
             memberIds = @[[NSString stringWithFormat:@"%@-0", userId]];
        }
        CGFloat memberMoney = [money doubleValue] / memberIds.count;
        
        [configIdArr addObject:[NSString stringWithFormat:@"'%@'", configId]];
        
        NSString *billDateStr = [resultSet stringForColumn:@"max(a.cbilldate)"];
        NSDate *fromDate = [NSDate dateWithString:billDateStr formatString:@"yyyy-MM-dd"];
        
        NSDate *currentDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day];
        NSDate *toDate = [endDate compare:currentDate] == NSOrderedAscending ? endDate : currentDate;
        
        int periodType = [resultSet intForColumn:@"itype"];
        
        NSArray *billDates = [self billDatesFromDate:fromDate toDate:toDate periodType:periodType containFromDate:NO];
        
        for (NSDate *billDate in billDates) {
            if ([endDate isEarlierThan:billDate]) {
                continue;
            }
            NSString *billDateStr = [billDate formattedDateWithFormat:@"yyyy-MM-dd"];
            NSString *chargeId = SSJUUID();
            
            if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, cid, ichargetype, cbilldate, cmemo, cimgurl, thumburl, cbooksid, iversion, cwritedate, operatortype) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)", chargeId, userId, money, billId, funsid, configId, @(SSJChargeIdTypeCircleConfig), billDateStr, memo, imgUrl, thumbUrl, booksId, @(SSJSyncVersion()), writeDate]) {
                return NO;
            }
            
            // 根据周期记账配置成员生成成员流水
            for (NSString *memberId in memberIds) {
                if (![db executeUpdate:@"insert into bk_member_charge (ichargeid, cmemberid, imoney, iversion, cwritedate, operatortype) values (?, ?, ?, ?, ?, ?)", chargeId, memberId, @(memberMoney), @(SSJSyncVersion()), writeDate, @0]) {
                    return NO;
                }
            }
        }
    }
    
    //  查询没有生成过流水的定期记账
    NSString *tConfigIdStr = [configIdArr componentsJoinedByString:@","];
    NSMutableString *query = [NSMutableString stringWithFormat:@"select iconfigid, ibillid, ifunsid, itype, imoney, cimgurl, cmemo, cbilldate, cbooksid, cmemberids, cbilldateend from bk_charge_period_config where cuserid = '%@' and istate = 1 and operatortype <> 2", userId];
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
        NSString *endDateStr = [resultSet stringForColumn:@"cbilldateend"];
        NSDate *endDate = [NSDate dateWithString:endDateStr formatString:@"yyyy-MM-dd"];

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
        NSDate *fromDate = [NSDate dateWithString:billDateStr formatString:@"yyyy-MM-dd"];
        
        NSDate *currentDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day];
        NSDate *toDate = [endDate compare:currentDate] == NSOrderedAscending ? endDate : currentDate;
        
        NSArray *tmpBillDates = [self billDatesFromDate:fromDate toDate:toDate periodType:periodType containFromDate:YES];
        
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
            if ([endDate isEarlierThan:billDate]) {
                continue;
            }
            NSString *chargeId = SSJUUID();
            
            NSString *billDateStr = [billDate formattedDateWithFormat:@"yyyy-MM-dd"];
            if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, cid, ichargetype, cbilldate, cmemo, cimgurl, thumburl, cbooksid, iversion, cwritedate, operatortype) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", chargeId, userId, money, billId, funsid, configId, @(SSJChargeIdTypeCircleConfig), billDateStr, memo, imgUrl, thumbUrl, booksid, @(SSJSyncVersion()), writeDate, @0]) {
                return NO;
            }
            
            // 根据周期记账配置成员生成成员流水
            for (NSString *memberId in memberIds) {
                if (![db executeUpdate:@"insert into bk_member_charge (ichargeid, cmemberid, imoney, iversion, cwritedate, operatortype) values (?, ?, ?, ?, ?, ?)", chargeId, memberId, @(memberMoney), @(SSJSyncVersion()), writeDate, @0]) {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

+ (BOOL)supplementBudgetForUserId:(NSString *)userId inDatabase:(FMDatabase *)db {
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
                [resultSet close];
                return NO;
            }
        }
    }
    
    [resultSet close];
    
    return YES;
}

+ (BOOL)supplementCyclicTransferForUserId:(NSString *)userId inDatabase:(FMDatabase *)db {
    if (!userId || !userId.length) {
        SSJPRINT(@">>> SSJ Warning:userid must not be nil or empty");
        return NO;
    }
    
    // 查询最大的周期转账流水的cid后缀
    FMResultSet *resultSet = [db executeQuery:@"select max(cast(substr(uc.cid, length(tc.icycleid) + 2) as int)) as suffix, tc.icycleid from bk_user_charge as uc, bk_transfer_cycle as tc where uc.cuserid = ? and tc.cuserid = uc.cuserid and uc.ichargetype = 5 and uc.cid like (tc.icycleid || '-%') and tc.operatortype <> 2 and tc.istate = 1 and tc.icycletype <> -1 group by tc.icycleid", userId];
    if (!resultSet) {
        return NO;
    }
    
    NSMutableDictionary *cidSuffixMapping = [[NSMutableDictionary alloc] init]; // 周期转账id和最大cid后缀的映射
    while ([resultSet next]) {
        NSString *suffix = [resultSet stringForColumn:@"suffix"];
        NSString *cycleId = [resultSet stringForColumn:@"icycleid"];
        if (suffix && cycleId) {
            [cidSuffixMapping setObject:suffix forKey:cycleId];
        }
    }
    [resultSet close];
    
    // 根据最近一次周期转账流水计算出需要补充的流水
    resultSet = [db executeQuery:@"select max(uc.cbilldate), tc.* from bk_user_charge as uc, bk_transfer_cycle as tc where uc.cuserid = ? and uc.cuserid = tc.cuserid and uc.ichargetype = 5 and uc.cid like (tc.icycleid || '-%') and tc.operatortype <> 2 and tc.istate = 1 and tc.icycletype <> -1 and uc.cbilldate <= datetime('now', 'localtime') group by tc.icycleid", userId];
    if (!resultSet) {
        return NO;
    }
    
    NSMutableArray *cycleIds = [[NSMutableArray alloc] init];   // 生成过流水的周期转账id
    NSMutableArray *chargeList = [[NSMutableArray alloc] init]; // 需要创建的流水列表
    
    while ([resultSet next]) {
        
        NSString *cycleId = [resultSet stringForColumn:@"icycleid"];
        [cycleIds addObject:[NSString stringWithFormat:@"'%@'", cycleId]];
        
        int periodType = [resultSet intForColumn:@"icycletype"];
        
        NSString *billDateStr = [resultSet stringForColumn:@"max(uc.cbilldate)"];
        NSDate *billDate = [NSDate dateWithString:billDateStr formatString:@"yyyy-MM-dd"];
        NSDate *beginDate = [NSDate dateWithString:[resultSet stringForColumn:@"cbegindate"] formatString:@"yyyy-MM-dd"];
        NSDate *fromDate = [billDate compare:beginDate] == NSOrderedDescending ? billDate : beginDate;
        
        NSDate *toDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day];
        NSString *endDateStr = [resultSet stringForColumn:@"cenddate"];
        if (endDateStr) {
            NSDate *endDate = [NSDate dateWithString:endDateStr formatString:@"yyyy-MM-dd"];
            toDate = [endDate compare:toDate] == NSOrderedAscending ? endDate : toDate;
        }
        
        NSArray *billDates = [self billDatesFromDate:fromDate toDate:toDate periodType:periodType containFromDate:NO];
        
        [self organiseChargeListWithResultSet:resultSet chargeList:chargeList billDates:billDates userId:userId suffixMapping:cidSuffixMapping];
    }
    [resultSet close];
    
    // 查询没有生成过流水的周期转账，根据起始日期、结束日期及当天日期得出需要补充的流水
    NSMutableString *sql = [[NSMutableString alloc] initWithString:@"select * from bk_transfer_cycle where cuserid = ? and operatortype <> 2 and istate = 1 and icycletype <> -1"];
    if (cycleIds.count) {
        NSString *cycleIdStr = [cycleIds componentsJoinedByString:@","];
        [sql appendFormat:@" and icycleid not in (%@)", cycleIdStr];
    }
    
    resultSet = [db executeQuery:sql, userId];
    if (!resultSet) {
        return NO;
    }
    
    while ([resultSet next]) {
        int periodType = [resultSet intForColumn:@"icycletype"];
        NSDate *fromDate = [NSDate dateWithString:[resultSet stringForColumn:@"cbegindate"] formatString:@"yyyy-MM-dd"];
        
        NSString *endDateStr = [resultSet stringForColumn:@"cenddate"];
        NSDate *toDate = nil;
        if (endDateStr) {
            toDate = [NSDate dateWithString:endDateStr formatString:@"yyyy-MM-dd"];
        }
        
        NSDate *currentDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day];
        toDate = [toDate compare:currentDate] == NSOrderedAscending ? toDate : currentDate;
        
        NSArray *billDates = [self billDatesFromDate:fromDate toDate:toDate periodType:periodType containFromDate:YES];
        
        [self organiseChargeListWithResultSet:resultSet chargeList:chargeList billDates:billDates userId:userId suffixMapping:cidSuffixMapping];
    }
    [resultSet close];
    
    // 插入补充的转账流水
    for (NSDictionary *chargeInfo in chargeList) {
        if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, cid, ichargetype, cbilldate, cmemo, iversion, cwritedate, operatortype) values (:ichargeid, :cuserid, :imoney, :ibillid, :ifunsid, :cid, :ichargetype, :cbilldate, :cmemo, :iversion, :cwritedate, :operatortype)" withParameterDictionary:chargeInfo]) {
            return NO;
        }
    }
    
    return YES;
}

+ (void)organiseChargeListWithResultSet:(FMResultSet *)resultSet chargeList:(NSMutableArray *)chargeList billDates:(NSArray *)billDates userId:(NSString *)userId suffixMapping:(NSDictionary *)mapping {
    
    NSString *cycleId = [resultSet stringForColumn:@"icycleid"];
    NSString *money = [resultSet stringForColumn:@"imoney"];
    NSString *memo = [resultSet stringForColumn:@"cmemo"];
    NSString *transferInId = [resultSet stringForColumn:@"ctransferinaccountid"];
    NSString *transferOutId = [resultSet stringForColumn:@"ctransferoutaccountid"];
    int cidSuffix = [mapping[cycleId] intValue];
    
    for (NSDate *date in billDates) {
        NSString *billDate = [date formattedDateWithFormat:@"yyyy-MM-dd"];
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString *cid = [NSString stringWithFormat:@"%@-%d", cycleId, ++cidSuffix];
        
        NSDictionary *transferInChargeInfo = @{@"ichargeid":SSJUUID(),
                                               @"cuserid":userId,
                                               @"imoney":money,
                                               @"ibillid":@3,
                                               @"ifunsid":transferInId,
                                               @"cid":cid,
                                               @"ichargetype":@5,
                                               @"cbilldate":billDate,
                                               @"cmemo":memo ?: @"",
                                               @"iversion": @(SSJSyncVersion()),
                                               @"cwritedate":writeDate,
                                               @"operatortype":@0};
        
        NSDictionary *transferOutChargeInfo = @{@"ichargeid":SSJUUID(),
                                                @"cuserid":userId,
                                                @"imoney":money,
                                                @"ibillid":@4,
                                                @"ifunsid":transferOutId,
                                                @"cid":cid,
                                                @"ichargetype":@5,
                                                @"cbilldate":billDate,
                                                @"cmemo":memo ?: @"",
                                                @"iversion": @(SSJSyncVersion()),
                                                @"cwritedate":writeDate,
                                                @"operatortype":@0};
        
        [chargeList addObject:transferInChargeInfo];
        [chargeList addObject:transferOutChargeInfo];
    }
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

+ (NSArray<NSDate *> *)billDatesFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate periodType:(SSJCyclePeriodType)periodType containFromDate:(BOOL)contained {
    //  如果date为空或晚于当前日期，就返回nil
    if (!fromDate || !toDate || [fromDate compare:toDate] == NSOrderedDescending) {
        return nil;
    }
    
    int dayInterval = contained ? 0 : 1;
    
    switch (periodType) {
        case SSJCyclePeriodTypeOnce:
            return nil;
            break;
            
            // 每天
        case SSJCyclePeriodTypeDaily: {
            NSInteger daycount = [toDate daysFrom:fromDate];
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:daycount];
            for (int i = dayInterval; i <= daycount; i ++) {
                [billDates addObject:[fromDate dateByAddingDays:i]];
            }
            return billDates;
            
        }   break;
            
            // 每个工作日
        case SSJCyclePeriodTypeWorkday: {
            NSInteger daycount = [toDate daysFrom:fromDate];
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:daycount];
            for (int i = dayInterval; i <= daycount; i ++) {
                NSDate *billDate = [fromDate dateByAddingDays:i];
                if (![billDate isWeekend]) {
                    [billDates addObject:billDate];
                }
            }
            return billDates;
            
        }   break;
            
            // 每个周末
        case SSJCyclePeriodTypePerWeekend: {
            NSInteger daycount = [toDate daysFrom:fromDate];
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:daycount];
            for (int i = dayInterval; i <= daycount; i ++) {
                NSDate *billDate = [fromDate dateByAddingDays:i];
                if ([billDate isWeekend]) {
                    [billDates addObject:billDate];
                }
            }
            return billDates;
            
        }   break;
            
            // 每周
        case SSJCyclePeriodTypeWeekly: {
            NSInteger weekCount = [SSJDatePeriod periodCountFromDate:fromDate toDate:toDate periodType:SSJDatePeriodTypeWeek];
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:weekCount];
            for (int i = dayInterval; i <= weekCount; i ++) {
                NSDate *newDate = [fromDate dateByAddingWeeks:i];
                if ([newDate compare:toDate] != NSOrderedDescending) {
                    [billDates addObject:newDate];
                }
            }
            return billDates;
            
        }   break;
            
            // 每月
        case SSJCyclePeriodTypePerMonth: {
            NSInteger monthCount = [SSJDatePeriod periodCountFromDate:fromDate toDate:toDate periodType:SSJDatePeriodTypeMonth];
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:monthCount];
            for (int i = dayInterval; i <= monthCount; i ++) {
                NSDate *newDate = [fromDate dateByAddingMonths:i];
                if (newDate.day == fromDate.day && [newDate compare:toDate] != NSOrderedDescending) {
                    [billDates addObject:newDate];
                }
            }
            return billDates;
            
        }   break;
            
            // 每月最后一天
        case SSJCyclePeriodTypeLastDayPerMonth: {
            NSInteger monthCount = [SSJDatePeriod periodCountFromDate:fromDate toDate:toDate periodType:SSJDatePeriodTypeMonth];
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:monthCount];
            for (int i = dayInterval; i <= monthCount; i ++) {
                NSDate *tDate = [fromDate dateByAddingMonths:i];
                NSDate *newDate = [NSDate dateWithYear:[tDate year] month:[tDate month] day:[tDate daysInMonth]];
                if ([newDate compare:toDate] != NSOrderedDescending) {
                    [billDates addObject:newDate];
                }
            }
            return billDates;
            
        }   break;
            
            // 每年
        case SSJCyclePeriodTypePerYear: {
            NSInteger yearCount = [SSJDatePeriod periodCountFromDate:fromDate toDate:toDate periodType:SSJDatePeriodTypeYear];
            NSMutableArray *billDates = [NSMutableArray arrayWithCapacity:yearCount];
            for (int i = dayInterval; i <= yearCount; i ++) {
                NSDate *newDate = [fromDate dateByAddingYears:i];
                if ([newDate compare:toDate] != NSOrderedDescending) {
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
