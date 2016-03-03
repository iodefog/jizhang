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
    return @[@"ibid", @"cuserid", @"itype", @"imoney", @"iremindmoney", @"csdate", @"cedate", @"istate", @"ccadddate", @"cbilltype", @"iremind", @"iversion", @"cwritedate", @"operatortype"];
}

+ (NSArray *)primaryKeys {
    return @[@"ibid"];
}

+ (BOOL)shouldMergeRecord:(NSDictionary *)record inDatabase:(FMDatabase *)db error:(NSError **)error {
    FMResultSet *resultSet = [db executeQuery:@"select a.cbillid from bk_user_bill as a, bk_bill_type as b where a.cbillid = b.id and a.cuserid = ? and a.operatortype <> 2 and b.itype = 1 and b.istate <> 2 order by a.cbillid asc", SSJUSERID()];
    if (!resultSet) {
        *error = [db lastError];
        return NO;
    }
    
    NSMutableArray *userBillTypeIdArr = [NSMutableArray array];
    while ([resultSet next]) {
        NSString *billTypeID = [resultSet stringForColumn:@"a.cbillid"];
        if (billTypeID) {
            [userBillTypeIdArr addObject:billTypeID];
        }
    }
    
    NSArray *mergeBillTypeIdArr = [record[@"cbilltype"] componentsSeparatedByString:@","];
    for (NSString *billTypeId in mergeBillTypeIdArr) {
        if (![userBillTypeIdArr containsObject:billTypeId]) {
            return NO;
        }
    }
    return YES;
}

@end
