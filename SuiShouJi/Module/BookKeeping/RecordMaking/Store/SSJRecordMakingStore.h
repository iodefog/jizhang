//
//  SSJRecordMakingStore.h
//  SuiShouJi
//
//  Created by ricky on 16/6/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJBillingChargeCellItem.h"
#import "SSJChargeMemberItem.h"

@interface SSJRecordMakingStore : NSObject

+ (void)saveChargeWithChargeItem:(SSJBillingChargeCellItem *)item
                         Success:(void(^)(SSJBillingChargeCellItem *editeItem))success
                         failure:(void (^)())failure;
@end
