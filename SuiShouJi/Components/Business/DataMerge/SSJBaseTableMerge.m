
//
//  SSJBaseTableMerge.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/12.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableMerge.h"

@implementation SSJBaseTableMerge

+ (NSString *)tableName {
    return nil;
}

+ (NSArray *)columns {
    return nil;
}

+ (NSArray *)primaryKeys {
    return nil;
}


+ (NSDictionary *)queryDatasWithSourceUserId:(NSString *)sourceUserid
                                TargetUserId:(NSString *)targetUserId
                                    FromDate:(NSDate *)fromDate
                                      ToDate:(NSDate *)toDate
                                  inDataBase:(FMDatabase *)db {
    return nil;
}

+ (void)updateIdSourceUserId:(NSString *)sourceUserid
                TargetUserId:(NSString *)targetUserId
                     DataDic:(NSDictionary *)dic {
    
}

+ (NSDictionary *)queryUserChargeWithUserId:(NSString *)userId
                                 condition:(NSString *)condition
                                   FromDate:(NSDate *)fromDate
                                     ToDate:(NSDate *)toDate
                                 inDataBase:(FMDatabase *)db {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    
    NSMutableString *sqlStr = [NSMutableString stringWithFormat:@"select * from bk_user_charge where cuserid = '%@' and operatortype <> 2",userId];
    
    if (condition.length) {
        [sqlStr appendString:condition];
    }
    
    FMResultSet *result = [db executeQuery:sqlStr];

    while ([result next]) {
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithCapacity:0];\
        [tempDic setObject:[result stringForColumn:@"ICHARGEID"] forKey:@"ICHARGEID"];
        [tempDic setObject:[result stringForColumn:@"CUSERID"] forKey:@"CUSERID"];
        [tempDic setObject:[result stringForColumn:@"IMONEY"] forKey:@"IMONEY"];
        [tempDic setObject:[result stringForColumn:@"IBILLID"] forKey:@"IBILLID"];
        [tempDic setObject:[result stringForColumn:@"IFUNSID"] forKey:@"IFUNSID"];
        [tempDic setObject:[result stringForColumn:@"CADDDATE"] forKey:@"CADDDATE"];
        [tempDic setObject:[result stringForColumn:@"IOLDMONEY"] forKey:@"IOLDMONEY"];
        [tempDic setObject:[result stringForColumn:@"IBALANCE"] forKey:@"IBALANCE"];
        [tempDic setObject:[result stringForColumn:@"CBILLDATE"] forKey:@"CBILLDATE"];
        [tempDic setObject:[result stringForColumn:@"CMEMO"] forKey:@"CMEMO"];
        [tempDic setObject:[result stringForColumn:@"CIMGURL"] forKey:@"CIMGURL"];
        [tempDic setObject:[result stringForColumn:@"THUMBURL"] forKey:@"THUMBURL"];
        [tempDic setObject:[result stringForColumn:@"IVERSION"] forKey:@"IVERSION"];
        [tempDic setObject:[result stringForColumn:@"CWRITEDATE"] forKey:@"CWRITEDATE"];
        [tempDic setObject:[result stringForColumn:@"OPERATORTYPE"] forKey:@"OPERATORTYPE"];
        [tempDic setObject:[result stringForColumn:@"CBOOKSID"] forKey:@"CBOOKSID"];
        [tempDic setObject:[result stringForColumn:@"CLIENTADDDATE"] forKey:@"CLIENTADDDATE"];
        [tempDic setObject:[result stringForColumn:@"ICHARGETYPE"] forKey:@"ICHARGETYPE"];
        [tempDic setObject:[result stringForColumn:@"CID"] forKey:@"CID"];
        [tempDic setObject:[result stringForColumn:@"CDETAILDATE"] forKey:@"CDETAILDATE"];
    }
    
    return dict;
}


@end
