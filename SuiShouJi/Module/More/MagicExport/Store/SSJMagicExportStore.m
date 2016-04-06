//
//  SSJMagicExportStore.m
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportStore.h"
#import "SSJDatabaseQueue.h"

NSString *const SSJMagicExportStoreBeginDateKey = @"SSJMagicExportStoreBeginDateKey";
NSString *const SSJMagicExportStoreEndDateKey = @"SSJMagicExportStoreEndDateKey";

@implementation SSJMagicExportStore

+ (void)queryBillPeriodWithSuccess:(void (^)(NSDictionary<NSString *, NSDate *> *result))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"select max(cbilldate), min(cbilldate) from bk_user_charge where cuserid = ? and operatortype <> 2", SSJUSERID()];
        if (!result) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            
            return;
        }
        
        NSMutableDictionary *dateInfo = [NSMutableDictionary dictionaryWithCapacity:2];
        while ([result next]) {
            NSString *beginDateStr = [result stringForColumn:@"min(cbilldate)"];
            NSString *endDateStr = [result stringForColumn:@"max(cbilldate)"];
            NSDate *beginDate = [NSDate dateWithString:beginDateStr formatString:@"yyyy-MM-dd"];
            NSDate *endDate = [NSDate dateWithString:endDateStr formatString:@"yyyy-MM-dd"];
            if (beginDate) {
                [dateInfo setObject:beginDate forKey:SSJMagicExportStoreBeginDateKey];
            }
            if (endDate) {
                [dateInfo setObject:endDate forKey:SSJMagicExportStoreEndDateKey];
            }
            
        }
        [result close];
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(dateInfo);
            });
        }
    }];
}

+ (void)queryAllBillDateWithSuccess:(void (^)(NSArray<NSDate *> *result))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"select cbilldate from bk_user_charge where cuserid = ? and operatortype <> 2 order by cbilldate desc", SSJUSERID()];
        if (!result) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSMutableArray *billDates = [[NSMutableArray alloc] init];
        while ([result next]) {
            NSString *dateStr = [result stringForColumn:@"cbilldate"];
            NSDate *date = [NSDate dateWithString:dateStr formatString:@"yyyy-MM-dd"];
            [billDates addObject:date];
        }
        [result close];
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(billDates);
            });
        }
    }];
}

@end
