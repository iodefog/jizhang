
//
//  SSJAccountMergeManager.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJAccountMergeManager.h"
#import <WCDB/WCDB.h>
#import "SSJUserChargeTableMerge.h"
#import "SSJBooksTypeTableMerge.h"

@interface SSJAccountMergeManager()

@property (nonatomic, strong) WCTDatabase *db;

@end

@implementation SSJAccountMergeManager

- (void)startMergeWithSourceUserId:(NSString *)sourceUserId
                      targetUserId:(NSString *)targetUserId
                         startDate:(NSString *)startDate
                           endDate:(NSString *)endDate
                           Success:(void(^)())success
                           failure:(void (^)(NSError *error))failure {
    [self.db runTransaction:^BOOL{
        
        
        return YES;
    }];
    
}

- (WCTDatabase *)db {
    if (!_db) {
        _db = [[WCTDatabase alloc] initWithPath:SSJSQLitePath()];
    }
    return _db;
}

- (void)creatTempleTableInDataBase:(WCTDatabase *)db {
    [db createTableAndIndexesOfName:@"temp_user_charge" withClass:SSJUserChargeTable.class];
    [db createTableAndIndexesOfName:@"temp_books_type" withClass:SSJBooksTypeTableMerge.class];
}

@end

