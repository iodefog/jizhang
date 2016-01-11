//
//  SSJBillTypeModel.m
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBillTypeModel.h"

@implementation SSJBillTypeModel

//+ (instancetype)modelWithResultSet:(FMResultSet *)result {
//    SSJBillTypeModel *model = [super modelWithResultSet:result];
//    model.CBILLID = [result stringForColumn:@"result"];
//    model.CUSERID = [result stringForColumn:@"CUSERID"];
//    model.ISTATE = [result intForColumn:@"ISTATE"];
//    return model;
//}

+ (NSArray *)primaryKeys {
    return @[@"CBILLID", @"CUSERID"];
}

@end
