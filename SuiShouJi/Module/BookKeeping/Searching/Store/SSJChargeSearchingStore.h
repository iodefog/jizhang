//
//  SSJChargeSearchingStore.h
//  SuiShouJi
//
//  Created by ricky on 16/9/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJChargeSearchingStore : NSObject

typedef NS_ENUM(NSInteger, SSJChargeListOrder) {
    SSJChargeListOrderMoneyAscending,
    SSJChargeListOrderMoneyDescending,
    SSJChargeListOrderDateAscending,
    SSJChargeListOrderDateDescending
};

@end
