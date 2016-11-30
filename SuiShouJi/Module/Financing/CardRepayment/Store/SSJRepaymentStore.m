//
//  SSJRepaymentStore.m
//  SuiShouJi
//
//  Created by ricky on 2016/11/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRepaymentStore.h"
#import "SSJDatabaseQueue.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJRepaymentModel.h"

@implementation SSJRepaymentStore

+ (SSJRepaymentModel *)queryRepaymentModelWithChargeItem:(SSJBillingChargeCellItem *)item{
    __block SSJRepaymentModel *model = [[SSJRepaymentModel alloc]init];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        if (item.idType == SSJChargeIdTypeRepayment) {
            // 如果有还款id,则为账单分期,若没有,则是还款
            if (item.sundryId.length) {
                FMResultSet *resultSet = [db executeQuery:@""];
                while ([resultSet next]) {
                    
                }
            }else{
                
            }
        }
    }];
    return model;
}

@end
