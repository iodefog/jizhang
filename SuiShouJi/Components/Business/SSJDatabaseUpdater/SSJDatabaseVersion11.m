//
//  SSJDatabaseVersion11.m
//  SuiShouJi
//
//  Created by ricky on 2016/11/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion11.h"
#import "SSJDatabaseQueue.h"

@implementation SSJDatabaseVersion11

+ (NSString *)dbVersion {
    return @"unknown";
}

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    
    NSError *error = [self updateUserChargeTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateCreditRepaymentTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateBillTypeTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    return nil;
}

+ (NSError *)updateUserChargeTableWithDatabase:(FMDatabase *)db {
    
    // 新版本改造user_charge表,将原来的借贷id和周期记账还有新加的还款id统一成一个字段id,新加一个itype字段来区分id是哪一个id
    if (![db executeUpdate:@"alter table bk_user_charge add ichargetype integer"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"alter table bk_user_charge add cid text"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update bk_user_charge set ichargetype = ?, cid = loanid where length(loanid) > 0",@(SSJChargeIdTypeLoan)]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update bk_user_charge set ichargetype = ?, cid = iconfigid where length(iconfigid) > 0",@(SSJChargeIdTypeCircleConfig)]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update bk_user_charge set ichargetype = ? where ichargetype is null",@(SSJChargeIdTypeNormal)]) {
        return [db lastError];
    }
    
    // 创建临时表
    if (![db executeUpdate:@"create temporary table TMP_USER_CHARGE (ICHARGEID TEXT, CUSERID TEXT, IMONEY TEXT,  IBILLID TEXT, IFUNSID TEXT, CADDDATE TEXT , IOLDMONEY TEXT, IBALANCE TEXT, CBILLDATE TEXT, CMEMO TEXT, CIMGURL TEXT,  THUMBURL TEXT, IVERSION INTEGER, CWRITEDATE TEXT , OPERATORTYPE TEXT, CBOOKSID TEXT, CLIENTADDDATE TEXT , ICHARGETYPE INTEGER , CID TEXT , PRIMARY KEY(ICHARGEID))"]) {
        return [db lastError];
    }
    
    // 将原来表中的纪录插入到临时表中
    if (![db executeUpdate:@"insert into TMP_USER_CHARGE select ICHARGEID, CUSERID, IMONEY,  IBILLID, IFUNSID, CADDDATE , IOLDMONEY, IBALANCE, CBILLDATE, CMEMO, CIMGURL,  THUMBURL, IVERSION, CWRITEDATE, OPERATORTYPE, CBOOKSID, CLIENTADDDATE, ICHARGETYPE , CID from BK_USER_CHARGE"]) {
        return [db lastError];
    }
    
    // 删除原来的表
    if (![db executeUpdate:@"drop table BK_USER_CHARGE"]) {
        return [db lastError];
    }
    
    // 新建表
    if (![db executeUpdate:@"create table BK_USER_CHARGE (ICHARGEID TEXT, CUSERID TEXT, IMONEY TEXT,  IBILLID TEXT, IFUNSID TEXT, CADDDATE TEXT , IOLDMONEY TEXT, IBALANCE TEXT, CBILLDATE TEXT, CMEMO TEXT, CIMGURL TEXT,  THUMBURL TEXT, IVERSION INTEGER, CWRITEDATE TEXT , OPERATORTYPE TEXT, CBOOKSID TEXT, CLIENTADDDATE TEXT , ICHARGETYPE INTEGER DEFAULT 0, CID TEXT , PRIMARY KEY(ICHARGEID))"]) {
        return [db lastError];
    }
    
    // 将临时表数据插入新表
    if (![db executeUpdate:@"insert into BK_USER_CHARGE select * from TMP_USER_CHARGE"]) {
        return [db lastError];
    }
    
    return nil;
}

+ (NSError *)updateCreditRepaymentTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table BK_CREDIT_REPAYMENT (CREPAYMENTID TEXT, IINSTALMENTCOUNT INTEGER, CAPPLYDATE TEXT, CCARDID TEXT, REPAYMENTMONEY TEXT, IPOUNDAGERATE NUMERIC, CMEMO TEXT, CUSERID TEXT, OPERATORTYPE INTEGER, CWRITEDATE TEXT, IVERSION INTEGER, CREPAYMENTMONTH TEXT)"]) {
        return [db lastError];
    }
    
    return nil;
}


+ (NSError *)updateBillTypeTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"insert into BK_BILL_TYPE values ('11','信用卡分期本金','1','ft_cash','#fc7a60',2,0,'','','')"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"insert into BK_BILL_TYPE values ('12','信用卡分期手续费','1','bt_shouxufei','#ccb530',2,0,'','','')"]) {
        return [db lastError];
    }
    
    return nil;
}

@end
