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

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    
    NSError *error = [self updateUserChargeTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    return nil;
}

+ (NSError *)updateUserChargeTableWithDatabase:(FMDatabase *)db {
    
    // 新版本改造user_charge表,将原来的借贷id和周期记账还有新加的还款id统一成一个字段id,新加一个itype字段来区分id是哪一个id
    if (![db executeUpdate:@"alter table bk_user_charge add itype integer"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"alter table bk_user_charge add id text"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update bk_user_charge set itype = ? and id = loanid where length(loanid) > 0",SSJChargeIdTypeLoan]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update bk_user_charge set itype = ? and id = iconfigid where length(iconfigid) > 0",SSJChargeIdTypeCircleConfig]) {
        return [db lastError];
    }
    
    // 创建临时表
    if (![db executeUpdate:@"create temporary table TMP_USER_CHARGE (ICHARGEID TEXT, CUSERID TEXT, IMONEY TEXT,  IBILLID TEXT, IFUNSID TEXT, CADDDATE TEXT , IOLDMONEY TEXT, IBALANCE TEXT, CBILLDATE TEXT, CMEMO TEXT, CIMGURL TEXT,  THUMBURL TEXT, IVERSION INTEGER, CWRITEDATE TEXT , OPERATORTYPE TEXT, CBOOKSID TEXT, CLIENTADDDATE TEXT , ITYPE INTEGER , ID TEXT , PRIMARY KEY(ICHARGEID))"]) {
        return [db lastError];
    }
    
    // 将原来表中的纪录插入到临时表中
    if (![db executeUpdate:@"insert into TMP_USER_CHARGE select ICHARGEID, CUSERID, IMONEY,  IBILLID, IFUNSID, CADDDATE , IOLDMONEY, IBALANCE, CBILLDATE, CMEMO, CIMGURL,  THUMBURL, IVERSION, CWRITEDATE, OPERATORTYPE, CBOOKSID, CLIENTADDDATE, ITYPE , ID from BK_BILL_TYPE"]) {
        return [db lastError];
    }
    
    // 删除原来的表
    if (![db executeUpdate:@"drop table BK_USER_CHARGE"]) {
        return [db lastError];
    }
    
    // 新建表
    if (![db executeUpdate:@"create table BK_USER_CHARGE (ICHARGEID TEXT, CUSERID TEXT, IMONEY TEXT,  IBILLID TEXT, IFUNSID TEXT, CADDDATE TEXT , IOLDMONEY TEXT, IBALANCE TEXT, CBILLDATE TEXT, CMEMO TEXT, CIMGURL TEXT,  THUMBURL TEXT, IVERSION INTEGER, CWRITEDATE TEXT , OPERATORTYPE TEXT, CBOOKSID TEXT, CLIENTADDDATE TEXT , ITYPE INTEGER , ID TEXT , PRIMARY KEY(ICHARGEID))"]) {
        return [db lastError];
    }
    
    // 将临时表数据插入新表
    if (![db executeUpdate:@"insert into BK_USER_CHARGE select * from TMP_USER_CHARGE"]) {
        return [db lastError];
    }
    
    return nil;
}

@end
