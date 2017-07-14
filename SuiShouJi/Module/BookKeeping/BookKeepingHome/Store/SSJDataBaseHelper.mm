//
//  SSJDataBaseHelper.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/14.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJDataBaseHelper.h"
#import <WCDB/WCDB.h>
#import "SSJUserChargeMergeTable.h"

@interface SSJDataBaseHelper()

@property (nonatomic, strong) WCTDatabase *db;

@end

@implementation SSJDataBaseHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        bool isExist = NO;
        isExist = [self.db isTableExists:@"bk_user_charge"];
        NSArray<SSJUserChargeMergeTable *> *message = [self.db getObjectsOfClass:SSJUserChargeMergeTable.class
                                                                       fromTable:@"bk_user_charge"
                                                                         where:SSJUserChargeMergeTable.userId == SSJUSERID() && SSJUserChargeMergeTable.operatorType != 2];
        
        
        NSLog(@"%@",message);
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
