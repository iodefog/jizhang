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
    return @[@"iconfigid", @"cuserid", @"ibillid", @"ifunsid", @"itype", @"imoney", @"cimgurl", @"cmemo", @"cbilldate", @"istate", @"iversion", @"cwritedate", @"operatortype"];
}

+ (NSArray *)primaryKeys {
    return @[@"iconfigid"];
}

+ (NSArray *)optionalColumns {
    return @[@"cimgurl", @"cmemo"];
}

+ (BOOL)shouldMergeRecord:(NSDictionary *)record inDatabase:(FMDatabase *)db error:(NSError **)error {
    NSString *billId = record[@"ibillid"];
    NSString *fundId = record[@"ifunsid"];
    
    if (!billId || !fundId) {
        *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"ibillid and fundId in record must not be nil"}];
        SSJPRINT(@">>> SSJ warning:cuserid and ibillid in record must not be nil \n record:%@", record);
        return NO;
    }
    
    //  如果此流水不依赖于特殊收支类型（istate等于2），还要从user_bill表中查询是否有此类型(因为user_bill中没有特殊收支类型)
    BOOL hasBillType = [db intForQuery:@"select istate from bk_bill_type where id = ?", billId] == 2;
    if (!hasBillType) {
        hasBillType = [db boolForQuery:@"select count(*) from bk_user_bill where cuserid = ? and cbillid = ?", SSJCurrentSyncDataUserId(), billId];
    }
    
    //  查询fund_info中是否有对应的资金帐户
    BOOL hasFundAccount = [db boolForQuery:@"select count(*) from bk_fund_info where cuserid = ? and cfundid = ?", SSJCurrentSyncDataUserId(), fundId];
    
    return (hasBillType && hasFundAccount);
}

@end
