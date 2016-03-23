//
//  SSJFundingDetailHelper.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//


#import "SSJFundingDetailHelper.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJDatabaseQueue.h"

NSString *const SSJFundingDetailDateKey = @"SSJFundingDetailDateKey";
NSString *const SSJFundingDetailRecordKey = @"SSJFundingDetailRecordKey";
NSString *const SSJFundingDetailSumKey = @"SSJFundingDetailSumKey";


@implementation SSJFundingDetailHelper

+ (void)queryDataWithFundTypeID:(NSString *)ID
                          month:(NSInteger)month
                        success:(void (^)(NSArray <NSDictionary *>*data))success
                        failure:(void (^)(NSError *error))failure {
    
    if (month > 12) {
        SSJPRINT(@"class:%@\n method:%@\n message:(year == 0 || month > 12)",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        failure(nil);
        return;
    }
    
    NSMutableString *dateStr = [NSMutableString stringWithString:@"____"];
    if (month == 0) {
        [dateStr appendFormat:@"-__-__"];
    } else {
        [dateStr appendFormat:@"-%02d-__",(int)month];
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select a.IMONEY, a.CBILLDATE , a.ICHARGEID , b.*  from BK_USER_CHARGE as a, BK_BILL_TYPE as b where a.IBILLID = b.ID and a.IFUNSID = '%@' and a.CBILLDATE like '%@' and a.operatortype != 2 and a.cbilldate <= '%@' order by a.cbilldate desc , a.cwritedate desc", ID, dateStr,[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]];
        FMResultSet *resultSet = [db executeQuery:sql];
        if (!resultSet) {
            SSJPRINT(@"class:%@\n method:%@\n message:%@\n error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorMessage], [db lastError]);
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        
        NSMutableArray *result = [NSMutableArray array];
        NSMutableDictionary *subDic = nil;
        NSString *tempDate = nil;
        
        NSDateFormatter *destinyFormatter = [[NSDateFormatter alloc] init];
        destinyFormatter.dateFormat = @"yyyy年MM月dd日";
        
        NSDateFormatter *originalFormatter = [[NSDateFormatter alloc] init];
        originalFormatter.dateFormat = @"yyyy-MM-dd";
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        double Sum;
        Sum = 0;
        while ([resultSet next]) {
            SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
            item.imageName = [resultSet stringForColumn:@"CCOIN"];
            item.typeName = [resultSet stringForColumn:@"CNAME"];
            item.incomeOrExpence = [resultSet intForColumn:@"ITYPE"];
            item.money = [resultSet stringForColumn:@"IMONEY"];
            item.colorValue = [resultSet stringForColumn:@"CCOLOR"];
            item.ID = [resultSet stringForColumn:@"ICHARGEID"];
            if (item.incomeOrExpence && ![item.money hasPrefix:@"-"]) {
                item.money = [NSString stringWithFormat:@"-%.2f",[[resultSet stringForColumn:@"IMONEY"] doubleValue]];
            }else if(!item.incomeOrExpence && ![item.money hasPrefix:@"+"]){
                item.money = [NSString stringWithFormat:@"+%.2f",[[resultSet stringForColumn:@"IMONEY"] doubleValue]];
            }
            NSString *billDate = [resultSet stringForColumn:@"CBILLDATE"];
            if ([tempDate isEqualToString:billDate]) {
                NSMutableArray *items = subDic[SSJFundingDetailRecordKey];
                Sum = Sum + [item.money doubleValue];
                [items addObject:item];
            } else {
                NSDate *transitDate = [originalFormatter dateFromString:billDate];
                NSDateComponents *dateComponent = [calendar components:NSCalendarUnitWeekday fromDate:transitDate];
                NSString *weekday = [self stringFromWeekday:[dateComponent weekday]];
                NSString *destinyDate = [destinyFormatter stringFromDate:transitDate];
                NSString *currentDate = [destinyFormatter stringFromDate:[NSDate date]];
                NSString *dateString;
                if ([destinyDate isEqualToString:currentDate]) {
                    dateString = @"今天";
                }else{
                    dateString = [NSString stringWithFormat:@"%@ %@", destinyDate, weekday];
                }
                subDic = [NSMutableDictionary dictionary];
                [subDic setObject:dateString forKey:SSJFundingDetailDateKey];
                [subDic setObject:[@[item] mutableCopy] forKey:SSJFundingDetailRecordKey];
                Sum = [item.money doubleValue];
                [result addObject:subDic];
                tempDate = billDate;
            }
            [subDic setObject:[NSNumber numberWithDouble:Sum] forKey:SSJFundingDetailSumKey];
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
