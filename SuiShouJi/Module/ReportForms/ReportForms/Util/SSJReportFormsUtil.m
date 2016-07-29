//
//  SSJReportFormsUtil.m
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJReportFormsUtil.h"
#import "SSJDatabaseQueue.h"
#import "SSJReportFormsPeriodModel.h"
#import "SSJUserTableManager.h"
#import "SSJReportFormsCurveModel.h"

NSString *const SSJReportFormsCurveModelListKey = @"SSJReportFormsCurveModelListKey";
NSString *const SSJReportFormsCurveModelBeginDateKey = @"SSJReportFormsCurveModelBeginDateKey";
NSString *const SSJReportFormsCurveModelEndDateKey = @"SSJReportFormsCurveModelEndDateKey";

@implementation SSJReportFormsUtil

+ (void)queryForPeriodListWithIncomeOrPayType:(SSJBillType)type
                                      success:(void (^)(NSArray<SSJDatePeriod *> *))success
                                      failure:(void (^)(NSError *))failure {
    
    SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"currentBooksId"] forUserId:SSJUSERID()];
    if (!userItem.currentBooksId.length) {
        userItem.currentBooksId = SSJUSERID();
    }
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *result = nil;
        switch (type) {
            case SSJBillTypeIncome:
            case SSJBillTypePay: {
                NSString *incomeOrPayType = type == SSJBillTypeIncome ? @"0" : @"1";
                result = [db executeQuery:@"select distinct strftime('%Y-%m', a.cbilldate) from bk_user_charge as a, bk_bill_type as b where  a.cuserid = ? and a.ibillid = b.id and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and a.cbooksid = ? and b.itype = ? and b.istate <> 2 order by a.cbilldate", SSJUSERID(), userItem.currentBooksId, incomeOrPayType];
            }   break;
                
            case SSJBillTypeSurplus: {
                result = [db executeQuery:@"select distinct strftime('%Y-%m', a.cbilldate) from bk_user_charge as a, bk_bill_type as b where a.cuserid = ? and a.ibillid = b.id and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and a.cbooksid = ? and b.istate <> 2 order by a.cbilldate", SSJUSERID(), userItem.currentBooksId];
            }   break;
                
            case SSJBillTypeUnknown:
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure(nil);
                    });
                }
                break;
        }
        
        if (!result) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
//        NSInteger year = 0;
        NSMutableArray *list = [NSMutableArray array];
        while ([result next]) {
            NSString *dateStr = [result stringForColumnIndex:0];
            NSDate *date = [NSDate dateWithString:dateStr formatString:@"yyyy-MM"];
//            if (year && year != [date year]) {
//                SSJDatePeriod *period = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeYear date:date];
//                [list addObject:period];
//                year = [date year];
//            }
            
            SSJDatePeriod *period = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeMonth date:date];
            [list addObject:period];
        }
        
        if (list.count) {
            SSJDatePeriod *firstPeriod = [list firstObject];
            SSJDatePeriod *lastPeriod = [list lastObject];
            [list addObject:[SSJDatePeriod datePeriodWithStartDate:firstPeriod.startDate endDate:lastPeriod.endDate]];
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(list);
            });
        }
    }];
}

+ (void)queryForIncomeOrPayType:(SSJBillType)type
                      startDate:(NSDate *)startDate
                        endDate:(NSDate *)endDate
                        success:(void(^)(NSArray<SSJReportFormsItem *> *result))success
                        failure:(void (^)(NSError *error))failure {
    
    switch (type) {
        case SSJBillTypeIncome:
        case SSJBillTypePay:
            [self queryForIncomeOrPayChargeWithType:type startDate:startDate endDate:endDate success:success failure:failure];
            break;
            
        case SSJBillTypeSurplus:
            [self queryForSurplusWithStartDate:startDate endDate:endDate success:success failure:failure];
            break;
            
        case SSJBillTypeUnknown:
            failure(nil);
            break;
    }
}

//  查询收支数据
+ (void)queryForIncomeOrPayChargeWithType:(SSJBillType)type
                                startDate:(NSDate *)startDate
                                  endDate:(NSDate *)endDate
                                  success:(void (^)(NSArray <SSJReportFormsItem *> *result))success
                                  failure:(void (^)(NSError *error))failure {
    
    NSString *incomeOrPayType = nil;
    switch (type) {
        case SSJBillTypeIncome:
            incomeOrPayType = @"0";
            break;
            
        case SSJBillTypePay:
            incomeOrPayType = @"1";
            break;
            
        case SSJBillTypeSurplus:
        case SSJBillTypeUnknown:
            failure(nil);
            return;
    }
    
    if (!startDate || !endDate) {
        failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"startDate or endDate must not be nil"}]);
        return;
    }
    
    NSString *beginDateStr = [startDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *endDateStr = [endDate formattedDateWithFormat:@"yyyy-MM-dd"];
    
    SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"currentBooksId"] forUserId:SSJUSERID()];
    
    if (!userItem.currentBooksId.length) {
        userItem.currentBooksId = SSJUSERID();
    }

    //  查询不同收支类型的总额
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *amountResultSet = [db executeQuery:@"select sum(a.IMONEY) from BK_USER_CHARGE as a, BK_BILL_TYPE as b where a.IBILLID = b.ID and a.CBILLDATE >= ? and a.cbilldate <= ? and a.cbilldate <= datetime('now', 'localtime') and a.CUSERID = ? and a.OPERATORTYPE <> 2 and a.cbooksid = ? and b.istate <> 2 and b.ITYPE = ?", beginDateStr , endDateStr, SSJUSERID(), userItem.currentBooksId, incomeOrPayType];
        
        if (!amountResultSet) {
            SSJPRINT(@">>>SSJ\n class:%@\n method:%@\n message:%@\n error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorMessage], [db lastError]);
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        
        double amount = 0;
        while ([amountResultSet next]) {
            amount = [amountResultSet doubleForColumnIndex:0];
        }
        
        if (amount == 0) {
            SSJDispatch_main_async_safe(^{
                success(nil);
            });
            
            return;
        }
        
        //  查询不同收支类型相应的金额、名称、图标、颜色
        FMResultSet *resultSet = [db executeQuery:@"select sum(a.imoney), b.id, b.cname, b.ccoin, b.ccolor from bk_user_charge as a, bk_bill_type as b where a.cuserid = ? and a.ibillid = b.id and a.cbilldate >= ? and a.cbilldate <= ? and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and a.cbooksid = ? and b.itype = ? and b.istate <> 2 group by b.id", SSJUSERID(), beginDateStr, endDateStr, userItem.currentBooksId, incomeOrPayType];
        
        if (!resultSet) {
            SSJPRINT(@">>>SSJ\n class:%@\n method:%@\n message:%@\n error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorMessage], [db lastError]);
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        
        NSMutableArray *result = [@[] mutableCopy];
        while ([resultSet next]) {
            SSJReportFormsItem *item = [[SSJReportFormsItem alloc] init];
            item.ID = [resultSet stringForColumn:@"id"];
            item.money = [resultSet doubleForColumn:@"sum(a.imoney)"];
            item.scale = item.money / amount;
            item.colorValue = [resultSet stringForColumn:@"ccolor"];
            item.imageName = [resultSet stringForColumn:@"ccoin"];
            item.name = [resultSet stringForColumn:@"cname"];
            item.titleColor = SSJ_CURRENT_THEME.mainColor;
            [result addObject:item];
        }
        
        SSJDispatch_main_async_safe(^{
            success(result);
        });
    }];
}

//  查询结余数据
+ (void)queryForSurplusWithStartDate:(NSDate *)startDate
                             endDate:(NSDate *)endDate
                             success:(void (^)(NSArray <SSJReportFormsItem *> *result))success
                             failure:(void (^)(NSError *error))failure {
    
    SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"currentBooksId"] forUserId:SSJUSERID()];
    
    if (!userItem.currentBooksId.length) {
        userItem.currentBooksId = SSJUSERID();
    }

    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        
        NSString *beginDateStr = [startDate formattedDateWithFormat:@"yyyy-MM-dd"];
        NSString *endDateStr = [endDate formattedDateWithFormat:@"yyyy-MM-dd"];
        
        FMResultSet *resultSet = [db executeQuery:@"select sum(a.imoney), b.itype from bk_user_charge as a, bk_bill_type as b where a.cuserid = ? and a.ibillid = b.id and a.cbilldate >= ? and a.cbilldate <= ? and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and a.cbooksid = ? and b.istate <> 2 group by b.itype order by b.itype desc", SSJUSERID(), beginDateStr, endDateStr, userItem.currentBooksId];
        
        if (!resultSet) {
            SSJPRINT(@">>>SSJ\n class:%@\n method:%@\n message:%@\n error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorMessage], [db lastError]);
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        
        double amount = 0;
        
        NSMutableArray *result = [NSMutableArray arrayWithCapacity:2];
        while ([resultSet next]) {
            //  0:收入 1:支出
            int type = [resultSet intForColumn:@"ITYPE"];
            
            SSJReportFormsItem *item = [[SSJReportFormsItem alloc] init];
            item.type = type;
            item.money = [resultSet doubleForColumn:@"sum(a.imoney)"];
            item.colorValue = type == 0 ? @"#f56262" : @"#59ae65";
            item.imageName = type == 0 ? @"reportForms_income" : @"reportForms_expenses";
            item.titleColor = SSJ_CURRENT_THEME.mainColor;
            [result addObject:item];
            amount += item.money;
        }
        
        for (int i = 0; i < result.count; i ++) {
            SSJReportFormsItem *item = result[i];
            item.scale = item.money / amount;
        }
        
        SSJDispatch_main_async_safe(^{
            success(result);
        });
    }];
}

+ (void)queryForBillStatisticsWithType:(int)type
                             startDate:(NSDate *)startDate
                               endDate:(NSDate *)endDate
                               success:(void(^)(NSDictionary *result))success
                               failure:(void (^)(NSError *error))failure {
    
    if (type != 0 && type != 1 && type != 2) {
        if (failure) {
            failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"type参数错误，只能为0、1、2"}]);
        }
        return;
    }
    
    SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"currentBooksId"] forUserId:SSJUSERID()];
    
    if (!userItem.currentBooksId.length) {
        userItem.currentBooksId = SSJUSERID();
    }

    NSMutableString *sqlStr = [NSMutableString stringWithFormat:@"select a.imoney, a.cbilldate, b.itype from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.cuserid = '%@' and a.operatortype <> 2 and a.cbooksid = '%@' and b.istate <> 2 and a.cbilldate <= datetime('now', 'localtime')", SSJUSERID(), userItem.currentBooksId];
    
    if (startDate) {
        NSString *startDateStr = [startDate formattedDateWithFormat:@"yyyy-MM-dd"];
        [sqlStr appendFormat:@" and a.cbilldate >= '%@'", startDateStr];
    }
    
    if (endDate) {
        NSString *endDateStr = [endDate formattedDateWithFormat:@"yyyy-MM-dd"];
        [sqlStr appendFormat:@" and a.cbilldate <= '%@'", endDateStr];
    }
    
    [sqlStr appendString:@"order by a.cbilldate"];
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sqlStr];
        if (!resultSet) {
            SSJPRINT(@">>>SSJ\n class:%@\n method:%@\n message:%@\n error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorMessage], [db lastError]);
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        SSJDatePeriod *period = nil;
        double payment = 0;
        double income = 0;
        int weekOrder = 0;
        SSJDatePeriodType periodType = SSJDatePeriodTypeUnknown;
        switch (type) {
            case 0:
                periodType = SSJDatePeriodTypeMonth;
                break;
                
            case 1:
                periodType = SSJDatePeriodTypeWeek;
                break;
                
            case 2:
                periodType = SSJDatePeriodTypeDay;
                break;
        }
        
        NSMutableArray *list = [NSMutableArray array];
        NSString *startDateStr = nil;
        NSString *endDateStr = nil;
        
        while ([resultSet next]) {
            NSString *billDateStr = [resultSet stringForColumn:@"cbilldate"];
            NSDate *billDate = [NSDate dateWithString:billDateStr formatString:@"yyyy-MM-dd"];
            double money = [resultSet doubleForColumn:@"imoney"];
            BOOL isPayment = [resultSet boolForColumn:@"itype"];
            
            if (!startDateStr) {
                startDateStr = [billDate formattedDateWithFormat:@"yyyy-MM-dd"];
            }
            endDateStr = [billDate formattedDateWithFormat:@"yyyy-MM-dd"];
            
            if (!period) {
                period = [SSJDatePeriod datePeriodWithPeriodType:periodType date:billDate];
                // 第一次遍历，补充查询起始时间和查询出的第一条纪录之间的收支统计
                if (startDate) {
                    SSJDatePeriod *startPeriod = [SSJDatePeriod datePeriodWithPeriodType:periodType date:startDate];
                    NSMutableArray *periods = [@[startPeriod] mutableCopy];
                    [periods addObjectsFromArray:[period periodsFromPeriod:startPeriod]];
                    for (int i = 0; i < periods.count - 1; i ++) {
                        SSJDatePeriod *addPeriod = periods[i];
                        weekOrder++;
                        [list addObject:[self modelWithPayment:0 income:0 weekOrder:weekOrder period:addPeriod]];
                    }
                }
            }
            
            if ([period containDate:billDate]) {
                if (isPayment) {
                    payment += money;
                } else {
                    income += money;
                }
            } else {
                
                weekOrder++;
                [list addObject:[self modelWithPayment:payment income:income weekOrder:weekOrder period:period]];
                
                SSJDatePeriod *currentPeriod = [SSJDatePeriod datePeriodWithPeriodType:periodType date:billDate];
                NSArray *periods = [currentPeriod periodsFromPeriod:period];
                for (int i = 0; i < periods.count - 1; i ++) {
                    SSJDatePeriod *addPeriod = periods[i];
                    weekOrder++;
                    [list addObject:[self modelWithPayment:0 income:0 weekOrder:weekOrder period:addPeriod]];
                }
                
                period = currentPeriod;
                payment = 0;
                income = 0;
                if (isPayment) {
                    payment += money;
                } else {
                    income += money;
                }
            }
        }
        
        if (period) {
            // 如果列表为空或者最后一个收支统计与当前收支统计的周期不一致，就把当前统计加入到列表中
            SSJReportFormsCurveModel *lastModel = [list lastObject];
            if (!lastModel || [lastModel.period compareWithPeriod:period] != SSJDatePeriodComparisonResultSame) {
                weekOrder++;
                [list addObject:[self modelWithPayment:payment income:income weekOrder:weekOrder period:period]];
            }
            
            // 补充查询出的最后一个收支统计和截止时间之间的收支统计
            if (endDate) {
                lastModel = [list lastObject];
                SSJDatePeriod *endPeriod = [SSJDatePeriod datePeriodWithPeriodType:periodType date:endDate];
                NSArray *periods = [endPeriod periodsFromPeriod:lastModel.period];
                for (int i = 0; i < periods.count; i ++) {
                    SSJDatePeriod *addPeriod = periods[i];
                    weekOrder++;
                    [list addObject:[self modelWithPayment:0 income:0 weekOrder:weekOrder period:addPeriod]];
                }
            }
        } else {
            // 如果数据库中没有纪录，并且起始、截止时间都传入了，补充之间的收支统计
            if (startDate && endDate) {
                SSJDatePeriod *startPeriod = [SSJDatePeriod datePeriodWithPeriodType:periodType date:startDate];
                SSJDatePeriod *endPeriod = [SSJDatePeriod datePeriodWithPeriodType:periodType date:endDate];
                NSMutableArray *periods = [[endPeriod periodsFromPeriod:startPeriod] mutableCopy];
                [periods addObject:startPeriod];
                for (int i = 0; i < periods.count; i ++) {
                    SSJDatePeriod *addPeriod = periods[i];
                    weekOrder++;
                    [list addObject:[self modelWithPayment:0 income:0 weekOrder:weekOrder period:addPeriod]];
                }
            }
        }
        
        startDateStr = startDate ? [startDate formattedDateWithFormat:@"yyyy-MM-dd"] : startDateStr;
        endDateStr = endDate ? [endDate formattedDateWithFormat:@"yyyy-MM-dd"] : endDateStr;
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                NSMutableDictionary *result = [NSMutableDictionary dictionary];
                if (list) {
                    [result setObject:list forKey:SSJReportFormsCurveModelListKey];
                }
                if (startDateStr) {
                    [result setObject:startDateStr forKey:SSJReportFormsCurveModelBeginDateKey];
                }
                if (endDateStr) {
                    [result setObject:endDateStr forKey:SSJReportFormsCurveModelEndDateKey];
                }
                success(result);
            });
        }
    }];
}

+ (SSJReportFormsCurveModel *)modelWithPayment:(double)payment income:(double)income weekOrder:(int)weekOrder period:(SSJDatePeriod *)period {
    NSString *paymentStr = [NSString stringWithFormat:@"%f", payment];
    NSString *incomeStr = [NSString stringWithFormat:@"%f", income];
    NSString *timeStr = nil;
    
    if (period.periodType == SSJDatePeriodTypeMonth) {
        timeStr = [NSString stringWithFormat:@"%d月", (int)period.startDate.month];
    } else if (period.periodType == SSJDatePeriodTypeWeek) {
        timeStr = [NSString stringWithFormat:@"%d周", weekOrder];
    } else if (period.periodType == SSJDatePeriodTypeDay) {
        
    }
    
    return [SSJReportFormsCurveModel modelWithPayment:paymentStr income:incomeStr time:timeStr period:period];
}

//  查询成员记账数据
+ (void)queryForMemberChargeWithType:(SSJBillType)type
                                startDate:(NSDate *)startDate
                                  endDate:(NSDate *)endDate
                                  success:(void (^)(NSArray <SSJReportFormsItem *> *result))success
                                  failure:(void (^)(NSError *error))failure {
    
    NSString *incomeOrPayType = nil;
    switch (type) {
        case SSJBillTypeIncome:
            incomeOrPayType = @"0";
            break;
            
        case SSJBillTypePay:
            incomeOrPayType = @"1";
            break;
            
        case SSJBillTypeSurplus:
        case SSJBillTypeUnknown:
            failure(nil);
            return;
    }
    
    if (!startDate || !endDate) {
        failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"startDate or endDate must not be nil"}]);
        return;
    }
    
    NSString *beginDateStr = [startDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *endDateStr = [endDate formattedDateWithFormat:@"yyyy-MM-dd"];
    
    SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"currentBooksId"] forUserId:SSJUSERID()];
    
    if (!userItem.currentBooksId.length) {
        userItem.currentBooksId = SSJUSERID();
    }
    
    //  查询不同收支类型的总额
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *amountResultSet = [db executeQuery:@"select sum(a.IMONEY) from BK_USER_CHARGE as a, BK_BILL_TYPE as b where a.IBILLID = b.ID and a.CBILLDATE >= ? and a.cbilldate <= ? and a.cbilldate <= datetime('now', 'localtime') and a.CUSERID = ? and a.OPERATORTYPE <> 2 and a.cbooksid = ? and b.istate <> 2 and b.ITYPE = ?", beginDateStr , endDateStr, SSJUSERID(), userItem.currentBooksId, incomeOrPayType];
        
        if (!amountResultSet) {
            SSJPRINT(@">>>SSJ\n class:%@\n method:%@\n message:%@\n error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorMessage], [db lastError]);
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        
        double amount = 0;
        while ([amountResultSet next]) {
            amount = [amountResultSet doubleForColumnIndex:0];
        }
        
        if (amount == 0) {
            SSJDispatch_main_async_safe(^{
                success(nil);
            });
            
            return;
        }
        
        //  查询不同收支类型相应的金额、名称、图标、颜色
        FMResultSet *resultSet = [db executeQuery:@"select sum(c.imoney), d.cname , d.ccolor , d.cmemberid from bk_user_charge as a, bk_bill_type as b , bk_member_charge as c , bk_member as d where a.cuserid = ? and a.ibillid = b.id and a.cbilldate >= ? and c.ichargeid = a.ichargeid and d.cmemberid = c.cmemberid and d.cuserid = a.cuserid and a.cbilldate <= ? and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and a.cbooksid = ? and b.itype = ? and b.istate <> 2 group by c.cmemberid", SSJUSERID(), beginDateStr, endDateStr, userItem.currentBooksId, incomeOrPayType];
        
        if (!resultSet) {
            SSJPRINT(@">>>SSJ\n class:%@\n method:%@\n message:%@\n error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorMessage], [db lastError]);
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        
        NSMutableArray *result = [@[] mutableCopy];
        while ([resultSet next]) {
            SSJReportFormsItem *item = [[SSJReportFormsItem alloc] init];
            item.ID = [resultSet stringForColumn:@"cmemberid"];
            item.money = [resultSet doubleForColumn:@"sum(c.imoney)"];
            item.scale = item.money / amount;
            item.colorValue = [resultSet stringForColumn:@"ccolor"];
            item.name = [resultSet stringForColumn:@"cname"];
            item.titleColor = SSJ_CURRENT_THEME.mainColor;
            item.isMember = YES;
            [result addObject:item];
        }
        
        SSJDispatch_main_async_safe(^{
            success(result);
        });
    }];
}

@end
