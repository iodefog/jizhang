//
//  SSJMotionPasswordHelper.m
//  SuiShouJi
//
//  Created by old lang on 16/3/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMotionPasswordHelper.h"
#import "SSJDatabaseQueue.h"

@implementation SSJMotionPasswordHelper

+ (NSArray *)queryMotionPassword {
    __block NSString *pass = nil;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
         pass = [db stringForQuery:@"select cfpwd from bk_user where cuserid = ?", SSJUSERID()];
    }];
    return [pass componentsSeparatedByString:@","];
}

+ (BOOL)saveMotionPassword:(NSArray *)password {
    __block BOOL success = YES;
    NSString *passwordStr = [password componentsJoinedByString:@","];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:@"update bk_user set cfpwd = ? where cuserid = ?", passwordStr, SSJUSERID()];
    }];
    return success;
}

@end
