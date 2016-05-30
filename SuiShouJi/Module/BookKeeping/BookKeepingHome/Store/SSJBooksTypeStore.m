//
//  SSJBooksTypeStore.m
//  SuiShouJi
//
//  Created by ricky on 16/5/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBooksTypeStore.h"
#import "SSJDatabaseQueue.h"

@implementation SSJBooksTypeStore
+ (void)queryForBooksListWithSuccess:(void(^)(NSMutableArray<SSJBooksTypeItem *> *result))success
                                  failure:(void (^)(NSError *error))failure{
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSMutableArray *booksList = [NSMutableArray array];
        FMResultSet *booksResult = [db executeQuery:@"select * from bk_books_type where cbooksid = 0 or cuserid = ? and operatortype <> 2",userid];
        if (!booksResult) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        while ([booksResult next]) {
            SSJBooksTypeItem *item = [[SSJBooksTypeItem alloc]init];
            item.booksId = [booksResult stringForColumn:@"cbooksid"];
            item.booksName = [booksResult stringForColumn:@"cbooksname"];
            item.booksColor = [booksResult stringForColumn:@"cbookscolor"];
            [booksList addObject:item];
        }
        SSJBooksTypeItem *item = [[SSJBooksTypeItem alloc]init];
        item.booksName = @"添加账本";
        item.booksColor = @"#CCCCCC";
        [booksList addObject:item];
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(booksList);
            });
        }
    }];
}

+ (BOOL)saveBooksTypeItem:(SSJBooksTypeItem *)item {
    NSString * typeId = item.booksId;
    if (!typeId || !typeId.length) {
        item.booksId = SSJUUID();
    }
    NSMutableDictionary * typeInfo = [NSMutableDictionary dictionaryWithDictionary:[self fieldMapWithTypeItem:item]];
    if ([[typeInfo allKeys] containsObject:@"iversion"]) {
        [typeInfo setObject:@(SSJSyncVersion()) forKey:@"iversion"];
    }
    __block BOOL success = YES;
    __block NSString * sql;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
    if (![db boolForQuery:@"select count(*) from BK_BOOKS_TYPE where CBOOKSID = ?", typeId]) {
        sql = [self inertSQLStatementWithTypeInfo:typeInfo];
    } else {
        sql = [self updateSQLStatementWithTypeInfo:typeInfo];
    }
        success = [db executeUpdate:sql withParameterDictionary:typeInfo];
    }];
    
    return success;
}

+ (NSDictionary *)fieldMapWithTypeItem:(SSJBooksTypeItem *)item {
    [SSJBooksTypeItem mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return [SSJBooksTypeItem propertyMapping];
    }];
    return item.mj_keyValues;
}


+ (NSString *)inertSQLStatementWithTypeInfo:(NSDictionary *)typeInfo {
    NSMutableArray *keys = [[typeInfo allKeys] mutableCopy];
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:[keys count]];
    for (NSString *key in keys) {
        [values addObject:[NSString stringWithFormat:@":%@", key]];
    }
    
    return [NSString stringWithFormat:@"insert into BK_BOOKS_TYPE (%@) values (%@)", [keys componentsJoinedByString:@","], [values componentsJoinedByString:@","]];
}

+ (NSString *)updateSQLStatementWithTypeInfo:(NSDictionary *)typeInfo {
    NSMutableArray *keyValues = [NSMutableArray arrayWithCapacity:[typeInfo count]];
    for (NSString *key in [typeInfo allKeys]) {
        [keyValues addObject:[NSString stringWithFormat:@"%@ =:%@", key, key]];
    }
    
    return [NSString stringWithFormat:@"update BK_BOOKS_TYPE set %@ where cbooksid = :cbooksid", [keyValues componentsJoinedByString:@", "]];
}

@end