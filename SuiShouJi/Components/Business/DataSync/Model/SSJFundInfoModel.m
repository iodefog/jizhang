//
//  SSJFundInfoModel.m
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundInfoModel.h"

@implementation SSJFundInfoModel

//+ (instancetype)modelWithResultSet:(FMResultSet *)result {
//    SSJFundInfoModel *model = [super modelWithResultSet:result];
//    model.CFUNDID = [result stringForColumn:@"CFUNDID"];
//    model.CACCTNAME = [result stringForColumn:@"CACCTNAME"];
//    model.CICOIN = [result stringForColumn:@"CICOIN"];
//    model.CPARENT = [result stringForColumn:@"CPARENT"];
//    model.CCOLOR = [result stringForColumn:@"CCOLOR"];
//    model.CADDDATE = [result stringForColumn:@"CADDDATE"];
//    model.CMEMO = [result stringForColumn:@"CMEMO"];
//    model.CUSERID = [result stringForColumn:@"CUSERID"];
//    return model;
//}

+ (NSArray *)primaryKeys {
    return @[@"CFUNDID"];
}

@end
