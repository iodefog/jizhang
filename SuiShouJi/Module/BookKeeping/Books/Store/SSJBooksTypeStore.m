//
//  SSJBooksTypeStore.m
//  SuiShouJi
//
//  Created by ricky on 16/5/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBooksTypeStore.h"
#import "SSJDatabaseQueue.h"
#import "SSJDailySumChargeTable.h"
#import "SSJReportFormsCurveModel.h"

@implementation SSJBooksTypeStore
+ (void)queryForBooksListWithSuccess:(void(^)(NSMutableArray<SSJBooksTypeItem *> *result))success
                                  failure:(void (^)(NSError *error))failure{
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSMutableArray *booksList = [NSMutableArray array];
        FMResultSet *booksResult = [db executeQuery:@"select * from bk_books_type where cuserid = ? and operatortype <> 2 order by iorder asc , cwritedate asc",userid];
        int order = 1;
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
            item.userId = [booksResult stringForColumn:@"cuserid"];
            item.booksIcoin = [booksResult stringForColumn:@"cicoin"];
            item.booksOrder = [booksResult intForColumn:@"iorder"];
            item.booksParent = [booksResult intForColumn:@"iparenttype"];
            if (item.booksOrder == 0) {
                item.booksOrder = order;
            }
            item.selectToEdite = NO;
            [booksList addObject:item];
            order ++;
        }
        SSJBooksTypeItem *item = [[SSJBooksTypeItem alloc]init];
        item.booksName = @"添加账本";
        item.booksColor = @"#CCCCCC";
        item.booksIcoin = @"book_tianjia";
        item.selectToEdite = NO;
        [booksList addObject:item];
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(booksList);
            });
        }
    }];
}

+ (BOOL)saveBooksTypeItem:(SSJBooksTypeItem *)item {
    NSString * booksid = item.booksId;
    if (!booksid.length) {
        item.booksId = SSJUUID();
    }
    if (!item.userId.length) {
        item.userId = SSJUSERID();
    }
    item.cwriteDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSMutableDictionary * typeInfo = [NSMutableDictionary dictionaryWithDictionary:[self fieldMapWithTypeItem:item]];
    [typeInfo removeObjectForKey:@"selectToEdite"];
    [typeInfo removeObjectForKey:@"editeModel"];
    if (![[typeInfo allKeys] containsObject:@"iversion"]) {
        [typeInfo setObject:@(SSJSyncVersion()) forKey:@"iversion"];
    }
    __block BOOL success = YES;
    __block NSString * sql;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        if ([db intForQuery:@"select count(1) from BK_BOOKS_TYPE where cbooksname = ? and cuserid = ? and cbooksid <> ? and operatortype <> 2",item.booksName,userid,item.booksId]) {
            success = NO;
            SSJDispatch_main_async_safe(^{
                [CDAutoHideMessageHUD showMessage:@"已有相同账本名称了，换一个吧"];
            });
        }else{
            int booksOrder = [db intForQuery:@"select max(iorder) from bk_books_type where cuserid = ?",userid] + 1;
            if ([item.booksId isEqualToString:userid]) {
                booksOrder = 1;
            }
            if (![db boolForQuery:@"select count(*) from BK_BOOKS_TYPE where CBOOKSID = ?", booksid]) {
                [typeInfo setObject:@(booksOrder) forKey:@"iorder"];
                [typeInfo setObject:@(0) forKey:@"operatortype"];
                sql = [self inertSQLStatementWithTypeInfo:typeInfo];
            } else {
                [typeInfo setObject:@(1) forKey:@"operatortype"];
                sql = [self updateSQLStatementWithTypeInfo:typeInfo];
            }
            success = [db executeUpdate:sql withParameterDictionary:typeInfo];
        }
    }];
    
    return success;
}

+ (void)saveBooksOrderWithItems:(NSArray *)items
                         sucess:(void(^)())success
                             failure:(void (^)(NSError *error))failure{
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        for (SSJBooksTypeItem *item in items) {
            NSInteger order = [items indexOfObject:item] + 1;
            NSString *userid = SSJUSERID();
            NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            if (![db executeUpdate:@"update bk_books_type set iorder = ?, iversion = ?, cwritedate = ? ,operatortype = 1 where cbooksid = ? and cuserid = ?",@(order),@(SSJSyncVersion()),writeDate,item.booksId,userid]) {
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
    }];
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

+(SSJBooksTypeItem *)queryCurrentBooksTypeForBooksId:(NSString *)booksid{
    __block SSJBooksTypeItem *item = [[SSJBooksTypeItem alloc]init];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select * from bk_books_type where cbooksid = ?",booksid];
        while ([resultSet next]) {
            item.booksId = [resultSet stringForColumn:@"cbooksid"];
            item.booksName = [resultSet stringForColumn:@"cbooksname"];
            item.booksColor = [resultSet stringForColumn:@"cbookscolor"];
            item.booksIcoin = [resultSet stringForColumn:@"cicoin"];
        }
    }];
    return item;
}

+ (void)deleteBooksTypeWithbooksItems:(NSArray *)items
                           deleteType:(BOOL)type
                           Success:(void(^)())success
                           failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *userId = SSJUSERID();
        if (!type) {
            for (SSJBooksTypeItem *item in items) {
                if (![db executeUpdate:@"update bk_books_type set operatortype = 2 ,cwritedate = ? ,iversion = ? where cbooksid = ?",[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),item.booksId]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                }
            }
        }else{
            for (SSJBooksTypeItem *item in items) {
                if (![db executeUpdate:@"update bk_books_type set operatortype = 2 ,cwritedate = ? ,iversion = ? where cbooksid = ?",[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),item.booksId]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                }
                if (![db executeUpdate:@"update bk_user_charge set operatortype = 2 ,cwritedate = ? ,iversion = ? where cbooksid = ?",[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),item.booksId]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                }
                //更新日常统计表
                if (![SSJDailySumChargeTable updateDailySumChargeForUserId:userId inDatabase:db]) {
                    if (failure) {
                        *rollback = YES;
                        SSJDispatchMainAsync(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                }
                
            }
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
    }];
}

+ (void)generateBooksTypeForBooksItem:(SSJBooksTypeItem *)item
                                Success:(void(^)())success
                                failure:(void (^)(NSError *error))failure{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm;ss.sss"];
        if (![db executeUpdate:@"insert into bk_user_bill select ?, id, istate, ?, ?, defualtorder,? from bk_bill_type where ibookstype = ? and icustom = 0",userId,@(SSJSyncVersion()),writeDate,item.booksId,item.booksParent]) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        if (success) {
            SSJDispatchMainAsync(^{
                success();
            });
        }
    }];
}
@end
