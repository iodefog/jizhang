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

+ (NSArray *)columns {
    return @[@"ibid", @"cuserid", @"itype", @"imoney", @"iremindmoney", @"csdate", @"cedate", @"istate", @"ccadddate", @"cbilltype", @"iremind", @"ihasremind", @"iversion", @"cwritedate", @"operatortype"];
}

+ (NSArray *)primaryKeys {
    return @[@"ibid"];
}

+ (BOOL)shouldMergeRecord:(NSDictionary *)record forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    //  查询当前用户的普通支出类型
    FMResultSet *resultSet = [db executeQuery:@"select a.cbillid from bk_user_bill as a, bk_bill_type as b where a.cbillid = b.id and a.cuserid = ? and a.operatortype <> 2 and b.itype = 1 and b.istate <> 2 order by a.cbillid asc", userId];
    if (!resultSet) {
        *error = [db lastError];
        return NO;
    }
    
    //  将用户支出类型添加到数组
    NSMutableArray *userBillTypeIdArr = [NSMutableArray array];
    while ([resultSet next]) {
        NSString *billTypeID = [resultSet stringForColumn:@"cbillid"];
        if (billTypeID) {
            [userBillTypeIdArr addObject:billTypeID];
        }
    }
    
    [resultSet close];
    
    //  如果将要合并的预算中包涵不属于用户的支出类型，忽略此条记录
    NSArray *mergeBillTypeIdArr = [record[@"cbilltype"] componentsSeparatedByString:@","];
    for (NSString *billTypeId in mergeBillTypeIdArr) {
        if (![userBillTypeIdArr containsObject:billTypeId]) {
            return NO;
        }
    }
    
    //  查询本地是否有预算类别、周期、支出类型都相同的其它记录，有的话保留修改时间较晚的
    resultSet = [db executeQuery:@"select ibid, cwritedate, operatortype from bk_user_budget where cuserid = ? and csdate = ? and cedate = ? and itype = ? and cbilltype = ? and ibid <> ?", userId, record[@"csdate"], record[@"cedate"], record[@"itype"], record[@"cbilltype"], record[@"ibid"]];
    if (!resultSet) {
        *error = [db lastError];
        return NO;
    }
    
    NSDate *mergeDate = [NSDate dateWithString:record[@"cwritedate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
    while ([resultSet next]) {
        //  如果本地流水已经删除，则忽略将要合并的流水
        if ([resultSet intForColumn:@"operatortype"] == 2) {
            [resultSet close];
            return NO;
        }
        
        //  如果将要合并的流水的operatortype是2，就将本地流水的operatortype改为2，并且忽略这条记录
        if ([record[@"operatortype"] intValue] == 2) {
            [db executeUpdate:@"update bk_user_budget set operatortype = 2 where ibid = ?", [resultSet stringForColumn:@"ibid"]];
            [resultSet close];
            return NO;
        }
        
        NSDate *localDate = [resultSet dateForColumn:@"cwritedate"];
        
        //  本地记录修改时间较晚，保留本地记录，忽略合并记录
        if ([mergeDate compare:localDate] == NSOrderedAscending) {
            [resultSet close];
            return NO;
        }
        
        //  合并记录修改时间较晚，删除本地记录，合并此记录
        if (![db executeUpdate:@"update bk_user_budget set operatortype = 2 where ibid = ?", [resultSet stringForColumn:@"ibid"]]) {
            *error = [db lastError];
            [resultSet close];
            return NO;
        }
    }
    
    [resultSet close];
    
    return YES;
}

@end
