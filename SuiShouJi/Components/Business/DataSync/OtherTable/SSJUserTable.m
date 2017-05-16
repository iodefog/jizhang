//
//  SSJUserTable.m
//  SuiShouJi
//
//  Created by old lang on 17/5/9.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserTable.h"
#import "SSJDatabaseQueue.h"

@implementation SSJUserTable

+ (NSDictionary *)syncDataWithUserId:(NSString *)userId {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select cnickid, usersignature, cwritedate from bk_user where cuserid = ?", userId];
        while ([rs next]) {
            [info setObject:[rs stringForColumn:@"cnickid"] ?: @"" forKey:@"crealname"];
            [info setObject:[rs stringForColumn:@"usersignature"] ?: @"" forKey:@"usersignature"];
            [info setObject:[rs stringForColumn:@"cwritedate"] ?: @"" forKey:@"cwritedate"];
        }
        [rs close];
        
        [info setObject:userId forKey:@"cuserid"];
        [info setObject:SSJUniqueID() forKey:@"cimei"];
        [info setObject:SSJDefaultSource() forKey:@"isource"];
        [info setObject:@1 forKey:@"operatortype"];
    }];
    return info;
}

+ (BOOL)mergeData:(NSDictionary *)info {
    __block BOOL successfull = NO;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
        successfull = [db executeUpdate:@"update bk_user set cmobileno = ?, cnickid = ?, usersignature = ?, cicons = ? where cuserid = ?", info[@"cmobileno"], info[@"crealname"], info[@"usersignature"], info[@"cicon"], info[@"cuserid"]];
    }];
    return successfull;
}

@end
