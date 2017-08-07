//
//  SSJDataMergeHelper.m
//  SuiShouJi
//
//  Created by 赵天立 on 2017/8/6.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJDataMergeHelper.h"
#import <WCDB/WCDB.h>
#import "SSJUserBaseTable.h"
#import "SSJUserChargeTable.h"

@interface SSJDataMergeHelper()

@property (nonatomic,strong) WCTDatabase *db;

@end

@implementation SSJDataMergeHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (WCTDatabase *)db {
    if (!_db) {
        _db = [[WCTDatabase alloc] initWithPath:SSJSQLitePath()];
    }
    return _db;
}

@end
