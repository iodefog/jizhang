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
                         InYear:(NSInteger)year
                          month:(NSInteger)month
                        success:(void (^)(NSArray <NSDictionary *>*data))success
                        failure:(void (^)(NSError *error))failure {
    
    if (year == 0 || month > 12) {
        SSJPRINT(@"class:%@\n method:%@\n message:(year == 0 || month > 12)",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        failure(nil);
        return;
    }
    
    NSMutableString *dateStr = [NSMutableString stringWithFormat:@"%04d",(int)year];
    if (month == 0) {
        [dateStr appendFormat:@"-__-__"];
    } else {
        [dateStr appendFormat:@"-%02d-__",(int)month];
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select a.IMONEY, a.CBILLDATE , a.ICHARGEID , b.* , c.ITYPE from BK_USER_CHARGE as a, BK_BILL_TYPE as b , BK_BILL_TYPE as c where a.IBILLID = b.ID and a.IFID = ? and a.CBILLDATE like ?  and a.IBILLID = c.ID order by a.CBILLDATE desc", ID, dateStr];
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
            if (item.incomeOrExpence) {
                item.money = [NSString stringWithFormat:@"-%@",[resultSet stringForColumn:@"IMONEY"]];
            }else{
                item.money = [NSString stringWithFormat:@"+%@",[resultSet stringForColumn:@"IMONEY"]];
            }
            item.ID = [resultSet stringForColumn:@"ICHARGEID"];
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
        case 1: return @"星期一";
        case 2: return @"星期二";
        case 3: return @"星期三";
        case 4: return @"星期四";
        case 5: return @"星期五";
        case 6: return @"星期六";
        case 7: return @"星期日";
            
        default: return nil;
    }
}


@end
