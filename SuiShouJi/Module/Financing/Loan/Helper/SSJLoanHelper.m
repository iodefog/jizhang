//
//  SSJLoanHelper.m
//  SuiShouJi
//
//  Created by old lang on 16/8/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanHelper.h"
#import "SSJLocalNotificationStore.h"
#import "SSJLoanFundAccountSelectionViewItem.h"
#import "SSJLoanDetailCellItem.h"
#import "SSJLocalNotificationHelper.h"
#import "SSJLoanCompoundChargeModel.h"
#import "SSJBillTypeManager.h"

NSString *const SSJFundItemListKey = @"SSJFundItemListKey";
NSString *const SSJFundIDListKey = @"SSJFundIDListKey";

@implementation SSJLoanHelper

+ (void)queryForLoanModelsWithFundID:(NSString *)fundID
                       colseOutState:(int)state
                             success:(void (^)(NSArray <SSJLoanModel *>*list))success
                             failure:(void (^)(NSError *error))failure {
    
    NSString *userId = SSJUSERID();
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSMutableString *sqlStr = [[NSString stringWithFormat:@"select l.*, fi.cicoin from bk_loan as l, bk_fund_info as fi where l.cthefundid = fi.cfundid and l.cuserid = ? and l.cthefundid = ? and l.operatortype <> 2"] mutableCopy];
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
        
        [sqlStr appendString:@" order by cborrowdate desc, iend asc, jmoney desc"];
        
        FMResultSet *result = [db executeQuery:sqlStr, userId, fundID];
        if (!result) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
//        // 到期未结算
//        NSMutableArray *list1 = [NSMutableArray array];
//        
//        // 未到期已结算
//        NSMutableArray *list2 = [NSMutableArray array];
//        
//        // 其他
//        NSMutableArray *list3 = [NSMutableArray array];
        
        NSMutableArray *list = [[NSMutableArray alloc] init];
        
        while ([result next]) {
            SSJLoanModel *model = [SSJLoanModel modelWithResultSet:result];
            [list addObject:model];
            
//            NSDate *nowDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day];
            
//            // 排序顺序：1.到期未结算 2.未到期已结算 3.其他
//            if (!model.closeOut && [model.repaymentDate compare:nowDate] != NSOrderedAscending) {
//                [list1 addObject:model];
//            } else if (model.closeOut && [model.repaymentDate compare:nowDate] == NSOrderedAscending) {
//                [list2 addObject:model];
//            } else {
//                [list3 addObject:model];
//            }
        }
        
        [result close];
        
//        [list addObjectsFromArray:list1];
//        [list addObjectsFromArray:list2];
//        [list addObjectsFromArray:list3];
        
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
    
    NSString *userId = SSJUSERID();
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSError *error = nil;
        SSJLoanModel *model = [self queryForLoanModelWithLoanID:loanID database:db error:&error];
        if (error) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure(error);
                });
            }
            return;
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(model);
            });
        }
    }];
}

+ (void)queryForLoanModelWithChargeID:(NSString *)chargeID
                              success:(void (^)(SSJLoanModel *model))success
                              failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSString *sundryID = [db stringForQuery:@"select cid from bk_user_charge where ichargeid = ? and ichargetype = ?", chargeID, @(SSJChargeIdTypeLoan)];
        if (!sundryID) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"查询不到此借贷流水"}]);
                });
            }
            return;
        }
        
        NSError *error = nil;
        NSString *loanID = [[sundryID componentsSeparatedByString:@"_"] firstObject];
        SSJLoanModel *model = [self queryForLoanModelWithLoanID:loanID database:db error:&error];
        if (error) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure(error);
                });
            }
            return;
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(model);
            });
        }
    }];
}

+ (SSJLoanModel *)queryForLoanModelWithLoanID:(NSString *)loanID
                                     database:(FMDatabase *)db
                                        error:(NSError **)error {
    FMResultSet *rs = [db executeQuery:@"select l.* , fi.cstartcolor, fi.cendcolor from bk_loan l, bk_fund_info fi where l.loanid = ? and l.cuserid = ? and l.cthefundid = fi.cfundid", loanID, SSJUSERID()];
    SSJLoanModel *model = [[SSJLoanModel alloc] init];
    while ([rs next]) {
        model.ID = [rs stringForColumn:@"loanid"];
        model.userID = [rs stringForColumn:@"cuserid"];
        model.lender = [rs stringForColumn:@"lender"];
        model.jMoney = [rs doubleForColumn:@"jmoney"];
        model.fundID = [rs stringForColumn:@"cthefundid"];
        model.targetFundID = [rs stringForColumn:@"ctargetfundid"];
        model.endTargetFundID = [rs stringForColumn:@"cetarget"];
        model.borrowDate = [NSDate dateWithString:[rs stringForColumn:@"cborrowdate"] formatString:@"yyyy-MM-dd"];
        model.repaymentDate = [NSDate dateWithString:[rs stringForColumn:@"crepaymentdate"] formatString:@"yyyy-MM-dd"];
        model.endDate = [NSDate dateWithString:[rs stringForColumn:@"cenddate"] formatString:@"yyyy-MM-dd"];
        model.rate = [rs doubleForColumn:@"rate"];
        model.memo = [rs stringForColumn:@"memo"];
        model.remindID = [rs stringForColumn:@"cremindid"];
        model.interest = [rs boolForColumn:@"interest"];
        model.interestType = [rs intForColumn:@"interesttype"];
        model.closeOut = [rs boolForColumn:@"iend"];
        model.type = [rs intForColumn:@"itype"];
        model.operatorType = [rs intForColumn:@"operatorType"];
        model.version = [rs longLongIntForColumn:@"iversion"];
        model.writeDate = [NSDate dateWithString:[rs stringForColumn:@"cwritedate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
        model.startColor = [rs stringForColumn:@"cstartcolor"];
        model.endColor = [rs stringForColumn:@"cendcolor"];
    }
    [rs close];
    
    return model;
}

+ (void)queryLoanChargeModeListWithLoanModel:(SSJLoanModel *)loanModel
                                     success:(void (^)(NSArray <SSJLoanCompoundChargeModel *>*list))success
                                     failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        
        NSMutableArray *compoundModels = [NSMutableArray array];
        double surplus = 0; // 剩余金额
        
        // 查询依赖借贷的转帐流水
        FMResultSet *rs = [db executeQuery:@"select ichargeid, ifunsid, ibillid, cid, imoney, cmemo, cbilldate, cwritedate from bk_user_charge where cuserid = ? and ifunsid = ? and cid like ? || '_%' and ichargetype = ? and operatortype <> 2 order by cbilldate, cwritedate", loanModel.userID, loanModel.fundID, loanModel.ID, @(SSJChargeIdTypeLoan)];
        
        while ([rs next]) {
            SSJLoanChargeModel *chargeModel = [[SSJLoanChargeModel alloc] init];
            chargeModel.chargeId = [rs stringForColumn:@"ichargeid"];
            chargeModel.fundId = [rs stringForColumn:@"ifunsid"];
            chargeModel.billId = [rs stringForColumn:@"ibillid"];
            chargeModel.loanId = [rs stringForColumn:@"cid"];
            chargeModel.userId = loanModel.userID;
            chargeModel.icon = SSJBillTypeModel(chargeModel.billId).icon;
            chargeModel.memo = [rs stringForColumn:@"cmemo"];
            chargeModel.billDate = [NSDate dateWithString:[rs stringForColumn:@"cbilldate"] formatString:@"yyyy-MM-dd"];
            chargeModel.writeDate = [NSDate dateWithString:[rs stringForColumn:@"cwritedate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
            chargeModel.money = [rs doubleForColumn:@"imoney"];
            chargeModel.oldMoney = surplus;
            chargeModel.type = loanModel.type;
            
            [self updateChargeTypeWithModel:chargeModel];
            
            switch (chargeModel.chargeType) {
                case SSJLoanCompoundChargeTypeCreate:
                    surplus = chargeModel.money;
                    break;
                    
                case SSJLoanCompoundChargeTypeBalanceIncrease:
                case SSJLoanCompoundChargeTypeAdd:
                    surplus += chargeModel.money;
                    break;
                    
                case SSJLoanCompoundChargeTypeBalanceDecrease:
                case SSJLoanCompoundChargeTypeRepayment:
                case SSJLoanCompoundChargeTypeCloseOut:
                    surplus -= chargeModel.money;
                    break;
                    
                case SSJLoanCompoundChargeTypeInterest:
                    break;
            }
            
            SSJLoanCompoundChargeModel *compoundModel = [[SSJLoanCompoundChargeModel alloc] init];
            compoundModel.chargeModel = chargeModel;
            if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeCreate) {
                // 确保创建的流水在数组中第一个
                [compoundModels insertObject:compoundModel atIndex:0];
            } else {
                [compoundModels addObject:compoundModel];
            }
        }
        [rs close];
        
        
        // 查询和第一次查询结果匹配的流水（例第一次查询结果是转入，这次查询就是转出、利息，反之一样）
        for (SSJLoanCompoundChargeModel *compoundModel in compoundModels) {
            
            NSString *billDateStr = [compoundModel.chargeModel.billDate formattedDateWithFormat:@"yyyy-MM-dd"];
            NSString *writeDateStr = [compoundModel.chargeModel.writeDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            
            FMResultSet *rs = [db executeQuery:@"select ichargeid, ifunsid, ibillid, cid, cmemo, cbilldate, imoney from bk_user_charge where ichargeid <> ? and cid = ? and cuserid = ? and ichargetype = ? and operatortype <> 2", compoundModel.chargeModel.chargeId, compoundModel.chargeModel.loanId, compoundModel.chargeModel.userId,@(SSJChargeIdTypeLoan)];
            
            while ([rs next]) {
                SSJLoanChargeModel *chargeModel = [[SSJLoanChargeModel alloc] init];
                chargeModel.chargeId = [rs stringForColumn:@"ichargeid"];
                chargeModel.fundId = [rs stringForColumn:@"ifunsid"];
                chargeModel.billId = [rs stringForColumn:@"ibillid"];
                chargeModel.loanId = [rs stringForColumn:@"cid"];
                chargeModel.memo = [rs stringForColumn:@"cmemo"];
                chargeModel.billDate = [NSDate dateWithString:[rs stringForColumn:@"cbilldate"] formatString:@"yyyy-MM-dd"];
                chargeModel.money = [rs doubleForColumn:@"imoney"];
                chargeModel.userId = compoundModel.chargeModel.userId;
                chargeModel.writeDate = compoundModel.chargeModel.writeDate;
                chargeModel.type = compoundModel.chargeModel.type;
                [self updateChargeTypeWithTargetModel:chargeModel];
                if (chargeModel.chargeType == SSJLoanCompoundChargeTypeInterest) {
                    compoundModel.interestChargeModel = chargeModel;
                } else {
                    compoundModel.targetChargeModel = chargeModel;
                }
            }
            [rs close];
            
            rs = [db executeQuery:@"select lender, iend from bk_loan where loanid = ? and cuserid = ?", compoundModel.chargeModel.loanId, compoundModel.chargeModel.userId];
            while ([rs next]) {
                compoundModel.lender = [rs stringForColumn:@"lender"];
                compoundModel.closeOut = [rs boolForColumn:@"iend"];
            }
            [rs close];
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(compoundModels);
            });
        }
    }];
}

+ (void)saveLoanModel:(SSJLoanModel *)loanModel
         chargeModels:(NSArray <SSJLoanCompoundChargeModel *>*)chargeModels
          remindModel:(nullable SSJReminderItem *)remindModel
              success:(void (^)())success
              failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        // 如果当前的借贷记录已经删除，就当作成功处理（这种情况发生在查询记录后在另一个客户端上删除了）
        int operatorType = [db intForQuery:@"select operatortype from bk_loan where loanid = ?", loanModel.ID];
        if (operatorType == 2) {
            if (success) {
                SSJDispatchMainAsync(^{
                    success();
                });
            }
            return;
        }
        
        // 存储借贷记录
        loanModel.version = SSJSyncVersion();
        loanModel.writeDate = [NSDate date];
        
        NSString *billID = nil;
        NSString *targetBillID = nil;
        
        switch (loanModel.type) {
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
        NSString *borrowDateStr = [loanModel.borrowDate formattedDateWithFormat:@"yyyy-MM-dd"];
        NSString *repaymentDateStr = [loanModel.repaymentDate formattedDateWithFormat:@"yyyy-MM-dd"];
        
        NSMutableDictionary *modelInfo = loanModel.mj_keyValues;
        
        [modelInfo setObject:(borrowDateStr ?: @"") forKey:@"cborrowdate"];
        [modelInfo setObject:(repaymentDateStr ?: @"") forKey:@"crepaymentdate"];
        
        [modelInfo setObject:writeDate forKey:@"cwritedate"];
        [modelInfo setObject:@(SSJSyncVersion()) forKey:@"iversion"];
        
        if (![modelInfo valueForKey:@"memo"]) {
            [modelInfo setObject:@"" forKey:@"memo"];
        }
        
        if (![modelInfo valueForKey:@"cremindid"]) {
            [modelInfo setObject:@"" forKey:@"cremindid"];
        }
        
        if (![db executeUpdate:@"replace into bk_loan (loanid, cuserid, lender, jmoney, cthefundid, ctargetfundid, cborrowdate, crepaymentdate, rate, memo, cremindid, interest, interesttype, iend, itype, cwritedate, operatortype, iversion) values (:loanid, :cuserid, :lender, :jmoney, :cthefundid, :ctargetfundid, :cborrowdate, :crepaymentdate, :rate, :memo, :cremindid, :interest, :interesttype, :iend, :itype, :cwritedate, :operatortype, :iversion)" withParameterDictionary:modelInfo]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        // 存储流水记录
        NSError *error = nil;
        NSDate *lastDate = [NSDate date];
        for (SSJLoanCompoundChargeModel *model in chargeModels) {
            
            NSDate *writeDate = [lastDate dateByAddingSeconds:1];
            model.chargeModel.writeDate = writeDate;
            model.targetChargeModel.writeDate = writeDate;
            model.interestChargeModel.writeDate = writeDate;
            lastDate = writeDate;
            
            if (![self saveLoanCompoundChargeModel:model inDatabase:db error:&error]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure(error);
                    });
                }
                return;
            }
        }
        
        // 存储提醒记录
        if (remindModel) {
            remindModel.fundId = loanModel.ID;
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
        
        // 修改借贷账户的可见状态
        if (![db executeUpdate:@"update bk_fund_info set idisplay = 1, iversion = ?, operatortype = 1, cwritedate = ? where cfundid = ?", @(SSJSyncVersion()), [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], loanModel.fundID]) {
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
    
    NSString *userId = SSJUSERID();
    
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSError *error = nil;
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        if ([self deleteLoanModel:model
                        writeDate:writeDate
                         database:db
                            error:&error]) {
            if (success) {
                SSJDispatchMainAsync(^{
                    success();
                });
            }
        } else {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure(error);
                });
            }
        }
    }];
}

+ (BOOL)deleteLoanModel:(SSJLoanModel *)model
              writeDate:(NSString *)writeDate
               database:(FMDatabase *)db
                  error:(NSError **)error {
    // 将借贷记录的operatortype改为2
    if (![db executeUpdate:@"update bk_loan set operatortype = ?, iversion = ?, cwritedate = ? where loanid = ? and operatortype <> 2", @2, @(SSJSyncVersion()), writeDate, model.ID]) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }
    
    // 将和借贷相关的流水operatortype改为2
    if (![db executeUpdate:@"update bk_user_charge set operatortype = ?, iversion = ?, cwritedate = ? where cid like ? || '_%' and ichargetype = ? and operatortype <> 2", @2, @(SSJSyncVersion()), writeDate, model.ID, @(SSJChargeIdTypeLoan)]) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }
    
    // 将提醒的operatortype改为2
    if (![db executeUpdate:@"update bk_user_remind set operatortype = ?, iversion = ?, cwritedate = ? where cremindid = ? and operatortype <> 2", @2, @(SSJSyncVersion()), writeDate, model.remindID]) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }
    
    //取消提醒
    SSJReminderItem *remindItem = [[SSJReminderItem alloc] init];
    remindItem.remindId = model.remindID;
    remindItem.userId = model.userID;
    [SSJLocalNotificationHelper cancelLocalNotificationWithremindItem:remindItem];
    
    return YES;
}

+ (void)closeOutLoanModel:(SSJLoanModel *)model
              chargeModel:(SSJLoanCompoundChargeModel *)chargeModel
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
        if (newestModel.operatorType == 2 || newestModel.closeOut) {
            if (success) {
                SSJDispatchMainAsync(^{
                    success();
                });
            }
            return;
        }
        
        NSDate *writeDate = [NSDate date];
        chargeModel.chargeModel.writeDate = writeDate;
        chargeModel.targetChargeModel.writeDate = writeDate;
        chargeModel.interestChargeModel.writeDate = writeDate;
        NSError *error = nil;
        
        if (![self saveLoanCompoundChargeModel:chargeModel inDatabase:db error:&error]) {
            
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            
            return;
        }
        
        NSString *writeDateStr = [writeDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString *endDateStr = [model.endDate formattedDateWithFormat:@"yyyy-MM-dd"];
        
        // 修改当前借贷记录的结清状态
        if (![db executeUpdate:@"update bk_loan set iend = ?, jmoney = ?, rate = ?, ctargetfundid = ?, cetarget = ?, cenddate = ?, iversion = ?, operatortype = ?, cwritedate = ? where loanid = ?", @1, @(model.jMoney), @(model.rate), model.targetFundID, model.endTargetFundID, endDateStr, @(SSJSyncVersion()), @1, writeDateStr, model.ID]) {
            
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
        if (![db executeUpdate:@"update bk_user_remind set istate = ?, cremindname = ?, iversion = ?, operatortype = ?, cwritedate = ? where cremindid = ? and operatortype <> 2", @0, remindName, @(SSJSyncVersion()), @1, writeDateStr, model.remindID]) {
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
        FMResultSet *rs = [db executeQuery:@"SELECT CICOIN, CFUNDID, CACCTNAME FROM BK_FUND_INFO WHERE CPARENT != 'root' AND CPARENT != '10' AND CPARENT != '11' AND CPARENT != '17' AND OPERATORTYPE <> 2 AND CUSERID = ? ORDER BY IORDER", userId];
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
        item.title = @"添加新的资金账户";
        [fundItems addObject:item];
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(fundItems);
            });
        }
    }];
}

+ (void)queryForFundNameWithID:(NSString *)ID completion:(void(^)(NSString *name))completion {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *fundName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ?", ID];
        if (completion) {
            SSJDispatchMainAsync(^{
                completion(fundName);
            });
        }
    }];
}

+ (void)queryForFundColorWithID:(NSString *)ID completion:(void(^)(NSString *color))completion {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *color = [db stringForQuery:@"select ccolor from bk_fund_info where cfundid = ?", ID];
        if (completion) {
            SSJDispatchMainAsync(^{
                completion(color);
            });
        }
    }];
}

+ (void)queryForFundColorWithLoanId:(NSString *)loanId completion:(void(^)(NSString *color))completion {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *colorValue = [db stringForQuery:@"select ccolor from bk_fund_info where cfundid = (select cthefundid from bk_loan where loanid = ?)", loanId];
        if (completion) {
            SSJDispatchMainAsync(^{
                completion(colorValue);
            });
        }
    }];
}

+ (double)caculateInterestForEveryDayWithLoanModel:(SSJLoanModel *)model chargeModels:(NSArray <SSJLoanCompoundChargeModel *>*)models {
    
    double principal = 0;   // 本金
    
    for (SSJLoanCompoundChargeModel *compoundModel in models) {
        
        if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeCreate) {
            principal = compoundModel.chargeModel.money;
        } else if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceIncrease) {
            principal += compoundModel.chargeModel.money;
        } else if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceDecrease) {
            principal -= compoundModel.chargeModel.money;
        } else if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeRepayment) {
            if (model.interestType == SSJLoanInterestTypeChangePrincipal) {
                principal -= compoundModel.chargeModel.money;
            }
        } else if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeAdd) {
            if (model.interestType == SSJLoanInterestTypeChangePrincipal) {
                principal += compoundModel.chargeModel.money;
            }
        }
    }
    
    return [self interestWithPrincipal:principal rate:model.rate days:1];
}

+ (double)caculateInterestUntilDate:(NSDate *)untilDate model:(SSJLoanModel *)model chargeModels:(NSArray <SSJLoanCompoundChargeModel *>*)models {
    
    if (!model.borrowDate || !untilDate) {
        SSJPRINT(@"借贷和截止日期不能为nil，借贷日期：%@ 截止日期:%@", model.borrowDate, untilDate);
        return 0;
    }
    
    if ([model.borrowDate compare:untilDate] == NSOrderedDescending) {
        return 0;
    }
    
    double principal = 0;   // 本金
    double interest = 0;    // 利息
    
    // 先计算出借贷起始本金（包括余额变更后的）
    for (SSJLoanCompoundChargeModel *compoundModel in models) {
        if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeCreate) {
            principal = compoundModel.chargeModel.money;
        } else if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceIncrease) {
            principal += compoundModel.chargeModel.money;
        } else if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceDecrease) {
            principal -= compoundModel.chargeModel.money;
        }
    }
    
    switch (model.interestType) {
        case SSJLoanInterestTypeUnknown: // 如果没有选择过计息方式，就按照原始本金计算
        case SSJLoanInterestTypeOriginalPrincipal:
            return [self interestWithPrincipal:principal rate:model.rate days:(int)[untilDate daysFrom:model.borrowDate]];
            
        case SSJLoanInterestTypeChangePrincipal: {
            NSDate *lastChangeDate = model.borrowDate;
            for (SSJLoanCompoundChargeModel *compoundModel in models) {
                if ([compoundModel.chargeModel.billDate compare:untilDate] != NSOrderedDescending) {
                    if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeRepayment) {
                        interest += [self interestWithPrincipal:principal rate:model.rate days:(int)[compoundModel.chargeModel.billDate daysFrom:lastChangeDate]];
                        principal -= compoundModel.chargeModel.money;
                        lastChangeDate = compoundModel.chargeModel.billDate;
                    } else if (compoundModel.chargeModel.chargeType == SSJLoanCompoundChargeTypeAdd) {
                        interest += [self interestWithPrincipal:principal rate:model.rate days:(int)[compoundModel.chargeModel.billDate daysFrom:lastChangeDate]];
                        principal += compoundModel.chargeModel.money;
                        lastChangeDate = compoundModel.chargeModel.billDate;
                    }
                }
            }
            
            interest += [self interestWithPrincipal:principal rate:model.rate days:(int)[untilDate daysFrom:lastChangeDate]];
            return interest;
        }
    }
}

+ (double)interestWithPrincipal:(double)principal rate:(double)rate days:(int)days {
    return days * principal * rate / 365;
}

+ (void)queryLoanCompoundChangeModelWithChargeID:(NSString *)chargeID
                                         success:(void (^)(SSJLoanCompoundChargeModel *model))success
                                         failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *sundryID = [db stringForQuery:@"select cid from bk_user_charge where ichargeid = ?", chargeID];
        
        FMResultSet *rs = [db executeQuery:@"select ichargeid, ifunsid, ibillid, cuserid, imoney, cmemo, cbilldate, cwritedate from bk_user_charge where cid = ? and ichargetype = ? and operatortype <> 2", sundryID, @(SSJChargeIdTypeLoan)];
        
        NSMutableArray *chargeModels = [NSMutableArray array];
        while ([rs next]) {
            SSJLoanChargeModel *model = [[SSJLoanChargeModel alloc] init];
            model.chargeId = [rs stringForColumn:@"ichargeid"];
            model.fundId = [rs stringForColumn:@"ifunsid"];
            model.billId = [rs stringForColumn:@"ibillid"];
            model.loanId = sundryID;
            model.userId = [rs stringForColumn:@"cuserid"];
            model.memo = [rs stringForColumn:@"cmemo"];
            model.money = [rs doubleForColumn:@"imoney"];
            model.billDate = [NSDate dateWithString:[rs stringForColumn:@"cbilldate"] formatString:@"yyyy-MM-dd"];
            model.writeDate = [NSDate dateWithString:[rs stringForColumn:@"cwritedate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
            [chargeModels addObject:model];
        }
        [rs close];
        
        NSString *loanID = [[sundryID componentsSeparatedByString:@"_"] firstObject];
        
        rs = [db executeQuery:@"select lender, iend from bk_loan where loanid = ?", loanID];
        
        SSJLoanCompoundChargeModel *compoundModel = [[SSJLoanCompoundChargeModel alloc] init];
        while ([rs next]) {
            compoundModel.lender = [rs stringForColumn:@"lender"];
            compoundModel.closeOut = [rs boolForColumn:@"iend"];
        }
        [rs close];
        
        for (SSJLoanChargeModel *chargeModel in chargeModels) {
            NSString *rootId = [db stringForQuery:@"select cparent from bk_fund_info where cfundid = ?", chargeModel.fundId];
            if ([rootId isEqualToString:@"10"] || [rootId isEqualToString:@"11"]) {
                chargeModel.type = [rootId isEqualToString:@"10"] ? SSJLoanTypeLend : SSJLoanTypeBorrow;
                [self updateChargeTypeWithModel:chargeModel];
                compoundModel.chargeModel = chargeModel;
            } else {
                [self updateChargeTypeWithTargetModel:chargeModel];
                if ([chargeModel.billId isEqualToString:@"5"] || [chargeModel.billId isEqualToString:@"6"]) {
                    compoundModel.interestChargeModel = chargeModel;
                } else {
                    compoundModel.targetChargeModel = chargeModel;
                }
            }
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(compoundModel);
            });
        }
    }];
}

+ (void)deleteLoanCompoundChargeModel:(SSJLoanCompoundChargeModel *)model
                              success:(void (^)(void))success
                              failure:(void (^)(NSError *error))failure {
    
    if (model.chargeModel.chargeType == SSJLoanCompoundChargeTypeCreate
        || model.chargeModel.chargeType == SSJLoanCompoundChargeTypeCloseOut) {
        
        if (failure) {
            SSJDispatchMainAsync(^{
                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"创建／结清借贷产生的流水记录不能删除"}]);
            });
            return;
        }
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        // 如果此借贷已经删除，按照执行成功处理
        if ([db intForQuery:@"select operatortype from bk_loan where loanid = ?", model.chargeModel.loanId] == 2) {
            if (success) {
                SSJDispatchMainAsync(^{
                    success();
                });
            }
            return;
        }
        
        NSString *writeDateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        // 更新删除后的借贷余额
        double surplus = [db doubleForQuery:@"select jmoney from bk_loan where loanid = ?", model.chargeModel.loanId];
        
        if (model.chargeModel.chargeType == SSJLoanCompoundChargeTypeRepayment) {
            surplus += model.chargeModel.money;
        } else if (model.chargeModel.chargeType == SSJLoanCompoundChargeTypeAdd) {
            surplus -= model.chargeModel.money;
        } else if (model.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceIncrease) {
            surplus -= model.chargeModel.money;
        } else if (model.chargeModel.chargeType == SSJLoanCompoundChargeTypeBalanceDecrease) {
            surplus += model.chargeModel.money;
        }
        
        if (surplus < 0) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([NSError errorWithDomain:SSJErrorDomain code:1 userInfo:nil]);
                });
            }
            return;
        }
        
        // 更新借贷的剩余金额
        if (![db executeUpdate:@"update bk_loan set jmoney = ?, iversion = ?, cwritedate = ?, operatortype = 1 where loanid = ?", @(surplus), @(SSJSyncVersion()), writeDateStr, model.chargeModel.loanId]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        // 删除流水
        NSMutableArray *chargeIds = [[NSMutableArray alloc] init];
        
        if (model.chargeModel.chargeId) {
            [chargeIds addObject:[NSString stringWithFormat:@"'%@'", model.chargeModel.chargeId]];
        }
        
        if (model.targetChargeModel.chargeId) {
            [chargeIds addObject:[NSString stringWithFormat:@"'%@'", model.targetChargeModel.chargeId]];
        }
        
        if (model.interestChargeModel.chargeId) {
            [chargeIds addObject:[NSString stringWithFormat:@"'%@'", model.interestChargeModel.chargeId]];
        }
        
        NSString *sql = [NSString stringWithFormat:@"update bk_user_charge set operatortype = 2, cwritedate = ?, iversion = ? where ichargeid in (%@) and cuserid = ?", [chargeIds componentsJoinedByString:@","]];
        
        if (![db executeUpdate:sql, writeDateStr, @(SSJSyncVersion()), model.chargeModel.userId]) {
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

+ (void)saveLoanCompoundChargeModel:(SSJLoanCompoundChargeModel *)model
                            success:(void (^)(void))success
                            failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSDate *writeDate = [NSDate date];
        model.chargeModel.writeDate = writeDate;
        model.targetChargeModel.writeDate = writeDate;
        model.interestChargeModel.writeDate = writeDate;
        
        NSError *error = nil;
        
        if (![self saveLoanCompoundChargeModel:model inDatabase:db error:&error]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure(error);
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

+ (void)saveLoanCompoundChargeModels:(NSArray <SSJLoanCompoundChargeModel *>*)models
                             success:(void (^)(void))success
                             failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSError *error = nil;
        NSDate *lastDate = [NSDate date];
        for (SSJLoanCompoundChargeModel *model in models) {
            
            NSDate *writeDate = [lastDate dateByAddingSeconds:1];
            model.chargeModel.writeDate = writeDate;
            model.targetChargeModel.writeDate = writeDate;
            model.interestChargeModel.writeDate = writeDate;
            lastDate = writeDate;
            
            if (![self saveLoanCompoundChargeModel:model inDatabase:db error:&error]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure(error);
                    });
                }
                return;
            }
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success();
            });
        }
    }];
}

/**
 存储借贷产生的流水记录

 @param model 借贷产生的流水记录
 @param db FMDatabase实例
 @param error 输出参数，传入指向指针的指针
 @return 是否保存成功
 */
+ (BOOL)saveLoanCompoundChargeModel:(SSJLoanCompoundChargeModel *)model inDatabase:(FMDatabase *)db error:(NSError **)error {
    
    if (!model.chargeModel || !model.targetChargeModel) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"chargeModel和targetChargeModel不能为nil"}];
        }
        return NO;
    }
    
    if (model.chargeModel.money < 0
        || model.targetChargeModel.money < 0) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"chargeModel和targetChargeModel的金额不能小于0"}];
        }
        return NO;
    }
    
    if (model.chargeModel.money != model.targetChargeModel.money) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"chargeModel和targetChargeModel的金额必须相等"}];
        }
        return NO;
    }
    
    // 所属账户转账流水
    if (model.chargeModel) {
        NSString *billDateStr = [model.chargeModel.billDate formattedDateWithFormat:@"yyyy-MM-dd"];
        NSString *writeDateStr = [model.chargeModel.writeDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        NSMutableDictionary *chargeInfo = [model.chargeModel mj_keyValues];
        [chargeInfo setObject:billDateStr forKey:@"billDate"];
        [chargeInfo setObject:writeDateStr forKey:@"writeDate"];
        [chargeInfo setObject:@(SSJSyncVersion()) forKey:@"version"];
        [chargeInfo setObject:@(1) forKey:@"operatorType"];
        [chargeInfo setObject:@(SSJChargeIdTypeLoan) forKey:@"chargetype"];

        if (![chargeInfo objectForKey:@"memo"]) {
            [chargeInfo setObject:@"" forKey:@"memo"];
        }
        
        if (![db executeUpdate:@"replace into bk_user_charge (ichargeid, cuserid, ibillid, ifunsid, cbilldate, cid, imoney, cmemo, iversion, operatortype, cwritedate, ichargetype) values (:chargeId, :userId, :billId, :fundId, :billDate, :loanId, :money, :memo, :version, :operatorType, :writeDate, :chargetype)" withParameterDictionary:chargeInfo]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
    }
    
    // 目标账户转账流水
    if (model.targetChargeModel) {
        NSString *billDateStr = [model.targetChargeModel.billDate formattedDateWithFormat:@"yyyy-MM-dd"];
        NSString *writeDateStr = [model.targetChargeModel.writeDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        NSMutableDictionary *targetChargeInfo = [model.targetChargeModel mj_keyValues];
        [targetChargeInfo setObject:billDateStr forKey:@"billDate"];
        [targetChargeInfo setObject:writeDateStr forKey:@"writeDate"];
        [targetChargeInfo setObject:@(SSJSyncVersion()) forKey:@"version"];
        [targetChargeInfo setObject:@(1) forKey:@"operatorType"];
        [targetChargeInfo setObject:@(SSJChargeIdTypeLoan) forKey:@"chargetype"];
        if (![targetChargeInfo objectForKey:@"memo"]) {
            [targetChargeInfo setObject:@"" forKey:@"memo"];
        }
        
        if (![db executeUpdate:@"replace into bk_user_charge (ichargeid, cuserid, ibillid, ifunsid, cbilldate, cid, imoney, cmemo, iversion, operatortype, cwritedate, ichargetype) values (:chargeId, :userId, :billId, :fundId, :billDate, :loanId, :money, :memo, :version, :operatorType, :writeDate, :chargetype)" withParameterDictionary:targetChargeInfo]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
    }
    
    // 利息流水
    if (model.interestChargeModel) {
        NSString *billDateStr = [model.interestChargeModel.billDate formattedDateWithFormat:@"yyyy-MM-dd"];
        NSString *writeDateStr = [model.interestChargeModel.writeDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        NSMutableDictionary *interestChargeInfo = [model.interestChargeModel mj_keyValues];
        [interestChargeInfo setObject:billDateStr forKey:@"billDate"];
        [interestChargeInfo setObject:writeDateStr forKey:@"writeDate"];
        [interestChargeInfo setObject:@(SSJSyncVersion()) forKey:@"version"];
        [interestChargeInfo setObject:@(1) forKey:@"operatorType"];
        [interestChargeInfo setObject:@(SSJChargeIdTypeLoan) forKey:@"chargetype"];
        if (![interestChargeInfo objectForKey:@"memo"]) {
            [interestChargeInfo setObject:@"" forKey:@"memo"];
        }
        
        if (![db executeUpdate:@"replace into bk_user_charge (ichargeid, cuserid, ibillid, ifunsid, cbilldate, cid, imoney, cmemo, iversion, operatortype, cwritedate, ichargetype) values (:chargeId, :userId, :billId, :fundId, :billDate, :loanId, :money, :memo, :version, :operatorType, :writeDate, :chargetype)" withParameterDictionary:interestChargeInfo]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
    }
    
    return YES;
}

+ (void)updateChargeTypeWithModel:(SSJLoanChargeModel *)model {
    switch (model.type) {
        case SSJLoanTypeLend:
            if ([model.billId isEqualToString:@"3"]) {
                // 创建
                model.chargeType = SSJLoanCompoundChargeTypeCreate;
            } else if ([model.billId isEqualToString:@"4"]) {
                // 结清
                model.chargeType = SSJLoanCompoundChargeTypeCloseOut;
            } else if ([model.billId isEqualToString:@"7"]) {
                // 追加借出
                model.chargeType = SSJLoanCompoundChargeTypeAdd;
            } else if ([model.billId isEqualToString:@"8"]) {
                // 收款
                model.chargeType = SSJLoanCompoundChargeTypeRepayment;
            } else if ([model.billId isEqualToString:@"9"]) {
                // 余额增加
                model.chargeType = SSJLoanCompoundChargeTypeBalanceIncrease;
            } else if ([model.billId isEqualToString:@"10"]) {
                // 余额减少
                model.chargeType = SSJLoanCompoundChargeTypeBalanceDecrease;
            }
            break;
            
        case SSJLoanTypeBorrow:
            if ([model.billId isEqualToString:@"3"]) {
                // 结清
                model.chargeType = SSJLoanCompoundChargeTypeCloseOut;
            } else if ([model.billId isEqualToString:@"4"]) {
                // 创建
                model.chargeType = SSJLoanCompoundChargeTypeCreate;
            } else if ([model.billId isEqualToString:@"7"]) {
                // 还款
                model.chargeType = SSJLoanCompoundChargeTypeRepayment;
            } else if ([model.billId isEqualToString:@"8"]) {
                // 追加欠款
                model.chargeType = SSJLoanCompoundChargeTypeAdd;
            } else if ([model.billId isEqualToString:@"9"]) {
                // 余额减少
                model.chargeType = SSJLoanCompoundChargeTypeBalanceDecrease;
            } else if ([model.billId isEqualToString:@"10"]) {
                // 余额增加
                model.chargeType = SSJLoanCompoundChargeTypeBalanceIncrease;
            }
            break;
    }
}

+ (void)updateChargeTypeWithTargetModel:(SSJLoanChargeModel *)model {
    switch (model.type) {
        case SSJLoanTypeLend:
            if ([model.billId isEqualToString:@"3"]) {
                // 结清
                model.chargeType = SSJLoanCompoundChargeTypeCloseOut;
            } else if ([model.billId isEqualToString:@"4"]) {
                // 创建
                model.chargeType = SSJLoanCompoundChargeTypeCreate;
            } else if ([model.billId isEqualToString:@"5"]
                       || [model.billId isEqualToString:@"6"]) {
                // 利息
                model.chargeType = SSJLoanCompoundChargeTypeInterest;
            } else if ([model.billId isEqualToString:@"7"]) {
                // 收款
                model.chargeType = SSJLoanCompoundChargeTypeRepayment;
            } else if ([model.billId isEqualToString:@"8"]) {
                // 追加借出
                model.chargeType = SSJLoanCompoundChargeTypeAdd;
            } else if ([model.billId isEqualToString:@"9"]) {
                // 余额减少
                model.chargeType = SSJLoanCompoundChargeTypeBalanceDecrease;
            } else if ([model.billId isEqualToString:@"10"]) {
                // 余额增加
                model.chargeType = SSJLoanCompoundChargeTypeBalanceIncrease;
            }
            break;
            
        case SSJLoanTypeBorrow:
            if ([model.billId isEqualToString:@"3"]) {
                // 创建
                model.chargeType = SSJLoanCompoundChargeTypeCreate;
            } else if ([model.billId isEqualToString:@"4"]) {
                // 结清
                model.chargeType = SSJLoanCompoundChargeTypeCloseOut;
            } else if ([model.billId isEqualToString:@"5"]
                       || [model.billId isEqualToString:@"6"]) {
                // 利息
                model.chargeType = SSJLoanCompoundChargeTypeInterest;
            } else if ([model.billId isEqualToString:@"7"]) {
                // 追加欠款
                model.chargeType = SSJLoanCompoundChargeTypeAdd;
            } else if ([model.billId isEqualToString:@"8"]) {
                // 还款
                model.chargeType = SSJLoanCompoundChargeTypeRepayment;
            } else if ([model.billId isEqualToString:@"9"]) {
                // 余额增加
                model.chargeType = SSJLoanCompoundChargeTypeBalanceIncrease;
            } else if ([model.billId isEqualToString:@"10"]) {
                // 余额减少
                model.chargeType = SSJLoanCompoundChargeTypeBalanceDecrease;
            }
            break;
    }
}

// 验证借贷有效性
+ (BOOL)checkLoanModelValid:(SSJLoanChargeModel *)model error:(NSError **)error {
    if (!model) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"借贷流水模型不能为nil"}];
        }
        return NO;
    }
    
    if (!model.chargeId.length) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"借贷流水的chargeId为nil或空字符串 chargeId:%@", model.chargeId]}];
        }
        return NO;
    }
    
    if (!model.fundId.length) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"借贷流水的fundId为nil或空字符串 fundId:%@", model.fundId]}];
        }
        return NO;
    }
    
    if (!model.loanId.length) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"借贷流水的loanId为nil或空字符串 loanId:%@", model.loanId]}];
        }
        return NO;
    }
    
    if (!model.userId.length) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"借贷流水的userId为nil或空字符串 userId:%@", model.userId]}];
        }
        return NO;
    }
    
    if (![model.billId isEqualToString:@"3"]
        && ![model.billId isEqualToString:@"4"]
        && ![model.billId isEqualToString:@"5"]
        && ![model.billId isEqualToString:@"6"]
        && ![model.billId isEqualToString:@"7"]
        && ![model.billId isEqualToString:@"8"]
        && ![model.billId isEqualToString:@"9"]
        && ![model.billId isEqualToString:@"10"]) {
        
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"该流水不是借贷产生的流水，billId:%@", model.billId]}];
        }
        return NO;
    }
    
    if (!model.billDate) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"借贷流水的billDate为nil billDate:%@", model.billDate]}];
        }
        return NO;
    }
    
    if (!model.writeDate) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"借贷流水的writeDate为nil writeDate:%@", model.writeDate]}];
        }
        return NO;
    }
    
    return YES;
}

+ (BOOL)deleteLoanDataRelatedToFundID:(NSString *)fundID
                            writeDate:(NSString *)writeDate
                             database:(FMDatabase *)db
                                error:(NSError **)error {
    NSMutableSet *loanIDs = [NSMutableSet set];
    FMResultSet *rs = [db executeQuery:@"select cid from bk_user_charge where ifunsid = ? and operatortype <> 2 and ichargetype = ?", fundID, @(SSJChargeIdTypeLoan)];
    while ([rs next]) {
        NSString *loanID = [[[rs stringForColumn:@"cid"] componentsSeparatedByString:@"_"] firstObject];
        [loanIDs addObject:loanID];
    }
    [rs close];
    
    for (NSString *loanID in loanIDs) {
        SSJLoanModel *loanModel = [[SSJLoanModel alloc] init];
        rs = [db executeQuery:@"select loanid, cuserid, cremindid from bk_loan where loanid = ?", loanID];
        while ([rs next]) {
            loanModel.ID = [rs stringForColumn:@"loanid"];
            loanModel.userID = [rs stringForColumn:@"cuserid"];
            loanModel.remindID = [rs stringForColumn:@"cremindid"];
        }
        [rs close];
        
        if (![self deleteLoanModel:loanModel writeDate:writeDate database:db error:error]) {
            return NO;
        }
    }
    
    return YES;
}

@end
