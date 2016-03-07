//
//  SSJBudgetHelper.m
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetDatabaseHelper.h"
#import "SSJDatabaseQueue.h"
#import "SSJPercentCircleViewItem.h"
#import "MJExtension.h"
#import "SSJBudgetCalendarHelper.h"

NSString *const SSJBudgetModelKey = @"SSJBudgetModelKey";
NSString *const SSJBudgetCircleItemsKey = @"SSJBudgetCircleItemsKey";
NSString *const SSJBudgetMonthIDKey = @"SSJBudgetMonthIDKey";
NSString *const SSJBudgetMonthTitleKey = @"SSJBudgetMonthTitleKey";

@implementation SSJBudgetDatabaseHelper

+ (void)queryForCurrentBudgetListWithSuccess:(void(^)(NSArray<SSJBudgetModel *> *result))success failure:(void (^)(NSError *error))failure {
    NSString *currentDate = [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"];
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSMutableArray *budgetList = [NSMutableArray array];
        FMResultSet *budgetResult = [db executeQuery:@"select ibid, itype, cbilltype, imoney, iremindmoney, csdate, cedate, istate, iremind from bk_user_budget where cuserid = ? and operatortype <> 2 and csdate <= ? and cedate >= ?", SSJUSERID(), currentDate, currentDate];
        
        if (!budgetResult) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        while ([budgetResult next]) {
            [budgetList addObject:[self budgetModelWithResultSet:budgetResult inDatabase:db]];
        }
        
        //  按照周、月、年的顺序排序
        [budgetList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            SSJBudgetModel *model1 = obj1;
            SSJBudgetModel *model2 = obj2;
            if (model1.type < model2.type) {
                return NSOrderedAscending;
            } else if (model1.type > model2.type) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }];
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(budgetList);
            });
        }
    }];
}

+ (void)queryForBudgetDetailWithID:(NSString *)ID success:(void(^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    if (!ID || !ID.length) {
        SSJPRINT(@">>> SSJ warning:budget is nil or empty");
        NSError *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"budget is nil or empty"}];
        if (failure) {
            failure(error);
        }
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select ibid, itype, cbilltype, imoney, iremindmoney, csdate, cedate, istate, iremind from bk_user_budget where ibid = ?", ID];
        if (!resultSet) {
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        
        SSJBudgetModel *budgetModel = nil;
        while ([resultSet next]) {
            budgetModel = [self budgetModelWithResultSet:resultSet inDatabase:db];
        }
        
        //  查询不同收支类型相应的金额、名称、图标、颜色
        NSString *query = [NSString stringWithFormat:@"select sum(a.imoney), b.ccoin, b.ccolor from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.cuserid = ? and a.operatortype <> 2 and a.cbilldate >= ? and a.cbilldate <= ? and b.id in %@ group by a.ibillid", [self queryStringForBillIds:budgetModel.billIds]];
        resultSet = [db executeQuery:query, SSJUSERID(), budgetModel.beginDate, budgetModel.endDate];
        
        if (!resultSet) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        double amount = 0;
        NSMutableArray *circleItemArr = [NSMutableArray array];
        NSMutableArray *moneyArr = [NSMutableArray array];
        while ([resultSet next]) {
            SSJPercentCircleViewItem *circleItem = [[SSJPercentCircleViewItem alloc] init];
            circleItem.colorValue = [resultSet stringForColumn:@"ccolor"];
            circleItem.imageName = [resultSet stringForColumn:@"ccoin"];
            circleItem.additionalText = [NSString stringWithFormat:@"%.0f％", circleItem.scale * 100];
            
            double money = [resultSet doubleForColumn:@"sum(a.imoney)"];
            double scale = money / budgetModel.payMoney;
            if (scale >= 0.01) {
                amount += money;
                [moneyArr addObject:@(money)];
                [circleItemArr addObject:circleItem];
            }
        }
        
        for (int i = 0; i < circleItemArr.count; i ++) {
            SSJPercentCircleViewItem *circleItem = circleItemArr[i];
            circleItem.scale = [moneyArr[i] doubleValue] / amount;
        }
        
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:2];
        [result setObject:budgetModel forKey:SSJBudgetModelKey];
        [result setObject:circleItemArr forKey:SSJBudgetCircleItemsKey];
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(result);
            });
        }
    }];
}

+ (void)queryForMonthBudgetIdListWithSuccess:(void(^)(NSArray<NSDictionary *> *result))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select ibid, csdate from bk_user_budget where cuserid = ? and itype = 1", SSJUSERID()];
        if (!resultSet) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        
        NSMutableArray *result = [NSMutableArray array];
        while ([resultSet next]) {
            NSString *budgetId = [resultSet stringForColumn:@"ibid"];
            
            NSString *beginDateStr = [resultSet stringForColumn:@"csdate"];
            NSDate *beginDate = [formatter dateFromString:beginDateStr];
            NSDateComponents *dateComponent = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:beginDate];
            NSString *title = [self titleForMonth:[dateComponent month]];
            
            [result addObject:@{SSJBudgetMonthIDKey:(budgetId ?: @""),
                                SSJBudgetMonthTitleKey:(title ?: @"")}];
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success([result copy]);
            });
        }
    }];
}

+ (NSString *)titleForMonth:(NSInteger)month {
    switch (month) {
        case 1:     return @"1月预算";
        case 2:     return @"2月预算";
        case 3:     return @"3月预算";
        case 4:     return @"4月预算";
        case 5:     return @"5月预算";
        case 6:     return @"6月预算";
        case 7:     return @"7月预算";
        case 8:     return @"8月预算";
        case 9:     return @"9月预算";
        case 10:    return @"10月预算";
        case 11:    return @"11月预算";
        case 12:    return @"12月预算";
            
        default:    return nil;
    }
}

+ (void)queryBillTypeMapWithSuccess:(void(^)(NSDictionary *billTypeMap))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSMutableDictionary *map = [NSMutableDictionary dictionary];
        FMResultSet *resultSet = [db executeQuery:@"select id, cname from bk_bill_type where itype = 1 and istate <> 2"];
        if (!resultSet) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        while ([resultSet next]) {
            [map setObject:[resultSet stringForColumn:@"cname"] forKey:[resultSet stringForColumn:@"id"]];
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(map);
            });
        }
    }];
}

+ (void)checkIfConflictBudgetModel:(SSJBudgetModel *)model success:(void(^)(BOOL isConficted))success failure:(void (^)(NSError *error))failure {
    if (![model isKindOfClass:[SSJBudgetModel class]]) {
        SSJPRINT(@"model is not kind of class SSJBudgetModel");
        NSError *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"model is not kind of class SSJBudgetModel"}];
        if (failure) {
            failure(error);
        }
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        BOOL isConficted = [db boolForQuery:@"select count(*) from bk_user_budget where cuserid = ? and operatortype <> 2 and ibid <> ? and cbilltype = ? and itype = ? and csdate = ?", SSJUSERID(), model.ID, [self billTypeStringWithBillTypeArr:model.billIds], @(model.type), model.beginDate];
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(isConficted);
            });
        }
    }];
}

+ (void)saveBudgetModel:(SSJBudgetModel *)model success:(void(^)())success failure:(void (^)(NSError *error))failure {
    if (![model isKindOfClass:[SSJBudgetModel class]]) {
        SSJPRINT(@"model is not kind of class SSJBudgetModel");
        NSError *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"model is not kind of class SSJBudgetModel"}];
        if (failure) {
            failure(error);
        }
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        
        BOOL isExisted = [db boolForQuery:@"select count(*) from bk_user_budget where ibid = ?", model.ID];
        if (isExisted) {
            NSMutableDictionary *parametersInfo = [[model mj_keyValuesWithIgnoredKeys:@[@"payMoney", @"billIds"]] mutableCopy];
            [parametersInfo setObject:[self billTypeStringWithBillTypeArr:model.billIds] forKey:@"cbilltype"];
            [parametersInfo setObject:[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] forKey:@"cwritedate"];
            [parametersInfo setObject:@(SSJSyncVersion()) forKey:@"iversion"];
            
            if ([db executeUpdate:@"update bk_user_budget set itype = :type, imoney = :budgetMoney, iremindmoney = :remindMoney, csdate = :beginDate, cedate = :endDate, istate = :isAutoContinued, cbilltype = :cbilltype, iremind = :isRemind, cwritedate = :cwritedate, iversion = :iversion, operatortype = 1 where ibid = :ID" withParameterDictionary:parametersInfo]) {
                if (success) {
                    SSJDispatch_main_async_safe(^{
                        success();
                    });
                }
            } else {
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
            }
        } else {
            NSMutableDictionary *parametersInfo = [[model mj_keyValuesWithIgnoredKeys:@[@"payMoney", @"billIds"]] mutableCopy];
            [parametersInfo setObject:[self billTypeStringWithBillTypeArr:model.billIds] forKey:@"cbilltype"];
            [parametersInfo setObject:[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] forKey:@"ccadddate"];
            [parametersInfo setObject:[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] forKey:@"cwritedate"];
            [parametersInfo setObject:@(SSJSyncVersion()) forKey:@"iversion"];
            
            if ([db executeUpdate:@"insert into bk_user_budget (ibid, cuserid, itype, imoney, iremindmoney, csdate, cedate, istate, ccadddate, cbilltype, iremind, cwritedate, iversion, operatortype) values (:ID, :userId, :type, :budgetMoney, :remindMoney, :beginDate, :endDate, :isAutoContinued, :ccadddate, :cbilltype, :isRemind, :cwritedate, :iversion, 0)" withParameterDictionary:parametersInfo]) {
                if (success) {
                    SSJDispatch_main_async_safe(^{
                        success();
                    });
                }
            } else {
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
            }
        }
    }];
}

//+ (void)supplementBudgetRecordWithSuccess:(void(^)())success
//                                  failure:(void (^)(NSError *error))failure {
//    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
//        FMResultSet *resultSet = [db executeQuery:@"select itype, imoney, iremindmoney, cbilltype, iremind, max(cedate) from bk_user_budget where cuserid = ? and operatortype <> 2 and istate = 1 group by itype, cbilltype", SSJUSERID()];
//        if (!resultSet) {
//            if (failure) {
//                SSJDispatch_main_async_safe(^{
//                    failure([db lastError]);
//                });
//            }
//            return;
//        }
//        
//        BOOL successfull = YES;
//        
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateFormat:@"yyyy-MM-dd"];
//
//        while ([resultSet next]) {
//             NSDate *recentEndDate = [formatter dateFromString:[resultSet stringForColumn:@"max(cedate)"]];
//            
//            if ([recentEndDate compare:[NSDate date]] == NSOrderedAscending) {
//                
//                int itype = [resultSet intForColumn:@"itype"];
//                NSString *imoney = [resultSet stringForColumn:@"imoney"];
//                NSString *iremindmoney = [resultSet stringForColumn:@"iremindmoney"];
//                NSString *cbilltype = [resultSet stringForColumn:@"cbilltype"];
//                int iremind = [resultSet intForColumn:@"iremind"];
//                NSString *currentDate = [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
//                
//                NSArray *periodArr = [self periodArrayForType:itype sinceDate:recentEndDate];
//                
//                for (NSDictionary *periodInfo in periodArr) {
//                    NSString *beginDate = periodInfo[kBudgetPeriodBeginDateKey];
//                    NSString *endDate = periodInfo[kBudgetPeriodEndDateKey];
//                    
//                    successfull = [db executeUpdate:@"insert into bk_user_budget (ibid, cuserid, itype, imoney, iremindmoney, csdate, cedate, istate, ccadddate, cbilltype, iremind, cwritedate, iversion, operatortype) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)", SSJUUID(), SSJUSERID(), @(itype), imoney, iremindmoney, beginDate, endDate, @1, currentDate, cbilltype, @(iremind), currentDate, @(SSJSyncVersion())];
//                }
//            }
//        }
//        
//        if (successfull) {
//            if (success) {
//                SSJDispatch_main_async_safe(^{
//                    success();
//                });
//            }
//        } else {
//            if (failure) {
//                SSJDispatch_main_async_safe(^{
//                    failure([db lastError]);
//                });
//            }
//        }
//        
//    }];
//}

//+ (NSArray *)periodArrayForType:(int)type sinceDate:(NSDate *)date {
//    NSCalendarUnit unit = NSCalendarUnitWeekOfMonth;
//    switch (type) {
//        case 0:
//            unit = NSCalendarUnitWeekOfMonth;
//            break;
//        case 1:
//            unit = NSCalendarUnitMonth;
//            break;
//        case 2:
//            unit = NSCalendarUnitYear;
//            break;
//    }
//    
//    NSMutableArray *periodArr = [NSMutableArray array];
//    
//    NSDate *tDate = [NSDate dateWithTimeInterval:(24 * 60 * 60) sinceDate:date];
//    NSDictionary *period = [SSJBudgetCalendarHelper getPeriodInfoWithCalendarUnit:unit ForDate:tDate];
//    NSDate *beginDate = period[kBudgetPeriodBeginDateKey];
//    NSDate *endDate = period[SSJBudgetPeriodEndDateKey];
//    
//    if ([endDate compare:[NSDate date]] == NSOrderedAscending) {
//        NSArray *anotherPeriod = [self periodArrayForType:type sinceDate:endDate];
//        [periodArr addObjectsFromArray:anotherPeriod];
//    }
//    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    formatter.timeZone = [NSTimeZone systemTimeZone];
//    [formatter setDateFormat:@"yyyy-MM-dd"];
//    
//    NSString *beginDateStr = [formatter stringFromDate:beginDate];
//    NSString *endDateStr = [formatter stringFromDate:endDate];
//    
//    [periodArr addObject:@{kBudgetPeriodBeginDateKey:beginDateStr,
//                           SSJBudgetPeriodEndDateKey:endDateStr}];
//    
//    return periodArr;
//}

+ (SSJBudgetModel *)budgetModelWithResultSet:(FMResultSet *)set inDatabase:(FMDatabase *)db {
    SSJBudgetModel *budgetModel = [[SSJBudgetModel alloc] init];
    budgetModel.ID = [set stringForColumn:@"ibid"];
    budgetModel.type = [set intForColumn:@"itype"];
    budgetModel.billIds = [[set stringForColumn:@"cbilltype"] componentsSeparatedByString:@","];
    budgetModel.budgetMoney = [set doubleForColumn:@"imoney"];
    budgetModel.remindMoney = [set doubleForColumn:@"iremindmoney"];
    budgetModel.beginDate = [set stringForColumn:@"csdate"];
    budgetModel.endDate = [set stringForColumn:@"cedate"];
    budgetModel.isAutoContinued = [set boolForColumn:@"istate"];
    budgetModel.isRemind = [set boolForColumn:@"iremind"];
    NSString *query = [NSString stringWithFormat:@"select sum(a.imoney) from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.cuserid = ? and a.operatortype <> 2 and a.cbilldate >= ? and a.cbilldate <= ? and b.id in %@", [self queryStringForBillIds:budgetModel.billIds]];
    budgetModel.payMoney = [db doubleForQuery:query, SSJUSERID(), budgetModel.beginDate, budgetModel.endDate];
    
    return budgetModel;
}

+ (NSString *)queryStringForBillIds:(NSArray *)billIds {
    NSMutableArray *tBillIdArr = [NSMutableArray arrayWithCapacity:billIds.count];
    for (NSString *billId in billIds) {
        NSString *tBillId = [NSString stringWithFormat:@"'%@'", billId];
        [tBillIdArr addObject:tBillId];
    }
    return [NSString stringWithFormat:@"(%@)", [tBillIdArr componentsJoinedByString:@","]];
}

+ (NSString *)billTypeStringWithBillTypeArr:(NSArray *)billTypeArr {
    NSArray *sortArr = [billTypeArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return NSOrderedAscending;
        } else if ([obj1 integerValue] > [obj2 integerValue]) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    return [sortArr componentsJoinedByString:@","];
}

@end
