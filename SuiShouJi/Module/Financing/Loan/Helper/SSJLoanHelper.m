//
//  SSJLoanHelper.m
//  SuiShouJi
//
//  Created by old lang on 16/8/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanHelper.h"
#import "SSJDatabaseQueue.h"

@implementation SSJLoanHelper

+ (void)queryForLoanModelsWithFundID:(NSString *)fundID
                       colseOutState:(int)state
                             success:(void (^)(NSArray <SSJLoanModel *>*list))success
                             failure:(void (^)(NSError *error))failure {
    
    NSMutableString *sqlStr = [[NSString stringWithFormat:@"select * from bk_loan where cuserid = '%@' and cthefundid = '%@' and operatortype <> 2", SSJUSERID(), fundID] mutableCopy];
    switch (state) {
        case 0:
        case 1:
            [sqlStr appendFormat:@" and iend = %d", state];
            break;
            
        case 2:
            break;
            
        default:
            SSJPRINT(@"警告：参数state无效");
            if (failure) {
                SSJDispatchMainAsync(^{
                    NSError *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"参数state无效，有效值0、1、2"}];
                    failure(error);
                });
            }
            break;
    }
    
    [sqlStr appendString:@" order by jmoney desc"];
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:sqlStr];
        if (!result) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        // 到期未结算
        NSMutableArray *list1 = [NSMutableArray array];
        
        // 未到期已结算
        NSMutableArray *list2 = [NSMutableArray array];
        
        // 其他
        NSMutableArray *list3 = [NSMutableArray array];
        
        while ([result next]) {
            SSJLoanModel *model = [SSJLoanModel modelWithResultSet:result];
            
            NSDate *repaymentDate = [NSDate dateWithString:model.repaymentDate formatString:@"yyyy-MM-dd"];
            NSDate *nowDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day];
            
            // 排序顺序：1.到期未结算 2.未到期已结算 3.其他
            if (!model.closeOut && [repaymentDate compare:nowDate] != NSOrderedDescending) {
                [list1 addObject:model];
            } else if (model.closeOut && [nowDate compare:repaymentDate] == NSOrderedDescending) {
                [list2 addObject:model];
            } else {
                [list3 addObject:model];
            }
        }
        
        NSMutableArray *list = [NSMutableArray arrayWithCapacity:list1.count + list2.count + list3.count];
        [list addObjectsFromArray:list1];
        [list addObjectsFromArray:list2];
        [list addObjectsFromArray:list3];
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(list);
            });
        }
    }];
}

+ (void)saveLoanModel:(SSJLoanModel *)model
              success:(void (^)())success
              failure:(void (^)(NSError *error))failure {
    
    NSString *booksID = SSJGetCurrentBooksType();
    
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        FMResultSet *resultSet = [db executeQuery:@"select * from bk_loan where loanid = ?", model.ID];
        if (!resultSet) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        SSJLoanModel *newestModel = nil;
        if ([resultSet next]) {
            newestModel = [SSJLoanModel modelWithResultSet:resultSet];
        }
        
        // 如果当前的借贷记录已经删除，就当作成功处理（这种情况发生在查询记录后在另一个客户端上删除了）
        if (newestModel.operatorType == 2) {
            if (success) {
                SSJDispatchMainAsync(^{
                    success();
                });
            }
            return;
        }
        
        // 创建或更新借贷记录、转账流水
        if (![self saveLoanModel:model booksID:booksID inDatabase:db]) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        // 创建或更新提醒
#warning todo
        
        
        if (success) {
            SSJDispatchMainAsync(^{
                success();
            });
        }
    }];
}

+ (void)deleteLoanModel:(SSJLoanModel *)model
                success:(void (^)())success
                failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        if (![db executeUpdate:@"update bk_loan set operatortype = ?, iversion = ?, cwritedate = ? where loanid = ?", @2, @(SSJSyncVersion()), writeDate, model.ID]) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        // 拼接要删除的转帐流水id
        NSMutableString *chargeIDs = [NSMutableString string];
        if (model.chargeID.length) {
            [chargeIDs appendFormat:@"'%@'", model.chargeID];
        }
        
        if (model.targetChargeID.length) {
            [chargeIDs appendFormat:@", '%@'", model.targetChargeID];
        }
        
        if (model.endChargeID.length) {
            [chargeIDs appendFormat:@", '%@'", model.endChargeID];
        }
        
        if (model.endTargetChargeID.length) {
            [chargeIDs appendFormat:@", '%@'", model.endTargetChargeID];
        }
        
        // 将要删除的转帐流水operatortype改为2
        NSString *sqlStr = [NSString stringWithFormat:@"update bk_user_charge set operatortype = %@, iversion = %@, cwritedate = '%@' where ichargeid in (%@)", @2, @(SSJSyncVersion()), writeDate, chargeIDs];
        if (![db executeUpdate:sqlStr]) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        if (![db executeUpdate:@"update bk_user_remind set operatortype = ?, iversion = ?, cwritedate = ? where cremindid = ?", @2, @(SSJSyncVersion()), writeDate, model.remindID]) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success();
            });
        }
    }];
}

+ (void)closeOutLoanModel:(SSJLoanModel *)model
                  success:(void (^)())success
                  failure:(void (^)(NSError *error))failure {
    
    NSString *booksID = SSJGetCurrentBooksType();
    
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        FMResultSet *resultSet = [db executeQuery:@"select * from bk_loan where loanid = ?", model.ID];
        if (!resultSet) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        SSJLoanModel *newestModel = nil;
        if ([resultSet next]) {
            newestModel = [SSJLoanModel modelWithResultSet:resultSet];
        }
        
        // 如果当前的借贷记录已结清或删除，直接执行成功回调
        if (newestModel.operatorType == 2 || newestModel.closeOut) {
            if (success) {
                SSJDispatchMainAsync(^{
                    success();
                });
            }
            return;
        }
        
        NSString *rollOutChargeID = SSJUUID();
        NSString *rollInChargeID = SSJUUID();
        
        NSString *rollOutFundID = nil;
        NSString *rollInFundID = nil;
        
        NSString *endChargeID = nil;
        NSString *endTargetChargeID = nil;
        
        switch (model.type) {
            case SSJLoanTypeLend:
                rollOutFundID = model.targetFundID;
                rollInFundID = model.fundID;
                endChargeID = rollInChargeID;
                endTargetChargeID = rollOutChargeID;
                
                break;
                
            case SSJLoanTypeBorrow:
                rollOutFundID = model.fundID;
                rollInFundID = model.targetFundID;
                endChargeID = rollOutChargeID;
                endTargetChargeID = rollInChargeID;
                
                break;
        }
        
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        // 结清转出流水
        if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, cbilldate, cbooksid, iversion, operatortype, cwritedate) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", rollOutChargeID, model.userID, model.jMoney, @4, rollOutFundID, model.endDate, booksID, @(SSJSyncVersion()), @(0), writeDate]) {
            
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            
            return;
        }
        
        // 结清转入流水
        if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, cbilldate, cbooksid, iversion, operatortype, cwritedate) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", rollInFundID, model.userID, model.jMoney, @3, rollInFundID, model.endDate, booksID, @(SSJSyncVersion()), @(0), writeDate]) {
            
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            
            return;
        }
        
        // 创建借贷记录产生的转帐流水的writedate不能和结清借贷产生的转帐流水的writedate一样，否则匹配转帐时会错乱
        writeDate = [[[NSDate date] dateByAddingTimeInterval:1] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        // 修改所属转帐流水
        if (![db executeUpdate:@"update bk_user_charge set imoney = ?, iversion = ?, operatortype = ?, cwritedate = ? where ichargeid = ?", model.jMoney, @(SSJSyncVersion()), @1, writeDate, model.chargeID]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            
            return;
        }
        
        // 修改目标转帐流水
        if (![db executeUpdate:@"update bk_user_charge set imoney = ?, ifunsid = ?, iversion = ?, operatortype = ?, cwritedate = ? where ichargeid = ?", model.jMoney, model.targetFundID, @(SSJSyncVersion()), @1, writeDate, model.targetChargeID]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            
            return;
        }
        
        // 修改当前借贷记录的结清状态
        if (![db executeUpdate:@"update bk_loan set iend = ?, jmoney = ?, rate = ?, ctargetfundid = ?, cenddate = ?, cethecharge = ?, cetargetcharge = ?, iversion = ?, operatortype = ?, cwritedate = ? where loanid = ?", @1, model.jMoney, model.rate, model.targetFundID, model.endDate, endChargeID, endTargetChargeID, @(SSJSyncVersion()), @1, writeDate, model.ID]) {
            
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            
            return;
        }
        
        // 关闭提醒
        if (![db executeUpdate:@"update bk_user_remind set istate = ?, iversion = ?, operatortype = ?, cwritedate = ? where cremindid = ? and operatortype <> 2", @0, @(SSJSyncVersion()), @1, writeDate, model.remindID]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            
            return;
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success();
            });
        }
    }];
}

+ (void)recoverLoanModel:(SSJLoanModel *)model
                 success:(void (^)())success
                 failure:(void (^)(NSError *error))failure {
    
}

+ (BOOL)saveLoanModel:(SSJLoanModel *)model booksID:(NSString *)booksID inDatabase:(FMDatabase *)db {
    
    NSString *rollOutFundID = nil;
    NSString *rollInFundID = nil;
    NSString *rollOutChargeID = nil;
    NSString *rollInChargeID = nil;
    
    switch (model.type) {
        case SSJLoanTypeLend:
            rollOutFundID = model.fundID;
            rollInFundID = model.targetFundID;
            rollOutChargeID = model.chargeID;
            rollInChargeID = model.targetChargeID;
            
            break;
            
        case SSJLoanTypeBorrow:
            rollOutFundID = model.targetFundID;
            rollInFundID = model.fundID;
            rollOutChargeID = model.targetChargeID;
            rollInChargeID = model.chargeID;
            
            break;
    }
    
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    // 转出流水
    if (![db executeUpdate:@"replace into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, cbilldate, cbooksid, iversion, operatortype, cwritedate) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", rollOutChargeID, model.userID, model.jMoney, @4, rollOutFundID, model.borrowDate, booksID, @(SSJSyncVersion()), @(model.operatorType), writeDate]) {
        return NO;
    }
    
    // 转入流水
    if (![db executeUpdate:@"replace into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, cbilldate, cbooksid, iversion, operatortype, cwritedate) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", rollInChargeID, model.userID, model.jMoney, @3, rollInFundID, model.borrowDate, booksID, @(SSJSyncVersion()), @(model.operatorType), writeDate]) {
        return NO;
    }
    
    NSMutableDictionary *modelInfo = model.mj_keyValues;
    [modelInfo setObject:writeDate forKey:@"writeDate"];
    [modelInfo setObject:@(SSJSyncVersion()) forKey:@"version"];
    
    if (![db executeUpdate:@"replace into bk_loan (loanid, cuserid, lender, jmoney, cthefundid, ctargetfundid, cthecharge, ctargetcharge, cethecharge, cetargetcharge, cborrowdate, crepaymentdate, cenddate, rate, memo, cremindid, interest, iend, itype, cwritedate, operatortype, iversion) values (:ID, :userID, :lender, :jMoney, :fundID, :targetFundID, :chargeID, :targetChargeID, :endChargeID, :endTargetChargeID, :borrowDate, :repaymentDate, :endDate, :rate, :memo, :remindID, :interest, :closeOut, :type, :writeDate, :operatorType, :version)", modelInfo]) {
        return NO;
    }
    
    return YES;
}

@end
