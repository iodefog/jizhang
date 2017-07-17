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

+ (void)queryChargeListWithMemberId:(nullable NSString *)memberId
                            booksId:(nullable NSString *)booksId
                             billId:(nullable NSString *)billId
                             period:(nullable SSJDatePeriod *)period
                            success:(void (^)(NSArray <NSDictionary *>*result))success
                            failure:(nullable void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSString *tMemberId = memberId;
        if (!tMemberId) {
            tMemberId = SSJUSERID();
        }
        
        NSString *tBooksId = booksId;
        if (!tBooksId) {
            tBooksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", SSJUSERID()];
            tBooksId = tBooksId.length > 0 ? tBooksId : SSJUSERID();
        }
        
        NSArray *result = nil;
        BOOL isShareBook = [db boolForQuery:@"select count(*) from bk_share_books where cbooksid = ?", tBooksId];
        if (isShareBook) {
            NSMutableDictionary *params = [@{@"booksId":tBooksId,
                                             @"userId":SSJUSERID()} mutableCopy];
            NSMutableString *sql = [@"select uc.cuserid, uc.ichargeid, uc.imoney, uc.cbilldate, uc.cwritedate, uc.ifunsid, uc.ibillid, uc.cmemo, uc.cimgurl, uc.thumburl, uc.cid, uc.ichargetype, uc.cbooksid, bt.cname, bt.ccoin, bt.ccolor, bt.itype, sm.cmark from bk_user_charge as uc, bk_bill_type as bt, bk_share_books_friends_mark as sm where uc.ibillid = bt.id and uc.operatortype <> 2 and uc.cbilldate <= datetime('now', 'localtime') and bt.istate <> 2 and uc.cbooksid = :booksId and uc.cbooksid = sm.cbooksid and uc.cuserid = sm.cfriendid and sm.cuserid = :userId" mutableCopy];
            
            if (![tMemberId isEqualToString:SSJAllMembersId]) {
                params[@"memberId"] = tMemberId;
                [sql appendString:@" and uc.cuserid = :memberId"];
            }
            
            if (billId) {
                params[@"billId"] = billId;
                [sql appendString:@" and uc.ibillid = :billId"];
            }
            
            if (period) {
                params[@"beginDate"] = [period.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
                params[@"endDate"] = [period.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
                [sql appendString:@" and uc.cbilldate >= :beginDate and uc.cbilldate <= :endDate"];
            }
            
            [sql appendString:@" order by uc.cbilldate desc"];
            FMResultSet *rs = [db executeQuery:sql withParameterDictionary:params];
            if (!rs) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
                return;
            }
            result = [self organiseDataWithResult:rs containsMemberMark:YES];
        } else if (billId) {
            NSMutableDictionary *params = [@{@"booksId":tBooksId,
                                             @"billId":billId} mutableCopy];
            NSMutableString *sql = [@"select uc.cuserid, uc.ichargeid, uc.imoney, uc.cbilldate, uc.cwritedate, uc.ifunsid, uc.ibillid, uc.cmemo, uc.cimgurl, uc.thumburl, uc.cid, uc.ichargetype, uc.cbooksid, bt.cname, bt.ccoin, bt.ccolor, bt.itype from bk_user_charge as uc, bk_bill_type as bt where uc.ibillid = bt.id and bt.istate <> 2 and uc.cbilldate <= datetime('now', 'localtime') and uc.operatortype <> 2 and uc.cbooksid = :booksId and uc.ibillid = :billId" mutableCopy];
            
            if (period) {
                params[@"beginDate"] = [period.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
                params[@"endDate"] = [period.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
                [sql appendString:@" and uc.cbilldate >= :beginDate and uc.cbilldate <= :endDate"];
            }
            
            [sql appendString:@" order by uc.cbilldate desc"];
            FMResultSet *rs = [db executeQuery:sql withParameterDictionary:params];
            if (!rs) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
                return;
            }
            result = [self organiseDataWithResult:rs containsMemberMark:NO];
        } else {
            NSMutableDictionary *params = [@{@"booksId":tBooksId} mutableCopy];
            NSMutableString *sql = [@"select uc.cuserid, uc.ichargeid, mc.imoney, uc.cbilldate, uc.cwritedate, uc.ifunsid, uc.ibillid, uc.cmemo, uc.cimgurl, uc.thumburl, uc.cid, uc.ichargetype, uc.cbooksid, bt.cname, bt.ccoin, bt.ccolor, bt.itype from bk_user_charge as uc, bk_bill_type as bt, bk_member_charge as mc where uc.ibillid = bt.id and uc.ichargeid = mc.ichargeid and bt.istate <> 2 and uc.cbilldate <= datetime('now', 'localtime') and uc.operatortype <> 2 and uc.cbooksid = :booksId" mutableCopy];
            
            if (![tMemberId isEqualToString:SSJAllMembersId]) {
                params[@"memberId"] = tMemberId;
                [sql appendString:@" and mc.cmemberid = :memberId"];
            }
            
            if (period) {
                params[@"beginDate"] = [period.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
                params[@"endDate"] = [period.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
                [sql appendString:@" and uc.cbilldate >= :beginDate and uc.cbilldate <= :endDate"];
            }
            
            [sql appendString:@" order by uc.cbilldate desc"];
            FMResultSet *rs = [db executeQuery:sql withParameterDictionary:params];
            if (!rs) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
                return;
            }
            result = [self organiseDataWithResult:rs containsMemberMark:NO];
        }
        
        SSJDispatch_main_async_safe(^{
            success(result);
        });
    }];
}

+ (void)queryChargeListWithMemberId:(nullable NSString *)memberId
                            booksId:(nullable NSString *)booksId
                           billName:(nullable NSString *)billName
                           billType:(SSJBillType)billType
                             period:(nullable SSJDatePeriod *)period
                            success:(void (^)(NSArray <NSDictionary *>*result))success
                            failure:(nullable void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSString *tMemberId = memberId;
        if (!tMemberId) {
            tMemberId = SSJUSERID();
        }
        
        NSString *tBooksId = booksId;
        if (!tBooksId) {
            tBooksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", SSJUSERID()];
            tBooksId = tBooksId.length > 0 ? tBooksId : SSJUSERID();
        }
        
        NSArray *result = nil;
        BOOL isShareBook = [db boolForQuery:@"select count(*) from bk_share_books where cbooksid = ?", tBooksId];
        if (isShareBook) {
            NSMutableDictionary *params = [@{@"booksId":tBooksId,
                                             @"userId":SSJUSERID()} mutableCopy];
            NSMutableString *sql = [@"select uc.cuserid, uc.ichargeid, uc.imoney, uc.cbilldate, uc.cwritedate, uc.ifunsid, uc.ibillid, uc.cmemo, uc.cimgurl, uc.thumburl, uc.cid, uc.ichargetype, uc.cbooksid, bt.cname, bt.ccoin, bt.ccolor, bt.itype, sm.cmark from bk_user_charge as uc, bk_bill_type as bt, bk_share_books_friends_mark as sm where uc.ibillid = bt.id and uc.operatortype <> 2 and uc.cbilldate <= datetime('now', 'localtime') and bt.istate <> 2 and uc.cbooksid = :booksId and uc.cbooksid = sm.cbooksid and uc.cuserid = sm.cfriendid and sm.cuserid = :userId" mutableCopy];
            
            if (![tMemberId isEqualToString:SSJAllMembersId]) {
                params[@"memberId"] = tMemberId;
                [sql appendString:@" and uc.cuserid = :memberId"];
            }
            
            if (billName) {
                params[@"billName"] = billName;
                [sql appendString:@" and bt.cname = :billName"];
            }
            
            if (billType == SSJBillTypePay || billType == SSJBillTypeIncome) {
                params[@"billType"] = @(billType);
                [sql appendString:@" and bt.itype = :billType"];
            }
            
            if (period) {
                params[@"beginDate"] = [period.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
                params[@"endDate"] = [period.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
                [sql appendString:@" and uc.cbilldate >= :beginDate and uc.cbilldate <= :endDate"];
            }
            
            [sql appendString:@" order by uc.cbilldate desc"];
            FMResultSet *rs = [db executeQuery:sql withParameterDictionary:params];
            if (!rs) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
                return;
            }
            
            result = [self organiseDataWithResult:rs containsMemberMark:YES];
        } else if (billName) {
            NSMutableDictionary *params = [@{@"booksId":tBooksId,
                                             @"billName":billName} mutableCopy];
            NSMutableString *sql = [@"select uc.cuserid, uc.ichargeid, uc.imoney, uc.cbilldate, uc.cwritedate, uc.ifunsid, uc.ibillid, uc.cmemo, uc.cimgurl, uc.thumburl, uc.cid, uc.ichargetype, uc.cbooksid, bt.cname, bt.ccoin, bt.ccolor, bt.itype from bk_user_charge as uc, bk_bill_type as bt where uc.ibillid = bt.id and bt.istate <> 2 and uc.cbilldate <= datetime('now', 'localtime') and uc.operatortype <> 2 and uc.cbooksid = :booksId" mutableCopy];
            
            if (billType == SSJBillTypePay || billType == SSJBillTypeIncome) {
                params[@"billType"] = @(billType);
                [sql appendString:@" and bt.itype = :billType"];
            }
            
            if (period) {
                params[@"beginDate"] = [period.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
                params[@"endDate"] = [period.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
                [sql appendString:@" and uc.cbilldate >= :beginDate and uc.cbilldate <= :endDate"];
            }
            
            [sql appendString:@" order by uc.cbilldate desc"];
            FMResultSet *rs = [db executeQuery:sql withParameterDictionary:params];if (!rs) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
                return;
            }
            
            result = [self organiseDataWithResult:rs containsMemberMark:NO];
        } else {
            NSMutableDictionary *params = [@{@"booksId":tBooksId} mutableCopy];
            NSMutableString *sql = [@"select uc.cuserid, uc.ichargeid, mc.imoney, uc.cbilldate, uc.cwritedate, uc.ifunsid, uc.ibillid, uc.cmemo, uc.cimgurl, uc.thumburl, uc.cid, uc.ichargetype, uc.cbooksid, bt.cname, bt.ccoin, bt.ccolor, bt.itype from bk_user_charge as uc, bk_bill_type as bt, bk_member_charge as mc where uc.ibillid = bt.id and uc.ichargeid = mc.ichargeid and bt.istate <> 2 and uc.cbilldate <= datetime('now', 'localtime') and uc.operatortype <> 2 and uc.cbooksid = :booksId" mutableCopy];
            
            if (![tMemberId isEqualToString:SSJAllMembersId]) {
                params[@"memberId"] = tMemberId;
                [sql appendString:@" and mc.cmemberid = :memberId"];
            }
            
            if (billType == SSJBillTypePay || billType == SSJBillTypeIncome) {
                params[@"billType"] = @(billType);
                [sql appendString:@" and bt.itype = :billType"];
            }
            
            if (period) {
                params[@"beginDate"] = [period.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
                params[@"endDate"] = [period.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
                [sql appendString:@" and uc.cbilldate >= :beginDate and uc.cbilldate <= :endDate"];
            }
            
            [sql appendString:@" order by uc.cbilldate desc"];
            FMResultSet *rs = [db executeQuery:sql withParameterDictionary:params];
            if (!rs) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
                return;
            }
            
            result = [self organiseDataWithResult:rs containsMemberMark:NO];
        }
        
        SSJDispatch_main_async_safe(^{
            success(result);
        });
    }];
}

+ (void)queryAllBooksChargeListBillId:(NSString *)billId
                               period:(nullable SSJDatePeriod *)period
                              success:(void (^)(NSArray <NSDictionary *>*result))success
                              failure:(nullable void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSMutableDictionary *params = [@{@"billId":billId,
                                         @"userId":SSJUSERID()} mutableCopy];
        NSMutableString *sql = [@"select uc.cuserid, uc.ichargeid, uc.imoney, uc.cbilldate, uc.cwritedate, uc.ifunsid, uc.ibillid, uc.cmemo, uc.cimgurl, uc.thumburl, uc.cid, uc.ichargetype, uc.cbooksid, bt.cname, bt.ccoin, bt.ccolor, bt.itype from bk_user_charge as uc, bk_bill_type as bt where uc.ibillid = bt.id and uc.operatortype <> 2 and uc.cbilldate <= datetime('now', 'localtime') and bt.istate <> 2 and uc.ibillid = :billId and uc.cuserid = :userId" mutableCopy];
        
        if (period) {
            params[@"beginDate"] = [period.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
            params[@"endDate"] = [period.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
            [sql appendString:@" and uc.cbilldate >= :beginDate and uc.cbilldate <= :endDate"];
        }
        
        [sql appendString:@" order by uc.cbilldate desc"];
        FMResultSet *rs = [db executeQuery:sql withParameterDictionary:params];
        if (!rs) {
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        
        NSArray *result = [self organiseDataWithResult:rs containsMemberMark:NO];
        SSJDispatch_main_async_safe(^{
            success(result);
        });
    }];
}

+ (NSArray *)organiseDataWithResult:(FMResultSet *)rs containsMemberMark:(BOOL)containsMemberMark {
    NSMutableArray *items = [NSMutableArray array];
    NSMutableDictionary *subDic = nil;
    NSString *tempDate = nil;
    
    while ([rs next]) {
        SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
        item.userId = [rs stringForColumn:@"cuserid"];
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
        if (containsMemberMark) {
            item.memberNickname = [item.userId isEqualToString:SSJUSERID()] ? @"我" : [rs stringForColumn:@"cmark"];
        }
        
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
            NSString *weekdayStr = nil;
            switch ([tmpDate weekday]) {
                case 1:
                    weekdayStr = @"星期日";
                    break;
                case 2:
                    weekdayStr = @"星期一";
                    break;
                case 3:
                    weekdayStr = @"星期二";
                    break;
                case 4:
                    weekdayStr = @"星期三";
                    break;
                case 5:
                    weekdayStr = @"星期四";
                    break;
                case 6:
                    weekdayStr = @"星期五";
                    break;
                case 7:
                    weekdayStr = @"星期六";
                    break;
            }
            
            NSString *dateString = [NSString stringWithFormat:@"%@ %@", [tmpDate formattedDateWithFormat:@"yyyy年MM月dd日"], weekdayStr];
            
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
