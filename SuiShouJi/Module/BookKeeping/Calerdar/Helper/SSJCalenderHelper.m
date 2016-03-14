//
//  SSJCalenderHelper.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCalenderHelper.h"
#import "SSJDatabaseQueue.h"
#import "SSJBillingChargeCellItem.h"

@implementation SSJCalenderHelper
+ (void)queryDataInYear:(NSInteger)year
                          month:(NSInteger)month
                        success:(void (^)(NSDictionary *data))success
                        failure:(void (^)(NSError *error))failure {
    
    if (year == 0 || month > 12) {
        SSJPRINT(@"class:%@\n method:%@\n message:(year == 0 || month > 12)",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        failure(nil);
        return;
    }
    NSString *dateStr = [NSString stringWithFormat:@"%04ld-%02ld-__",year,month];
//    if (month == 0) {
//        [dateStr appendFormat:@"-__-__"];
//    } else {
//        [dateStr appendFormat:@"-%02d-__",(int)month];
//    }
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select a.IMONEY, a.CBILLDATE , a.ICHARGEID , b.*  from BK_USER_CHARGE as a, BK_BILL_TYPE as b where a.IBILLID = b.ID and a.IFUNSID = ? and a.CBILLDATE like ? and a.operatortype != 2 order by a.cbilldate desc , a.cwritedate desc", dateStr];
        if (!resultSet) {
            SSJPRINT(@"class:%@\n method:%@\n message:%@\n error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorMessage], [db lastError]);
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        
        NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
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
                item.money = [NSString stringWithFormat:@"-%@",[resultSet stringForColumn:@"IMONEY"]];
            }else if(!item.incomeOrExpence && ![item.money hasPrefix:@"+"]){
                item.money = [NSString stringWithFormat:@"+%@",[resultSet stringForColumn:@"IMONEY"]];
            }
            NSString *billDate = [resultSet stringForColumn:@"CBILLDATE"];
            if ([tempDate isEqualToString:billDate]) {
                NSMutableArray *items = subDic[billDate];
                Sum = Sum + [item.money doubleValue];
                [items addObject:item];
            } else {
//                NSDate *transitDate = [originalFormatter dateFromString:billDate];
//                NSDateComponents *dateComponent = [calendar components:NSCalendarUnitWeekday fromDate:transitDate];
//                NSString *destinyDate = [destinyFormatter stringFromDate:transitDate];
//                NSString *currentDate = [destinyFormatter stringFromDate:[NSDate date]];
//                NSString *dateString;
//                if ([destinyDate isEqualToString:currentDate]) {
//                    dateString = @"今天";
//                }else{
//                    dateString = [NSString stringWithFormat:@"%@ %@", destinyDate, weekday];
//                }
//                subDic = [NSMutableDictionary dictionary];
//                [subDic setObject:dateString forKey:SSJFundingDetailDateKey];
//                [subDic setObject:[@[item] mutableCopy] forKey:SSJFundingDetailRecordKey];
//                Sum = [item.money doubleValue];
//                [result addObject:subDic];
//                tempDate = billDate;
//            }
//            [subDic setObject:[NSNumber numberWithDouble:Sum] forKey:SSJFundingDetailSumKey];
            }
        }
        
        SSJDispatch_main_async_safe(^{
            success(result);
        });
    }];
}

@end
