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
                                      booksId:(NSString *)booksId
                                      success:(void (^)(NSArray<SSJDatePeriod *> *))success
                                      failure:(void (^)(NSError *))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *tBooksId = booksId;
        if (!tBooksId) {
            tBooksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", SSJUSERID()];
            tBooksId = tBooksId ?: SSJUSERID();
        }
        // 查询有数据的月份
        FMResultSet *result = nil;
        switch (type) {
            case SSJBillTypeIncome:
            case SSJBillTypePay: {
                NSString *incomeOrPayType = type == SSJBillTypeIncome ? @"0" : @"1";
                if ([tBooksId isEqualToString:@"all"]) {
                    // 查询所有账本数据时，要加上userid条件，因为可能包含共享账本，把其他人的数据排除
                    result = [db executeQuery:@"select distinct strftime('%Y-%m', a.cbilldate) from bk_user_charge as a, bk_bill_type as b where a.cuserid = ? and a.ibillid = b.id and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and b.itype = ? and b.istate <> 2 order by a.cbilldate", SSJUSERID(), incomeOrPayType];
                } else {
                    // 查询某个账本数据时，不需要userid条件
                    result = [db executeQuery:@"select distinct strftime('%Y-%m', a.cbilldate) from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and a.cbooksid = ? and b.itype = ? and b.istate <> 2 order by a.cbilldate", tBooksId, incomeOrPayType];
                }
                
            }   break;
                
            case SSJBillTypeSurplus: {
                if ([tBooksId isEqualToString:@"all"]) {
                    result = [db executeQuery:@"select distinct strftime('%Y-%m', a.cbilldate) from bk_user_charge as a, bk_bill_type as b where a.cuserid = ? and a.ibillid = b.id and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and b.istate <> 2 order by a.cbilldate", SSJUSERID()];
                } else {
                    result = [db executeQuery:@"select distinct strftime('%Y-%m', a.cbilldate) from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and a.cbooksid = ? and b.istate <> 2 order by a.cbilldate", tBooksId];
                }
                
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
        
        NSMutableArray *list = [NSMutableArray array];
        
        while ([result next]) {
            
            NSString *dateStr = [result stringForColumnIndex:0];
            NSDate *date = [NSDate dateWithString:dateStr formatString:@"yyyy-MM"];
            SSJDatePeriod *currentPeriod = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeMonth date:date];
            
            if (list.count) {
                // 计算当前和上次之间的周期列表
                SSJDatePeriod *lastPeriod = [list lastObject];
                NSArray *periods = [currentPeriod periodsFromPeriod:lastPeriod];
                
                for (SSJDatePeriod *period in periods) {
                    // 比较每个相邻的月周期之间的年份是否相同，不同就插入一条上个月周期的年周期
                    if (period.startDate.year != lastPeriod.startDate.year) {
                        SSJDatePeriod *yearPeriod = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeYear date:lastPeriod.startDate];
                        [list addObject:yearPeriod];
                    }
                    
                    [list addObject:period];
                    lastPeriod = period;
                }
            } else {
                [list addObject:currentPeriod];
            }
        }
        
        [result close];
        
        if (list.count) {
            SSJDatePeriod *firstPeriod = [list firstObject];
            SSJDatePeriod *lastPeriod = [list lastObject];
            
            // 增加最后一个年周期
            [list addObject:[SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeYear date:lastPeriod.startDate]];
            
            // 增加合计（即最开始的日期到当前日期）
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
                        booksId:(NSString *)booksId
                      startDate:(NSDate *)startDate
                        endDate:(NSDate *)endDate
                        success:(void(^)(NSArray<SSJReportFormsItem *> *result))success
                        failure:(void (^)(NSError *error))failure {
    switch (type) {
        case SSJBillTypeIncome:
        case SSJBillTypePay:
            [self queryForIncomeOrPayChargeWithType:type booksId:booksId startDate:startDate endDate:endDate success:success failure:failure];
            break;
            
        case SSJBillTypeSurplus:
            [self queryForSurplusWithBooksId:booksId startDate:startDate endDate:endDate success:success failure:failure];
            break;
            
        case SSJBillTypeUnknown:
            failure(nil);
            break;
    }
}

//  查询成员记账数据
+ (void)queryForMemberChargeWithType:(SSJBillType)type
                             booksId:(NSString *)booksId
                           startDate:(NSDate *)startDate
                             endDate:(NSDate *)endDate
                             success:(void (^)(NSArray <SSJReportFormsItem *> *result))success
                             failure:(void (^)(NSError *error))failure {
    switch (type) {
        case SSJBillTypeIncome:
        case SSJBillTypePay:
            [self queryForMemberIncomeOrPayChargeWithType:type booksId:booksId startDate:startDate endDate:endDate success:success failure:failure];
            break;
            
        case SSJBillTypeSurplus:
            [self queryForSurplusWithBooksId:booksId startDate:startDate endDate:endDate success:success failure:failure];
            break;
        case SSJBillTypeUnknown:
            failure(nil);
            return;
    }
}

// 查询收支数据
+ (void)queryForIncomeOrPayChargeWithType:(SSJBillType)type
                                  booksId:(NSString *)booksId
                                startDate:(NSDate *)startDate
                                  endDate:(NSDate *)endDate
                                  success:(void (^)(NSArray <SSJReportFormsItem *> *result))success
                                  failure:(void (^)(NSError *error))failure {
    
    if (type == SSJBillTypeSurplus || type == SSJBillTypeUnknown) {
        if (failure) {
            SSJDispatchMainAsync(^{
                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"无效参数：%d", (int)type]}]);
            });
        }
        return;
    }
    
    if (!startDate || !endDate) {
        failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"startDate or endDate must not be nil"}]);
        return;
    }
    
    NSString *beginDateStr = [startDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *endDateStr = [endDate formattedDateWithFormat:@"yyyy-MM-dd"];
    
    // 查询不同收支类型的总额
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *tBooksId = booksId;
        if (!tBooksId) {
            tBooksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", SSJUSERID()];
            tBooksId = tBooksId ?: SSJUSERID();
        }
        
        NSError *error = nil;
        double amount = [self queryAmountForChargesInDatabse:db booksId:tBooksId beginDate:beginDateStr endDate:endDateStr type:type error:&error];
        if (error) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure(error);
                });
            }
            return;
        }
        
        if (amount == 0) {
            SSJDispatch_main_async_safe(^{
                success(nil);
            });
            return;
        }
        
        // 查询不同收支类型相应的金额、名称、图标、颜色
        NSMutableString *sql_2 = [@"select sum(a.imoney), b.id, b.cname, b.ccoin, b.ccolor from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.cbilldate >= :beginDateStr and a.cbilldate <= :endDateStr and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and b.itype = :type and b.istate <> 2" mutableCopy];
        
        NSMutableDictionary *params_2 = [@{@"beginDateStr":beginDateStr,
                                           @"endDateStr":endDateStr,
                                           @"type":@(type)} mutableCopy];
        
        if ([tBooksId isEqualToString:@"all"]) {
            [sql_2 appendString:@" and a.cuserid = :userId"];
            [params_2 setObject:SSJUSERID() forKey:@"userId"];
        } else {
            [sql_2 appendString:@" and a.cbooksid = :booksId"];
            [params_2 setObject:tBooksId forKey:@"booksId"];
        }
        
        // 只有共享账本是根据类别名称分组，所有账本、个人账本都是根据类别id分组
        BOOL isShareBook = [db boolForQuery:@"select count(*) from bk_share_books where cbooksid = ?", tBooksId];
        if (isShareBook) {
            [sql_2 appendString:@" group by b.cname"];
        } else {
            [sql_2 appendString:@" group by b.id"];
        }
        
        FMResultSet *resultSet = [db executeQuery:sql_2 withParameterDictionary:params_2];
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
            [result addObject:item];
        }
        [resultSet close];
        
        SSJDispatch_main_async_safe(^{
            success(result);
        });
    }];
}

+ (void)queryForMemberIncomeOrPayChargeWithType:(SSJBillType)type
                                        booksId:(NSString *)booksId
                                      startDate:(NSDate *)startDate
                                        endDate:(NSDate *)endDate
                                        success:(void (^)(NSArray <SSJReportFormsItem *> *result))success
                                        failure:(void (^)(NSError *error))failure {
    
    if (type == SSJBillTypeSurplus || type == SSJBillTypeUnknown) {
        if (failure) {
            SSJDispatchMainAsync(^{
                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"无效参数：%d", (int)type]}]);
            });
        }
        return;
    }
    
    if (!startDate || !endDate) {
        if (failure) {
            SSJDispatchMainAsync(^{
                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"startDate or endDate must not be nil"}]);
            });
        }
        return;
    }
    
    NSString *beginDateStr = [startDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *endDateStr = [endDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *userID = SSJUSERID();
    
    // 查询不同收支类型的总额
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *tBooksId = booksId;
        if (!tBooksId) {
            tBooksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", userID];
            tBooksId = tBooksId ?: userID;
        }
        
        NSError *error = nil;
        double amount = [self queryAmountForChargesInDatabse:db booksId:tBooksId beginDate:beginDateStr endDate:endDateStr type:type error:&error];
        if (error) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure(error);
                });
            }
            return;
        }
        
        if (amount == 0) {
            SSJDispatch_main_async_safe(^{
                success(nil);
            });
            return;
        }
        
        NSMutableArray *result = [@[] mutableCopy];
        if ([booksId isEqualToString:@"all"]) {
            // ----------------------------------------------------------------
            // 查询所有账本数据分两步：
            // 1.查询共享账本中当前登录用户的数据
            // 2.查询当前登录用户的个人账本数据
            // ----------------------------------------------------------------
            
            // --------------------------- 第1步 ---------------------------
            NSDictionary *params = @{@"userId":userID,
                                     @"type":@(type),
                                     @"startDate":beginDateStr,
                                     @"endDate":endDateStr,
                                     @"chargeType":@(SSJChargeIdTypeShareBooks)};
            
            FMResultSet *rs = [db executeQuery:@"select sum(uc.imoney) as amount, sm.cmemberid, sm.ccolor, sf.cmark from bk_user_charge as uc, bk_share_books_member as sm, bk_share_books_friends_mark as sf, bk_bill_type as bt where uc.cuserid = sm.cmemberid and sm.cbooksid = uc.cbooksid and sf.cuserid = :userId and sf.cbooksid = uc.cbooksid and sf.cfriendid = uc.cuserid and bt.id = uc.ibillid and bt.itype = :type and bt.istate <> 2 and uc.operatortype <> 2 and uc.cbilldate >= :startDate and uc.cbilldate <= :endDate and uc.cbilldate <= datetime('now', 'localtime') and uc.ichargetype = :chargeType and uc.cuserid = :userId group by sm.cmemberid" withParameterDictionary:params];
            if (!rs) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
                return;
            }
            
            while ([rs next]) {
                SSJReportFormsItem *item = [[SSJReportFormsItem alloc] init];
                item.ID = [rs stringForColumn:@"cmemberid"];
                item.money = [rs doubleForColumn:@"amount"];
                item.name = [rs stringForColumn:@"cmark"];
                item.colorValue = [rs stringForColumn:@"ccolor"];
                item.scale = item.money / amount;
                item.isMember = YES;
                [result addObject:item];
            }
            [rs close];
            
            // --------------------------- 第2步 ---------------------------
            params = @{@"userId":userID,
                       @"type":@(type),
                       @"startDate":beginDateStr,
                       @"endDate":endDateStr};
            
            rs = [db executeQuery:@"select sum(mc.imoney), mc.cmemberid from bk_member_charge as mc, bk_user_charge as uc, bk_bill_type as bt where mc.ichargeid = uc.ichargeid and uc.ibillid = bt.id and uc.cuserid = :userId and uc.operatortype <> 2 and bt.itype = :type and bt.istate <> 2 and uc.cbilldate >= :startDate and uc.cbilldate <= :endDate and uc.cbilldate <= datetime('now', 'localtime') group by mc.cmemberid" withParameterDictionary:params];
            if (!rs) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
                return;
            }
            
            while ([rs next]) {
                SSJReportFormsItem *item = [[SSJReportFormsItem alloc] init];
                item.ID = [rs stringForColumn:@"cmemberid"];
                item.money = [rs doubleForColumn:@"sum(mc.imoney)"];
                item.scale = item.money / amount;
                item.isMember = YES;
                [result addObject:item];
            }
            [rs close];
            
            for (SSJReportFormsItem *item in result) {
                rs = [db executeQuery:@"select cname, ccolor from bk_member where cmemberid = ? and cuserid = ?", item.ID, userID];
                while ([rs next]) {
                    item.name = [rs stringForColumnIndex:0];
                    item.colorValue = [rs stringForColumnIndex:1];
                }
                [rs close];
            }
            
        } else {
            BOOL isShareBook = [db boolForQuery:@"select count(*) from bk_share_books where cbooksid = ?", tBooksId];
            if (isShareBook) {
                // ----------------------------------------------------------------
                // 查询单个账本数据（共享账本）
                // ----------------------------------------------------------------
                NSDictionary *params = @{@"userId":userID,
                                         @"type":@(type),
                                         @"booksId":tBooksId,
                                         @"startDate":beginDateStr,
                                         @"endDate":endDateStr};
                
                FMResultSet *rs = [db executeQuery:@"select sum(uc.imoney) as amount, sm.cmemberid, sm.ccolor, sf.cmark from bk_user_charge as uc, bk_share_books_member as sm, bk_share_books_friends_mark as sf, bk_bill_type as bt where uc.cuserid = sm.cmemberid and sm.cbooksid = uc.cbooksid and sf.cuserid = :userId and sf.cbooksid = uc.cbooksid and sf.cfriendid = uc.cuserid and bt.id = uc.ibillid and bt.itype = :type and bt.istate <> 2 and uc.cbooksid = :booksId and uc.operatortype <> 2 and uc.cbilldate >= :startDate and uc.cbilldate <= :endDate and uc.cbilldate <= datetime('now', 'localtime') group by sm.cmemberid" withParameterDictionary:params];
                if (!rs) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                    return;
                }
                
                while ([rs next]) {
                    SSJReportFormsItem *item = [[SSJReportFormsItem alloc] init];
                    item.ID = [rs stringForColumn:@"cmemberid"];
                    item.money = [rs doubleForColumn:@"amount"];
                    item.name = [rs stringForColumn:@"cmark"];
                    item.colorValue = [rs stringForColumn:@"ccolor"];
                    item.scale = item.money / amount;
                    item.isMember = YES;
                    [result addObject:item];
                }
                [rs close];
            } else {
                // ----------------------------------------------------------------
                // 查询单个账本数据（个人账本）
                // ----------------------------------------------------------------
                NSDictionary *params = @{@"userId":userID,
                                         @"booksId":tBooksId,
                                         @"type":@(type),
                                         @"startDate":beginDateStr,
                                         @"endDate":endDateStr};
                
                FMResultSet *rs = [db executeQuery:@"select sum(mc.imoney), mc.cmemberid from bk_member_charge as mc, bk_user_charge as uc, bk_bill_type as bt where mc.ichargeid = uc.ichargeid and uc.ibillid = bt.id and uc.cuserid = :userId and uc.operatortype <> 2 and uc.cbooksid = :booksId and bt.itype = :type and bt.istate <> 2 and uc.cbilldate >= :startDate and uc.cbilldate <= :endDate and uc.cbilldate <= datetime('now', 'localtime') group by mc.cmemberid" withParameterDictionary:params];
                if (!rs) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                    return;
                }
                
                while ([rs next]) {
                    SSJReportFormsItem *item = [[SSJReportFormsItem alloc] init];
                    item.ID = [rs stringForColumn:@"cmemberid"];
                    item.money = [rs doubleForColumn:@"sum(mc.imoney)"];
                    item.scale = item.money / amount;
                    item.isMember = YES;
                    [result addObject:item];
                }
                [rs close];
                
                for (SSJReportFormsItem *item in result) {
                    rs = [db executeQuery:@"select cname, ccolor from bk_member where cmemberid = ? and cuserid = ?", item.ID, userID];
                    while ([rs next]) {
                        item.name = [rs stringForColumnIndex:0];
                        item.colorValue = [rs stringForColumnIndex:1];
                    }
                    [rs close];
                }
            }
        }
        
        SSJDispatch_main_async_safe(^{
            success(result);
        });
    }];
}

//  查询结余数据
+ (void)queryForSurplusWithBooksId:(NSString *)booksId
                         startDate:(NSDate *)startDate
                           endDate:(NSDate *)endDate
                           success:(void (^)(NSArray <SSJReportFormsItem *> *result))success
                           failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {

        NSString *tBooksId = booksId;
        if (!tBooksId) {
            tBooksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", SSJUSERID()];
            tBooksId = tBooksId ?: SSJUSERID();
        }
        
        NSString *beginDateStr = [startDate formattedDateWithFormat:@"yyyy-MM-dd"];
        NSString *endDateStr = [endDate formattedDateWithFormat:@"yyyy-MM-dd"];
        
        NSMutableString *sql = [@"select sum(a.imoney), b.itype from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.cbilldate >= :beginDateStr and a.cbilldate <= :endDateStr and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and b.istate <> 2" mutableCopy];
        
        NSMutableDictionary *params = [@{@"beginDateStr":beginDateStr,
                                         @"endDateStr":endDateStr} mutableCopy];
        
        if ([tBooksId isEqualToString:@"all"]) {
            [sql appendString:@" and a.cuserid = :userId"];
            [params setObject:SSJUSERID() forKey:@"userId"];
        } else {
            [sql appendString:@" and a.cbooksid = :booksId"];
            [params setObject:tBooksId forKey:@"booksId"];
        }
        [sql appendString:@" group by b.itype order by b.itype desc"];
        
        FMResultSet *resultSet = [db executeQuery:sql withParameterDictionary:params];
        
        if (!resultSet) {
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
            [result addObject:item];
            amount += item.money;
        }
        
        [resultSet close];
        
        for (int i = 0; i < result.count; i ++) {
            SSJReportFormsItem *item = result[i];
            item.scale = item.money / amount;
        }
        
        SSJDispatch_main_async_safe(^{
            success(result);
        });
    }];
}

+ (double)queryAmountForChargesInDatabse:(FMDatabase *)db booksId:(NSString *)booksId beginDate:(NSString *)beginDate endDate:(NSString *)endDate type:(SSJBillType)type error:(NSError **)error {
    NSMutableString *sql_1 = [@"select sum(a.IMONEY) from BK_USER_CHARGE as a, BK_BILL_TYPE as b where a.IBILLID = b.ID and a.cbilldate >= :beginDateStr and a.cbilldate <= :endDateStr and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and b.istate <> 2 and b.itype = :type" mutableCopy];
    
    NSMutableDictionary *params_1 = [@{@"beginDateStr":beginDate,
                                       @"endDateStr":endDate,
                                       @"type":@(type)} mutableCopy];
    
    if ([booksId isEqualToString:@"all"]) {
        [sql_1 appendString:@" and a.cuserid = :userId"];
        [params_1 setObject:SSJUSERID() forKey:@"userId"];
    } else {
        [sql_1 appendString:@" and a.cbooksid = :booksId"];
        [params_1 setObject:booksId forKey:@"booksId"];
    }
    
    FMResultSet *rs = [db executeQuery:sql_1 withParameterDictionary:params_1];
    if (!rs) {
        if (error) {
            *error = [db lastError];
        }
        return 0;
    }
    
    double amount = 0;
    while ([rs next]) {
        amount = [rs doubleForColumnIndex:0];
    }
    [rs close];
    
    return amount;
}

+ (void)queryForDefaultTimeDimensionWithStartDate:(NSDate *)startDate
                                          endDate:(NSDate *)endDate
                                          booksId:(NSString *)booksId
                                       billTypeId:(NSString *)billTypeId
                                          success:(void(^)(SSJTimeDimension timeDimension))success
                                          failure:(void (^)(NSError *error))failure {
    
    if ([startDate compare:endDate] == NSOrderedDescending) {
        if (failure) {
            failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"startDate不能晚于endDate"}]);
        }
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *tBooksId = booksId;
        if (!tBooksId) {
            tBooksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", SSJUSERID()];
            tBooksId = tBooksId ?: SSJUSERID();
        }
        
        NSMutableDictionary *params = [@{} mutableCopy];
        NSMutableString *sqlStr = [NSMutableString stringWithFormat:@"select max(a.cbilldate) as maxBillDate, min(a.cbilldate) as minBillDate from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.operatortype <> 2 and b.istate <> 2 and a.cbilldate <= datetime('now', 'localtime')"];
        
        if ([tBooksId isEqualToString:@"all"]) {
            [params setObject:SSJUSERID() forKey:@"userId"];
            [sqlStr appendString:@" and a.cuserid = :userId"];
        } else {
            [params setObject:tBooksId forKey:@"booksId"];
            [sqlStr appendString:@" and a.cbooksid = :booksId"];
        }
        
        if (billTypeId) {
            [params setObject:billTypeId forKey:@"billId"];
            [sqlStr appendString:@" and a.ibillid = :billId"];
        }
        
        if (startDate) {
            NSString *startDateStr = [startDate formattedDateWithFormat:@"yyyy-MM-dd"];
            [params setObject:startDateStr forKey:@"startDate"];
            [sqlStr appendString:@" and a.cbilldate >= :startDate"];
        }
        
        if (endDate) {
            NSString *endDateStr = [endDate formattedDateWithFormat:@"yyyy-MM-dd"];
            [params setObject:endDateStr forKey:@"endDate"];
            [sqlStr appendString:@" and a.cbilldate <= :endDate"];
        }
        
        FMResultSet *resultSet = [db executeQuery:sqlStr withParameterDictionary:params];
        if (!resultSet) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSDate *maxDate = nil;
        NSDate *minDate = nil;
        
        while ([resultSet next]) {
            NSString *maxDateStr = [resultSet stringForColumn:@"maxBillDate"];
            maxDate = [NSDate dateWithString:maxDateStr formatString:@"yyyy-MM-dd"];
            
            NSString *minDateStr = [resultSet stringForColumn:@"minBillDate"];
            minDate = [NSDate dateWithString:minDateStr formatString:@"yyyy-MM-dd"];
        }
        
        [resultSet close];
        
        SSJTimeDimension timeDimension = [self dimensionWithDate1:maxDate date2:minDate];
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(timeDimension);
            });
        }
    }];
}

+ (SSJTimeDimension)dimensionWithDate1:(NSDate *)date1 date2:(NSDate *)date2 {
    if (!date1 || !date2) {
        return SSJTimeDimensionUnknown;
    }
    
    if (date1.month != date2.month || date1.year != date2.year) {
        return SSJTimeDimensionMonth;
    }
    
    SSJDatePeriod *weekPeriod = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeWeek date:date1];
    if (![weekPeriod containDate:date2]) {
        return SSJTimeDimensionWeek;
    }
    
    return SSJTimeDimensionDay;
}

+ (void)queryForBillStatisticsWithTimeDimension:(SSJTimeDimension)dimension
                                        booksId:(NSString *)booksId
                                     billTypeId:(NSString *)billTypeId
                                      startDate:(NSDate *)startDate
                                        endDate:(NSDate *)endDate
                                        success:(void(^)(NSDictionary *result))success
                                        failure:(void (^)(NSError *error))failure {
    
    SSJDatePeriodType periodType = SSJDatePeriodTypeUnknown;
    switch (dimension) {
        case SSJTimeDimensionDay:
            periodType = SSJDatePeriodTypeDay;
            break;
            
        case SSJTimeDimensionWeek:
            periodType = SSJDatePeriodTypeWeek;
            break;
            
        case SSJTimeDimensionMonth:
            periodType = SSJDatePeriodTypeMonth;
            break;
            
        case SSJTimeDimensionUnknown:
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"dimension参数无效"}]);
                });
            }
            return;
            break;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *tBooksId = booksId;
        if (!tBooksId) {
            tBooksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", SSJUSERID()];
            tBooksId = tBooksId ?: SSJUSERID();
        }
        
        NSMutableDictionary *params = [@{} mutableCopy];
        NSMutableString *sqlStr = [@"select a.imoney, a.cbilldate, b.itype from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.operatortype <> 2 and b.istate <> 2 and a.cbilldate <= datetime('now', 'localtime')" mutableCopy];
        
        if ([tBooksId isEqualToString:@"all"]) {
            params[@"userId"] = SSJUSERID();
            [sqlStr appendString:@" and a.cuserid = :userId"];
        } else {
            params[@"booksId"] = tBooksId;
            [sqlStr appendString:@" and a.cbooksid = :booksId"];
        }
        
        if (billTypeId) {
            params[@"billId"] = billTypeId;
            [sqlStr appendString:@" and a.ibillid = :billId"];
        }
        
        if (startDate) {
            NSString *startDateStr = [startDate formattedDateWithFormat:@"yyyy-MM-dd"];
            params[@"startDate"] = startDateStr;
            [sqlStr appendString:@" and a.cbilldate >= :startDate"];
        }
        
        if (endDate) {
            NSString *endDateStr = [endDate formattedDateWithFormat:@"yyyy-MM-dd"];
            params[@"endDate"] = endDateStr;
            [sqlStr appendString:@" and a.cbilldate <= :endDate"];
        }
        
        [sqlStr appendString:@" order by a.cbilldate"];
        
        FMResultSet *resultSet = [db executeQuery:sqlStr withParameterDictionary:params];
        if (!resultSet) {
            SSJPRINT(@">>>SSJ\n class:%@\n method:%@\n message:%@\n error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorMessage], [db lastError]);
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        double payment = 0;
        double income = 0;
        
        NSMutableArray *list = [NSMutableArray array];
        NSString *startDateStr = nil;
        NSString *endDateStr = nil;
        SSJDatePeriod *period = nil;
        
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
            }
            
            if ([period containDate:billDate]) {
                if (isPayment) {
                    payment += money;
                } else {
                    income += money;
                }
            } else {
                [list addObject:[SSJReportFormsCurveModel modelWithPayment:payment income:income startDate:period.startDate endDate:period.endDate]];
                
                SSJDatePeriod *currentPeriod = [SSJDatePeriod datePeriodWithPeriodType:periodType date:billDate];
                NSArray *periods = [currentPeriod periodsFromPeriod:period];
                for (int i = 0; i < periods.count - 1; i ++) {
                    SSJDatePeriod *addPeriod = periods[i];
                    [list addObject:[SSJReportFormsCurveModel modelWithPayment:0 income:0 startDate:addPeriod.startDate endDate:addPeriod.endDate]];
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
            if (!lastModel || [lastModel.startDate compare:period.startDate] != NSOrderedSame) {
                [list addObject:[SSJReportFormsCurveModel modelWithPayment:payment income:income startDate:period.startDate endDate:period.endDate]];
            }
        }
        
        // 确保第一条模型的开始时间不早于传入的开始时间
        SSJReportFormsCurveModel *firstCurveModel = [list firstObject];
        firstCurveModel.startDate = ([firstCurveModel.startDate compare:startDate] == NSOrderedAscending) ? startDate : firstCurveModel.startDate;
        
        // 确保最后一条模型的结束时间不晚于传入的结束时间
        SSJReportFormsCurveModel *lastCurveModel = [list lastObject];
        lastCurveModel.endDate = ([lastCurveModel.endDate compare:endDate] == NSOrderedAscending) ? lastCurveModel.endDate : endDate;
        
        startDateStr = startDate ? [startDate formattedDateWithFormat:@"yyyy-MM-dd"] : startDateStr;
        endDateStr = endDate ? [endDate formattedDateWithFormat:@"yyyy-MM-dd"] : endDateStr;
        
        if (success) {
            SSJDispatchMainAsync(^{
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

+ (BOOL)isPaymentWithBillTypeId:(NSString *)billTypeId {
    __block BOOL isPayment;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        isPayment = [db boolForQuery:@"select itype from bk_bill_type where id = ?", billTypeId];
    }];
    return isPayment;
}

+ (NSString *)billTypeColorWithBillTypeId:(NSString *)billTypeId {
    __block NSString *color;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        color = [db stringForQuery:@"select ccolor from bk_bill_type where id = ?", billTypeId];
    }];
    return color;
}

@end
