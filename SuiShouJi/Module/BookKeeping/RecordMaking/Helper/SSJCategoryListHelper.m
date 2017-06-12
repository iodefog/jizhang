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
        NSString *sql = [NSString stringWithFormat:@"SELECT A.CNAME , A.CCOLOR , A.CCOIN , B.CWRITEDATE , A.ID, B.IORDER FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE B.ISTATE = 1 AND A.ITYPE = %d AND A.ID = B.CBILLID AND B.CUSERID = '%@' AND (A.CPARENT <> 'root' or A.CPARENT is null) AND B.CBOOKSID = '%@' ORDER BY B.IORDER, B.CWRITEDATE , A.ID", (int)billType,userId,booksID];
            FMResultSet *result = [db executeQuery:sql];
            while ([result next]) {
                NSString *categoryTitle = [result stringForColumn:@"CNAME"];
                NSString *categoryImage = [result stringForColumn:@"CCOIN"];
                NSString *categoryColor = [result stringForColumn:@"CCOLOR"];
                NSString *categoryID = [result stringForColumn:@"ID"];
                int order = [result intForColumn:@"IORDER"];
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

+ (int)queryForBillTypeMaxOrderWithState:(int)state
                                    type:(SSJBillType)type
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
        maxOrder = [db intForQuery:@"select max(a.iorder) from bk_user_bill as a, bk_bill_type as b where a.cbillid = b.id and a.cuserid = ? and b.itype = ? and a.istate = ? and a.cbooksid = ?", userID, @(type), @(state),booksID];
    }];
    return maxOrder;
}

+ (void)updateCategoryWithID:(NSString *)categoryId
                        name:(NSString *)name
                       color:(NSString *)color
                       image:(NSString *)image
                       order:(int)order
                       state:(int)state
                     booksId:(NSString *)booksId
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
        if (![db executeUpdate:@"update bk_bill_type set cname = ?, ccoin = ?, ccolor = ? where id = ?", name, image, color, categoryId]) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                })
            }
            return;
        }
        
        if (![db intForQuery:@"select count(1) from bk_user_bill where cbillid = ? and cuserid = ? and cbooksid = ?",categoryId,userID,booksID]) {
            if (![db executeUpdate:@"insert into bk_user_bill values (?, ?, ?, ?, ?, 1, ?, ?)",userID, categoryId, @(state), [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], @(SSJSyncVersion()), @(order),booksID]) {
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
        }else{
            if (![db executeUpdate:@"update bk_user_bill set istate = ?, iorder = ?, cwritedate =?, iversion = ?, operatortype = 1 where cbillid = ? and cuserid = ? and cbooksid = ?", @(state), @(order), [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], @(SSJSyncVersion()), categoryId, userID, booksID]) {
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

+ (void)queryForUnusedCategoryListWithIncomeOrExpenture:(int)incomeOrExpenture
                                                 custom:(int)custom
                                                booksId:(NSString *)booksId
                                                success:(void(^)(NSMutableArray<SSJRecordMakingCategoryItem *> *result))success
                                                failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db){
        NSString *userId = SSJUSERID();
        NSString *booksID = booksId;
        if (!booksId.length) {
            booksID = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userId];
            if (!booksID.length) {
                booksID = userId;
            }
        }
        int parentType = 0;
        
        if ([db intForQuery:@"select count(1) from bk_books_type where cbooksid = ?",booksID]) {
            parentType = [db intForQuery:@"select iparenttype from bk_books_type where cbooksid = ?",booksID];
        } else {
            parentType = [db intForQuery:@"select iparenttype from bk_share_books where cbooksid = ?",booksID];
        }
        NSString *sql;
        if (parentType == 0) {
            sql = [NSString stringWithFormat:@"SELECT * FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE A.ITYPE = '%d' AND A.ICUSTOM = '%d' AND B.ISTATE = 0 AND B.CUSERID = '%@' AND A.ID = B.CBILLID AND B.OPERATORTYPE <> 2 AND B.CBOOKSID = '%@' ORDER BY B.IORDER",incomeOrExpenture, custom, userId,booksID];
        }else{
            if (custom == 0) {
                sql = [NSString stringWithFormat:@"SELECT DISTINCT * FROM (SELECT * FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE A.ITYPE = %d AND A.ICUSTOM = 0 AND B.CUSERID = '%@' AND A.ID = B.CBILLID AND B.OPERATORTYPE <> 2 AND B.CBOOKSID = '%@' AND A.ID NOT IN (SELECT CBILLID FROM BK_USER_BILL WHERE CUSERID = '%@' AND CBOOKSID = '%@') UNION SELECT * FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE A.ITYPE = %d AND A.ICUSTOM = 0  AND B.ISTATE = 0 AND B.CUSERID = '%@' AND A.ID = B.CBILLID AND B.OPERATORTYPE <> 2 AND B.CBOOKSID = '%@' ORDER BY B.IORDER)",incomeOrExpenture,userId,userId,userId,booksID,incomeOrExpenture,userId,booksID];
            }else{
                sql = [NSString stringWithFormat:@"SELECT * FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE A.ITYPE = %d AND A.ICUSTOM = 1 AND B.ISTATE = 0 AND B.CUSERID = '%@' AND A.ID = B.CBILLID AND B.OPERATORTYPE <> 2 AND B.CBOOKSID = '%@' ORDER BY B.IORDER",incomeOrExpenture, userId,booksID];
            }
        }
        FMResultSet *rs = [db executeQuery:sql];
        if (!rs) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        while ([rs next]) {
            SSJRecordMakingCategoryItem *item = [[SSJRecordMakingCategoryItem alloc] init];
            item.categoryTitle = [rs stringForColumn:@"CNAME"];
            item.categoryImage = [rs stringForColumn:@"CCOIN"];
            item.categoryColor = [rs stringForColumn:@"CCOLOR"];
            item.categoryID = [rs stringForColumn:@"ID"];
            item.order = [rs intForColumn:@"IORDER"];
            [tempArray addObject:item];
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(tempArray);
            });
        }
    }];
}

+ (void)queryCustomCategoryImagesWithIncomeOrExpenture:(int)incomeOrExpenture
                                               success:(void(^)(NSArray<NSString *> *images))success
                                               failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"select ccoin from bk_bill_type where itype = ? and cparent = 'root'", @(incomeOrExpenture)];
        if (!result) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        while ([result next]) {
            NSString *image = [result stringForColumn:@"ccoin"];
            [tempArray addObject:(image ?: @"")];
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(tempArray);
            });
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
        NSString *newCategoryId = SSJUUID();
        NSString *colorValue = [color hasPrefix:@"#"] ? color : [NSString stringWithFormat:@"#%@", color];
        if (![db executeUpdate:@"insert into bk_bill_type (id, cname, itype, ccoin, ccolor, icustom, istate) values (?, ?, ?, ?, ?, 1, 1)", newCategoryId, name, @(incomeOrExpenture), icon, colorValue]) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        int maxOrder = [db intForQuery:@"select max(a.iorder) from bk_user_bill as a, bk_bill_type as b where a.cuserid = ? and a.istate = 1 and a.operatortype <> 2 and a.cbillid = b.id and b.itype = ? and a.cbooksid = ?", userId, @(incomeOrExpenture),booksID];
        
        if ([db executeUpdate:@"insert into bk_user_bill (cuserid, cbillid, istate, cwritedate, iversion, operatortype, iorder, cbooksid) values (?, ?, 1, ?, ?, 0, ?, ?)", userId, newCategoryId, [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], @(SSJSyncVersion()), @(maxOrder + 1),booksID]) {
            if (success) {
                SSJDispatch_main_async_safe(^{
                    success(newCategoryId);
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
            
            if (![db executeUpdate:@"update bk_user_bill set iorder = ?, cwritedate = ?, iversion = ?, operatortype = 1 where cbillid = ?", @(i + firstOrder), [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], @(SSJSyncVersion()), item.ID]) {
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
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE A.ITYPE = ? AND B.ISTATE = 1 AND B.CUSERID = ? AND A.ID = B.CBILLID ORDER BY B.IORDER LIMIT 1", @(incomeOrExpenture), SSJUSERID()];
        while ([rs next]) {
            item.categoryTitle = [rs stringForColumn:@"CNAME"];
            item.categoryImage = [rs stringForColumn:@"CCOIN"];
            item.categoryColor = [rs stringForColumn:@"CCOLOR"];
            item.categoryID = [rs stringForColumn:@"ID"];
        }
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
        NSString *sqlStr = [NSString stringWithFormat:@"update bk_user_bill set operatortype = 2, iversion = %@, cwritedate = '%@' where cbillid in (%@) and cuserid = '%@' and cbooksid = '%@'", @(SSJSyncVersion()), writeDate, billIDs, userId, booksID];
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
        FMResultSet *resultSet = [db executeQuery:@"select ub.cbillid, ub.istate, ub.operatortype, bt.cname, bt.ccoin, bt.ccolor, bt.itype, bt.icustom from bk_user_bill as ub, bk_bill_type as bt where ub.cbillid = bt.id and ub.cuserid = ? and bt.cname = ? and ub.operatortype <> 2 and ub.cbooksid = ? and bt.itype = ? order by ub.cwritedate desc", userID, name, booksID, @(incomeOrExpence)];
        
        while ([resultSet next]) {
            model = [[SSJBillModel alloc] init];
            model.ID = [resultSet stringForColumn:@"cbillid"];
            model.name = [resultSet stringForColumn:@"cname"];
            model.icon = [resultSet stringForColumn:@"ccoin"];
            model.color = [resultSet stringForColumn:@"ccolor"];
            model.state = [resultSet intForColumn:@"istate"];
            model.operatorType = [resultSet intForColumn:@"operatortype"];
            model.type = [resultSet intForColumn:@"itype"];
            model.custom = [resultSet intForColumn:@"icustom"];
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
        resultSet = [db executeQuery:@"select ub.cbillid, ub.istate, ub.operatortype, bt.cname, bt.ccoin, bt.ccolor, bt.itype, bt.icustom from bk_user_bill as ub, bk_bill_type as bt where ub.cbillid = bt.id and ub.cuserid = ? and bt.cname = ? and ub.operatortype == 2 and ub.cbooksid = ? order by ub.cwritedate desc", userID, name, booksID];
        
        while ([resultSet next]) {
            model = [[SSJBillModel alloc] init];
            model.ID = [resultSet stringForColumn:@"cbillid"];
            model.name = [resultSet stringForColumn:@"cname"];
            model.icon = [resultSet stringForColumn:@"ccoin"];
            model.color = [resultSet stringForColumn:@"ccolor"];
            model.state = [resultSet intForColumn:@"istate"];
            model.operatorType = [resultSet intForColumn:@"operatortype"];
            model.type = [resultSet intForColumn:@"itype"];
            model.custom = [resultSet intForColumn:@"icustom"];
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
        FMResultSet *resultSet = [db executeQuery:@"select ub.cbillid, ub.istate, ub.operatortype, bt.cname, bt.ccoin, bt.ccolor, bt.itype, bt.icustom from bk_user_bill as ub, bk_bill_type as bt where ub.cbillid = bt.id and ub.cuserid = ? and bt.cname = ? and ub.cbillid <> ? and ub.operatortype <> 2 and ub.cbooksid = ? order by ub.cwritedate desc", userID, name, categoryID, booksID];
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
            model.icon = [resultSet stringForColumn:@"ccoin"];
            model.color = [resultSet stringForColumn:@"ccolor"];
            model.state = [resultSet intForColumn:@"istate"];
            model.operatorType = [resultSet intForColumn:@"operatortype"];
            model.type = [resultSet intForColumn:@"itype"];
            model.custom = [resultSet intForColumn:@"icustom"];
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
