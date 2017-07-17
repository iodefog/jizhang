//
//  SSJShareBooksMemberStore.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksMemberStore.h"
#import "SSJDatabaseQueue.h"

@implementation SSJShareBooksMemberStore

+ (void)queryMemberItemWithMemberId:(NSString *)memberId
                            booksId:(NSString *)booksId
                            Success:(void(^)(SSJUserItem * memberItem))success
                            failure:(void(^)(NSError *error))failure 
 {
     
    if (!memberId.length) {
        SSJPRINT(@"memberid不正确");
    }
     
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select bm.cicon, bf.cmark from bk_share_books_member bm,bk_share_books_friends_mark bf where bm.cmemberid = ? and bm.cmemberid = bf.cfriendid and bm.cbooksid = ? and bm.cbooksid = bf.cbooksid",memberId,booksId];
        if (!rs) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        SSJUserItem *memberItem = [[SSJUserItem alloc] init];
        
        while ([rs next]) {
            memberItem.nickName = [rs stringForColumn:@"cmark"];
            memberItem.icon = [rs stringForColumn:@"cicon"];
            memberItem.userId = memberId;
        }
        
        [rs close];
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(memberItem);
            });
        }
    }];
}

+ (void)queryForPeriodListWithIncomeOrPayType:(SSJBillType)type
                                     memberId:(NSString *)memberId
                                      booksId:(NSString *)booksId
                                      success:(void (^)(NSArray<SSJDatePeriod *> *periods))success
                                      failure:(void (^)(NSError *))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        // 查询有数据的月份
        FMResultSet *result = nil;
        switch (type) {
            case SSJBillTypeIncome:
            case SSJBillTypePay: {
                NSString *incomeOrPayType = type == SSJBillTypeIncome ? @"0" : @"1";
                result = [db executeQuery:@"select distinct strftime('%Y-%m', a.cbilldate) from bk_user_charge as a, bk_user_bill_type as b where a.ibillid = b.cbillid and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and a.cbooksid = ? and ichargetype = ? and b.itype = ? order by a.cbilldate", memberId, booksId, incomeOrPayType, @(SSJChargeIdTypeShareBooks)];
                
            }   break;
                
            case SSJBillTypeSurplus: {
                result = [db executeQuery:@"select distinct strftime('%Y-%m', a.cbilldate) from bk_user_charge as a, bk_user_bill_type as b where a.cuserid = ? and a.ibillid = b.cbillid and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and a.cbooksid = ? and ichargetype = ? order by a.cbilldate", memberId, booksId, @(SSJChargeIdTypeShareBooks)];
                
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
                       memberId:(NSString *)memberId
                      startDate:(NSDate *)startDate
                        endDate:(NSDate *)endDate
                        success:(void(^)(NSArray<SSJReportFormsItem *> *result))success
                        failure:(void (^)(NSError *error))failure {
    
    switch (type) {
        case SSJBillTypeIncome:
        case SSJBillTypePay:
            [self queryForIncomeOrPayChargeWithType:type booksId:booksId memberId:memberId startDate:startDate endDate:endDate success:success failure:failure];
            break;
            
        case SSJBillTypeSurplus:
            [self queryForSurplusWithBooksId:booksId memberId:memberId startDate:startDate endDate:endDate success:success failure:failure];
            break;
            
        case SSJBillTypeUnknown:
            failure(nil);
            break;
    }
}

//  查询收支数据
+ (void)queryForIncomeOrPayChargeWithType:(SSJBillType)type
                                  booksId:(NSString *)booksId
                                 memberId:(NSString *)memberId
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
    
    //  查询不同收支类型的总额
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *tBooksId = booksId;
        if (!tBooksId) {
            tBooksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", SSJUSERID()];
            tBooksId = tBooksId.length > 0 ? tBooksId : SSJUSERID();
        }
        
        NSMutableString *sql_1 = [@"select sum(a.IMONEY) from BK_USER_CHARGE as a, BK_USER_BILL_TYPE as b where a.IBILLID = b.CBILLID and a.cbilldate >= :beginDateStr and a.cbilldate <= :endDateStr and a.cbilldate <= datetime('now', 'localtime') and a.cuserid = :userId and a.operatortype <> 2 and b.itype = :type" mutableCopy];
        
        NSMutableDictionary *params_1 = [@{@"beginDateStr":beginDateStr,
                                           @"endDateStr":endDateStr,
                                           @"userId":memberId,
                                           @"type":incomeOrPayType} mutableCopy];
        
        if (![tBooksId isEqualToString:SSJAllBooksIds]) {
            [sql_1 appendString:[NSString stringWithFormat:@" and a.cbooksid = :booksId and ichargetype = %ld",(long)SSJChargeIdTypeShareBooks]];
            [params_1 setObject:tBooksId forKey:@"booksId"];
        }
        
        FMResultSet *amountResultSet = [db executeQuery:sql_1 withParameterDictionary:params_1];
        
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
        
        [amountResultSet close];
        
        if (amount == 0) {
            SSJDispatch_main_async_safe(^{
                success(nil);
            });
            
            return;
        }
        
        //  查询不同收支类型相应的金额、名称、图标、颜色
        NSMutableString *sql_2 = [@"select sum(a.imoney), b.cbillid, b.cname, b.cicoin, b.ccolor from bk_user_charge as a, bk_user_bill_type as b where a.cuserid = :userId and a.ibillid = b.cbillid and a.cbilldate >= :beginDateStr and a.cbilldate <= :endDateStr and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and b.itype = :type" mutableCopy];
        
        NSMutableDictionary *params_2 = [@{@"userId":memberId,
                                           @"beginDateStr":beginDateStr,
                                           @"endDateStr":endDateStr,
                                           @"type":incomeOrPayType} mutableCopy];
        
        if (![tBooksId isEqualToString:SSJAllBooksIds]) {
            [sql_2 appendString:[NSString stringWithFormat:@" and a.cbooksid = :booksId and ichargetype = %ld",(long)SSJChargeIdTypeShareBooks]];
            [params_2 setObject:tBooksId forKey:@"booksId"];
        }
        
        [sql_2 appendString:@" group by b.cbillid"];
        
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
            item.ID = [resultSet stringForColumn:@"cbillid"];
            item.money = [resultSet doubleForColumn:@"sum(a.imoney)"];
            item.scale = item.money / amount;
            item.colorValue = [resultSet stringForColumn:@"ccolor"];
            item.imageName = [resultSet stringForColumn:@"cicoin"];
            item.name = [resultSet stringForColumn:@"cname"];
            [result addObject:item];
        }
        
        [resultSet close];
        
        SSJDispatch_main_async_safe(^{
            success(result);
        });
    }];
}

//  查询结余数据
+ (void)queryForSurplusWithBooksId:(NSString *)booksId
                          memberId:(NSString *)memberId
                         startDate:(NSDate *)startDate
                           endDate:(NSDate *)endDate
                           success:(void (^)(NSArray <SSJReportFormsItem *> *result))success
                           failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *tBooksId = booksId;
        
        NSString *beginDateStr = [startDate formattedDateWithFormat:@"yyyy-MM-dd"];
        NSString *endDateStr = [endDate formattedDateWithFormat:@"yyyy-MM-dd"];
        
        NSMutableString *sql = [@"select sum(a.imoney), b.itype from bk_user_charge as a, bk_user_bill_type as b where a.cuserid = :userId and a.ibillid = b.cbillid and a.cbilldate >= :beginDateStr and a.cbilldate <= :endDateStr and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2" mutableCopy];
        
        NSMutableDictionary *params = [@{@"userId":memberId,
                                         @"beginDateStr":beginDateStr,
                                         @"endDateStr":endDateStr} mutableCopy];
        
        if (![tBooksId isEqualToString:SSJAllBooksIds]) {
            [sql appendString:@" and a.cbooksid = :booksId"];
            [params setObject:tBooksId forKey:@"booksId"];
        }
        [sql appendString:@" group by b.itype order by b.itype desc"];
        
        FMResultSet *resultSet = [db executeQuery:sql withParameterDictionary:params];
        
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

+ (void)saveNickNameWithNickName:(NSString *)name
                        memberId:(NSString *)memberId
                        booksid:(NSString *)booksid
                  success:(void (^)(NSString * name))success
                  failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        if (![db executeUpdate:@"update bk_share_books_friends_mark set cmark = ?, cwritedate = ?, iversion = ? ,operatortype = 2 where cfriendid = ? and cuserid = ? and cbooksid = ?", name, [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], @(SSJSyncVersion()), memberId, SSJUSERID(), booksid]) {
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        
        
        
        SSJDispatch_main_async_safe(^{
            success(name);
        });
    }];
}

@end
