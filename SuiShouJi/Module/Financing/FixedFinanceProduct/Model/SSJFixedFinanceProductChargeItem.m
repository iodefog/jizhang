//
//  SSJFixedFinanceProductChargeItem.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanceProductChargeItem.h"
#import "FMResultSet.h"

@implementation SSJFixedFinanceProductChargeItem

+ (instancetype)modelWithResultSet:(FMResultSet *)resultSet;
{
    return nil;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    SSJFixedFinanceProductChargeItem *item = [[SSJFixedFinanceProductChargeItem alloc] init];
    return item;
}

- (NSString *)debugDescription {
    return [self ssj_debugDescription];
}
@end
