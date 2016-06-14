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

+ (void)queryBillPeriodWithBookId:(NSString *)bookId
                          success:(void (^)(NSDictionary<NSString *, NSDate *> *result))success
                          failure:(void (^)(NSError *error))failure {
    
    NSMutableString *sqlStr = [[NSString stringWithFormat:@"select max(cbilldate), min(cbilldate) from bk_user_charge where cuserid = '%@' and operatortype <> 2 and cbilldate <= datetime('now', 'localtime')", SSJUSERID()] mutableCopy];
    if (bookId.length) {
        [sqlStr appendFormat:@" and cbooksid = '%@'", bookId];
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:sqlStr];
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
                             booksId:(NSString *)booksId
                             success:(void (^)(NSArray<NSDate *> *result))success
                             failure:(void (^)(NSError *error))failure {
    
    NSMutableString *queryStr = nil;
    switch (billType) {
        case SSJBillTypeIncome:
            queryStr = [NSMutableString stringWithFormat:@"select a.cbilldate from bk_user_charge as a, bk_bill_type as b where a.cuserid = '%@' and a.operatortype <> 2 and a.cbilldate <= datetime('now', 'localtime') and a.ibillid = b.id and b.istate <> 2 and b.itype = 0", SSJUSERID()];
            break;
            
        case SSJBillTypePay:
            queryStr = [NSMutableString stringWithFormat:@"select a.cbilldate from bk_user_charge as a, bk_bill_type as b where a.cuserid = '%@' and a.operatortype <> 2 and a.cbilldate <= datetime('now', 'localtime') and a.ibillid = b.id and b.istate <> 2 and b.itype = 1", SSJUSERID()];
            break;
            
        case SSJBillTypeSurplus:
            queryStr = [NSMutableString stringWithFormat:@"select a.cbilldate from bk_user_charge as a, bk_bill_type as b where a.cuserid = '%@' and a.operatortype <> 2 and a.cbilldate <= datetime('now', 'localtime') and a.ibillid = b.id and b.istate <> 2", SSJUSERID()];
            break;
            
        case SSJBillTypeUnknown:
            queryStr = [NSMutableString stringWithFormat:@"select a.cbilldate from bk_user_charge as a where a.cuserid = '%@' and a.operatortype <> 2 and a.cbilldate <= datetime('now', 'localtime')", SSJUSERID()];
            break;
    }
    
    if (booksId.length) {
        [queryStr appendFormat:@" and a.cbooksid = '%@'", booksId];
    }
    [queryStr appendString:@" order by a.cbilldate"];
    
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
