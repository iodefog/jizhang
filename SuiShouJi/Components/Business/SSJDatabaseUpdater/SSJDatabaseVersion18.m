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

+ (NSError *)updateLoanChargesWithDatabase:(FMDatabase *)db {
    NSMutableArray *chargeModels = [NSMutableArray array];
    FMResultSet *rs = [db executeQuery:@"select ichargeid, ibillid, ifunsid, cid, cuserid, cbilldate, cwritedate from bk_user_charge where ichargetype = ? and operatortype <> 2 order by cwritedate", @(SSJChargeIdTypeLoan)];
    while ([rs next]) {
        SSJLoanChargeModel *model = [[SSJLoanChargeModel alloc] init];
        model.chargeId = [rs stringForColumn:@"ichargeid"];
        model.billId = [rs stringForColumn:@"ibillid"];
        model.fundId = [rs stringForColumn:@"ifunsid"];
        model.loanId = [rs stringForColumn:@"cid"];
        model.userId = [rs stringForColumn:@"cuserid"];
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

        NSString *loanOutFundID = [NSString stringWithFormat:@"%@-5", model.userId];
        NSString *borrowFundID = [NSString stringWithFormat:@"%@-6", model.userId];
        
        if ([model.fundId isEqualToString:loanOutFundID]
            || [model.fundId isEqualToString:borrowFundID]) {
            
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
    
    __block NSError *tError = nil;
    __block int64_t timestamp = SSJMilliTimestamp();
    [compoundModels enumerateObjectsUsingBlock:^(SSJLoanCompoundChargeModel *compoundModel, NSUInteger idx, BOOL * _Nonnull stop) {
        timestamp += idx;
        NSString *cid = [NSString stringWithFormat:@"%@_%lld", compoundModel.chargeModel.loanId, timestamp];
        
        if (![self updateLoanChargeWithModel:compoundModel.chargeModel cid:cid db:db error:&tError]) {
            return;
        }
        
        if (![self updateLoanChargeWithModel:compoundModel.targetChargeModel cid:cid db:db error:&tError]) {
            return;
        }
        
        if (compoundModel.interestChargeModel) {
            if (![self updateLoanChargeWithModel:compoundModel.interestChargeModel cid:cid db:db error:&tError]) {
                return;
            }
        }
    }];
    
    if (tError) {
        if (error) {
            *error = tError;
        }
        return NO;
    }
    
    return YES;
}

+ (BOOL)updateLoanChargeWithModel:(SSJLoanChargeModel *)model
                              cid:(NSString *)cid
                               db:(FMDatabase *)db
                            error:(NSError **)error {
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    if (![db executeUpdate:@"update bk_user_charge set cid = ?, operatortype = 1, iversion = ?, cwritedate = ? where ichargeid = ? and operatortype <> 2", cid, @(SSJSyncVersion()), writeDate, model.chargeId]) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }
    return YES;
}

@end
