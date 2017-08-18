//
//  SSJDatabaseVersion17.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/13.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion17.h"
#import "FMDB.h"
#import "SSJBillTypeManager.h"

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
    
    error = [self insertSpecialBillTypeWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self migrateBillTypeRecordsToNewTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateUserTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateTheTransferTableInDataBase:db];
    if (error) {
        return error;
    }
    
    return nil;
}

+ (NSError *)createWishTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists BK_WISH(WISHID text not null, CUSERID text not null, WISHNAME text not null, WISHMONEY real not null, WISHIMAGE text, IVERSION integer, CWRITEDATE text, OPERATORTYPE integer, STATUS integer, REMINDID text, STARTDATE text, ENDDATE text, WISHTYPE integer,primary key(WISHID))"]) {
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

+ (NSError *)insertSpecialBillTypeWithDatabase:(FMDatabase *)db {
    NSString *writeDateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    for (NSDictionary *billTypeInfo in [[SSJBillTypeManager sharedManager].specialBillTypes allValues]) {
        NSDictionary *param = @{@"cbillid":billTypeInfo[@"ID"],
                                @"itype":billTypeInfo[@"expended"],
                                @"cname":billTypeInfo[@"name"],
                                @"ccolor":billTypeInfo[@"color"],
                                @"cicoin":billTypeInfo[@"icon"]};
        
        if (![db executeUpdate:@"insert into bk_user_bill_type (cbillid, itype, cname, ccolor, cicoin) values (:cbillid, :itype, :cname, :ccolor, :cicoin)" withParameterDictionary:param]) {
            return db.lastError;
        }
    }
    return nil;
}

// 将bk_bill_type和bk_user_bill的数据迁移到bk_user_bill_type
+ (NSError *)migrateBillTypeRecordsToNewTableWithDatabase:(FMDatabase *)db {
    NSString *writeDateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSDictionary *info = @{@"cwritedate":writeDateStr,
                           @"iversion":@(SSJSyncVersion())};
    
    // 未开启的类别迁移到新表中改为删除
    [db executeUpdate:@"update bk_user_bill set operatortype = 2 where istate = 0"];
    
    // 将流水依赖的收支类别迁移到新表中
    if (![db executeUpdate:@"insert into bk_user_bill_type (cbillid, cuserid, cbooksid, iorder, itype, cname, ccolor, cicoin, cwritedate, operatortype, iversion) select ub.cbillid, ub.cuserid, ub.cbooksid, ub.iorder, bt.itype, bt.cname, bt.ccolor, bt.ccoin, :cwritedate, ub.operatortype, :iversion from bk_bill_type as bt, bk_user_bill as ub, bk_user_charge as uc where bt.id = ub.cbillid and ub.cuserid = uc.cuserid and ub.cbillid = uc.ibillid and ub.cbooksid = uc.cbooksid and uc.operatortype <> 2 group by ub.cbillid, ub.cbooksid, ub.cuserid" withParameterDictionary:info]) {
        return [db lastError];
    }
    
    // 将周期记账依赖的收支类别迁移到新表中
    if (![db executeUpdate:@"replace into bk_user_bill_type (cbillid, cuserid, cbooksid, iorder, itype, cname, ccolor, cicoin, cwritedate, operatortype, iversion) select ub.cbillid, ub.cuserid, ub.cbooksid, ub.iorder, bt.itype, bt.cname, bt.ccolor, bt.ccoin, :cwritedate, ub.operatortype, :iversion from bk_bill_type as bt, bk_user_bill as ub, bk_charge_period_config as pc where bt.id = ub.cbillid and ub.cuserid = pc.cuserid and ub.cbillid = pc.ibillid and ub.cbooksid = pc.cbooksid and pc.operatortype <> 2 group by ub.cbillid, ub.cbooksid, ub.cuserid" withParameterDictionary:info]) {
        return [db lastError];
    }
    
    // 将自定义类别迁移到新表中
    if (![db executeUpdate:@"replace into bk_user_bill_type (cbillid, cuserid, cbooksid, iorder, itype, cname, ccolor, cicoin, cwritedate, operatortype, iversion) select ub.cbillid, ub.cuserid, ub.cbooksid, ub.iorder, bt.itype, bt.cname, bt.ccolor, bt.ccoin, :cwritedate, ub.operatortype, :iversion from bk_bill_type as bt, bk_user_bill as ub where bt.id = ub.cbillid and ub.operatortype <> 2 and bt.icustom = 1" withParameterDictionary:info]) {
        return [db lastError];
    }
    
    return nil;
}

+ (NSError *)updateUserTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table BK_USER add CLASTMERGETIME TEXT"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)updateTheTransferTableInDataBase:(FMDatabase *)db {
    // 将以前的转账包括安卓chargetype为4的转账转移到周期转账表里
    
    NSMutableArray *chargeArr = [NSMutableArray arrayWithCapacity:0];
    
    FMResultSet *rs = [db executeQuery:@"select * from bk_user_charge where ibillid = ? and operatortype <> 2 and (ichargetype = ? or ichargetype = ?)",@(SSJSpecialBillIdBalanceRollIn),@(SSJChargeIdTypeTransfer),@(SSJChargeIdTypeNormal)];
    
    if (!rs) {
        return [db lastError];
    }
    
    while ([rs next]) {
        NSMutableDictionary *userCharge = [NSMutableDictionary dictionaryWithCapacity:0];
        [userCharge setObject:[rs stringForColumn:@"ifunsid"] forKey:@"ifunsid"];
        [userCharge setObject:[rs stringForColumn:@"cwritedate"] forKey:@"cwritedate"];
        [userCharge setObject:[rs stringForColumn:@"ichargeid"] forKey:@"ichargeid"];
        [userCharge setObject:[rs stringForColumn:@"cuserid"] forKey:@"cuserid"];
        [userCharge setObject:[rs stringForColumn:@"ibillid"] forKey:@"ibillid"];
        [userCharge setObject:[rs stringForColumn:@"imoney"] forKey:@"imoney"];
        [userCharge setObject:[rs stringForColumn:@"cbilldate"] forKey:@"cbilldate"];
        [userCharge setObject:[rs stringForColumn:@"cmemo"] forKey:@"cmemo"];
        [chargeArr addObject:userCharge];
    }
    
    [rs close];
    
    for (NSMutableDictionary *userCharge in chargeArr) {
        NSString *writeDateStr = [userCharge objectForKey:@"cwritedate"];
        NSString *fundId = [userCharge objectForKey:@"ifunsid"];
        NSString *chargeid = [userCharge objectForKey:@"ichargeid"];
        NSString *userid = [userCharge objectForKey:@"cuserid"];
        NSString *money = [userCharge objectForKey:@"imoney"];
        NSString *billDate = [userCharge objectForKey:@"cbilldate"];
        NSString *memo = [userCharge objectForKey:@"cmemo"];
        NSDate *writeDate = [NSDate dateWithString:writeDateStr formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSDate *startDate = [writeDate dateBySubtractingSeconds:1];
        NSDate *endDate = [writeDate dateByAddingSeconds:1];
        NSString *otherChargeId = [db stringForQuery:@"select ichargeid from bk_user_charge where cwritedate between ? and ? and ibillid = ? and imoney = ? and cuserid = ? and cbilldate = ? limit 1",[startDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[endDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSpecialBillIdBalanceRollOut),money,userid,billDate];
        if (otherChargeId.length) {
            NSString *otherFundid = [db stringForQuery:@"select ifunsid from bk_user_charge where ichargeid = ?",otherChargeId];
            NSString *cycleId = SSJUUID();
            NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            NSMutableDictionary *transferCycle = [NSMutableDictionary dictionaryWithCapacity:0];
            [transferCycle setObject:cycleId forKey:@"icycleid"];
            [transferCycle setObject:userid forKey:@"cuserid"];
            [transferCycle setObject:fundId forKey:@"ctransferinaccountid"];
            [transferCycle setObject:otherFundid forKey:@"ctransferoutaccountid"];
            [transferCycle setObject:money forKey:@"imoney"];
            [transferCycle setObject:memo forKey:@"cmemo"];
            [transferCycle setObject:@(SSJCyclePeriodTypeOnce) forKey:@"icycletype"];
            [transferCycle setObject:billDate forKey:@"cbegindate"];
            [transferCycle setObject:@(1) forKey:@"istate"];
            [transferCycle setObject:writeDate forKey:@"cwritedate"];
            [transferCycle setObject:@(SSJSyncVersion()) forKey:@"iversion"];
            [transferCycle setObject:@(1) forKey:@"operatortype"];
            [transferCycle setObject:writeDate forKey:@"clientadddate"];
            if (![db executeUpdate:@"insert into bk_transfer_cycle (icycleid, cuserid, ctransferinaccountid, ctransferoutaccountid, imoney, cmemo, icycletype, cbegindate, istate, cwritedate, iversion, operatortype, clientadddate) values (:icycleid, :cuserid, :ctransferinaccountid, :ctransferoutaccountid, :imoney, :cmemo, :icycletype, :cbegindate, :istate, :cwritedate, :iversion, :operatortype, :clientadddate)" withParameterDictionary:transferCycle]) {
                return [db lastError];
            }
        
            if (![db executeUpdate:@"update bk_user_charge set ichargetype = ?, cid = ?, cwritedate = ?, iversion = ?, operatortype = ? where ichargeid = ? and cuserid = ?",@(SSJChargeIdTypeCyclicTransfer),cycleId,writeDate,@(SSJSyncVersion()),@(1),otherChargeId,userid]) {
                return [db lastError];
            }
            
            if (![db executeUpdate:@"update bk_user_charge set ichargetype = ?, cid = ?, cwritedate = ?, iversion = ?, operatortype = ? where ichargeid = ? and cuserid = ?",@(SSJChargeIdTypeCyclicTransfer),cycleId,writeDate,@(SSJSyncVersion()),@(1),chargeid,userid]) {
                return [db lastError];
            }
        } else {
            if (![db executeUpdate:@"delete from bk_user_charge where ichargeid = ?",chargeid]) {
                return [db lastError];
            }
        }
    }

    return nil;
}

@end
