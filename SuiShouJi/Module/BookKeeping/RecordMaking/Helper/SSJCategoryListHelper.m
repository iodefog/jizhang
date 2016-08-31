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

+ (void)queryForCategoryListWithIncomeOrExpenture:(int)incomeOrExpenture
                                          Success:(void(^)(NSMutableArray<SSJRecordMakingBillTypeSelectionCellItem *> *result))success
                                          failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        NSMutableArray *categoryList =[NSMutableArray array];
        NSString *sql = [NSString stringWithFormat:@"SELECT A.CNAME , A.CCOLOR , A.CCOIN , B.CWRITEDATE , A.ID, B.IORDER FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE B.ISTATE = 1 AND A.ITYPE = %d AND A.ID = B.CBILLID AND B.CUSERID = '%@' AND A.CPARENT is null ORDER BY B.IORDER, B.CWRITEDATE , A.ID",incomeOrExpenture,userId];
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

+ (int)queryForBillTypeMaxOrderWithState:(int)state type:(int)type {
    __block int maxOrder = 0;
    NSString *userID = SSJUSERID();
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        maxOrder = [db intForQuery:@"select max(a.iorder) from bk_user_bill as a, bk_bill_type as b where a.cbillid = b.id and a.cuserid = ? and b.itype = ? and a.istate = ?", userID, @(type), @(state)];
    }];
    return maxOrder;
}

+ (void)updateCategoryWithID:(NSString *)categoryId
                        name:(NSString *)name
                       color:(NSString *)color
                       image:(NSString *)image
                       order:(int)order
                       state:(int)state
                     Success:(void(^)(NSString *categoryId))success
                     failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        
        if (![db executeUpdate:@"update bk_bill_type set cname = ?, ccoin = ?, ccolor = ? where id = ?", name, image, color, categoryId]) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        if (![db executeUpdate:@"update bk_user_bill set istate = ?, iorder = ?, cwritedate =?, iversion = ?, operatortype = 1 where cbillid = ? and cuserid = ?", @(state), @(order), [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], @(SSJSyncVersion()), categoryId, SSJUSERID()]) {
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

+ (void)queryForUnusedCategoryListWithIncomeOrExpenture:(int)incomeOrExpenture
                                                 custom:(int)custom
                                                success:(void(^)(NSMutableArray<SSJRecordMakingCategoryItem *> *result))success
                                                failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db){
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE A.ITYPE = ? AND A.ICUSTOM = ? AND B.ISTATE = 0 AND B.CUSERID = ? AND A.ID = B.CBILLID ORDER BY B.IORDER", @(incomeOrExpenture), @(custom), SSJUSERID()];
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
            [tempArray addObject:item];
        }
        
        SSJRecordMakingCategoryItem *item = [tempArray firstObject];
        item.selected = YES;
        
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
                                          success:(void(^)(NSString *categoryId))success
                                          failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        // 检查当前用户有没有同名的收支类型
//        if ([db boolForQuery:@"select count(*) from bk_user_bill as a, bk_bill_type as b where a.cbillid = b.id and a.cuserid = ? and a.operatortype <> 2 and b.cname = ?", SSJUSERID(), name]) {
//            if (failure) {
//                SSJDispatch_main_async_safe(^{
//                    NSError *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"已有相同名称了，换一个吧。"}];
//                    failure(error);
//                });
//            }
//            return;
//        }
        
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
        
        int maxOrder = [db intForQuery:@"select max(a.iorder) from bk_user_bill as a, bk_bill_type as b where a.cuserid = ? and a.istate = 1 and a.operatortype <> 2 and a.cbillid = b.id and b.itype = ?", SSJUSERID(), @(incomeOrExpenture)];
        
        if ([db executeUpdate:@"insert into bk_user_bill (cuserid, cbillid, istate, cwritedate, iversion, operatortype, iorder) values (?, ?, 1, ?, ?, 0, ?)", SSJUSERID(), newCategoryId, [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], @(SSJSyncVersion()), @(maxOrder + 1)]) {
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
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE A.ITYPE = ? AND B.ISTATE = 1 AND B.CUSERID = ? AND A.ID = B.CBILLID AND B.IORDER = 1", @(incomeOrExpenture), SSJUSERID()];
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
                      success:(void(^)())success
                      failure:(void(^)(NSError *error))failure {
    
    NSMutableArray *tmpIDs = [NSMutableArray arrayWithCapacity:categoryIDs.count];
    for (NSString *ID in categoryIDs) {
        [tmpIDs addObject:[NSString stringWithFormat:@"'%@'", ID]];
    }
    NSString *billIDs = [tmpIDs componentsJoinedByString:@", "];
    NSString *sqlStr = [NSString stringWithFormat:@"update bk_user_bill set operatortype = 2 where cbillid in (%@) and cuserid = '%@'", billIDs, SSJUSERID()];
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:sqlStr]) {
            if (success) {
                success();
            }
            return;
        }
        
        if (failure) {
            failure([db lastError]);
        }
    }];
}

+ (void)querySameNameCategoryWithName:(NSString *)name
                              success:(void(^)(SSJBillModel *model))success
                              failure:(void(^)(NSError *))failure {
    
    NSString *userID = SSJUSERID();
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select ub.cbillid, ub.istate, ub.operatortype, bt.cname, bt.ccoin, bt.ccolor, bt.itype, bt.icustom from bk_user_bill as ub, bk_bill_type as bt where ub.cbillid = bt.id and ub.cuserid = ? and bt.cname = ?", userID, name];
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
