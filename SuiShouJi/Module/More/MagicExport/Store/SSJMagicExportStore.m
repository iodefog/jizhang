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
        FMResultSet *result = [db executeQuery:@"select max(cbilldate), min(cbilldate) from bk_user_charge where cuserid = ? and operatortype <> 2 and cbilldate <= datetime('now', 'localtime')", SSJUSERID()];
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

+ (void)queryAllBillDateWithBillType:(SSJBillType)billType
                             success:(void (^)(NSArray<NSDate *> *result))success
                             failure:(void (^)(NSError *error))failure {
    
    NSString *queryStr = nil;
    switch (billType) {
        case SSJBillTypeIncome:
            queryStr = [NSString stringWithFormat:@"select a.cbilldate from bk_user_charge as a, bk_bill_type as b where a.cuserid = '%@' and a.operatortype <> 2 and a.cbilldate <= datetime('now', 'localtime') and a.ibillid = b.id and b.istate <> 2 and b.itype = 0 order by a.cbilldate", SSJUSERID()];
            break;
        case SSJBillTypePay:
            queryStr = [NSString stringWithFormat:@"select a.cbilldate from bk_user_charge as a, bk_bill_type as b where a.cuserid = '%@' and a.operatortype <> 2 and a.cbilldate <= datetime('now', 'localtime') and a.ibillid = b.id and b.istate <> 2 and b.itype = 1 order by a.cbilldate", SSJUSERID()];
            break;
        case SSJBillTypeSurplus:
            queryStr = [NSString stringWithFormat:@"select a.cbilldate from bk_user_charge as a, bk_bill_type as b where a.cuserid = '%@' and a.operatortype <> 2 and a.cbilldate <= datetime('now', 'localtime') and a.ibillid = b.id and b.istate <> 2 order by a.cbilldate", SSJUSERID()];
            break;
            
        case SSJBillTypeUnknown:
            queryStr = [NSString stringWithFormat:@"select cbilldate from bk_user_charge where cuserid = '%@' and operatortype <> 2 and cbilldate <= datetime('now', 'localtime') order by cbilldate", SSJUSERID()];
            break;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:queryStr];
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
