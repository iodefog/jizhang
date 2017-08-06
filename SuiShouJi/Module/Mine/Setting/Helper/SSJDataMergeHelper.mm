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

- (NSDictionary *)getStartAndEndChargeDataForUnloggedUser {
    NSMutableDictionary *dateDic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *unLoggedUserId;
    SSJUserBaseTable *unloggedUser = [self.db getOneObjectOfClass:SSJUserBaseTable.class fromTable:@"BK_USER" where:SSJUserBaseTable.registerState == 0];
    unLoggedUserId = unloggedUser.userId;
    
    NSString *maxDate = [self.db getOneValueOnResult:SSJUserChargeTable.billDate.max() fromTable:@"BK_USER_CHARGE"
                                               where:SSJUserChargeTable.operatorType != 2
                         && SSJUserChargeTable.userId == unLoggedUserId && SSJUserChargeTable.writeDate <= [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"]];
    
    NSString *minDate = [self.db getOneValueOnResult:SSJUserChargeTable.billDate.min() fromTable:@"BK_USER_CHARGE"
                                               where:SSJUserChargeTable.operatorType != 2
                         && SSJUserChargeTable.userId == unLoggedUserId && SSJUserChargeTable.writeDate <= [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"]];
    
    [dateDic setObject:maxDate forKey:@"maxDate"];
    
    [dateDic setObject:minDate forKey:@"minDate"];

    return dateDic;
    
}

- (WCTDatabase *)db {
    if (!_db) {
        _db = [[WCTDatabase alloc] initWithPath:SSJSQLitePath()];
    }
    return _db;
}

@end
