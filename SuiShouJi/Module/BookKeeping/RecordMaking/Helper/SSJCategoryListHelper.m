//
//  SSJCategoryListHelper.m
//  SuiShouJi
//
//  Created by ricky on 16/3/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCategoryListHelper.h"
#import "SSJDatabaseQueue.h"
#import "SSJRecordMakingBillTypeSelectionCellItem.h"
#import "SSJRecordMakingCategoryItem.h"
#import "SSJBillModel.h"

const int SSJImmovableOrder = INT_MAX;

@implementation SSJCategoryListHelper

+ (void)queryForCategoryListWithIncomeOrExpenture:(SSJBillType)billType
                                          booksId:(NSString *)booksId
                                          Success:(void(^)(NSMutableArray<SSJRecordMakingBillTypeSelectionCellItem *> *result))success
                                          failure:(void (^)(NSError *error))failure {
    
    if (billType != SSJBillTypeIncome && billType != SSJBillTypePay) {
        if (failure) {
            failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"billType参数错误"}]);
        }
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        NSString *booksID = booksId;
        if (!booksId.length) {
            booksID = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userId];
            if (!booksID.length) {
                booksID = userId;
            }
        }
        NSMutableArray *categoryList =[NSMutableArray array];
        FMResultSet *result = [db executeQuery:@"select cname, ccolor, cicoin, cwritedate, cbillid, iorder from bk_user_bill_type where itype = ? and cuserid = ? and cbooksid = ? and operatortype <> 2 order by iorder, cwritedate, cbillid", @(billType), userId, booksID];
        while ([result next]) {
            NSString *categoryTitle = [result stringForColumn:@"cname"];
            NSString *categoryImage = [result stringForColumn:@"cicoin"];
            NSString *categoryColor = [result stringForColumn:@"ccolor"];
            NSString *categoryID = [result stringForColumn:@"cbillid"];
            int order = [result intForColumn:@"iorder"];
            [categoryList addObject:[SSJRecordMakingBillTypeSelectionCellItem itemWithTitle:categoryTitle
                                                                                  imageName:categoryImage
                                                                                 colorValue:categoryColor
                                                                                         ID:categoryID
                                                                                      order:order]];
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(categoryList);
            });
        }
    }];
}

+ (int)queryForBillTypeMaxOrderWithType:(SSJBillType)type
                                 booksId:(NSString *)booksId{
    
    __block int maxOrder = 0;
    NSString *userID = SSJUSERID();
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *booksID = booksId;
        if (!booksId.length) {
            booksID = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userID];
            if (!booksID.length) {
                booksID = userID;
            }
        }
        maxOrder = [db intForQuery:@"select max(iorder) from bk_user_bill_type where cuserid = ? and itype = ? and cbooksid = ?", userID, @(type), booksID];
    }];
    return maxOrder;
}

+ (void)updateCategoryWithID:(NSString *)categoryId
                        name:(NSString *)name
                       color:(NSString *)color
                       image:(NSString *)image
                       order:(int)order
                     booksId:(NSString *)booksId
                     success:(void(^)(NSString *categoryId))success
                     failure:(void (^)(NSError *error))failure {
    
    NSString *userID = SSJUSERID();
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *booksID = booksId;
        if (!booksId.length) {
            booksID = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userID];
            if (!booksID.length) {
                booksID = userID;
            }
        }
        
        NSString *writeDateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSMutableDictionary *record = [@{@"cbillid":categoryId,
                                         @"cuserid":userID,
                                         @"cbooksid":booksId,
                                         @"cname":name,
                                         @"ccolor":color,
                                         @"cicoin":image,
                                         @"cwritedate":writeDateStr,
                                         @"operatortype":@1,
                                         @"iversion":@(SSJSyncVersion())} mutableCopy];
        
        NSMutableString *sql = [@"update bk_user_bill_type set cname = :cname, ccolor = :ccolor, cicoin = :cicoin, cwritedate = :cwritedate, iversion = :iversion, operatortype = :operatortype" mutableCopy];
        if (order != SSJImmovableOrder) {
            record[@"iorder"] = @(order);
            [sql appendString:@", iorder = :iorder"];
        }
        [sql appendString:@" where cbillid = :cbillid and cuserid = :cuserid and cbooksid = :cbooksid"];
        
        if (![db executeUpdate:sql withParameterDictionary:record]) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        if (success){
            SSJDispatch_main_async_safe(^{
                success(categoryId);
            });
        }
    }];
}

+ (void)deleteBillTypeWithId:(NSString *)billId
                      userId:(NSString *)userId
                     booksId:(NSString *)booksId
                     success:(void(^)())success
                     failure:(void(^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSString *writeDateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSDictionary *info = @{@"operatortype":@2,
                               @"cwritedate":writeDateStr,
                               @"iversion":@(SSJSyncVersion()),
                               @"cbillid":billId,
                               @"cuserid":userId,
                               @"cbooksid":booksId};
        if ([db executeUpdate:@"update bk_user_bill_type set operatortype = :operatortype, cwritedate = :cwritedate, iversion = :iversion where cbillid = :cbillid and cuserid = :cuserid and cbooksid = :cbooksid" withParameterDictionary:info]) {
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

+ (void)addNewCustomCategoryWithIncomeOrExpenture:(int)incomeOrExpenture
                                             name:(NSString *)name
                                             icon:(NSString *)icon
                                            color:(NSString *)color
                                          booksId:(NSString *)booksId
                                          success:(void(^)(NSString *categoryId))success
                                          failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        NSString *booksID = booksId;
        if (!booksId.length) {
            booksID = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userId];
            if (!booksID.length) {
                booksID = userId;
            }
        }
        
        
        int maxOrder = [db intForQuery:@"select max(iorder) from bk_user_bill_type where cuserid = ? and operatortype <> 2 and itype = ? and cbooksid = ?", userId, @(incomeOrExpenture), booksID];
        
        NSString *billId = SSJUUID();
        NSString *colorValue = [color hasPrefix:@"#"] ? color : [NSString stringWithFormat:@"#%@", color];
        NSString *dateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        NSDictionary *record = @{@"cbillid":billId,
                                 @"cuserid":userId,
                                 @"cbooksid":booksID,
                                 @"itype":@(incomeOrExpenture),
                                 @"cname":name,
                                 @"ccolor":colorValue,
                                 @"cicoin":icon,
                                 @"iorder":@(maxOrder + 1),
                                 @"cwritedate":dateStr,
                                 @"operatortype":@0,
                                 @"iversion":@(SSJSyncVersion())};
        
        if ([db executeUpdate:@"insert into bk_user_bill_type (cbillid, cuserid, cbooksid, itype, cname, ccolor, cicoin, iorder, cwritedate, operatortype, iversion) values (:cbillid, :cuserid, :cbooksid, :itype, :cname, :ccolor, :cicoin, :iorder, :cwritedate, :operatortype, :iversion)" withParameterDictionary:record]) {
            if (success) {
                SSJDispatchMainAsync(^{
                    success(billId);
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

+ (void)updateCategoryOrderWithItems:(NSArray <SSJRecordMakingBillTypeSelectionCellItem *>*)items
                             booksID:(NSString *)booksID
                             success:(void (^)())success
                             failure:(void(^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        
        SSJRecordMakingBillTypeSelectionCellItem *firstItem = [items firstObject];
        int firstOrder = firstItem.order;
        
        for (int i = 0; i < items.count; i ++) {
            SSJRecordMakingBillTypeSelectionCellItem *item = items[i];
            if (item.ID.length == 0) {
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        NSError *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"类别id为空"}];
                        SSJDispatch_main_async_safe(^{
                            failure(error);
                        });
                    });
                }
                return;
            }
            
            if (![db executeUpdate:@"update bk_user_bill_type set iorder = ?, cwritedate = ?, iversion = ?, operatortype = 1 where cbillid = ? and cuserid = ? and cbooksid = ?", @(i + firstOrder), [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], @(SSJSyncVersion()), item.ID, SSJUSERID(), booksID]) {
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    });
                }
            }
        }
    }];
}

+ (SSJRecordMakingCategoryItem *)queryfirstCategoryItemWithIncomeOrExpence:(BOOL)incomeOrExpenture {
    SSJRecordMakingCategoryItem *item = [[SSJRecordMakingCategoryItem alloc]init];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *userID = SSJUSERID();
        NSString *booksID = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?", userID];
        if (!booksID.length) {
            booksID = userID;
        }
        
        FMResultSet *rs = [db executeQuery:@"select * from bk_user_bill_type where itype = ? and cuserid = ? and cbooksid = ? and operatortype <> 2 order by iorder limit 1", @(incomeOrExpenture), userID, booksID];
        while ([rs next]) {
            item.categoryTitle = [rs stringForColumn:@"cname"];
            item.categoryImage = [rs stringForColumn:@"cicoin"];
            item.categoryColor = [rs stringForColumn:@"ccolor"];
            item.categoryID = [rs stringForColumn:@"cbillid"];
        }
        [rs close];
    }];
    return item;
}

+ (void)deleteCategoryWithIDs:(NSArray *)categoryIDs
                      booksId:(NSString *)booksId
                      success:(void(^)())success
                      failure:(void(^)(NSError *error))failure {

    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        NSString *booksID = booksId;
        if (!booksId.length) {
            booksID = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userId];
            if (!booksID.length) {
                booksID = userId;
            }
        }
        NSMutableArray *tmpIDs = [NSMutableArray arrayWithCapacity:categoryIDs.count];
        for (NSString *ID in categoryIDs) {
            [tmpIDs addObject:[NSString stringWithFormat:@"'%@'", ID]];
        }
        NSString *billIDs = [tmpIDs componentsJoinedByString:@", "];
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString *sqlStr = [NSString stringWithFormat:@"update bk_user_bill_type set operatortype = 2, iversion = %@, cwritedate = '%@' where cbillid in (%@) and cuserid = '%@' and cbooksid = '%@'", @(SSJSyncVersion()), writeDate, billIDs, userId, booksID];
        if ([db executeUpdate:sqlStr]) {
            if (success) {
                SSJDispatchMainAsync(^{
                    success();
                });
            }
            return;
        }
        
        if (failure) {
            SSJDispatchMainAsync(^{
                failure([db lastError]);
            });
        }
    }];
}

+ (void)querySameNameCategoryWithName:(NSString *)name
                      exceptForBillID:(NSString *)billID
                              booksId:(NSString *)booksId
                             expended:(BOOL)expended
                              success:(void(^)(SSJBillModel *model))success
                              failure:(void(^)(NSError *))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userID = SSJUSERID();
        NSString *booksID = booksId;
        if (!booksId.length) {
            booksID = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userID];
            if (!booksID.length) {
                booksID = userID;
            }
        }
        SSJBillModel *model = nil;
        
        // 可能有多个未删除的同名类别，根据writedate取最新的类别
        NSMutableDictionary *params = [@{@"userid":userID,
                                         @"cname":name,
                                         @"cbooksid":booksID,
                                         @"itype":@(expended)} mutableCopy];
        NSMutableString *sql = [@"select cbillid, operatortype, cname, cicoin, ccolor, itype from bk_user_bill_type where cuserid = :userid and cname = :cname and operatortype <> 2 and cbooksid = :cbooksid and itype = :itype" mutableCopy];
        if (billID) {
            params[@"cbillid"] = billID;
            [sql appendString:@" and cbillid <> :cbillid"];
        }
        [sql appendString:@" order by cwritedate desc"];
        
        FMResultSet *resultSet = [db executeQuery:sql withParameterDictionary:params];
        while ([resultSet next]) {
            model = [[SSJBillModel alloc] init];
            model.ID = [resultSet stringForColumn:@"cbillid"];
            model.name = [resultSet stringForColumn:@"cname"];
            model.icon = [resultSet stringForColumn:@"cicoin"];
            model.color = [resultSet stringForColumn:@"ccolor"];
            model.operatorType = [resultSet intForColumn:@"operatortype"];
            model.type = [resultSet intForColumn:@"itype"];
            break;
        }
        
        [resultSet close];
        
        if (model) {
            if (success) {
                SSJDispatchMainAsync(^{
                    success(model);
                });
            }
            return ;
        }
        
        // 可能有多个已经删除的同名类别，根据writedate取最新的类别
        params = [@{@"cuserid":userID,
                    @"cname":name,
                    @"cbooksid":booksID} mutableCopy];
        sql = [@"select cbillid, operatortype, cname, cicoin, ccolor, itype from bk_user_bill_type where cuserid = :cuserid and cname = :cname and operatortype == 2 and cbooksid = :cbooksid" mutableCopy];
        if (billID) {
            params[@"cbillid"] = billID;
            [sql appendString:@" and cbillid <> :cbillid"];
        }
        [sql appendString:@" order by cwritedate desc"];
        
        resultSet = [db executeQuery:sql withParameterDictionary:params];
        
        while ([resultSet next]) {
            model = [[SSJBillModel alloc] init];
            model.ID = [resultSet stringForColumn:@"cbillid"];
            model.name = [resultSet stringForColumn:@"cname"];
            model.icon = [resultSet stringForColumn:@"cicoin"];
            model.color = [resultSet stringForColumn:@"ccolor"];
            model.operatorType = [resultSet intForColumn:@"operatortype"];
            model.type = [resultSet intForColumn:@"itype"];
            break;
        }
        
        [resultSet close];
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(model);
            });
        }
    }];
}

+ (void)queryAnotherCategoryWithSameName:(NSString *)name
                     exceptForCategoryID:(NSString *)categoryID
                                 booksId:(NSString *)booksId
                                 success:(void(^)(SSJBillModel *model))success
                                 failure:(void(^)(NSError *))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userID = SSJUSERID();
        NSString *booksID = booksId;
        if (!booksId.length) {
            booksID = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userID];
            if (!booksID.length) {
                booksID = userID;
            }
        }
        // 可能有多个已经删除的同名类别，根据writedate取最新的类别
        FMResultSet *resultSet = [db executeQuery:@"select cbillid, operatortype, cname, cicoin, ccolor, itype from bk_user_bill_type where cuserid = ? and cname = ? and cbillid <> ? and operatortype <> 2 and cbooksid = ? order by cwritedate desc", userID, name, categoryID, booksID];
        if (!resultSet) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        SSJBillModel *model = nil;
        
        while ([resultSet next]) {
            model = [[SSJBillModel alloc] init];
            model.ID = [resultSet stringForColumn:@"cbillid"];
            model.name = [resultSet stringForColumn:@"cname"];
            model.icon = [resultSet stringForColumn:@"cicoin"];
            model.color = [resultSet stringForColumn:@"ccolor"];
            model.operatorType = [resultSet intForColumn:@"operatortype"];
            model.type = [resultSet intForColumn:@"itype"];
            break;
        }
        
        [resultSet close];
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(model);
            });
        }
    }];
}

+ (NSArray *)billTypeLibraryColors {
    return @[@"#FC72AE",
             @"#F96A6A",
             @"#8094F9",
             @"#C260E3",
             @"#81B9F0",
             @"#39D4DA",
             @"#56D696",
             @"#F8B556",
             @"#FC835A",
             @"#C6B244",
             @"#8D79FF",
             @"#DE96F5",
             @"#51A4FF",
             @"#8F96CD",
             @"#6A86D2",
             @"#D89388",
             @"#CBA9D6",
             @"#8BCBB7",
             @"#8DBB88",
             @"#8DC4DC",
             @"#4A80B5",
             @"#A48864",
             @"#4F8B6D",
             @"#DF6464",
             @"#009AD8"];
}

@end
