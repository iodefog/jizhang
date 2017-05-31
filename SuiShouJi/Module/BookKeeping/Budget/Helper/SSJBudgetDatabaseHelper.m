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
#import "SSJDatePeriod.h"
#import "SSJUserTableManager.h"
#import "SSJBudgetBillTypeSelectionCellItem.h"
#import "SSJBudgetListCellItem.h"
#import "SSJReportFormsItem.h"
#import "SSJBudgetDetailHeaderViewItem.h"

NSString *const SSJBudgetModelKey = @"SSJBudgetModelKey";
NSString *const SSJBudgetDetailHeaderViewItemKey = @"SSJBudgetDetailHeaderViewItemKey";
NSString *const SSJBudgetListCellItemKey = @"SSJBudgetListCellItemKey";
NSString *const SSJBudgetIDKey = @"SSJBudgetIDKey";
NSString *const SSJBudgetPeriodKey = @"SSJBudgetPeriodKey";

NSString *const SSJBudgetConflictBillIdsKey = @"SSJBudgetConflictBillIdsKey";
NSString *const SSJBudgetConflictMajorBudgetMoneyKey = @"SSJBudgetConflictMajorBudgetMoneyKey";
NSString *const SSJBudgetConflictSecondaryBudgetMoneyKey = @"SSJBudgetConflictSecondaryBudgetMoneyKey";
NSString *const SSJBudgetConflictBudgetModelKey = @"SSJBudgetConflictBudgetModelKey";

@implementation SSJBudgetDatabaseHelper

+ (void)queryForBudgetCellItemListWithSuccess:(void(^)(NSArray<SSJBudgetListCellItem *> *result))success
                                      failure:(void (^)(NSError * _Nullable error))failure {
    
    NSString *currentDate = [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"];
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *booksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", SSJUSERID()];
        if (!booksId) {
            booksId = SSJUSERID();
        }
        FMResultSet *resultSet = [db executeQuery:@"select a.cbillid, b.cname, b.ccolor from bk_user_bill as a, bk_bill_type as b where a.cuserid = ? and a.cbillid = b.id and b.itype = 1 and b.istate <> 2", SSJUSERID()];
        if (!resultSet) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSMutableDictionary *mapping = [NSMutableDictionary dictionary];
        while ([resultSet next]) {
            NSString *billId = [resultSet stringForColumn:@"cbillid"];
            NSString *billName = [resultSet stringForColumn:@"cname"];
            NSString *billColor = [resultSet stringForColumn:@"ccolor"];
            [mapping setObject:@{@"name":billName, @"color":billColor} forKey:billId];
        }
        [resultSet close];
        
        FMResultSet *budgetResult = [db executeQuery:@"select ibid, itype, cbilltype, imoney, iremindmoney, csdate, cedate, istate, iremind, ihasremind, cbooksid, islastday from bk_user_budget where cuserid = ? and operatortype <> 2 and csdate <= ? and cedate >= ? and cbooksid = ? order by imoney desc", SSJUSERID(), currentDate, currentDate, booksId];
        
        if (!budgetResult) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSMutableArray *majorWeekList = [NSMutableArray array];
        NSMutableArray *secondaryWeekList = [NSMutableArray array];
        NSMutableArray *majorMonthList = [NSMutableArray array];
        NSMutableArray *secondaryMonthList = [NSMutableArray array];
        NSMutableArray *majorYearList = [NSMutableArray array];
        NSMutableArray *secondaryYearList = [NSMutableArray array];
        
        while ([budgetResult next]) {
            SSJBudgetModel *budget = [self budgetModelWithResultSet:budgetResult inDatabase:db];
            SSJBudgetListCellItem *cellItem = [SSJBudgetListCellItem cellItemWithBudgetModel:budget billTypeMapping:mapping];
            BOOL isAllBillType = [[budget.billIds firstObject] isEqualToString:SSJAllBillTypeId];
            switch (budget.type) {
                case SSJBudgetPeriodTypeWeek:
                    if (isAllBillType) {
                        [majorWeekList addObject:cellItem];
                        cellItem.title = @"周总预算";
                        cellItem.rowHeight = 320;
                    } else {
                        [secondaryWeekList addObject:cellItem];
                        if (secondaryWeekList.count == 1) {
                            cellItem.title = @"周分类预算";
                            cellItem.rowHeight = 208;
                        } else {
                            cellItem.rowHeight = 174;
                        }
                    }
                    
                    break;
                    
                case SSJBudgetPeriodTypeMonth:
                    if (isAllBillType) {
                        [majorMonthList addObject:cellItem];
                        cellItem.title = @"月总预算";
                        cellItem.rowHeight = 320;
                    } else {
                        [secondaryMonthList addObject:cellItem];
                        if (secondaryMonthList.count == 1) {
                            cellItem.title = @"月分类预算";
                            cellItem.rowHeight = 208;
                        } else {
                            cellItem.rowHeight = 174;
                        }
                    }
                    
                    break;
                    
                case SSJBudgetPeriodTypeYear:
                    if (isAllBillType) {
                        [majorYearList addObject:cellItem];
                        cellItem.title = @"年总预算";
                        cellItem.rowHeight = 320;
                    } else {
                        [secondaryYearList addObject:cellItem];
                        if (secondaryYearList.count == 1) {
                            cellItem.title = @"年分类预算";
                            cellItem.rowHeight = 208;
                        } else {
                            cellItem.rowHeight = 174;
                        }
                    }
                    
                    break;
            }
        }
        
        NSMutableArray *budgetList = [NSMutableArray array];
        if (majorWeekList.count) {
            [budgetList addObject:majorWeekList];
        }
        if (secondaryWeekList.count) {
            [budgetList addObject:secondaryWeekList];
        }
        if (majorMonthList.count) {
            [budgetList addObject:majorMonthList];
        }
        if (secondaryMonthList.count) {
            [budgetList addObject:secondaryMonthList];
        }
        if (majorYearList.count) {
            [budgetList addObject:majorYearList];
        }
        if (secondaryYearList.count) {
            [budgetList addObject:secondaryYearList];
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(budgetList);
            });
        }
    }];
}

+ (void)queryForCurrentBudgetListWithSuccess:(void(^)(NSArray<SSJBudgetModel *> *result))success failure:(void (^)(NSError *error))failure {
    
    NSString *currentDate = [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"];
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *booksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", SSJUSERID()];
        if (!booksId) {
            booksId = SSJUSERID();
        }
        FMResultSet *budgetResult = [db executeQuery:@"select ibid, itype, cbilltype, imoney, iremindmoney, csdate, cedate, istate, iremind, ihasremind, cbooksid, islastday from bk_user_budget where cuserid = ? and operatortype <> 2 and csdate <= ? and cedate >= ? and cbooksid = ? order by imoney desc", SSJUSERID(), currentDate, currentDate, booksId];
        
        if (!budgetResult) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSMutableArray *weekList = [NSMutableArray array];
        NSMutableArray *monthList = [NSMutableArray array];
        NSMutableArray *yearList = [NSMutableArray array];
        
        while ([budgetResult next]) {
            SSJBudgetModel *budget = [self budgetModelWithResultSet:budgetResult inDatabase:db];
            BOOL isAllBillType = [[budget.billIds firstObject] isEqualToString:SSJAllBillTypeId];
            
            switch (budget.type) {
                case SSJBudgetPeriodTypeWeek:
                    if (isAllBillType) {
                        [weekList insertObject:budget atIndex:0];
                    } else {
                        [weekList addObject:budget];
                    }
                    
                    break;
                    
                case SSJBudgetPeriodTypeMonth:
                    if (isAllBillType) {
                        [monthList insertObject:budget atIndex:0];
                    } else {
                        [monthList addObject:budget];
                    }
                    
                    break;
                    
                case SSJBudgetPeriodTypeYear:
                    if (isAllBillType) {
                        [yearList insertObject:budget atIndex:0];
                    } else {
                        [yearList addObject:budget];
                    }
                    
                    break;
            }
        }
        
        NSMutableArray *budgetList = [NSMutableArray array];
        [budgetList addObjectsFromArray:weekList];
        [budgetList addObjectsFromArray:monthList];
        [budgetList addObjectsFromArray:yearList];
        
        //        //  按照周、月、年的顺序排序
        //        [budgetList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        //            SSJBudgetModel *model1 = obj1;
        //            SSJBudgetModel *model2 = obj2;
        //            if (model1.type < model2.type) {
        //                return NSOrderedAscending;
        //            } else if (model1.type > model2.type) {
        //                return NSOrderedDescending;
        //            } else {
        //                return NSOrderedSame;
        //            }
        //        }];
        
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
    
    NSString *userid = SSJUSERID();
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        
        // 查询当前用户所有有效的支出类别
        FMResultSet *resultSet = [db executeQuery:@"select a.cbillid, b.cname, b.ccolor from bk_user_bill as a, bk_bill_type as b where a.cuserid = ? and a.cbillid = b.id and b.itype = 1 and b.istate <> 2", userid];
        if (!resultSet) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSMutableDictionary *mapping = [NSMutableDictionary dictionary];
        while ([resultSet next]) {
            NSString *billId = [resultSet stringForColumn:@"cbillid"];
            NSString *billName = [resultSet stringForColumn:@"cname"];
            NSString *billColor = [resultSet stringForColumn:@"ccolor"];
            [mapping setObject:@{SSJBudgetDetailBillInfoNameKey:billName,
                                 SSJBudgetDetailBillInfoColorKey:billColor} forKey:billId];
        }
        [resultSet close];
        
        // 查询用户的预算详情
        resultSet = [db executeQuery:@"select ibid, itype, cbilltype, imoney, iremindmoney, csdate, cedate, istate, iremind, ihasremind, cbooksid, islastday from bk_user_budget where ibid = ? and operatortype <> 2", ID];
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
        [resultSet close];
        
        SSJBudgetDetailHeaderViewItem *headerItem = [SSJBudgetDetailHeaderViewItem itemWithBudgetModel:budgetModel billMapping:mapping];
        
        //  查询预算范围内不同收支类型相应的金额、名称、图标、颜色
        NSMutableString *query = [NSMutableString stringWithFormat:@"select sum(a.imoney), b.ccoin, b.ccolor, b.cname, b.id from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.cuserid = '%@' and a.operatortype <> 2 and a.cbilldate >= '%@'and a.cbilldate <= '%@' and a.cbilldate <= datetime('now', 'localtime') and a.cbooksid = '%@' and b.itype = 1 and b.istate <> 2", userid, budgetModel.beginDate, budgetModel.endDate, budgetModel.booksId];
        
        if (![budgetModel.billIds isEqualToArray:@[SSJAllBillTypeId]]) {
            NSMutableArray *billIds = [NSMutableArray arrayWithCapacity:budgetModel.billIds.count];
            for (NSString *billId in budgetModel.billIds) {
                [billIds addObject:[NSString stringWithFormat:@"'%@'", billId]];
            }
            [query appendFormat:@" and a.ibillid in (%@)", [billIds componentsJoinedByString:@","]];
        }
        
        [query appendFormat:@" group by a.ibillid order by sum(a.imoney) desc"];
        
        resultSet = [db executeQuery:query];
        
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
        NSMutableArray *listItem = [NSMutableArray array];
        
        while ([resultSet next]) {
            double money = [resultSet doubleForColumn:@"sum(a.imoney)"];
            double scale = money / budgetModel.payMoney;
            if (scale >= 0.01) {
                amount += money;
                [moneyArr addObject:@(money)];
                
                SSJPercentCircleViewItem *circleItem = [[SSJPercentCircleViewItem alloc] init];
                circleItem.colorValue = [resultSet stringForColumn:@"ccolor"];
                circleItem.imageName = [resultSet stringForColumn:@"ccoin"];
                circleItem.additionalText = [NSString stringWithFormat:@"%.0f％", scale * 100];
                circleItem.additionalFont = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
                circleItem.imageBorderShowed = YES;
                [circleItemArr addObject:circleItem];
            }
            
            SSJReportFormsItem *item = [[SSJReportFormsItem alloc] init];
            item.ID = [resultSet stringForColumn:@"id"];
            item.imageName = [resultSet stringForColumn:@"ccoin"];
            item.name = [resultSet stringForColumn:@"cname"];
            item.colorValue = [resultSet stringForColumn:@"ccolor"];
            item.money = money;
            item.percentHiden = YES;
            [listItem addObject:item];
        }
        [resultSet close];
        
        for (int i = 0; i < circleItemArr.count; i ++) {
            SSJPercentCircleViewItem *circleItem = circleItemArr[i];
            circleItem.scale = [moneyArr[i] doubleValue] / amount;
        }
        headerItem.circleItems = circleItemArr;
        
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:2];
        
        if (budgetModel) {
            [result setObject:budgetModel forKey:SSJBudgetModelKey];
        }
        
        if (headerItem) {
            [result setObject:headerItem forKey:SSJBudgetDetailHeaderViewItemKey];
        }
        
        if (listItem) {
            [result setObject:listItem forKey:SSJBudgetListCellItemKey];
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(result);
            });
        }
    }];
}

+ (void)deleteBudgetWithID:(NSString *)ID success:(void(^)())success failure:(void (^)(NSError * _Nullable error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:@"update bk_user_budget set operatortype = 2, iversion = ?, cwritedate = ? where ibid = ?", @(SSJSyncVersion()), [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], ID]) {
            SSJDispatch_main_async_safe(^{
                if (success) {
                    success();
                }
            });
        } else {
            SSJDispatch_main_async_safe(^{
                if (failure) {
                    failure([db lastError]);
                }
            });
        }
    }];
}

+ (void)queryForBudgetIdListWithType:(SSJBudgetPeriodType)type billIds:(NSArray *)billIds success:(void(^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    
    NSString *userid = SSJUSERID();
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *booksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", userid];
        if (!booksId) {
            booksId = userid;
        }
        NSString *billIdStr = [self billTypeStringWithBillTypeArr:billIds];
        NSString *today = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"];
        
        FMResultSet *resultSet = [db executeQuery:@"select ibid, csdate, cedate from bk_user_budget where cuserid = ? and itype = ? and cbilltype = ? and operatortype <> 2 and csdate <= ? and cbooksid = ? order by csdate", userid, @(type), billIdStr, today, booksId];
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
        
        NSMutableArray *budgetIDs = [NSMutableArray array];
        NSMutableArray *budgetPeriods = [NSMutableArray array];
        
        NSString *dateFormat = nil;
        
        switch (type) {
            case SSJBudgetPeriodTypeWeek:
            case SSJBudgetPeriodTypeMonth:
                dateFormat = @"M.d";
                break;
                
            case SSJBudgetPeriodTypeYear:
                dateFormat = @"yyyy.M.d";
                break;
        }
        
        while ([resultSet next]) {
            NSString *budgetId = [resultSet stringForColumn:@"ibid"];
            NSString *beginDateStr = [[resultSet stringForColumn:@"csdate"] ssj_dateStringFromFormat:@"yyyy-MM-dd" toFormat:dateFormat];
            NSString *endDateStr = [[resultSet stringForColumn:@"cedate"] ssj_dateStringFromFormat:@"yyyy-MM-dd" toFormat:dateFormat];
            
            [budgetIDs addObject:budgetId ?: @""];
            [budgetPeriods addObject:[NSString stringWithFormat:@"%@~%@", beginDateStr ?: @"", endDateStr ?: @""]];
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(@{SSJBudgetIDKey:budgetIDs,
                          SSJBudgetPeriodKey:budgetPeriods});
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
    NSString *userID = SSJUSERID();
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSMutableDictionary *map = [NSMutableDictionary dictionary];
        FMResultSet *resultSet = [db executeQuery:@"select a.cbillid, b.cname from bk_user_bill as a, bk_bill_type as b where a.cuserid = ? and a.cbillid = b.id and b.itype = 1 and b.istate <> 2", userID];
        if (!resultSet) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        while ([resultSet next]) {
            [map setObject:[resultSet stringForColumn:@"cname"] forKey:[resultSet stringForColumn:@"cbillid"]];
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(map);
            });
        }
    }];
}

+ (void)checkIfConflictBudgetModel:(SSJBudgetModel *)model success:(void(^)(int code, NSDictionary *additionInfo))success failure:(void (^)(NSError *error))failure {
    
    if (![model isKindOfClass:[SSJBudgetModel class]]) {
        SSJPRINT(@"model is not kind of class SSJBudgetModel");
        NSError *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"model is not kind of class SSJBudgetModel"}];
        if (failure) {
            failure(error);
        }
        return;
    }
    
    NSString *userId = SSJUSERID();
    NSString *billIds = [self billTypeStringWithBillTypeArr:model.billIds];
    
    if (!billIds.length) {
        SSJPRINT(@"预算类别id为空");
        NSError *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"预算类别id为空"}];
        if (failure) {
            failure(error);
        }
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        // 检测相同类型、账本、类别预算有没有周期冲突
        BOOL isConficted = [db boolForQuery:@"select count(*) from bk_user_budget where cuserid = ? and operatortype <> 2 and ibid <> ? and itype = ? and csdate <= date('now', 'localtime') and cedate >= date('now', 'localtime') and cbooksid = ? and cbilltype = ?", userId, model.ID, @(model.type), model.booksId, billIds];
        
        if (isConficted) {
            if (success) {
                SSJDispatch_main_async_safe(^{
                    success(1, nil);
                });
            }
            return;
        }
        
        if ([billIds isEqualToString:SSJAllBillTypeId]) {
            
            // 检测所有相同类型（周、月、年）、账本、周期分预算总额是否大于当前设置的总预算金额
            double amount = [db doubleForQuery:@"select sum(imoney) from bk_user_budget where cuserid = ? and operatortype <> 2 and ibid <> ? and itype = ? and cbooksid = ? and csdate = ? and cedate = ? and cbilltype <> 'all'", userId, model.ID, @(model.type), model.booksId, model.beginDate, model.endDate];
            if (model.budgetMoney < amount) {
                if (success) {
                    SSJDispatch_main_async_safe(^{
                        success(3, @{SSJBudgetConflictMajorBudgetMoneyKey:@(model.budgetMoney),
                                     SSJBudgetConflictSecondaryBudgetMoneyKey:@(amount)});
                    });
                }
                return;
            }
        } else {
            
            // 检测相同类型（周、月、年）、账本、周期的分预算有没有类别冲突
            FMResultSet *resultSet = [db executeQuery:@"select cbilltype from bk_user_budget where cuserid = ? and operatortype <> 2 and ibid <> ? and itype = ? and cbooksid = ? and csdate = ? and cedate = ? and cbilltype <> 'all'", userId, model.ID, @(model.type), model.booksId, model.beginDate, model.endDate];
            
            if (!resultSet) {
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
            
            NSMutableArray *conflictBillIds = [NSMutableArray array];
            while ([resultSet next]) {
                NSArray *billIds = [[resultSet stringForColumn:@"cbilltype"] componentsSeparatedByString:@","];
                for (NSString *billId in model.billIds) {
                    if ([billIds containsObject:billId]) {
                        isConficted = YES;
                        if (![conflictBillIds containsObject:billId]) {
                            [conflictBillIds addObject:billId];
                        }
                        break;
                    }
                }
            }
            [resultSet close];
            
            if (isConficted) {
                if (success) {
                    SSJDispatch_main_async_safe(^{
                        success(2, @{SSJBudgetConflictBillIdsKey:conflictBillIds});
                    });
                }
                return;
            }
            
            // 检测设置的分预算金额是否大于相同类型（周、月、年）、账本、周期的总预算金额额
            resultSet = [db executeQuery:@"select * from bk_user_budget where cuserid = ? and operatortype <> 2 and ibid <> ? and itype = ? and cbooksid = ? and csdate = ? and cedate = ? and cbilltype = 'all'", userId, model.ID, @(model.type), model.booksId, model.beginDate, model.endDate];
            
            if (!resultSet) {
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
            
            SSJBudgetModel *budgetModel = nil;
            while ([resultSet next]) {
                budgetModel = [self budgetModelWithResultSet:resultSet inDatabase:db];
            }
            [resultSet close];
            
            if (budgetModel) {
                double amount = [db doubleForQuery:@"select sum(imoney) from bk_user_budget where cuserid = ? and operatortype <> 2 and ibid <> ? and itype = ? and cbooksid = ? and csdate = ? and cedate = ? and cbilltype <> 'all'", userId, model.ID, @(model.type), model.booksId, model.beginDate, model.endDate];
                amount += model.budgetMoney;
                
                if (amount > budgetModel.budgetMoney) {
                    if (success) {
                        SSJDispatch_main_async_safe(^{
                            success(4, @{SSJBudgetConflictMajorBudgetMoneyKey:@(budgetModel.budgetMoney),
                                         SSJBudgetConflictSecondaryBudgetMoneyKey:@(amount),
                                         SSJBudgetConflictBudgetModelKey:budgetModel});
                        });
                    }
                    return;
                }
            }
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(0, nil);
            });
        }
    }];
}

+ (void)saveBudgetModel:(SSJBudgetModel *)model success:(void(^)())success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSError *error = nil;
        if (![self saveBudgetModel:model inDatabase:db error:&error]) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure(error);
                });
            }
            return;
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
    }];
}

+ (void)saveBudgetModels:(NSArray <SSJBudgetModel *>*)models
                 success:(void(^)())success
                 failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        for (SSJBudgetModel *model in models) {
            NSError *error = nil;
            if (![self saveBudgetModel:model inDatabase:db error:&error]) {
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure(error);
                    });
                }
                return;
            }
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
    }];
}

+ (BOOL)saveBudgetModel:(SSJBudgetModel *)model inDatabase:(FMDatabase *)db error:(NSError **)error {
    if (![model isKindOfClass:[SSJBudgetModel class]]) {
        SSJPRINT(@"model is not kind of class SSJBudgetModel");
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"model is not kind of class SSJBudgetModel"}];
        }
        return NO;
    }
    
    BOOL isExisted = [db boolForQuery:@"select count(*) from bk_user_budget where ibid = ?", model.ID];
    if (isExisted) {
        NSMutableDictionary *parametersInfo = [[model mj_keyValuesWithIgnoredKeys:@[@"payMoney", @"billIds", @"isDeleted"]] mutableCopy];
        [parametersInfo setObject:[self billTypeStringWithBillTypeArr:model.billIds] forKey:@"cbilltype"];
        [parametersInfo setObject:[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] forKey:@"cwritedate"];
        [parametersInfo setObject:@(SSJSyncVersion()) forKey:@"iversion"];
        
        //  如果此记录没有被删除，就保存
        if ([db executeUpdate:@"update bk_user_budget set itype = :type, imoney = :budgetMoney, iremindmoney = :remindMoney, csdate = :beginDate, cedate = :endDate, istate = :isAutoContinued, cbilltype = :cbilltype, iremind = :isRemind, ihasremind = :isAlreadyReminded, cwritedate = :cwritedate, iversion = :iversion, operatortype = 1, cbooksid = :booksId, islastday = :isLastDay where ibid = :ID and operatortype <> 2" withParameterDictionary:parametersInfo]) {
            
            return YES;
            
        } else {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
        
    } else {
        NSMutableDictionary *parametersInfo = [[model mj_keyValuesWithIgnoredKeys:@[@"payMoney", @"billIds"]] mutableCopy];
        [parametersInfo setObject:[self billTypeStringWithBillTypeArr:model.billIds] forKey:@"cbilltype"];
        [parametersInfo setObject:[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] forKey:@"ccadddate"];
        [parametersInfo setObject:[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] forKey:@"cwritedate"];
        [parametersInfo setObject:@(SSJSyncVersion()) forKey:@"iversion"];
        
        if ([db executeUpdate:@"insert into bk_user_budget (ibid, cuserid, itype, imoney, iremindmoney, csdate, cedate, istate, ccadddate, cbilltype, iremind, ihasremind, cwritedate, iversion, operatortype, cbooksid, islastday) values (:ID, :userId, :type, :budgetMoney, :remindMoney, :beginDate, :endDate, :isAutoContinued, :ccadddate, :cbilltype, :isRemind, :isAlreadyReminded, :cwritedate, :iversion, 0, :booksId, :isLastDay)" withParameterDictionary:parametersInfo]) {
            
            return YES;
            
        } else {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
    }
}

+ (void)queryBookNameForBookId:(NSString *)ID success:(void(^)(NSString *bookName))success failure:(void(^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *bookName = [db stringForQuery:@"select cbooksname from bk_books_type where cbooksid = ? and cuserid = ?", ID, SSJUSERID()];
        if (success) {
            SSJDispatchMainAsync(^{
                success(bookName);
            });
        }
    }];
}

+ (SSJBudgetModel *)budgetModelWithResultSet:(FMResultSet *)set inDatabase:(FMDatabase *)db {
    SSJBudgetModel *budgetModel = [[SSJBudgetModel alloc] init];
    budgetModel.ID = [set stringForColumn:@"ibid"];
    budgetModel.type = [set intForColumn:@"itype"];
    budgetModel.booksId = [set stringForColumn:@"cbooksid"];
    budgetModel.billIds = [[set stringForColumn:@"cbilltype"] componentsSeparatedByString:@","];
    budgetModel.budgetMoney = [set doubleForColumn:@"imoney"];
    budgetModel.remindMoney = [set doubleForColumn:@"iremindmoney"];
    budgetModel.beginDate = [set stringForColumn:@"csdate"];
    budgetModel.endDate = [set stringForColumn:@"cedate"];
    budgetModel.isAutoContinued = [set boolForColumn:@"istate"];
    budgetModel.isRemind = [set boolForColumn:@"iremind"];
    budgetModel.isAlreadyReminded = [set boolForColumn:@"ihasremind"];
    budgetModel.isLastDay = [set boolForColumn:@"islastday"];
    
    // 当前账本所有有效支出流水的总金额
    NSMutableString *sqlStr = [[NSString stringWithFormat:@"select sum(a.imoney) from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.cuserid = '%@' and a.operatortype <> 2 and a.cbilldate >= '%@' and a.cbilldate <= '%@' and a.cbilldate <= datetime('now', 'localtime') and a.cbooksid = '%@' and b.istate <> 2 and b.itype = 1", SSJUSERID(), budgetModel.beginDate, budgetModel.endDate, budgetModel.booksId] mutableCopy];
    
    if (![[budgetModel.billIds firstObject] isEqualToString:SSJAllBillTypeId]) {
        NSMutableArray *tmpBillIds = [NSMutableArray arrayWithCapacity:budgetModel.billIds.count];
        for (NSString *billId in budgetModel.billIds) {
            [tmpBillIds addObject:[NSString stringWithFormat:@"'%@'", billId]];
        }
        NSString *billIdStr = [tmpBillIds componentsJoinedByString:@","];
        [sqlStr appendFormat:@" and ibillid in (%@)", billIdStr];
    }
    budgetModel.payMoney = [db doubleForQuery:sqlStr];
    
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
//    NSArray *sortArr = [billTypeArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//        if ([obj1 integerValue] < [obj2 integerValue]) {
//            return NSOrderedAscending;
//        } else if ([obj1 integerValue] > [obj2 integerValue]) {
//            return NSOrderedDescending;
//        } else {
//            return NSOrderedSame;
//        }
//    }];
    NSArray *sortArr = [billTypeArr sortedArrayUsingSelector:@selector(compare:)];
    return [sortArr componentsJoinedByString:@","];
}

+ (void)queryBudgetBillTypeSelectionItemListWithSelectedTypeList:(NSArray *)typeList
                                                         booksId:(NSString *)booksId
                                                         success:(void(^)(NSArray <SSJBudgetBillTypeSelectionCellItem *>*list))success
                                                         failure:(void(^)(NSError *error))failure {
    NSString *userID = SSJUSERID();
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *tBooksId = booksId;
        if (!tBooksId) {
            tBooksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", SSJUSERID()];
            tBooksId = tBooksId ?: SSJUSERID();
        }
        // 查询所有默认支出类别
        FMResultSet *resultSet = [db executeQuery:@"select bt.cname, bt.ccolor, bt.ccoin, ub.cwritedate, bt.id from BK_BILL_TYPE bt, BK_USER_BILL ub where ub.istate = 1 and bt.itype = 1 and bt.id = ub.cbillid and ub.cuserid = ? and ub.cbooksid = ? and (bt.cparent <> 'root' or bt.cparent is null) order by ub.iorder, ub.cwritedate, bt.id", userID, tBooksId];
        
        if (!resultSet) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSMutableArray *list = [NSMutableArray array];
        
        while ([resultSet next]) {
            SSJBudgetBillTypeSelectionCellItem *item = [[SSJBudgetBillTypeSelectionCellItem alloc] init];
            item.billID = [resultSet stringForColumn:@"id"];
            item.leftImage = [resultSet stringForColumn:@"ccoin"];
            item.billTypeName = [resultSet stringForColumn:@"cname"];
            item.billTypeColor = [resultSet stringForColumn:@"ccolor"];
            item.canSelect = YES;
            item.selected = [typeList containsObject:item.billID] || [[typeList firstObject] isEqualToString:SSJAllBillTypeId];
            [list addObject:item];
        }
        [resultSet close];
        
        if (list.count > 0) {
            SSJBudgetBillTypeSelectionCellItem *selectAllItem = [[SSJBudgetBillTypeSelectionCellItem alloc] init];
            selectAllItem.billID = SSJAllBillTypeId;
            selectAllItem.billTypeName = @"全选";
            selectAllItem.canSelect = YES;
            selectAllItem.selected = [[typeList firstObject] isEqualToString:SSJAllBillTypeId];
            [list insertObject:selectAllItem atIndex:0];
        }
        
        SSJBudgetBillTypeSelectionCellItem *addItem = [[SSJBudgetBillTypeSelectionCellItem alloc] init];
        addItem.leftImage = @"border_add";
        addItem.billTypeName = @"添加类别";
        addItem.billTypeColor = SSJ_CURRENT_THEME.secondaryColor;
        addItem.canSelect = NO;
        [list addObject:addItem];
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(list);
            });
        }
    }];
}

@end
