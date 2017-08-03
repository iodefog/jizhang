//
//  SSJAccountMergeTask.m
//  SuiShouJi
//
//  Created by ricky on 2017/8/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJAccountMergeTask.h"
#import <WCDB/WCDB.h>

@interface SSJAccountMergeTask()

@property (nonatomic, strong) WCTDatabase *db;

@end

@implementation SSJAccountMergeTask

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeDataIfNeeded) name:SSJSyncDataSuccessNotification object:nil];
}

- (void)mergeDataIfNeeded {
    
}

- (WCTDatabase *)db {
    if (!_db) {
        _db = [[WCTDatabase alloc] initWithPath:SSJSQLitePath()];
    }
    return _db;
}

@end
