//
//  SSJUserBudgetSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/3/2.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserBudgetSyncTable.h"

@implementation SSJUserBudgetSyncTable

+ (NSString *)tableName {
    return @"bk_user_budget";
}

+ (NSSet *)columns {
    return [NSSet setWithObjects:
            @"ibid",
            @"cuserid",
            @"itype",
            @"imoney",
            @"iremindmoney",
            @"csdate",
            @"cedate",
            @"istate",
            @"ccadddate",
            @"cbilltype",
            @"iremind",
            @"ihasremind",
            @"cbooksid",
            @"islastday",
            @"iversion",
            @"cwritedate",
            @"operatortype",
            nil];
}

+ (NSSet *)primaryKeys {
    return [NSSet setWithObject:@"ibid"];
}

- (BOOL)shouldMergeRecord:(NSDictionary *)record forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    NSDate *startDate = [NSDate dateWithString:record[@"csdate"] formatString:@"yyyy-MM-dd"];
    NSDate *endDate = [NSDate dateWithString:record[@"cedate"] formatString:@"yyyy-MM-dd"];
    NSDate *tmpDate = [NSDate date];
    NSDate *today = [NSDate dateWithYear:tmpDate.year month:tmpDate.month day:tmpDate.day];
    
    // 不能合并未来预算
    if ([startDate compare:today] == NSOrderedDescending) {
        return NO;
    }
    
    // 可以合并历史预算
    if ([endDate compare:today] == NSOrderedAscending) {
        return YES;
    }
    
    // 查询本地是否有相同预算类别、账本类型，并且当前有效的记录记录，有的话保留修改时间较晚的
    NSString *todayStr = [today formattedDateWithFormat:@"yyyy-MM-dd"];
    FMResultSet *resultSet = [db executeQuery:@"select ibid, cwritedate, operatortype from bk_user_budget where cuserid = ? and csdate <= ? and cedate >= ? and itype = ? and cbooksid = ? and cbilltype = ? and ibid <> ? and operatortype <> 2", userId, todayStr, todayStr, record[@"itype"], record[@"cbooksid"], record[@"cbilltype"], record[@"ibid"]];
    
    if (!resultSet) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }
    
    NSDate *mergeDate = [NSDate dateWithString:record[@"cwritedate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
    while ([resultSet next]) {
        
        //  如果将要合并的流水的没有删除，就保留修改时间最近的一条
        if ([record[@"operatortype"] intValue] != 2) {
            
            //  本地记录修改时间较晚，保留本地记录，忽略合并记录
            NSString *localDateStr = [resultSet stringForColumn:@"cwritedate"];
            NSDate *localDate = [NSDate dateWithString:localDateStr formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
            
            if ([mergeDate compare:localDate] == NSOrderedAscending) {
                [resultSet close];
                return NO;
            }
            
            //  合并记录修改时间较晚，删除本地记录，合并此记录；如果本地记录删除失败，就忽略服务器返回的记录
            if (![db executeUpdate:@"update bk_user_budget set operatortype = 2 where ibid = ?", [resultSet stringForColumn:@"ibid"]]) {
                if (error) {
                    *error = [db lastError];
                }
                [resultSet close];
                return NO;
            }
        }
    }
    
    [resultSet close];
    
    return YES;
}

@end
