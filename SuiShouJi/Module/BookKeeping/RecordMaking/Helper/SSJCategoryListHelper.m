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

@implementation SSJCategoryListHelper

+ (void)queryForCategoryListWithIncomeOrExpenture:(int)incomeOrExpenture
                                          Success:(void(^)(NSMutableArray<SSJRecordMakingBillTypeSelectionCellItem *> *result))success
                                          failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        NSMutableArray *categoryList =[NSMutableArray array];
        NSString *sql = [NSString stringWithFormat:@"SELECT A.CNAME , A.CCOLOR , A.CCOIN , B.CWRITEDATE , A.ID FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE B.ISTATE = 1 AND A.ITYPE = %d AND A.ID = B.CBILLID AND B.CUSERID = '%@' AND A.CPARENT is null ORDER BY B.IORDER, B.CWRITEDATE , A.ID",incomeOrExpenture,userId];
            FMResultSet *result = [db executeQuery:sql];
            while ([result next]) {
                NSString *categoryTitle = [result stringForColumn:@"CNAME"];
                NSString *categoryImage = [result stringForColumn:@"CCOIN"];
                NSString *categoryColor = [result stringForColumn:@"CCOLOR"];
                NSString *categoryID = [result stringForColumn:@"ID"];
                [categoryList addObject:[SSJRecordMakingBillTypeSelectionCellItem itemWithTitle:categoryTitle
                                                                                      imageName:categoryImage
                                                                                     colorValue:categoryColor
                                                                                             ID:categoryID]];
            }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(categoryList);
            });
        }
    }];
}

+ (void)deleteCategoryWithCategoryId:(NSString *)categoryId
                             Success:(void(^)(BOOL result))success
                             failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        BOOL deletesucess = [db executeUpdate:@"update bk_user_bill set istate = 0, cwritedate =?, iversion = ?, operatortype = 1 where cbillid = ? and cuserid = ?", [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], @(SSJSyncVersion()), categoryId, SSJUSERID()];
        if (deletesucess) {
            if (success){
                SSJDispatch_main_async_safe(^{
                    success(deletesucess);
                });
            }
        } else {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
        }
        
    }];
}

+ (void)queryForUnusedCategoryListWithIncomeOrExpenture:(int)incomeOrExpenture
                                                success:(void(^)(NSMutableArray<SSJRecordMakingCategoryItem *> *result))success
                                                failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db){
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE A.ITYPE = ? AND B.ISTATE = 0 AND B.CUSERID = ? AND A.ID = B.CBILLID", @(incomeOrExpenture), SSJUSERID()];
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
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(tempArray);
            });
        }
    }];
}

+ (void)queryCustomCategoryListWithIncomeOrExpenture:(int)incomeOrExpenture
                                             success:(void(^)(NSArray<SSJRecordMakingCategoryItem *> *items))success
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
            SSJRecordMakingCategoryItem *item = [[SSJRecordMakingCategoryItem alloc]init];
            item.categoryImage = [result stringForColumn:@"ccoin"];
            item.categoryTintColor = @"969696";
            [tempArray addObject:item];
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(tempArray);
            });
        }
    }];
}

+ (void)addNewCategoryWithidentifier:(NSString *)identifier
                   incomeOrExpenture:(int)incomeOrExpenture
                             success:(void(^)())success
                             failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db){
        int order = 0;
        if ([identifier isEqualToString:@"1042"]
            || [identifier isEqualToString:@"2018"]) {
            order = 1;
        } else {
            // 查询已添加类别最大序号
            order = [db intForQuery:@"select max(iorder) from bk_user_bill as a, bk_bill_type as b where a.cuserid = ? and a.istate = 1 and a.operatortype <> 2 and a.cbillid = b.id and b.itype = ?", SSJUSERID(), @(incomeOrExpenture)];
            order ++;
        }
        
        if ([db executeUpdate:@"UPDATE BK_USER_BILL SET ISTATE = 1, IORDER = ?, CWRITEDATE = ? , IVERSION = ? , OPERATORTYPE = 1 WHERE CBILLID = ? AND CUSERID = ?", @(order), [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], @(SSJSyncVersion()), identifier, SSJUSERID()]) {
            if (success) {
                SSJDispatch_main_async_safe(^{
                    success();
                });
            }
        } else {
            if (failure) {
                SSJDispatch_main_async_safe(^{
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
                                          success:(void(^)(NSString *categoryId))success
                                          failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        // 检查当前用户有没有同名的收支类型
        if ([db boolForQuery:@"select count(*) from bk_user_bill as a, bk_bill_type as b where a.cbillid = b.id and a.cuserid = ? and a.operatortype <> 2 and b.cname = ?", SSJUSERID(), name]) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    NSError *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"已有相同名称了，换一个吧。"}];
                    failure(error);
                });
            }
            return;
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
        
        int maxOrder = [db intForQuery:@"select max(iorder) from bk_user_bill as a, bk_bill_type as b where a.cuserid = ? and a.istate = 1 and a.operatortype <> 2 and a.cbillid = b.id and b.itype = ?", SSJUSERID(), @(incomeOrExpenture)];
        if ([db executeUpdate:@"insert into bk_user_bill (cuserid, cbillid, istate, cwritedate, iversion, operatortype, iorder) values (?, ?, 1, ?, ?, 0, ?)", SSJUSERID(), newCategoryId, [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], @(SSJSyncVersion()), @(maxOrder + 1)]) {
            if (success) {
                SSJDispatch_main_async_safe(^{
                    success(newCategoryId);
                });
            }
        }
    }];
}

+ (NSArray *)payOutColors {
    return @[@"c55553", @"c6632f", @"a90868", @"d29361", @"a8a67e", @"006f5f", @"ac3b2b", @"6293b0", @"ab94c6", @"d96421", @"a74257", @"c1af65"];
}

+ (NSArray *)incomeColors {
    return @[@"f4a755", @"50b7c0", @"018792", @"c55553", @"7d5786", @"eb66a7", @"ac3b2b", @"6293b0", @"ab94c6", @"d96421", @"b3d236", @"c1af65"];
}

@end
