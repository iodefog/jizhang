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
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        [self reloadUserIdInDatabase:db error:error];
    }];
}

+ (void)reloadUserIdWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure {
    __block NSError *tError = nil;
    
    if (SSJUSERID().length) {
        tError = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"当前的userid无效"}];
        SSJPRINT(@">>> SSJ warning:current userid is invalid");
        if (failure) {
            failure(tError);
        }
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSError *error = nil;
        [self reloadUserIdInDatabase:db error:&error];
        if (error) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure(error);
                });
            }
        } else {
            if (success) {
                SSJDispatchMainAsync(^{
                    success();
                });
            }
        }
    }];
}

+ (void)reloadUserIdInDatabase:(FMDatabase *)db error:(NSError **)error {
    NSString *userId = [self unregisteredUserIdInDatabase:db error:error];
    if (*error) {
        return;
    }
    
    if (userId.length) {
        SSJSetUserId(userId);
        return;
    }
    
    userId = SSJUUID();
    if (![db executeUpdate:@"insert into BK_USER (CUSERID, CREGISTERSTATE, CCURRENTBOOKSID, CWRITEDATE, CFINGERPRINTSTATE) values (?, 0, ?, ?, 0)", userId, userId, [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"]]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    SSJSetUserId(userId);
}

+ (NSString *)unregisteredUserIdInDatabase:(FMDatabase *)db error:(NSError **)error {
    FMResultSet *result = [db executeQuery:@"select CUSERID from BK_USER where CREGISTERSTATE = 0"];
    if (!result) {
        if (error) {
            *error = [db lastError];
        }
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

+ (void)queryUserItemWithID:(NSString *)userID success:(void(^)(SSJUserItem *userItem))success failure:(void(^)(NSError *error))failure {
    NSArray *properties = [[SSJUserItem propertyMapping] allKeys];
    [self queryProperty:properties forUserId:userID success:success failure:failure];
}

+ (void)queryProperty:(NSArray *)propertyNames forUserId:(NSString *)userId success:(void(^)(SSJUserItem *userModel))success failure:(void(^)(NSError *error))failure {
    
    if (!userId || !userId.length) {
        NSError *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"userid不能为空"}];
        if (failure) {
            failure(error);
        }
        return;
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
        NSError *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"propertyNames中的属性名无效"}];
        if (failure) {
            failure(error);
        }
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *queryStr = [NSString stringWithFormat:@"select %@ from bk_user where cuserid = ?", [fieldArr componentsJoinedByString:@", "]];
        FMResultSet *resultSet = [db executeQuery:queryStr, userId];
        if (!resultSet) {
            return;
        }
        [resultSet next];
        
        SSJUserItem *item = [[SSJUserItem alloc] init];
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
        item.userId = userId;
        [resultSet close];
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(item);
            });
        }
    }];
}

+ (void)saveUserItem:(SSJUserItem *)userItem success:(void(^)())success failure:(void(^)(NSError *error))failure {
    NSString *userId = userItem.userId;
    if (!userId || !userId.length) {
        SSJPRINT(@"SSJ Warning:userid不能为空!!!");
        if (failure) {
            failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"userid不能为空"}]);
        }
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *statment = nil;
        NSMutableDictionary *userInfo = [[self fieldMapWithUserItem:userItem] mutableCopy];
        if (![db boolForQuery:@"select count(*) from BK_USER where CUSERID = ?", userId]) {
            if (![[userInfo allKeys] containsObject:@"cwritedate"]) {
                [userInfo setObject:[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] forKey:@"cwritedate"];
            }
            
            // 因为user表的指纹字段默认是1，但是现在要求默认是0，所以只能在这里处理
            if (![[userInfo allKeys] containsObject:@"cfingerPrintState"]) {
                userInfo[@"cfingerPrintState"] = @"0";
            }
            statment = [self inertSQLStatementWithUserInfo:userInfo];
        } else {
            statment = [self updateSQLStatementWithUserInfo:userInfo];
        }
        
        if ([db executeUpdate:statment withParameterDictionary:userInfo]) {
            if (success) {
                SSJDispatchMainAsync(^{
                    success();
                });
            }
        } else {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
        }
    }];
}

+ (void)currentBooksId:(void(^)(NSString *booksId))success failure:(void(^)(NSError *error))failure {
    [SSJUserTableManager queryProperty:@[@"currentBooksId"] forUserId:SSJUSERID() success:^(SSJUserItem * _Nonnull userModel) {
        NSString *booksId = userModel.currentBooksId.length ? userModel.currentBooksId : userModel.userId;
        if (success) {
            success(booksId);
        }
    } failure:failure];
}

+ (void)updateCurrentBooksId:(NSString *)booksId success:(void(^)())success failure:(void(^)(NSError *error))failure {
    SSJUserItem *item = [[SSJUserItem alloc] init];
    item.userId = SSJUSERID();
    item.currentBooksId = booksId;
    [SSJUserTableManager saveUserItem:item success:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SSJBooksTypeDidChangeNotification object:nil];
        if (success) {
            success();
        }
    } failure:failure];
}

+ (NSDictionary *)fieldMapWithUserItem:(SSJUserItem *)userItem {
    [SSJUserItem mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return [SSJUserItem propertyMapping];
    }];
    return userItem.mj_keyValues;
}

+ (NSString *)inertSQLStatementWithUserInfo:(NSDictionary *)userInfo {
    NSMutableArray *keys = [[userInfo allKeys] mutableCopy];
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
