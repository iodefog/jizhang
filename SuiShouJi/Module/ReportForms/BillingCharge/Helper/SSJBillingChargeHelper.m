//
//  SSJBillingChargeHelper.m
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBillingChargeHelper.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJDatabaseQueue.h"
#import "SSJDatePeriod.h"
#import "SSJUserTableManager.h"

NSString *const SSJBillingChargeDateKey = @"SSJBillingChargeDateKey";
NSString *const SSJBillingChargeSumKey = @"SSJBillingChargeSumKey";
NSString *const SSJBillingChargeRecordKey = @"SSJBillingChargeRecordKey";

@implementation SSJBillingChargeHelper

+ (void)queryDataWithBillTypeID:(NSString *)ID
                        booksId:(NSString *)booksId
                       inPeriod:(SSJDatePeriod *)period
                        success:(void (^)(NSArray <NSDictionary *>*data))success
                        failure:(void (^)(NSError *error))failure {
    
    NSString *beginDate = [period.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *endDate = [period.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *tBooksId = booksId;
        if (!tBooksId) {
            tBooksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", SSJUSERID()];
            tBooksId = tBooksId ?: SSJUSERID();
        }
        
        NSMutableString *sql = [@"select a.ICHARGEID, a.IMONEY, a.CBILLDATE, a.CWRITEDATE, a.IFUNSID, a.IBILLID, a.cmemo, a.cimgurl, a.thumburl, a.cid , a.ichargetype, a.cbooksid, b.CNAME, b.CCOIN, b.CCOLOR, b.ITYPE from BK_USER_CHARGE as a, BK_BILL_TYPE as b where a.IBILLID = b.ID and a.IBILLID = :billId and a.CBILLDATE >= :beginDate and a.CBILLDATE <= :endDate and a.CBILLDATE <= datetime('now', 'localtime') and a.CUSERID = :userId and a.OPERATORTYPE <> 2" mutableCopy];
        
        NSMutableDictionary *params = [@{@"billId":ID,
                                         @"beginDate":beginDate,
                                         @"endDate":endDate,
                                         @"userId":SSJUSERID()} mutableCopy];
        
        if (![tBooksId isEqualToString:SSJAllBooksIds]) {
            [sql appendString:@" and a.CBOOKSID = :booksId"];
            [params setObject:tBooksId forKey:@"booksId"];
        }
        [sql appendString:@" order by a.CBILLDATE desc"];
        
        FMResultSet *rs = [db executeQuery:sql withParameterDictionary:params];
        if (!rs) {
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        
        NSArray *result = [self organiseDataWithResult:rs];
        SSJDispatch_main_async_safe(^{
            success(result);
        });
    }];
}

+ (void)queryDataWithBillTypeName:(NSString *)name
                          booksId:(NSString *)booksId
                         inPeriod:(SSJDatePeriod *)period
                          success:(void (^)(NSArray <NSDictionary *>*data))success
                          failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSString *beginDate = [period.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
        NSString *endDate = [period.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
        
        NSDictionary *params = @{@"name":name,
                                 @"beginDate":beginDate,
                                 @"endDate":endDate};
        FMResultSet *rs = [db executeQuery:@"select uc.ichargeid, uc.imoney, uc.cbilldate, uc.cwritedate, uc.ifunsid, uc.ibillid, uc.cmemo, uc.cimgurl, uc.thumburl, uc.cid, uc.ichargetype, uc.cbooksid, bt.cname, bt.ccoin, bt.ccolor, bt.itype from bk_user_charge as uc, bk_bill_type as bt where uc.ibillid = bt.id and bt.cname = :name and uc.cbilldate >= :beginDate and uc.cbilldate <= :endDate and uc.cbilldate <= datetime('now', 'localtime') and uc.operatortype <> 2 order by uc.cbilldate desc" withParameterDictionary:params];
        if (!rs) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSArray *result = [self organiseDataWithResult:rs];
        if (success) {
            SSJDispatchMainAsync(^{
                success(result);
            });
        }
    }];
}

+ (void)queryMemberChargeWithMemberID:(NSString *)ID
                              booksId:(NSString *)booksId
                             inPeriod:(SSJDatePeriod *)period
                            isPayment:(BOOL)isPayment
                              success:(void (^)(NSArray <NSDictionary *>*data))success
                              failure:(void (^)(NSError *error))failure {
    
    NSString *beginDate = [period.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *endDate = [period.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
    
    NSString *userID = SSJUSERID();
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *tBooksId = booksId;
        if (!tBooksId) {
            tBooksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", SSJUSERID()];
            tBooksId = tBooksId ?: SSJUSERID();
        }
        
        BOOL isShareBook = [db boolForQuery:@"select count(*) from bk_share_books_member where cmemberid = ? and cbooksid = ?", ID, tBooksId];
        FMResultSet *rs = nil;
        
        if (isShareBook) {
            NSDictionary *params = @{@"beginDate":beginDate,
                                     @"endDate":endDate,
                                     @"type":@(isPayment),
                                     @"memberId":ID,
                                     @"booksId":tBooksId};
            
            rs = [db executeQuery:@"select uc.ichargeid, uc.imoney, uc.cbilldate, uc.cwritedate, uc.ifunsid, uc.ibillid, uc.cmemo, uc.cimgurl, uc.thumburl, uc.cid, uc.ichargetype, uc.cbooksid, bt.cname, bt.ccoin, bt.ccolor, bt.itype from bk_user_charge as uc, bk_bill_type as bt, bk_share_books_member as sm where uc.ibillid = bt.id and sm.cmemberid = uc.cuserid and sm.cbooksid = uc.cbooksid and uc.operatortype <> 2 and uc.cbilldate >= :beginDate and uc.cbilldate <= :endDate and uc.cbilldate <= datetime('now', 'localtime') and bt.istate <> 2 and bt.itype = :type and sm.cmemberid = :memberId and sm.cbooksid = :booksId" withParameterDictionary:params];
        } else {
            NSMutableString *sql = [@"select a.ICHARGEID, c.IMONEY, a.CBILLDATE , a.CWRITEDATE , a.IFUNSID, a.IBILLID, a.cmemo, a.cimgurl, a.thumburl, a.cid, a.ichargetype, a.cbooksid, b.CNAME, b.CCOIN, b.CCOLOR, b.ITYPE from BK_USER_CHARGE as a, BK_BILL_TYPE as b, bk_member_charge as c where a.IBILLID = b.ID and a.ichargeid = c.ichargeid and b.istate <> 2 and b.itype = :type and c.cmemberid = :memberId and a.CBILLDATE >= :beginDate and a.CBILLDATE <= :endDate and a.CBILLDATE <= datetime('now', 'localtime') and a.CUSERID = :userId and a.OPERATORTYPE <> 2" mutableCopy];
            
            NSMutableDictionary *params = [@{@"type":@(isPayment),
                                             @"memberId":ID,
                                             @"beginDate":beginDate,
                                             @"endDate":endDate,
                                             @"userId":userID} mutableCopy];
            
            if (![tBooksId isEqualToString:SSJAllBooksIds]) {
                [sql appendString:@" and a.CBOOKSID = :booksId"];
                [params setObject:tBooksId forKey:@"booksId"];
            }
            [sql appendString:@" order by a.CBILLDATE desc"];
            
            rs = [db executeQuery:sql withParameterDictionary:params];
        }
        
        if (!rs) {
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        
        NSArray *result = [self organiseDataWithResult:rs];
        SSJDispatch_main_async_safe(^{
            success(result);
        });
    }];
}

+ (NSArray *)organiseDataWithResult:(FMResultSet *)rs {
    NSMutableArray *items = [NSMutableArray array];
    NSMutableDictionary *subDic = nil;
    NSString *tempDate = nil;
    
    while ([rs next]) {
        SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
        item.imageName = [rs stringForColumn:@"CCOIN"];
        item.typeName = [rs stringForColumn:@"CNAME"];
        item.money = [rs stringForColumn:@"IMONEY"];
        item.colorValue = [rs stringForColumn:@"CCOLOR"];
        item.incomeOrExpence = [rs boolForColumn:@"ITYPE"];
        item.ID = [rs stringForColumn:@"ICHARGEID"];
        item.fundId = [rs stringForColumn:@"IFUNSID"];
        item.billDate = [rs stringForColumn:@"CBILLDATE"];
        item.editeDate = [rs stringForColumn:@"CWRITEDATE"];
        item.billId = [rs stringForColumn:@"IBILLID"];
        item.chargeMemo = [rs stringForColumn:@"cmemo"];
        item.chargeImage = [rs stringForColumn:@"cimgurl"];
        item.chargeThumbImage = [rs stringForColumn:@"thumburl"];
        item.idType = [rs intForColumn:@"ichargetype"];
        item.sundryId = [rs stringForColumn:@"cid"];
        item.booksId = [rs stringForColumn:@"cbooksid"];
        
        if ([tempDate isEqualToString:item.billDate]) {
            NSMutableArray *items = subDic[SSJBillingChargeRecordKey];
            [items addObject:item];
            
            double sum = [subDic[SSJBillingChargeSumKey] doubleValue];
            double money = [item.money doubleValue];
            if (item.incomeOrExpence) {
                money = -money;
            }
            sum += money;
            [subDic setObject:@(sum) forKey:SSJBillingChargeSumKey];
            
        } else {
            NSDate *tmpDate = [NSDate dateWithString:item.billDate formatString:@"yyyy-MM-dd"];
            NSString *dateString = [NSString stringWithFormat:@"%@ %@", [tmpDate formattedDateWithFormat:@"yyyy年MM月dd日"], [self stringFromWeekday:[tmpDate weekday]]];
            
            
            subDic = [NSMutableDictionary dictionary];
            [subDic setObject:dateString forKey:SSJBillingChargeDateKey];
            [subDic setObject:[@[item] mutableCopy] forKey:SSJBillingChargeRecordKey];
            
            double money = [item.money doubleValue];
            if (item.incomeOrExpence) {
                money = -money;
            }
            [subDic setObject:@(money) forKey:SSJBillingChargeSumKey];
            
            [items addObject:subDic];
            tempDate = item.billDate;
        }
    }
    [rs close];
    
    return items;
}

+ (NSString *)stringFromWeekday:(NSInteger)weekday {
    switch (weekday) {
        case 1: return @"星期日";
        case 2: return @"星期一";
        case 3: return @"星期二";
        case 4: return @"星期三";
        case 5: return @"星期四";
        case 6: return @"星期五";
        case 7: return @"星期六";
            
        default: return nil;
    }
}

+ (void)queryTheRestChargeCountWithBillId:(NSString *)billId
                                 memberId:(NSString *)memberId
                                  booksId:(NSString *)booksId
                                   period:(SSJDatePeriod *)period
                                  success:(void(^)(int count))success
                                  failure:(void(^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSMutableString *chargeCountSql = [NSMutableString stringWithFormat:@"select count(1) from bk_user_charge as uc, bk_member_charge as mc where uc.cuserid = '%@' and uc.operatortype <> 2 and mc.operatortype <> 2 and uc.ichargeid = mc.ichargeid", SSJUSERID()];
        if (billId) {
            [chargeCountSql appendFormat:@" and uc.ibillid = '%@'", billId];
        }
        if (memberId) {
            [chargeCountSql appendFormat:@" and uc.cmemberid = '%@'", memberId];
        }
        if (booksId && ![booksId isEqualToString:SSJAllBooksIds]) {
            [chargeCountSql appendFormat:@" and uc.cbooksid = '%@'", booksId];
        }
        if (period) {
            NSString *startDate = [period.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
            NSString *endDate = [period.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
            [chargeCountSql appendFormat:@" and uc.cbilldate >= '%@' and uc.cbilldate <= '%@'", startDate, endDate];
        }
        
        int count = [db intForQuery:chargeCountSql];
        if (success) {
            SSJDispatchMainAsync(^{
                success(count);
            });
        }
    }];
}

@end
