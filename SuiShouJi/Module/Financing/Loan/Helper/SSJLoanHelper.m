//
//  SSJLoanHelper.m
//  SuiShouJi
//
//  Created by old lang on 16/8/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanHelper.h"
#import "SSJDatabaseQueue.h"
#import "SSJLocalNotificationStore.h"
#import "SSJLoanFundAccountSelectionViewItem.h"
#import "SSJFundAccountTable.h"

NSString *const SSJFundItemListKey = @"SSJFundItemListKey";
NSString *const SSJFundIDListKey = @"SSJFundIDListKey";

@implementation SSJLoanHelper

+ (void)queryForLoanModelsWithFundID:(NSString *)fundID
                       colseOutState:(int)state
                             success:(void (^)(NSArray <SSJLoanModel *>*list))success
                             failure:(void (^)(NSError *error))failure {
    
    NSMutableString *sqlStr = [[NSString stringWithFormat:@"select l.*, fi.cicoin from bk_loan as l, bk_fund_info as fi where l.cthefundid = fi.cfundid and l.cuserid = '%@' and l.cthefundid = '%@' and l.operatortype <> 2", SSJUSERID(), fundID] mutableCopy];
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
            
            NSDate *nowDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day];
            
            // 排序顺序：1.到期未结算 2.未到期已结算 3.其他
            if (!model.closeOut && [model.repaymentDate compare:nowDate] != NSOrderedAscending) {
                [list1 addObject:model];
            } else if (model.closeOut && [model.repaymentDate compare:nowDate] == NSOrderedAscending) {
                [list2 addObject:model];
            } else {
                [list3 addObject:model];
            }
        }
        
        [result close];
        
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

+ (void)queryForLoanModelWithLoanID:(NSString *)loanID
                            success:(void (^)(SSJLoanModel *model))success
                            failure:(void (^)(NSError *error))failure {
    
    if (!loanID.length) {
        SSJDispatchMainAsync(^{
            NSError *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"借贷ID不能为空"}];
            failure(error);
        });
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select * from bk_loan where loanid = ?", loanID];
        if (!resultSet) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        SSJLoanModel *model = [[SSJLoanModel alloc] init];
        while ([resultSet next]) {
            model.ID = [resultSet stringForColumn:@"loanid"];
            model.userID = [resultSet stringForColumn:@"cuserid"];
            model.lender = [resultSet stringForColumn:@"lender"];
            model.jMoney = [resultSet doubleForColumn:@"jmoney"];
            model.fundID = [resultSet stringForColumn:@"cthefundid"];
            model.targetFundID = [resultSet stringForColumn:@"ctargetfundid"];
            model.endTargetFundID = [resultSet stringForColumn:@"cetarget"];
            model.chargeID = [resultSet stringForColumn:@"cthecharge"];
            model.targetChargeID = [resultSet stringForColumn:@"ctargetcharge"];
            model.endChargeID = [resultSet stringForColumn:@"cethecharge"];
            model.endTargetChargeID = [resultSet stringForColumn:@"cetargetcharge"];
            model.interestChargeID = [resultSet stringForColumn:@"cinterestid"];
            model.borrowDate = [NSDate dateWithString:[resultSet stringForColumn:@"cborrowdate"] formatString:@"yyyy-MM-dd"];
            model.repaymentDate = [NSDate dateWithString:[resultSet stringForColumn:@"crepaymentdate"] formatString:@"yyyy-MM-dd"];
            model.endDate = [NSDate dateWithString:[resultSet stringForColumn:@"cenddate"] formatString:@"yyyy-MM-dd"];
            model.rate = [resultSet doubleForColumn:@"rate"];
            model.memo = [resultSet stringForColumn:@"memo"];
            model.remindID = [resultSet stringForColumn:@"cremindid"];
            model.interest = [resultSet boolForColumn:@"interest"];
            model.closeOut = [resultSet boolForColumn:@"iend"];
            model.type = [resultSet intForColumn:@"itype"];
            model.operatorType = [resultSet intForColumn:@"operatorType"];
            model.version = [resultSet longLongIntForColumn:@"iversion"];
            model.writeDate = [NSDate dateWithString:[resultSet stringForColumn:@"cwritedate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
        }
        [resultSet close];
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(model);
            });
        }
    }];
}

+ (void)saveLoanModel:(SSJLoanModel *)loanModel
          remindModel:(SSJReminderItem *)remindModel
              success:(void (^)())success
              failure:(void (^)(NSError *error))failure {
    
    NSString *booksID = SSJGetCurrentBooksType();
    
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        FMResultSet *resultSet = [db executeQuery:@"select * from bk_loan where loanid = ?", loanModel.ID];
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
        [resultSet close];
        
        // 如果当前的借贷记录已经删除，就当作成功处理（这种情况发生在查询记录后在另一个客户端上删除了）
        if (newestModel.operatorType == 2) {
            if (success) {
                SSJDispatchMainAsync(^{
                    success();
                });
            }
            return;
        }
        
        loanModel.version = SSJSyncVersion();
        loanModel.writeDate = [NSDate date];
        
        // 创建或更新借贷记录、转账流水
        if (![self saveLoanModel:loanModel booksID:booksID inDatabase:db]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        // 更新资金账户的余额
        if (![SSJFundAccountTable updateBalanceForUserId:loanModel.userID inDatabase:db]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        // 存储提醒记录
        if (remindModel) {
            NSError *error = [SSJLocalNotificationStore saveReminderWithReminderItem:remindModel inDatabase:db];
            if (error) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
        }
        
        //
        if (![db executeUpdate:@"update bk_fund_info set idisplay = 1 where cfundid = ?", loanModel.fundID]) {
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

+ (void)deleteLoanModel:(SSJLoanModel *)model
                success:(void (^)())success
                failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        // 将借贷记录的operatortype改为2
        if (![db executeUpdate:@"update bk_loan set operatortype = ?, iversion = ?, cwritedate = ? where loanid = ?", @2, @(SSJSyncVersion()), writeDate, model.ID]) {
            *rollback = YES;
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
        
        if (model.interestChargeID.length) {
            [chargeIDs appendFormat:@", '%@'", model.interestChargeID];
        }
        
        // 将要删除的转帐流水operatortype改为2
        NSString *sqlStr = [NSString stringWithFormat:@"update bk_user_charge set operatortype = %@, iversion = %@, cwritedate = '%@' where ichargeid in (%@)", @2, @(SSJSyncVersion()), writeDate, chargeIDs];
        if (![db executeUpdate:sqlStr]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        // 将提醒的operatortype改为2
        if (![db executeUpdate:@"update bk_user_remind set operatortype = ?, iversion = ?, cwritedate = ? where cremindid = ?", @2, @(SSJSyncVersion()), writeDate, model.remindID]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        // 更新资金账户余额
        if (![SSJFundAccountTable updateBalanceForUserId:model.userID inDatabase:db]) {
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
        [resultSet close];
        
        // 如果当前的借贷记录已结清或删除，直接执行成功回调
        if (newestModel.operatorType == 2 || newestModel.closeOut) {
            if (success) {
                SSJDispatchMainAsync(^{
                    success();
                });
            }
            return;
        }
        
        NSString *endChargeID = SSJUUID();
        NSString *endTargetChargeID = SSJUUID();
        NSString *interestChargeID = SSJUUID();
        
        NSString *endBillID = nil;
        NSString *endTargetBillID = nil;
        NSString *interestBillID = nil;
        
        switch (model.type) {
            case SSJLoanTypeLend:
                endBillID = @"4";
                endTargetBillID = @"3";
                interestBillID = @"2025";
                break;
                
            case SSJLoanTypeBorrow:
                endBillID = @"3";
                endTargetBillID = @"4";
                interestBillID = @"1030";
                break;
        }
        
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString *endDateStr = [model.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
        
        // 计算利息，利息只保留2位小数
        double interest = [[NSString stringWithFormat:@"%.2f", [self closeOutInterestWithLoanModel:model]] doubleValue];
        
        // 插入所属结清流水
        if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, cbilldate, cbooksid, loanid, iversion, operatortype, cwritedate) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", endChargeID, model.userID, @(model.jMoney), endBillID, model.fundID, endDateStr, booksID, model.ID, @(SSJSyncVersion()), @(0), writeDate]) {
            
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }

            return;
        }
        
        // 插入目标结清流水
        if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, cbilldate, cbooksid, loanid, iversion, operatortype, cwritedate) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", endTargetChargeID, model.userID, @(model.jMoney), endTargetBillID, model.endTargetFundID, endDateStr, booksID, model.ID, @(SSJSyncVersion()), @(0), writeDate]) {
            
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            
            return;
        }
        
        // 利息大于0就插入一条利息流水
        if (interest > 0) {
            if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, cbilldate, loanid, iversion, operatortype, cwritedate) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", interestChargeID, model.userID, @(interest), interestBillID, model.endTargetFundID, endDateStr, model.ID, @(SSJSyncVersion()), @(0), writeDate]) {
                
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure([db lastError]);
                    });
                }
                
                return;
            }
        }
        
        // 创建借贷记录产生的转帐流水的writedate不能和结清借贷产生的转帐流水的writedate一样，否则匹配转帐时会错乱
        writeDate = [[[NSDate date] dateByAddingTimeInterval:1] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        // 修改所属转帐流水
        if (![db executeUpdate:@"update bk_user_charge set imoney = ?, iversion = ?, operatortype = ?, cwritedate = ? where ichargeid = ?", @(model.jMoney), @(SSJSyncVersion()), @1, writeDate, model.chargeID]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            
            return;
        }
        
        // 修改目标转帐流水
        if (![db executeUpdate:@"update bk_user_charge set imoney = ?, iversion = ?, operatortype = ?, cwritedate = ? where ichargeid = ?", @(model.jMoney), @(SSJSyncVersion()), @1, writeDate, model.targetChargeID]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            
            return;
        }
        
        // 修改当前借贷记录的结清状态
        if (![db executeUpdate:@"update bk_loan set iend = ?, jmoney = ?, rate = ?, ctargetfundid = ?, cetarget = ?, cenddate = ?, cethecharge = ?, cetargetcharge = ?, cinterestid = ?, iversion = ?, operatortype = ?, cwritedate = ? where loanid = ?", @1, @(model.jMoney), @(model.rate), model.targetFundID, model.endTargetFundID, endDateStr, endChargeID, endTargetChargeID, interestChargeID, @(SSJSyncVersion()), @1, writeDate, model.ID]) {
            
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            
            return;
        }
        
        // 更新资金账户的余额
        if (![SSJFundAccountTable updateBalanceForUserId:model.userID inDatabase:db]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSString *remindName = nil;
        switch (model.type) {
            case SSJLoanTypeLend:
                remindName = [NSString stringWithFormat:@"被%@借%.2f元", model.lender ?: @"", model.jMoney];
                break;
                
            case SSJLoanTypeBorrow:
                remindName = [NSString stringWithFormat:@"欠%@钱款%.2f元", model.lender ?: @"", model.jMoney];
                break;
        }
        
        // 关闭提醒、更改提醒名称（因为结清时金额可以再次被用户编辑）
        if (![db executeUpdate:@"update bk_user_remind set istate = ?, cremindname = ?, iversion = ?, operatortype = ?, cwritedate = ? where cremindid = ? and operatortype <> 2", @0, remindName, @(SSJSyncVersion()), @1, writeDate, model.remindID]) {
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
        [resultSet close];
        
        // 如果当前的借贷记录已结清或删除，直接执行成功回调
        if (newestModel.operatorType == 2) {
            if (success) {
                SSJDispatchMainAsync(^{
                    success();
                });
            }
            return;
        }
        
        NSString *writedate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        // 拼接要删除的转帐流水id
        NSMutableString *chargeIDs = [NSMutableString string];
        
        if (model.endChargeID.length) {
            [chargeIDs appendFormat:@"'%@'", model.endChargeID];
        }
        
        if (model.endTargetChargeID.length) {
            [chargeIDs appendFormat:@", '%@'", model.endTargetChargeID];
        }
        
        if (model.interestChargeID.length) {
            [chargeIDs appendFormat:@", '%@'", model.interestChargeID];
        }
        
        // 将要删除的转帐流水operatortype改为2
        NSString *sqlStr = [NSString stringWithFormat:@"update bk_user_charge set operatortype = %@, iversion = %@, cwritedate = '%@' where ichargeid in (%@)", @2, @(SSJSyncVersion()), writedate, chargeIDs];
        
        // 把结清借贷产生的转帐流水状态改为删除
        if (![db executeUpdate:sqlStr]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        // 修改借贷记录的结清状态，并且清空结清转帐流水ID
        if (![db executeUpdate:@"update bk_loan set iend = ?, cethecharge = ?, cetargetcharge = ?, iversion = ?, operatortype = ?, cwritedate = ? where loanid = ?", @0, @"", @"", @(SSJSyncVersion()), @1, writedate, model.ID]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        // 开启提醒
        if (![db executeUpdate:@"update bk_user_remind set istate = ?, operatortype = ?, iversion = ?, cwritedate = ? where cremindid = ? and operatortype <> 2", @1, @1, @(SSJSyncVersion()), writedate, model.remindID]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        // 更新资金账户的余额
        if (![SSJFundAccountTable updateBalanceForUserId:model.userID inDatabase:db]) {
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

+ (void)queryFundModelListWithSuccess:(void (^)(NSArray <SSJLoanFundAccountSelectionViewItem *>*items))success
                              failure:(void (^)(NSError *error))failure {
    
    NSString *userId = SSJUSERID();
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT CICOIN, CFUNDID, CACCTNAME FROM BK_FUND_INFO WHERE CPARENT != 'root' AND CPARENT != '10' AND CPARENT != '11' AND OPERATORTYPE <> 2 AND CUSERID = ? ORDER BY IORDER", userId];
        if (!rs) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSMutableArray *fundItems = [NSMutableArray array];
        
        while ([rs next]) {
            SSJLoanFundAccountSelectionViewItem *item = [[SSJLoanFundAccountSelectionViewItem alloc] init];
            item.image = [rs stringForColumn:@"CICOIN"];
            item.title = [rs stringForColumn:@"CACCTNAME"];
            item.ID =  [rs stringForColumn:@"CFUNDID"];
            [fundItems addObject:item];
        }
        [rs close];
        
        SSJLoanFundAccountSelectionViewItem *item = [[SSJLoanFundAccountSelectionViewItem alloc] init];
        item.image = @"add";
        item.title = @"添加资金新的账户";
        [fundItems addObject:item];
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(fundItems);
            });
        }
    }];
}

+ (NSString *)queryForFundNameWithID:(NSString *)ID {
    __block NSString *fundName = nil;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        fundName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ?", ID];
    }];
    
    return fundName;
}

+ (double)currentInterestWithLoanModel:(SSJLoanModel *)model {
    NSDate *today = [NSDate date];
    today = [NSDate dateWithYear:today.year month:today.month day:today.day];
    return [self interestUntilDate:today withLoanModel:model];
}

+ (double)expectedInterestWithLoanModel:(SSJLoanModel *)model {
    return [self interestUntilDate:model.repaymentDate withLoanModel:model];
}

+ (double)closeOutInterestWithLoanModel:(SSJLoanModel *)model {
    return [self interestUntilDate:model.endDate withLoanModel:model];
}

+ (double)interestUntilDate:(NSDate *)date withLoanModel:(SSJLoanModel *)model {
    if (!date || !model.borrowDate) {
        SSJPRINT(@">>> 警告：借贷利息日期为空");
        return 0;
    }
    
    NSInteger daysInterval = [date daysFrom:model.borrowDate];
    if (daysInterval < 0) {
        SSJPRINT(@">>> 警告：借贷利息截止日期早于起始日期");
        return 0;
    }
    
    return daysInterval * model.rate * model.jMoney / 365;
}

+ (BOOL)saveLoanModel:(SSJLoanModel *)model booksID:(NSString *)booksID inDatabase:(FMDatabase *)db {
    
    NSString *billID = nil;
    NSString *targetBillID = nil;
    
    switch (model.type) {
        case SSJLoanTypeLend:
            billID = @"3";
            targetBillID = @"4";
            
            break;
            
        case SSJLoanTypeBorrow:
            billID = @"4";
            targetBillID = @"3";
            
            break;
    }
    
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString *borrowDateStr = [model.borrowDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *repaymentDateStr = [model.repaymentDate formattedDateWithFormat:@"yyyy-MM-dd"];
    
    // 所属账户转账流水
    if (![db executeUpdate:@"replace into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, cbilldate, cbooksid, loanid, iversion, operatortype, cwritedate) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", model.chargeID, model.userID, @(model.jMoney), billID, model.fundID, borrowDateStr, booksID, model.ID, @(SSJSyncVersion()), @(model.operatorType), writeDate]) {
        return NO;
    }
    
    // 目标账户转账流水
    if (![db executeUpdate:@"replace into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, cbilldate, cbooksid, loanid, iversion, operatortype, cwritedate) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", model.targetChargeID, model.userID, @(model.jMoney), targetBillID, model.targetFundID, borrowDateStr, booksID, model.ID, @(SSJSyncVersion()), @(model.operatorType), writeDate]) {
        return NO;
    }
    
    NSMutableDictionary *modelInfo = model.mj_keyValues;
    
    [modelInfo setObject:(borrowDateStr ?: @"") forKey:@"borrowDate"];
    [modelInfo setObject:(repaymentDateStr ?: @"") forKey:@"repaymentDate"];
    
    [modelInfo setObject:writeDate forKey:@"writeDate"];
    [modelInfo setObject:@(SSJSyncVersion()) forKey:@"version"];
    
    if (![db executeUpdate:@"replace into bk_loan (loanid, cuserid, lender, jmoney, cthefundid, ctargetfundid, cthecharge, ctargetcharge, cborrowdate, crepaymentdate, rate, memo, cremindid, interest, iend, itype, cwritedate, operatortype, iversion) values (:ID, :userID, :lender, :jMoney, :fundID, :targetFundID, :chargeID, :targetChargeID, :borrowDate, :repaymentDate, :rate, :memo, :remindID, :interest, :closeOut, :type, :writeDate, :operatorType, :version)" withParameterDictionary:modelInfo]) {
        return NO;
    }
    
    return YES;
}

@end
