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
                       inPeriod:(SSJDatePeriod *)period
                        success:(void (^)(NSArray <NSDictionary *>*data))success
                        failure:(void (^)(NSError *error))failure {
    
    SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"currentBooksId"] forUserId:SSJUSERID()];
    
    if (!userItem.currentBooksId.length) {
        userItem.currentBooksId = SSJUSERID();
    }
    
    NSString *beginDate = [period.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *endDate = [period.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select a.ICHARGEID, a.IMONEY, a.CBILLDATE , a.CWRITEDATE , a.IFUNSID, a.IBILLID, a.cmemo, a.cimgurl, a.thumburl, a.iconfigid, b.CNAME, b.CCOIN, b.CCOLOR, b.ITYPE from BK_USER_CHARGE as a, BK_BILL_TYPE as b where a.IBILLID = b.ID and a.IBILLID = ? and a.CBILLDATE >= ? and a.CBILLDATE <= ? and a.CBILLDATE <= datetime('now', 'localtime') and a.CUSERID = ? and a.OPERATORTYPE <> 2 and a.CBOOKSID = ? order by a.CBILLDATE desc", ID, beginDate, endDate, SSJUSERID(), userItem.currentBooksId];
        
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
            item.configId = [resultSet stringForColumn:@"iconfigid"];
            item.booksId = userItem.currentBooksId;
            
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
                             inPeriod:(SSJDatePeriod *)period
                              success:(void (^)(NSArray <NSDictionary *>*data))success
                              failure:(void (^)(NSError *error))failure {
    
    SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"currentBooksId"] forUserId:SSJUSERID()];
    
    if (!userItem.currentBooksId.length) {
        userItem.currentBooksId = SSJUSERID();
    }
    
    NSString *beginDate = [period.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *endDate = [period.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        
        FMResultSet *resultSet = [db executeQuery:@"select a.ICHARGEID, c.IMONEY, a.CBILLDATE , a.CWRITEDATE , a.IFUNSID, a.IBILLID, a.cmemo, a.cimgurl, a.thumburl, a.iconfigid, b.CNAME, b.CCOIN, b.CCOLOR, b.ITYPE from BK_USER_CHARGE as a, BK_BILL_TYPE as b, bk_member_charge as c where a.IBILLID = b.ID and a.ichargeid = c.ichargeid and c.cmemberid = ? and a.CBILLDATE >= ? and a.CBILLDATE <= ? and a.CBILLDATE <= datetime('now', 'localtime') and a.CUSERID = ? and a.OPERATORTYPE <> 2 and a.CBOOKSID = ? order by a.CBILLDATE desc", ID, beginDate, endDate, SSJUSERID(), userItem.currentBooksId];
        
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
            item.configId = [resultSet stringForColumn:@"iconfigid"];
            item.booksId = userItem.currentBooksId;
            
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

@end
