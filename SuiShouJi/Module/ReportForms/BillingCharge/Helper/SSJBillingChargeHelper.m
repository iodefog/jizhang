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
        
        if (![tBooksId isEqualToString:@"all"]) {
            [sql appendString:@" and a.CBOOKSID = :booksId"];
            [params setObject:tBooksId forKey:@"booksId"];
        }
        [sql appendString:@" order by a.CBILLDATE desc"];
        
        FMResultSet *resultSet = [db executeQuery:sql withParameterDictionary:params];
        
        if (!resultSet) {
            SSJPRINT(@">>>SSJ\n class:%@\n method:%@\n message:%@\n error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorMessage], [db lastError]);
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        
        NSMutableArray *result = [NSMutableArray array];
        NSMutableDictionary *subDic = nil;
        NSString *tempDate = nil;
        
        while ([resultSet next]) {
            SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
            item.imageName = [resultSet stringForColumn:@"CCOIN"];
            item.typeName = [resultSet stringForColumn:@"CNAME"];
            item.money = [resultSet stringForColumn:@"IMONEY"];
            item.colorValue = [resultSet stringForColumn:@"CCOLOR"];
            item.incomeOrExpence = [resultSet boolForColumn:@"ITYPE"];
            item.ID = [resultSet stringForColumn:@"ICHARGEID"];
            item.fundId = [resultSet stringForColumn:@"IFUNSID"];
            item.billDate = [resultSet stringForColumn:@"CBILLDATE"];
            item.editeDate = [resultSet stringForColumn:@"CWRITEDATE"];
            item.billId = [resultSet stringForColumn:@"IBILLID"];
            item.chargeMemo = [resultSet stringForColumn:@"cmemo"];
            item.chargeImage = [resultSet stringForColumn:@"cimgurl"];
            item.chargeThumbImage = [resultSet stringForColumn:@"thumburl"];
            item.idType = [resultSet intForColumn:@"ichargetype"];
            if (item.idType == SSJChargeIdTypeCircleConfig) {
                item.configId = [resultSet stringForColumn:@"cid"];
            }
            item.booksId = [resultSet stringForColumn:@"cbooksid"];;
            
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
                
                [result addObject:subDic];
                tempDate = item.billDate;
            }
        }
        
        SSJDispatch_main_async_safe(^{
            success(result);
        });
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
        
        NSMutableString *sql = [@"select a.ICHARGEID, c.IMONEY, a.CBILLDATE , a.CWRITEDATE , a.IFUNSID, a.IBILLID, a.cmemo, a.cimgurl, a.thumburl, a.cid, a.ichargetype, a.cbooksid, b.CNAME, b.CCOIN, b.CCOLOR, b.ITYPE from BK_USER_CHARGE as a, BK_BILL_TYPE as b, bk_member_charge as c where a.IBILLID = b.ID and a.ichargeid = c.ichargeid and b.istate <> 2 and b.itype = :type and c.cmemberid = :memberId and a.CBILLDATE >= :beginDate and a.CBILLDATE <= :endDate and a.CBILLDATE <= datetime('now', 'localtime') and a.CUSERID = :userId and a.OPERATORTYPE <> 2" mutableCopy];
        
        NSMutableDictionary *params = [@{@"type":@(isPayment),
                                         @"memberId":ID,
                                         @"beginDate":beginDate,
                                         @"endDate":endDate,
                                         @"userId":userID} mutableCopy];
        
        if (![tBooksId isEqualToString:@"all"]) {
            [sql appendString:@" and a.CBOOKSID = :booksId"];
            [params setObject:tBooksId forKey:@"booksId"];
        }
        
        [sql appendString:@" order by a.CBILLDATE desc"];
        
        FMResultSet *resultSet = [db executeQuery:sql withParameterDictionary:params];
        
        if (!resultSet) {
            SSJPRINT(@">>>SSJ\n class:%@\n method:%@\n message:%@\n error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorMessage], [db lastError]);
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        
        NSMutableArray *result = [NSMutableArray array];
        NSMutableDictionary *subDic = nil;
        NSString *tempDate = nil;
        
        while ([resultSet next]) {
            SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
            item.imageName = [resultSet stringForColumn:@"CCOIN"];
            item.typeName = [resultSet stringForColumn:@"CNAME"];
            item.money = [resultSet stringForColumn:@"IMONEY"];
            item.colorValue = [resultSet stringForColumn:@"CCOLOR"];
            item.incomeOrExpence = [resultSet boolForColumn:@"ITYPE"];
            item.ID = [resultSet stringForColumn:@"ICHARGEID"];
            item.fundId = [resultSet stringForColumn:@"IFUNSID"];
            item.billDate = [resultSet stringForColumn:@"CBILLDATE"];
            item.editeDate = [resultSet stringForColumn:@"CWRITEDATE"];
            item.billId = [resultSet stringForColumn:@"IBILLID"];
            item.chargeMemo = [resultSet stringForColumn:@"cmemo"];
            item.chargeImage = [resultSet stringForColumn:@"cimgurl"];
            item.chargeThumbImage = [resultSet stringForColumn:@"thumburl"];
            item.idType = [resultSet intForColumn:@"ichargetype"];
            if (item.idType) {
                item.configId = [resultSet stringForColumn:@"cid"];
            }
            item.booksId = [resultSet stringForColumn:@"cbooksid"];
            
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
                
                [result addObject:subDic];
                tempDate = item.billDate;
            }
        }
        
        SSJDispatch_main_async_safe(^{
            success(result);
        });
    }];
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
        if (booksId && ![booksId isEqualToString:@"all"]) {
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
