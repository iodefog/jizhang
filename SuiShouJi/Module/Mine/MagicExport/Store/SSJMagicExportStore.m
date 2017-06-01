//
//  SSJMagicExportStore.m
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportStore.h"
#import "SSJDatabaseQueue.h"

NSString *const SSJMagicExportStoreBeginDateKey = @"SSJMagicExportStoreBeginDateKey";
NSString *const SSJMagicExportStoreEndDateKey = @"SSJMagicExportStoreEndDateKey";

@implementation SSJMagicExportStore

+ (void)queryBillPeriodWithBookId:(NSString *)bookId
                          success:(void (^)(NSDictionary<SSJMagicExportStoreDateKey *, NSDate *> *result))success
                          failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *tBooksId = bookId;
        if (!tBooksId.length) {
            tBooksId = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?", SSJUSERID()];
            if (!tBooksId.length) {
                tBooksId = SSJUSERID();
            }
        }
        
        NSMutableDictionary *params = [@{} mutableCopy];
        NSString *sql = nil;
        if ([tBooksId isEqualToString:SSJAllBooksIds]) {
            // 三种情况：
            // 1.个人账本非借贷流水：需要限制用户id为当前用户、流水时间不能超过当前时间
            // 2.个人账本借贷流水：需要限制用户id为当前用户，因为借贷可以生成未来时间流水，所以不需要限制流水时间
            // 3.共享账本流水：当前用户加入的共享账本的所有成员流水，并限制流水时间不能超过当前时间
            params[@"userId"] = SSJUSERID();
            params[@"loanChargeType"] = @(SSJChargeIdTypeLoan);
            params[@"shareChargeType"] = @(SSJChargeIdTypeShareBooks);
            params[@"memberState"] = @(SSJShareBooksMemberStateNormal);
            sql = @"select max(cbilldate) as maxDate, min(cbilldate) as minDate from bk_user_charge where (ichargetype <> :shareChargeType and ichargetype <> :loanChargeType and cuserid = :userId and cbilldate <= datetime('now', 'localtime')) or (ichargetype = :loanChargeType and cuserid = :userId) or (ichargetype = :shareChargeType and cbooksid in (select cbooksid from bk_share_books_member where cmemberid = :userId and istate = :memberState) and cbilldate <= datetime('now', 'localtime')) and operatortype <> 2";
        } else {
            params[@"booksId"] = tBooksId;
            sql = @"select max(uc.cbilldate) as maxDate, min(uc.cbilldate) as minDate from bk_user_charge as uc, bk_bill_type as bt where uc.ibillid = bt.id and uc.operatortype <> 2 and uc.cbilldate <= datetime('now', 'localtime') and uc.cbooksid = :booksId and bt.istate <> 2";
        }
        
        FMResultSet *result = [db executeQuery:sql withParameterDictionary:params];
        if (!result) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSMutableDictionary *dateInfo = [NSMutableDictionary dictionaryWithCapacity:2];
        while ([result next]) {
            NSString *beginDateStr = [result stringForColumn:@"minDate"];
            NSString *endDateStr = [result stringForColumn:@"maxDate"];
            NSDate *beginDate = [NSDate dateWithString:beginDateStr formatString:@"yyyy-MM-dd"];
            NSDate *endDate = [NSDate dateWithString:endDateStr formatString:@"yyyy-MM-dd"];
            if (beginDate) {
                [dateInfo setObject:beginDate forKey:SSJMagicExportStoreBeginDateKey];
            }
            if (endDate) {
                [dateInfo setObject:endDate forKey:SSJMagicExportStoreEndDateKey];
            }
        }
        [result close];
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(dateInfo);
            });
        }
    }];
}

+ (void)queryAllBillDateWithBillId:(NSString *)billId
                          billType:(SSJBillType)billType
                           booksId:(NSString *)booksId
               containOtherMembers:(BOOL)containOtherMembers
                           success:(void (^)(NSArray<NSDate *> *result))success
                           failure:(void (^)(NSError *error))failure {
    
    if (billType != SSJBillTypeUnknown && billId) {
        if (failure) {
            SSJDispatchMainAsync(^{
                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"billType和billTypeId不能同时都传值"}]);
            });
        }
        return;
    }
    
    if (billType == SSJBillTypeUnknown && !billId) {
        if (failure) {
            SSJDispatchMainAsync(^{
                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"billType、billTypeId两个参数中必须传一个"}]);
            });
        }
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSMutableString *sql = nil;
        NSMutableDictionary *params = nil;
        
        NSString *tBooksId = booksId;
        if (!tBooksId.length) {
            tBooksId = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?", SSJUSERID()];
            if (!tBooksId.length) {
                tBooksId = SSJUSERID();
            }
        }
        
        if ([tBooksId isEqualToString:SSJAllBooksIds] && containOtherMembers) {
            // 三种情况：
            // 1.个人账本非借贷流水：需要限制用户id为当前用户、流水时间不能超过当前时间
            // 2.个人账本借贷流水：需要限制用户id为当前用户，因为借贷可以生成未来时间流水，所以不需要限制流水时间
            // 3.共享账本流水：当前用户加入的共享账本的所有成员流水，并限制流水时间不能超过当前时间
            params = [@{@"shareChargeType_1":@(SSJChargeIdTypeShareBooks),
                        @"loanChargeType_1":@(SSJChargeIdTypeLoan),
                        @"userId_1":SSJUSERID(),
                        @"shareChargeType_2":@(SSJChargeIdTypeShareBooks),
                        @"loanChargeType_2":@(SSJChargeIdTypeLoan),
                        @"userId_2":SSJUSERID(),
                        @"userId_3":SSJUSERID(),
                        @"memberState":@(SSJShareBooksMemberStateNormal)} mutableCopy];
            sql = [@"select distinct(uc.cbilldate) from bk_user_charge as uc, bk_bill_type as bt where (uc.ichargetype <> :shareChargeType_1 and uc.ichargetype <> :loanChargeType_1 and uc.cuserid = :userId_1 and uc.cbilldate <= datetime('now', 'localtime')) or (uc.ichargetype = :loanChargeType_2 and uc.cuserid = :userId_2) or (uc.ichargetype = :shareChargeType_2 and uc.cbooksid in (select cbooksid from bk_share_books_member where cmemberid = :userId_3 and istate = :memberState) and uc.cbilldate <= datetime('now', 'localtime')) and uc.operatortype <> 2" mutableCopy];
        } else {
            params = [@{} mutableCopy];
            sql = [@"select distinct(uc.cbilldate) from bk_user_charge as uc, bk_bill_type as bt where uc.ibillid = bt.id and bt.istate <> 2 and uc.operatortype <> 2 and uc.cbilldate <= datetime('now', 'localtime')" mutableCopy];
            if ([tBooksId isEqualToString:SSJAllBooksIds]) {
                params[@"userId"] = SSJUSERID();
                [sql appendString:@" and uc.cuserid = :userId"];
            } else {
                params[@"booksId"] = tBooksId;
                [sql appendString:@" and uc.cbooksid = :booksId"];
            }
        }
        
        if (billId) {
            params[@"billId"] = billId;
            [sql appendString:@" and uc.ibillid = :billId"];
        } else {
            if (billType == SSJBillTypeIncome || billType == SSJBillTypePay) {
                params[@"billType"] = @(billType);
                [sql appendString:@" and bt.itype = :billType"];
            }
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
        
        NSMutableArray *billDates = [[NSMutableArray alloc] init];
        while ([rs next]) {
            NSString *dateStr = [rs stringForColumn:@"cbilldate"];
            NSDate *date = [NSDate dateWithString:dateStr formatString:@"yyyy-MM-dd"];
            [billDates addObject:date];
        }
        [rs close];
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(billDates);
            });
        }
    }];
}

@end
