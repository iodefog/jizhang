//
//  SSJUserChargeModel.m
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserChargeModel.h"

@implementation SSJUserChargeModel

//+ (instancetype)modelWithResultSet:(FMResultSet *)result {
//    SSJUserChargeModel *model = [super modelWithResultSet:result];
//    model.ICHARGEID = [result stringForColumn:@"ICHARGEID"];
//    model.CUSERID = [result stringForColumn:@"CUSERID"];
//    model.IMONEY = [result stringForColumn:@"IMONEY"];
//    model.IBILLID = [result stringForColumn:@"IBILLID"];
//    model.IFID = [result stringForColumn:@"IFID"];
//    model.CADDDATE = [result stringForColumn:@"CADDDATE"];
//    model.IOLDMONEY = [result stringForColumn:@"IOLDMONEY"];
//    model.IBALANCE = [result stringForColumn:@"IBALANCE"];
//    model.CBILLDATE = [result stringForColumn:@"CBILLDATE"];
//    return model;
//}

+ (NSArray *)primaryKeys {
    return @[@"ICHARGEID"];
}

@end
