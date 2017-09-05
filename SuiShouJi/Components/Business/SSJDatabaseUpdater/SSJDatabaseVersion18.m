//
//  SSJDatabaseVersion18.m
//  SuiShouJi
//
//  Created by old lang on 2017/8/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion18.h"
#import "FMDB.h"
#import "SSJLoanCompoundChargeModel.h"
#import "SSJBillTypeManager.h"

@implementation SSJDatabaseVersion18

+ (NSString *)dbVersion {
    return @"2.8.0";
}

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    NSError *error = [self createRecycleTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self insertSpecialBillTypeWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateLoanChargesWithDatabase:db];
    if (error) {
        return error;
    }
    
    return nil;
}

+ (NSError *)createRecycleTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"CREATE TABLE IF NOT EXISTS BK_RECYCLE (\
                                                        RID	TEXT,\
                                                        CUSERID TEXT,\
                                                        CID	TEXT,\
                                                        ITYPE INTEGER,\
                                                        CLIENTADDDATE TEXT,\
                                                        CWRITEDATE	TEXT,\
                                                        OPERATORTYPE INTEGER,\
                                                        IVERSION INTEGER,\
                                                        PRIMARY KEY(RID))"]) {
        return [db lastError];
    }
    
    return nil;
}

/**
 插入固收理财特殊类别
 */
+ (NSError *)insertSpecialBillTypeWithDatabase:(FMDatabase *)db {
    for (SSJSpecialBillId billID = SSJSpecialBillIdFixedFinanceChangeEarning;
         billID <= SSJSpecialBillIdFixedFinanceServiceCharge;
         billID ++) {
        
        if ([db boolForQuery:@"select count(1) from bk_user_bill_type where cbillid = ?", @(billID)]) {
            continue;
        }
        
        NSString *billIDStr = [NSString stringWithFormat:@"%d", (int)billID];
        NSDictionary *info = [SSJBillTypeManager sharedManager].specialBillTypes[billIDStr];
        
        if (![db executeUpdate:@"insert into bk_user_bill_type (cbillid, itype, cname, ccolor, cicoin) values (:ID, :expended, :name, :color, :icon)" withParameterDictionary:info]) {
            return db.lastError;
        }
    }
    return nil;
}

/**
 升级借贷流水；将原有的流水改为删除状态，重新生成一份新的流水，chargeid用新的拼接格式
 */
+ (NSError *)updateLoanChargesWithDatabase:(FMDatabase *)db {
    NSMutableArray *chargeModels = [NSMutableArray array];
    FMResultSet *rs = [db executeQuery:@"select * from bk_user_charge where ichargetype = ? and operatortype <> 2 order by cwritedate", @(SSJChargeIdTypeLoan)];
    while ([rs next]) {
        SSJLoanChargeModel *model = [[SSJLoanChargeModel alloc] init];
        model.chargeId = [rs stringForColumn:@"ichargeid"];
        model.fundId = [rs stringForColumn:@"ifunsid"];
        model.billId = [rs stringForColumn:@"ibillid"];
        model.loanId = [rs stringForColumn:@"cid"];
        model.userId = [rs stringForColumn:@"cuserid"];
        model.money = [rs doubleForColumn:@"money"];
        model.memo = [rs stringForColumn:@"cmemo"];
        model.billDate = [NSDate dateWithString:[rs stringForColumn:@"cbilldate"] formatString:@"yyyy-MM-dd"];
        model.writeDate = [NSDate dateWithString:[rs stringForColumn:@"cwritedate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
        [chargeModels addObject:model];
    }
    [rs close];
    
    NSError *error = nil;
    [self updateLoanChargesWithModels:chargeModels database:db error:&error];
    
    return error;
}

+ (BOOL)updateLoanChargesWithModels:(NSArray<SSJLoanChargeModel *> *)models
                           database:(FMDatabase *)db
                              error:(NSError **)error {
    
    NSMutableArray *targetModels = [NSMutableArray array];
    NSMutableArray *compoundModels = [NSMutableArray array];
    
    for (SSJLoanChargeModel *model in models) {
        SSJFinancingParent fundType = [db intForQuery:@"select cparent from bk_fund_info where cfundid = ?", model.fundId];
        
        if (fundType == SSJFinancingParentPaidLeave
            || fundType == SSJFinancingParentDebt) {

            SSJLoanCompoundChargeModel *compoundModel = [[SSJLoanCompoundChargeModel alloc] init];
            compoundModel.chargeModel = model;
            [compoundModels addObject:compoundModel];
            
        } else {
            [targetModels addObject:model];
        }
    }
    
    for (SSJLoanChargeModel *model in targetModels) {
        for (SSJLoanCompoundChargeModel *compoundModel in compoundModels) {
            
            if (compoundModel.chargeModel
                && compoundModel.targetChargeModel
                && compoundModel.interestChargeModel) {
                continue;
            }
            
            if ([compoundModel.chargeModel.loanId isEqualToString:model.loanId]
                && [compoundModel.chargeModel.userId isEqualToString:model.userId]
                && [compoundModel.chargeModel.billDate compare:model.billDate] == NSOrderedSame
                && [compoundModel.chargeModel.writeDate compare:model.writeDate] == NSOrderedSame) {
                
                if ([model.billId integerValue] == SSJSpecialBillIdLoanInterestEarning
                    || [model.billId integerValue] == SSJSpecialBillIdLoanInterestExpense) {
                    compoundModel.interestChargeModel = model;
                } else {
                    compoundModel.targetChargeModel = model;
                }
            }
        }
    }
    
    __block NSTimeInterval timestamp = [NSDate date].timeIntervalSince1970;
    
    [compoundModels enumerateObjectsUsingBlock:^(SSJLoanCompoundChargeModel *compoundModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        int billID = [compoundModel.chargeModel.billId intValue];
        int targetBillID = [compoundModel.targetChargeModel.billId intValue];
        
        NSString *preChargeID = billID < targetBillID ? compoundModel.chargeModel.chargeId : compoundModel.targetChargeModel.chargeId;
        NSString *writeDate = [[NSDate dateWithTimeIntervalSince1970:timestamp] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        NSString *chargeID = [NSString stringWithFormat:@"%@_%@", preChargeID, compoundModel.chargeModel.billId];
        if (![self upgradeChargeWithModel:compoundModel.chargeModel
                              newChargeID:chargeID
                                writeDate:writeDate
                                 database:db
                                    error:error]) {
            *stop = YES;
            return;
        }
        
        
        NSString *targetChargeID = [NSString stringWithFormat:@"%@_%@", preChargeID, compoundModel.targetChargeModel.billId];
        if (![self upgradeChargeWithModel:compoundModel.targetChargeModel
                              newChargeID:targetChargeID
                                writeDate:writeDate
                                 database:db
                                    error:error]) {
            *stop = YES;
            return;
        }
        
        if (compoundModel.interestChargeModel) {
            NSString *interestChargeID = [NSString stringWithFormat:@"%@_%@", preChargeID, compoundModel.interestChargeModel.billId];
            if (![self upgradeChargeWithModel:compoundModel.interestChargeModel
                                  newChargeID:interestChargeID
                                    writeDate:writeDate
                                     database:db
                                        error:error]) {
                *stop = YES;
                return;
            }
        }
        
        timestamp += 0.001;
    }];
    
    if (error && *error) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)upgradeChargeWithModel:(SSJLoanChargeModel *)model
                   newChargeID:(NSString *)newChargeID
                     writeDate:(NSString *)writeDate
                      database:(FMDatabase *)db
                         error:(NSError **)error {
    
    if (![db executeUpdate:@"update bk_user_charge set operatortype = 2, iversion = ?, cwritedate = ? where ichargeid = ? and operatortype <> 2", @(SSJSyncVersion()), writeDate, model.chargeId]) {
        return NO;
    }
    
    NSDictionary *params = @{@"ichargeid":newChargeID,
                             @"ifunsid":model.fundId,
                             @"ibillid":model.billId,
                             @"cid":model.loanId,
                             @"cuserid":model.userId,
                             @"cmemo":model.memo,
                             @"cbilldate":model.billDate,
                             @"imoney":@(model.money),
                             @"iversion":@(SSJSyncVersion()),
                             @"operatortype":@0,
                             @"cwritedate":writeDate};
    
    if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, ifunsid, ibillid, cid, cuserid, cmemo, cbilldate, imoney, iversion, operatortype, cwritedate) values (:ichargeid, :ifunsid, :ibillid, :cid, :cuserid, :cmemo, :cbilldate, :imoney, :iversion, :operatortype, :cwritedate)" withParameterDictionary:params]) {
        return NO;
    }
    
    return YES;
}

@end
