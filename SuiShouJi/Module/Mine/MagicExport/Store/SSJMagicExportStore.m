//
//  SSJMagicExportStore.m
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportStore.h"
#import "SSJDatabaseQueue.h"

@implementation SSJMagicExportStore

+ (void)queryAllBillDateWithBillId:(NSString *)billId
                          billName:(NSString *)billName
                          billType:(SSJBillType)billType
                           booksId:(NSString *)booksId
                            userId:(NSString *)userId
            containsSpecialCharges:(BOOL)containsSpecialCharges
                           success:(void (^)(NSArray<NSDate *> *result))success
                           failure:(void (^)(NSError *error))failure {
    if (!billId && billType == SSJBillTypeUnknown) {
        if (failure) {
            SSJDispatchMainAsync(^{
                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"billType参数无效"}]);
            });
        }
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSString *tBooksId = booksId;
        if (!tBooksId.length) {
            tBooksId = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?", SSJUSERID()];
            if (!tBooksId.length) {
                tBooksId = SSJUSERID();
            }
        }
        
        NSMutableDictionary *params = [@{} mutableCopy];
        NSMutableString *sql = nil;
        
        if (containsSpecialCharges) {
            // 1.非借贷流水：需要限制流水时间不能超过当前时间
            // 2.借贷流水：借贷可以生成未来时间流水，所以不需要限制流水时间
            params[@"loanChargeType"] = @(SSJChargeIdTypeLoan);
            sql = [@"select distinct(uc.cbilldate) from bk_user_charge as uc, bk_user_bill_type as bt where uc.ibillid = bt.cbillid and ((uc.cuserid = bt.cuserid and uc.cbooksid = bt.cbooksid) or (length(bt.cbillid) < 4)) and uc.operatortype <> 2 and ((uc.ichargetype = :loanChargeType) or (uc.ichargetype != :loanChargeType and uc.cbilldate <= datetime('now', 'localtime')))" mutableCopy];
        } else {
            sql = [@"select distinct(uc.cbilldate) from bk_user_charge as uc, bk_user_bill_type as bt where uc.ibillid = bt.cbillid and uc.cuserid = bt.cuserid and uc.cbooksid = bt.cbooksid and uc.operatortype <> 2 and uc.cbilldate <= datetime('now', 'localtime')" mutableCopy];
        }
        
        if (![tBooksId isEqualToString:SSJAllBooksIds]) {
            params[@"booksId"] = tBooksId;
            [sql appendString:@" and uc.cbooksid = :booksId"];
        }
        
        if (![userId isEqualToString:SSJAllMembersId]) {
            params[@"userId"] = userId ?: SSJUSERID();
            [sql appendString:@" and uc.cuserid = :userId"];
        }
        
        if (billId) {
            params[@"billId"] = billId;
            [sql appendString:@" and uc.ibillid = :billId"];
        }
        
        if (billName) {
            params[@"billName"] = billName;
            [sql appendString:@" and bt.cname = :billName"];
        }
        
        if (billType == SSJBillTypePay || billType == SSJBillTypeIncome) {
            params[@"billType"] = @(billType);
            [sql appendString:@" and bt.itype = :billType"];
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
