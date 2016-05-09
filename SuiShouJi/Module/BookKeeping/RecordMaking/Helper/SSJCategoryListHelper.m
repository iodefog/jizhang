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

@implementation SSJCategoryListHelper

+ (void)queryForCategoryListWithIncomeOrExpenture:(int)incomeOrExpenture
                                          Success:(void(^)(NSMutableArray<SSJRecordMakingBillTypeSelectionCellItem *> *result))success
                                          failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        NSMutableArray *categoryList =[NSMutableArray array];
        NSString *sql = [NSString stringWithFormat:@"SELECT A.CNAME , A.CCOLOR , A.CCOIN , B.CWRITEDATE , A.ID FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE B.ISTATE = 1 AND A.ITYPE = %d AND A.ID = B.CBILLID AND B.CUSERID = '%@' ORDER BY B.CWRITEDATE , A.ID",incomeOrExpenture,userId];
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
