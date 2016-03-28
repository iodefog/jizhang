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

+ (void)queryForCategoryListWithCountForEachPage:(int)count IncomeOrExpenture:(int)incomeOrExpenture Success:(void(^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        int page = 0;
        NSMutableDictionary *categoryList =[NSMutableDictionary dictionary];
        NSString *countSql = [NSString stringWithFormat:@"select count(a.cbillid) from bk_user_bill as a , bk_bill_type as b where a.cuserid = '%@' and a.istate = 1 and b.itype = %d and a.cbillid = b.id",userId,incomeOrExpenture];
        int totalCount = [db intForQuery:countSql] + 1;
        if (totalCount % count == 0) {
            page = totalCount / count - 1;
        }else{
            page = totalCount / count;
        }
        for (int i = 0; i <= page; i++) {
            NSMutableArray *tempArray = [NSMutableArray array];
            NSString *sql = [NSString stringWithFormat:@"SELECT A.CNAME , A.CCOLOR , A.CCOIN , B.CWRITEDATE , A.ID FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE B.ISTATE = 1 AND A.ITYPE = %d AND A.ID = B.CBILLID AND B.CUSERID = '%@' ORDER BY B.CWRITEDATE , A.ID LIMIT %d OFFSET %d",incomeOrExpenture,userId,count,i*count];
            FMResultSet *result = [db executeQuery:sql];
            while ([result next]) {
                [tempArray addObject:[self recordMakingCategoryItemWithResultSet:result inDatabase:db]];
            }
            if (i == page) {
                SSJRecordMakingCategoryItem *item = [[SSJRecordMakingCategoryItem alloc]init];
                item.categoryTitle = @"添加";
                item.categoryImage = @"add";
                [tempArray addObject:item];
            }
            [categoryList setObject:tempArray forKey:[NSString stringWithFormat:@"page%d",i]];
        }
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
@end
