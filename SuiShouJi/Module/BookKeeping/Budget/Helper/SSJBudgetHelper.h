//
//  SSJBudgetHelper.h
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJBudgetModel.h"

@interface SSJBudgetHelper : NSObject

+ (void)queryForCurrentBudgetListWithSuccess:(void(^)(NSArray<SSJBudgetModel *> *result))success
                                     failure:(void (^)(NSError *error))failure;

@end
