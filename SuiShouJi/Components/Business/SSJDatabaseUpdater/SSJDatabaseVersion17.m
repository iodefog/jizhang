//
//  SSJDatabaseVersion17.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/13.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion17.h"
#import "FMDB.h"

@implementation SSJDatabaseVersion17

+ (NSString *)dbVersion {
    return @"2.7.0";
}

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    NSError *error = [self createWishTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self createWishChargeTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self createUserBillTypeTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self migrateBillTypeRecordsToNewTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    return nil;
}

+ (NSError *)createWishTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists BK_WISH(WISHID text not null, CUSERID text not null, WISHNAME text not null, WISHMONEY real not null, WISHIMAGE text, IVERSION integer, CWRITEDATE text, OPERATORTYPE integer, ISFINISHED integer, REMINDID text, STARTDATE text, ENDDATE text, WISHTYPE integer,primary key(WISHID))"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)createWishChargeTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists BK_WISH_CHARGE(CHARGEID text not null, MONEY real not null, WISHID text not null, CUSERID text not null, IVERSION integer, CWRITEDATE text, OPERATORTYPE integer, MEMO text, ITYPE integer, CBILLDATE text, primary key(CHARGEID))"]) {
        return db.lastError;
    }
    return nil;
}

+ (NSError *)createUserBillTypeTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"CREATE TABLE IF NOT EXISTS BK_USER_BILL_TYPE (CBILLID TEXT, CUSERID TEXT, CBOOKSID TEXT, ITYPE INTEGER, CNAME TEXT, CCOLOR TEXT, CICOIN TEXT, IORDER INTEGER, CWRITEDATE TEXT, OPERATORTYPE INTEGER, IVERSION INTEGER, PRIMARY KEY(CBILLID, CUSERID, CBOOKSID))"]) {
        return db.lastError;
    }
    return nil;
}

// 将bk_bill_type和bk_user_bill的数据迁移到bk_user_bill_type
+ (NSError *)migrateBillTypeRecordsToNewTableWithDatabase:(FMDatabase *)db {
    NSString *writeDateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    FMResultSet *rs = [db executeQuery:@"select cuserid from bk_user"];
    if (!rs) {
        return [db lastError];
    }
    
    while ([rs next]) {
        NSDictionary *info = @{@"cwritedate":writeDateStr,
                               @"iversion":@(SSJSyncVersion()),
                               @"cuserid":[rs stringForColumn:@"cuserid"]};
        
        // 将流水依赖的收支类别迁移到新表中
        if (![db executeUpdate:@"insert into bk_user_bill_type (cbillid, cuserid, cbooksid, iorder, itype, cname, ccolor, cicoin, cwritedate, operatortype, iversion) select ub.cbillid, ub.cuserid, ub.cbooksid, ub.iorder, bt.itype, bt.cname, bt.ccolor, bt.ccoin, :cwritedate, ub.operatortype, :iversion from bk_bill_type as bt, bk_user_bill as ub where bt.id = ub.cbillid and ub.cuserid = :cuserid and ub.cbillid in (select distinct ibillid from bk_user_charge where operatortype <> 2 and cuserid = :cuserid)" withParameterDictionary:info]) {
            return [db lastError];
        }
        
        // 将周期记账依赖的收支类别迁移到新表中
        if (![db executeUpdate:@"replace into bk_user_bill_type (cbillid, cuserid, cbooksid, iorder, itype, cname, ccolor, cicoin, cwritedate, operatortype, iversion) select ub.cbillid, ub.cuserid, ub.cbooksid, ub.iorder, bt.itype, bt.cname, bt.ccolor, bt.ccoin, :cwritedate, ub.operatortype, :iversion from bk_bill_type as bt, bk_user_bill as ub where bt.id = ub.cbillid and ub.cuserid = :cuserid and ub.cbillid in (select distinct ibillid from bk_charge_period_config where operatortype <> 2 and istate = 1 and cuserid = :cuserid)" withParameterDictionary:info]) {
            return [db lastError];
        }
    }
    [rs close];
    
    return nil;
}

@end
