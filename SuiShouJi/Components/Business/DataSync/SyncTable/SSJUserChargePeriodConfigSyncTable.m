//
//  SSJUserChargePeriodConfigSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/3/2.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserChargePeriodConfigSyncTable.h"

@implementation SSJUserChargePeriodConfigSyncTable

+ (NSString *)tableName {
    return @"bk_charge_period_config";
}

+ (NSArray *)columns {
    return @[@"iconfigid",
             @"cuserid",
             @"ibillid",
             @"ifunsid",
             @"itype",
             @"imoney",
             @"cimgurl",
             @"cmemo",
             @"cbilldate",
             @"istate",
             @"cbooksid",
             @"cmemberids",
             @"iversion",
             @"cwritedate",
             @"operatortype",
             @"cbilldateend"];
}

+ (NSArray *)primaryKeys {
    return @[@"iconfigid"];
}

+ (BOOL)subjectToDeletion {
    return NO;
}

+ (BOOL)shouldMergeRecord:(NSDictionary *)record forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError *__autoreleasing *)error {
    NSString *billId = record[@"ibillid"];
    NSString *fundId = record[@"ifunsid"];
    NSString *booksId = record[@"cbooksid"];
    
    if (!billId || !fundId || !booksId) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"收支类别id／资金账户id／账本id不能为nil"}];
        }
        return NO;
    }
    
    // 从user_bill表中查询是否有此类型
    BOOL hasBillType = [db boolForQuery:@"select count(*) from bk_user_bill_type where cuserid = ? and cbillid = ? and cbooksid = ?", userId, billId, booksId];
    // 查询fund_info中是否有对应的资金账户
    BOOL hasFundAccount = [db boolForQuery:@"select count(*) from bk_fund_info where cuserid = ? and cfundid = ?", userId, fundId];
    
    return (hasBillType && hasFundAccount);
}

@end
