//
//  SSJUserTableManager.m
//  SuiShouJi
//
//  Created by old lang on 16/1/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserTableManager.h"
#import "SSJDatabaseQueue.h"

@implementation SSJUserTableManager

+ (void)reloadUserIdWithError:(NSError **)error {
    __block NSError *tError = nil;
    
    if (SSJUSERID().length) {
        tError = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"current userid is invalid"}];
        SSJPRINT(@">>> SSJ warning:current userid is invalid");
        if (error) {
            *error = tError;
        }
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {

        NSString *tUserId = [self unregisteredUserIdInDatabase:db error:&tError];
        
        if (tError) {
            if (error) {
                *error = tError;
            }
            return;
        }
        
        if (tUserId.length) {
            SSJSetUserId(tUserId);
            return;
        }
        
        tUserId = SSJUUID();
        if (![db executeUpdate:@"insert into BK_USER (CUSERID, CREGISTERSTATE, CDEFAULTFUNDACCTSTATE) values (?, 0, 0)", tUserId]) {
            tError = [db lastError];
            if (error) {
                *error = tError;
            }
            return;
        }
        
        SSJSetUserId(tUserId);
    }];
}

+ (NSString *)unregisteredUserIdInDatabase:(FMDatabase *)db error:(NSError **)error {
    FMResultSet *result = [db executeQuery:@"select CUSERID from BK_USER where CREGISTERSTATE = 0"];
    if (!result) {
        *error = [db lastError];
        return nil;
    }
    
    if (![result nextWithError:error]) {
        [result close];
        return nil;
    }
    
    NSString *userId = [result stringForColumnIndex:0];
    [result close];
    
    return userId;
}

+ (SSJUserItem *)queryUserItemForID:(NSString *)userID {
    return [self queryProperty:@[@"*"] forUserId:userID];
}

+ (SSJUserItem *)queryProperty:(NSArray *)propertyNames forUserId:(NSString *)userId {
    SSJUserItem *item = [[SSJUserItem alloc] init];
    
    if (!userId || !userId.length) {
        SSJPRINT(@">>> SSJ Warning:userid不能为空");
        return item;
    }
    
    //  将属性名转换成字段名
    NSDictionary *mapping = [SSJUserItem propertyMapping];
    NSMutableArray *fieldArr = [NSMutableArray arrayWithCapacity:propertyNames.count];
    NSMutableArray *filterPropertyArr = [NSMutableArray arrayWithCapacity:propertyNames.count];
    for (NSString *property in propertyNames) {
        NSString *fieldName = [mapping objectForKey:property];
        if (fieldName && fieldName.length > 0) {
            [fieldArr addObject:fieldName];
            [filterPropertyArr addObject:property];
        }
    }
    
    if (fieldArr.count == 0) {
        SSJPRINT(@">>> SSJ Warning:propertyNames中的属性名无效");
        return item;
    }
    
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *queryStr = [NSString stringWithFormat:@"select %@ from bk_user where cuserid = ?", [fieldArr componentsJoinedByString:@", "]];
        FMResultSet *resultSet = [db executeQuery:queryStr, userId];
        if (!resultSet) {
            return;
        }
        
        [resultSet next];
        
        for (int i = 0; i < fieldArr.count; i ++) {
            NSString *fieldName = [fieldArr ssj_safeObjectAtIndex:i];
            NSString *propertyName = [filterPropertyArr ssj_safeObjectAtIndex:i];
            
            NSMutableString *setter = [NSMutableString stringWithString:@"set"];
            [setter appendString:[[propertyName substringToIndex:1] uppercaseString]];
            if (propertyName.length > 1) {
                [setter appendString:[propertyName substringFromIndex:1]];
                [setter appendString:@":"];
            }
            SEL setterSel = NSSelectorFromString(setter);
            if ([item respondsToSelector:setterSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [item performSelector:setterSel withObject:[resultSet stringForColumn:fieldName]];
#pragma clang diagnostic pop
                
            }
        }
        
        [resultSet close];
    }];
    
    return item;
}

+ (BOOL)saveUserItem:(SSJUserItem *)userItem {
    NSString *userId = userItem.userId;
    if (!userId || !userId.length) {
        SSJPRINT(@"SSJ Warning:userid不能为空!!!");
        return NO;
    }
    
    __block BOOL success = YES;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *statment = nil;
        NSDictionary *userInfo = [self fieldMapWithUserItem:userItem];
        if (![db boolForQuery:@"select count(*) from BK_USER where CUSERID = ?", userId]) {
            statment = [self inertSQLStatementWithUserInfo:userInfo];
        } else {
            statment = [self updateSQLStatementWithUserInfo:userInfo];
        }
        
        success = [db executeUpdate:statment withParameterDictionary:userInfo];
    }];
    
    return success;
}

+ (NSDictionary *)fieldMapWithUserItem:(SSJUserItem *)userItem {
    [SSJUserItem mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return [SSJUserItem propertyMapping];
    }];
    return userItem.mj_keyValues;
}

+ (NSString *)inertSQLStatementWithUserInfo:(NSDictionary *)userInfo {
    NSArray *keys = [userInfo allKeys];
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:[keys count]];
    for (NSString *key in keys) {
        [values addObject:[NSString stringWithFormat:@":%@", key]];
    }
    
    return [NSString stringWithFormat:@"insert into BK_USER (%@) values (%@)", [keys componentsJoinedByString:@","], [values componentsJoinedByString:@","]];
}

+ (NSString *)updateSQLStatementWithUserInfo:(NSDictionary *)userInfo {
    NSMutableArray *keyValues = [NSMutableArray arrayWithCapacity:[userInfo count]];
    for (NSString *key in [userInfo allKeys]) {
        [keyValues addObject:[NSString stringWithFormat:@"%@ =:%@", key, key]];
    }
    
    return [NSString stringWithFormat:@"update BK_USER set %@ where cuserid = :cuserid", [keyValues componentsJoinedByString:@", "]];
}

@end
