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
                                  Success:(void(^)(NSDictionary *result))success
                                  failure:(void (^)(NSError *error))failure
{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *sql;
        switch (order) {
            case SSJChargeListOrderMoneyAscending:{
                sql = [NSString stringWithFormat:@"select * from bk_user_charge"];
                break;
            }
                
            case SSJChargeListOrderMoneyDescending:{
                
                break;
            }
                
            case SSJChargeListOrderDateAscending:{
                
                break;
            }
                
            case SSJChargeListOrderDateDescending:{
                
                break;
            }
                
            default:
                break;
        }
    }];
}
@end
