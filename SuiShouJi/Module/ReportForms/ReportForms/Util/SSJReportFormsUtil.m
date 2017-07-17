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
    if (type == SSJBillTypeUnknown) {
        if (failure) {
            SSJDispatchMainAsync(^{
                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"参数type无效"}]);
            });
        }
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *tBooksId = booksId;
        if (!tBooksId) {
            tBooksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", SSJUSERID()];
            tBooksId = tBooksId.length > 0 ? tBooksId : SSJUSERID();
        }
        // 查询有数据的月份
        NSMutableDictionary *params = [@{} mutableCopy];
        NSMutableString *sql = [@"select distinct strftime('%Y-%m', uc.cbilldate) from bk_user_charge as uc, bk_bill_type as bt where uc.ibillid = bt.id and uc.cbilldate <= datetime('now', 'localtime') and uc.operatortype <> 2 and bt.istate <> 2" mutableCopy];
        
        if ([tBooksId isEqualToString:SSJAllBooksIds]) {
            // 因为所有账本中可能包括共享账本，要加两个限制流水的条件
            // 1.共享账本流水：当前用户加入的共享账本流水并且是当前用户的流水
            // 2.非共享账本流水：只要是当前用户的流水
            params[@"userId"] = SSJUSERID();
            params[@"shareBooksType"] = @(SSJChargeIdTypeShareBooks);
            params[@"memberState"] = @(SSJShareBooksMemberStateNormal);
            [sql appendString:@" and ((uc.ichargetype = :shareBooksType and uc.cuserid = :userId and uc.cbooksid in (select cbooksid from bk_share_books_member where cmemberid = :userId and istate = :memberState) or (uc.ichargetype <> :shareBooksType and uc.cuserid = :userId)))"];
        } else {
            // 如果是特定的账本，不限制特定用户的流水
            params[@"booksId"] = tBooksId;
            [sql appendString:@" and uc.cbooksid = :booksId"];
        }
        
        if (type != SSJBillTypeSurplus) {
            params[@"billType"] = @(type);
            [sql appendString:@" and and bt.itype = :billType"];
        }
        
        [sql appendString:@" order by uc.cbilldate"];
        
        FMResultSet *result = [db executeQuery:sql withParameterDictionary:params];
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
            tBooksId = tBooksId.length > 0 ? tBooksId : SSJUSERID();
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
        NSMutableDictionary *params_2 = [@{@"beginDateStr":beginDateStr,
                                           @"endDateStr":endDateStr,
                                           @"type":@(type)} mutableCopy];
        
        NSMutableString *sql_2 = [@"select sum(a.imoney), b.id, b.cname, b.ccoin, b.ccolor from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.cbilldate >= :beginDateStr and a.cbilldate <= :endDateStr and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and b.itype = :type and b.istate <> 2" mutableCopy];
        
        if ([tBooksId isEqualToString:SSJAllBooksIds]) {
            // 因为所有账本中可能包括共享账本，要加两个限制流水的条件
            // 1.共享账本流水：当前用户加入的共享账本流水并且是当前用户的流水
            // 2.非共享账本流水：只要是当前用户的流水
            params_2[@"userId"] = SSJUSERID();
            params_2[@"shareBooksType"] = @(SSJChargeIdTypeShareBooks);
            params_2[@"memberState"] = @(SSJShareBooksMemberStateNormal);
            [sql_2 appendString:@" and ((a.ichargetype = :shareBooksType and a.cuserid = :userId and a.cbooksid in (select cbooksid from bk_share_books_member where cmemberid = :userId and istate = :memberState) or (a.ichargetype <> :shareBooksType and a.cuserid = :userId)))"];
        } else {
            [params_2 setObject:tBooksId forKey:@"booksId"];
            [sql_2 appendString:@" and a.cbooksid = :booksId"];
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
            tBooksId = tBooksId.length > 0 ? tBooksId : userID;
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
                item.name = [item.ID isEqualToString:userID] ? @"我" : [rs stringForColumn:@"cmark"];
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
            tBooksId = tBooksId.length > 0 ? tBooksId : SSJUSERID();
        }
        
        NSString *beginDateStr = [startDate formattedDateWithFormat:@"yyyy-MM-dd"];
        NSString *endDateStr = [endDate formattedDateWithFormat:@"yyyy-MM-dd"];
        
        NSMutableDictionary *params = [@{@"beginDateStr":beginDateStr,
                                         @"endDateStr":endDateStr} mutableCopy];
        
        NSMutableString *sql = [@"select sum(a.imoney), b.itype from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.cbilldate >= :beginDateStr and a.cbilldate <= :endDateStr and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and b.istate <> 2" mutableCopy];
        
        if ([tBooksId isEqualToString:SSJAllBooksIds]) {
            // 因为所有账本中可能包括共享账本，要加两个限制流水的条件
            // 1.共享账本流水：当前用户加入的共享账本流水并且是当前用户的流水
            // 2.非共享账本流水：只要是当前用户的流水
            params[@"userId"] = SSJUSERID();
            params[@"shareBooksType"] = @(SSJChargeIdTypeShareBooks);
            params[@"memberState"] = @(SSJShareBooksMemberStateNormal);
            [sql appendString:@" and ((a.ichargetype = :shareBooksType and a.cuserid = :userId and a.cbooksid in (select cbooksid from bk_share_books_member where cmemberid = :userId and istate = :memberState) or (a.ichargetype <> :shareBooksType and a.cuserid = :userId)))"];
        } else {
            params[@"booksId"] = tBooksId;
            [sql appendString:@" and a.cbooksid = :booksId"];
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
    
    if ([booksId isEqualToString:SSJAllBooksIds]) {
        // 因为所有账本中可能包括共享账本，要加两个限制流水的条件
        // 1.共享账本流水：当前用户加入的共享账本流水并且是当前用户的流水
        // 2.非共享账本流水：只要是当前用户的流水
        params_1[@"userId"] = SSJUSERID();
        params_1[@"shareBooksType"] = @(SSJChargeIdTypeShareBooks);
        params_1[@"memberState"] = @(SSJShareBooksMemberStateNormal);
        [sql_1 appendString:@" and ((a.ichargetype = :shareBooksType and a.cuserid = :userId and a.cbooksid in (select cbooksid from bk_share_books_member where cmemberid = :userId and istate = :memberState) or (a.ichargetype <> :shareBooksType and a.cuserid = :userId)))"];
    } else {
        params_1[@"booksId"] = booksId;
        [sql_1 appendString:@" and a.cbooksid = :booksId"];
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
                                         billName:(NSString *)billName
                                         billType:(SSJBillType)billType
                                          success:(void(^)(SSJTimeDimension timeDimension))success
                                          failure:(void (^)(NSError *error))failure {
    if ([startDate compare:endDate] == NSOrderedDescending) {
        if (failure) {
            failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"startDate不能晚于endDate"}]);
        }
        return;
    }
    
    if (billType == SSJBillTypeUnknown) {
        if (failure) {
            failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"billType参数无效"}]);
        }
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *tBooksId = booksId;
        if (!tBooksId) {
            tBooksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", SSJUSERID()];
            tBooksId = tBooksId.length > 0 ? tBooksId : SSJUSERID();
        }
        
        NSMutableDictionary *params = [@{} mutableCopy];
        NSMutableString *sql = [NSMutableString stringWithFormat:@"select max(uc.cbilldate) as maxBillDate, min(uc.cbilldate) as minBillDate from bk_user_charge as uc, bk_bill_type as bt where uc.ibillid = bt.id and uc.operatortype <> 2 and bt.istate <> 2 and uc.cbilldate <= datetime('now', 'localtime')"];
        
        if ([tBooksId isEqualToString:SSJAllBooksIds]) {
            // 因为所有账本中可能包括共享账本，要加两个限制流水的条件
            // 1.共享账本流水：当前用户加入的共享账本流水并且是当前用户的流水
            // 2.非共享账本流水：只要是当前用户的流水
            params[@"userId"] = SSJUSERID();
            params[@"shareBooksType"] = @(SSJChargeIdTypeShareBooks);
            params[@"memberState"] = @(SSJShareBooksMemberStateNormal);
            [sql appendString:@" and ((uc.ichargetype = :shareBooksType and uc.cuserid = :userId and uc.cbooksid in (select cbooksid from bk_share_books_member where cmemberid = :userId and istate = :memberState) or (uc.ichargetype <> :shareBooksType and uc.cuserid = :userId)))"];
        } else {
            [params setObject:tBooksId forKey:@"booksId"];
            [sql appendString:@" and uc.cbooksid = :booksId"];
        }
        
        if (billName) {
            [params setObject:billName forKey:@"billName"];
            [sql appendString:@" and bt.cname = :billName"];
        }
        
        if (billType == SSJBillTypePay || billType == SSJBillTypeIncome) {
            [params setObject:@(billType) forKey:@"billType"];
            [sql appendString:@" and bt.itype = :billType"];
        }
        
        if (startDate) {
            NSString *startDateStr = [startDate formattedDateWithFormat:@"yyyy-MM-dd"];
            [params setObject:startDateStr forKey:@"startDate"];
            [sql appendString:@" and uc.cbilldate >= :startDate"];
        }
        
        if (endDate) {
            NSString *endDateStr = [endDate formattedDateWithFormat:@"yyyy-MM-dd"];
            [params setObject:endDateStr forKey:@"endDate"];
            [sql appendString:@" and uc.cbilldate <= :endDate"];
        }
        
        FMResultSet *resultSet = [db executeQuery:sql withParameterDictionary:params];
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

+ (void)queryForDefaultTimeDimensionWithStartDate:(NSDate *)startDate
                                          endDate:(NSDate *)endDate
                                          booksId:(NSString *)booksId
                                           billId:(NSString *)billId
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
            tBooksId = tBooksId.length > 0 ? tBooksId : SSJUSERID();
        }
        
        NSMutableDictionary *params = [@{} mutableCopy];
        NSMutableString *sql = [NSMutableString stringWithFormat:@"select max(uc.cbilldate) as maxBillDate, min(uc.cbilldate) as minBillDate from bk_user_charge as uc, bk_bill_type as bt where uc.ibillid = bt.id and uc.operatortype <> 2 and bt.istate <> 2 and uc.cbilldate <= datetime('now', 'localtime')"];
        
        if ([tBooksId isEqualToString:SSJAllBooksIds]) {
            // 因为所有账本中可能包括共享账本，要加两个限制流水的条件
            // 1.共享账本流水：当前用户加入的共享账本流水并且是当前用户的流水
            // 2.非共享账本流水：只要是当前用户的流水
            params[@"userId"] = SSJUSERID();
            params[@"shareBooksType"] = @(SSJChargeIdTypeShareBooks);
            params[@"memberState"] = @(SSJShareBooksMemberStateNormal);
            [sql appendString:@" and ((uc.ichargetype = :shareBooksType and uc.cuserid = :userId and uc.cbooksid in (select cbooksid from bk_share_books_member where cmemberid = :userId and istate = :memberState) or (uc.ichargetype <> :shareBooksType and uc.cuserid = :userId)))"];
        } else {
            [params setObject:tBooksId forKey:@"booksId"];
            [sql appendString:@" and uc.cbooksid = :booksId"];
        }
        
        if (billId) {
            [params setObject:billId forKey:@"billId"];
            [sql appendString:@" and uc.ibillid = :billId"];
        }
        
        if (startDate) {
            NSString *startDateStr = [startDate formattedDateWithFormat:@"yyyy-MM-dd"];
            [params setObject:startDateStr forKey:@"startDate"];
            [sql appendString:@" and uc.cbilldate >= :startDate"];
        }
        
        if (endDate) {
            NSString *endDateStr = [endDate formattedDateWithFormat:@"yyyy-MM-dd"];
            [params setObject:endDateStr forKey:@"endDate"];
            [sql appendString:@" and uc.cbilldate <= :endDate"];
        }
        
        FMResultSet *resultSet = [db executeQuery:sql withParameterDictionary:params];
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
                                       billName:(NSString *)billName
                                       billType:(SSJBillType)billType
                                      startDate:(NSDate *)startDate
                                        endDate:(NSDate *)endDate
                                        success:(void(^)(NSDictionary *result))success
                                        failure:(void (^)(NSError *error))failure {
    
    SSJDatePeriodType periodType = [self periodTypeWithDimension:dimension];
    if (periodType == SSJTimeDimensionUnknown) {
        if (failure) {
            SSJDispatchMainAsync(^{
                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"dimension参数无效"}]);
            });
        }
        return;
    }
    
    if (billType == SSJBillTypeUnknown) {
        if (failure) {
            SSJDispatchMainAsync(^{
                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"billType参数无效"}]);
            });
        }
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *tBooksId = booksId;
        if (!tBooksId) {
            tBooksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", SSJUSERID()];
            tBooksId = tBooksId.length > 0 ? tBooksId : SSJUSERID();
        }
        
        NSMutableDictionary *params = [@{} mutableCopy];
        NSMutableString *sql = [@"select uc.imoney, uc.cbilldate, bt.itype from bk_user_charge as uc, bk_bill_type as bt where uc.ibillid = bt.id and uc.operatortype <> 2 and bt.istate <> 2 and uc.cbilldate <= datetime('now', 'localtime')" mutableCopy];
        
        if ([tBooksId isEqualToString:SSJAllBooksIds]) {
            // 因为所有账本中可能包括共享账本，要加两个限制流水的条件
            // 1.共享账本流水：当前用户加入的共享账本流水并且是当前用户的流水
            // 2.非共享账本流水：只要是当前用户的流水
            params[@"userId"] = SSJUSERID();
            params[@"shareBooksType"] = @(SSJChargeIdTypeShareBooks);
            params[@"memberState"] = @(SSJShareBooksMemberStateNormal);
            [sql appendString:@" and ((uc.ichargetype = :shareBooksType and uc.cuserid = :userId and uc.cbooksid in (select cbooksid from bk_share_books_member where cmemberid = :userId and istate = :memberState) or (uc.ichargetype <> :shareBooksType and uc.cuserid = :userId)))"];
        } else {
            params[@"booksId"] = tBooksId;
            [sql appendString:@" and uc.cbooksid = :booksId"];
        }
        
        if (billName) {
            params[@"billName"] = billName;
            [sql appendString:@" and bt.cname = :billName"];
        }
        
        if (billType == SSJBillTypePay || billType == SSJBillTypeIncome) {
            params[@"billType"] = @(billType);
            [sql appendString:@" and bt.itype = :billType"];
        }
        
        if (startDate) {
            NSString *startDateStr = [startDate formattedDateWithFormat:@"yyyy-MM-dd"];
            params[@"startDate"] = startDateStr;
            [sql appendString:@" and uc.cbilldate >= :startDate"];
        }
        
        if (endDate) {
            NSString *endDateStr = [endDate formattedDateWithFormat:@"yyyy-MM-dd"];
            params[@"endDate"] = endDateStr;
            [sql appendString:@" and uc.cbilldate <= :endDate"];
        }
        
        [sql appendString:@" order by uc.cbilldate"];
        
        FMResultSet *rs = [db executeQuery:sql withParameterDictionary:params];
        if (!rs) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSDictionary *result = [self organiseDataWithResult:rs periodType:periodType startDate:startDate endDate:endDate];
        if (success) {
            SSJDispatchMainAsync(^{
                success(result);
            });
        }
    }];
}

+ (void)queryForBillStatisticsWithTimeDimension:(SSJTimeDimension)dimension
                                        booksId:(NSString *)booksId
                                         billId:(NSString *)billId
                                      startDate:(NSDate *)startDate
                                        endDate:(NSDate *)endDate
                                        success:(void(^)(NSDictionary *result))success
                                        failure:(void (^)(NSError *error))failure {
    
    SSJDatePeriodType periodType = [self periodTypeWithDimension:dimension];
    if (periodType == SSJTimeDimensionUnknown) {
        if (failure) {
            SSJDispatchMainAsync(^{
                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"dimension参数无效"}]);
            });
        }
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *tBooksId = booksId;
        if (!tBooksId) {
            tBooksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", SSJUSERID()];
            tBooksId = tBooksId.length > 0 ? tBooksId : SSJUSERID();
        }
        
        NSMutableDictionary *params = [@{} mutableCopy];
        NSMutableString *sql = [@"select a.imoney, a.cbilldate, b.itype from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.operatortype <> 2 and b.istate <> 2 and a.cbilldate <= datetime('now', 'localtime')" mutableCopy];
        
        if ([tBooksId isEqualToString:SSJAllBooksIds]) {
            // 因为所有账本中可能包括共享账本，要加两个限制流水的条件
            // 1.共享账本流水：当前用户加入的共享账本流水并且是当前用户的流水
            // 2.非共享账本流水：只要是当前用户的流水
            params[@"userId"] = SSJUSERID();
            params[@"shareBooksType"] = @(SSJChargeIdTypeShareBooks);
            params[@"memberState"] = @(SSJShareBooksMemberStateNormal);
            [sql appendString:@" and ((a.ichargetype = :shareBooksType and a.cuserid = :userId and a.cbooksid in (select cbooksid from bk_share_books_member where cmemberid = :userId and istate = :memberState) or (a.ichargetype <> :shareBooksType and a.cuserid = :userId)))"];
        } else {
            params[@"booksId"] = tBooksId;
            [sql appendString:@" and a.cbooksid = :booksId"];
        }
        
        if (billId) {
            params[@"billId"] = billId;
            [sql appendString:@" and a.ibillid = :billId"];
        }
        
        if (startDate) {
            NSString *startDateStr = [startDate formattedDateWithFormat:@"yyyy-MM-dd"];
            params[@"startDate"] = startDateStr;
            [sql appendString:@" and a.cbilldate >= :startDate"];
        }
        
        if (endDate) {
            NSString *endDateStr = [endDate formattedDateWithFormat:@"yyyy-MM-dd"];
            params[@"endDate"] = endDateStr;
            [sql appendString:@" and a.cbilldate <= :endDate"];
        }
        
        [sql appendString:@" order by a.cbilldate"];
        
        FMResultSet *rs = [db executeQuery:sql withParameterDictionary:params];
        if (!rs) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSDictionary *result = [self organiseDataWithResult:rs periodType:periodType startDate:startDate endDate:endDate];
        if (success) {
            SSJDispatchMainAsync(^{
                success(result);
            });
        }
    }];
}

+ (SSJDatePeriodType)periodTypeWithDimension:(SSJTimeDimension)dimension {
    switch (dimension) {
        case SSJTimeDimensionDay:
            return SSJDatePeriodTypeDay;
            break;
            
        case SSJTimeDimensionWeek:
            return SSJDatePeriodTypeWeek;
            break;
            
        case SSJTimeDimensionMonth:
            return SSJDatePeriodTypeMonth;
            break;
            
        case SSJTimeDimensionUnknown:
            return SSJDatePeriodTypeUnknown;
            break;
    }
}

+ (NSDictionary *)organiseDataWithResult:(FMResultSet *)resultSet periodType:(SSJDatePeriodType)periodType startDate:(NSDate *)startDate endDate:(NSDate *)endDate {
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
    [resultSet close];
    
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
    
    return result;
}

@end
