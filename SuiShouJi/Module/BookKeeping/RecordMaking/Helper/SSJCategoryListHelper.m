//
//  SSJCategoryListHelper.m
//  SuiShouJi
//
//  Created by ricky on 16/3/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCategoryListHelper.h"
#import "SSJDatabaseQueue.h"

@implementation SSJCategoryListHelper

+ (void)queryForCategoryListWithIncomeOrExpenture:(int)incomeOrExpenture
                                          Success:(void(^)(NSMutableArray *result))success
                                          failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        NSMutableArray *categoryList =[NSMutableArray array];
        NSString *sql = [NSString stringWithFormat:@"SELECT A.CNAME , A.CCOLOR , A.CCOIN , B.CWRITEDATE , A.ID FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE B.ISTATE = 1 AND A.ITYPE = %d AND A.ID = B.CBILLID AND B.CUSERID = '%@' ORDER BY B.CWRITEDATE , A.ID",incomeOrExpenture,userId];
            FMResultSet *result = [db executeQuery:sql];
            while ([result next]) {
                [categoryList addObject:[self recordMakingCategoryItemWithResultSet:result inDatabase:db]];
            }
            SSJRecordMakingCategoryItem *item = [[SSJRecordMakingCategoryItem alloc]init];
            item.categoryTitle = @"添加";
            item.categoryImage = @"add";
            [categoryList addObject:item];
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(categoryList);
            });
        }
    }];
}

+ (SSJRecordMakingCategoryItem *)recordMakingCategoryItemWithResultSet:(FMResultSet *)set inDatabase:(FMDatabase *)db {
    SSJRecordMakingCategoryItem *item = [[SSJRecordMakingCategoryItem alloc]init];
    item.categoryTitle = [set stringForColumn:@"CNAME"];
    item.categoryImage = [set stringForColumn:@"CCOIN"];
    item.categoryColor = [set stringForColumn:@"CCOLOR"];
    item.categoryID = [set stringForColumn:@"ID"];
    return item;
}

+ (void)deleteCategoryWithCategoryId:(NSString *)categoryId
                             Success:(void(^)(BOOL result))success
                             failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSString *sql = [NSString stringWithFormat:@"update bk_user_bill set istate = 0 where cbillid = '%@' and cuserid = '%@'",categoryId,userid];
        BOOL deletesucess = [db executeUpdate:sql];
        if (failure) {
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
        }else{
            SSJDispatch_main_async_safe(^{
                success(deletesucess);
            });
        }
    }];
}
@end
