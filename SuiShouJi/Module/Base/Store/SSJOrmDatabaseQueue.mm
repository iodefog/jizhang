//
//  SSJOrmDatabaseQueue.m
//  SuiShouJi
//
//  Created by ricky on 2017/8/25.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJOrmDatabaseQueue.h"
#import "SSJDatabaseErrorHandler.h"

static const void * kSSJOrmDatabaseQueueSpecificKey = &kSSJOrmDatabaseQueueSpecificKey;

@implementation SSJOrmDatabaseQueue {
    WCTDatabase *_db;
}

+ (instancetype)sharedInstance {
    static SSJOrmDatabaseQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!queue) {
            queue = [[SSJOrmDatabaseQueue alloc] init];
        }
    });
    return queue;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ormDatabaseQueue = dispatch_queue_create("com.ShuiShouJi.SSJOrmDatabaseQueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_queue_set_specific(self.ormDatabaseQueue, kSSJOrmDatabaseQueueSpecificKey, (__bridge void *)self, NULL);
        [WCTStatistics SetGlobalErrorReport:^(WCTError *error) {
            NSString *desc = [NSString stringWithFormat:@"code:%@  description:%@  sql:%@", [error infoForKey:WCTErrorKeyExtendedCode], error.localizedDescription, [error infoForKey:WCTErrorKeySQL]];
            NSError *customError = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:desc}];
            [SSJDatabaseErrorHandler handleError:customError];
        }];
        
        [WCTStatistics SetGlobalSQLTrace:^(NSString *sql) {
            NSLog(@"SQL: %@", sql);
        }];
    }
    return self;
}

- (WCTDatabase *)database {
    if (!_db){
        _db = [[WCTDatabase alloc] initWithPath:SSJSQLitePath()];
    }
    return _db;
}

- (void)inDatabase:(void (^)(WCTDatabase *_db))block {
    dispatch_sync(self.ormDatabaseQueue, ^{
        WCTDatabase *db = [self database];
        block(db);
    });
}

- (void)asyncInDatabase:(void (^)(WCTDatabase *db))block {
    SSJOrmDatabaseQueue *currentDatabaseQueue = (__bridge id) dispatch_get_specific(kSSJOrmDatabaseQueueSpecificKey);
    if (currentDatabaseQueue == self) {
        [self inDatabase:block];
    } else {
        dispatch_async(self.ormDatabaseQueue, ^{
            [self inDatabase:block];
        });
    }
}

@end
