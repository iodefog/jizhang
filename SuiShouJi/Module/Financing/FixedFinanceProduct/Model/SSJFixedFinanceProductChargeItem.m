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
    SSJFixedFinanceProductChargeItem *item = [[SSJFixedFinanceProductChargeItem alloc] init];
    item.chargeId = [resultSet stringForColumn:@"ichargeid"];
    item.fundId = [resultSet stringForColumn:@"ifunsid"];
    item.billId = [resultSet stringForColumn:@"ibillid"];
//    item.userId = [resultSet stringForColumn:@"cuserid"];
    item.memo = [resultSet stringForColumn:@"cmemo"];
    item.billDate = [NSDate dateWithString:[resultSet stringForColumn:@"cbilldate"] formatString:@"yyyy-MM-dd"];
    item.writeDate = [NSDate dateWithString:[resultSet stringForColumn:@"cwritedate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
    item.money = [resultSet doubleForColumn:@"imoney"];
    item.cid = [resultSet stringForColumn:@"cid"];
    return item;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    SSJFixedFinanceProductChargeItem *item = [[SSJFixedFinanceProductChargeItem alloc] init];
    return item;
}

- (NSString *)debugDescription {
    return [self ssj_debugDescription];
}
@end
