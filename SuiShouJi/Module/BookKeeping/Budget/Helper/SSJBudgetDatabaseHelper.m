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

NSString *const SSJBudgetModelKey = @"SSJBudgetModelKey";
NSString *const SSJBudgetCircleItemsKey = @"SSJBudgetCircleItemsKey";

@implementation SSJBudgetDatabaseHelper

+ (void)queryForCurrentBudgetListWithSuccess:(void(^)(NSArray<SSJBudgetModel *> *result))success failure:(void (^)(NSError *error))failure {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDate = [formatter stringFromDate:[NSDate date]];
    
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
        FMResultSet *resultSet = [db executeQuery:@"select from ibid, itype, cbilltype, imoney, iremindmoney, csdate, cedate, istate from bk_user_budget where ibid = ?", ID];
        if (!resultSet) {
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        
        SSJBudgetModel *budgetModel = [self budgetModelWithResultSet:resultSet inDatabase:db];
        
        //  查询不同收支类型相应的金额、名称、图标、颜色
//        result = [db executeQuery:@"select a.IBILLID, a.AMOUNT, b.CNAME, b.CCOIN, b.CCOLOR from (select sum(IMONEY) as AMOUNT, IBILLID from BK_USER_CHARGE where CBILLDATE like ? and CUSERID = ? and OPERATORTYPE <> 2 and (IBILLID like '1___' or IBILLID like '2___') group by IBILLID) as a, BK_BILL_TYPE as b where a.IBILLID = b.ID and b.ITYPE = ?", billDate, SSJUSERID(), incomeOrPayType];
        
        resultSet = [db executeQuery:@"select sum(a.imoney), b.ccoin, b.ccolor from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.cuserid = ? and a.operatortype <> 2 and a.cbilldate >= ? and a.cbilldate <= ? and b.id in (?) group by a.ibillid", SSJUSERID(), budgetModel.beginDate, budgetModel.endDate, [self queryStringForBillIds:budgetModel.billIds]];
        
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
            
            double money = [resultSet doubleForColumn:@"a.imoney"];
            double scale = money / budgetModel.payMoney;
            if (scale >= 0.01) {
                amount += money;
                [moneyArr addObject:@(money)];
                [circleItemArr addObject:circleItemArr];
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

+ (void)queryForMonthBudgetIdListWithSuccess:(void(^)(NSArray<NSString *> *result))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select ibid from bk_user_budget where cuserid = ? and itype = 2"];
        if (!resultSet) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSMutableArray *result = [NSMutableArray array];
        while ([resultSet next]) {
            [result addObject:[resultSet stringForColumn:@"ibid"]];
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(result);
            });
        }
    }];
}

+ (void)queryBillTypeMapWithSuccess:(void(^)(NSDictionary *billTypeMap))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSMutableDictionary *map = [NSMutableDictionary dictionary];
        FMResultSet *resultSet = [db executeQuery:@"select id, cname from bk_bill_type"];
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
        BOOL isConficted = [db boolForQuery:@"select count(*) from bk_user_budget where cuserid = ? and operatortype <> 2 and ibid <> ? and cbilltype = ? and itype = ? and csdate = ?", SSJUSERID(), model.ID, model.billIds, @(model.type), model.beginDate];
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
        
        [SSJBudgetModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
            return @{@"ID":@"ibid",
                     @"userId":@"cuserid",
                     @"type":@"itype",
                     @"budgetMoney":@"imoney",
                     @"remindMoney":@"iremindmoney",
                     @"beginDate":@"csdate",
                     @"endDate":@"cedate",
                     @"isAutoContinued":@"istate",
                     @"isRemind":@"iremind"};
        }];
        
        NSArray *billTypeArr = [model.billIds sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            if ([obj1 integerValue] < [obj2 integerValue]) {
                return NSOrderedAscending;
            } else if ([obj1 integerValue] > [obj2 integerValue]) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }];
        NSString *billTypes = [billTypeArr componentsJoinedByString:@","];
        
        NSMutableDictionary *parametersInfo = [[model mj_keyValues] mutableCopy];
        [parametersInfo setObject:billTypes forKey:@"cbilltype"];
        [parametersInfo setObject:[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] forKey:@"ccadddate"];
        [parametersInfo setObject:[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] forKey:@"cwritedate"];
        [parametersInfo setObject:@(SSJSyncVersion()) forKey:@"iversion"];
        
        BOOL isExisted = [db boolForQuery:@"select count(*) from bk_user_budget where ibid = ?", model.ID];
        if (isExisted) {
            if ([db executeUpdate:@"update bk_user_budget set itype = ?, imoney = ?, iremindmoney = ?, csdate = ?, cedate = ?, istate = ?, cbilltype = ?, cwritedate = ?, iversion = ?, operatortype = 1" withParameterDictionary:parametersInfo]) {
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
            if ([db executeUpdate:@"insert into bk_user_budget (ibid, cuserid, itype, imoney, iremindmoney, csdate, cedate, istate, cbilltype, ccadddate, cwritedate, iversion, operatortype) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)" withParameterDictionary:parametersInfo]) {
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
    budgetModel.payMoney = [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.cuserid = ? and a.operatortype <> 2 and a.cbilldate >= ? and a.cbilldate <= ? and b.id in (?)", SSJUSERID(), budgetModel.beginDate, budgetModel.endDate, [self queryStringForBillIds:budgetModel.billIds]];
    
    return budgetModel;
}

+ (NSString *)queryStringForBillIds:(NSArray *)billIds {
    NSMutableArray *tBillIdArr = [NSMutableArray arrayWithCapacity:billIds.count];
    for (NSString *billId in billIds) {
        NSString *tBillId = [NSString stringWithFormat:@"'%@'", billId];
        [tBillIdArr addObject:tBillId];
    }
    return [tBillIdArr componentsJoinedByString:@","];
}

@end
