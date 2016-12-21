//
//  SSJDatabaseQueue.m
//  SuiShouJi
//
//  Created by old lang on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJDatabaseQueue.h"
#import "SSJDatabaseErrorHandler.h"

static const void * kSSJDatabaseQueueSpecificKey = &kSSJDatabaseQueueSpecificKey;

@interface SSJDatabaseQueue ()

@property (nonatomic, strong) dispatch_queue_t dataBaseQueue;

@end

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

- (instancetype)initWithPath:(NSString*)aPath flags:(int)openFlags vfs:(NSString *)vfsName {
    if (self = [super initWithPath:aPath flags:openFlags vfs:vfsName]) {
        self.dataBaseQueue = dispatch_queue_create("com.ShuiShouJi.SSJDatabaseQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(self.dataBaseQueue, kSSJDatabaseQueueSpecificKey, (__bridge void *)self, NULL);
    }
    return self;
}

- (void)inDatabase:(void (^)(FMDatabase *))block {
    [super inDatabase:^(FMDatabase *db) {
        if (block) {
            block(db);
        }
        
        NSError *error = [db lastError];
        if (error.code != 0) {
            [SSJDatabaseErrorHandler handleError:error];
        }
    }];
}

- (void)inTransaction:(void (^)(FMDatabase *, BOOL *))block {
    [super inTransaction:^(FMDatabase *db, BOOL *rollback) {
        BOOL shouldRollback;
        if (block) {
            block(db, &shouldRollback);
        }
        
        NSError *error = [db lastError];
        if (error.code != 0) {
            [SSJDatabaseErrorHandler handleError:error];
        }
        
        *rollback = shouldRollback;
    }];
}

- (void)inDeferredTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block {
    [super inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        BOOL shouldRollback;
        if (block) {
            block(db, &shouldRollback);
        }
        
        NSError *error = [db lastError];
        if (error.code != 0) {
            [SSJDatabaseErrorHandler handleError:error];
        }
        
        *rollback = shouldRollback;
    }];
}

- (void)asyncInDatabase:(void (^)(FMDatabase *db))block {
    SSJDatabaseQueue *currentDatabaseQueue = (__bridge id)dispatch_get_specific(kSSJDatabaseQueueSpecificKey);
    if (currentDatabaseQueue == self) {
        [self inDatabase:block];
    } else {
        dispatch_async(self.dataBaseQueue, ^{
            [self inDatabase:block];
        });
    }
}

- (void)asyncInTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block {
    SSJDatabaseQueue *currentDatabaseQueue = (__bridge id)dispatch_get_specific(kSSJDatabaseQueueSpecificKey);
    if (currentDatabaseQueue == self) {
        [self inTransaction:block];
    } else {
        dispatch_async(self.dataBaseQueue, ^{
            [self inTransaction:block];
        });
    }
}

- (void)asyncInDeferredTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block {
    SSJDatabaseQueue *currentDatabaseQueue = (__bridge id)dispatch_get_specific(kSSJDatabaseQueueSpecificKey);
    if (currentDatabaseQueue == self) {
        [self inDeferredTransaction:block];
    } else {
        dispatch_async(self.dataBaseQueue, ^{
            [self inDeferredTransaction:block];
        });
    }
}

@end
