//
//  SSJDatabaseQueue.m
//  SuiShouJi
//
//  Created by old lang on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJDatabaseQueue.h"

@implementation SSJDatabaseQueue

+ (instancetype)sharedInstance {
    static SSJDatabaseQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!queue) {
            queue = [[SSJDatabaseQueue alloc] initWithPath:SSJSQLitePath()];
        }
    });
    return queue;
}

- (void)asyncInDatabase:(void (^)(FMDatabase *db))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self inDatabase:block];
    });
}

- (void)asyncInTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self inTransaction:block];
    });
}

- (void)asyncInDeferredTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self inDeferredTransaction:block];
    });
}

@end
