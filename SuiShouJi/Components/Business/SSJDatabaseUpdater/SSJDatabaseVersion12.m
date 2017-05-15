//
// Created by ricky on 2017/1/24.
// Copyright (c) 2017 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion12.h"
#import "SSJDatabaseQueue.h"

@implementation SSJDatabaseVersion12

+ (NSString *)dbVersion {
    return @"2.1.0";
}

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {

    NSError *error = [self updateUserChargeTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self createTransferCycleTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateUserTableWithDatabase:db];
    if (error) {
        return error;
    }

    return nil;
}

+ (NSError *)updateUserChargeTableWithDatabase:(FMDatabase *)db {

    // 添加记账时分字段
    if (![db columnExists:@"cdetaildate" inTableWithName:@"bk_user_charge"]) {
        if (![db executeUpdate:@"alter table bk_user_charge add cdetaildate text"]) {
            return [db lastError];
        }
    }
    
    
    if (![db executeUpdate:@"update bk_user_charge set cdetaildate = '00:00' where ichargetype = ?", @(SSJChargeIdTypeCircleConfig)]) {
        return [db lastError];
    }

    // 修改记账时分字段
    if (![db executeUpdate:@"update bk_user_charge set cdetaildate = (select substr(clientadddate,12,5) from bk_user_charge) where length(clientadddate) > 0 and ichargetype <> ?", @(SSJChargeIdTypeCircleConfig)]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update bk_user_charge set cdetaildate = (select substr(cwritedate,12,5) from bk_user_charge) where length(cdetaildate) = 0 or cdetaildate is null"]) {
        return [db lastError];
    }
    
    return nil;
}

+ (NSError *)createTransferCycleTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"CREATE TABLE IF NOT EXISTS BK_TRANSFER_CYCLE (ICYCLEID TEXT, CUSERID TEXT NOT NULL, CTRANSFERINACCOUNTID TEXT NOT NULL, CTRANSFEROUTACCOUNTID TEXT NOT NULL, IMONEY REAL, CMEMO TEXT, ICYCLETYPE INTEGER, CBEGINDATE TEXT NOT NULL, CENDDATE TEXT, ISTATE INTEGER DEFAULT 1, CLIENTADDDATE TEXT NOT NULL, CWRITEDATE TEXT NOT NULL, IVERSION INTEGER, OPERATORTYPE INTEGER, PRIMARY KEY(ICYCLEID))"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)updateUserTableWithDatabase:(FMDatabase *)db {
    // 添加记账时分字段
    if (![db columnExists:@"CADVICETIME" inTableWithName:@"bk_user"]) {
        if (![db executeUpdate:@"alter table bk_user add CADVICETIME TEXT"]) {
            return [db lastError];
        }

    }
    return nil;
}

@end
