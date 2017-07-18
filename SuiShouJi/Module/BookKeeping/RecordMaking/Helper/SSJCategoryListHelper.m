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
        FMResultSet *result = [db executeQuery:@"select cname, ccolor, cicoin, cwritedate, cbillid, iorder from bk_user_bill_type where itype = ? and cuserid = ? and cbooksid = ? order by iorder, cwritedate, cbillid", @(billType), userId, booksID];
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
                    billType:(SSJBillType)billType
                     Success:(void(^)(NSString *categoryId))success
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
        if (![db intForQuery:@"select count(1) from bk_user_bill_type where cbillid = ? and cuserid = ? and cbooksid = ?", categoryId, userID, booksID]) {
            NSDictionary *record = @{@"cbillid":categoryId,
                                     @"cuserid":userID,
                                     @"cbooksid":booksId,
                                     @"itype":@(billType),
                                     @"cname":name,
                                     @"ccolor":color,
                                     @"cicoin":image,
                                     @"iorder":@(order),
                                     @"cwritedate":writeDateStr,
                                     @"operatortype":@0,
                                     @"iversion":@(SSJSyncVersion())};
            
            if (![db executeUpdate:@"insert into bk_user_bill_type (cbillid, cuserid, cbooksid, itype, cname, ccolor, cicoin, iorder, cwritedate, operatortype, iversion) values (:cbillid, :cuserid, :cbooksid, :itype, :cname, :ccolor, :cicoin, :iorder, :cwritedate, :operatortype, :iversion)" withParameterDictionary:record]) {
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
        } else {
            NSDictionary *record = @{@"cbillid":categoryId,
                                     @"cuserid":userID,
                                     @"cbooksid":booksId,
                                     @"cname":name,
                                     @"ccolor":color,
                                     @"cicoin":image,
                                     @"iorder":@(order),
                                     @"cwritedate":writeDateStr,
                                     @"operatortype":@0,
                                     @"iversion":@(SSJSyncVersion())};
            
            if (![db executeUpdate:@"update bk_user_bill_type set cname = :cname, ccolor = :ccolor, cicoin = :cicoin, iorder = :iorder, cwritedate = :cwritedate, iversion = :iversion, operatortype = :operatortype where cbillid = :cbillid and cuserid = :cuserid and cbooksid = :cbooksid" withParameterDictionary:record]) {
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
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
            
            if (![db executeUpdate:@"update bk_user_bill_type set iorder = ?, cwritedate = ?, iversion = ?, operatortype = 1 where cbillid = ?", @(i + firstOrder), [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], @(SSJSyncVersion()), item.ID]) {
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

+ (SSJRecordMakingCategoryItem *)queryfirstCategoryItemWithIncomeOrExpence:(BOOL)incomeOrExpenture{
    SSJRecordMakingCategoryItem *item = [[SSJRecordMakingCategoryItem alloc]init];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select * from bk_user_bill_type where itype = ? and cuserid = ? and operatortype <> 2 order by iorder limit 1"];
        while ([rs next]) {
            item.categoryTitle = [rs stringForColumn:@"CNAME"];
            item.categoryImage = [rs stringForColumn:@"CCOIN"];
            item.categoryColor = [rs stringForColumn:@"CCOLOR"];
            item.categoryID = [rs stringForColumn:@"ID"];
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
                              booksId:(NSString *)booksId
                      incomeOrExpence:(BOOL)incomeOrExpence
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
        FMResultSet *resultSet = [db executeQuery:@"select cbillid, operatortype, cname, cicoin, ccolor, itype from bk_user_bill_type where cuserid = ? and cname = ? and operatortype <> 2 and cbooksid = ? and itype = ? order by cwritedate desc", userID, name, booksID, @(incomeOrExpence)];
        
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
        resultSet = [db executeQuery:@"select cbillid, operatortype, cname, cicoin, ccolor, itype from bk_user_bill_type where cuserid = ? and cname = ? and operatortype == 2 and cbooksid = ? order by cwritedate desc", userID, name, booksID];
        
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

+ (NSArray *)payOutColors {
    return @[@"#c55553", @"#c6632f", @"#a90868", @"#d29361", @"#a8a67e", @"#006f5f", @"#ac3b2b", @"#6293b0", @"#ab94c6", @"#d96421", @"#a74257", @"#c1af65", @"#af5e53", @"#c77a3a", @"#008e59", @"#a1558b", @"#0d7473", @"#569597", @"#1ec3e9", @"#8ecbae", @"#f12b5f", @"#61348a", @"#746b07", @"#8a5736"];
}

+ (NSArray *)incomeColors {
    return @[@"#f4a755", @"#50b7c0", @"#018792", @"#c55553", @"#7d5786", @"#eb66a7", @"#ac3b2b", @"#6293b0", @"#ab94c6", @"#d96421", @"#b3d236", @"#c1af65", @"#af5e53", @"#c77a3a", @"#008e59", @"#a1558b", @"#0d7473", @"#569597", @"#1ec3e9", @"#8ecbae", @"#f12b5f", @"#61348a", @"#746b07", @"#8a5736"];
}

@end
