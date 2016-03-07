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
    return @[@"ichargeid", @"imoney", @"ibillid", @"ifunsid", @"iconfigid", @"cadddate", @"ioldmoney", @"ibalance", @"cbilldate", @"cuserid", @"cimgurl", @"thumburl", @"cmemo", @"cwritedate", @"iversion", @"operatortype"];
}

+ (NSArray *)primaryKeys {
    return @[@"ichargeid"];
}

+ (NSArray *)optionalColumns {
    return @[@"iconfigid", @"cimgurl", @"thumburl", @"cmemo"];
}

+ (BOOL)shouldMergeRecord:(NSDictionary *)record inDatabase:(FMDatabase *)db error:(NSError **)error {
    NSString *billId = record[@"ibillid"];
    NSString *fundId = record[@"ifunsid"];
    NSString *configId = record[@"iconfigid"];  //  定期记账配置id可已为空（仅一次）
    if (!billId || !fundId) {
        *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"ibillid and fundId in record must not be nil"}];
        SSJPRINT(@">>> SSJ warning: ibillid and fundId in record must not be nil \n record:%@", record);
        return NO;
    }
    
    //  如果此流水不依赖于特殊收支类型（istate等于2），还要从user_bill表中查询是否有此类型(因为user_bill中没有特殊收支类型)
    if ([db intForQuery:@"select istate from bk_bill_type where id = ?", billId] != 2) {
        if (![db boolForQuery:@"select count(*) from bk_user_bill where cuserid = ? and cbillid = ?", SSJCurrentSyncDataUserId(), billId]) {
            return NO;
        }
    }
    
    //  查询fund_info中是否有对应的资金帐户
    if (![db boolForQuery:@"select count(*) from bk_fund_info where cuserid = ? and cfundid = ?", SSJCurrentSyncDataUserId(), fundId]) {
        return NO;
    }
    
    //  如果返回了定期配置id，就查询定期配置表中是否有这个id
    if (configId.length) {
        //  定期配置表中没有对应id的记录
        if (![db boolForQuery:@"select count(*) from bk_charge_period_config where iconfigid = ? and cuserid = ?", configId, SSJCurrentSyncDataUserId()]) {
            return NO;
        }
        
        //  根据定期配置表中的有效时间，判断如果流水在有效时间外，就不合并
//        if (![db boolForQuery:@"select count(*) from bk_user_charge where iconfigid = ? and cbilldate = ? and cuserid = ?", configId, record[@"cbilldate"], SSJCurrentSyncDataUserId()]) {
//            
//        }
        
        //  如果当前用户已经有了相同的定期记账流水，将其operatortype改为2
        if (![db executeUpdate:@"update bk_user_charge set operatortype = 2 where iconfigid = ? and cbilldate = ? and cuserid = ?", configId, record[@"cbilldate"], SSJCurrentSyncDataUserId()]) {
            return NO;
        }
    }
    
    return YES;
}

@end
