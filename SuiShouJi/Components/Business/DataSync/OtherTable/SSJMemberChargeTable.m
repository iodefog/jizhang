//
//  SSJMemberChargeTable.m
//  SuiShouJi
//
//  Created by old lang on 16/7/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMemberChargeTable.h"
#import "SSJDatabaseQueue.h"

@implementation SSJMemberChargeTable

+ (BOOL)supplementMemberChargeRecords {
    __block BOOL success = YES;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        success = [self supplementMemberChargeRecordsInDatabase:db];
    }];
    return success;
}

+ (BOOL)supplementMemberChargeRecordsInDatabase:(FMDatabase *)db {
    return [db executeUpdate:@"insert into bk_member_charge (ichargeid, cmemberid, imoney, iversion, cwritedate, operatortype) select ichargeid, '0', imoney, ?, ?, 0", @(SSJSyncVersion()), [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"]];
}

@end
