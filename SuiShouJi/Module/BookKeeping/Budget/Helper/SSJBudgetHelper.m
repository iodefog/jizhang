//
//  SSJBudgetHelper.m
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetHelper.h"
#import "SSJDatabaseQueue.h"

@implementation SSJBudgetHelper

+ (void)queryForCurrentBudgetListWithSuccess:(void(^)(NSArray<SSJBudgetModel *> *result))success
                                     failure:(void (^)(NSError *error))failure {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDate = [formatter stringFromDate:[NSDate date]];
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSMutableArray *budgetList = [NSMutableArray array];
        FMResultSet *budgetResult = [db executeQuery:@"select ibid, itype, imoney, iremindmoney, csdate, cedate, istate from bk_user_budget where cuserid = ? and operatortype <> 2 and csdate <= ? and cedate >= ?", SSJUSERID(), currentDate, currentDate];
        
        if (!budgetResult) {
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        
        while ([budgetResult next]) {
            SSJBudgetModel *budgetModel = [[SSJBudgetModel alloc] init];
            budgetModel.ID = [budgetResult stringForColumn:@"ibid"];
            budgetModel.type = [budgetResult intForColumn:@"itype"];
            budgetModel.budgetMoney = [budgetResult doubleForColumn:@"imoney"];
            budgetModel.budgetMoney = [budgetResult doubleForColumn:@"iremindmoney"];
            budgetModel.beginDate = [budgetResult stringForColumn:@"csdate"];
            budgetModel.endDate = [budgetResult stringForColumn:@"cedate"];
            budgetModel.isAutoContinued = [budgetResult boolForColumn:@"istate"];
            budgetModel.payMoney = [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge as a, bk_bill_type as b where a.ibillid = b.id and a.cuserid = ? and a.operatortype <> 2 and (a.ibillid like '1___' or a.ibillid like '2___') and a.cbilldate >= ? and a.cbilldate <= ? and b.itype = 1", SSJUSERID(), budgetModel.beginDate, budgetModel.endDate];
            [budgetList addObject:budgetModel];
        }
        
        //  按照周、月、年的顺序排序
        [budgetList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            SSJBudgetModel *model1 = obj1;
            SSJBudgetModel *model2 = obj2;
            if (model1.type < model2.type) {
                return NSOrderedAscending;
            } else if (model1.type > model2.type) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }];
        
        SSJDispatch_main_async_safe(^{
            success(budgetList);
        });
    }];
}

//+ (void)query

@end
