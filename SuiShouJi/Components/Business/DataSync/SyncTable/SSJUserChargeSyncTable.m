//
//  SSJUserChargeSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserChargeSyncTable.h"

@implementation SSJUserChargeSyncTable

+ (NSString *)tableName {
    return @"bk_user_charge";
}

+ (NSArray *)columns {
    return @[@"ichargeid", @"imoney", @"ibillid", @"ifunsid", @"cadddate", @"ioldmoney", @"ibalance", @"cbilldate", @"cuserid", @"cwritedate", @"iversion", @"operatortype"];
}

+ (NSArray *)primaryKeys {
    return @[@"ichargeid"];
}

+ (BOOL)shouldMergeRecord:(NSDictionary *)record inDatabase:(FMDatabase *)db {
    NSString *userId = record[@"cuserid"];
    NSString *billId = record[@"ibillid"];
    NSString *fundId = record[@"ifunsid"];
    if (!userId || !billId || !fundId) {
        SSJPRINT(@">>> SSJ warning:cuserid and ibillid in record must not be nil \n record:%@", record);
        return NO;
    }
    
    //  如果此流水不依赖于特殊收支类型（istate等于2），还要从user_bill表中查询是否有此类型
    BOOL hasBillType = [db intForQuery:@"select istate from bk_bill_type where id = ?", billId] == 2;
    if (!hasBillType) {
        hasBillType = [db boolForQuery:@"select count(*) from BK_USER_BILL where CUSERID = ? and CBILLID = ?", userId, billId];
    }
    
    //  查询fund_info中是否有对应的资金帐户
    BOOL hasFundAccount = [db boolForQuery:@"select count(*) from BK_FUND_INFO where CUSERID = ? and CFUNDID = ?", userId, fundId];
    
    return (hasBillType && hasFundAccount);
}

@end
