//
//  SSJChargeSearchingStore.m
//  SuiShouJi
//
//  Created by ricky on 16/9/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJChargeSearchingStore.h"
#import "SSJDatabaseQueue.h"
#import "SSJBillingChargeCellItem.h"

@implementation SSJChargeSearchingStore

+ (void)searchForChargeListWithSearchContent:(NSString *)content
                                   ListOrder:(SSJChargeListOrder)order
                                  Success:(void(^)(NSArray <SSJSearchResultItem *>*result))success
                                  failure:(void (^)(NSError *error))failure
{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        NSString *lastBillDate = @"";
        NSString *currentBookId = [db stringForQuery:@"select CCURRENTBOOKSID from bk_user where cuserid = ?",userId];
        NSMutableArray *tempArr = [NSMutableArray array];
        if (!currentBookId.length) {
            currentBookId = userId;
        }
        NSMutableString *sql = [NSMutableString stringWithFormat:@"select a.*, b.cname, b.istate, b.ccoin, b.ccolor from bk_user_charge a, bk_bill_type b where a.operatortype <> 2 and a.cuserid = '%@' and a.cbooksid = '%@' and a.cmemo like '%%%@%%' or b.cname like '%%%@%%' and a.ibillid = b.id and b.istate <> 2 and a.cbilldate <= '%@' and b.istate <> 2",userId,currentBookId,content,content,[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"]];
        switch (order) {
            case SSJChargeListOrderMoneyAscending:{
                [sql appendString:@" order by a.imoney asc"];
                break;
            }
                
            case SSJChargeListOrderMoneyDescending:{
                [sql appendString:@" order by a.imoney desc"];
                break;
            }
                
            case SSJChargeListOrderDateAscending:{
                [sql appendString:@" order by a.cbilldate asc"];
                break;
            }
                
            case SSJChargeListOrderDateDescending:{
                [sql appendString:@" order by a.cbilldate desc"];
                break;
            }
                
            default:
                break;  
        }
        FMResultSet *resultSet = [db executeQuery:sql];
        if (!resultSet) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
        }
        while ([resultSet next]) {
            SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
            item.imageName = [resultSet stringForColumn:@"CCOIN"];
            item.typeName = [resultSet stringForColumn:@"CNAME"];
            item.colorValue = [resultSet stringForColumn:@"CCOLOR"];
            item.ID = [resultSet stringForColumn:@"ICHARGEID"];
            item.fundId = [resultSet stringForColumn:@"IFUNSID"];
            item.billDate = [resultSet stringForColumn:@"CBILLDATE"];
            item.billId = [resultSet stringForColumn:@"IBILLID"];
            item.chargeMemo = [resultSet stringForColumn:@"cmemo"];
            item.chargeImage = [resultSet stringForColumn:@"cimgurl"];
            item.chargeThumbImage = [resultSet stringForColumn:@"thumburl"];
            item.configId = [resultSet stringForColumn:@"iconfigid"];
            item.booksId = [resultSet stringForColumn:@"cbooksid"];
            item.loanId = [resultSet stringForColumn:@"loanid"];
            if (item.incomeOrExpence && ![item.money hasPrefix:@"-"]) {
                item.money = [NSString stringWithFormat:@"-%.2f",[[resultSet stringForColumn:@"IMONEY"] doubleValue]];
            }else if(!item.incomeOrExpence && ![item.money hasPrefix:@"+"]){
                item.money = [NSString stringWithFormat:@"+%.2f",[[resultSet stringForColumn:@"IMONEY"] doubleValue]];
            }
            if (![item.billDate isEqualToString:lastBillDate]) {
                SSJSearchResultItem *searchItem = [[SSJSearchResultItem alloc]init];
                searchItem.date = item.billDate;
                if (order == SSJChargeListOrderMoneyAscending || order == SSJChargeListOrderMoneyDescending) {
                    searchItem.balance = [item.money doubleValue];
                }
                searchItem.chargeList = [NSMutableArray arrayWithObject:item];
                lastBillDate = item.billDate;
                [tempArr addObject:searchItem];
            }else{
                SSJSearchResultItem *searchItem = [tempArr lastObject];
                if (order == SSJChargeListOrderMoneyAscending || order == SSJChargeListOrderMoneyDescending) {
                    searchItem.balance =  searchItem.balance + [item.money doubleValue];
                }
                [searchItem.chargeList addObject:item];
                lastBillDate = item.billDate;
            }
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(tempArr);
            });
        }
    }];
}

+ (void)querySearchHistoryWithSuccess:(void(^)(NSArray <SSJSearchHistoryItem *>*result))success
                                     failure:(void (^)(NSError *error))failure
{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
        FMResultSet *resultSet = [db executeQuery:@"select * from bk_search_history where cuserid = ?",userId];
        if (!resultSet) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
        }
        while ([resultSet next]) {
            SSJSearchHistoryItem *item = [[SSJSearchHistoryItem alloc]init];
            item.searchHistory = [resultSet stringForColumn:@"csearchcontent"];
            [tempArr addObject:item];
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(tempArr);
            });
        }
    }];
}
@end
