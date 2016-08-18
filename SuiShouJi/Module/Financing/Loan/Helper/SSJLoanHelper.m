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
                NSError *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"参数state无效，有效值0、1、2"}];
                failure(error);
            }
            break;
    }
    
    [sqlStr appendString:@" order by jmoney desc"];
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:sqlStr];
        if (!result) {
            if (failure) {
                failure([db lastError]);
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
            success(list);
        }
    }];
}

+ (void)saveLoanModel:(SSJLoanModel *)model
              success:(void (^)())success
              failure:(void (^)(NSError *error))failure {
    
    NSString *booksID = SSJGetCurrentBooksType();
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        
        
        
//        if (successfull) {
//            if (success) {
//                success();
//            }
//        } else {
//            if (failure) {
//                failure([db lastError]);
//            }
//        }
    }];
}

+ (void)closeOutLoanModel:(SSJLoanModel *)model
                  success:(void (^)())success
                  failure:(void (^)(NSError *error))failure {
    
    NSString *booksID = SSJGetCurrentBooksType();
    
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        if (![db executeUpdate:@"update bk_loan set iend = ?, cenddate = ? where loanid = ?", @1, [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"], model.ID]) {
            
            *rollback = YES;
            if (failure) {
                failure([db lastError]);
            }
            
            return;
        }
        
        
        NSString *rollOutFundID = nil;
        NSString *rollInFundID = nil;
        
        switch (model.type) {
            case SSJLoanTypeLend:
                rollOutFundID = model.fundID;
                rollInFundID = model.targetFundID;
                
                break;
                
            case SSJLoanTypeBorrow:
                rollOutFundID = model.targetFundID;
                rollInFundID = model.fundID;
                
                break;
        }
        
        // 转出流水
        if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, cbilldate, cbooksid, iversion, operatortype, cwritedate) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", SSJUUID(), model.userID, model.jMoney, @4, rollOutFundID, model.borrowDate, booksID, @(model.version), @(model.operatorType), model.writeDate]) {
            
            *rollback = YES;
            if (failure) {
                failure([db lastError]);
            }
            
            return;
        }
        
        // 转入流水
        if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, cbilldate, cbooksid, iversion, operatortype, cwritedate) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", SSJUUID(), model.userID, model.jMoney, @3, rollInFundID, model.borrowDate, booksID, @(model.version), @(model.operatorType), model.writeDate]) {
            
            *rollback = YES;
            if (failure) {
                failure([db lastError]);
            }
            
            return;
        }
        
        // 关闭提醒
#warning todo
        
        if (success) {
            success();
        }
    }];
}

+ (BOOL)saveLoanModel:(SSJLoanModel *)model booksID:(NSString *)booksID inDatabase:(FMDatabase *)db {
    
    if (![db executeUpdate:@"replace into bk_loan (loanid, cuserid, lender, jmoney, cthefundid, ctargetfundid, cborrowdate, crepaymentdate, rate, memo, cremindid, interest, iend, itype) values (:ID, :userID, :lender, :jMoney, :fundID, :targetFundID, :borrowDate, :repaymentDate, :rate, :memo, :remindID, :interest, :closeOut, :type, :writeDate, :operatorType, :version)", model.mj_keyValues]) {
        return NO;
    }
    
    NSString *rollOutFundID = nil;
    NSString *rollInFundID = nil;
    NSString *rollOutChargeID = nil;
    NSString *rollInChargeID = nil;
    
    switch (model.type) {
        case SSJLoanTypeLend:
            rollOutFundID = model.targetFundID;
            rollInFundID = model.fundID;
            rollOutChargeID = model.targetChargeID;
            rollInChargeID = model.chargeID;
            
            break;
            
        case SSJLoanTypeBorrow:
            rollOutFundID = model.fundID;
            rollInFundID = model.targetFundID;
            rollOutChargeID = model.chargeID;
            rollInChargeID = model.targetChargeID;
            
            break;
    }
    
    // 转出流水
    if (![db executeUpdate:@"replace into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, cbilldate, cbooksid, iversion, operatortype, cwritedate) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", rollOutChargeID, model.userID, model.jMoney, @4, rollOutFundID, model.borrowDate, booksID, @(model.version), @(model.operatorType), model.writeDate]) {
        return NO;
    }
    
    // 转入流水
    if (![db executeUpdate:@"replace into bk_user_charge (ichargeid, cuserid, imoney, ibillid, ifunsid, cbilldate, cbooksid, iversion, operatortype, cwritedate) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", rollInChargeID, model.userID, model.jMoney, @3, rollInFundID, model.borrowDate, booksID, @(model.version), @(model.operatorType), model.writeDate]) {
        return NO;
    }
    
    return YES;
}

@end
