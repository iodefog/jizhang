//
//  SSJDatabaseUpgrader.m
//  SuiShouJi
//
//  Created by old lang on 16/3/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatabaseUpgrader.h"
#import "SSJDatabaseQueue.h"

@implementation SSJDatabaseUpgrader

+ (NSError *)upgradeDatabase {
    __block NSError *error = nil;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        error = [self upgraderUserChargeTableWithDatabase:db];
        error = [self createUserBudgetTableWithDatabase:db];
        error = [self crateImageSyncTableWithDatabase:db];
        error = [self crateChargePeriodConfigTableWithDatabase:db];
        error = [self crateChargeReminderTableWithDatabase:db];
        error = [self upgradeUserTableWithDatabase:db];
    }];
    return error;
}

+ (void)upgradeDatabaseWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSError *error = [self upgraderUserChargeTableWithDatabase:db];
        error = [self createUserBudgetTableWithDatabase:db];
        error = [self crateImageSyncTableWithDatabase:db];
        error = [self crateChargePeriodConfigTableWithDatabase:db];
        error = [self crateChargeReminderTableWithDatabase:db];
        if (error) {
            if (failure) {
                failure(error);
            }
        } else {
            if (success) {
                success();
            }
        }
    }];
}

+ (NSError *)upgraderUserChargeTableWithDatabase:(FMDatabase *)db {
    NSError *error = nil;
    if (![db columnExists:@"iconfigid" inTableWithName:@"bk_user_charge"]) {
        if (![db executeUpdate:@"alter table bk_user_charge add iconfigid text"]) {
            error = [db lastError];
        }
    }
    if (![db columnExists:@"cimgurl" inTableWithName:@"bk_user_charge"]) {
        if (![db executeUpdate:@"alter table bk_user_charge add cimgurl text"]) {
            error = [db lastError];
        }
    }
    if (![db columnExists:@"cmemo" inTableWithName:@"bk_user_charge"]) {
        if (![db executeUpdate:@"alter table bk_user_charge add cmemo text"]) {
            error = [db lastError];
        }
    }
    return error;
}

+ (NSError *)createUserBudgetTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists bk_user_budget (ibid text not null, cuserid text not null, itype integer not null, imoney real not null, iremindmoney real not null, csdate text not null, cedate text not null, istate integer not null, ccadddate text not null, cbilltype text not null, iremind integer not null, hasremind integer not null, cwritedate text not null, iversion integer not null, operatortype integer not null, primary key(ibid))"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)crateImageSyncTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists bk_img_sync (rid text not null, cimgname text not null, cwritedate text not null, operatortype integer not null, isynctype integer not null, isyncstate integer not null, primary key(cimgname))"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)crateChargePeriodConfigTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists bk_charge_period_config (iconfigid text not null, cuserid text not null, ibillid text not null, ifunsid text not null, itype integer not null, imoney text not null, cimgurl text, cmemo text, cbilldate text, istate integer, iversion integer not null, cwritedate text not null, operatortype integer not null, primary key(iconfigid))"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)crateChargeReminderTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"create table if not exists bk_charge_reminder (isonornot text not null, time text, circle text)"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)upgradeUserTableWithDatabase:(FMDatabase *)db {
    NSError *error = nil;
    if (![db columnExists:@"cmotionpwd" inTableWithName:@"bk_user"]) {
        if (![db executeUpdate:@"alter table bk_user add cmotionpwd text"]) {
            error = [db lastError];
        }
    }
    if (![db columnExists:@"cmotionpwdstate" inTableWithName:@"bk_user"]) {
        if (![db executeUpdate:@"alter table bk_user add cmotionpwdstate text default 1"]) {
            error = [db lastError];
        }
    }
    return error;
}

@end
