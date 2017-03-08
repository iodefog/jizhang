//
//  SSJFinancingStore.h
//  SuiShouJi
//
//  Created by ricky on 2017/3/8.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJFinancingHomeitem.h"

@interface SSJFinancingStore : NSObject

+ (void)saveFundingItem:(SSJFinancingHomeitem *)item
                Success:(void (^)(SSJFinancingHomeitem *item))success
                failure:(void (^)(NSError *error))failure;

@end
